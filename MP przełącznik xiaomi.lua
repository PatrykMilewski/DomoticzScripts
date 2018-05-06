
local IDX_SWITCH = 75
local IDX_LAMP = 78

local function swtichDevice(domoticz, idx)
   
    local sonoffState = domoticz.devices(idx).active
	if (sonoffState == true) then
	    domoticz.devices(idx).switchOff()
	elseif (sonoffState == false) then
	    domoticz.devices(idx).switchOn()
	end
    
end

return {
	active = true,
	on = {
		devices = { IDX_SWITCH }
	},
	
	execute = function(domoticz, device)
	    
	    if (device.state == 'Click') then
	        
	        swtichDevice(domoticz, IDX_LAMP)
	        device.switchOff()
	    
	    elseif (device.state == 'Double Click') then
	       
	        
	    elseif (device.state == 'Long Click') then
	       
	        
	    end

    end
}
