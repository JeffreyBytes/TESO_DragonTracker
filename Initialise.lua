DragonTracker = {}

DragonTracker.name           = "DragonTracker"
DragonTracker.savedVariables = nil
DragonTracker.ready          = false

--[[
-- Module initialiser
-- Intiialise savedVariables and GUI
--]]
function DragonTracker:Initialise()
    DragonTracker.savedVariables = ZO_SavedVars:NewAccountWide("DragonTrackerSavedVariables", 1, nil, {})

    local labelFormat = DragonTracker.savedVariables.labelFormat

    if labelFormat == nil then
        DragonTracker.savedVariables.labelFormat = "cp"
    end

    if labelFormat ~= "cp" and labelFormat ~= "ln" then
        DragonTracker.savedVariables.labelFormat = "cp"
    end

    DragonTracker.GUI:init()
    DragonTracker.ready = true
end
