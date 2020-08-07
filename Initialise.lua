DragonTracker = {}

DragonTracker.name           = "DragonTracker"
DragonTracker.savedVariables = nil
DragonTracker.ready          = false
DragonTracker.LAM            = LibAddonMenu2

--[[
-- Module initialiser
-- Intiialise savedVariables, settings panel and GUI
--]]
function DragonTracker:Initialise()
    DragonTracker.savedVariables = ZO_SavedVars:NewAccountWide("DragonTrackerSavedVariables", 1, nil, {})
    self:initSavedVars()

    DragonTracker.Settings:init()
    DragonTracker.GUI:init()
    DragonTracker.ready = true
end

--[[
-- Initialise all savedVariable's default values
--]]
function DragonTracker:initSavedVars()
    if DragonTracker.savedVariables.gui == nil then
        DragonTracker.savedVariables.gui = {}
    end
    local gui = DragonTracker.savedVariables.gui

    if gui.labelFormat == nil then
        gui.labelFormat = "cp"
    end
    if gui.labelFormat ~= "cp" and gui.labelFormat ~= "ln" then
        gui.labelFormat = "cp"
    end

    if gui.position == nil then
        gui.position = {}
    end
    if gui.position.left == nil then
        gui.position.left = 0
    end
    if gui.position.top == nil then
        gui.position.top = 0
    end

    if gui.locked == nil then
        gui.locked = false
    end

    if gui.displayWithWMap == nil then
        gui.displayWithWMap = false
    end

    if gui.toDisplay == nil then
        gui.toDisplay = true
    end

    -- Convert old gui info
    if DragonTracker.savedVariables.labelFormat ~= nil then
        gui.labelFormat = DragonTracker.savedVariables.labelFormat
        DragonTracker.savedVariables.labelFormat = nil
    end
    if DragonTracker.savedVariables.left ~= nil then
        gui.position.left = DragonTracker.savedVariables.left
        DragonTracker.savedVariables.left = nil
    end
    if DragonTracker.savedVariables.top ~= nil then
        gui.position.top = DragonTracker.savedVariables.top
        DragonTracker.savedVariables.top = nil
    end
end
