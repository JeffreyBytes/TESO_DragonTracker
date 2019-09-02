DragonTracker = {}

DragonTracker.name = "DragonTracker"
DragonTracker.savedVariables = nil
DragonTracker.updateTimeEnabled = false
	
DragonTracker.dragonInfo = {
	[1] = {
		position   = "South",
		gui        = nil,
		status     = nil,
		statusTime = 0
	},
	[2] = {
		position   = "North",
		gui        = nil,
		status     = nil,
		statusTime = 0
	},
	[3] = {
		position   = "West ",
		gui        = nil,
		status     = nil,
		statusTime = 0
	}
}

DragonTracker.status = {
	unknown = "Unknown",
	killed  = "Killed",
	waiting = "waiting",
	figth   = "fight",
	weak    = "weak"
}
	
DragonTracker.zoneInfo = {
	onDragonZone   = false,
	lastMapZoneIdx = nil
}

function DragonTracker.OnAddOnLoaded(eventCode, addOnName)
	-- The event fires each time *any* addon loads - but we only care about when our own addon loads.
	if addOnName == DragonTracker.name then
		DragonTracker:Initialise()
	end
end

EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_ADD_ON_LOADED, DragonTracker.OnAddOnLoaded)

function DragonTracker:Initialise()
	-- self:obtainSavedVariables()
	DragonTracker.savedVariables = ZO_SavedVars:NewAccountWide("DragonTrackerSavedVariables", 1, nil, {})
	
	self:GuiRestorePosition()
	self:GuiShowHide()
	self:initDragonGuiItems()
	self:checkZone()
	self:addEvents()
	
	self.initialised = true
end

function DragonTracker:addEvents()
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_WORLD_EVENT_DEACTIVATED, DragonTracker.OnWEDeactivate)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE, DragonTracker.OnWEUnitPin)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ZONE_CHANGED, DragonTracker.OnZoneChanged)
	-- EVENT_MANAGER:RegisterForEvent("DragonTracker", EVENT_GAME_CAMERA_UI_MODE_CHANGED, DragonTracker.OnGuiChanged) -- Used to dump some data
end

function DragonTracker:enabledUpdateTime()
	if DragonTracker.updateTimeEnabled == true then
		return
	end
	
	EVENT_MANAGER:RegisterForUpdate(self.name, 1000, DragonTracker.updateTime)
	DragonTracker.updateTimeEnabled = true
end

function DragonTracker:disableUpdateTiem()
	if DragonTracker.updateTimeEnabled == false then
		return
	end
	
	EVENT_MANAGER:UnregisterForUpdate(self.name)
	DragonTracker.updateTimeEnabled = false
end

function DragonTracker:obtainSavedVariables()
	DragonTracker.savedVariables = ZO_SavedVars:NewAccountWide("DragonTrackerSavedVariables", 1, nil, {})
end

function DragonTracker:GuiRestorePosition()
	local left = self.savedVariables.left
	local top  = self.savedVariables.top

	DragonTrackerGUI:ClearAnchors()
	DragonTrackerGUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function DragonTracker:GuiShowHide()
	local fragment = ZO_SimpleSceneFragment:New(DragonTrackerGUI)
	
	SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
	SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
end

function DragonTracker:initDragonGuiItems()
	self.dragonInfo[1].gui = DragonTrackerGUIDragonSouth
	self.dragonInfo[2].gui = DragonTrackerGUIDragonNorth
	self.dragonInfo[3].gui = DragonTrackerGUIDragonWest
end

function DragonTracker:checkZone()
	local currentMapZoneIdx = GetCurrentMapZoneIndex()
	self.zoneInfo.onDragonZone = false
	
	if currentMapZoneIdx == 680 then -- Elsweyr
		self.zoneInfo.onDragonZone = true
	end
	
	if self.zoneInfo.lastMapZoneIdx ~= currentMapZoneIdx then
		self.zoneInfo.lastMapZoneIdx = currentMapZoneIdx
		self:initDragonStatus()
	end
	
	if self.zoneInfo.onDragonZone == true then
		self:enabledUpdateTime()
	else
		self:disableUpdateTiem()
		self:resetDragonStatus()
	end
	
	for worldEventInstanceId=1,3,1 do
		DragonTracker.dragonInfo[worldEventInstanceId].gui:SetHidden(not self.zoneInfo.onDragonZone)
	end
end

