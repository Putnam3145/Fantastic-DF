local function saiyanCanGoSuperSaiyan(saiyan)
	--15 is combathardness
	for _,misc_trait in ipairs(saiyan.status.misc_traits) do
		if misc_trait.id == 15 then
			if misc_trait.value > 31 then return true end
		end
	end
	return false
end

local function saiyanCanGoSuperSaiyan2(saiyan)
	--15 is combathardness
	for _,misc_trait in ipairs(saiyan.status.misc_traits) do
		if misc_trait.id == 15 then
			if misc_trait.value > 64 then return true end
		end
	end
	return false
end

local function saiyanCanGoSuperSaiyan3(saiyan)
	--15 is combathardness
	for _,misc_trait in ipairs(saiyan.status.misc_traits) do
		if misc_trait.id == 15 then
			if misc_trait.value > 99 then return true end
		end
	end
	return false
end

local function superSaiyanGodSyndrome()
	for syn_id,syndrome in ipairs(df.global.world.raws.syndromes.all) do
		if syndrome.syn_name == "Super Saiyan God" then return syn_id end
	end
	qerror("Super saiyan god syndrome not found.")
end

local function getPowerLevel(unit)
	local speed = 1000/dfhack.units.computeMovementSpeed(unit)
	local strength = unit.body.physical_attrs.STRENGTH.value/3550
	local endurance = unit.body.physical_attrs.ENDURANCE.value/1000
	local toughness = unit.body.physical_attrs.TOUGHNESS.value/2250
	local spatialsense = unit.status.current_soul.mental_attrs.SPATIAL_SENSE.value/1500
	local kinestheticsense = unit.status.current_soul.mental_attrs.KINESTHETIC_SENSE.value/1000
	local willpower = unit.status.current_soul.mental_attrs.WILLPOWER.value/1000
	local bodysize = (unit.body.blood_count/100)^2
	local powerlevel = bodysize*speed*((strength*endurance*toughness*spatialsense*kinestheticsense*willpower)^(1/6))
	if saiyanCanGoSuperSaiyan(unit) then powerlevel = powerlevel * 50 end
	if saiyanCanGoSuperSaiyan2(unit) then powerlevel = powerlevel * 2 end
	if saiyanCanGoSuperSaiyan3(unit) then powerlevel = powerlevel * 4 end
	return powerlevel
end

local function getSuperSaiyanCount()
	local superSaiyanCount = 0
	local saiyan = df.global.ui.race_id
	for _,unit in ipairs(df.global.world.units.active) do
		if unit.race==saiyan then
			if saiyanCanGoSuperSaiyan(unit) then
				superSaiyanCount = superSaiyanCount + 1
			end
		end
	end
	return superSaiyanCount
end

local function unitWithHighestPowerLevel()
	local highestUnit = nil
	local highestPowerLevel = 0
	for _,unit in ipairs(df.global.world.units.active) do
		if getPowerLevel(unit) > highestPowerLevel and unit.race==df.global.ui.race_id then highestUnit = unit end
	end
	return highestUnit
end

local function combinedSaiyanPowerLevel()
	local totalPowerLevel=0
	local saiyan = df.global.ui.race_id
	for _,unit in ipairs(df.global.world.units.active) do
		if unit.race == saiyan then totalPowerLevel = totalPowerLevel + getPowerLevel(unit) end
	end
	return totalPowerLevel
end

local function assignSyndrome(target,syn_id) --taken straight from here, but edited so I can understand it better: https://gist.github.com/warmist/4061959/
    if target==nil then
        qerror("Not a valid target") --this probably won't happen :V
    end
    local newSyndrome=df.unit_syndrome:new()
    local target_syndrome=df.syndrome.find(syn_id)
    newSyndrome.type=target_syndrome.id
    --newSyndrome.year=
    --newSyndrome.year_time=
    newSyndrome.ticks=1
    newSyndrome.unk1=1
    for k,v in ipairs(target_syndrome.ce) do
        local sympt=df.unit_syndrome.T_symptoms:new()
        sympt.ticks=1
        sympt.flags=2
        newSyndrome.symptoms:insert("#",sympt)
    end
    target.syndromes.active:insert("#",newSyndrome)
end

local function applySuperSaiyanGodSyndrome()
	local superSaiyanCount = getSuperSaiyanCount()
	local superSaiyanGod = unitWithHighestPowerLevel()
	if getPowerLevel(superSaiyanGod) > 1000000 and superSaiyanCount > 5 then assignSyndrome(superSaiyanGod,superSaiyanGodSyndrome()) end
end

local function stopMegabeastAttacks()
	local removedMegaBeastAttack = false
	for eventid,event in ipairs(df.global.timed_events) do
		if event.type == df.timed_event_type.Megabeast then
			table.remove(df.global.timed_events,eventid)
			removedMegaBeastAttack = true
		end
	end
	return removedMegaBeastAttack
end

local function causeMegaBeastAttack()
	df.global.timed_events:insert('#', { new = df.timed_event, type = df.timed_event_type.Megabeast, season = df.global.cur_season, season_ticks = df.global.cur_season_tick } )
end

local function checkForMegabeastAttack()
	if combinedSaiyanPowerLevel() > 4000000 and stopMegabeastAttacks() then causeMegaBeastAttack() end
end

dfhack.onStateChange.dragonball = function(code) --Many thanks to Warmist for pointing this out to me!
	if code==SC_WORLD_LOADED then
		dfhack.timeout(1,'months',callback)
	end
end

function callback()
	applySuperSaiyanGodSyndrome()
	checkForMegabeastAttack()
	dfhack.timeout(1,'months',callback)
end

dfhack.onStateChange.dragonball()