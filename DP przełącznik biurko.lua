

local IDX_SWITCH = 68
local IDX_SONOFF = 45
local IDX_MONITOR = 44

local function switchDevice(domoticz, device, idx)
   
    local sonoffState = domoticz.devices(idx).active
	if (sonoffState == true) then
	    domoticz.devices(idx).switchOff()
	elseif (sonoffState == false) then
	    domoticz.devices(idx).switchOn()
	end
	device.switchOff()
    
end


return {
	active = true,
	on = {
		devices = { IDX_SWITCH }
	},
	
	execute = function(domoticz, device)
	    
	    if (device.state == 'Click') then
	        
	        switchDevice(domoticz, device, IDX_SONOFF)
	        
	    elseif (device.state == 'Double Click') then
	        
	        switchDevice(domoticz, device, IDX_MONITOR)
	        
	    elseif (device.state == 'Long Click') then
	        
	        
	        
	    end 

    end
}