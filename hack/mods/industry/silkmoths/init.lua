local G=_G
local _ENV={}


name="Silkmoths"
raws_list={"creature_vermin_fantastic.txt"}
author="Putnam"

function fileExists(filename)
	local file=G.io.open(filename,"rb")
	if file==nil then
		return
	else
		file:close()
		return true
	end
end

function checkInstalled()
	for k,v in G.pairs(raws_list) do
		if fileExists(G.dfhack.getDFPath().."/raw/objects/"..v) then
			return true,v
		end
	end
end

description=[[
Adds silkmoths, a hiveable creature that gets you silk.
]]
return _ENV