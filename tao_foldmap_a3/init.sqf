// Tao Folding Map init
// (C) 2013 Ryan Schultz. See LICENSE.

tao_foldmap = false;

/////////////////////////////////////////////////////////////////////////////////


// Include the userconfig key file
#include "\userconfig\tao_foldmap_a3\tao_foldmap_a3.hpp"

// Get a rsc layer
tao_foldmap_rscLayer = ["TMR_FoldMap"] call BIS_fnc_rscLayer;

// TODO: Is this ideal? original = 0.20
tao_foldmap_mapScale = 0.053;
tao_foldmap_baseScale = 0.053;

// default map scale is 0.20 * 8192 / mapsize
/* map size:
Stratis: 8192
Altis: 30720
Zargabad: 8192
Takistan: 12800
proving grounds: 2048  ("ProvingGrounds_PMC")
Shapur: 2048		("Shapur_BAF")
Utes: 5120		("utes")
Chernarus: 15360
Desert: 2048		("Desert_E")
*/

_island = worldname;

switch (_island) do
{
	case "Stratis": { tao_foldmap_mapScale = 0.2;};
	case "Zargabad": { tao_foldmap_mapScale = 0.2;};
	case "Altis": { tao_foldmap_mapScale = 0.053;};
	case "Takistan": { tao_foldmap_mapScale = 0.128;};
	case "ProvingGrounds_PMC": { tao_foldmap_mapScale = 0.8;};
	case "Shapur_BAF": { tao_foldmap_mapScale = 0.8;};
	case "Desert_E": { tao_foldmap_mapScale = 0.8;};
	case "Chernarus": { tao_foldmap_mapScale = 0.107;};
	case "utes": { tao_foldmap_mapScale = 0.32;};
	default { tao_foldmap_mapScale = 0.2;};
};

tao_foldmap_scaleReset = false; // Does the scale need to be reset for paging?
tao_foldmap_baseScale = tao_foldmap_mapScale;

tao_foldmap_nightMap = false; // Display the night vision map?

// Define values for positioning the foldmap.
#define tao_foldmap_leftX  0.021
#define tao_foldmap_rightX  0.66

tao_foldmap_mapPosXOffset = tao_foldmap_leftX + 0.0032;
tao_foldmap_mapPosYOffset = 0.265 - 0.026 + 0.015;
tao_foldmap_mapBackPosXOffset = tao_foldmap_mapPosXOffset - 0.07 - 0.0037;
tao_foldmap_mapBackPosYOffset = tao_foldmap_mapPosYOffset - 0.050 + 0.025 - 0.015;

#define tao_foldmap_mapPosX (safezoneX + tao_foldmap_mapPosXOffset * safezoneW)
#define tao_foldmap_mapPosY (safezoneY + tao_foldmap_mapPosYOffset * safezoneW)
#define tao_foldmap_mapBackPosX  (safezoneX + tao_foldmap_mapBackPosXOffset * safezoneW)
#define tao_foldmap_mapBackPosY  (safezoneY + tao_foldmap_mapBackPosYOffset * safezoneW)

#define tao_foldmap_statusBarYOffset 0.021
#define tao_foldmap_statusBarTextYOffset 0.022

// FUNCTIONS /////////////////////////////////////////////////////////////////////

tao_foldmap_drawUpdate = {
	// Draw location of player if in Vet/Expert and has a GPS
	if (!cadetMode && ("ItemGPS" in assignedItems player)) then {
		_pos = getPos player;
		_dayColor = [0.06, 0.08, 0.06, 0.87];
		_nightColor = [0.9, 0.9, 0.9, 0.8];

		((uiNamespace getVariable "Tao_FoldMap") displayCtrl 25) drawIcon [getText(configFile >> "CfgMarkers" >> "mil_arrow2" >> "icon"), _dayColor, _pos, 19, 25, direction vehicle player, "", false];
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl 26) drawIcon [getText(configFile >> "CfgMarkers" >> "mil_arrow2" >> "icon"), _nightColor, _pos, 19, 25, direction vehicle player, "", false];
	};
};

