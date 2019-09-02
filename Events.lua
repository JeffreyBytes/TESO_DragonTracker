--[[
-- Declare all events to follow
--]]
function DragonTracker:addEvents()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_WORLD_EVENT_DEACTIVATED, DragonTracker.OnWEDeactivate)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE, DragonTracker.OnWEUnitPin)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ZONE_CHANGED, DragonTracker.OnZoneChanged)
    -- EVENT_MANAGER:RegisterForEvent("DragonTracker", EVENT_GAME_CAMERA_UI_MODE_CHANGED, DragonTracker.OnGuiChanged) -- Used to dump some data
end

--[[
-- Called when a World Event is finished (aka dragon killed).
--
-- @param number eventCode
-- @param number worldEventInstanceId The concerned world event (aka dragon).
--]]
function DragonTracker.OnWEDeactivate(eventCode, worldEventInstanceId)
    if DragonTracker.zoneInfo.onDragonZone == false then
        return
    end

    DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.killed)
    DragonTracker:updateGui(worldEventInstanceId)
end

--[[
-- Called when a World Event has this map pin changed (aka new dragon or dragon in fight).
--
-- @param number eventCode
-- @param number worldEventInstanceId The concerned world event (aka dragon).
-- string unitTag
-- number MapDisplayPinType oldPinType
-- number MapDisplayPinType newPinType
--]]
function DragonTracker.OnWEUnitPin(eventCode, worldEventInstanceId, unitTag, oldPinType, newPinType)
    if DragonTracker.zoneInfo.onDragonZone == false then
        return
    end

    if newPinType == MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY then
        DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.waiting)
    elseif newPinType == MAP_PIN_TYPE_DRAGON_IDLE_WEAK then
        DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.waiting)
    elseif newPinType == MAP_PIN_TYPE_DRAGON_COMBAT_HEALTHY then
        DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.fight)
    elseif newPinType == MAP_PIN_TYPE_DRAGON_COMBAT_WEAK then
        DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.weak)
    end

    DragonTracker:updateGui(worldEventInstanceId)
end

--[[
-- Called when the zone change.
--
-- @param number eventCode
-- @param string zoneName
-- @param string subZoneName
-- @param boolean newSubzone
-- @param number zoneId
-- @param number subZoneId
--]]
function DragonTracker.OnZoneChanged(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
    DragonTracker:checkZone()
end

--[[
-- Called when GUI items has been moved by user
--]]
function DragonTracker.OnGuiMoveStop()
    DragonTracker.savedVariables.left = DragonTrackerGUI:GetLeft()
    DragonTracker.savedVariables.top  = DragonTrackerGUI:GetTop()
end

--[[
-- Called when something change in GUI (like open inventory).
-- Used to some debug, the add to event is commented.
--]]
function DragonTracker.OnGuiChanged(eventCode)
    -- do an action
end