DragonTracker.Settings = {}

-- @var string panelName The name of the settings panel
DragonTracker.Settings.panelName = "DragonTrackerSettingsPanel"

--[[
-- Initialise the settings panel
--]]
function DragonTracker.Settings:init()
    local panelData = {
        type   = "panel",
        name   = "Dragon Tracker",
        author = "bulton-fr",
    }

    DragonTracker.LAM:RegisterAddonPanel(self.panelName, panelData)
    self:build()
end

--[[
-- Build the settings panel
--]]
function DragonTracker.Settings:build()
    local optionsData = {
    }

    DragonTracker.LAM:RegisterOptionControls(self.panelName, optionsData)
end
