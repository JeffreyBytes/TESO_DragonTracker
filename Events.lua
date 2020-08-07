DragonTracker.Events = {}

--[[
-- Called when the addon is loaded
--
-- @param number eventCode
-- @param string addonName name of the loaded addon
--]]
function DragonTracker.Events.onLoaded(eventCode, addOnName)
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
function DragonTracker.Events.onLoadScreen(eventCode, initial)
    if DragonTracker.ready == false then
        return
    end

    DragonTracker.GUITimer:changeStatus(LibDragonWorldEvent.Zone.onDragonMap)
    DragonTracker.GUI:display(LibDragonWorldEvent.Zone.onDragonMap)
end

--[[
-- Called when a new dragon instance is created
--
-- @param table dragon The new dragon instance
--]]
function DragonTracker.Events.onNewDragon(dragon)
    dragon.GUI = {
        item  = nil,
        title = dragon.title,
    }

    dragon.GUI.item = DragonTracker.GUI:createItem(dragon)

    DragonTracker.Events.onDragonChangeType(dragon)
end

--[[
-- Called when all dragon are created from DragonList
--
-- @param table dragonList The DragonList table
--]]
function DragonTracker.Events.onCreateAllDragon(dragonList)
    DragonTracker.GUI:changeLabelType(DragonTracker.savedVariables.gui.labelFormat)
end

--[[
-- Called when all dragon is removed from DragonList
--
-- @param table dragonList The DragonList table
--]]
function DragonTracker.Events.onRemoveAllFromDragonList(dragonList)
    DragonTracker.GUI:resetItem()
end

--[[
-- Called when a dragon's type change
--
-- @param Dragon dragon The concerned dragon
--]]
function DragonTracker.Events.onDragonChangeType(dragon)
    if dragon.GUI == nil then
        return
    end
    
    local alpha = 1
    if dragon.type.colorRGB == nil then
        alpha = 0
    end

    dragon.GUI.item:changeColor(dragon.type.colorRGB, alpha)
end

--[[
-- Called when a dragon is killed
--
-- @param Dragon dragon The killed dragon
--]]
function DragonTracker.Events.onDragonKilled(dragon)
    if dragon.GUI == nil then
        return
    end
    
    dragon.GUI.item:changeColor(nil, 0)
end

--[[
-- Called when GUI items has been moved by user
--]]
function DragonTracker.Events.onGuiMoveStop()
    if DragonTracker.ready == false then
        return
    end

    DragonTracker.GUI:savePosition()
end

--[[
-- Called when something change in GUI (like open inventory).
-- Used to some debug, the add to event is commented.
--]]
function DragonTracker.Events.onGuiChanged(eventCode)
    if DragonTracker.ready == false then
        return
    end
end

--[[
-- Called when player use slash command /dragontrackerlabeltype.
-- Used to change label name to use between cardinal point and location name.
--
-- @param string labelMode the value after the command
--]]
function DragonTracker.Events.changeLabelType(labelMode)
    if labelMode == "name" then
        DragonTracker.GUI:labelUseName()
    else
        DragonTracker.GUI:labelUseCardinalPoint()
    end
end
