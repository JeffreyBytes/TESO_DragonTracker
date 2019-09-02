DragonTracker = {}

DragonTracker.name = "DragonTracker"
DragonTracker.savedVariables = nil
DragonTracker.updateTimeEnabled = false

DragonTracker.dragonInfo = {
    [1] = {
        position   = "South",
        gui        = nil,
        status     = nil,
        statusTime = 0,
        statusPrev = nil,
    },
    [2] = {
        position   = "North",
        gui        = nil,
        status     = nil,
        statusTime = 0,
        statusPrev = nil,
    },
    [3] = {
        position   = "West ",
        gui        = nil,
        status     = nil,
        statusTime = 0,
        statusPrev = nil,
    }
}

DragonTracker.status = {
    unknown = "Unknown",
    killed  = "Killed",
    waiting = "waiting",
    fight   = "fight",
    weak    = "weak"
}

DragonTracker.zoneInfo = {
    onDragonZone   = false,
    lastMapZoneIdx = nil
}

--[[
-- Called when the addon is loaded
--
-- @param number eventCode
-- @param string addonName name of the loaded addon
--]]
function DragonTracker.OnAddOnLoaded(eventCode, addOnName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addOnName == DragonTracker.name then
        DragonTracker:Initialise()
    end
end

EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_ADD_ON_LOADED, DragonTracker.OnAddOnLoaded)

--[[
-- Module initialiser
-- Intiialise savedVariables, GUI, and events
--]]
function DragonTracker:Initialise()
    self:obtainSavedVariables()

    self:GuiRestorePosition()
    self:GuiShowHide()
    self:initDragonGuiItems()

    self:checkZone()
    self:addEvents()
end

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
-- Enable timer used to know since how many time dragon has its status
--]]
function DragonTracker:enabledUpdateTime()
    if DragonTracker.updateTimeEnabled == true then
        return
    end

    EVENT_MANAGER:RegisterForUpdate(self.name, 1000, DragonTracker.updateTime)
    DragonTracker.updateTimeEnabled = true
end

--[[
-- Disable timer used to know since how many time dragon has its status
--]]
function DragonTracker:disableUpdateTiem()
    if DragonTracker.updateTimeEnabled == false then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(self.name)
    DragonTracker.updateTimeEnabled = false
end

--[[
-- Obtain all savedVariables used by the addon
--]]
function DragonTracker:obtainSavedVariables()
    DragonTracker.savedVariables = ZO_SavedVars:NewAccountWide("DragonTrackerSavedVariables", 1, nil, {})
end

--[[
-- Restore the GUI's position from savedVariables
--]]
function DragonTracker:GuiRestorePosition()
    local left = self.savedVariables.left
    local top  = self.savedVariables.top

    DragonTrackerGUI:ClearAnchors()
    DragonTrackerGUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

--[[
-- Define GUI has a fragment linked to scenes.
-- With that, the GUI is hidden when we open a menu (like inventory or map)
--]]
function DragonTracker:GuiShowHide()
    local fragment = ZO_SimpleSceneFragment:New(DragonTrackerGUI)

    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
end

--[[
-- Define GUI item for each dragons
--]]
function DragonTracker:initDragonGuiItems()
    self.dragonInfo[1].gui = DragonTrackerGUIDragonSouth
    self.dragonInfo[2].gui = DragonTrackerGUIDragonNorth
    self.dragonInfo[3].gui = DragonTrackerGUIDragonWest
end

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
        self:disableUpdateTiem()
        self:resetDragonStatus()
    end

    -- Hide or show GUI items
    for worldEventInstanceId=1,3,1 do
        DragonTracker.dragonInfo[worldEventInstanceId].gui:SetHidden(not self.zoneInfo.onDragonZone)
    end
end

--[[
-- Reset all info about all dragons.
--]]
function DragonTracker:resetDragonStatus()
    for worldEventInstanceId=1,3,1 do
        self.dragonInfo[worldEventInstanceId].status     = DragonTracker.status.unknown
        self.dragonInfo[worldEventInstanceId].statusTime = 0
        self.dragonInfo[worldEventInstanceId].statusPrev = nil
    end
end

--[[
-- Initialise info about all dragons.
--]]
function DragonTracker:initDragonStatus()
    if self.zoneInfo.onDragonZone == false then
        return
    end

    local worldEventId = nil
    local unitTag = nil
    local unitPin = nil

    for worldEventInstanceId=1,3,1 do
        worldEventId = GetWorldEventId(worldEventInstanceId)

        if worldEventId == 0 then
            self.OnWEDeactivate(nil, worldEventInstanceId)
        else
            unitTag = GetWorldEventInstanceUnitTag(worldEventInstanceId, 1)
            unitPin = GetWorldEventInstanceUnitPinType(worldEventInstanceId, unitTag)

            self.OnWEUnitPin(nil, worldEventInstanceId, nil, nil, unitPin)
        end

        self.dragonInfo[worldEventInstanceId].statusTime = 0
    end
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
-- To change the dragon's status.
--
-- @param number worldEventInstanceId The concerned world event (aka dragon).
-- @param string newStatus The new dragon status in DragonTracker.dragonStatus list
--]]
function DragonTracker:changeDragonStatus(worldEventInstanceId, newStatus)
    self.dragonInfo[worldEventInstanceId].statusPrev = self.dragonInfo[worldEventInstanceId].status
    self.dragonInfo[worldEventInstanceId].status     = newStatus
    self.dragonInfo[worldEventInstanceId].statusTime = os.time()

    local currentStatus  = self.dragonInfo[worldEventInstanceId].status
    local previousStatus = self.dragonInfo[worldEventInstanceId].statusPrev

    if previousStatus == nil or previousStatus == currentStatus then
        self.dragonInfo[worldEventInstanceId].statusTime = 0
    end
end

--[[
-- Update the message displayed in GUI for a specific dragon
--
-- @param number worldEventInstanceId The concerned world event (aka dragon).
--]]
function DragonTracker:updateGui(worldEventInstanceId)
    if worldEventInstanceId > 4 then
        return
    end

    local guiItem        = self.dragonInfo[worldEventInstanceId].gui
    local dragonPosition = self.dragonInfo[worldEventInstanceId].position
    local dragonStatus   = self.dragonInfo[worldEventInstanceId].status
    local dragonTime     = self.dragonInfo[worldEventInstanceId].statusTime
    local currentTime    = os.time()
    local textMessage    = ""

    if dragonStatus == self.status.killed then
        textMessage = "Killed"
    elseif dragonStatus == self.status.waiting then
        textMessage = "Waiting or flying"
    elseif dragonStatus == self.status.fight then
        textMessage = "In fight"
    elseif dragonStatus == self.status.weak then
        textMessage = "In fight (life < 50%)"
    else
        textMessage = "Unknown"
    end

    if dragonTime ~= 0 then
        local timeDiff       = currentTime - dragonTime
        local timeUnit       = "sec"

        if timeDiff > 60 then
            timeDiff = timeDiff / 60
            timeUnit = "min"
        end

        if timeDiff > 60 then
            timeDiff = timeDiff / 60
            timeUnit = "h"
        end

        textMessage = textMessage .. " since " .. math.floor(timeDiff) .. timeUnit
    end

    guiItem:SetText(dragonPosition .. " : " .. textMessage)
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

--[[
-- Callback function on timer.
-- Called each 1sec in dragons zone.
-- Update the GUI for each dragons.
--]]
function DragonTracker.updateTime()
    for worldEventInstanceId=1,3,1 do
        DragonTracker:updateGui(worldEventInstanceId)
    end
end
