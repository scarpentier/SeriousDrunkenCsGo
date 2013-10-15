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
		PrintToChat(attacker, "You killed \"%s\" with a knife! That's 5 sips!", name);
	}
	else if (GetEventBool(event, "headshot")) {
		AddSipToUserId(attackerId, 2);
		PrintToChat(attacker, "You killed \"%s\" with a headshot! That's 2 sips!", name);
	}	
	else {
		AddSipToUserId(attackerId, 1);
		PrintToChat(attacker, "You killed \"%s\"! That's 1 sip!", name);
	}
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast) {
	// Reset sip count
	for(new i = 1; i <= MaxClients; i++) {
		playerSip[i] = 0;
	}
}

public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast) {
	new winningTeamId = GetEventInt(event, "winner");

	// Distribute winning sips
	// Print total sips and for each player
	new totalSips = 0;
	for(new i = 1; i <= MaxClients; i++) {
		if (GetClientTeam(GetClientOfUserId(i)) == winningTeamId) {
			playerSip[i] += 1;
		}
	
		if (playerSip[i] != 0) {
			decl String:name[64];
			new client = GetClientOfUserId(i);
			GetClientName(client, name, sizeof(name));
			
			PrintToChat(client, "You have to take %s sips this round", playerSip[i]);
			//PrintToChatAll("%s has to drink %s sip(s)", name, playerSip[i]);			
		}
	}
	PrintToChatAll("A total of %s sips were taken this round", totalSips);
}

public Event_RoundMvp(Handle:event, const String:name[], bool:dontBroadcast) {
	AddSipToUserId(GetEventInt(event, "userid"), 1);
}
