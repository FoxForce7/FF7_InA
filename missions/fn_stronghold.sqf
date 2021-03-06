/* ----------
Function:
	InA_fnc_stronghold

Description:
	spawns a stronghold AO on the map (centered around a city/town/village)

Parameters:

Optional:

Example:
	[] spawn InA_fnc_stronghold;

Returns:
	Nil

Author:
	[FF7] Newsparta
---------- */

// Local declarations
private		_loc			= [];
private		_candidates		= [];
private 	_choice			= [];
private		_mark			= [];
private 	_regions		= [];
private		_accepted		= false;
private		_towns			= [];
private		_isNearPlayer	= false;
private		_isNearLoc		= false;
private		_cleared		= false;
private		_pos			= [];
private		_obj			= ObjNull;
private		_allRoads		= [];
private 	_connectedRoads	= [];
private		_road			= nil;
private		_dir			= 0;
private		_car			= ObjNull;
private		_addSome		= 0;
private		_troops			= [];
private		_group			= [];
private		_wp				= nil;
private		_buildings		= [];
private		_array			= [];
private		_bldg			= [];
private		_nme			= nil;
private		_called			= false;

/////////////////////////////////////////////////
// ---------- BEGIN LOCATION FINDER ---------- //
/////////////////////////////////////////////////

// Check for saved data
if !(InA_stronghold) then {
scopeName "Finder";

	// Collect region data
	_regions = [] call InA_fnc_regionCheck;

	// Check for volatile regions
	{
		if ((_x select 1) >= 0.9) then {
			_candidates pushBack _x
		};
	} forEach _regions;

	// Select region location
	if (count _candidates > 0) then {
		_choice = selectRandom _candidates;
		_mark = getMarkerPos (_choice select 0);
	};

	// Exit if no locations are found
	if (count _candidates < 1) then {
		breakOut "Finder";
	}; 

	// Find the nearest city/town/village
	_towns = nearestLocations [
		_mark, 
		[
			"NameCity",
			"NameCityCapital",
			"NameVillage"
		], 
		750
	];

	// Location selection loop
	while {!_accepted;} do {

		// Store location data
		_loc = locationPosition (selectRandom _towns);
		
		// Check if near players
		_isNearPlayer = false;
		{
			if ((_x distance _loc) < 2000) then {
				_isNearPlayer = true;
			};
		} forEach (allPlayers - entities "HeadlessClient_F");

		// Check if near any other AO locations
		_isNearLoc = false;
		if (count concentrations > 0) then {
			{
				if ((_x distance _loc) < 2000) then {
					_isNearLoc = true;
				};
			} forEach concentrations;
		};

		// Accept location if conditions are met		
		if (((getMarkerPos "respawn_west") distance _loc) > 3000) then {
			if !(_isNearPlayer) then {
				if !(_isNearLoc) then {
					_accepted = true;
				};
			};
		};
	};

	// Declare AO active and set final location
	InA_stronghold = true;
	InA_stronghold_Loc = _loc;

} else {

	// Use stored data
	_loc = InA_stronghold_Loc;

};

///////////////////////////////////////////////
// ---------- END LOCATION FINDER ---------- //
///////////////////////////////////////////////

// If no candidates and not stored in data, exit script
if (count _candidates < 1 && {!InA_stronghold}) exitWith {

	// Time out spawn attempts
	[] spawn {
		InA_stronghold = true;
		sleep 3600;
		InA_stronghold = false;
	};
};

// Enter location into AO array
concentrations pushBack _loc;

/////////////////////////////////////////
// ---------- BEGIN AO LOOP ---------- //
/////////////////////////////////////////

