DragonTracker = {}

DragonTracker.name = "DragonTracker"
DragonTracker.savedVariables = nil
DragonTracker.ready = false
DragonTracker.updateTimeEnabled = false

DragonTracker.dragonInfo = {
    [1] = {
        position   = "South",
        gui        = nil,
        status     = nil,
        statusTime = 0,
        statusPrev = nil,
    },
    [2] = {
        position   = "North",
        gui        = nil,
        status     = nil,
        statusTime = 0,
        statusPrev = nil,
    },
    [3] = {
        position   = "West ",
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