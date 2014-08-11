local G=_G
local _ENV={}


name="Putnam's stuff"
raws_list={"inorganic_putnamagic.txt","interaction_secret_putnamagic.txt","interaction_sphere_putnamagic.txt","reaction_adventure_putnamagic.txt"}
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
Adds a bunch of secrets/curses made by Putnam.
Recommended! On by default.
These were made a while ago. Planned to be made more modular.
]]
return _ENV