while {!_cleared;} do {

	sleep (2 + (random 2));

	// Check if players are near
	if ({_x distance _loc < mainLimit} count (allPlayers - entities "HeadlessClient_F") > 0) then {

		/////////////////////////
		// BEGIN MISSION SPAWN //
		/////////////////////////

		// MG nests
		for "_i" from 1 to (1 + (round random 2)) do {
			_pos = [_loc, 0, 500, 5, 0, 0.2, 0] call BIS_fnc_findSafePos;
			[_pos] spawn InA_fnc_MGNest;
		};

		// Flags
		for "_i" from 1 to (2 + (round random 5)) do {
			_pos = [_loc, 0, 500, 5, 0, 0.2, 0] call BIS_fnc_findSafePos;
			_obj = createVehicle [INS_FLAG, _pos, [], 0, "CAN_COLLIDE"];
		};

		// Find nearby roads
		_allRoads = _loc nearRoads 500;
		{
			_connectedRoads = roadsConnectedTo _x;
			if ((count _connectedRoads) > 2) then {
				_allRoads = _allRoads - [_x];
			};
		} forEach _allRoads;

		// Ambient trucks
		for "_i" from 1 to (floor random 5) do {
			
				_road = selectRandom _allRoads;
				_connectedTo = ((roadsConnectedTo _road) select 0);
				
				if (random 1 < 0.5) then {
					if (count (roadsConnectedTo _road) > 0) then {
						_dir = _road getDir _connectedTo;
					} else {
						_dir = random 360
					};

					if (supplier == "BLU") then {
						_car = createVehicle [(selectRandom INS_TRUCK_BLU), _road, [], 0, "CAN_COLLIDE"];
						[
							_car,
							missionNamespace getVariable ["INS_TRUCK_BLU_TEX", nil],
							missionNamespace getVariable ["INS_TRUCK_BLU_ANI", nil]
						] call BIS_fnc_initVehicle;
					} else {
						_car = createVehicle [(selectRandom INS_TRUCK_OPF), _road, [], 0, "CAN_COLLIDE"];
						[
							_car,
							missionNamespace getVariable ["INS_TRUCK_OPF_TEX", nil],
							missionNamespace getVariable ["INS_TRUCK_OPF_ANI", nil]
						] call BIS_fnc_initVehicle;
					};
					_car setDir _dir;
					_car setPos [(getPosASL _car select 0) + 4.5, getPosASL _car select 1, 0];

				} else {
					
					if (count (roadsConnectedTo _road) > 0) then {
						_dir = _road getDir _connectedTo;
					} else {
						_dir = random 360
					};

					if (supplier == "BLU") then {
						_car = createVehicle [(selectRandom INS_TRUCK_BLU), _road, [], 0, "CAN_COLLIDE"];
						[
							_car,
							missionNamespace getVariable ["INS_TRUCK_BLU_TEX", nil],
							missionNamespace getVariable ["INS_TRUCK_BLU_ANI", nil]
						] call BIS_fnc_initVehicle;
					} else {
						_car = createVehicle [(selectRandom INS_TRUCK_OPF), _road, [], 0, "CAN_COLLIDE"];
						[
							_car,
							missionNamespace getVariable ["INS_TRUCK_OPF_TEX", nil],
							missionNamespace getVariable ["INS_TRUCK_OPF_ANI", nil]
						] call BIS_fnc_initVehicle;
					};
					_car setDir _dir;
					_car setPos [(getPosASL _car select 0) + 4.5, getPosASL _car select 1, 0];

				};
				
				clearBackpackCargoGlobal _car;
				clearMagazineCargoGlobal _car;
				clearWeaponCargoGlobal _car;
				clearItemCargoGlobal _car;
				if (damage _car > 0.2) then {
					deleteVehicle _car;
				};
		};

		// Ambient cars
		for "_i" from 1 to (floor random 5) do {
			
				_road = selectRandom _allRoads;
				_connectedTo = ((roadsConnectedTo _road) select 0);
				
				if (random 1 < 0.5) then {
					if (count (roadsConnectedTo _road) > 0) then {
						_dir = _road getDir _connectedTo;
					} else {
						_dir = random 360
					};

					if (supplier == "BLU") then {
						_car = createVehicle [(selectRandom INS_CARU_BLU), _road, [], 0, "CAN_COLLIDE"];
						[
							_car,
							missionNamespace getVariable ["INS_CARU_OPF_TEX", nil],
							missionNamespace getVariable ["INS_CARU_OPF_ANI", nil]
						] call BIS_fnc_initVehicle;
					} else {
						_car = createVehicle [(selectRandom INS_CARU_OPF), _road, [], 0, "CAN_COLLIDE"];
						[
							_car,
							missionNamespace getVariable ["INS_CARU_BLU_TEX", nil],
							missionNamespace getVariable ["INS_CARU_BLU_ANI", nil]
						] call BIS_fnc_initVehicle;
					};
					_car setDir _dir;
					_car setPos [(getPosASL _car select 0) + 4.5, getPosASL _car select 1, 0];

				} else {
					
					if (count (roadsConnectedTo _road) > 0) then {
						_dir = _road getDir _connectedTo;
					} else {
						_dir = random 360
					};

					if (supplier == "BLU") then {
						_car = createVehicle [(selectRandom INS_CARU_BLU), _road, [], 0, "CAN_COLLIDE"];
						[
							_car,
							missionNamespace getVariable ["INS_CARU_OPF_TEX", nil],
							missionNamespace getVariable ["INS_CARU_OPF_ANI", nil]
						] call BIS_fnc_initVehicle;
					} else {
						_car = createVehicle [(selectRandom INS_CARU_OPF), _road, [], 0, "CAN_COLLIDE"];
						[
							_car,
							missionNamespace getVariable ["INS_CARU_BLU_TEX", nil],
							missionNamespace getVariable ["INS_CARU_BLU_ANI", nil]
						] call BIS_fnc_initVehicle;
					};
					_car setDir _dir;
					_car setPos [(getPosASL _car select 0) + 4.5, getPosASL _car select 1, 0];

				};
				
				clearBackpackCargoGlobal _car;
				clearMagazineCargoGlobal _car;
				clearWeaponCargoGlobal _car;
				clearItemCargoGlobal _car;
				if (damage _car > 0.2) then {
					deleteVehicle _car;
				};
		};

		// Add extra spawns if there are more players
		if (count (call BIS_fnc_listPlayers) > 10) then {
			_addSome = 2;
		};

		// Enemies

			// Large spawns
			for "_i" from 0 to (round random (3 + _addSome)) do {
				_pos = [_loc, 0, 500, 1, 0, 1, 0] call BIS_fnc_findSafePos;

				_troops = [];
				for "_i" from 1 to (4 + (round random 6)) do {

					_troops pushBack (selectRandom INS_INF_SINGLE);
				};

				_group = [
					_pos, 
					INDEPENDENT,
					_troops
				] call BIS_fnc_spawnGroup;
				[_group, _pos] call BIS_fnc_taskDefend;
				_group setFormDir (random 360);
				[units _group] call InA_fnc_insCustomize;
			};

			for "_i" from 0 to (round random (3 + _addSome)) do {
				_pos = [_loc, 0, 500, 1, 0, 1, 0] call BIS_fnc_findSafePos;

				_troops = [];
				for "_i" from 1 to (4 + (round random 6)) do {

					_troops pushBack (selectRandom INS_INF_SINGLE);
				};

				_group = [
						_pos, 
						INDEPENDENT,
						_troops
					] call BIS_fnc_spawnGroup;
				[_group, _pos, 500] call BIS_fnc_taskPatrol;
				[units _group] call InA_fnc_insCustomize;
			};

			// ManPAD
			for "_i" from 0 to ((count (call BIS_fnc_listPlayers)) * 0.05) do {
				_pos = [_loc, 0, 500, 0, 0, -1, 0] call BIS_fnc_findSafePos;
				_group = [
					_pos, 
					INDEPENDENT, 
					[
						(selectRandom INS_INF_SINGLE),
						(selectRandom INS_INF_SINGLE)
					]
				] call BIS_fnc_spawnGroup;
				[_group, _pos, 500] call BIS_fnc_taskPatrol;
				[units _group] call InA_fnc_insCustomize;
				{
				
					removeBackpackGlobal _x;
					
					if (supplier == "OPF") then {
					
						_choice = INS_AA_OPF call BIS_fnc_selectRandom;
						_x addBackpack (INS_BACKPACKS call BIS_fnc_selectRandom);
						for "_i" from 1 to 2 do {_x addMagazine (_choice select 1);};
						_x addWeapon (_choice select 0);
					
					} else {
					
						_choice = INS_AA_BLU call BIS_fnc_selectRandom;
						_x addBackpack (INS_BACKPACKS call BIS_fnc_selectRandom);
						for "_i" from 1 to 2 do {_x addMagazine (_choice select 1);};
						_x addWeapon (_choice select 0);
					
					};
				} forEach (units _group);
			};
			
			// Car guards
			for "_i" from 0 to ((count (call BIS_fnc_listPlayers)) * 0.1) do {
				if (random 100 < 50) then {
					_pos = [_loc, 0, 250, 1, 0, 1, 0] call BIS_fnc_findSafePos;
					if (supplier == "BLU") then {
						_car = (selectRandom INS_CAR_BLU) createVehicle _pos;
						[
							_car,
							missionNamespace getVariable ["INS_CAR_BLU_TEX", nil],
							missionNamespace getVariable ["INS_CAR_BLU_ANI", nil]
						] call BIS_fnc_initVehicle;
					} else {
						_car = (selectRandom INS_CAR_OPF) createVehicle _pos;
						[
							_car,
							missionNamespace getVariable ["INS_CAR_OPF_TEX", nil],
							missionNamespace getVariable ["INS_CAR_OPF_ANI", nil]
						] call BIS_fnc_initVehicle;
					};
					clearBackpackCargoGlobal _car;
					clearMagazineCargoGlobal _car;
					clearWeaponCargoGlobal _car;
					clearItemCargoGlobal _car;	
					_group = [
						_pos, 
						INDEPENDENT, 
						[
							(selectRandom INS_INF_SINGLE),
							(selectRandom INS_INF_SINGLE)
						]
					] call BIS_fnc_spawnGroup;
							(units _group select 0) assignAsDriver _car;
							(units _group select 1) assignAsGunner _car;
					[units _group] call InA_fnc_insCustomize;
					[_group,_pos,_car] spawn {
						while {true} do {
							scopeName "guard1";
							if (spotted) then {
								_wp = (_this select 0) addWaypoint [(_this select 1),0];
								_wp waypointAttachVehicle (_this select 3);
								_wp setWaypointType "GETIN";
							
								[(_this select 0), (_this select 1)] call BIS_fnc_taskDefend;
								breakOut "guard2";
							};
							
							if (!alive (_this select 3) || count units (_this select 0) < 2) then {
								
								breakOut "guard2";
							};
						sleep 3;
						};
					};
				};
			};

			// MRAP guards
			for "_i" from 0 to ((count (call BIS_fnc_listPlayers)) * 0.067) do {
				if (random 100 < 50) then {
					_pos = [_loc, 0, 250, 1, 0, 1, 0] call BIS_fnc_findSafePos;
					if (supplier == "BLU") then {
						_car = (selectRandom INS_MRAP_BLU) createVehicle _pos;
						[
							_car,
							missionNamespace getVariable ["INS_MRAP_BLU_TEX", nil],
							missionNamespace getVariable ["INS_MRAP_BLU_ANI", nil]
						] call BIS_fnc_initVehicle;
					} else {
						_car = (selectRandom INS_MRAP_OPF) createVehicle _pos;
						[
							_car,
							missionNamespace getVariable ["INS_MRAP_OPF_TEX", nil],
							missionNamespace getVariable ["INS_MRAP_OPF_ANI", nil]
						] call BIS_fnc_initVehicle;
					};
					_car lock 3;
					clearBackpackCargoGlobal _car;
					clearMagazineCargoGlobal _car;
					clearWeaponCargoGlobal _car;
					clearItemCargoGlobal _car;	
					_group = [
						_pos, 
						INDEPENDENT, 
						[
							(selectRandom INS_INF_SINGLE),
							(selectRandom INS_INF_SINGLE)
						]
					] call BIS_fnc_spawnGroup;
						(units _group select 0) assignAsDriver _car;
						(units _group select 1) assignAsGunner _car;
					[units _group] call InA_fnc_insCustomize;
					[_group,_pos,_car] spawn {
						while {true} do {
							scopeName "guard1";
							if (spotted) then {
								_wp = (_this select 0) addWaypoint [(_this select 1),0];
								_wp waypointAttachVehicle (_this select 3);
								_wp setWaypointType "GETIN";
							
								[(_this select 0), (_this select 1)] call BIS_fnc_taskDefend;
								breakOut "guard1";
							};
							
							if (!alive (_this select 3) || count units (_this select 0) < 2) then {
								
								breakOut "guard1";
							};
						sleep 3;
						};
					};
				};
			};

			// Armored guards
			for "_i" from 0 to ((count (call BIS_fnc_listPlayers)) * 0.067) do {
				if (random 100 < 50) then {
					_pos = [_loc, 0, 250, 1, 0, 1, 0] call BIS_fnc_findSafePos;
					if (supplier == "BLU") then {
						_car = (selectRandom (INS_APC_BLU + INS_IFV_BLU + INS_TANK_BLU)) createVehicle _pos;
						if (typeOf _car in INS_APC_BLU) then {
							[
								_car,
								missionNamespace getVariable ["INS_APC_BLU_TEX", nil],
								missionNamespace getVariable ["INS_APC_BLU_ANI", nil]
							] call BIS_fnc_initVehicle;
						};
						if (typeOf _car in INS_IFV_BLU) then {
							[
								_car,
								missionNamespace getVariable ["INS_IFV_BLU_TEX", nil],
								missionNamespace getVariable ["INS_IFV_BLU_ANI", nil]
							] call BIS_fnc_initVehicle;
						};
						if (typeOf _car in INS_TANK_BLU) then {
							[
								_car,
								missionNamespace getVariable ["INS_TANK_BLU_TEX", nil],
								missionNamespace getVariable ["INS_TANK_BLU_ANI", nil]
							] call BIS_fnc_initVehicle;
						};
					} else {
						_car = (selectRandom (INS_APC_OPF + INS_IFV_OPF + INS_TANK_OPF)) createVehicle _pos;
						if (typeOf _car in INS_APC_OPF) then {
							[
								_car,
								missionNamespace getVariable ["INS_APC_OPF_TEX", nil],
								missionNamespace getVariable ["INS_APC_OPF_ANI", nil]
							] call BIS_fnc_initVehicle;
						};
						if (typeOf _car in INS_IFV_OPF) then {
							[
								_car,
								missionNamespace getVariable ["INS_IFV_OPF_TEX", nil],
								missionNamespace getVariable ["INS_IFV_OPF_ANI", nil]
							] call BIS_fnc_initVehicle;
						};
						if (typeOf _car in INS_TANK_OPF) then {
							[
								_car,
								missionNamespace getVariable ["INS_TANK_OPF_TEX", nil],
								missionNamespace getVariable ["INS_TANK_OPF_ANI", nil]
							] call BIS_fnc_initVehicle;
						};
					};
					_car lock 3;
					clearBackpackCargoGlobal _car;
					clearMagazineCargoGlobal _car;
					clearWeaponCargoGlobal _car;
					clearItemCargoGlobal _car;	
					_group = [
						_pos, 
						INDEPENDENT, 
						[
							(selectRandom INS_INF_SINGLE),
							(selectRandom INS_INF_SINGLE),
							(selectRandom INS_INF_SINGLE)
						]
					] call BIS_fnc_spawnGroup;
						(units _group select 0) assignAsDriver _car;
						(units _group select 1) assignAsGunner _car;
						(units _group select 2) assignAsCommander _car;
					[units _group] call InA_fnc_insCustomize;
					[_group,_pos,_car] spawn {
						while {true} do {
							scopeName "guard3";
							if (spotted) then {
								_wp = (_this select 0) addWaypoint [(_this select 1),0];
								_wp waypointAttachVehicle (_this select 3);
								_wp setWaypointType "GETIN";
							
								[(_this select 0), (_this select 1)] call BIS_fnc_taskDefend;
								breakOut "guard3";
							};
							
							if (!alive (_this select 3) || count units (_this select 0) < 2) then {
								
								breakOut "guard3";
							};
							
						sleep 3;
						};
					};
				};
			};

			// Small patrols
			for "_i" from 0 to (round random 4) do {
				if (random 100 < random 50) then {
					_pos = [_loc, 0, 500, 0, 0, 50, 0] call BIS_fnc_findSafePos;

					_troops = [];
					for "_i" from 1 to (round random 4) do {

						_troops pushBack (selectRandom INS_INF_SINGLE);
					};

					_group = [
					_pos, 
					INDEPENDENT,
					_troops
				] call BIS_fnc_spawnGroup;
					[_group, _pos, 450] call BIS_fnc_taskPatrol;
					[units _group] call InA_fnc_insCustomize;
				};
			};

			// Find nearest houses
			_buildings = nearestTerrainObjects [
				_loc, 
				[
					"HOUSE",
					"HOSPITAL",
					"FUELSTATION"
				], 
				500
			];

			// Garrison buildings
			_array = [];
			{
				_bldg = [_x] call BIS_fnc_buildingPositions;
				_array = _array + _bldg;
			} forEach _buildings;

			{
				if (random 100 < 10) then {
					
					_group = [
						_x, 
						INDEPENDENT, 
						[
							(selectRandom INS_INF_SINGLE)
						]
					] call BIS_fnc_spawnGroup;
					_group setFormDir (random 360);
					[_group, _x] call BIS_fnc_taskDefend;
					[units _group] call InA_fnc_insCustomize;
					
				};
			} forEach _array;

		///////////////////////
		// END MISSION SPAWN //
		///////////////////////

		// enemies cleared trigger spawn
		_nme = createTrigger ["EmptyDetector",_loc];
		_nme setTriggerArea [1000,1000, 0, false];
		_nme setTriggerActivation ["GUER", "NOT PRESENT", false];
		_nme setTriggerStatements ["this","",""];

		// No reinforcements have been called yet
		_called = false;

		// near AO pause loop
		while {true;} do {
			scopeName "pause";

			sleep (2 + (random 2));

			// Check if players are in AO
			if ({_x distance _loc < mainLimit} count (allPlayers - entities "HeadlessClient_F") > 0) then {

				// Reinforcement call if spotted
				if ((spotted) && {!_called}) then {
					[_loc] call InA_fnc_reinforcementCall;
					_called = true;
				};

				// Objective completion condition
				if (count list _nme < 20) then {

					deleteVehicle _nme;
					_cleared = true;
					compObj = compObj + 1;
					LogV = LogV + 6;
					LogM = LogM + (50 + (round random 100));
					concentrations = concentrations - _loc;

					[] spawn {

						sleep 172800;

						InA_stronghold = false;

					};
				
					["INSURGENT STRONGHOLD", "The insurgents concentrated here have been mostly routed."] remoteExec ["FF7_fnc_formatHint", 0];

					breakOut "pause";

					sleep 10;

					["INSURGENT STRONGHOLD", "Supplies have been appropriated from the insurgent stronghold."] remoteExec ["FF7_fnc_formatHint", 0];
				};
			};

			// Cleanup
			if ({_x distance _loc < mainLimit} count (allPlayers - entities "HeadlessClient_F") < 1) then {

				[_loc, (mainLimit - 500)] spawn InA_fnc_cleanup;

				deleteVehicle _nme;

				breakOut "pause";
			};
		};
	};
};

///////////////////////////////////////
// ---------- END AO LOOP ---------- //
///////////////////////////////////////