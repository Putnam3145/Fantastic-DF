local G=_G
local _ENV={}

loadnum=7
name="Artifact mats"
author="Putnam"

patch_init="dofile(dfhack.getDFPath()..'/hack/mods/artifact additions/artifactAdditions.lua')"

description=[[
Makes weapon and armor artifacts use a special material whenever they're made.
On by default.
]]
return _ENV