local fantasticEvents=require('fantastic.events')

fantasticEvents.enableEvent("UNIT_SPAWNED",50)

local function getMarkedUnit()
	local markPersistent='CHOSEN_ONE_FOR_SITE_'..df.global.ui.site_id
	if dfhack.persistent.get(markPersistent) then
		return df.unit.find(dfhack.persistent.get('CHOSEN_ONE_FOR_SITE_'..df.global.ui.site_id).ints[1])
	else
		return nil
	end
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
end
 
local function combineBody(unit1,unit2)
    local firstBody = unit1.body
    local secondBody = unit2.body
    for k,attribute in ipairs(firstBody.physical_attrs) do
        attribute.value = attribute.value + secondBody.physical_attrs[k].value
        attribute.max_value = attribute.max_value + secondBody.physical_attrs[k].max_value
        if attribute.value < 0 or attribute.value > 2^31-1 then attribute.value = 2^30 end
        if attribute.max_value < 0 or attribute.max_value > 2^31-1 then attribute.max_value = 2^31-1 end
    end
end

local function fuseUnit(unit1,unit2)
	if unit1.id==unit2.id then return false end
	unit1.body.blood_count=0
	unit1.animal.vanish_countdown=2
    combineSoul(unit2,unit1)
    combineBody(unit2,unit1)
	dfhack.gui.showAnnouncement(dfhack.TranslateName(dfhack.units.getVisibleName(unit2)) .. " absorbed the power and life of " .. dfhack.TranslateName(dfhack.units.getVisibleName(unit1)) .. "!",COLOR_RED,true)
end

local function markForLife(unit)
	dfhack.persistent.save({key='CHOSEN_ONE_FOR_SITE_'..df.global.ui.site_id,value=dfhack.TranslateName(dfhack.units.getVisibleName(unit)),ints={unit.id}})
end

local function unitMarkedForLife(unit)
	return unit.id==dfhack.persistent.get('CHOSEN_ONE_FOR_SITE_'..df.global.ui.site_id).ints[1]
end

local function checkUnitMarkedForLifeAndIfNotMarkOneRandomly()
	if dfhack.persistent.get('CHOSEN_ONE_FOR_SITE_'..df.global.ui.site_id) then return true else
	local citizens={}
	for k,unit in ipairs(df.global.world.units.active) do
		if dfhack.units.isCitizen(unit) then
			table.insert(citizens,unit)
		end
	end
	local rng=dfhack.random.new()
	local selectedCitizen=citizens[rng:random(#citizens)+1]
	markForLife(selectedCitizen)
	end
end

dfhack.timeout(25,'ticks',checkUnitMarkedForLifeAndIfNotMarkOneRandomly)

fantasticEvents.onUnitSpawned.wizardTowerP=function(unit_id)
	local unit = df.unit.find(unit_id)
	if dfhack.units.isCitizen(unit) then
		fuseUnit(unit,getMarkedUnit())
	end
end

local checkAnyway=function()
	local markedUnit=getMarkedUnit()
	for k,unit in ipairs(df.global.world.units.active) do
		if dfhack.units.isCitizen(unit) then
			fuseUnit(unit,markedUnit)
		end
	end
end

dfhack.timeout(100,'ticks',checkAnyway)