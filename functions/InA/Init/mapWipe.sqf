private ["_excludedObjects"];
// ---------- Map wipe init ----------

if (!isServer) exitWith {};

waitUntil {sleep 1; initialized};

playerVehicles = [];

// ---------- Control loop ----------

private _excludedObjects = allMissionObjects "";

[] spawn {

	while {true} do {
		
		sleep 600;
		
		{
			if ((_x distance (getMarkerPos "respawn_west")) < 750) then {
				deleteVehicle _x;
			};
		} forEach allDeadMen;
	};
};

while {true} do {

	sleep (10 +(random 10));
	
	if ({_x distance (getMarkerPos "respawn_west") > 750} count (allPlayers - entities "HeadlessClient_F") < 1) then {
		if !(alive logiVeh) then {
			{ 
				if ((_x distance (getMarkerPos "respawn_west")) > 750) then {
					deleteVehicle _x;
				};
			} forEach allUnits - (allPlayers - entities "HeadlessClient_F"); 
				
			{ 
				if ((_x distance (getMarkerPos "respawn_west")) > 750) then {
					deleteVehicle _x;
				};
			} forEach (allMissionObjects "" - _excludedObjects - playerVehicles);
			
			[true, "Map has been wiped.", "DEBUG"] call InA_fnc_formatHint;
					
			sleep params_mapWipe;
		};
	};
};