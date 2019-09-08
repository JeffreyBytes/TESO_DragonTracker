--[[
-- Check if the current zone is Elsweyr.
-- Also call methods used to define dragons status.
-- And hide or show GUI items we are (or not) in Elsweyr.
--]]
function DragonTracker:checkZone()
    local currentMapZoneIdx = GetCurrentMapZoneIndex()
    local currentMapCtnType = GetMapContentType()
    self.zoneInfo.onDragonZone = false

    -- Check if it's a zone with Dragon
    if currentMapZoneIdx == 680 and currentMapCtnType == 0 then -- Elsweyr
        self.zoneInfo.onDragonZone = true
    end

    -- Check parent zone changed (function also called with sub-zone change) to reset dragon info
    if self.zoneInfo.lastMapZoneIdx ~= currentMapZoneIdx then
        self.zoneInfo.lastMapZoneIdx = currentMapZoneIdx
        self:initDragonStatus()
    end

    DragonTracker:changeTimerStatus(DragonTracker.zoneInfo.onDragonZone)
    DragonTracker:GuiShowHide(DragonTracker.zoneInfo.onDragonZone)
end