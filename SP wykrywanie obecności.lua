

local IDX_PRESENCE_PERCENTAGE = 74
local IDX_REAL_PRESENCE_PERCENTAGE = 87

local IDX_DOOR = 80
local IDX_MOTION_PERCENTAGE = 84
local IDX_LAPTOP_PAULINA_FIRST = 53
local IDX_LAPTOP_PAULINA_SECOND = 70
local IDX_LAPTOP_TOMEK = 66
local IDX_PHONE_PAULINA_FIRST = 63
local IDX_PHONE_PAULINA_SECOND = 50

local WEIGHT_DOOR = 10
local WEIGHT_MOTION_SENSOR = 0.76
local WEIGHT_LAPTOP = 30
local WEIGHT_PHONE = 30
local WEIGHT_MULTIPLER_NIGHT = 2

local DECRASE_VALUE_DAY = -4
local DECRASE_VALUE_NIGHT = -1

local Time = require('Time')

local function setPercentage(domoticz, deviceIDX, newValue)
    
    local newValueCopy = newValue
    -- cut to <0 ; 100>
	if (newValue > 100) then
		newValueCopy = 100
    elseif (newValue < 0) then
	    newValueCopy = 0
	end
	domoticz.devices(IDX_REAL_PRESENCE_PERCENTAGE).updateCustomSensor(newValue)
	domoticz.devices(deviceIDX).updatePercentage(newValueCopy)
	domoticz.log("Presence updated with value: " .. newValueCopy .. " original no cut: " .. newValue, domoticz.LOG_DEBUG)
    
end

local function isNight()
     
    local actualTime = Time()
    if (actualTime.matchesRule('at 00:00-07:00 on mon, tue, wed, thu, sun') or actualTime.matchesRule('at 01:00-08:00 on fri, sat')) then
        return true
    else
        return false
    end    
    
end

local function calculateMinimalPresence(domoticz)
   
    local laptopPaulinaFirst = domoticz.devices(IDX_LAPTOP_PAULINA_FIRST)
    local laptopPaulinaSecond = domoticz.devices(IDX_LAPTOP_PAULINA_SECOND)
    local laptopTomek = domoticz.devices(IDX_LAPTOP_TOMEK)
    local phonePaulinaFirst = domoticz.devices(IDX_PHONE_PAULINA_FIRST)
    local phonePaulinaSecond = domoticz.devices(IDX_PHONE_PAULINA_SECOND)
    local motionPercentage = domoticz.devices(IDX_MOTION_PERCENTAGE)
   
    local minimalPresence = 0
    
    local globalWeight = 1
    
    if (isNight()) then
        globalWeight = WEIGHT_MULTIPLER_NIGHT
    end
    
    if (laptopPaulinaFirst.bState == true) then
        minimalPresence = minimalPresence + WEIGHT_LAPTOP
    end
    
    if (laptopPaulinaSecond.bState == true) then
        minimalPresence = minimalPresence + WEIGHT_LAPTOP
    end
    
    if (laptopTomek.bState == true) then
        minimalPresence = minimalPresence + WEIGHT_LAPTOP
    end
    
    if (phonePaulinaFirst.bState == true) then
        minimalPresence = minimalPresence + WEIGHT_PHONE
    end
    
    if (phonePaulinaSecond.bState == true) then
        minimalPresence = minimalPresence + WEIGHT_PHONE
    end
    
    minimalPresence = minimalPresence + (motionPercentage.percentage * WEIGHT_MOTION_SENSOR)
    
    minimalPresence = minimalPresence * globalWeight
    
    domoticz.log("minimalPresence: " .. minimalPresence, domoticz.LOG_DEBUG)
    return minimalPresence
    
end

local function changePresencePercentage(domoticz, deviceIDX, changeValue)
    
    local presencePercentage = domoticz.globalData.presenceValueSP
    local newValue = 0
    
    local minimalPresence = 0
    if (changeValue < 0) then
        minimalPresence = calculateMinimalPresence(domoticz)
        
        if (minimalPresence > (presencePercentage + changeValue)) then
            
            domoticz.globalData.presenceValueSP = minimalPresence
            setPercentage(domoticz, deviceIDX, minimalPresence)
            return
            
        end
        
    end
    
    domoticz.globalData.presenceValueSP = presencePercentage + changeValue
    
    setPercentage(domoticz, deviceIDX, presencePercentage + changeValue)
    
end

local function calculateStateValue(domoticz, state, weight)
   
    local newWeight = 0
    if (state == true) then
        newWeight = weight
    else
        newWeight = -weight
    end
    
    domoticz.log("calculateStateValue returned: " .. newWeight, domoticz.LOG_DEBUG)
    return newWeight
    
end

