# Dragon Tracker

It's an addon for [The Elder Scroll Online](https://www.elderscrollsonline.com) which track Dragons status in Elsweyr.

I was inspired by the addon [World Event Alert (aka Dragon Alert)](https://esoui.com/downloads/info2335-WorldEventAlertakaDragonAlert.html) created by [Enodoc](https://www.esoui.com/downloads/author-12447.html). Thanks to him.  
And, you can install the addon World Event Alert in addition if you want because I not display an alert when a dragon's status change.

## Dependencies

One library : [`LibWorldEvents`](https://www.esoui.com/downloads/info2473-LibWorldEvents.html).

## Install it

Into the addon folder (`Elder Scrolls Online\live\AddOns` in your document folder), you need to have a folder `WorldEventsTracker` and copy all files into it.

So you can :

* Clone the repository in the AddOns folder and name it `WorldEventsTracker`.
* Or download the zip file started by `esoui-` of the last release in github, and extract it in the AddOns folder.

## In game

Go to Elsweyr, and you will see something appear with the status of each dragon.  
You can move it where you want.  
If you are not in Elsweyr zone (also in Elsweyr public dungeons), info will be hidden.

![Screen 1](https://projects.bulton.fr/teso/WorldEventsTracker/screen1.jpg)
![Screen 2](https://projects.bulton.fr/teso/WorldEventsTracker/screen2.jpg)

![Map with dragons](https://projects.bulton.fr/teso/WorldEventsTracker/map.jpg)

## API usage

A dragon is a "World Event" in the API, so we use some event on WorldEvents.

Game Events triggered :

* `EVENT_ADD_ON_LOADED` : When the addon is loaded
* `EVENT_PLAYER_ACTIVATED` : When a load screen displayed
* `EVENT_GAME_CAMERA_UI_MODE_CHANGED` : A change in camera mode (free mouse, open inventory, etc). **In released versions, this event is not triggered.** I use it to dump some data when I dev or debug.

`LibWorldEvents` events triggered :

* `LibWorldEvents.Events.callbackEvents.dragon.new` : When a new dragon instance is created.
* `LibWorldEvents.Events.callbackEvents.dragonList.removeAll` : When all dragon are removed from `DragonList`.

Note : Dark anchor, world bosses, etc are not trigger WorldEvent events. So I cannot catch events on them.

## Timer

When the interface is displayed, a timer is created. This timer call a function which updates the display info "since ..." every 1 second. If the interface is not loaded, the timer is destroyed.

The text "since..." cannot be displayed if you just arrived in the zone; the addon doesn't know since how many time a dragon has its status. The "since..." will be displayed only if you are in the zone when the status change.

To know if the timer is created, you can use the variable `WorldEventsTracker.updateTimeEnabled`; `true` if created, `false` if not exist.

## About lua files

There are loaded in order :

* Initialise.lua
* Events.lua
* GUI.lua
* GUIItem.lua
* GUITimer.lua
* Run.lua

### Initialise.lua

Declare all variables and the initialise function.

Declared variables :

* `WorldEventsTracker` : The global table for all addon's properties and methods.
* `WorldEventsTracker.name` : The addon name
* `WorldEventsTracker.savedVariables` : The `ZO_SavedVars` table which contains saved variable for this addon.
* `WorldEventsTracker.ready` : If the addon is ready to be used
* `WorldEventsTracker.LAM` : The library LibAddonMenu2

Methods :

* `WorldEventsTracker:Initialise` : Module initialiser  
Intiialise savedVariables, settings panel and GUI
* `WorldEventsTracker:initSavedVars` : Initialise all savedVariable's default values

### Events.lua

Table : `WorldEventsTracker.Events`

Contain all functions called when a listened event is triggered.

* `WorldEventsTracker.Events.onLoaded` : Called when the addon is loaded
* `WorldEventsTracker.Events.onLoadScreen` : Called after each load screen
* `WorldEventsTracker.Events.onNewDragon` : Called when a new dragon instance is created
* `WorldEventsTracker.Events.onCreateAllDragon` : Called when all dragon are created from DragonList
* `WorldEventsTracker.Events.onRemoveAllFromDragonList` : Called when all dragon is removed from DragonList
* `WorldEventsTracker.Events.onDragonChangeType` : Called when a dragon's type change
* `WorldEventsTracker.Events.onDragonKilled` : Called when a dragon is killed
* `WorldEventsTracker.Events.onGuiMoveStop` : Called when GUI items have been moved by the user
* `WorldEventsTracker.Events.onGuiChanged` : Called when something changes in the GUI (like open inventory).  
Used to debug only, the line to add the listener on the event is commented.
* `WorldEventsTracker.Events.changeLabelType` : Called when player use slash command /WorldEventsTrackerlabeltype.  
Used to change label name to use between cardinal point and location name.
* `WorldEventsTracker.Events.keybindingsToggle` : Called when player use the keybind to show/hide the GUI

### GUI.lua

Table : `WorldEventsTracker.GUI`

Contains all functions to define the GUI container and save GUIItems instances.

Properties :

* `container` : The TopLevelControl in interface
* `items` : List of GUIItems associate to a dragon
* `savedVars` : A direct access to `WorldEventsTracker.savedVariables.gui` which contain all saved variables used by the GUI.
* `fragment` : The fragment used to define when the GUI is displayed
* `toDisplay` : To know if the GUI should be displayed (user config only)  
It's not the current GUI display status because the user can accept to display it but not be in a dragon's zone (so the GUI will be hidden) !

Methods :

* `WorldEventsTracker.GUI:init` : Initialise the GUI
* `WorldEventsTracker.GUI:obtainContainer` : Obtain the TopLevelControl's table
* `WorldEventsTracker.GUI:restorePosition` : Restore the GUI's position from savedVariables
* `WorldEventsTracker.GUI:savePosition` : Save the GUI's position from savedVariables
* `WorldEventsTracker.GUI:restoreLock` : Restore the GUI locked status
* `WorldEventsTracker.GUI:isLocked` : Return the status if the GUI should be locked or not
* `WorldEventsTracker.GUI:defineLocked` : Define if the GUI should be locked or not, and update the GUI to lock it (or not)
* `WorldEventsTracker.GUI:defineFragment` : Define GUI has a fragment linked to scenes.  
With that, the GUI is hidden when we open a menu (like inventory or map)
* `WorldEventsTracker.GUI:isDisplayWithWMap` : Return the status if the GUI should be display in the world map interface
* `WorldEventsTracker.GUI:defineDisplayWithWMap` : Define the status which define if the GUI is displayed in the world map interface or not, and update the fragment to apply the new status.
* `WorldEventsTracker.GUI:display` : Hide or show all GUIItems.
* `WorldEventsTracker.GUI:toggleToDisplay` : Switch the status of toDisplay to be the invert of the previous status, and call self:display() to update the GUI
* `WorldEventsTracker.GUI:createItem` : To create a GUIItem instance for a Dragon
* `WorldEventsTracker.GUI:resetAllItems` : To reset the list of GUIItems
* `WorldEventsTracker.GUI:labelUseName` : Define the label type to use on the location name.
* `WorldEventsTracker.GUI:labelUseCardinalPoint` : Define the label type to use on  the cardinal point.
* `WorldEventsTracker.GUI:obtainLabelType` : Return the current labelFormat used
* `WorldEventsTracker.GUI:defineLabelType` : Define the label to use and call the method to move the value controler relative to the max width of labels

### GUIItems.lua

Table : `WorldEventsTracker.GUIItem`

Contain all info about a LabelControl in the gui. It's a POO like with one instance of GUIItem by LabelControl.
Each GUIItem is linked to a Dragon instance. Else, the text value is empty and label is hidden.

Properties :

* `dragon` : The Dragon instance linked to the GUIItem
* `colorctr` : The Color square in the interface
* `labelctr` : The label control in the interface used to display location
* `valuectr` : The Label control in the interface used to display the status and the timer
* `title` : The prefix to use for the dragon (like "North")
* `value` : The text displayed

Methods :

* `WorldEventsTracker.GUIItem:new` : To instanciate a new GUIItem instance
* `WorldEventsTracker.GUIItem:defineTooltips` : Define all tooltip 
* `WorldEventsTracker.GUIItem:obtainTypeTooltipText` : Return the text to use in color tooltip
* `WorldEventsTracker.GUIItem:changeColor` : To change the color in the dragon color box 
* `WorldEventsTracker.GUIItem:changeTitleType` : Change the title type to use and update label text.
* `WorldEventsTracker.GUIItem:moveValueCtr` : Move the value controler relative to the label width.
* `WorldEventsTracker.GUIItem:clear` : Define the text value as empty string
* `WorldEventsTracker.GUIItem:display` : Define the value of SetHidden to show or hide the label
* `WorldEventsTracker.GUIItem:show` : Show the label
* `WorldEventsTracker.GUIItem:hide` : Hide the label
* `WorldEventsTracker.GUIItem:update` : Update the text value
* `WorldEventsTracker.GUIItem:obtainSinceValue` : Obtain the text to display with a "[status] since..."
* `WorldEventsTracker.GUIItem:obtainRepopInValue` : Obtain the text to display with a "repop in..."
* `WorldEventsTracker.GUIItem:obtainStatusText` : Obtain the status to display from a dragon status
* `WorldEventsTracker.GUIItem:obtainSinceTimerInfo` : Obtain the timer text to display when message is "[status] since..." (so count from 0)
* `WorldEventsTracker.GUIItem:obtainInTimerInfo` : Obtain the timer text to display when message is "repop in..." (so count to 0)
* `WorldEventsTracker.GUIItem:formatTime` : Format the time to have it for second, minute, or hour

### GUITimer.lua

Table : `WorldEventsTracker.GUITimer`  
Extends : `LibWorldEvents.Timer`

Contain all function to manage the timer used to display "since..."

Methods :

* `WorldEventsTracker.GUITimer.update` : Callback function on timer. Called each 1sec in dragons zone. Update the GUI for each dragon.

### Settings.lua

Table : `WorldEventsTracker.Settings`

Contain all function used to build the settings panel

Properties :

* `panelName` : The name of the settings panel

Methods :

* `WorldEventsTracker.Settings:init` : Initialise the settings panel
* `WorldEventsTracker.Settings:build` : Build the settings panel
* `WorldEventsTracker.Settings:buildGUILocked` : Build the "GUI Locked" part of the panel
* `WorldEventsTracker.Settings:buildDisplayedWithWorldMap` : Build the "Displayed with the World Map" part of the panel
* `WorldEventsTracker.Settings:buildPositionType` : Build the "Position type" part of the panel

### Run.lua

Define a listener to all used events.
