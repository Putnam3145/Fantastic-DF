local fantasticEvents=require('fantastic.events')

fantasticEvents.enableEvent("UNIT_SPAWNED",50)

local function killUnit(unit)
	unit.body.blood_count=0
	unit.animal.vanish_countdown=2
end

local function markForLife(unit)
	unit.general_refs:insert('#',{new=df.general_ref_interactionst,anon_1=1959,anon_2=1004,anon_3=1041,anon_4=103})
end

local function unitMarkedForLife(unit)
	for k,v in ipairs(unit.general_refs) do
		if v:is_instance(df.general_ref_interactionst) and (v.anon_1==1959 and anon_2==1004 and anon_3==1041 and anon_4==103) then
			return true
		end
	end
	return false
end

local function checkUnitMarkedForLifeAndIfNotMarkOneRandomly()
	local citizens={}
	for k,v in ipairs(df.global.world.units.active) do
		if dfhack.units.isCitizen(unit) then
			if unitMarkedForLife(unit) then return true end
			table.insert(citizens,unit)
		end
	end
	local rng=dfhack.random.new()
	markForLife(citizens[rng:random(#citizens)+1])
end

dfhack.timeout(25,'ticks',checkUnitMarkedForLifeAndIfNotMarkOneRandomly)

fantasticEvents.onUnitSpawned.wizardTowerP=function(unit_id)
	local unit = df.unit.find(unit_id)
	if dfhack.units.isCitizen(unit) and not unitMarkedForLife(unit) then
		killUnit(unit)
	end
end