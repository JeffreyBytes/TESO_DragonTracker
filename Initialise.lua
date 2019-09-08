--[[
-- Module initialiser
-- Intiialise savedVariables, GUI, and events
--]]
function DragonTracker:Initialise()
    DragonTracker.savedVariables = ZO_SavedVars:NewAccountWide("DragonTrackerSavedVariables", 1, nil, {})

    self:GuiRestorePosition()
    self:GuiShowHide()
    self:initDragonGuiItems()

    DragonTracker.ready = true
end

EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_ADD_ON_LOADED, DragonTracker.OnLoaded)
EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_PLAYER_ACTIVATED, DragonTracker.OnLoadScreen)
EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_WORLD_EVENT_DEACTIVATED, DragonTracker.OnWEDeactivate)
EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE, DragonTracker.OnWEUnitPin)
-- EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, DragonTracker.OnGuiChanged) -- Used to dump some data, so to debug only