// Dialog init function for foldmap.
tao_foldmap_initDialog = {
	// Scroll isn't finished yet.
	tao_foldmap_scrollFinished = false;

	// Determine if it's day or night so we can use the correct map.
	tao_foldmap_mapCtrlActive = 25;
	tao_foldmap_mapCtrlInactive = 26;
	if (tao_foldmap_nightMap) then { // Night map
		tao_foldmap_mapCtrlActive = 26;
		tao_foldmap_mapCtrlInactive = 25;
	};

	tao_foldmap_mapCtrlStatusBar = 24;
	tao_foldmap_mapCtrlStatusBarRight = 27;
	tao_foldmap_mapCtrlStatusBarLeft = 28;
	
	// On first run, get the center pos. This is used for all paging thereafter.
	if (isNil "tao_foldmap_centerPos") then {
		tao_foldmap_centerPos = getpos player;
	};
	
	// Off-map check: if the player passed off the map while it was closed, recenter it (can't fold neatly)
	if (!isNil "tao_foldmap_xPagingD") then {
		_dX = abs ((tao_foldmap_centerPos select 0) - (getpos player select 0));
		_dY = abs ((tao_foldmap_centerPos select 0) - (getpos player select 0));
		
		// Fudge factor here to avoid opening on the edge of the map, which isn't very helpful.
		if (_dX + 150 > tao_foldmap_xPagingD || _dY + 150 > tao_foldmap_yPagingD) then {
			tao_foldmap_centerpos = getpos player;
			//player sidechat 'passed off while map closed';
		};
	};
	
	// Center map on centering pos
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlMapAnimAdd [0, tao_foldmap_mapScale, tao_foldmap_centerPos];
	ctrlMapAnimCommit ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive);
	
	// Get player position for auto-recenter (teleport fix)
	tao_foldmap_oldPos = getPos player;

	// Place everything in position to be scrolled.
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl 23) ctrlSetPosition [tao_foldmap_mapBackPosX, safezoneY + 1 * safezoneW];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl 23) ctrlCommit 0;

	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlSetPosition [tao_foldmap_mapPosX, safezoneY + 1 * safezoneW];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlCommit 0;

	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBar ) ctrlSetPosition [tao_foldmap_mapPosX, safezoneY + 1 * safezoneW];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBar ) ctrlCommit 0;

	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarRight) ctrlSetPosition [tao_foldmap_mapPosX, safezoneY + 1 * safezoneW];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarRight) ctrlCommit 0;

	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarLeft) ctrlSetPosition [tao_foldmap_mapPosX, safezoneY + 1 * safezoneW];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarLeft) ctrlCommit 0;
	
	// Add draw handler to page the map and update the player marker.
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl 25) ctrlAddEventHandler ["Draw", "[] call tao_foldmap_drawUpdate"];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl 26) ctrlAddEventHandler ["Draw", "[] call tao_foldmap_drawUpdate"];
	
	// Hide the map we are not using.
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlInactive) ctrlSetPosition [tao_foldmap_mapPosX, safezoneY + 1 * safezoneW];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlInactive) ctrlCommit 0;
};

