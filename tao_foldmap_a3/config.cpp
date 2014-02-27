#define true	1
#define false	0

class CfgPatches {
	class tao_foldmap_a3 {
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {CBA_XEH, CBA_MAIN, A3_UI_F};
		version = 2.2;
		author[] = {"Taosenai"};
		authorUrl = "http://ryanschultz.org/arma-3/";
	};
};

class CfgMods {
	class tao_foldmap_a3 {
		dir = "tao_foldmap_a3";
		name = "Tao Folding Map";
		picture = "";
		hidePicture = "true";
		hideName = "false";
		actionName = "Website";
		action = "http://ryanschultz.org/arma-3/";
	};
};

class Extended_PostInit_EventHandlers {
	class tao_foldmap_a3 {
		clientInit = "call compile preProcessFileLineNumbers '\tao_foldmap_a3\init.sqf'";
	};
};

class TAO_RscStdText {
   type = 0;
   idc = -1;
   style = 2;
   colorBackground[] = {0,0,0,0};
   colorText[] = {1,1,1,1};
   font = "PuristaMedium";
   size = 2.3;
   sizeEx = 0.055;
   shadow = 2;
};

class RscMapControl;

class RscTitles {
	class Tao_FoldMap {
		idd = -1;
		onLoad = "with uiNameSpace do { Tao_Foldmap = _this select 0 }; [] call tao_foldmap_initDialog;";
		onUnload = "";
		movingEnable = 1;
		duration = 1000000;
		fadeIn = 0;
		fadeOut = 0;
		controls[] = {"Tao_FoldMapBack", "Tao_FoldMapStatusBar", "Tao_FoldMapStatusBarTextRight", "Tao_FoldMapStatusBarTextLeft", "TAO_Foldmap", "Tao_Foldmap_NightRed"};

		class Tao_FoldMapBack : TAO_RscStdText {
			idc = 23;
			type = 0;
			style = 48;
			x = safezoneX + 0.574 * safezoneW;
			y = safezoneY + 1 * safezoneW;
			w = safezoneW * 0.4525;
			h = safezoneH * 0.745;
			colorBackground[] = {0, 0, 0, 0};
			colorText[] = {1,1,1,1};
			text = "\tao_foldmap_a3\data\datapad_ca.paa";
		};

		class Tao_FoldMapStatusBar : TAO_RscStdText {
			idc = 24;
			style = 0x01;
			x = safezoneX + 0.582 * safezoneW;
			y = safezoneY + 1 * safezoneW;
			w = safezoneW * 0.305;
			h = safezoneH * 0.015;
			colorBackground[] = {0.09, 0.1, 0.13, 1};
			colorText[] = {1,1,1,1};
			sizeEx = "0.012 / (getResolution select 5)"
			text = "";
		};

		class Tao_FoldMapStatusBarTextRight : Tao_FoldMapStatusBar {
			idc = 27;
			style = 0x01; // Right justify
			w = safezoneW * 0.305;
			colorBackground[] = {1, 0, 0, 0};
			colorText[] = {1,1,1,1};
			sizeEx = "0.014 / (getResolution select 5)"
			text = "";
		};

		class Tao_FoldMapStatusBarTextLeft: Tao_FoldMapStatusBar {
			idc = 28;
			style = 0x00; // Left justify
			w = safezoneW * 0.295;
			colorBackground[] = {1, 0, 0, 0};
			colorText[] = {1,1,1,1};
			sizeEx = "0.014 / (getResolution select 5)"
			text = "Armacomm AGPRS";
		};
		
		class Tao_FoldMap : RscMapControl {
			idc = 25;
			x = safezoneX + 0.58 * safezoneW;
			y = safezoneY + 1 * safezoneW;
			w = safezoneW * 0.305;
			h = safezoneH * 0.625;
			type = 101; // Use 100 to hide markers
			style = 48;
			colorLevels[] = {0.65, 0.6, 0.55, 1};
			colorSea[] = {0.46, 0.65, 0.74, 0.5};
			colorForest[] = {0.02, 0.5, 0.01, 0.3};
			colorForestBorder[] = {0.02, 0.5, 0.01, 0.27};
			colorRocks[] = {0, 0, 0, 0.3};
			colorCountlines[] = {0.65, 0.45, 0.27, 0.70};
			colorMainCountlines[] = {1, 0.1, 0.1, 0.9};
			colorCountlinesWater[] = {0.25, 0.4, 0.5, 0.3};
			colorMainCountlinesWater[] = {0.25, 0.4, 0.5, 0.9};

			colorBuildings[] = {0.541, 0.216, 0.204, 0.95};
			colorBuilding[] = {0.541, 0.216, 0.204, 0.95};
			colorStructures[] = {0.541, 0.216, 0.204, 0.95};

			colorPowerLines[] = {0.1, 0.1, 0.1, 1};
			colorRailWay[] = {0.8, 0.2, 0, 1};
			colorTracks[] = {0.84, 0.76, 0.65, 0.15};
			colorTracksFill[] = {0.84, 0.76, 0.65, 1.0};
			colorRoads[] = {0.7, 0.7, 0.7, 1.0};
			colorRoadsFill[] = {1.0, 1.0, 1.0, 1.0};
			colorMainRoads[] = {0.9, 0.5, 0.3, 1.0};
			colorMainRoadsFill[] = {1.0, 0.6, 0.4, 1.0};
			
			colorRocksBorder[] = {0, 0, 0, 0};
			colorNames[] = {0.1, 0.1, 0.1, 0.9};
			colorInactive[] = {1, 1, 1, 0.5};
			colorOutside[] = {0.7, 0.5, 0.5, 1};
			colorBackground[] = {1, 1, 0.85, 0.95};
			colorText[] = {1, 1, 1, 0.85};

