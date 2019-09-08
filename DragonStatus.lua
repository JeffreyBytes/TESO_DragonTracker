--[[
-- Reset all info about all dragons.
--]]
function DragonTracker:resetDragonStatus()
    for worldEventInstanceId=1,3,1 do
        self.dragonInfo[worldEventInstanceId].status     = DragonTracker.status.unknown
        self.dragonInfo[worldEventInstanceId].statusTime = 0
        self.dragonInfo[worldEventInstanceId].statusPrev = nil
    end
end

--[[
-- Initialise info about all dragons.
--]]
function DragonTracker:initDragonStatus()
    if self.zoneInfo.onDragonZone == false then
        return
    end

    local worldEventId = nil
    local unitTag = nil
    local unitPin = nil

    for worldEventInstanceId=1,3,1 do
        worldEventId = GetWorldEventId(worldEventInstanceId)

        if worldEventId == 0 then
            self.OnWEDeactivate(nil, worldEventInstanceId)
        else
            unitTag = GetWorldEventInstanceUnitTag(worldEventInstanceId, 1)
            unitPin = GetWorldEventInstanceUnitPinType(worldEventInstanceId, unitTag)

            self.OnWEUnitPin(nil, worldEventInstanceId, nil, nil, unitPin)
        end

        self.dragonInfo[worldEventInstanceId].statusTime = 0
    end
end

--[[
-- To change the dragon's status.
--
-- @param number worldEventInstanceId The concerned world event (aka dragon).
-- @param string newStatus The new dragon status in DragonTracker.dragonStatus list
--]]
function DragonTracker:changeDragonStatus(worldEventInstanceId, newStatus)
    self.dragonInfo[worldEventInstanceId].statusPrev = self.dragonInfo[worldEventInstanceId].status
    self.dragonInfo[worldEventInstanceId].status     = newStatus
    self.dragonInfo[worldEventInstanceId].statusTime = os.time()

    local currentStatus  = self.dragonInfo[worldEventInstanceId].status
    local previousStatus = self.dragonInfo[worldEventInstanceId].statusPrev

    if previousStatus == nil or previousStatus == currentStatus then
        self.dragonInfo[worldEventInstanceId].statusTime = 0
    end
end

--[[
-- Convert from MAP_PIN_TYPE_DRAGON_* constant value to DragonTracker.status value
--
-- @param number mapPin
--
-- @return string
--]]
function DragonTracker:obtainDragonStatus(mapPin)
    if mapPin == MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY then
        return DragonTracker.status.waiting
    elseif mapPin == MAP_PIN_TYPE_DRAGON_IDLE_WEAK then
        return DragonTracker.status.waiting
    elseif mapPin == MAP_PIN_TYPE_DRAGON_COMBAT_HEALTHY then
        return DragonTracker.status.fight
    elseif mapPin == MAP_PIN_TYPE_DRAGON_COMBAT_WEAK then
        return DragonTracker.status.weak
    else
        return DragonTracker.status.killed
    end
end