// Loop which runs while foldmap is open. Separate from draw EH.
tao_foldmap_drawMapLoop = {
	// Scroll the map up from the bottom of the screen.
	tao_foldmap_rscLayer cutRsc ["tao_foldmap","PLAIN",0];

	// Set the fake radio string based on player's side
	_radioSource = "Armacomm GPS";
	switch (side player) do {
		case blufor: {
			_radioSource = "Blucomm GPS";
		};

		case opfor: {
			_radioSource = "Opcomm GPS";
		};

		default {
			_radioSource = "Armacomm GPS";
		};
	};
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarLeft) ctrlSetText _radioSource;

	// Set the time on the status bar
	_min = date select 4;
	if (_min < 10) then {
		_min = format ["0%1", _min];
	};
	_date = format ["%1/%2/%3 %4:%5 []]]]", date select 0, date select 1, date select 2, date select 3, _min];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarRight) ctrlSetText _date;
	
	// Darken the background sheet before it pops up.
	//_darkFactor = (0.6 min (abs(sunOrMoon - 1)));
	//((uiNamespace getVariable "Tao_FoldMap") displayCtrl 23) ctrlSetBackgroundColor [1 - _darkFactor, 1 - _darkFactor, 0.87 - _darkFactor / 1.08, 0.95];
	
	// Pop up map and background and GUI bits.
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl 23) ctrlSetPosition [tao_foldmap_mapBackPosX, tao_foldmap_mapBackPosY];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl 23) ctrlCommit 0.4;
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive)  ctrlSetPosition [tao_foldmap_mapPosX, tao_foldmap_mapPosY];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive)  ctrlCommit 0.4;
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBar)  ctrlSetPosition [tao_foldmap_mapPosX, tao_foldmap_mapPosY - tao_foldmap_statusBarYOffset];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBar)  ctrlCommit 0.4;

	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarRight)  ctrlSetPosition [tao_foldmap_mapPosX, tao_foldmap_mapPosY - tao_foldmap_statusBarTextYOffset];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarRight)  ctrlCommit 0.4;

	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarLeft)  ctrlSetPosition [tao_foldmap_mapPosX, tao_foldmap_mapPosY - tao_foldmap_statusBarTextYOffset];
	((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarLeft)  ctrlCommit 0.4;
	
	// Wait til map pops up
	waituntil {ctrlCommitted ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) };
	sleep 0.1;
	tao_foldmap_scrollFinished = true;
	
	tao_foldmap_drawingLoop = true;
	while {tao_foldmap_open && !visibleMap} do {
		// Update the delta number for map paging updates if needed
		if (isNil "tao_foldmap_xPagingD" || tao_foldmap_scaleReset) then {
			// Upper left corner
			_upperLeftCornerPos = ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive)  ctrlMapScreenToWorld [tao_foldmap_mapPosX, tao_foldmap_mapPosY];
			tao_foldmap_xPagingD = abs((_upperLeftCornerPos select 0) - (tao_foldmap_centerPos select 0));
			tao_foldmap_yPagingD = abs((_upperLeftCornerPos select 1) - (tao_foldmap_centerPos select 1));
		};
		
		// Don't show map outside of usual cameras or when dead
		_check = (cameraView in ["INTERNAL","EXTERNAL"]) && alive player;
	
		// Close map if any of the check fails.
		if !(_check) then {
			tao_foldmap_open = false;
		};
			
		// Off-map check: if the player has gotten off the map for whatever reason (teleport, off-map area), re-center the map
		if (ctrlCommitted ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) && tao_foldmap_scrollFinished) then {
			_wts = ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive)  ctrlMapWorldToScreen getPos player;
			_upperLeftCorner = [tao_foldmap_mapPosX, tao_foldmap_mapPosY];
			_lowerRightCorner = [tao_foldmap_mapPosX + (safezoneW * 0.38), tao_foldmap_mapPosY + (safezoneH * 0.75)];
			
			_fudgeFactor = 0.2;

			if (_wts select 0 < (_upperLeftCorner select 0) - _fudgeFactor || _wts select 1 < (_upperLeftCorner select 1) - _fudgeFactor || _wts select 0 > (_lowerRightCorner select 0) + _fudgeFactor || _wts select 1 > (_lowerRightCorner select 1) + _fudgeFactor) then {
				tao_foldmap_centerpos = getpos player;
				((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlMapAnimAdd [0, tao_foldmap_mapScale, [tao_foldmap_centerpos select 0, tao_foldmap_centerpos select 1, 0]];
				ctrlMapAnimCommit ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive);
				//player sidechat 'offmap recenter';
			};
		};
		
		// Don't try to page until paging values are defined (map must have slid into place).
		if (!isNil "tao_foldmap_xPagingD" && tao_foldmap_scrollFinished) then {
			// Flip to next 'page' as we pass off the map.
			_pagingFudgeFactor = 80 * tao_foldmap_mapScale / tao_foldmap_baseScale;
			_deltaX = (tao_foldmap_centerpos select 0) - (getpos player select 0);

			// This could probably all be done with only two checks but I got lazy

			// Page left
			if (_deltaX > tao_foldmap_xPagingD - _pagingFudgeFactor) then {
				((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlMapAnimAdd [0, tao_foldmap_mapScale, [(getpos player select 0) - _deltaX + 1, tao_foldmap_centerpos select 1, 0]];
				tao_foldmap_centerpos set [0, abs((getpos player select 0) - _deltaX + 1)];
				ctrlMapAnimCommit ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive);
				//player sidechat 'foldmap deltaxleft';
			};

			// Page right
			if (_deltaX < -tao_foldmap_xPagingD + _pagingFudgeFactor) then {
				((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlMapAnimAdd [0, tao_foldmap_mapScale, [(getpos player select 0) - _deltaX - 1, tao_foldmap_centerpos select 1, 0]];
				tao_foldmap_centerpos set [0, abs((getpos player select 0) - _deltaX - 1)];
				ctrlMapAnimCommit ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive);
				//player sidechat 'foldmap deltaxright';
			};


			_deltaY = (tao_foldmap_centerpos select 1) - (getpos player select 1);

			// Page up
			if (_deltaY < -tao_foldmap_yPagingD + _pagingFudgeFactor) then {
				((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive)  ctrlMapAnimAdd [0, tao_foldmap_mapScale, [tao_foldmap_centerpos select 0, (getpos player select 1) - _deltaY - 1, 0]];
				tao_foldmap_centerpos set [1, abs((getpos player select 1) - _deltaY - 1)];
				ctrlMapAnimCommit ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive);
				//player sidechat 'foldmap deltayip';
			};

			// Page down
			if (_deltaY > tao_foldmap_yPagingD - _pagingFudgeFactor) then {
				((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive)  ctrlMapAnimAdd [0, tao_foldmap_mapScale, [tao_foldmap_centerpos select 0, (getpos player select 1) - _deltaY + 1, 0]];
				tao_foldmap_centerpos set [1, abs((getpos player select 1) - _deltaY + 1)];
				ctrlMapAnimCommit ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive);
				//player sidechat 'foldmap deltaydown';
			};
		};
		
		// Update pos for recenter checking
		tao_foldmap_oldPos = getpos player;

		// Update the time on the status bar
		_min = date select 4;
		if (_min < 10) then {
			_min = format ["0%1", _min];
		};
		_date = format ["%1/%2/%3 %4:%5 []]]]", date select 0, date select 1, date select 2, date select 3, _min];
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarRight) ctrlSetText _date;

		sleep 0.3;
	};
	tao_foldmap_drawingLoop = false;
	
	// Starting a new scroll.
	tao_foldmap_scrollFinished = false;
	
	// Scroll the map off the screen.

	[] spawn {
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl 23) ctrlSetPosition [tao_foldmap_mapBackPosX, safezoneY + 1 * safezoneW];
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl 23) ctrlCommit 0.4;
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlSetPosition [tao_foldmap_mapPosX, safezoneY + 1 * safezoneW];
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlCommit 0.4;
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBar) ctrlSetPosition [tao_foldmap_mapPosX, safezoneY + 1 * safezoneW];
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBar) ctrlCommit 0.4;
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarRight) ctrlSetPosition [tao_foldmap_mapPosX, safezoneY + 1 * safezoneW];
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarRight) ctrlCommit 0.4;
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarLeft) ctrlSetPosition [tao_foldmap_mapPosX, safezoneY + 1 * safezoneW];
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlStatusBarLeft) ctrlCommit 0.4;

		waitUntil {sleep 0.1; ctrlCommitted ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive)};

		if (!tao_foldmap_open) then {
			tao_foldmap_rscLayer cutText ["", "PLAIN"];
		};
	};
};

