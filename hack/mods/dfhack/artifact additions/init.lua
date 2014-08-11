local G=_G
local _ENV={}


name="Artifact mats"
author="Putnam"

patch_init="dofile(dfhack.getDFPath()..'/hack/mods/dfhack/artifact additions/artifactAdditions.lua')"

description=[[
Makes weapon and armor artifacts use a special material whenever they're made.
On by default.
]]
return _ENV