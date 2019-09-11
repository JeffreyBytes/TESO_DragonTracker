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

* Definition.lua
* DragonStatus.lua
* Events.lua
* GUI.lua
* Timer.lua
* Zone.lua
* Initialise.lua

### Definitiion.lua

Declare all variables and tables used by the addon.

Declared variables :

* `DragonTracker` : The global table for all addon's properties and methods.
* `DragonTracker.name` : The addon name
* `DragonTracker.savedVariables` : The `ZO_SavedVars` table which contains saved variable for this addon.
* `DragonTracker.ready` : If the addon is ready to be used
* `DragonTracker.updateTimeEnabled` : If the timer which displays "since time" if enabled
* `DragonTracker.dragonInfo` : All info about each dragon
* `DragonTracker.status` : All status
* `DragonTracker.zoneInfo` : Info about the current zone

### DragonStatus.lua

Contain all functions used to check and define the current status of a dragon, or all dragons.

* `DragonTracker:resetDragonStatus` : Reset all info about all dragons.
* `DragonTracker:initDragonStatus` : Initialise info about all dragons.
* `DragonTracker:changeDragonStatus` : To change the dragon's status.
* `DragonTracker:execOnDragonStatus` : Execute a callback function for all dragons in the zone
* `DragonTracker:checkDragonStatus` : Check the status of all dragons to know if the status is correct or not.
* `DragonTracker:obtainDragonStatus` : Convert from `MAP_PIN_TYPE_DRAGON_*` constant value to `DragonTracker.status` value

### Events.lua

Contain all functions called when a listened event is triggered.

* `DragonTracker.onLoaded` : Called when the addon is loaded
* `DragonTracker.onLoadScreen` : Called after each load screen
* `DragonTracker.onWEDeactivate` : Called when a World Event is finished (aka dragon killed).
* `DragonTracker.onWEUnitPin` : Called when a World Event has this map pin changed (aka new dragon or dragon in fight).
* `DragonTracker.onGuiMoveStop` : Called when GUI items have been moved by the user
* `DragonTracker.onGuiChanged` : Called when something changes in the GUI (like open inventory).  
Used to debug only, the line to add the listener on the event is commented.

### GUI.lua

Contains all functions to modify info displayed on the GUI.

* `DragonTracker:guiRestorePosition` : Restore the GUI's position from savedVariables
* `DragonTracker:guiDefineFragment` : Define GUI has a fragment linked to scenes.  
-- With that, the GUI is hidden when we open a menu (like inventory or map)
* `DragonTracker:initDragonGuiItems` : Define GUI item for each dragons in `DragonTracker.dragonInfo`
* `DragonTracker:guiShowHide` : Hide or show all DragonTrackers GUI items.
* `DragonTracker:updateGui` : Update the message displayed in GUI for a specific dragon.

## Initialise.lua

Contain the function called to initialise the addon, and registered for all events we want to listen.

## Timer.lua

Contain all function to manage the timer used to display "since..."

* `DragonTracker:enabledUpdateTime` : Enable timer used to know since how many time dragon has its status
* `DragonTracker:disableUpdateTime` : Disable timer used to know since how many time dragon has its status
* `DragonTracker.updateTime` : Callback function on timer. Called each 1sec in dragons zone. Update the GUI for each dragon.
* `DragonTracker:changeTimerStatus` : Call the method to enable or disable timer according to newStatus value

## Zone.lua

Contain all function to know if the current zone has dragons or not

* `DragonTracker:updateZoneInfo` : Update info about the current zone.
* `DragonTracker:checkZoneWithDragons` : Check if it's a zone with dragons.
