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

    -- Enable or disable timer
    if self.zoneInfo.onDragonZone == true then
        self:enabledUpdateTime()
    else
        self:disableUpdateTime()
        self:resetDragonStatus()
    end

    -- Hide or show GUI items
    for worldEventInstanceId=1,3,1 do
        DragonTracker.dragonInfo[worldEventInstanceId].gui:SetHidden(not self.zoneInfo.onDragonZone)
    end
end