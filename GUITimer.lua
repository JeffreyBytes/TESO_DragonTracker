DragonTracker.GUITimer = {}

-- @var string name The timer's name
DragonTracker.GUITimer.name    = "DragonTracker_GUITimer"

-- @var boolean enabled If the timer is enabled or not
DragonTracker.GUITimer.enabled = false

--[[
-- Enable timer used to know since how many time dragon has its status
--]]
function DragonTracker.GUITimer:enable()
    if self.enabled == true then
        return
    end

    EVENT_MANAGER:RegisterForUpdate(self.name, 1000, self.update)
    self.enabled = true
end

--[[
-- Disable timer used to know since how many time dragon has its status
--]]
function DragonTracker.GUITimer:disable()
    if self.enabled == false then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(self.name)
    self.enabled = false
end

--[[
-- Callback function on timer.
-- Called each 1sec in dragons zone.
-- Update the GUI for each dragons.
--]]
function DragonTracker.GUITimer.update()
    DragonTracker.DragonList:execOnAll(function(dragon)
        dragon.GUI.item:update()
    end)
end

--[[
-- Call the method to enable or disable timer according to newStatus value
--
-- @param boolean newStatus : true to enable timer, false to disable it
--]]
function DragonTracker.GUITimer:changeStatus(newStatus)
    if newStatus == true then
        self:enable()
    else
        self:disable()
    end
end
