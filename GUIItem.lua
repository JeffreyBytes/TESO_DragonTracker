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
    local killedStatus = LibDragonWorldEvent.DragonStatus.list.killed
    local repopTime    = LibDragonWorldEvent.Zone.repopTime
    local newValue     = ""

    if dragonStatus == killedStatus and repopTime > 0 then
        newValue = self:obtainRepopInValue(dragonStatus)
    else
        newValue = self:obtainSinceValue(dragonStatus)
    end

    if newValue == self.value then
        return
    end

    self.value = newValue
    self.labelctr:SetText(newValue)
end

--[[
-- Obtain the text to display with a "[status] since..."
--
-- @param string dragonStatus Current dragon's status
--
-- @return string
--]]
function DragonTracker.GUIItem:obtainSinceValue(dragonStatus)
    local dragonTime = self.dragon.status.time
    local statusText = self:obtainStatusText(dragonStatus)
    local timerInfo  = self:obtainSinceTimerInfo(dragonTime)

    if timerInfo == nil then
        return string.format(
            GetString(SI_DRAGON_TRACKER_GUI_SIMPLE),
            self.title,
            statusText
        )
    else
        return string.format(
            GetString(SI_DRAGON_TRACKER_GUI_STATUS),
            self.title,
            statusText,
            timerInfo.value,
            timerInfo.unit
        )
    end
end

--[[
-- Obtain the text to display with a "repop in..."
--
-- @return string
--]]
function DragonTracker.GUIItem:obtainRepopInValue(dragonStatus)
    local dragonTime = self.dragon.status.time
    local timerInfo  = self:obtainInTimerInfo(dragonTime)

    if timerInfo == nil then
        return self:obtainSinceValue(dragonStatus)
    else
        return string.format(
            GetString(SI_DRAGON_TRACKER_GUI_REPOP),
            self.title,
            timerInfo.value,
            timerInfo.unit
        )
    end
end

--[[
-- Obtain the status to display from a dragon status
--
-- @param string dragonStatus The dragon status
--
-- @return string
--]]
function DragonTracker.GUIItem:obtainStatusText(dragonStatus)
    local statusList = LibDragonWorldEvent.DragonStatus.list

    if dragonStatus == statusList.killed then
        return GetString(SI_LIB_DRAGON_WORLD_EVENT_STATUS_KILLED)
    elseif dragonStatus == statusList.waiting then
        return GetString(SI_LIB_DRAGON_WORLD_EVENT_STATUS_WAITING)
    elseif dragonStatus == statusList.fight then
        return GetString(SI_LIB_DRAGON_WORLD_EVENT_STATUS_FIGHT)
    elseif dragonStatus == statusList.weak then
        return GetString(SI_LIB_DRAGON_WORLD_EVENT_STATUS_WEAK)
    elseif dragonStatus == statusList.flying then
        return GetString(SI_LIB_DRAGON_WORLD_EVENT_STATUS_FLYING)
    end

    return GetString(SI_LIB_DRAGON_WORLD_EVENT_STATUS_UNKNOWN)
end

--[[
-- Obtain the timer text to display when message is "[status] since..." (so count from 0)
--
-- @param number dragonTime the os.time() of the last event
--
-- @return table
--]]
function DragonTracker.GUIItem:obtainSinceTimerInfo(dragonTime)
    if dragonTime == 0 then
        return nil
    end

    local currentTime = os.time()
    local timeDiff    = currentTime - dragonTime

    return self:formatTime(timeDiff)
end

--[[
-- Obtain the timer text to display when message is "repop in..." (so count to 0)
--
-- @param number dragonTime the os.time() of the last event
--
-- @return table
--]]
function DragonTracker.GUIItem:obtainInTimerInfo(dragonTime)
    local repopTime  = LibDragonWorldEvent.Zone.repopTime

    if dragonTime == 0 then
        return nil
    end

    local currentTime = os.time()
    local repopTime   = dragonTime + repopTime
    local timeDiff    = repopTime - currentTime

    if timeDiff < 0 then
        timeDiff = 0
    end

    return self:formatTime(timeDiff)
end

--[[
-- Format the time to have it for second, minute, or hour
--
-- @param number timeValue the os.time() of the last event
--
-- @return table
--]]
function DragonTracker.GUIItem:formatTime(timeValue)
    local timeUnit = GetString(SI_DRAGON_TRACKER_TIMER_SECOND)

    if timeValue > 60 then
        timeValue = timeValue / 60
        timeUnit = GetString(SI_DRAGON_TRACKER_TIMER_MINUTE)
    end

    if timeValue > 60 then
        timeValue = timeValue / 60
        timeUnit = GetString(SI_DRAGON_TRACKER_TIMER_HOUR)
    end

    return {
        value = timeValue,
        unit  = timeUnit
    }
end
