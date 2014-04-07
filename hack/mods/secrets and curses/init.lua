local G=_G
local _ENV={}

loadnum=5
name="Secrets/Curses"
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
Adds a bunch of secrets/curses.
Recommended! On by default.
]]
return _ENV