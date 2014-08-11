local function fixOverflow(a)
	if a < 0 then a = 2^30-1 end
end

local function checkOverflows(unit)
	for _,attribute in ipairs(unit.body.physical_attrs) do
		fixOverflow(attribute.value)
	end
	for _,soul in ipairs(unit.status.souls) do --soul[0] is a pointer to the current soul
		for _,attribute in ipairs(soul.mental_attrs) do
			fixOverflow(attribute.value)
		end
	end
	fixOverflow(unit.body.blood_max)
	fixOverflow(unit.body.blood_count)
end

local function fixAllOverflows()
	for _,unit in ipairs(df.global.world.units.active) do
		checkOverflows(unit)
	end
end

dfhack.onStateChange.overflow = function(code) --Many thanks to Warmist for pointing this out to me!
	if code==SC_WORLD_LOADED then
		dfhack.timeout(200,'ticks',callback)
	end
end

function overflow()
	fixAllOverflows()
	dfhack.timeout(200,'ticks',overflow)
end