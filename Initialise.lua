--[[
-- Module initialiser
-- Intiialise savedVariables, GUI, and events
--]]
function DragonTracker:Initialise()
    DragonTracker.savedVariables = ZO_SavedVars:NewAccountWide("DragonTrackerSavedVariables", 1, nil, {})

    self:guiRestorePosition()
    self:guiDefineFragment()
    self:initDragonGuiItems()

    DragonTracker.ready = true
end

EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_ADD_ON_LOADED, DragonTracker.onLoaded)
EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_PLAYER_ACTIVATED, DragonTracker.onLoadScreen)
EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_WORLD_EVENT_DEACTIVATED, DragonTracker.onWEDeactivate)
EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE, DragonTracker.onWEUnitPin)
-- EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, DragonTracker.onGuiChanged) -- Used to dump some data, so to debug only