// Process keybinds specified in config file, if so specified. Else, default to modified actionKeys
tao_foldmap_processKeyConfig = {
	// Key config format is [dikCode, shift?, ctrl?, alt?]
	if (TAO_FOLDMAP_USECUSTOMKEYS) then {
		// User has asked us to use config keys, parse them into a keyHandler check expression
		tao_foldmap_keyOpen = [TAO_FOLDMAP_OPEN, TAO_FOLDMAP_OPEN_SHIFT, TAO_FOLDMAP_OPEN_CTRL, TAO_FOLDMAP_OPEN_ALT];
		tao_foldmap_keyCenter = [TAO_FOLDMAP_CENTER, TAO_FOLDMAP_CENTER_SHIFT, TAO_FOLDMAP_CENTER_CTRL, TAO_FOLDMAP_CENTER_ALT];
		tao_foldmap_keyZoomIn = [TAO_FOLDMAP_ZOOMIN, TAO_FOLDMAP_ZOOMIN_SHIFT, TAO_FOLDZOOMIN_CTRL, TAO_FOLDMAP_ZOOMIN_ALT];
		tao_foldmap_keyZoomOut = [TAO_FOLDMAP_ZOOMOUT, TAO_FOLDMAP_ZOOMOUT_SHIFT, TAO_FOLDZOOMOUT_CTRL, TAO_FOLDMAP_ZOOMOUT_ALT];
		tao_foldmap_keyNVMode = [TAO_FOLDMAP_NVMODE, TAO_FOLDMAP_NVMODE_SHIFT, TAO_FOLDNVMODE_CTRL, TAO_FOLDMAP_NVMODE_ALT];
	} else {
		// Default: Use modified actionKeys for all keybinds
		tao_foldmap_keyOpen = [actionKeys "ShowMap" select 0, true, false, false];
		tao_foldmap_keyCenter = [actionKeys "ShowMap" select 0, true, true, false];
		tao_foldmap_keyZoomIn = [actionKeys "ZoomIn" select 0, true, true, false];
		tao_foldmap_keyZoomOut = [actionKeys "ZoomOut" select 0, true, true, false];
		tao_foldmap_keyNVMode = [actionKeys "NightVision" select 0, true, true, false];
	};
};

