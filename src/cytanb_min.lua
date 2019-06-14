-- cytanb | Copyright (c) 2019 oO (https://github.com/oocytanb) | MIT Licensed
---@type cytanb @See `cytanb_annotations.lua`
local cytanb=(function()math.randomseed(os.time()-os.clock()*10000)local b=function(c,d)setmetatable(c,{__index=d,__newindex=function(table,e,f)if table==c and d[e]~=nil then error('Cannot assign to read only field "'..e..'"')end;rawset(table,e,f)end})return c end;local g={FatalLogLevel=100,ErrorLogLevel=200,WarnLogLevel=300,InfoLogLevel=400,DebugLogLevel=500,TraceLogLevel=600,ColorHueSamples=10,ColorSaturationSamples=4,ColorBrightnessSamples=5,ColorMapSize=10*4*5,NegativeNumberTag='#__CYTANB_NEGATIVE_NUMBER',InstanceIDParameterName='__CYTANB_INSTANCE_ID'}local h='__CYTANB_INSTANCE_ID'local i=400;local j;local a;a={InstanceID=function()if j==''then j=vci.state.Get(h)or''end;return j end,Extend=function(k,l,m,n,o)if k==l or type(k)~='table'or type(l)~='table'then return k end;if m then if not o then o={}end;if o[l]then error('circular reference')end;o[l]=true end;for p,q in pairs(l)do if m and type(q)=='table'then local r=k[p]k[p]=a.Extend(type(r)=='table'and r or{},q,m,n,o)else k[p]=q end end;if not n then local s=getmetatable(l)if type(s)=='table'then if m then local t=getmetatable(k)setmetatable(k,a.Extend(type(t)=='table'and t or{},s,true))else setmetatable(k,s)end end end;if m then o[l]=nil end;return k end,Vars=function(q,u,v,o)local w;if u then w=u~='__NOLF'else u='  'w=true end;if not v then v=''end;if not o then o={}end;local x=type(q)if x=='table'then o[q]=o[q]and o[q]+1 or 1;local y=w and v..u or''local z='('..tostring(q)..') {'local A=true;for e,B in pairs(q)do if A then A=false else z=z..(w and','or', ')end;if w then z=z..'\n'..y end;if type(B)=='table'and o[B]and o[B]>0 then z=z..e..' = ('..tostring(B)..')'else z=z..e..' = '..a.Vars(B,u,y,o)end end;if not A and w then z=z..'\n'..v end;z=z..'}'o[q]=o[q]-1;if o[q]<=0 then o[q]=nil end;return z elseif x=='function'or x=="thread"or x=="userdata"then return'('..x..')'elseif x=='string'then return'('..x..') '..string.format('%q',q)else return'('..x..') '..tostring(q)end end,GetLogLevel=function()return i end,SetLogLevel=function(C)i=C end,Log=function(C,...)if C<=i then local D=table.pack(...)if D.n==1 then local q=D[1]if q~=nil then print(type(q)=='table'and a.Vars(q)or tostring(q))else print('')end else local z=''for E=1,D.n do local q=D[E]if q~=nil then z=z..(type(q)=='table'and a.Vars(q)or tostring(q))end end;print(z)end end end,FatalLog=function(...)a.Log(g.FatalLogLevel,...)end,ErrorLog=function(...)a.Log(g.ErrorLogLevel,...)end,WarnLog=function(...)a.Log(g.WarnLogLevel,...)end,InfoLog=function(...)a.Log(g.InfoLogLevel,...)end,DebugLog=function(...)a.Log(g.DebugLogLevel,...)end,TraceLog=function(...)a.Log(g.TraceLogLevel,...)end,ListToMap=function(F,G)local table={}local H=G==nil;for p,q in pairs(F)do table[q]=H and q or G end;return table end,Random32=function()return math.random(-2147483648,2147483646)end,RandomUUID=function()return{a.Random32(),bit32.bor(0x4000,bit32.band(a.Random32(),0xFFFF0FFF)),bit32.bor(0x80000000,bit32.band(a.Random32(),0x3FFFFFFF)),a.Random32()}end,UUIDString=function(I)local J=I[2]or 0;local K=I[3]or 0;return string.format('%08x-%04x-%04x-%04x-%04x%08x',bit32.band(I[1]or 0,0xFFFFFFFF),bit32.band(bit32.rshift(J,16),0xFFFF),bit32.band(J,0xFFFF),bit32.band(bit32.rshift(K,16),0xFFFF),bit32.band(K,0xFFFF),bit32.band(I[4]or 0,0xFFFFFFFF))end,ColorFromARGB32=function(L)local M=type(L)=='number'and L or 0xFF000000;return Color.__new(bit32.band(bit32.rshift(M,16),0xFF)/0xFF,bit32.band(bit32.rshift(M,8),0xFF)/0xFF,bit32.band(M,0xFF)/0xFF,bit32.band(bit32.rshift(M,24),0xFF)/0xFF)end,ColorToARGB32=function(N)return bit32.bor(bit32.lshift(math.floor(255*N.a+0.5),24),bit32.lshift(math.floor(255*N.r+0.5),16),bit32.lshift(math.floor(255*N.g+0.5),8),math.floor(255*N.b+0.5))end,ColorFromIndex=function(O,P,Q,R,S)local T=math.max(math.floor(P or g.ColorHueSamples),1)local U=S and T or T-1;local V=math.max(math.floor(Q or g.ColorSaturationSamples),1)local W=math.max(math.floor(R or g.ColorBrightnessSamples),1)local X=math.max(math.min(math.floor(O or 0),T*V*W-1),0)local Y=X%T;local Z=math.floor(X/T)local _=Z%V;local a0=math.floor(Z/V)if S or Y~=U then local a1=Y/U;local a2=(V-_)/V;local q=(W-a0)/W;return Color.HSVToRGB(a1,a2,q)else local q=(W-a0)/W*_/(V-1)return Color.HSVToRGB(0.0,0.0,q)end end,GetSubItemTransform=function(a3)local a4=a3.GetPosition()local a5=a3.GetRotation()local a6=a3.GetLocalScale()return{positionX=a4.x,positionY=a4.y,positionZ=a4.z,rotationX=a5.x,rotationY=a5.y,rotationZ=a5.z,rotationW=a5.w,scaleX=a6.x,scaleY=a6.y,scaleZ=a6.z}end,TableToSerialiable=function(a7,o)if type(a7)~='table'then return a7 end;if not o then o={}end;if o[a7]then error('circular reference')end;o[a7]=true;local a8={}for p,q in pairs(a7)do if type(q)=='number'and q<0 then a8[p..g.NegativeNumberTag]=tostring(q)else a8[p]=a.TableToSerialiable(q,o)end end;o[a7]=nil;return a8 end,TableFromSerialiable=function(a8)if type(a8)~='table'then return a8 end;local a7={}for p,q in pairs(a8)do if type(q)=='string'and string.endsWith(p,g.NegativeNumberTag)then a7[string.sub(p,1,#p-#g.NegativeNumberTag)]=tonumber(q)else a7[p]=a.TableFromSerialiable(q)end end;return a7 end,EmitMessage=function(a9,aa)local table=aa and a.TableToSerialiable(aa)or{}table[g.InstanceIDParameterName]=a.InstanceID()vci.message.Emit(a9,json.serialize(table))end,OnMessage=function(a9,ab)local ac=function(ad,ae,af)local aa;if af==''then aa={}else local ag,a8=pcall(json.parse,af)if not ag or type(a8)~='table'then a.TraceLog('Invalid message format: ',af)return end;aa=a.TableFromSerialiable(a8)end;ab(ad,ae,aa)end;vci.message.On(a9,ac)return{Off=function()if ac then ac=nil end end}end}b(a,g)package.loaded['cytanb']=a;if vci.assets.IsMine then j=a.UUIDString(a.RandomUUID())vci.state.Set(h,j)else j=''end;return a end)()
