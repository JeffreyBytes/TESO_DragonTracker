DragonTracker.GUITimer         = setmetatable({}, {__index = LibDragonWorldEvent.Timer})
DragonTracker.GUITimer.__index = DragonTracker.GUITimer

-- @var string name The timer's name
DragonTracker.GUITimer.name = "DragonTracker_GUITimer"

-- @var number time The time in ms where update() which will be called
DragonTracker.GUITimer.time = 1000

--[[
-- Callback function on timer.
-- Called each 1sec in dragons zone.
-- Update the GUI for each dragons.
--]]
function DragonTracker.GUITimer:update()
    LibDragonWorldEvent.DragonList:execOnAll(function(dragon)
        dragon.GUI.item:update()
    end)
end
