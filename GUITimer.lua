WorldEventsTracker.GUITimer         = setmetatable({}, {__index = LibWorldEvents.Timer})
WorldEventsTracker.GUITimer.__index = WorldEventsTracker.GUITimer

-- @var string name The timer's name
WorldEventsTracker.GUITimer.name = "WorldEventsTracker_GUITimer"

-- @var number time The time in ms where update() which will be called
WorldEventsTracker.GUITimer.time = 1000

--[[
-- Callback function on timer.
-- Called each 1sec in dragons zone.
-- Update the GUI for each dragons.
--]]
function WorldEventsTracker.GUITimer:update()
    LibWorldEvents.Dragons.DragonList:execOnAll(function(dragon)
        dragon.GUI.item:update()
    end)
end
