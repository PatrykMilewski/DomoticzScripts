

local IDX_THERMOSTAT_DP = 28
local IDX_THERMOSTAT_SP = 40
local IDX_THERMOSTAT_MP = 33

local IDX_AUTO_HEATING_SWITCH_DP = 92
local IDX_AUTO_HEATING_SWITCH_SP = 93
local IDX_AUTO_HEATING_SWITCH_MP = 94

local IDX_TEMPERATURE_SENSOR_DP = 29
local IDX_TEMPERATURE_SENSOR_SP = 38
local IDX_TEMPERATURE_SENSOR_MP = 31
local IDX_TEMPERATURE_OUTSIDE = 37

local IDX_PRESENCE_DP = 72
local IDX_PRESENCE_SP = 74
local IDX_PRESENCE_MP = 73

local IDX_MOTION_DP = 57
local IDX_MOTION_SP = 83
local IDX_MOTION_MP = 84

local TEMPERATURE_MAX = 23.0
local TEMPERATURE_MIN = 15.0

local TEMPERATURE_DAY_DP = 21.0
local TEMPERATURE_DAY_SP = 21.0
local TEMPERATURE_DAY_MP = 21.0
local TEMPERATURE_NIGHT_DP = 20.0
local TEMPERATURE_NIGHT_SP = 20.0
local TEMPERATURE_NIGHT_MP = 20.0

local PRESENCE_PERCENTAGE_LIMIT_DP = 40
local PRESENCE_PERCENTAGE_LIMIT_SP = 40
local PRESENCE_PERCENTAGE_LIMIT_MP = 40



local function automaticHeatingHandle(domoticz, heatingSwitchIDX, presenceIDX, thermostatIDX, motionIDX, temperatureIDX, presencePercentageLimit, temperatureSetpointDay, temperatureSetpointNight)
    
    -- check if automatic heating enabled
    local heatingSwitch = domoticz.devices(heatingSwitchIDX)
    
    if (heatingSwitch.bState == false) then
        return
    end
    
    local presence = domoticz.devices(presenceIDX)
    local thermostat = domoticz.devices(thermostatIDX)
    local motion = domoticz.devices(motionIDX)
    local temperatureInside = domoticz.devices(temperatureIDX)
    local temperatureOutside = domoticz.devices(IDX_TEMPERATURE_OUTSIDE)
    
    -- check if room is occupied
    if (presence.percentage < presencePercentageLimit) then
        return
    end
    
    --local newTemperatureSetpoint = 
    
end

return {
	active = true,
	on = {
	   -- timer = {
	   --     'every 5 minutes',
	   -- },
		devices = { 
		    IDX_THERMOSTAT_DP,
	        IDX_THERMOSTAT_SP,
	        IDX_THERMOSTAT_MP
	    }
	},
	
	execute = function(domoticz, device, triggerInfo)
	    
	    
	    -- if thermostat setpoint changed
	    if (triggerInfo.type == domoticz.EVENT_TYPE_DEVICE) then
	        
	        local currentSetPoint = device.setPoint
	    
    	    if (currentSetPoint > TEMPERATURE_MAX) then
    	    
    	        domoticz.log("Temperature set point over max value: " .. TEMPERATURE_MAX .. " on IDX: " .. device.idx)
    	        device.updateSetPoint(TEMPERATURE_MAX)
    	        
    	        
    	    elseif (currentSetPoint < TEMPERATURE_MIN) then 
    	    
    	        domoticz.log("Temperature set point under min value: " .. TEMPERATURE_MIN .. " on IDX: " .. device.idx)
    	        device.updateSetPoint(TEMPERATURE_MIN)
    	        
	        end
	        
	    -- automatic heating
	    elseif (triggerInfo.type == domoticz.EVENT_TYPE_TIMER) then
	        
	        automaticHeatingHandle(domoticz, IDX_AUTO_HEATING_SWITCH_DP, IDX_PRESENCE_DP, IDX_THERMOSTAT_DP, IDX_MOTION_DP, IDX_TEMPERATURE_SENSOR_DP, PRESENCE_PERCENTAGE_LIMIT_DP, TEMPERATURE_DAY_DP, TEMPERATURE_NIGHT_DP)
	        
	        automaticHeatingHandle(domoticz, IDX_AUTO_HEATING_SWITCH_SP, IDX_PRESENCE_SP, IDX_THERMOSTAT_SP, IDX_MOTION_SP, IDX_TEMPERATURE_SENSOR_SP, PRESENCE_PERCENTAGE_LIMIT_SP, TEMPERATURE_DAY_SP, TEMPERATURE_NIGHT_SP)
	        
	        automaticHeatingHandle(domoticz, IDX_AUTO_HEATING_SWITCH_MP, IDX_PRESENCE_MP, IDX_THERMOSTAT_MP, IDX_MOTION_MP, IDX_TEMPERATURE_SENSOR_MP, PRESENCE_PERCENTAGE_LIMIT_MP, TEMPERATURE_DAY_MP, TEMPERATURE_NIGHT_MP)

	    end
	    
	    
        
    end
}