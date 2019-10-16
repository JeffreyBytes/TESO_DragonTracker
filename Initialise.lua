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

    if DragonTracker.savedVariables.labelFormat == nil then
        DragonTracker.savedVariables.labelFormat = "cp"
    end

    DragonTracker.GUI:init()
    DragonTracker.ready = true
end
