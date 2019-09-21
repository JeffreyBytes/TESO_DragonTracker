DragonTracker.DragonStatus = {}

-- @var table : List of all status which can be defined
DragonTracker.DragonStatus.list = {
    unknown = "unknown",
    killed  = "killed",
    waiting = "waiting",
    fight   = "fight",
    weak    = "weak"
}

-- @var table : All map pin available and the corresponding status
DragonTracker.DragonStatus.mapPinList = {
    [MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY]   = DragonTracker.DragonStatus.list.waiting,
    [MAP_PIN_TYPE_DRAGON_IDLE_WEAK]      = DragonTracker.DragonStatus.list.waiting,
    [MAP_PIN_TYPE_DRAGON_COMBAT_HEALTHY] = DragonTracker.DragonStatus.list.fight,
    [MAP_PIN_TYPE_DRAGON_COMBAT_WEAK]    = DragonTracker.DragonStatus.list.weak,
}

--[[
-- Initialise the status for a dragon
--
-- @param Dragon dragon : The dragon with the status to initialise
--]]
function DragonTracker.DragonStatus:initForDragon(dragon)
    local status = self:convertMapPin(dragon.unit.pin)
    dragon:resetWithStatus(status)
end

--[[
-- Check the status for all dragon instancied
--]]
function DragonTracker.DragonStatus:checkAllDragon()
    DragonTracker.DragonList:execOnAll(self.checkForDragon)
end

--[[
-- Check the status for a specific dragon.
-- It's a callback for DragonList:execOnAll
--
-- @param Dragon dragon The dragon to check
--]]
function DragonTracker.DragonStatus.checkForDragon(dragon)
    dragon:updateUnit()
    local realStatus = DragonTracker.DragonStatus:convertMapPin(dragon.unit.pin)

    if dragon.status.current ~= realStatus then
        dragon:resetWithStatus(realStatus)
    end
end

--[[
-- Convert from MAP_PIN_TYPE_DRAGON_* constant to a status in the list
--
-- @param number mapPin The dragon map pin
--
-- @return string
--]]
function DragonTracker.DragonStatus:convertMapPin(mapPin)
    local status = self.mapPinList[mapPin]

    if status == nil then
        return self.list.killed
    else
        return status
    end
end
