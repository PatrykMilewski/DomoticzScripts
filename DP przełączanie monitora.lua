

local IDX_COMPUTER_STATUS = 51
local IDX_COMPUTER_POWER_BUTTON = 41
local IDX_MONITOR_SONOFF = 44

local IDX_SWITCH_FIRST = 19
local IDX_SWITCH_SECOND = 68

local Time = require('Time')

local function getInitialTime()
   
    return Time('2000-01-01 00:00:00')
    
end

return {
	active = true,
	on = {
	    timer = { 'every 1 minutes' },
		devices = { 
		    IDX_COMPUTER, 
		    IDX_COMPUTER_POWER_BUTTON,
		    IDX_SWITCH_FIRST,
		    IDX_SWITCH_SECOND,
        }
	},
	data = {
	    lastTimeSwitch = { initial = getInitialTime() },
	},
	logging = {
	    level = domoticz.LOG_ERROR,  
	},
	execute = function(domoticz, device, triggerInfo)
	    
	    local monitor = domoticz.devices(IDX_MONITOR_SONOFF)
	    local computer = domoticz.devices(IDX_COMPUTER_STATUS)
	    
	    if (device.idx == IDX_SWITCH_FIRST or device.idx == IDX_SWITCH_SECOND) then
	       
	        if (device.state == 'Double Click') then
	       
	            domoticz.data.lastTimeSwitch = Time()
	            return
	            
	        end
	        
	    end
	    
	    -- if timer, then check if computer is off and monitor is on
	    if (triggerInfo.type == domoticz.EVENT_TYPE_TIMER) then
	       
	        domoticz.log("Timer event values: " .. computer.state .. " " .. monitor.state, domoticz.LOG_DEBUG)
	        
	        local actualTime = Time()
	        if (domoticz.data.lastTimeSwitch.minutesAgo < 5) then
	            return
	        end
	        
	        if (computer.bState == false and monitor.bState == true) then
	            monitor.switchOff()
	            domoticz.log("Timer event, switching off monitor.", domoticz.LOG_DEBUG)
	        end
	        
	        return
	    end
	    
	    -- if computer is off then turn off monitor
	    if (device.idx == IDX_COMPUTER_STATUS and device.bState == false) then
	        
	        if (monitor.bState == true) then
	            domoticz.devices(IDX_MONITOR_SONOFF).switchOff()
	        end
	        
	    -- if computer is on or power button is clicked then switch on monitor
        elseif ((device.idx == IDX_COMPUTER_STATUS and device.bState == true) or (device.idx == IDX_COMPUTER_POWER_BUTTON and device.bState == true)) then
        
	        if (monitor.bState == false) then
	            domoticz.devices(IDX_MONITOR_SONOFF).switchOn()
	        end
	        
	    end

    end
}