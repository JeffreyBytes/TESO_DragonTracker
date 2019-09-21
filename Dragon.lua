DragonTracker.Dragon = {}
DragonTracker.Dragon.__index = DragonTracker.Dragon

--[[
-- Instanciate a new Dragon "object"
--
-- @param number dragonIdx The dragon index in DragonList.list
-- @param number WEInstanceId The dragon's WorldEventInstanceId
--
-- @return Dragon
--]]
function DragonTracker.Dragon:new(dragonIdx, WEInstanceId)
    local newDragon = {
        dragonIdx    = dragonIdx,
        WEInstanceId = WEInstanceId,
        WEId    = nil,
        unit         = {
            tag = nil,
            pin = nil,
        },
        position     = {
            x = 0,
            y = 0,
            z = 0,
        },
        GUI          = {
            item  = nil,
            title = DragonTracker.Zone.info.dragons.title[dragonIdx],
        },
        status       = {
            previous = nil,
            current  = nil,
            time     = 0,
        }
    }

    setmetatable(newDragon, self)

    newDragon:updateUnit()
    newDragon.GUI.item = DragonTracker.GUI:createItem(newDragon)
    DragonTracker.DragonStatus:initForDragon(newDragon)

    -- Not need, already updated each 1 second
    -- DragonTracker.GUI:updateForDragon(newDragon)

    return newDragon
end

--[[
-- Update the WorldEventId
--]]
function DragonTracker.Dragon:updateWEId()
    self.WEId = GetWorldEventId(self.WEInstanceId)
end

--[[
-- Update the dragon's UnitTag and UnitPinType
--]]
function DragonTracker.Dragon:updateUnit()
    self:updateWEId()

    self.unit.tag = GetWorldEventInstanceUnitTag(self.WEInstanceId, 1)
    self.unit.pin = GetWorldEventInstanceUnitPinType(self.WEInstanceId, self.unit.tag)
end

--[[
-- Change the dragon's current status
--
-- @param string newStatus The dragon's new status in DragonStatus.list
-- @param string unitTag (default nil) The new unitTag
-- @param number unitPin (default nil) The new unitPin
--]]
function DragonTracker.Dragon:changeStatus(newStatus, unitTag, unitPin)
    self.status.previous = self.status.current
    self.status.current  = newStatus
    self.status.time     = os.time()

    if self.status.previous == nil or self.status.previous == self.status.current then
        self.status.time = 0
    end

    if unitTag ~= nil then
        self.unit.tag = unitTag
    end

    if unitPin ~= nil then
        self.unit.pin = unitPin
    end
end

--[[
-- Reset dragon's status info and define the status with newStatus.
--
-- @param string newStatus The dragon's new status in DragonStatus.list
--]]
function DragonTracker.Dragon:resetWithStatus(newStatus)
    self.status.previous = nil
    self.status.current  = newStatus
    self.status.time     = 0
end
