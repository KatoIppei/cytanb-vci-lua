----------------------------------------------------------------
--  Copyright (c) 2019 oO (https://github.com/oocytanb)
--  MIT Licensed
----------------------------------------------------------------

-- [VCI](https://github.com/virtual-cast/VCI) 環境の簡易 Fake モジュール。
-- Unit test を行うための、補助モジュールとしての利用を目的としている。
-- 実環境を忠実にエミュレートするものではなく、挙動が異なる部分が多分にあるため、その点に留意して利用する必要がある。
-- (例えば、3D オブジェクトの物理演算は行われない、ネットワーク通信は行われずローカルのインメモリーで処理される、など)
-- **EXPERIMENTAL: 実験的なモジュールであるため、多くの変更が加えられる可能性がある。**

return (function ()
	local dkjson = require('dkjson')

	-- @see cytanb.SetConst
	local SetConst = function (target, name, value)
		if type(target) ~= 'table' then
			error('Cannot set const to non-table target')
		end

		local curMeta = getmetatable(target)
		local meta = curMeta or {}
		local hasMetaIndex = type(meta.__index) == 'table'
		if target[name] ~= nil and (not hasMetaIndex or meta.__index[name] == nil) then
			error('Non-const field "' .. name .. '" already exists')
		end

		if not hasMetaIndex then
			meta.__index = {}
		end
		local metaIndex = meta.__index
		metaIndex[name] = value

		if not hasMetaIndex or type(meta.__newindex) ~= 'function' then
			meta.__newindex = function (table, key, v)
				if table == target and metaIndex[key] ~= nil then
					error('Cannot assign to read only field "' .. key .. '"')
				end
				rawset(table, key, v)
			end
		end

		if not curMeta then
			setmetatable(target, meta)
		end

		return target
	end

	local ModuleName = 'cytanb_fake_vci'
	local StringModuleName = 'string'
	local moonsharpAdditions = {_MOONSHARP = true, json = true}

	local currentVciName = ModuleName
	local stateMap = {}
	local studioSharedMap = {}
	local studioSharedCallbackMap = {}

	local messageCallbackMap = {}

	local fakeModule, Color, vci

	local ColorMetatable = {
		__add = function (op1, op2)
			return Color.__new(op1.r + op2.r, op1.g + op2.g, op1.b + op2.b, op1.a + op2.a)
		end,

		__sub = function (op1, op2)
			return Color.__new(op1.r - op2.r, op1.g - op2.g, op1.b - op2.b, op1.a - op2.a)
		end,

		__mul = function (op1, op2)
			return Color.__new(op1.r * op2.r, op1.g * op2.g, op1.b * op2.b, op1.a * op2.a)
		end,

		__div = function (op1, op2)
			return Color.__new(op1.r / op2, op1.g / op2, op1.b / op2, op1.a / op2)
		end,

		__eq = function (op1, op2)
			return op1.r == op2.r and op1.g == op2.g and op1.b == op2.b and op1.a == op2.a
		end,

		__index = function (table, key)
			if key == 'gamma' then
				error('!!NOT IMPLEMENTED!!')
			elseif key == 'grayscale' then
				error('!!NOT IMPLEMENTED!!')
			elseif key == 'linear' then
				error('!!NOT IMPLEMENTED!!')
			elseif key == 'maxColorComponent' then
				return math.max(table.r, table.g, table.b)
			else
				error('Cannot access field "' .. key .. '"')
			end
		end,

		__newindex = function (table, key, v)
			error('Cannot assign to field "' .. key .. '"')
		end,

		__tostring = function (value)
			return value.ToString()
		end
	}

	fakeModule = {
		-- [MoonSharp](https://www.moonsharp.org/additions.html) の拡張。
		_MOONSHARP = {
			version = '2.0.0.0',
			luacompat = string.match(_VERSION or '', '(%d+(%.%d+))') or '',
			platform = 'limited.unity.dll.mono.clr4.aot',
			is_aot = true,
			is_unity = true,
			is_mono = true,
			is_clr4 = true,
			is_pcl = false,
			banner = 'cytanb_fake_vci | Copyright (c) 2019 oO (https://github.com/oocytanb) | MIT Licensed'
		},

		-- [MoonSharp](https://www.moonsharp.org/additions.html) の拡張。
		string = {
			contains = function (str1, str2)
				return string.find(str1, str2, 1, true) ~= nil
			end,

			startsWith = function (str1, str2)
				local len1 = string.len(str1)
				local len2 = string.len(str2)
				if len1 < len2 then
					return false
				elseif len2 == 0 then
					return true
				end

				return str2 == string.sub(str1, 1, len2)
			end,

			endsWith = function (str1, str2)
				local len1 = string.len(str1)
				local len2 = string.len(str2)
				if len1 < len2 then
					return false
				elseif len2 == 0 then
					return true
				end

				local i = string.find(str1, str2, - len2, true)
				return i ~= nil
			end
		},

		-- [MoonSharp](https://www.moonsharp.org/additions.html) の拡張。
		json = {
			parse = function (jsonString)
				return dkjson.decode(jsonString, 1, dkjson.null)
			end,

			serialize = function (table)
				local t = type(table)
				if t ~= 'table' then
					error('Invalid type: ' .. t)
				end
				return dkjson.encode(table)
			end,

			isNull = function (val)
				return val == dkjson.null
			end,

			null = function ()
				return dkjson.null
			end
		},

		Color = {
			__new = function (r, g, b, a)
				local rgbSpecified = r and g and b
				local self
				self = {
					r = rgbSpecified and r or 0.0,
					g = rgbSpecified and g or 0.0,
					b = rgbSpecified and b or 0.0,
					a = rgbSpecified and (a or 1.0) or 0.0,
					ToString = function (format)
						if format then
							error('!!NOT IMPLEMENTED!!')
						end
						return string.format('RGBA(%.3f, %.3f, %.3f, %.3f)', self.r, self.g, self.b, self.a)
					end,

					GetHashCode = function ()
						error('!!NOT IMPLEMENTED!!')
					end,
				}
				setmetatable(self, ColorMetatable)
				return self
			end,

			HSVToRGB = function (H, S, V)
				error('!!NOT IMPLEMENTED!!')
			end,

			Lerp = function (a, b, t)
				error('!!NOT IMPLEMENTED!!')
			end,

			LerpUnclamped = function (a, b, t)
				error('!!NOT IMPLEMENTED!!')
			end,

			__toVector4 = function (color)
				error('!!NOT IMPLEMENTED!!')
			end,

			__toColor = function (vec4)
				error('!!NOT IMPLEMENTED!!')
			end
		},

		-- [VirtualCast Official Wiki](https://virtualcast.jp/wiki/)
		vci = {
			assets = {},

			state = {
				Set = function (name, value)
					local nv
					local t = type(value)
					if (t == 'number' or t == 'string' or t == 'boolean') then
						nv = value
					else
						nv = nil
					end
					stateMap[name] = nv
				end,

				Get = function (name)
					return stateMap[name]
				end,

				Add = function (name, value)
					if type(value) == 'number' then
						local curValue = stateMap[name]
						if type(curValue) == 'number' then
							stateMap[name] = curValue + value
						else
							stateMap[name] = value
						end
					end
				end
			},

			studio = {
				shared = {
					Set = function (name, value)
						local nv
						local t = type(value)
						if (t == 'number' or t == 'string' or t == 'boolean') then
							nv = value
						else
							nv = nil
						end

						local changed = studioSharedMap[name] ~= nv
						studioSharedMap[name] = nv
						if changed then
							local cbMap = studioSharedCallbackMap[name]
							if cbMap then
								for cb, v in pairs(cbMap) do
									cb(nv)
								end
							end
						end
					end,

					Get = function (name)
						return studioSharedMap[name]
					end,

					Add = function (name, value)
						if type(value) == 'number' then
							local curValue = studioSharedMap[name]
							local nv
							if type(curValue) == 'number' then
								nv = curValue + value
							else
								nv = value
							end

							local changed = studioSharedMap[name] ~= nv
							studioSharedMap[name] = nv
							if changed then
								local cbMap = studioSharedCallbackMap[name]
								if cbMap then
									for cb, v in pairs(cbMap) do
										cb(nv)
									end
								end
							end
						end
					end,

					Bind = function (name, callback)
						if not studioSharedCallbackMap[name] then
							studioSharedCallbackMap[name] = {}
						end
						studioSharedCallbackMap[name][callback] = true
					end
				}
			},

			message = {
				On = function (messageName, callback)
					if not messageCallbackMap[messageName] then
						messageCallbackMap[messageName] = {}
					end
					messageCallbackMap[messageName][callback] = true
				end,

				Emit = function (messageName, ...)
					if select('#', ...) < 1 then
						-- value 引数が指定されない場合は、処理しない。
						return
					end

					local value = ...
					local nv
					local t = type(value)
					if (t == 'number' or t == 'string' or t == 'boolean') then
						nv = value
					elseif (t == 'nil' or t == 'table' or t == 'userdata') then
						nv = nil
					else
						-- その他の型の場合は処理しない。
						return
					end

					vci.fake.EmitVciMessage(currentVciName, messageName, nv)
				end
			},

			-- fake module
			fake = {
				Setup = function (target)
					for k, v in pairs(fakeModule) do
						if moonsharpAdditions[k] then
							if target[k] == nil then
								target[k] = v
							end
						elseif k ~= StringModuleName then
							target[k] = v
						end
					end

					for k, v in pairs(fakeModule[StringModuleName]) do
						if target[StringModuleName][k] == nil then
							target[StringModuleName][k] = v
						end
					end

					package.loaded[ModuleName] = fakeModule
				end,

				Teardown = function (target)
					for k, v in pairs(fakeModule) do
						if k ~= StringModuleName and target[k] == v then
							target[k] = nil
						end
					end

					for k, v in pairs(fakeModule[StringModuleName]) do
						if target[StringModuleName][k] == v then
							target[StringModuleName][k] = nil
						end
					end

					package.loaded[ModuleName] = nil
				end,

				SetVciName = function (name)
					currentVciName = tostring(name)
				end,

				GetVciName = function ()
					return currentVciName
				end,

				SetAssetsIsMine = function (mine)
					SetConst(vci.assets, 'IsMine', mine and true or nil)
				end,

				ClearState = function ()
					stateMap = {}
				end,

				UnbindStudioShared = function (name, callback)
					local cbMap = studioSharedCallbackMap[name]
					if cbMap and cbMap[callback] then
						cbMap[callback] = nil
					end
				end,

				ClearStudioShared = function ()
					studioSharedMap = {}
					studioSharedCallbackMap = {}
				end,

				EmitRawMessage = function (sender, messageName, value)
					local cbMap = messageCallbackMap[messageName]
					if cbMap then
						for cb, v in pairs(cbMap) do
							cb(sender, messageName, value)
						end
					end
				end,

				EmitVciMessage = function (vciName, messageName, value)
					vci.fake.EmitRawMessage({type = 'vci', name = vciName}, messageName, value)
				end,

				EmitCommentMessage = function (userName, value)
					vci.fake.EmitRawMessage({type = 'comment', name = userName or ''}, 'comment', tostring(value))
				end,

				OffMessage = function (messageName, callback)
					local cbMap = messageCallbackMap[messageName]
					if cbMap and cbMap[callback] then
						cbMap[callback] = nil
					end
				end,

				ClearMessage = function ()
					messageCallbackMap = {}
				end
			}
		}
	}

	Color = fakeModule.Color
	SetConst(Color, 'black', Color.__new(0, 0, 0, 1))
	SetConst(Color, 'blue', Color.__new(0, 0, 1, 1))
	SetConst(Color, 'blue', Color.__new(0, 0, 1, 1))
	SetConst(Color, 'clear', Color.__new(0, 0, 0, 0))
	SetConst(Color, 'cyan', Color.__new(0, 1, 1, 1))
	SetConst(Color, 'gray', Color.__new(0.5, 0.5, 0.5, 1))
	SetConst(Color, 'magenta', Color.__new(1, 0, 1, 1))
	SetConst(Color, 'red', Color.__new(1, 0, 0, 1))
	SetConst(Color, 'white', Color.__new(1, 1, 1, 1))
	SetConst(Color, 'yellow', Color.__new(1, 0.921568632125854, 0.0156862754374743, 1))

	vci = fakeModule.vci

	vci.fake.SetAssetsIsMine(true)

	return fakeModule
end)()