			colorGrid[] = {0.1, 0.1, 0.1, 0.6};
			colorGridMap[] = {0.1, 0.1, 0.1, 0.6};

			text = "#(argb,8,8,3)color(1,1,1,1)";

			font = "PuristaMedium";
			sizeEx = 0.0270000;
			scaleMin = 1e-006;
			scaleMax = 1000;
			scaleDefault = 0.18;
		
			stickX[] = {0.20, {"Gamma", 1.00, 1.50} };
			stickY[] = {0.20, {"Gamma", 1.00, 1.50} };
			ptsPerSquareSea = 6;
			ptsPerSquareTxt = 8;
			ptsPerSquareCLn = 8;
			ptsPerSquareExp = 8;
			ptsPerSquareCost = 8;
			ptsPerSquareFor = "4.0f";
			ptsPerSquareForEdge = "10.0f";
			ptsPerSquareRoad = 2;
			ptsPerSquareObj = 10;

			fontLabel = "PuristaMedium";
			sizeExLabel = 0.027000;
			fontGrid = "EtelkaMonospaceProBold";
			sizeExGrid = 0.022000;
			fontUnits = "PuristaMedium";
			sizeExUnits = 0.031000;
			fontNames = "PuristaMedium";
			sizeExNames = 0.056000;
			fontInfo = "PuristaMedium";
			sizeExInfo = 0.031000;
			fontLevel = "PuristaMedium";
			sizeExLevel = 0.021000;
			
			maxSatelliteAlpha = 0;     // Alpha to 0 by default
			alphaFadeStartScale = 0.1; 
			alphaFadeEndScale = 3;   // Prevent div/0

			showCountourInterval = "false";
			onMouseButtonClick = "";
			onMouseButtonDblClick = "";
		};

		class Tao_Foldmap_NightRed : Tao_Foldmap {
			idc = 26;
			type = 101; // Use 100 to hide markers
			style = 48;
			colorLevels[] = {0.016, 0.004, 0, 1};
			colorSea[] = {0.208, 0.05, 0.043, 0.5};
			colorForest[] = {0.447, 0.122, 0.137, 0.3};
			colorForestBorder[] = {0.447, 0.122, 0.137, 0.27};
			colorRocks[] = {0, 0, 0, 0.4};
			colorCountlines[] = {0.371, 0.124, 0.122, 0.75};
			colorMainCountlines[] = {0.371, 0.124, 0.122, 0.9};
			colorCountlinesWater[] = {0.371, 0.124, 0.122, 0.55};
			colorMainCountlinesWater[] = {0.371, 0.124, 0.122, 0.6};

			colorTracks[] = {0.447, 0.122, 0.137, 0.15};
			colorTracksFill[] = {0.467, 0.142, 0.157, 1.0};
			colorRoads[] = {0.227, 0.055, 0.051, 1.0};
			colorRoadsFill[] = {0.227, 0.055, 0.051, 0.85};
			colorMainRoads[] = {0.286, 0.071, 0.067, 1.0};
			colorMainRoadsFill[] = {0.286, 0.071, 0.067, 0.85};
			colorPowerLines[] = {0.74, 0.47, 0.49, 0.9};
			colorRailWay[] = {0.506, 0.235, 0.25, 0.9};
			
			colorBuildings[] = {0.541, 0.216, 0.204, 0.95};

			colorRocksBorder[] = {0, 0, 0, 0.3};
			colorNames[] = {0.85, 0.62, 0.61, 0.9};
			colorInactive[] = {0.8, 0.7, 0.7, 0.5};
			colorOutside[] = {0, 0, 0, 1};
			colorBackground[] = {0.016, 0.004, 0, 0.95};
			colorText[] = {0.84, 0.61, 0.60, 0.85};

			colorGrid[] = {0.371, 0.124, 0.122, 0.5};
			colorGridMap[] = {0.371, 0.124, 0.122, 0.5};

			text = "#(argb,8,8,3)color(0,0,0,1)";

			font = "PuristaMedium";
			sizeEx = 0.0270000;
			scaleMin = 1e-006;
			scaleMax = 1000;
			scaleDefault = 0.18;
		
			stickX[] = {0.20, {"Gamma", 1.00, 1.50} };
			stickY[] = {0.20, {"Gamma", 1.00, 1.50} };
			ptsPerSquareSea = 6;
			ptsPerSquareTxt = 8;
			ptsPerSquareCLn = 8;
			ptsPerSquareExp = 8;
			ptsPerSquareCost = 8;
			ptsPerSquareFor = "4.0f";
			ptsPerSquareForEdge = "10.0f";
			ptsPerSquareRoad = 2;
			ptsPerSquareObj = 10;

			fontLabel = "PuristaMedium";
			sizeExLabel = 0.027000;
			fontGrid = "EtelkaMonospaceProBold";
			sizeExGrid = 0.022000;
			fontUnits = "PuristaMedium";
			sizeExUnits = 0.031000;
			fontNames = "PuristaMedium";
			sizeExNames = 0.056000;
			fontInfo = "PuristaMedium";
			sizeExInfo = 0.031000;
			fontLevel = "PuristaMedium";
			sizeExLevel = 0.021000;
			
			maxSatelliteAlpha = 0;     // Alpha to 0 by default
			alphaFadeStartScale = 0.1; 
			alphaFadeEndScale = 3;   // Prevent div/0

			showCountourInterval = "false";
			onMouseButtonClick = "";
			onMouseButtonDblClick = "";
		};
	};
};