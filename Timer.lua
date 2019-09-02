--[[
-- Enable timer used to know since how many time dragon has its status
--]]
function DragonTracker:enabledUpdateTime()
    if DragonTracker.updateTimeEnabled == true then
        return
    end

    EVENT_MANAGER:RegisterForUpdate(self.name, 1000, DragonTracker.updateTime)
    DragonTracker.updateTimeEnabled = true
end

--[[
-- Disable timer used to know since how many time dragon has its status
--]]
function DragonTracker:disableUpdateTime()
    if DragonTracker.updateTimeEnabled == false then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(self.name)
    DragonTracker.updateTimeEnabled = false
end

--[[
-- Callback function on timer.
-- Called each 1sec in dragons zone.
-- Update the GUI for each dragons.
--]]
function DragonTracker.updateTime()
    for worldEventInstanceId=1,3,1 do
        DragonTracker:updateGui(worldEventInstanceId)
    end
end
