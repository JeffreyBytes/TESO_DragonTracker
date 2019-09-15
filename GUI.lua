--[[
-- Restore the GUI's position from savedVariables
--]]
function DragonTracker:guiRestorePosition()
    local left = self.savedVariables.left
    local top  = self.savedVariables.top

    DragonTrackerGUI:ClearAnchors()
    DragonTrackerGUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

--[[
-- Define GUI has a fragment linked to scenes.
-- With that, the GUI is hidden when we open a menu (like inventory or map)
--]]
function DragonTracker:guiDefineFragment()
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
-- Hide or show GUI items according to status value
--
-- @param boolean status : true to display gui, false to hide it
--]]
function DragonTracker:guiShowHide(status)
    -- Hide or show GUI items
    for worldEventInstanceId=1,3,1 do
        DragonTracker.dragonInfo[worldEventInstanceId].gui:SetHidden(not status)
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
        textMessage = GetString(SI_DRAGON_TRACKER_STATUS_KILLED)
    elseif dragonStatus == self.status.waiting then
        textMessage = GetString(SI_DRAGON_TRACKER_STATUS_WAITING)
    elseif dragonStatus == self.status.fight then
        textMessage = GetString(SI_DRAGON_TRACKER_STATUS_FIGHT)
    elseif dragonStatus == self.status.weak then
        textMessage = GetString(SI_DRAGON_TRACKER_STATUS_WEAK)
    else
        textMessage = GetString(SI_DRAGON_TRACKER_STATUS_UNKNOWN)
    end

    if dragonTime ~= 0 then
        local timeDiff       = currentTime - dragonTime
        local timeUnit       = GetString(SI_DRAGON_TRACKER_TIMER_SECOND)

        if timeDiff > 60 then
            timeDiff = timeDiff / 60
            timeUnit = GetString(SI_DRAGON_TRACKER_TIMER_MINUTE)
        end

        if timeDiff > 60 then
            timeDiff = timeDiff / 60
            timeUnit = GetString(SI_DRAGON_TRACKER_TIMER_HOUR)
        end

        textMessage = string.format(
            "%s %s %d %s",
            textMessage,
            GetString(SI_DRAGON_TRACKER_TIMER_SINCE),
            math.floor(timeDiff),
            timeUnit
        )
    end

    guiItem:SetText(dragonPosition .. " : " .. textMessage)
end