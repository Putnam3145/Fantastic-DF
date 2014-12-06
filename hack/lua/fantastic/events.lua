local _ENV = mkmodule('fantastic.events')

onUnitSpawned=dfhack.event.new()

local hiddenEventInfo={UNIT_SPAWNED={prevNumUnits=#df.global.world.units.all,ticks=50}}

hiddenEventInfo.UNIT_SPAWNED.func=function()
	local script=require('gui.script')
	local info=hiddenEventInfo.UNIT_SPAWNED
	script.start(function()
	local curNumUnits=#df.global.world.units.all
	local lowestUnitToCheck = info.prevNumUnits-1>-1 and info.prevNumUnits-1 or 0
	if curNumUnits>info.prevNumUnits then
		for i=curNumUnits-1,info.prevNumUnits-1,-1 do
			if i>-1 then
				onUnitSpawned(df.global.world.units.all[i].id)
			end
		end
		info.prevNumUnits=curNumUnits
	end
	script.sleep(info.ticks,'ticks')
	info.func()
	end)
end

eventTypes={UNIT_SPAWNED=false}

function enableEvent(eventType,numTicks)
	local eventActivated=eventTypes[eventType]
	local event=hiddenEventInfo[eventType]
	if eventActivated then
		if numTicks<event.ticks then event.ticks=numTicks end
	else
		eventTypes[eventType]=true
		event.ticks=numTicks and numTicks or event.ticks
		dfhack.timeout(25,'ticks',event.func)
	end
end

return _ENV