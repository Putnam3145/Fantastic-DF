local function killUnit(unit)
	unit.body.blood_count = 0
	unit.animal.vanish_countdown = 2
end

killUnit(df.unit.find(...))