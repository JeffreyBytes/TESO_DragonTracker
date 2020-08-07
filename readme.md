# Dragon Tracker

It's an addon for [The Elder Scroll Online](https://www.elderscrollsonline.com) which track Dragons status in Elsweyr.

I was inspired by the addon [World Event Alert (aka Dragon Alert)](https://esoui.com/downloads/info2335-WorldEventAlertakaDragonAlert.html) created by [Enodoc](https://www.esoui.com/downloads/author-12447.html). Thanks to him.  
And, you can install the addon World Event Alert in addition if you want because I not display an alert when a dragon's status change.

## Dependencies

One library : [`LibDragonWorldEvent`](https://www.esoui.com/downloads/info2473-LibDragonWorldEvent.html).

## Install it

Into the addon folder (`Elder Scrolls Online\live\AddOns` in your document folder), you need to have a folder `DragonTracker` and copy all files into it.

So you can :

* Clone the repository in the AddOns folder and name it `DragonTracker`.
* Or download the zip file started by `esoui-` of the last release in github, and extract it in the AddOns folder.

## In game

Go to Elsweyr, and you will see something appear with the status of each dragon.  
You can move it where you want.  
If you are not in Elsweyr zone (also in Elsweyr public dungeons), info will be hidden.

![Screen 1](https://projects.bulton.fr/teso/DragonTracker/screen1.jpg)
![Screen 2](https://projects.bulton.fr/teso/DragonTracker/screen2.jpg)

![Map with dragons](https://projects.bulton.fr/teso/DragonTracker/map.jpg)

## API usage

A dragon is a "World Event" in the API, so we use some event on WorldEvents.

Game Events triggered :

* `EVENT_ADD_ON_LOADED` : When the addon is loaded
* `EVENT_PLAYER_ACTIVATED` : When a load screen displayed
* `EVENT_GAME_CAMERA_UI_MODE_CHANGED` : A change in camera mode (free mouse, open inventory, etc). **In released versions, this event is not triggered.** I use it to dump some data when I dev or debug.

`LibDragonWorldEvent` events triggered :

* `LibDragonWorldEvent.Events.callbackEvents.dragon.new` : When a new dragon instance is created.
* `LibDragonWorldEvent.Events.callbackEvents.dragonList.removeAll` : When all dragon are removed from `DragonList`.

Note : Dark anchor, world bosses, etc are not trigger WorldEvent events. So I cannot catch events on them.

## Timer

When the interface is displayed, a timer is created. This timer call a function which updates the display info "since ..." every 1 second. If the interface is not loaded, the timer is destroyed.

The text "since..." cannot be displayed if you just arrived in the zone; the addon doesn't know since how many time a dragon has its status. The "since..." will be displayed only if you are in the zone when the status change.

To know if the timer is created, you can use the variable `DragonTracker.updateTimeEnabled`; `true` if created, `false` if not exist.

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

* `DragonTracker` : The global table for all addon's properties and methods.
* `DragonTracker.name` : The addon name
* `DragonTracker.savedVariables` : The `ZO_SavedVars` table which contains saved variable for this addon.
* `DragonTracker.ready` : If the addon is ready to be used
* `DragonTracker.LAM` : The library LibAddonMenu2

Methods :

* `DragonTracker:Initialise` : Module initialiser  
Intiialise savedVariables, settings panel and GUI
* `DragonTracker:initSavedVars` : Initialise all savedVariable's default values

### Events.lua

Table : `DragonTracker.Events`

Contain all functions called when a listened event is triggered.

* `DragonTracker.Events.onLoaded` : Called when the addon is loaded
* `DragonTracker.Events.onLoadScreen` : Called after each load screen
* `DragonTracker.Events.onNewDragon` : Called when a new dragon instance is created
* `DragonTracker.Events.onCreateAllDragon` : Called when all dragon are created from DragonList
* `DragonTracker.Events.onRemoveAllFromDragonList` : Called when all dragon is removed from DragonList
* `DragonTracker.Events.onDragonChangeType` : Called when a dragon's type change
* `DragonTracker.Events.onDragonKilled` : Called when a dragon is killed
* `DragonTracker.Events.onGuiMoveStop` : Called when GUI items have been moved by the user
* `DragonTracker.Events.onGuiChanged` : Called when something changes in the GUI (like open inventory).  
Used to debug only, the line to add the listener on the event is commented.
* `DragonTracker.Events.changeLabelType` : Called when player use slash command /dragontrackerlabeltype.  
Used to change label name to use between cardinal point and location name.
* `DragonTracker.Events.keybindingsToggle` : Called when player use the keybind to show/hide the GUI

### GUI.lua

Table : `DragonTracker.GUI`

Contains all functions to define the GUI container and save GUIItems instances.

Properties :

* `container` : The TopLevelControl in interface
* `items` : List of GUIItems associate to a dragon
* `nbItems` : Number of GUIItems in `items`.
* `savedVars` : A direct access to `DragonTracker.savedVariables.gui` which contain all saved variables used by the GUI.
* `fragment` : The fragment used to define when the GUI is displayed
* `toDisplay` : To know if the GUI should be displayed (user config only)  
It's not the current GUI display status because the user can accept to display it but not be in a dragon's zone (so the GUI will be hidden) !

Methods :

* `DragonTracker.GUI:init` : Initialise the GUI
* `DragonTracker.GUI:obtainContainer` : Obtain the TopLevelControl's table
* `DragonTracker.GUI:restorePosition` : Restore the GUI's position from savedVariables
* `DragonTracker.GUI:savePosition` : Save the GUI's position from savedVariables
* `DragonTracker.GUI:restoreLock` : Restore the GUI locked status
* `DragonTracker.GUI:isLocked` : Return the status if the GUI should be locked or not
* `DragonTracker.GUI:defineLocked` : Define if the GUI should be locked or not, and update the GUI to lock it (or not)
* `DragonTracker.GUI:defineFragment` : Define GUI has a fragment linked to scenes.  
With that, the GUI is hidden when we open a menu (like inventory or map)
* `DragonTracker.GUI:isDisplayWithWMap` : Return the status if the GUI should be display in the world map interface
* `DragonTracker.GUI:defineDisplayWithWMap` : Define the status which define if the GUI is displayed in the world map interface or not, and update the fragment to apply the new status.
* `DragonTracker.GUI:display` : Hide or show all GUIItems.
* `DragonTracker.GUI:toggleToDisplay` : Switch the status of toDisplay to be the invert of the previous status, and call self:display() to update the GUI
* `DragonTracker.GUI:createItem` : To create a GUIItem instance for a Dragon
* `DragonTracker.GUI:resetItem` : To reset the list of GUIItems
* `DragonTracker.GUI:labelUseName` : Define the label type to use on the location name.
* `DragonTracker.GUI:labelUseCardinalPoint` : Define the label type to use on  the cardinal point.
* `DragonTracker.GUI:obtainLabelType` : Return the current labelFormat used
* `DragonTracker.GUI:defineLabelType` : Define the label to use and call the method to move the value controler relative to the max width of labels

### GUIItems.lua

Table : `DragonTracker.GUIItem`

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

* `DragonTracker.GUIItem:new` : To instanciate a new GUIItem instance
* `DragonTracker.GUIItem:defineTooltips` : Define all tooltip 
* `DragonTracker.GUIItem:obtainTypeTooltipText` : Return the text to use in color tooltip
* `DragonTracker.GUIItem:changeColor` : To change the color in the dragon color box 
* `DragonTracker.GUIItem:changeTitleType` : Change the title type to use and update label text.
* `DragonTracker.GUIItem:moveValueCtr` : Move the value controler relative to the label width.
* `DragonTracker.GUIItem:clear` : Define the text value as empty string
* `DragonTracker.GUIItem:display` : Define the value of SetHidden to show or hide the label
* `DragonTracker.GUIItem:show` : Show the label
* `DragonTracker.GUIItem:hide` : Hide the label
* `DragonTracker.GUIItem:update` : Update the text value
* `DragonTracker.GUIItem:obtainSinceValue` : Obtain the text to display with a "[status] since..."
* `DragonTracker.GUIItem:obtainRepopInValue` : Obtain the text to display with a "repop in..."
* `DragonTracker.GUIItem:obtainStatusText` : Obtain the status to display from a dragon status
* `DragonTracker.GUIItem:obtainSinceTimerInfo` : Obtain the timer text to display when message is "[status] since..." (so count from 0)
* `DragonTracker.GUIItem:obtainInTimerInfo` : Obtain the timer text to display when message is "repop in..." (so count to 0)
* `DragonTracker.GUIItem:formatTime` : Format the time to have it for second, minute, or hour

### GUITimer.lua

Table : `DragonTracker.GUITimer`  
Extends : `LibDragonWorldEvent.Timer`

Contain all function to manage the timer used to display "since..."

Methods :

* `DragonTracker.GUITimer.update` : Callback function on timer. Called each 1sec in dragons zone. Update the GUI for each dragon.

### Settings.lua

Table : `DragonTracker.Settings`

Contain all function used to build the settings panel

Properties :

* `panelName` : The name of the settings panel

Methods :

* `DragonTracker.Settings:init` : Initialise the settings panel
* `DragonTracker.Settings:build` : Build the settings panel
* `DragonTracker.Settings:buildGUILocked` : Build the "GUI Locked" part of the panel
* `DragonTracker.Settings:buildDisplayedWithWorldMap` : Build the "Displayed with the World Map" part of the panel
* `DragonTracker.Settings:buildPositionType` : Build the "Position type" part of the panel

### Run.lua

Define a listener to all used events.
