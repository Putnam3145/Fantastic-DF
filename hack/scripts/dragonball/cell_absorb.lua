
local args={...}

local unit = df.unit.find(args[1])

if df.creature_raw.find(unit.race).creature_id~="CELL" then dfhack.error("Creature absorbing isn't Cell! Report this error with the stack trace!",nil,true) end

unit.body.blood_max=unit.body.blood_max+300

for k,v in ipairs(unit.body.size_info) do
	v=v*math.log(math.ceil((v/1000*math.exp(1))))
end

for k,v in ipairs(unit.body.physical_attrs) do
	v.value=v.value+500
end