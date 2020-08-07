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
        self:buildDisplayedWithWorldMap(),
        self:buildPositionType()
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

--[[
-- Build the "Displayed with the World Map" part of the panel
--
-- @return table
--]]
function DragonTracker.Settings:buildDisplayedWithWorldMap()
    return {
        type = "checkbox",
        name = GetString(SI_DRAGON_TRACKER_SETTINGS_DISPLAY_WITH_WM),
        getFunc = function()
            return DragonTracker.GUI:isDisplayWithWMap()
        end,
        setFunc = function(value)
            DragonTracker.GUI:defineDisplayWithWMap(value)
        end,
    }
end

--[[
-- Build the "Position type" part of the panel
--
-- @return table
--]]
function DragonTracker.Settings:buildPositionType()
    return {
        type          = "dropdown",
        name          = GetString(SI_DRAGON_TRACKER_SETTINGS_POSITION_TYPE),
        tooltip       = GetString(SI_DRAGON_TRACKER_SETTINGS_POSITION_TYPE_TOOLTIP),
        choices       = {
            GetString(SI_DRAGON_TRACKER_SETTINGS_POSITION_TYPE_CHOICE_LN),
            GetString(SI_DRAGON_TRACKER_SETTINGS_POSITION_TYPE_CHOICE_CP)
        },
        choicesValues = {"ln", "cp"},
        getFunc       = function()
            return DragonTracker.GUI:obtainLabelType()
        end,
        setFunc       = function(labelMode)
            DragonTracker.Events.changeLabelType(labelMode)
        end
    }
end
