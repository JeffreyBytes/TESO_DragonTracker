DragonTracker = {}

DragonTracker.name = "DragonTracker"
DragonTracker.savedVariables = nil
DragonTracker.ready = false
DragonTracker.updateTimeEnabled = false

DragonTracker.dragonInfo = {
    [1] = {
        position   = GetString(SI_DRAGON_TRACKER_CP_SOUTH),
        gui        = nil,
        status     = nil,
        statusTime = 0,
        statusPrev = nil,
    },
    [2] = {
        position   = GetString(SI_DRAGON_TRACKER_CP_NORTH),
        gui        = nil,
        status     = nil,
        statusTime = 0,
        statusPrev = nil,
    },
    [3] = {
        position   = GetString(SI_DRAGON_TRACKER_CP_WEST),
        gui        = nil,
        status     = nil,
        statusTime = 0,
        statusPrev = nil,
    }
}

DragonTracker.status = {
    unknown = "Unknown",
    killed  = "Killed",
    waiting = "waiting",
    fight   = "fight",
    weak    = "weak"
}

DragonTracker.zoneInfo = {
    onDragonZone   = false,
    lastMapZoneIdx = nil
}