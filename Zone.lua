--[[
-- Check if the current zone is Elsweyr.
-- Also call methods used to define dragons status.
-- And hide or show GUI items we are (or not) in Elsweyr.
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

    -- No world event (currently aka Dragon) on the zone
    if GetNextWorldEventInstanceId() == nil then
        return
    end

    if currentMapZoneIdx == 680 then -- Elsweyr
        self.zoneInfo.onDragonZone = true
    end
end
