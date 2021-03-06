/* ----------
Function:
	InA_fnc_majorActivity

Description:
	spawns a hideout AO on the map

Parameters:

Optional:

Example:
	[] spawn InA_fnc_majorActivity;

Returns:
	Nil

Author:
	[FF7] Newsparta
---------- */

// Local declarations
private		_accepted		= false;
private		_loc			= [];
private		_pos			= [];
private		_isNearPlayer	= false;
private		_isNearLoc		= false;
private		_cleared		= false;
private		_i				= 0;
private		_addSome		= 0;
private 	_troops			= [];
private		_group			= [];
private		_choice			= nil;
private		_car			= ObjNull;
private		_wp				= nil;
private		_nme			= nil;

/////////////////////////////////////////////////
// ---------- BEGIN LOCATION FINDER ---------- //
/////////////////////////////////////////////////

// Location selection loop
while {!_accepted;} do {

	// Select random position
	_pos = [[[mapCenter,mapSize]],["water","out"]] call BIS_fnc_randomPos;
	_loc = _pos isFlatEmpty [5, 0, 0.6, 5, 0, false];
	
	// Check to see if location is valid
	if (count _loc > 2) then {
		
		// Check if players are near
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
};

///////////////////////////////////////////////
// ---------- END LOCATION FINDER ---------- //
///////////////////////////////////////////////

// Declare AO active
activeLocations = activeLocations + 1;

// Enter location into AO array
concentrations pushBack _loc;

/////////////////////////////////////////
// ---------- BEGIN AO LOOP ---------- //
/////////////////////////////////////////

while {!_cleared;} do {

	sleep (2 + (random 2));

	// Increment timer for automatic AO location migration
	_i = _i + 1;

	// Automatic location clearing
	if (_i >= 14400) then {
		_cleared = true;
		activeLocations = activeLocations - 1;
		concentrations = concentrations - _loc;
	};

	// Check if players are near
	if ({_x distance _loc < mainLimit} count (allPlayers - entities "HeadlessClient_F") > 0) then {

		/////////////////////////
		// BEGIN MISSION SPAWN //
		/////////////////////////

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

		///////////////////////
		// END MISSION SPAWN //
		///////////////////////

		// Enemies cleared trigger spawn
		_nme = createTrigger ["EmptyDetector",_loc];
		_nme setTriggerArea [1000,1000, 0, false];
		_nme setTriggerActivation ["GUER", "NOT PRESENT", false];
		_nme setTriggerStatements ["this","",""];

		// Near AO pause loop
		while {true} do {
			scopeName "activity";

			sleep (2 + (random 2));

			// Check if players are in AO
			if ({_x distance _loc < mainLimit} count (allPlayers - entities "HeadlessClient_F") > 0) then {

				// Objection completion condition
				if (count list _nme < 20) then {

					deleteVehicle _nme;
					_cleared = true;
					activeLocations = activeLocations - 1;
					compObj = compObj + 1;
					LogV = LogV + 3;
					concentrations = concentrations - _loc;
				
					["INSURGENT HIDEOUT", "The insurgents concentrated here have been mostly routed."] remoteExec ["FF7_fnc_formatHint", 0];

					breakOut "activity";
				};
			};

			// Cleanup
			if ({_x distance _loc < mainLimit} count (allPlayers - entities "HeadlessClient_F") < 1) then {

				[_loc, (mainLimit - 500)] spawn InA_fnc_cleanup;

				deleteVehicle _nme;

				_active = false;

				breakOut "activity";
			};

		};
	};
};

///////////////////////////////////////
// ---------- END AO LOOP ---------- //
///////////////////////////////////////