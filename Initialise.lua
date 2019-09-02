--[[
-- Called when the addon is loaded
--
-- @param number eventCode
-- @param string addonName name of the loaded addon
--]]
function DragonTracker.OnAddOnLoaded(eventCode, addOnName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addOnName == DragonTracker.name then
        DragonTracker:Initialise()
    end
end

EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_ADD_ON_LOADED, DragonTracker.OnAddOnLoaded)

--[[
-- Module initialiser
-- Intiialise savedVariables, GUI, and events
--]]
function DragonTracker:Initialise()
    DragonTracker.savedVariables = ZO_SavedVars:NewAccountWide("DragonTrackerSavedVariables", 1, nil, {})

    self:GuiRestorePosition()
    self:GuiShowHide()
    self:initDragonGuiItems()

    self:checkZone()
    self:addEvents()
end