tao_xnor = {
	// The year is 2014. 
	// SQF has no logical equivalence operator.

	_a = _this select 0;
	_b = _this select 1;

	_ret = true;
	if (_a) then {
		if (_b) then {
			_ret = true;
		} else {
			_ret = false;
		};
	} else {
		if (!_b) then {
			_ret = true;
		} else {
			_ret = false;
		};
	};

	_ret;
};

// Checks if a given key input [dikcode, shift, ctrl, alt] is equal to a key config array (same format)
tao_foldmap_checkKey = {
	_keyConfig = _this select 0;
	_dikCode = _this select 1;
	_shift = _this select 2;
	_ctrl = _this select 3;
	_alt = _this select 4;

	_kcDikCode = _keyConfig select 0;
	_kcShift = _keyConfig select 1;
	_kcCtrl = _keyConfig select 2;
	_kcAlt = _keyConfig select 3;

	// Return true if all are equal, false if not.

	//_dikCode == _kcDikCode && _shift == _kcShift && _ctrl == _kcCtrl && _alt == _kcAlt;
	// That's what we could do if SQF WERE REMOTELY A FUCKING USEFUL SCRIPTING LANGUAGE.

	_dikCode == _kcDikCode && ([_shift, _kcShift] call tao_xnor) && ([_ctrl, _kcCtrl] call tao_xnor) && ([_alt, _kcAlt] call tao_xnor);

};

