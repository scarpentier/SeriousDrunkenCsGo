#include <sourcemod>

public Plugin:myinfo =
{
	name = "Serious Drunken CSGO",
	author = "Simon Carpentier (SPACEBAR)",
	description = "Counter-Strike GO: The Drinking Game",
	version = "1.0",
	url = "http://spacebar.ca/"
};

new playerSip[MAXPLAYERS + 1]; // This index starts at 1

public OnPluginStart() {
	PrintToServer("Serious Drunken CSGO!");
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Post);
	HookEvent("round_mvp", Event_RoundMvp, EventHookMode_Pre);
	LogMessage("[SeriousDrunkenCSGO] - Loaded");
}

public AddSipToUserId(userId, sips) {
	playerSip[GetClientOfUserId(userId)] += sips;
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:weaponName[12];
	GetEventString(event, "weapon", weaponName, sizeof(weaponName))

	new victimId = GetEventInt(event, "userid");
	new attackerId = GetEventInt(event, "attacker");

	decl String:name[64];
	new victim = GetClientOfUserId(victimId);
	new attacker = GetClientOfUserId(attackerId);
	GetClientName(victim, name, sizeof(name));
	
	if(strcmp(weaponName, "knife") == 0) {
		AddSipToUserId(attackerId, 5);
		PrintToConsole(attacker, "You killed \"%s\" with a knife! That's 5 sips!", name);
	}
	else if (GetEventBool(event, "headshot")) {
		AddSipToUserId(attackerId, 2);
		PrintToConsole(attacker, "You killed \"%s\" with a headshot! That's 2 sips!", name);
	}	
	else {
		AddSipToUserId(attackerId, 1);
		PrintToConsole(attacker, "You killed \"%s\"! That's 1 sip!", name);
	}
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast) {
	// Reset sip count
	for(new i = 1; i <= MaxClients; i++) {
		playerSip[i] = 0;
	}
}

public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast) {
	// Distribute winning sips
	new winningTeamId = GetEventInt(event, "winner");
	for(new i = 1; i <= MaxClients; i++) {
		if (GetClientTeam(GetClientOfUserId(i)) == winningTeamId) {
			playerSip[i] += 1;
		}
	}

	// Print total sips
	new totalSips = 0;
	for(new i = 1; i <= MaxClients; i++) {
		if (playerSip[i] != 0) {
			decl String:name[64];
			GetClientName(GetClientOfUserId(i), name, sizeof(name));
			PrintToChatAll("%s has to drink %s sip(s)", name, playerSip[i]);
		}
	}
}

public Event_RoundMvp(Handle:event, const String:name[], bool:dontBroadcast) {
	AddSipToUserId(GetEventInt(event, "userid"), 1);
}
