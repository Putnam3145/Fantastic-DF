local G=_G
local _ENV={}

loadnum=6
name="Weekly complaint report"
author="Putnam"

patch_init=[[
do
	local script=require('gui.scripts')
	local citizens={}
	fantasticEvents.onUnitSpawned.badThoughtNotifier=function(unitID)
		local unit=df.units.find(unitID)
		if dfhack.units.isCitizen(unit) then
			table.insert(citizens,unit)
		end
	end
	for k,v in ipairs(df.global.world.units.all) do
		if dfhack.units.isCitizen(v) then
			table.insert(citizens,v)
		end
	end
	local function thoughtIsNegative(thought)
		return df.unit_thought_type.attrs[thought.type].value:sub(1,1)=='-'
	end
	local function write_gamelog_and_announce(msg,color)
		dfhack.gui.showAnnouncement(msg,color)
		local log = io.open('gamelog.txt', 'a')
		log:write(msg.."\n")
		log:close()
	end
	local function checkForBadThoughts(silent)
		if not silent then
			local thoughts={}
			local mostPopularNegativeThought={cur_amount=0,thought_type=0}
			for _,unit in ipairs(citizens) do
				for __,thought in ipairs(unit.status.recent_events) do
					if thoughtIsNegative(thought) then
						thoughts[thought.type]=thoughts[thought.type] or 0
						thoughts[thought.type]=thoughts[thought.type]+1
						if thoughts[thought.type]>mostPopularNegativeThought.cur_amount then
							mostPopularNegativeThought.cur_amount=thoughts[thought.type]
							mostPopularNegativeThought.thought_type=thought.type
						end
					end
				end
			end
			write_gamelog_and_announce('Your dwarves are most complaining about this: "' .. df.unit_thought_type.attrs[mostPopularNegativeThought.thought_type].caption..'".',COLOR_CYAN)
		end
		script.sleep('days',7)
		checkForBadThoughts()
	end
	checkForBadThoughts(true)
end
]]

description=[[
Adds a weekly message about what your dwarves are most unhappy about.
Recommended! On by default.
]]
return _ENV