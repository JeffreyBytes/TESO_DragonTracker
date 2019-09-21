DragonTracker.DragonList = {}

-- @var table List of all dragons instancied
DragonTracker.DragonList.list = {}

-- @var number Number of item in list
DragonTracker.DragonList.nb   = 0

-- @var table Map table with WEInstanceId as key, and index in list as value
DragonTracker.DragonList.WEInstanceIdToListIdx = {}

--[[
-- Reset the list
--]]
function DragonTracker.DragonList:reset()
    self.list                  = {}
    self.nb                    = 0
    self.WEInstanceIdToListIdx = {}
end

--[[
-- Add a new dragon to the list
--
-- @param Dragon dragon : The dragon instance to add
--]]
function DragonTracker.DragonList:add(dragon)
    local newIdx = self.nb + 1

    self.list[newIdx] = dragon
    self.nb           = newIdx

    self.WEInstanceIdToListIdx[dragon.WEInstanceId] = newIdx
end

--[[
-- Execute the callback for all dragon
--
-- @param function callback : A callback called for each dragon in the list.
-- The callback take the dragon instance as parameter.
--]]
function DragonTracker.DragonList:execOnAll(callback)
    local dragonIdx = 1

    for dragonIdx = 1, self.nb do
        callback(self.list[dragonIdx])
    end
end

--[[
-- Obtain the dragon instance for a WEInstanceId
--
-- @return Dragon
--]]
function DragonTracker.DragonList:obtainForWEInstanceId(WEInstanceId)
    local dragonIdx = self.WEInstanceIdToListIdx[WEInstanceId]

    return self.list[dragonIdx]
end

--[[
-- To update the list : remove all dragon or create all dragon compared to Zone info.
--]]
function DragonTracker.DragonList:update()
    if DragonTracker.Zone.changedZone == true then
        self:removeAll()
    end

    if DragonTracker.Zone.onDragonMap == true and self.nb == 0 then
        self:createAll()
    end
end

--[[
-- Remove all dragon instance in the list and reset GUI items list
--]]
function DragonTracker.DragonList:removeAll()
    self:reset()
    DragonTracker.GUI:resetItem()
end

--[[
-- Create a dragon instance for each dragon in the zone, and add it to the list.
--]]
function DragonTracker.DragonList:createAll()
    local dragonIdx    = 1
    local dragon       = nil
    local WEInstanceId = 0
    local nbDragons    = DragonTracker.Zone.info.nbDragons

    self:removeAll()

    for dragonIdx=1, nbDragons do
        WEInstanceId = DragonTracker.Zone.info.dragons.WEInstanceId[dragonIdx]
        dragon       = DragonTracker.Dragon:new(dragonIdx, WEInstanceId)

        self:add(dragon)
    end
end
