

local IDX_DOOR = 23
local IDX_GATEWAY_ALARM = 58

local ALARM_TIME = 5

return {
	active = true,
	on = {
	    device = { IDX_DOOR },
		timer = {'every minute'}
	},
	execute = function(domoticz, device, triggerInfo)

		local door = domoticz.devices(IDX_DOOR)

        if (triggerInfo.type == domoticz.EVENT_TYPE_DEVICE) then
            
            
            
        elseif (triggerInfo.type == domoticz.EVENT_TYPE_TIMER) then
            
            if (door.state == 'Open' and door.lastUpdate.minutesAgo > ALARM_TIME) then
                
			    domoticz.notify('Alarm drzwi wejściowych',
    				'Drzwi wejściowe są otwarte ponad ' .. ALARM_TIME .. ' minut!',
    				domoticz.PRIORITY_HIGH)
    			domoticz.devices(IDX_GATEWAY_ALARM).switchSelector(30)
    			
			end
        end
            
    end
}