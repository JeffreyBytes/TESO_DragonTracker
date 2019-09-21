# Dragon Tracker

It's an addon for [The Elder Scroll Online](https://www.elderscrollsonline.com) which track Dragons status in Elsweyr.

I was inspired by the addon [World Event Alert (aka Dragon Alert)](https://esoui.com/downloads/info2335-WorldEventAlertakaDragonAlert.html) created by [Enodoc](https://www.esoui.com/downloads/author-12447.html). Thanks to him.  
And, you can install the addon World Event Alert in addition if you want because I not display an alert when a dragon's status change.

## Dependencies

Only the game. No addon or library is needed.

## Install it

Into the addon folder (`Elder Scrolls Online\live\AddOns` in your document folder), you need to have a folder `DragonTracker` and copy all files into it.

So you can :

* Clone the repository in the AddOns folder and name it `DragonTracker`.
* Or download the zip file of the last release in github, extract it in the AddOns folder, and rename `TESO_DragonTracker-{release}` to `DragonTracker`.

## In game

Go to Elsweyr, and you will see something appear with the status of each dragon.  
You can move it where you want.  
If you are not in Elsweyr zone (also in Elsweyr public dungeons), info will be hidden.

![Screen 1](https://projects.bulton.fr/teso/DragonTracker/screen1.jpg)
![Screen 2](https://projects.bulton.fr/teso/DragonTracker/screen2.jpg)

![Map with dragons](https://projects.bulton.fr/teso/DragonTracker/map.jpg)

## API usage

A dragon is a "World Event" in the API, so we use some event on WorldEvents.

Events triggered :

* `EVENT_ADD_ON_LOADED` : When the addon is loaded
* `EVENT_PLAYER_ACTIVATED` : When a load screen displayed
* `EVENT_WORLD_EVENT_DEACTIVATED` : When a WorldEvent finish (aka dragon killed)
* `EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE` : When the worldEvent's map pin change (aka new dragon, of change status to "in fight" or "waiting")
* `EVENT_GAME_CAMERA_UI_MODE_CHANGED` : A change in camera mode (free mouse, open inventory, etc). **In released versions, this event is not triggered.** I use it to dump some data when I dev or debug.

Note : Dark anchor, world bosses, etc are not trigger WorldEvent events. So I cannot catch events on them.

## Status

There are 5 status displayed :

* Waiting or flying : Dragon just appears, and flying, or it's on the ground and waiting for the fight.
* In fight : Currently in fight against players, with his life > 50%.
* In fight (life < 50%) : Currently in fight against players, with his life < 50%.
* Killed : Dead.
* Unknown : Only to catch not managed cases, normally you should never see this status.

## Timer

When the interface is displayed, a timer is created. This timer call a function which updates the display info "since ..." every 1 second. If the interface is not loaded, the timer is destroyed.

The text "since..." cannot be displayed if you just arrived in the zone; the addon doesn't know since how many time a dragon has its status. The "since..." will be displayed only if you are in the zone when the status change.

To know if the timer is created, you can use the variable `DragonTracker.updateTimeEnabled`; `true` if created, `false` if not exist.

## About lua files

There are loaded in order :

* Initialise.lua
* Dragon.lua
* DragonList.lua
* DragonStatus.lua
* Events.lua
* GUI.lua
* GUIItem.lua
* GUITimer.lua
* Zone.lua
* Run.lua

### Initialise.lua

Declare all variables and the initialise function.

Declared variables :

* `DragonTracker` : The global table for all addon's properties and methods.
* `DragonTracker.name` : The addon name
* `DragonTracker.savedVariables` : The `ZO_SavedVars` table which contains saved variable for this addon.
* `DragonTracker.ready` : If the addon is ready to be used

### Dragon.lua

Table : `DragonTracker.Dragon`

Contain all info about a dragon. It's a POO like with one instance of Dragon by dragon on the map.

Properties :

* `dragonIdx` : Index in the DragonList
* `WEInstanceId` : The WorldEventInstanceId
* `WEId` : The WorldEventId, obtained by function `GetWorldEventId`
* `unit` : Info about unit
  * `tag` : The unit tag
  * `pin` : The unit pin
* `position` : Dragon position (not real-time)
  * `x`
  * `y`
  * `z`
* `GUI` : Info about GUI dedicated for the dragon
  * `item` : The `GUIItem` instance
  * `title` : The title to use for the dragon (like "North")
* `status` : Info about dragon's status
  * `previous` : The previous status
  * `current` : The current status
  * `time` : Time when current status has been defined (0 to unknown)

Methods :

* `DragonTracker.Dragon:new` : To instanciate a new Dragon instance
* `DragonTracker.Dragon:updateWEId` : Update the property `WEId`
* `DragonTracker.Dragon:updateUnit` : Update properties `unit.tag` and `unit.pin`
* `DragonTracker.Dragon:changeStatus` : Change the dragon's current status
* `DragonTracker.Dragon:resetWithStatus` : Reset dragon's status (like just instancied) with a status.

### DragonList.lua

Table : `DragonTracker.DragonList`

Contain all instancied Dragon instance.

Properties :

* `list` : List of Dragon instance
* `nb` : Number of item in `list`
* `WEInstanceIdToListIdx` : Table with WEInstanceId in key, and index in `list` for value.

Methods :

* `reset` : Reset the list
* `add` : Add a new dragon to the list
* `execOnAll` : Execute a callback for all dragon
* `obtainForWEInstanceId` : Obtain the dragon instance for a WEInstanceId
* `update` : To update the list : remove all dragon or create all dragon compared to Zone info.
* `removeAll` : Remove all dragon and reset GUI items
* `createAll` : Create all dragon for the zone

### DragonStatus.lua

Table : `DragonTracker.DragonStatus`

Contain all functions used to check and define the current status of a dragon, or all dragons.

Property :

* `list` : List of all status which can be defined
  * `unknown`
  * `killed`
  * `waiting`
  * `fight`
  * `weak`
* `mapPinList` : All map pin available and the corresponding status
  * `MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY` : `list.waiting`
  * `MAP_PIN_TYPE_DRAGON_IDLE_WEAK` : `list.waiting`
  * `MAP_PIN_TYPE_DRAGON_COMBAT_HEALTHY` : `list.fight`
  * `MAP_PIN_TYPE_DRAGON_COMBAT_WEAK` : `list.weak`

Methods :

* `DragonTracker.DragonStatus:initForDragon` : Initialise status for a dragon
* `DragonTracker.DragonStatus:checkAllDragon` : Check status for all dragon in DragonList
* `DragonTracker.DragonStatus:checkForDragon` : Check the status of a dragon to know if the status is correct or not.
* `DragonTracker.DragonStatus:convertMapPin` : Convert from `MAP_PIN_TYPE_DRAGON_*` constant value to `DragonTracker.DragonStatus.list` value

### Events.lua

Table : `DragonTracker.Events`

Contain all functions called when a listened event is triggered.

* `DragonTracker.Events.onLoaded` : Called when the addon is loaded
* `DragonTracker.Events.onLoadScreen` : Called after each load screen
* `DragonTracker.Events.onWEDeactivate` : Called when a World Event is finished (aka dragon killed).
* `DragonTracker.Events.onWEUnitPin` : Called when a World Event has this map pin changed (aka new dragon or dragon in fight).
* `DragonTracker.Events.onGuiMoveStop` : Called when GUI items have been moved by the user
* `DragonTracker.Events.onGuiChanged` : Called when something changes in the GUI (like open inventory).  
Used to debug only, the line to add the listener on the event is commented.

### GUI.lua

Table : `DragonTracker.GUI`

Contains all functions to define the GUI container and save GUIItems instances.

Properties :

* `container` : The TopLevelControl in interface
* `items` : List of GUIItems associate to a dragon
* `nbItems` : Number of GUIItems in `items`.

Methods :

* `DragonTracker.GUI:init` : Initialise the GUI
* `DragonTracker.GUI:obtainContainer` : Obtain the TopLevelControl's table
* `DragonTracker.GUI:guiRestorePosition` : Restore the GUI's position from savedVariables
* `DragonTracker.GUI:savePosition` : Save the GUI's position from savedVariables
* `DragonTracker.GUI:defineFragment` : Define GUI has a fragment linked to scenes.  
-- With that, the GUI is hidden when we open a menu (like inventory or map)
* `DragonTracker.GUI:display` : Hide or show all GUIItems.
* `DragonTracker.GUI:createItem` : To create a GUIItem instance for a Dragon
* `DragonTracker.GUI:resetItem` : To reset the list of GUIItems

### GUIItems.lua

Table : `DragonTracker.GUIItem`

Contain all info about a LabelControl in the gui. It's a POO like with one instance of GUIItem by LabelControl.
Each GUIItem is linked to a Dragon instance. Else, the text value is empty and label is hidden.

Properties :

* `dragon` : The Dragon instance linked to the GUIItem
* `labelctr` : The LabelControl in interface
* `title` : The prefix to use for the dragon (like "North")
* `value` : The text displayed

Methods :

* `DragonTracker.GUIItem:new` : To instanciate a new GUIItem instance
* `DragonTracker.GUIItem:clear` : Define the text value as empty string
* `DragonTracker.GUIItem:display` : Define the value of SetHidden to show or hide the label
* `DragonTracker.GUIItem:show` : Show the label
* `DragonTracker.GUIItem:hide` : Hide the label
* `DragonTracker.GUIItem:update` : Update the text value
* `DragonTracker.GUIItem:obtainStatusText` : Obtain the status to display from a dragon status
* `DragonTracker.GUIItem:obtainTimerText` : Obtain the timer text to display for a dragon

### GUITimer.lua

Table : `DragonTracker.GUITimer`

Contain all function to manage the timer used to display "since..."

Properties :

* `name` : The timer's name
* `enabled` : If the timer is enabled or not

Methods :

* `DragonTracker.GUITimer:enable` : Enable timer used to know since how many time dragon has its status
* `DragonTracker.GUITimer:disable` : Disable timer used to know since how many time dragon has its status
* `DragonTracker.GUITimer.update` : Callback function on timer. Called each 1sec in dragons zone. Update the GUI for each dragon.
* `DragonTracker.GUITimer:changeStatus` : Call the method to enable or disable timer according to newStatus value

### Zone.lua

Table : `DragonTracker.Zone`

Contain all function to know if the current zone has dragons or not

Properties :

* `onDragonZone` : If player is on a zone with dragon (zone = Elsweyr)
* `onDragonMap` : If player is on a map with dragon (map = delve, dungeon, none, ...)
* `lastMapZoneIdx` : The previous MapZoneIndex
* `changedZone` : If the player has changed zone
* `info` : Info about the current zone (ref to list value corresponding to the zone)
* `nbZone` : Number of zone in the list
* `list` : List of info about zones with dragons.
  Each value is a table with keys :
  * `mapZoneIdx` : The zone's MapZoneIndex
  * `nbDragons` : Number of dragon in the zone
  * `dragons` : Info about each dragon
    * `title` : Title to use for each dragon
    * `WEInstanceId` : The WorldEventInstanceId for each dragon

Methods :

* `DragonTracker:updateInfo` : Update info about the current zone.
* `DragonTracker:checkDragonZone` : Check if it's a zone with dragons.

### Run.lua

Define a listener to all used events.
