EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_ADD_ON_LOADED, DragonTracker.Events.onLoaded)
EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_PLAYER_ACTIVATED, DragonTracker.Events.onLoadScreen)
-- EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, DragonTracker.Events.onGuiChanged) -- Used to dump some data, so to debug only

LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.dragon.new,
    DragonTracker.Events.onNewDragon
)
LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.dragonList.createAll,
    DragonTracker.Events.onCreateAllDragon
)
LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.dragonList.removeAll,
    DragonTracker.Events.onRemoveAllFromDragonList
)
LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.dragon.changeType,
    DragonTracker.Events.onDragonChangeType
)
LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.dragon.killed,
    DragonTracker.Events.onDragonKilled
)

SLASH_COMMANDS["/dragontrackerlabeltype"] = DragonTracker.Events.changeLabelType
