DragonTracker.Zone = {}

-- @var boolean If player is on a zone with dragon
DragonTracker.Zone.onDragonZone   = false -- Elweyr is a zone

-- @var boolean If player is on a map with dragon
DragonTracker.Zone.onDragonMap    = false -- A delve is a map in the zone

-- @var nil|number The previous MapZoneIndex
DragonTracker.Zone.lastMapZoneIdx = nil

-- @var boolean If the player has changed zone
DragonTracker.Zone.changedZone    = false

-- @var ref-to-table Info about the current zone (ref to list value corresponding to the zone)
DragonTracker.Zone.info           = nil

-- @var number Number of zone in the list
DragonTracker.Zone.nbZone         = 2

-- @var table List of info about zones with dragons.
DragonTracker.Zone.list           = {
    [1] = { -- North Elsweyr
        mapZoneIdx = 680,
        nbDragons  = 3,
        dragons    = {
            title = {
                [1] = GetString(SI_DRAGON_TRACKER_CP_NORTH),
                [2] = GetString(SI_DRAGON_TRACKER_CP_SOUTH),
                [3] = GetString(SI_DRAGON_TRACKER_CP_WEST)
            },
            WEInstanceId = {
                [1] = 2,
                [2] = 1,
                [3] = 3,
            },
        },
    }
}

--[[
-- Update info about the current zone.
--]]
function DragonTracker.Zone:updateInfo()
    local currentMapZoneIdx = GetCurrentMapZoneIndex()

    self:checkDragonZone(currentMapZoneIdx)

    self.changedZone = false
    if self.lastMapZoneIdx ~= currentMapZoneIdx then
        self.changedZone    = true
        self.lastMapZoneIdx = currentMapZoneIdx
    end
end

--[[
-- Check if it's a zone with dragons.
--
-- @param number currentMapZoneIdx The current MapZoneIndex
--]]
function DragonTracker.Zone:checkDragonZone(currentMapZoneIdx)
    self.onDragonZone = false
    self.onDragonMap  = false

    local listIdx    = 1
    local mapZoneIdx = 0

    for listIdx=1, self.nbZone do
        mapZoneIdx = self.list[listIdx].mapZoneIdx

        if currentMapZoneIdx == mapZoneIdx then
            self.onDragonMap  = true
            self.onDragonZone = true
            self.info         = self.list[listIdx]
        end
    end

    -- If we are in a dungeon/delve or battleground : no world event.
    if GetMapContentType() ~= MAP_CONTENT_NONE then
        self.onDragonMap = false
    end
end
