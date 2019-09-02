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