-- Allows instant transmission.

if df.global.gamemode~=1 then
	qerror("Adventure mode only (for now). Sorry!")
end

function getTileType(x,y,z)
    local block = dfhack.maps.getTileBlock(x,y,z)
    if block then
        return block.tiletype[x%16][y%16]
    else
        return 0
    end
end

function getPowerLevel(unit)
	local speed = 1000/dfhack.units.computeMovementSpeed(unit)
	local strength = unit.body.physical_attrs.STRENGTH.value/3550
	local endurance = unit.body.physical_attrs.ENDURANCE.value/1000
	local toughness = unit.body.physical_attrs.TOUGHNESS.value/2250
	local spatialsense = unit.status.current_soul.mental_attrs.SPATIAL_SENSE.value/1500
	local kinestheticsense = unit.status.current_soul.mental_attrs.KINESTHETIC_SENSE.value/1000
	local willpower = unit.status.current_soul.mental_attrs.WILLPOWER.value/1000
	local bodysize = (unit.body.blood_count/100)^2
	local powerlevel = bodysize*speed*((strength*endurance*toughness*spatialsense*kinestheticsense*willpower)^(1/6))
	return powerlevel
end

local function positionIsValid(x,y,z)
	local occupancy = dfhack.maps.getTileBlock(x,y,z).occupancy[x%16][y%16]
	local tiletype = getTileType(x,y,z)
	local attrs = df.tiletype.attrs[tiletype]
	if occupancy.building~=0 or occupancy.unit or not dfhack.maps.isValidTilePos(x,y,z) or attrs.shape == df.tiletype_shape.WALL  then return false else return true end
end

local dialog = require('gui.dialogs')

local function teleport(player,unitID)
	local unit = df.global.world.units.all[unitID]
	local playeroccupancy = dfhack.maps.getTileBlock(player.pos).occupancy[player.pos.x%16][player.pos.y%16]
	local teleportToPosX = unit.pos.x
	local teleportToPosY = unit.pos.y
	local timesTried = 0
	teleportToPosY = unit.pos.y - 1
	repeat
		if timesTried > 4 then qerror("Failed to teleport.") end
		local hasNotTried = true
		if teleportToPosY < unit.pos.y and hasNotTried then
			teleportToPosY = unit.pos.y
			teleportToPosX = unit.pos.x-1 
			hasNotTried = false
		end
		if teleportToPosX < unit.pos.x and hasNotTried then
			teleportToPosX = unit.pos.x
			teleportToPosY = unit.pos.y+1
			hasNotTried = false
		end
		if teleportToPosY > unit.pos.y and hasNotTried then
			teleportToPosY = unit.pos.y
			teleportToPosX = unit.pos.x+1 
			hasNotTried = false
		end
		if teleportToPosX > unit.pos.x and hasNotTried then
			teleportToPosX = unit.pos.x
			teleportToPosY = unit.pos.y-1
			hasNotTried = false
		end
		timesTried = timesTried + 1
	until positionIsValid(teleportToPosX,teleportToPosY,unit.pos.z)
	dfhack.gui.showAnnouncement("You put two fingers up to your head and concentrate...",11)
	player.pos.x = teleportToPosX
	player.pos.y = teleportToPosY
	player.pos.z = unit.pos.z
	if not player.flags1.on_ground then playeroccupancy.unit = false else playeroccupancy.unit_grounded = false end
end

function selectUnit() --taken straight from here, but edited so I can understand it better: https://gist.github.com/warmist/4061959/... again. Also edited for syndromeTrigger, but in a completely different way.
    local creatures=df.global.world.units.all
    local tbl={}
    local tunit=df.global.world.units.active[0]
    for k,creature in ipairs(creatures) do
		local plevel=math.ceil(getPowerLevel(creature))
		local racename=df.creature_raw.find(creature.race).caste[creature.caste].caste_name[0]
		table.insert(tbl,{racename.." "..plevel.." ".. (creature==tunit and "(You!)" or ""),nil,k})
    end
    local f=function(name,C)
        teleport(tunit,C[3])
    end
	dialog.showListPrompt("Left is species, right is power level.","Choose creature to teleport to:",COLOR_WHITE,tbl,f)
end

selectUnit()