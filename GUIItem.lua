DragonTracker.GUIItem = {}
DragonTracker.GUIItem.__index = DragonTracker.GUIItem

--[[
-- Instanciate a new GUIItem "object"
--
-- @param Dragon dragon The Dragon instance to link with the new GUIItem
--
-- @return GUIItem
--]]
function DragonTracker.GUIItem:new(dragon)

    local guiItem = {
        dragon   = dragon,
        labelctr = nil,
        title    = dragon.GUI.title,
        value    = ""
    }

    setmetatable(guiItem, self)
    
    guiItem.labelctr = _G["DragonTrackerGUIItem" .. dragon.dragonIdx]

    return guiItem
end

--[[
-- Define the text value of the LabelControl to empty string
--]]
function DragonTracker.GUIItem:clear()
    self.labelctr:SetText("")
end

--[[
-- Hide or show all GUIItems.
--
-- @param boolean status true to show it, false to hide it
--]]
function DragonTracker.GUIItem:display(status)
    self.labelctr:SetHidden(not status)
end

--[[
-- Show the container (LabelControl)
--]]
function DragonTracker.GUIItem:show()
    self:display(true)
end

--[[
-- Hide the container (LabelControl)
--]]
function DragonTracker.GUIItem:hide()
    self:display(false)
end

--[[
-- Update the message displayed in GUI for a specific dragon
--]]
function DragonTracker.GUIItem:update()
    local dragonStatus = self.dragon.status.current
    local dragonTime   = self.dragon.status.time
    local statusText   = self:obtainStatusText(dragonStatus)
    local timerText    = self:obtainTimerText(dragonTime)

    local newValue = string.format(
        "%s : %s%s",
        self.title,
        statusText,
        timerText
    )

    if newValue == self.value then
        return
    end

    self.value = newValue
    self.labelctr:SetText(newValue)
end

--[[
-- Obtain the status to display from a dragon status
--
-- @param string dragonStatus The dragon status
--
-- @return string
--]]
function DragonTracker.GUIItem:obtainStatusText(dragonStatus)
    local statusList = DragonTracker.DragonStatus.list

    if dragonStatus == statusList.killed then
        return GetString(SI_DRAGON_TRACKER_STATUS_KILLED)
    elseif dragonStatus == statusList.waiting then
        return GetString(SI_DRAGON_TRACKER_STATUS_WAITING)
    elseif dragonStatus == statusList.fight then
        return GetString(SI_DRAGON_TRACKER_STATUS_FIGHT)
    elseif dragonStatus == statusList.weak then
        return GetString(SI_DRAGON_TRACKER_STATUS_WEAK)
    end

    return GetString(SI_DRAGON_TRACKER_STATUS_UNKNOWN)
end

--[[
-- Obtain the timer text to display for a dragon
--
-- @param number dragonTime the os.time() of the last event
--
-- @return string
--]]
function DragonTracker.GUIItem:obtainTimerText(dragonTime)
    if dragonTime == 0 then
        return ""
    end

    local currentTime = os.time()
    local timeDiff    = currentTime - dragonTime
    local timeUnit    = GetString(SI_DRAGON_TRACKER_TIMER_SECOND)

    if timeDiff > 60 then
        timeDiff = timeDiff / 60
        timeUnit = GetString(SI_DRAGON_TRACKER_TIMER_MINUTE)
    end

    if timeDiff > 60 then
        timeDiff = timeDiff / 60
        timeUnit = GetString(SI_DRAGON_TRACKER_TIMER_HOUR)
    end

    return string.format(
        " %s %d %s",
        GetString(SI_DRAGON_TRACKER_TIMER_SINCE),
        math.floor(timeDiff),
        timeUnit
    )
end