function DragonTracker:resetDragonStatus()
	for worldEventInstanceId=1,3,1 do
		self.dragonInfo[worldEventInstanceId].status     = DragonTracker.status.unknown
		self.dragonInfo[worldEventInstanceId].statusTime = 0
		self.dragonInfo[worldEventInstanceId].statusPrev = nil
	end
end

function DragonTracker:initDragonStatus()
	if self.zoneInfo.onDragonZone == false then
		return
	end

	local worldEventId = nil
	local unitTag = nil
	local unitPin = nil
	
	for worldEventInstanceId=1,3,1 do
		worldEventId = GetWorldEventId(worldEventInstanceId)
		
		if worldEventId == 0 then
			self.OnWEDeactivate(nil, worldEventInstanceId)
		else
			unitTag = GetWorldEventInstanceUnitTag(worldEventInstanceId, 1)
			unitPin = GetWorldEventInstanceUnitPinType(worldEventInstanceId, unitTag)
			
			self.OnWEUnitPin(nil, worldEventInstanceId, nil, nil, unitPin)
		end
		
		self.dragonInfo[worldEventInstanceId].statusTime = 0
	end
end

function DragonTracker.OnWEDeactivate(eventCode, worldEventInstanceId)
	if DragonTracker.zoneInfo.onDragonZone == false then
		return
	end

	-- d("Dragon Alert : Dragon on the " .. DragonTracker.dragonInfo[worldEventInstanceId].position .. " has been killed at " .. os.date("%H:%M:%S"))

	DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.killed)
	DragonTracker:updateGui(worldEventInstanceId)
end

function DragonTracker.OnWEUnitPin(eventCode, worldEventInstanceId, unitTag, oldPinType, newPinType)
	if DragonTracker.zoneInfo.onDragonZone == false then
		return
	end

	local txtStatus = ""

	if newPinType == MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY then
		DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.waiting)
	elseif newPinType == MAP_PIN_TYPE_DRAGON_IDLE_WEAK then
		DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.waiting)
	elseif newPinType == MAP_PIN_TYPE_DRAGON_COMBAT_HEALTHY then
		DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.fight)
	elseif newPinType == MAP_PIN_TYPE_DRAGON_COMBAT_WEAK then
		DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.weak)
	end

	-- d("Dragon Alert : Dragon on the " .. DragonTracker.dragonInfo[worldEventInstanceId].position .. " is now " .. txtStatus)

	DragonTracker:updateGui(worldEventInstanceId)
end

function DragonTracker:changeDragonStatus(worldEventInstanceId, newStatus)
	self.dragonInfo[worldEventInstanceId].status     = newStatus
	self.dragonInfo[worldEventInstanceId].statusTime = os.time()
end

function DragonTracker:updateGui(worldEventInstanceId)
	if worldEventInstanceId > 4 then
		return
	end
	
	local guiItem        = self.dragonInfo[worldEventInstanceId].gui
	local dragonPosition = self.dragonInfo[worldEventInstanceId].position
	local dragonStatus   = self.dragonInfo[worldEventInstanceId].status
	local dragonTime     = self.dragonInfo[worldEventInstanceId].statusTime
	local currentTime    = os.time()
	local textMessage    = ""
	
	if dragonStatus == self.status.killed then
		textMessage = "Killed"
	elseif dragonStatus == self.status.waiting then
		textMessage = "Waiting or flying"
	elseif dragonStatus == self.status.fight then
		textMessage = "In fight"
	elseif dragonStatus == self.status.weak then
		textMessage = "In fight (life < 50%)"
	else
		textMessage = "Unknown"
	end
	
	if dragonTime ~= 0 then
		local timeDiff       = currentTime - dragonTime
		local timeUnit       = "sec"
		
		if timeDiff > 60 then
			timeDiff = timeDiff / 60
			timeUnit = "min"
		end
		
		if timeDiff > 60 then
			timeDiff = timeDiff / 60
			timeUnit = "h"
		end
		
		textMessage = textMessage .. " since " .. math.floor(timeDiff) .. timeUnit
	end
	
	guiItem:SetText(dragonPosition .. " : " .. textMessage)
end

function DragonTracker.OnZoneChanged(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
	DragonTracker:checkZone()
end

function DragonTracker.OnGuiMoveStop()
	DragonTracker.savedVariables.left = DragonTrackerGUI:GetLeft()
	DragonTracker.savedVariables.top  = DragonTrackerGUI:GetTop()
end

function DragonTracker.OnGuiChanged(eventCode)
	-- do an action
end

function DragonTracker.updateTime()
	for worldEventInstanceId=1,3,1 do
		DragonTracker:updateGui(worldEventInstanceId)
	end
end
