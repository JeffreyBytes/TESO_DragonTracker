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
