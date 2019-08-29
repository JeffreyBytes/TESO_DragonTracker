DragonTracker = {}

DragonTracker.name = "DragonTracker"
DragonTracker.savedVariables = nil
	
DragonTracker.dragonInfo = {
	[1] = {
		position = "South",
		gui      = nil,
		status   = nil
	},
	[2] = {
		position = "North",
		gui      = nil,
		status   = nil
	},
	[3] = {
		position = "West ",
		gui      = nil,
		status   = nil
	}
}

DragonTracker.status = {
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
	EVENT_MANAGER:RegisterForEvent("DragonTracker", EVENT_WORLD_EVENT_DEACTIVATED, DragonTracker.OnWEDeactivate)
	EVENT_MANAGER:RegisterForEvent("DragonTracker", EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE, DragonTracker.OnWEUnitPin)
	EVENT_MANAGER:RegisterForEvent("DragonTracker", EVENT_ZONE_CHANGED, DragonTracker.OnZoneChanged)
	-- EVENT_MANAGER:RegisterForEvent("DragonTracker", EVENT_GAME_CAMERA_UI_MODE_CHANGED, DragonTracker:OnGuiChanged) -- Used to dump some data
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
	
	for worldEventInstanceId=1,3,1 do
		DragonTracker.dragonInfo[worldEventInstanceId].gui:SetHidden(not self.zoneInfo.onDragonZone)
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
		d(worldEventInstanceId .. " - worldEventId : " .. worldEventId)
		
		if worldEventId == 0 then
			self.OnWEDeactivate(nil, worldEventInstanceId)
		else
			unitTag = GetWorldEventInstanceUnitTag(worldEventInstanceId, 1)
			d(worldEventInstanceId .. " - unitTag : " .. unitTag)
			unitPin = GetWorldEventInstanceUnitPinType(worldEventInstanceId, unitTag)
			d(worldEventInstanceId .. " - unitPin : " .. unitPin)
			
			self.OnWEUnitPin(nil, worldEventInstanceId, nil, nil, unitPin)
		end
	end
end

function DragonTracker.OnWEDeactivate(eventCode, worldEventInstanceId)
	if DragonTracker.zoneInfo.onDragonZone == false then
		return
	end

	-- d("Dragon Alert : Dragon on the " .. DragonTracker.dragonInfo[worldEventInstanceId].position .. " has been killed at " .. os.date("%H:%M:%S"))

	local fromEvent = true
	if eventCode == nil then
		fromEvent = false
	end
	
	DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.killed)
	DragonTracker:updateGui(worldEventInstanceId, "Killed", fromEvent)
end

function DragonTracker.OnWEUnitPin(eventCode, worldEventInstanceId, unitTag, oldPinType, newPinType)
	if DragonTracker.zoneInfo.onDragonZone == false then
		return
	end

	local txtStatus = ""

	if newPinType == MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY then
		DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.waiting)
		txtStatus = "Waiting or flying"
	elseif newPinType == MAP_PIN_TYPE_DRAGON_IDLE_WEAK then
		DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.waiting)
		txtStatus = "Waiting or flying (life < 50%)"
	elseif newPinType == MAP_PIN_TYPE_DRAGON_COMBAT_HEALTHY then
		DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.fight)
		txtStatus = "In fight"
	elseif newPinType == MAP_PIN_TYPE_DRAGON_COMBAT_WEAK then
		DragonTracker:changeDragonStatus(worldEventInstanceId, DragonTracker.status.weak)
		txtStatus = "In fight (life < 50%)"
	end

	-- d("Dragon Alert : Dragon on the " .. DragonTracker.dragonInfo[worldEventInstanceId].position .. " is now " .. txtStatus)

	local fromEvent = true
	if eventCode == nil then
		fromEvent = false
	end
	
	DragonTracker:updateGui(worldEventInstanceId, txtStatus, fromEvent)
end

function DragonTracker:changeDragonStatus(worldEventInstanceId, newStatus)
	self.dragonInfo[worldEventInstanceId].status = newStatus
end

function DragonTracker:updateGui(worldEventInstanceId, textStatus, addTime)
	if worldEventInstanceId > 4 then
		return
	end
	
	local guiItem        = self.dragonInfo[worldEventInstanceId].gui
	local dragonPosition = self.dragonInfo[worldEventInstanceId].position
	local currentTime    = os.date("%H:%M:%S")
	
	if addTime == false then
		currentTime = '--:--:--'
	end

 	guiItem:SetText("[" .. currentTime .. "] " .. dragonPosition .. " : " .. textStatus)
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

EVENT_MANAGER:RegisterForEvent(DragonTracker.name, EVENT_ADD_ON_LOADED, DragonTracker.OnAddOnLoaded)
