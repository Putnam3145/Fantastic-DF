local G=_G
local _ENV={}


name="Weekly complaints"
author="Putnam"

patch_init="dofile(dfhack.getDFPath()..'/hack/mods/dfhack/bad thought notifier/badThoughtNotifier.lua')"

description=[[
Adds a weekly message about what your dwarves are most unhappy about.
Recommended! On by default.
]]
return _ENV