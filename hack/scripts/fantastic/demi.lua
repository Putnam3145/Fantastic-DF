local args = {...}

local unit = df.unit.find(args[1])

local demilevel=1-(tonumber(args[2])/100)

if demilevel>1 or demilevel<0 then qerror("number can't be more than 100 or less than 0!") end

unit.body.blood_count=math.ceil(unit.body.blood_count*demilevel)