--[[
-- Called when the addon is loaded
--
-- @param number eventCode
-- @param string addonName name of the loaded addon
--]]
function DragonTracker.OnLoaded(eventCode, addOnName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addOnName == DragonTracker.name then
        DragonTracker:Initialise()
    end
end

--[[
-- Called when the user's interface loads and their character is activated after logging in or performing a reload of the UI.
-- This happens after <EVENT_ADD_ON_LOADED>, so the UI and all addons should be initialised already.
--
-- @param integer eventCode
-- @param boolean initial : true if the user just logged on, false with a UI reload (for example)
--]]
function DragonTracker.OnLoadScreen(eventCode, initial)
    if DragonTracker.ready == false then
        return
    end
    
    DragonTracker:updateZoneInfo()
    DragonTracker:changeTimerStatus(DragonTracker.zoneInfo.onDragonZone)
    DragonTracker:GuiShowHide(DragonTracker.zoneInfo.onDragonZone)
    DragonTracker:checkDragonStatus()
end

--[[
-- Called when a World Event is finished (aka dragon killed).
--
-- @param number eventCode
-- @param number worldEventInstanceId The concerned world event (aka dragon).
--]]
function DragonTracker.OnWEDeactivate(eventCode, worldEventInstanceId)
    if DragonTracker.ready == false then
        return
    end
    
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
    if DragonTracker.ready == false then
        return
    end
    
    if DragonTracker.zoneInfo.onDragonZone == false then
        return
    end
    
    local dragonStatus = DragonTracker:obtainDragonStatus(newPinType)
    
    DragonTracker:changeDragonStatus(worldEventInstanceId, dragonStatus)
    DragonTracker:updateGui(worldEventInstanceId)
end

--[[
-- Called when GUI items has been moved by user
--]]
function DragonTracker.OnGuiMoveStop()
    if DragonTracker.ready == false then
        return
    end
    
    DragonTracker.savedVariables.left = DragonTrackerGUI:GetLeft()
    DragonTracker.savedVariables.top  = DragonTrackerGUI:GetTop()
end

--[[
-- Called when something change in GUI (like open inventory).
-- Used to some debug, the add to event is commented.
--]]
function DragonTracker.OnGuiChanged(eventCode)
    if DragonTracker.ready == false then
        return
    end
end