// Key handler for opening, closing, and moving tap.
tao_foldmap_keyHandler = {
	private["_handled", "_display", "_ctrl", "_dikCode", "_shift", "_alt"];
	_display = _this select 0;
	_dikCode = _this select 1;
	_shift = _this select 2;
	_ctrl = _this select 3;
	_alt = _this select 4;
	  
	_handled = false;
	
	// Toggle foldmap on Shift-Map
	if ([tao_foldmap_keyOpen, _dikCode, _shift, _ctrl, _alt] call tao_foldmap_checkKey && !visibleMap && ("ItemMap" in assignedItems player)) then {
		// Initialize variable if never set.
		if (isNil "tao_foldmap_open") then {tao_foldmap_open = false};
	
	
		// Don't show map outside of usual cameras, when dead, or when in debug
		_check = (cameraView in ["INTERNAL","EXTERNAL","GUNNER"]) && alive player && isNil "BIS_DEBUG_CAM";
	
		if (_check && !tao_foldmap_open) then {
			tao_foldmap_open = true;
			[] spawn tao_foldmap_drawMapLoop;
		} else {
			tao_foldmap_open = false;
		};
		_handled = true;
	};
	
	// If opening gear, close foldmap
	if (_dikCode in (actionKeys "Gear")) then {
		tao_foldmap_open = false;
		_handled = false;
	};
	
	// Shift-Ctrl-Map 'refolds' the map to recenter it. Poor man's GPS I guess but whatever, I don't really care
	// about people who are playing ArmA for landnav training.
	if ([tao_foldmap_keyCenter, _dikCode, _shift, _ctrl, _alt] call tao_foldmap_checkKey && tao_foldmap_open) then {
		tao_foldmap_centerpos = getpos player;
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlMapAnimAdd [0, tao_foldmap_mapScale, [tao_foldmap_centerpos select 0, tao_foldmap_centerpos select 1, 0]];
		ctrlMapAnimCommit ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive);
		_handled = true;
	};

	// Shift-Ctrl-ZoomIn to center and zoom
	if ([tao_foldmap_keyZoomIn, _dikCode, _shift, _ctrl, _alt] call tao_foldmap_checkKey && tao_foldmap_open) then {
		if (tao_foldmap_mapscale / 2 > 0.005) then { // Don't allow excessive zoom
			tao_foldmap_centerpos = getpos player;
			tao_foldmap_mapScale = tao_foldmap_mapScale /2;
			((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlMapAnimAdd [0, tao_foldmap_mapScale, [tao_foldmap_centerpos select 0, tao_foldmap_centerpos select 1, 0]];
			ctrlMapAnimCommit ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive);
			tao_foldmap_scaleReset = true;
			_handled = true;
		};
	};
	
	// Shift-Ctrl-ZoomOut to center and unzoom
	if ([tao_foldmap_keyZoomOut, _dikCode, _shift, _ctrl, _alt] call tao_foldmap_checkKey && tao_foldmap_open) then {
		tao_foldmap_centerpos = getpos player;
		tao_foldmap_mapScale = tao_foldmap_mapScale * 2;
		if (tao_foldmap_mapScale > 1) then { 
			tao_foldmap_mapScale = 1;
		};
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlMapAnimAdd [0, tao_foldmap_mapScale, [tao_foldmap_centerpos select 0, tao_foldmap_centerpos select 1, 0]];
		ctrlMapAnimCommit ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive);
		tao_foldmap_scaleReset = true;
		_handled = true;
	};

	// Shift-Ctrl-Nightvision to toggle the map's nightvision view
	if ([tao_foldmap_keyNVMode, _dikCode, _shift, _ctrl, _alt] call tao_foldmap_checkKey && tao_foldmap_open) then {
		tao_foldmap_nightMap = !tao_foldmap_nightMap;
		// Change which map is in use
		if (tao_foldmap_nightMap) then { // Night map
			tao_foldmap_mapCtrlActive = 26;
			tao_foldmap_mapCtrlInactive = 25;
		} else {
			tao_foldmap_mapCtrlActive = 25;
			tao_foldmap_mapCtrlInactive = 26;
		};

		// Show the map we want and give it the scale/centering properties of the current map.
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlSetPosition ctrlPosition ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlInactive);
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlCommit 0;
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive) ctrlMapAnimAdd [0, tao_foldmap_mapScale, [tao_foldmap_centerpos select 0, tao_foldmap_centerpos select 1, 0]];
		ctrlMapAnimCommit ((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlActive);

		// Hide the map we are not using.
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlInactive) ctrlSetPosition [tao_foldmap_mapPosX, safezoneY + 1 * safezoneW];
		((uiNamespace getVariable "Tao_FoldMap") displayCtrl tao_foldmap_mapCtrlInactive) ctrlCommit 0;
		_handled = true;
	};
	
	_handled;
};

// Fired EH to close the foldmap.
tao_foldmap_firedEH = {
	if ((_this select 0) == player) then {
		tao_foldmap_open = false;
	};
};


/////////////////////////////////////////////////////////////////////////////////

// Add key handler. 
[] spawn {
	waituntil {!isNull (findDisplay 46)};
	[] call tao_foldmap_processKeyConfig;
	(findDisplay 46) displayAddEventHandler ["KeyDown", "_this call tao_foldmap_keyHandler"];
};

/////////////////////////////////////////////////////////////////////////////////

tao_foldmap = true; // Init done.