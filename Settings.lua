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
        self:buildGUILocked(),
    }

    DragonTracker.LAM:RegisterOptionControls(self.panelName, optionsData)
end

--[[
-- Build the "GUI Locked" part of the panel
--
-- @return table
--]]
function DragonTracker.Settings:buildGUILocked()
    return {
        type = "checkbox",
        name = GetString(SI_DRAGON_TRACKER_SETTINGS_LOCK_UI),
        getFunc = function()
            return DragonTracker.GUI:isLocked()
        end,
        setFunc = function(value)
            DragonTracker.GUI:defineLocked(value)
        end,
    }
end
