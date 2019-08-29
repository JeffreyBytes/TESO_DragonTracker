DragonTracker = {}

DragonTracker.name = "DragonTracker"
DragonTracker.version = "1.0.0"
DragonTracker.initialised = false

function DragonTracker.Initialise(eventCode, addOnName)

	-- Initialize self only.
	if (DragonTracker.name ~= addOnName) then return end

    -- Event registration.
	EVENT_MANAGER:RegisterForEvent("DragonTracker", EVENT_WORLD_EVENT_DEACTIVATED, DragonTracker.OnWEDeactivate)
	EVENT_MANAGER:RegisterForEvent("DragonTracker", EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE, DragonTracker.OnWEUnitPin)
	EVENT_MANAGER:RegisterForEvent("DragonTracker", EVENT_ZONE_CHANGED, DragonTracker.OnZoneChanged)
	-- EVENT_MANAGER:RegisterForEvent("DragonTracker", EVENT_GAME_CAMERA_UI_MODE_CHANGED, DragonTracker.OnGuiChanged) -- Used to dump some data
	
	-- Saved variable
	DragonTracker.savedVariables = ZO_SavedVars:NewAccountWide("DragonTrackerSavedVariables", 1, nil, {})
	DragonTracker.GuiRestorePosition()

	-- Display/hide gui
	local fragment = ZO_SimpleSceneFragment:New(DragonTrackerGUI)
	SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
	SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
	
	DragonTracker.position = {[1]="South", [2]="North", [3]="West "}
	DragonTracker.guiItems = {[1]=DragonTrackerGUIDragonSouth, [2]=DragonTrackerGUIDragonNorth, [3]=DragonTrackerGUIDragonWest}
	
	DragonTracker.onDragonZone   = false
	DragonTracker.lastMapZoneIdx = nil
	DragonTracker.checkZone()

	DragonTracker.initialised = true   
	-- d("DragonTracker Debug: Ran Through Init") 
end

EVENT_MANAGER:RegisterForEvent("DragonTracker", EVENT_ADD_ON_LOADED, DragonTracker.Initialise)

function DragonTracker.checkZone()
	local currentMapZoneIdx = GetCurrentMapZoneIndex()
	DragonTracker.onDragonZone = false
	
	if currentMapZoneIdx == 680 then -- Elsweyr
		DragonTracker.onDragonZone = true
	end
	
	if DragonTracker.lastMapZoneIdx ~= currentMapZoneIdx then
		DragonTracker.lastMapZoneIdx = currentMapZoneIdx
		DragonTracker.initDragonStatus()
	end
	
	for worldEventInstanceId=1,3,1 do
		DragonTracker.guiItems[worldEventInstanceId]:SetHidden(not DragonTracker.onDragonZone)
	end
end

function DragonTracker.initDragonStatus()
	if DragonTracker.onDragonZone == false then
		return
	end

	local worldEventId = nil
	local unitTag = nil
	local unitPin = nil
	
	for worldEventInstanceId=1,3,1 do
		worldEventId = GetWorldEventId(worldEventInstanceId)
		d(worldEventInstanceId .. " - worldEventId : " .. worldEventId)
		
		if worldEventId == 0 then
			DragonTracker.OnWEDeactivate(nil, worldEventInstanceId)
		else
			unitTag = GetWorldEventInstanceUnitTag(worldEventInstanceId, 1)
			d(worldEventInstanceId .. " - unitTag : " .. unitTag)
			unitPin = GetWorldEventInstanceUnitPinType(worldEventInstanceId, unitTag)
			d(worldEventInstanceId .. " - unitPin : " .. unitPin)
			
			DragonTracker.OnWEUnitPin(nil, worldEventInstanceId, nil, nil, unitPin)
		end
	end
end

function DragonTracker.OnWEDeactivate(eventCode, worldEventInstanceId)
	if DragonTracker.onDragonZone == false then
		return
	end

	-- d("Dragon Alert : Dragon on the " .. DragonTracker.position[worldEventInstanceId] .. " has been killed at " .. os.date("%H:%M:%S"))

	local fromEvent = true
	if eventCode == nil then
		fromEvent = false
	end
	
	updateGui(worldEventInstanceId, "Killed", fromEvent)
end

function DragonTracker.OnWEUnitPin(eventCode, worldEventInstanceId, unitTag, oldPinType, newPinType)
	if DragonTracker.onDragonZone == false then
		return
	end

	local txtStatus = ""

	if newPinType == MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY then
		txtStatus = "Waiting or flying"
	elseif newPinType == MAP_PIN_TYPE_DRAGON_IDLE_WEAK then
		txtStatus = "Waiting or flying (life < 50%)"
	elseif newPinType == MAP_PIN_TYPE_DRAGON_COMBAT_HEALTHY then
		txtStatus = "In fight"
	elseif newPinType == MAP_PIN_TYPE_DRAGON_COMBAT_WEAK then
		txtStatus = "In fight (life < 50%)"
	end

	-- d("Dragon Alert : Dragon on the " .. DragonTracker.position[worldEventInstanceId] .. " is now " .. txtStatus)

	local fromEvent = true
	if eventCode == nil then
		fromEvent = false
	end
	
	updateGui(worldEventInstanceId, txtStatus, fromEvent)
end

function updateGui(worldEventInstanceId, textStatus, addTime)
	if worldEventInstanceId > 4 then
		return
	end
	
	local guiItem        = DragonTracker.guiItems[worldEventInstanceId]
	local dragonPosition = DragonTracker.position[worldEventInstanceId]
	local currentTime    = os.date("%H:%M:%S")
	
	if addTime == false then
		currentTime = '--:--:--'
	end

 	guiItem:SetText("[" .. currentTime .. "] " .. dragonPosition .. " : " .. textStatus)
end

function DragonTracker.OnZoneChanged(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
	DragonTracker.checkZone()
end

function DragonTracker.OnGuiMoveStop()
	DragonTracker.savedVariables.left = DragonTrackerGUI:GetLeft()
	DragonTracker.savedVariables.top  = DragonTrackerGUI:GetTop()
end

function DragonTracker.GuiRestorePosition()
	local left = DragonTracker.savedVariables.left
	local top  = DragonTracker.savedVariables.top

	DragonTrackerGUI:ClearAnchors()
	DragonTrackerGUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function DragonTracker.OnGuiChanged(eventCode)
	-- do an action
end
