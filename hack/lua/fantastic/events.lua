local _ENV = mkmodule('fantastic.events')

onUnitSpawned=dfhack.event.new()

local hiddenEventInfo={'UNIT_SPAWNED'={prevNumUnits=#df.global.world.units.all,ticks=50}}

hiddenEventInfo.UNIT_SPAWNED.func=function()
	local script=require('gui.script')
	local info=hiddenEventInfo.UNIT_SPAWNED
	script.start(function()
	local curNumUnits=#df.global.world.units.all
	if curNumUnits>prevNumUnits then
		for i=curNumUnits-1,prevNumUnits-1,-1 do
			onUnitSpawned(df.global.world.units.all[i].id)
		end
		prevNumUnits=curNumUnits
	end
	script.sleep(info.ticks,'ticks')
	info.func()
	end)
end

local metaEventTypes={__tostring=function(self) return self.activated end,__metatable='just for tostring'}

eventTypes={'UNIT_SPAWNED'=false}

setmetatable(eventTypes,metaEventTypes)

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