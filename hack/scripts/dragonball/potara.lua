--allows potara earrings

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

function monthlyCheck()
	applySuperSaiyanGodSyndrome()
	checkForMegabeastAttack()
	dfhack.timeout(1,'months',monthlyCheck)
end

local function getInorganic(item)
    local decode = dfhack.matinfo.decode(item)
    if not decode.inorganic then return nil else return decode.inorganic end
end

local function giveName(unitName,nameCopy)
    unitName.first_name = nameCopy.first_name
    unitName.nickname = nameCopy.nickname
    unitName.language = nameCopy.language
    unitName.unknown = nameCopy.unknown
    for i=1,7 do
        unitName.words[i-1] = nameCopy.words[i]
        unitName.parts_of_speech[i-1] = nameCopy.parts_of_speech[i]
    end
end

local function fuseTwoNames(name1,name2) --name1 will be changed directly in this function
    newName = {}
    newName.first_name = string.sub(name1.first_name,1,math.floor(#name1.first_name/2)) .. string.sub(name2.first_name,-math.floor(#name2.first_name/2))
    newName.nickname = ""
    newName.language = name1.language
    newName.unknown = name1.unknown
    newName.words = {}
    newName.parts_of_speech = {}
    for i = 1, 7 do
        if i%2==1 then
            newName.words[i] = name2.words[i-1]
            newName.parts_of_speech[i] = name1.parts_of_speech[i-1]
        else
            newName.words[i] = name1.words[i-1]
            newName.parts_of_speech[i] = name2.parts_of_speech[i-1]
        end
    end
	printall(newName.words)
	printall(name1.words)
    giveName(name1,newName)
end

local function insertSkill(unit,skill)
    unit.status.current_soul.skills:insert('#', 
        {
        new = df.unit_skill,
        id = skill.id,
        rating = skill.rating,
        experience = skill.experience,
        unused_counter = skill.unused_counter,
        rusty = skill.rusty,
        rust_counter = skill.rust_counter,
        demotion_counter = skill.demotion_counter, 
        unk_1c = skill.unk_1c
        }
        )
end

local function combineSoul(unit1,unit2)
    local firstUnitSoul = unit1.status.current_soul
    local secondUnitSoul= unit2.status.current_soul
    for k,attribute in ipairs(firstUnitSoul.mental_attrs) do
        attribute.value = attribute.value + secondUnitSoul.mental_attrs[k].value
        attribute.max_value = attribute.max_value + secondUnitSoul.mental_attrs[k].max_value
		if attribute.value < 0 or attribute.value > 2^31-1 then attribute.value = 2^30 end
		if attribute.max_value < 0 or attribute.max_value > 2^31-1 then attribute.max_value = 2^31-1 end
    end
    for _,skill2 in ipairs(secondUnitSoul.skills) do
        local skillFound = false
            for _,skill1 in ipairs(firstUnitSoul.skills) do
                if skill2.id == skill1.id then 
					skillFound = true
					skill1.rating = skill1.rating + skill2.rating
				end
            end
        if not skillFound then 
            insertSkill(unit1,skill2)
        end
    end
    --preferences are too much trouble for their worth
    for k,trait1 in ipairs(firstUnitSoul.traits) do
        local trait2 = secondUnitSoul.traits[k]
        trait1 = math.floor((trait1+trait2)/2)
    end
    --unk5 and unk6 are... unknown to me, so...
end

local function combineBody(unit1,unit2)
    firstBody = unit1.body
    firstAppearance = unit1.appearance
    secondBody = unit2.body
    secondAppearance = unit2.appearance
    firstBody.blood_max = firstBody.blood_max + secondBody.blood_max
    firstBody.blood_count = firstBody.blood_max
    for k,attribute in ipairs(firstBody.physical_attrs) do
        attribute.value = attribute.value + secondBody.physical_attrs[k].value
        attribute.max_value = attribute.max_value * secondBody.physical_attrs[k].max_value
		if attribute.value < 0 or attribute.value > 2^31-1 then attribute.value = 2^30 end
		if attribute.max_value < 0 or attribute.max_value > 2^31-1 then attribute.max_value = 2^31-1 end
    end
    for k,tissue in ipairs(firstBody.physical_attr_tissues) do
        tissue = tissue + secondBody.physical_attr_tissues[k]
    end
    for k,modifier in ipairs(firstAppearance.body_modifiers) do
        modifier = math.floor((modifier+secondAppearance.body_modifiers[k])/2)
    end
    for k,modifier in ipairs(firstAppearance.bp_modifiers) do
        modifier = math.floor((modifier+secondAppearance.bp_modifiers[k])/2)
    end
    for k,length1 in ipairs(firstAppearance.tissue_length) do
        local length2 = secondAppearance.tissue_length[k]
        length1 = math.floor((length1+length2)/2)
    end
end

local function combineCounters(unit1,unit2)
    local traits1 = unit1.status.misc_traits
    local traits2 = unit2.status.misc_traits
    for _,trait1 in ipairs(traits1) do
        if trait1.id==15 then
            for _,trait2 in ipairs(traits2) do
                if trait2.id==15 then
                    trait1.value = trait1.value+trait2.value
                    if trait1.value>100 then trait1.value = 100 end
                end
            end
        end
    end
end

local function fuseUnits(unit1,unit2)
    if unit1.race~=unit2.race then
        return nil
    end
    fuseTwoNames(unit1.name,unit2.name)
    combineSoul(unit1,unit2)
    combineBody(unit1,unit2)
    combineCounters(unit1,unit2)
    unit2.animal.vanish_countdown = 2
end

local function findPotara()
    local potaraNumber = 0
    local unitsWithPotara = {}
    for _uid,unit in ipairs(df.global.world.units.active) do
        for itemid,item_inv in ipairs(unit.inventory) do
            local item = item_inv.item
            local material = getInorganic(item)
            if material then
                if material.id == "POTARA_DB" then
                    table.insert(unitsWithPotara,unit)
                    potaraNumber=potaraNumber+1
                end
            end
        end
    end
    if potaraNumber == 2 and #unitsWithPotara == 2 then
        fuseUnits(unitsWithPotara[1],unitsWithPotara[2])
    end
end

local args = {...}

if args[1] == "force" then
	fuseUnits(df.global.world.units.all[tonumber(args[2])],df.global.world.units.all[tonumber(args[3])])
end


function potara()
	findPotara()
	dfhack.timeout(200,'ticks',potara)
end

monthlyCheck()
potara()