local function calculateMotionPercentageWeightValue(domoticz, device)
   
    local motionPercentageLastValue = domoticz.globalData.motionPercentageLastValueSP
    local motionPercentageActualValue = device.percentage
    
    local diffPercentage = motionPercentageActualValue - motionPercentageLastValue
    domoticz.globalData.motionPercentageLastValueSP = motionPercentageActualValue 
    
    local returnValue = WEIGHT_MOTION_SENSOR * diffPercentage
    
    domoticz.log("motion sensor last value: " .. motionPercentageLastValue .. " " .. returnValue .. " "
        .. motionPercentageActualValue .. " " .. diffPercentage .. " " .. domoticz.globalData.motionPercentageLastValueSP, domoticz.LOG_DEBUG) 
    
    return returnValue
    
end

local function calculateComputerWeightValue(domoticz, device)
   
    if (device.bState == domoticz.data.previousComputerStance) then
        return 0.0
    else
        return calculateStateValue(domoticz, device.bState, WEIGHT_COMPUTER)
    end
    
end

local function getSwitchWeightValue(domoticz, device)
    
    if (device.state == 'Off') then
        return 0.0
    end
    
    local returnValue = 0.0
       
    if (device.lastUpdate.minutesAgo > 10) then
        returnValue = WEIGHT_SWITCH * 1.0
    elseif (device.lastUpdate.minutesAgo > 5) then
        returnValue = WEIGHT_SWITCH * 0.7
    elseif (device.lastUpdate.minutesAgo > 2) then
        returnValue = WEIGHT_SWITCH * 0.4
    elseif (device.lastUpdate.minutesAgo > 1) then
        returnValue = WEIGHT_SWITCH * 0.2
    else
        returnValue = WEIGHT_SWITCH * 0.1
    end
    
    returnValue = domoticz.round(returnValue, 2)
    
    domoticz.log("switchWeightValue returned: " .. returnValue, domoticz.LOG_DEBUG)
    return returnValue
end

local function calculateDecraseValue(domoticz, idxPresence, decraseValue)
    
    local minimalPresence = calculateMinimalPresence(domoticz)
    local presencePercentageDevice = domoticz.devices(idxPresence)
    local percentageValue = domoticz.globalData.presenceValueSP
    local newDecraseValue = 0.0
    
    if (percentageValue > minimalPresence) then
        newDecraseValue = (percentageValue / minimalPresence) * decraseValue 
    else
        newDecraseValue = decraseValue
    end
    
    newDecraseValue = domoticz.round(newDecraseValue, 2)
    
    domoticz.log("calculateDecraseValue returned: " .. newDecraseValue .. " other values: " .. minimalPresence .. " " .. percentageValue, domoticz.LOG_DEBUG)
    return newDecraseValue
    
end


return {
    data = {
        previousComputerStance = { initial = false },  
    },
    logging = {
        level = domoticz.LOG_ERROR,   
    },
	on = {
	    timer = {
	        'every 5 minutes'
	    },
		devices = {
			IDX_DOOR, 
			IDX_MOTION_PERCENTAGE,
			IDX_LAPTOP_PAULINA_FIRST,
			IDX_LAPTOP_PAULINA_SECOND,
			IDX_LAPTOP_TOMEK,
			IDX_PHONE_PAULINA_FIRST,
			IDX_PHONE_PAULINA_SECOND,
		}
	},
	execute = function(domoticz, device, triggerInfo)
	    
	    if (triggerInfo.type == domoticz.EVENT_TYPE_DEVICE) then
	        
            local changeValue = 0
	        
	        if (device.idx == IDX_DOOR) then
	           
	           changeValue = WEIGHT_DOOR
	           
            elseif (device.idx == IDX_MOTION_PERCENTAGE) then
	           
	            changeValue = calculateMotionPercentageWeightValue(domoticz, device)
	           
	        elseif (device.idx == IDX_LAPTOP_PAULINA_FIRST or device.idx == IDX_LAPTOP_PAULINA_SECOND or device.idx == IDX_LAPTOP_TOMEK) then
	           
	           changeValue = calculateStateValue(domoticz, device.bState, WEIGHT_LAPTOP)
	           
	        elseif (device.idx == IDX_PHONE_PAULINA_FIRST or device.IDX == IDX_PHONE_PAULINA_SECOND) then
	           
	           changeValue = calculateStateValue(domoticz, device.bState, WEIGHT_PHONE)
	           
	        end
	        
	        domoticz.log("change value in main block: " .. changeValue, domoticz.LOG_DEBUG)
	        changePresencePercentage(domoticz, IDX_PRESENCE_PERCENTAGE, changeValue)
	        
	    elseif (triggerInfo.type == domoticz.EVENT_TYPE_TIMER) then
	        
	        local decraseValue = calculateDecraseValue(domoticz, IDX_PRESENCE_PERCENTAGE, DECRASE_VALUE_DAY)
	        changePresencePercentage(domoticz, IDX_PRESENCE_PERCENTAGE, decraseValue)
	        
	    end
		
	end
}