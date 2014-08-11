local G=_G
local _ENV={}


name="Sparking!"
author="Putnam"
raws_list={}

for k,v in ipairs(dfhack.internal.getDir(dfhack.getDFPath()..'/hack/mods/fortress replacers/sparking')) do
	if v:find('.txt') then
		table.insert(raws_list,v)
	end
end

function findGuards(str,start,patch_guard)
	local pStart=G.string.find(str,patch_guard[1],start)
	if pStart==nil then return nil end
	local pEnd=G.string.find(str,patch_guard[2],pStart)
	if pEnd==nil then error("Start guard token found, but end was not found") end
	return pStart-1,pEnd+#patch_guard[2]+1
end

function addCivControllable(file_name,patch_guard,after_string,code)
    local input_lines=patch_guard[1].."\n"..code.."\n"..patch_guard[2]
    
    local badchars="[%:%[%]]"
    local find_string=after_string:gsub(badchars,"%%%1") --escape some bad chars

    local entityFile=G.io.open(file_name,"r")
    local buf=entityFile:read("*all")
    entityFile:close()
    local entityFile=G.io.open(file_name,"w+")
    buf=G.string.gsub(buf,find_string,after_string.."\n"..input_lines)
    entityFile:write(buf)
    entityFile:close()
end

function removeCivControllable(filename)
	local file=G.io.open(filename,"r")
	local buf=file:read("*all")
	file:close()

	local newBuf=""
	local pos=1
	local lastPos=1
	repeat 
		local endPos
		pos,endPos=findGuards(buf,lastPos,{'<<Civ controllable patch','>>End Civ controllable'})
		newBuf=newBuf..G.string.sub(buf,lastPos,pos)
		if endPos~=nil then
			lastPos=endPos
		end
	until pos==nil

	local file=G.io.open(filename,"w+")
	file:write(newBuf)
    file:close()
end

pre_install=function(args)
	removeCivControllable(G.dfhack.getDFPath().."/raw/objects/entity_default.txt")
end

pre_uninstall=function(args)
	addCivControllable(G.dfhack.getDFPath().."/raw/objects/entity_default.txt",{'<<Civ controllable patch','>>End Civ controllable'},"[ENTITY:MOUNTAIN]","[CIV_CONTROLLABLE]")
end

patch_init="dofile(dfhack.getDFPath()..'/hack/mods/fortress replacers/sparking/sparking.lua')"

description=[[
A mode where you play as Saiyans.
It's pretty silly.
]]
return _ENV