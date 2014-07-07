// Function to determine the text for the "Change to X" interface button.
// Returns the opposite style from whatever is selected.
tao_foldmap_fnc_getNotSelectedStyleName = {
	_style = profileNamespace getVariable ["tao_foldmap_drawStyle", "paper"];

	_return = "tablet";
	if (_style == "tablet") then {
		_return = "paper";
	};

	_return;
};

// Menu definition.
tao_foldmap_fleximenu =
{
    [
        ["main", "Tao Folding Map", "popup"],
        [
          [
            "Reposition map", // text on button
            {[] call tao_foldmap_fnc_reposition}, // code to run
            "", // icon
            "", // tooltip
            [], // submenu
            DIK_R, // shortcut key
            tao_foldmap_repositionPermitted , // enabled?
            true // visible if true
          ],

          [
          	// Change to tablet/paper
            format ["Change to %1", [] call tao_foldmap_fnc_getNotSelectedStyleName], // text on button
            {[[] call tao_foldmap_fnc_getNotSelectedStyleName] call tao_foldmap_fnc_changeType}, // code to run
            "", // icon
            "", // tooltip
            [], // submenu
            DIK_T, // shortcut key
            tao_foldmap_changePermitted, // enabled?
            true // visible if true
          ]
        ]
    ];
};

// Create a Fleximenu without an associated keypress.
tao_foldmap_fleximenu_def = ["player", [], -100, "_this call tao_foldmap_fleximenu"];
tao_foldmap_fleximenu_def call cba_ui_fnc_fleximenu_add;

// ---------------------------------------------------------------
// Open the Fleximenu for configuring the map.
// ---------------------------------------------------------------
tao_foldmap_fnc_openFleximenu = {
	if (tao_foldmap_isOpen) then {
		tao_foldmap_fleximenu_def call cba_fnc_fleximenu_openMenuByDef;
	};
};