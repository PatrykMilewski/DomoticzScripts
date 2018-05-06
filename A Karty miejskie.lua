
local IDX_GATEWAY_ALARM = 58

local DOMOTICZ_PORT = 8080

local CARDS_AMOUNT = 2
local IDX_COUNTER_PATRYK = 61
local IDX_COUNTER_IZA = 62

local CARD_ID_PATRYK = "1260772102"
local CARD_ID_IZA = "0697816305"

-- need to update
local CARD_ID_PAULINA = "1234567890"
local CARD_ID_BASIA = "1234567890"

local COUNTERS_AND_CARDS = {
    [1] = { IDX_COUNTER_PATRYK, CARD_ID_PATRYK },
    [2] = { IDX_COUNTER_IZA, CARD_ID_IZA }
}

local function canRaiseAlarm(cardID)
    
    if (cardID ~= CARD_ID_PATRYK and cardID ~= CARD_ID_IZA) then
        return false
    end
    
    local Time = require('Time')
	local actualTime = Time()
    
    if (actualTime.matchesRule('at 20:45-21:15') 
        or actualTime.matchesRule('at 6:15-6:45 on mon, tue, wed, thu, fri') 
        or actualTime.matchesRule('at 9:00 on sat, sun')) then
        return true
    else
        return false
    end    
    
end


return {
	on = {
	    timer = {'every hour'},
		devices = { IDX_COUNTER_PATRYK, IDX_COUNTER_IZA }
	},
	
	logging = {
        level = domoticz.LOG_DEBUG
    },

	execute = function(domoticz, device, triggerInfo)
        
        if (triggerInfo.type == domoticz.EVENT_TYPE_TIMER) then
        
            local commandBase = "python /home/pi/domoticz/scripts/python/checkCardDate.py "
            
            for userIndex, counterAndCard in pairs(COUNTERS_AND_CARDS) do
            
                local command = commandBase .. counterAndCard[2] .. " " .. counterAndCard[1] .. " " .. DOMOTICZ_PORT
                domoticz.utils.osExecute(command)
                
            end
            
        elseif (triggerInfo.type == domoticz.EVENT_TYPE_DEVICE) then
            
            if (canRaiseAlarm() == false) then
                return
            end
            
            local gateway = domoticz.devices(IDX_GATEWAY_ALARM)
            
            if (device.state == "2.0000") then
                domoticz.log("Licznik dni o IDX: " .. device.idx .. " ma wartość 2 dni.")
                gateway.switchSelector(10)
            elseif (device.state == "1.0000") then
                domoticz.log("Licznik dni o IDX: " .. device.idx .. " ma wartość 1 dni, podnoszę ostrzeżenie.")
                gateway.switchSelector(20)
            elseif (device.state == "0.0000") then
                domoticz.log("Licznik dni o IDX: " .. device.idx .. " ma wartość 0 dni, zgłaszam awarię.")
                gateway.switchSelector(40)
            end
            
        end
        
    end
}