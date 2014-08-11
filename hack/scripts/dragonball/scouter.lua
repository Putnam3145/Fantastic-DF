-- Gives power level of selected unit. Type "accurate" for a more linear, but more boring number.

local selectedUnit = dfhack.gui.getSelectedUnit(silent)

local args = {...}

local accurate = false

for _,arg in ipairs(args) do
    if arg == "accurate" then accurate = true end
end

local function unitIsGod(unit)
    local unitraws = df.creature_raw.find(unit.race)
    local casteraws = unitraws.caste[unit.caste]
    local unitclasses = casteraws.creature_class
    for _,class in ipairs(unitclasses) do
        if class.value == "GOD" then return true end
    end
    for _,u_syndrome in ipairs(unit.syndromes.active) do
        local syndrome = df.global.world.raws.syndromes.all[u_syndrome.type]
        for _,synclass in ipairs(syndrome.syn_class) do
            if synclass.value == "GOD" then return true end
        end
    end
    return false
end

--power levels should account for disabilities and such
local function isWinded(unit)
    if unit.counters.winded > 0 then return true end
    return false
end
local function isStunned(unit)
    if unit.counters.stunned > 0 then return true end
    return false
end
local function isUnconscious(unit)
    if unit.counters.unconscious > 0 then return true end
    return false
end
local function isParalyzed(unit)
    if unit.counters2.paralysis > 0 then return true end
    return false
end
local function getExhaustion(unit)
    local exhaustion = 1
    if unit.counters2.exhaustion~=0 then
        exhaustion = 1000/unit.counters2.exhaustion
        return exhaustion
    end
    return 1
end

if not selectedUnit then
    qerror('Need to select a unit.')
end

--blood_max appears to be the creature's body size divided by 10; the power level calculation relies on body size divided by 1000, so divided by 100 it is. blood_count refers to current blood amount, and it, when full, is equal to blood_max.
local speed = 1000/dfhack.units.computeMovementSpeed(selectedUnit)
if selectedUnit.curse.attr_change then
	strength = ((selectedUnit.body.physical_attrs.STRENGTH.value+selectedUnit.curse.attr_change.phys_att_add.STRENGTH)/3550)*(selectedUnit.curse.attr_change.phys_att_perc.STRENGTH/100)
	endurance = ((selectedUnit.body.physical_attrs.ENDURANCE.value+selectedUnit.curse.attr_change.phys_att_add.ENDURANCE)/1000)*(selectedUnit.curse.attr_change.phys_att_perc.ENDURANCE/100)
	toughness = ((selectedUnit.body.physical_attrs.TOUGHNESS.value+selectedUnit.curse.attr_change.phys_att_add.TOUGHNESS)/2250)*(selectedUnit.curse.attr_change.phys_att_perc.TOUGHNESS/100)
	spatialsense = ((selectedUnit.status.current_soul.mental_attrs.SPATIAL_SENSE.value+selectedUnit.curse.attr_change.ment_att_add.SPATIAL_SENSE)/1500)*(selectedUnit.curse.attr_change.ment_att_perc.SPATIAL_SENSE/100)
	kinestheticsense = ((selectedUnit.status.current_soul.mental_attrs.KINESTHETIC_SENSE.value+selectedUnit.curse.attr_change.ment_att_add.KINESTHETIC_SENSE)/1000)*(selectedUnit.curse.attr_change.ment_att_perc.KINESTHETIC_SENSE/100)
	willpower = ((selectedUnit.status.current_soul.mental_attrs.WILLPOWER.value+selectedUnit.curse.attr_change.ment_att_add.WILLPOWER)/1000)*(selectedUnit.curse.attr_change.ment_att_perc.WILLPOWER/100)
else
	strength = selectedUnit.body.physical_attrs.STRENGTH.value/3550
	endurance = selectedUnit.body.physical_attrs.ENDURANCE.value/1000
	toughness = selectedUnit.body.physical_attrs.TOUGHNESS.value/2250
	spatialsense = selectedUnit.status.current_soul.mental_attrs.SPATIAL_SENSE.value/1500
	kinestheticsense = selectedUnit.status.current_soul.mental_attrs.KINESTHETIC_SENSE.value/1000
	willpower = selectedUnit.status.current_soul.mental_attrs.WILLPOWER.value/1000
end
local exhaustion = getExhaustion(selectedUnit)


if accurate == true
then
    local bodysize = selectedUnit.body.blood_count*10
    powerlevel = bodysize*speed*((strength*endurance*toughness*spatialsense*kinestheticsense*willpower)^(1/6))*exhaustion
    powerlevel = powerlevel * 300
else
    local bodysize = (selectedUnit.body.blood_count/100)^2
    powerlevel = bodysize*speed*((strength*endurance*toughness*spatialsense*kinestheticsense*willpower)^(1/6))*exhaustion
end
if isWinded(selectedUnit) then powerlevel=powerlevel/1.2 end
if isStunned(selectedUnit) then powerlevel=powerlevel/1.5 end
if isParalyzed(selectedUnit) then powerlevel=powerlevel/5 end
if isUnconscious(selectedUnit) then powerlevel=powerlevel/10 end

if powerlevel == 1/0 or unitIsGod(selectedUnit) then
    dfhack.gui.showPopupAnnouncement("The scouter broke at this incredible power. Either the power belongs to a god... or it's immeasurable.")
    qerror("Scouter broke! Oh well, there are more.",11)
end

dfhack.gui.showAnnouncement("The scouter says " .. math.floor(powerlevel) .. "!",11)
