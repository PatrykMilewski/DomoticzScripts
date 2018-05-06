
local Time = require('Time')

local function getInitialTime()
   
    return Time('2000-01-01 00:00:00')
    
end

local function getActualTime()
    
   return Time()
    
end

return {

    data = {
        -- kitchen window alarm
        
        kitchenWindowStatus = { initial = 'off' },
        enteranceDoorStatus = { initial = 'off' },
        kitchenWindowSuspendTime = { initial = getInitialTime() },
        enteranceDoorSuspendTime = { initial = getInitialTime() },
        
        -- presence detection DP
        
        presenceValueDP = { initial = 0 },
        motionPercentageLastValueDP = { initial = 0.0 },
        
        -- presence detection SP
        
        presenceValueSP = { initial = 0 },
        motionPercentageLastValueSP = { initial = 0.0 },
        
        -- presence detection MP
        
        presenceValueMP = { initial = 0 },
        motionPercentageLastValueMP = { initial = 0.0 },
        
    },

    helpers = {
        
        STATUS_OFF = 'off',
        STATUS_ON = 'on',
        STATUS_SUSPEND = 'suspend',
        
        KITCHEN_ALARM_SUSPEND_TIME = 1200,
        ENTERANCE_DOOR_SUSPEND_TIME = 600,
        
        switchDevice = function(domoticz, idx)
   
            local sonoffState = domoticz.devices(idx).active
        	if (sonoffState == true) then
        	    domoticz.devices(idx).switchOff()
        	elseif (sonoffState == false) then
        	    domoticz.devices(idx).switchOn()
        	end
            
        end,
        
        isSuspendActive = function(lastSuspendTimeStamp, suspendTimeInSeconds)
            
            local actualTime = getActualTime()
            local secondsDifference = actualTime.compare(lastSuspendTimeStamp).seconds
            if (secondsDifference > suspendTimeInSeconds) then
                return true
            else
                return false
            end
            
        end,
        
        isHeatingNeeded = function(domoticz, insideSensor, outsideSensor)
            
            local insideTemperature = insideSensor.temperature
            local outsideTemperature = outsideSensor.temperature
            local actualTime = getActualTime()
            
            if (actualTime.matchesRule('on 30/09-20/04') and (insideTemperature < 19.5 or outsideTemperature < 12.0)) then
                return true
            else
                return false
            end
            
        end,
        
    }
    
}