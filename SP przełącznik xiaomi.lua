
local IDX_SWITCH = 90
local IDX_SONOFF_LAMP = 82
local IDX_THERMOSTAT = 40

local DOUBLE_CLICK_TEMPERATURE = 20.0
local LONG_CLICK_TEMPERATURE = 21.0

local function swtichDevice(domoticz, idx)
   
    local sonoffState = domoticz.devices(idx).active
	if (sonoffState == true) then
	    domoticz.devices(idx).switchOff()
	elseif (sonoffState == false) then
	    domoticz.devices(idx).switchOn()
	end
    
end

local function changeTemperature(thermostatIDX, temperatureValue, domoticz)
    
    domoticz.devices(thermostatIDX).updateSetPoint(temperatureValue)
	domoticz.log('Temperature in SP set to ' .. temperatureValue, domoticz.LOG_INFO)
	
end

return {
	active = true,
	on = {
		devices = { IDX_SWITCH }
	},
	
	execute = function(domoticz, device)
	    
	    if (device.level == 10) then
	        
	        swtichDevice(domoticz, IDX_SONOFF_LAMP)
	        device.switchOff()
	    
	    elseif (device.level == 20) then
	       
	        -- swtichDevice(domoticz, DOUBLE_CLICK_TEMPERATURE)
	        device.switchOff() 
	        
	    elseif (device.level == 30) then
	       
	        -- changeTemperature(IDX_THERMOSTAT, LONG_CLICK_TEMPERATURE, domoticz)
            device.switchOff()
	        
	    end

    end
}
