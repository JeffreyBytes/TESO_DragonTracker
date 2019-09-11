--[[
-- Update info about the current zone.
-- Call the method who check if the zone have Dragons.
--]]
function DragonTracker:updateZoneInfo()
    local currentMapZoneIdx = GetCurrentMapZoneIndex()

    self:checkZoneWithDragons(currentMapZoneIdx)

    -- Check parent zone changed (function also called with sub-zone change)
    if self.zoneInfo.lastMapZoneIdx ~= currentMapZoneIdx then
        self.zoneInfo.lastMapZoneIdx = currentMapZoneIdx
        self:initDragonStatus()
    end
end

--[[
-- Check if it's a zone with Dragon.
-- Currently only Elsweyr.
--
-- @param integer currentMapZoneIdx zone index
--]]
function DragonTracker:checkZoneWithDragons(currentMapZoneIdx)
    self.zoneInfo.onDragonZone = false

    -- Not in a dungeon or battleground
    if GetMapContentType() ~= MAP_CONTENT_NONE then
        return
    end

    if currentMapZoneIdx == 680 then -- Elsweyr
        self.zoneInfo.onDragonZone = true
    end
end
