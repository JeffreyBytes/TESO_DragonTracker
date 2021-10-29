EVENT_MANAGER:RegisterForEvent(WorldEventsTracker.name, EVENT_ADD_ON_LOADED, WorldEventsTracker.Events.onLoaded)
-- EVENT_MANAGER:RegisterForEvent(WorldEventsTracker.name, EVENT_PLAYER_ACTIVATED, WorldEventsTracker.Events.onLoadScreen)
-- EVENT_MANAGER:RegisterForEvent(WorldEventsTracker.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, WorldEventsTracker.Events.onGuiChanged) -- Used to dump some data, so to debug only

LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.zone.updateInfo,
    WorldEventsTracker.Events.onZoneUpdate
)
LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.dragon.new,
    WorldEventsTracker.Events.onNewDragon
)
LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.dragonList.createAll,
    WorldEventsTracker.Events.onCreateAllDragon
)
LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.dragonList.removeAll,
    WorldEventsTracker.Events.onRemoveAllFromDragonList
)
LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.dragon.changeType,
    WorldEventsTracker.Events.onDragonChangeType
)
LibWorldEvents.Events.callbackManager:RegisterCallback(
    LibWorldEvents.Events.callbackEvents.dragon.killed,
    WorldEventsTracker.Events.onDragonKilled
)

SLASH_COMMANDS["/worldeventstrackerlabeltype"] = WorldEventsTracker.Events.changeLabelType
