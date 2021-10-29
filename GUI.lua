WorldEventsTracker.GUI = {}

-- @var table The TopLevelControl in interface
WorldEventsTracker.GUI.container = nil

-- @var table List of GUIItems associate to a dragon
WorldEventsTracker.GUI.items     = {}

-- @var number Number of GUIItems in items
WorldEventsTracker.GUI.nbItems   = 0

-- @var table Ref to the SavedVariables.gui table
WorldEventsTracker.GUI.savedVars = nil

-- @var table The fragment used to define when the GUI is displayed
WorldEventsTracker.GUI.fragment  = nil

-- @var bool To know if the GUI should be displayed (user config only)
-- It's not the current GUI display status because the user can accept to
-- display it but not be in a dragon's zone (so the GUI will be hidden) !
WorldEventsTracker.GUI.toDisplay = false

--[[
-- Initialise the GUI
--]]
function WorldEventsTracker.GUI:init()
    self.savedVars = WorldEventsTracker.savedVariables.gui
    
    self:obtainContainer()
    self:defineFragment()
    self:restorePosition()
    self:restoreLock()
end

--[[
-- Obtain the TopLevelControl's table
--]]
function WorldEventsTracker.GUI:obtainContainer()
    self.container = WorldEventsTrackerGUI
end

--[[
-- Restore the GUI's position from savedVariables
--]]
function WorldEventsTracker.GUI:restorePosition()
    local left = self.savedVars.position.left
    local top  = self.savedVars.position.top

    self.container:ClearAnchors()
    self.container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

--[[
-- Save the GUI's position from savedVariables
--]]
function WorldEventsTracker.GUI:savePosition()
    self.savedVars.position.left = self.container:GetLeft()
    self.savedVars.position.top  = self.container:GetTop()
end

--[[
-- Restore the GUI locked status
--]]
function WorldEventsTracker.GUI:restoreLock()
    if self.savedVars.locked == nil then
        self.savedVars.locked = false
    end

    self:defineLocked(self.savedVars.locked)
end

--[[
-- Return the status if the GUI should be locked or not
--
-- @return bool
--]]
function WorldEventsTracker.GUI:isLocked()
    return self.savedVars.locked
end

--[[
-- Define if the GUI should be locked or not, and update the GUI to lock it (or not)
--
-- @param bool isLocked The new locked status
--]]
function WorldEventsTracker.GUI:defineLocked(isLocked)
    self.container:SetMouseEnabled(not isLocked)
    self.container:SetMovable(not isLocked)

    self.savedVars.locked = isLocked
end

--[[
-- Define GUI has a fragment linked to scenes.
-- With that, the GUI is hidden when we open a menu (like inventory or map)
--]]
function WorldEventsTracker.GUI:defineFragment()
    self.fragment = ZO_SimpleSceneFragment:New(self.container)

    SCENE_MANAGER:GetScene("hud"):AddFragment(self.fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(self.fragment)

    self:defineDisplayWithWMap(self.savedVars.displayWithWMap)
end

--[[
-- Return the status if the GUI should be display in the world map interface
--
-- @return bool
--]]
function WorldEventsTracker.GUI:isDisplayWithWMap()
    return self.savedVars.displayWithWMap
end

--[[
-- Define the status which define if the GUI is displayed in the world map
-- interface or not, and update the fragment to apply the new status.
--
-- @param bool value
--]]
function WorldEventsTracker.GUI:defineDisplayWithWMap(value)
    self.savedVars.displayWithWMap = value

    if value == true then
        SCENE_MANAGER:GetScene("worldMap"):AddFragment(self.fragment)
    else
        SCENE_MANAGER:GetScene("worldMap"):RemoveFragment(self.fragment)
    end
end

--[[
-- Hide or show all GUIItems.
--
-- @param boolean status true to show it, false to hide it
--]]
function WorldEventsTracker.GUI:display(status)
    if status == true and self.savedVars.toDisplay == false then
        status = false
    end

    -- self.container:SetHidden(not status) -- Not work :(
    local itemIdx = 1
    for itemIdx = 1, self.nbItems do
        self.items[itemIdx]:display(status)
    end
end

--[[
-- Switch the status of toDisplay to be the invert of the previous status, and
-- call self:display() to update the GUI
--]]
function WorldEventsTracker.GUI:toggleToDisplay()
    self.savedVars.toDisplay = not self.savedVars.toDisplay

    if self.savedVars.toDisplay == true then
        self:display(LibWorldEvents.Dragons.ZoneInfo.onMap)
    else
        self:display(false)
    end
end

--[[
-- To create a GUIItem instance for a Dragon and show it
--
-- @param Dragon dragon The dragon instance to link with the new GUIItem
--
-- @return GUIItem
--]]
function WorldEventsTracker.GUI:createItem(dragon)
    local item    = WorldEventsTracker.GUIItem:new(dragon)
    local itemIdx = self.nbItems + 1

    self.items[itemIdx] = item
    self.nbItems        = itemIdx

    item:show()

    return item
end

--[[
-- To reset the list of GUIItems
--]]
function WorldEventsTracker.GUI:resetItem()
    local itemIdx = 1

    for itemIdx = 1, self.nbItems do
        self.items[itemIdx]:clear()
        self.items[itemIdx]:hide()
    end

    self.items   = {}
    self.nbItems = 0
end

--[[
-- Define the label type to use on  the location name.
--]]
function WorldEventsTracker.GUI:labelUseName()
    self:defineLabelType("ln")
end

--[[
-- Define the label type to use on  the cardinal point.
--]]
function WorldEventsTracker.GUI:labelUseCardinalPoint()
    self:defineLabelType("cp")
end

--[[
-- Return the current labelFormat used
--
-- @return string "cp" (cardinal point) or "ln" (location name)
--]]
function WorldEventsTracker.GUI:obtainLabelType()
    return self.savedVars.labelFormat
end

--[[
-- Define the label to use and call the method to move the value controler
-- relative to the max width of labels.
--
-- @param string newType The new type of label ("cp" or "ln")
--]]
function WorldEventsTracker.GUI:defineLabelType(newType)
    self.savedVars.labelFormat = newType

    local itemIdx   = 1
    local widthMax  = 0
    local widthText = 0

    for itemIdx = 1, self.nbItems do
        widthText = self.items[itemIdx]:changeTitleType(newType)

        if widthText > widthMax then
            widthMax = widthText
        end
    end

    for itemIdx = 1, self.nbItems do
        self.items[itemIdx]:moveValueCtr(widthMax)
    end
end
