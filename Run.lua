EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_ADD_ON_LOADED, DragonTracker.Events.onLoaded)
EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_PLAYER_ACTIVATED, DragonTracker.Events.onLoadScreen)
EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_WORLD_EVENT_DEACTIVATED, DragonTracker.Events.onWEDeactivate)
EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE, DragonTracker.Events.onWEUnitPin)
-- EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, DragonTracker.Events.onGuiChanged) -- Used to dump some data, so to debug only
