-->>Artifact mats patch
do
	local function isBlunt(item)
		if not item:isWeapon() then return false end
		for k,v in ipairs(item.subtype.attacks) do
			if v.edged then return false end
		end
		return true
	end

	local function activateArtifactChanges()
		local eventful=require('plugins.eventful')

		eventful.enableEvent(eventful.eventType['ITEM_CREATED'],4)

		eventful.onItemCreated.fantasticArtifactP=function(item_id)
			local item=df.item.find(item_id)
			--check if item is eligible for this particular function
			if item.flags.artifact and (item:isWeapon() or item:getEffectiveArmorLevel()<2) then
				local matInfo
				--check if blunt or not; if blunt, set matInfo (defined above) to the blunt artifact mat, else sharp/armor artifact mat
				if isBlunt(item) then
					matinfo=dfhack.matinfo.find('ARTIFACT_BLUNT_P')
				else
					matinfo=dfhack.matinfo.find('ARTIFACT_SHARP_ARMOR_P')
				end
				item:setMaterial(matInfo.type)
				item:setMaterialIndex(matinfo.index)
			end
		end
	end

	activateArtifactChanges()
end
--<<End Artifact mats patch

local fantasticEvents={}
fantasticEvents.onUnitSpawned=dfhack.event.new()
do
	local script=require('gui.scripts')
	local prevNumUnits=#df.global.world.units.all
	local function checkUnitSpawned()
		script.start(function()
		local curNumUnits=#df.global.world.units.all
		if curNumUnits>prevNumUnits then
			for i=curNumUnits-1,prevNumUnits-1,-1 do
				fantasticEvents.onUnitSpawned(df.global.world.units.all[i].id)
			end
			prevNumUnits=curNumUnits
		end
		script.sleep('ticks',200)
		checkUnitSpawned()
		end)
	end
end

-->>Weekly complaint report patch
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
--<<End Weekly complaint report patch