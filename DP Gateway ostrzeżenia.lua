

local IDX_GATEWAY = 1
local IDX_ALERT_SWITCH = 58
local IDX_HUE = 59
local IDX_BRI = 60

local function gatewayInformation(hue, bri)
    hue.dimTo(60)
    bri.dimTo(100)
end

local function gatewayWarning(hue, bri)
    hue.dimTo(12)
    bri.dimTo(100)
end

local function gatewayEmergency(hue, bri)
    hue.dimTo(95)
    bri.dimTo(100)
end

local function gatewayFailure(hue, bri)
    hue.dimTo(100)
    bri.dimTo(100)
end

return {
	active = true,
	on = {
		devices = { IDX_ALERT_SWITCH }
	},
	
	execute = function(domoticz, device)
	    
	    local hue = domoticz.devices(IDX_HUE)
	    local bri = domoticz.devices(IDX_BRI)
	    
	    if (device.level == 0) then
	        
	        bri.switchOff()
	        
	    elseif (device.level == 10) then
	        
	        gatewayInformation(hue, bri)
	        
	    elseif (device.level == 20) then
	        
	        gatewayWarning(hue, bri)
	        
	    elseif (device.level == 30) then
	        
	        gatewayEmergency(hue, bri)
	        
	    elseif (device.level == 40) then
	        
	        gatewayFailure(hue, bri)
	        
	    end

    end
}