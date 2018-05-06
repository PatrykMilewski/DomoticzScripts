

local IDX_MOTION_SENSOR = 81
local IDX_MOTION_PERCENTAGE = 84

local INCREASE_VALUE = 10
local INCREASE_VALUE_NIGHT = 20
local DECRASE_VALUE = -3
local DECRASE_VALUE_NIGHT = -1
local SWITCH_OFF_DELAY = 5

local function changePercentage(domoticz, deviceIDX, changeValue)
    
   local percentage = domoticz.devices(deviceIDX).percentage
    percentage = percentage + changeValue
	if (percentage > 100) then
		percentage = 100
    elseif (percentage < 0) then
	    percentage = 0
	end
	
	domoticz.devices(deviceIDX).updatePercentage(percentage)
    
end

local function increasePercentage(domoticz, deviceIDX, changeValue)
    
    local percentage = domoticz.devices(deviceIDX).percentage
    if (percentage == 0) then
        changeValue = changeValue * 2
    elseif (percentage < 20) then
        changeValue = changeValue * 1.5
    elseif (percentage < 40) then
        changeValue = changeValue * 1.25
    elseif (percentage < 50) then
        changeValue = changeValue * 1.1
    elseif (percentage > 80) then
        changeValue = changeValue * 1.25
    end
    
    changePercentage(domoticz, deviceIDX, changeValue)
end

local function increasePercentageAtNight(domoticz, deviceIDX, changeValue)
   
   local percentage = domoticz.devices(deviceIDX).percentage
   
   if (percentage == 0) then
        changeValue = changeValue * 1.25
    elseif (percentage < 20) then
        changeValue = changeValue * 2
    elseif (percentage < 75) then
        changeValue = changeValue * 1.5
    else
        changeValue = changeValue * 2
    end
   
   changePercentage(domoticz, deviceIDX, changeValue)
   
end

local function isNight(actualTime)
    
    if (actualTime.matchesRule('at 00:00-07:00 on mon, tue, wed, thu, sun') or actualTime.matchesRule('at 01:00-08:00 on fri, sat')) then
        return true
    else
        return false
    end    
    
end

return {
	active = true,
	on = {
		devices = { IDX_MOTION_SENSOR },
		timer = {'every 2 minutes'}
	},

	execute = function(domoticz, device, triggerInfo)
	    
	    local Time = require('Time')
	    local actualTime = Time()
	    
	    if (triggerInfo.type == domoticz.EVENT_TYPE_TIMER) then
	        
	        if (isNight(actualTime)) then
                changePercentage(domoticz, IDX_MOTION_PERCENTAGE, DECRASE_VALUE_NIGHT)
            else
                changePercentage(domoticz, IDX_MOTION_PERCENTAGE, DECRASE_VALUE)
            end
	        
	    elseif (triggerInfo.type == domoticz.EVENT_TYPE_DEVICE) then
	        
	        if (device.bState == true) then
	            
                if (isNight(actualTime)) then
                    if (device.lastUpdate.minutesAgo > 30) then
			            increasePercentageAtNight(domoticz, IDX_MOTION_PERCENTAGE, INCREASE_VALUE_NIGHT * 2)
    			    else
    			        increasePercentageAtNight(domoticz, IDX_MOTION_PERCENTAGE, INCREASE_VALUE_NIGHT)
    			    end
                else
                    if (device.lastUpdate.minutesAgo > 10) then
			            increasePercentage(domoticz, IDX_MOTION_PERCENTAGE, INCREASE_VALUE * 2)
    			    else
    			        increasePercentage(domoticz, IDX_MOTION_PERCENTAGE, INCREASE_VALUE)
    			    end
            	end
	            
			    device.switchOff().afterSec(SWITCH_OFF_DELAY)
		    end
		    
	    else
	        
	        domoticz.log('Unknown trigger type: ' .. triggerInfo.type, domoticz.LOG_ERROR)
	   
	    end
		
	end
}