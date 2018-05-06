
local IDX_GATEWAY = 1
local IDX_HUE = 59
local IDX_BRI = 60


return {
    active = true,
    on = {
        devices = {
            IDX_HUE,
            IDX_BRI
        } 
    },
    logging = {
        level = domoticz.LOG_ERROR 
    },
    execute = function(dz, item)
        
         local Gateway   = dz.devices(IDX_GATEWAY)
         local HueDevice = dz.devices(IDX_HUE)
         local BriDevice = dz.devices(IDX_BRI)
         
         
         url = "http://127.0.0.1:8080/json.htm?type=command&dparam=setcolbrightnessvalue&"

        if HueValue == nil then HueValue = 0 end
        if BriValue == nil then BriValue = 0 end

     function GatewayOn()
        SetScene = 'curl -s '..'"'..url..'idx='..IDX_GATEWAY..'&hue='..HueValue..'&brightness='..BriValue..'&iswhite=false" &'
        dz.utils.osExecute('('..SetScene..' > /dev/null)&')
     end  

         HueValue  = dz.utils.round(HueDevice.level * 3.59),0
         BriValue  = BriDevice.level
         
        if (item.idx == IDX_HUE) then
               if (item.state ~= 'Off') then   
                      if (BriDevice.state == 'Off') then
                          BriValue = BriDevice.lastLevel
                          GatewayOn()
                          BriDevice.dimTo(BriDevice.lastLevel).silent()
                          item.dimTo(item.level).silent()
                      else
                          GatewayOn()
                      end
               else
                   Gateway.switchOff().checkFirst().silent()
                   BriDevice.switchOff().checkFirst().silent()
               end
        end     
        if (item.idx == IDX_BRI) then 
               if (item.state ~= 'Off') then     
                      if (HueDevice.state == 'Off') then
                          HueValue = dz.utils.round(HueDevice.lastLevel * 3.59),0
                          GatewayOn()
                          HueDevice.dimTo(HueDevice.lastLevel).silent()
                          item.dimTo(item.level).silent()
                      else
                          GatewayOn()
                      end
               else
                   Gateway.switchOff().checkFirst().silent()
                   HueDevice.switchOff().checkFirst().silent()
               end
        end
    end
}