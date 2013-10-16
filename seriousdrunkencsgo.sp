#include <sourcemod>

public Plugin:myinfo =
{
	name = "Serious Drunken CSGO",
	author = "Simon Carpentier (SPACEBAR)",
	description = "Counter-Strike GO: The Drinking Game",
	version = "1.0",
	url = "http://spacebar.ca/"
};

new playerSip[MAXPLAYERS + 1]; // This index starts at 1.

public OnPluginStart() {
	PrintToServer("Serious Drunken CSGO!");
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Post);
	HookEvent("round_mvp", Event_RoundMvp, EventHookMode_Pre);
	LogMessage("[SeriousDrunkenCSGO] - Loaded");
}

public AddSipToClient(client, sips, String:message[]) {
	playerSip[client] = playerSip[client] + sips;
	PrintToChat(client, "%s That's %d sips!. Total this round: %d", message, sips, playerSip[client]);
}

public AddSipToUserId(userId, sips, String:message[]) {
	AddSipToClient(GetClientOfUserId(userId), sips, message);
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victimId = GetEventInt(event, "userid");
	new attackerId = GetEventInt(event, "attacker");

	if (victimId == attackerId)
	{
		// Death by suicide does not award any sips
		return;
	}
	
	decl String:weaponName[12];
	GetEventString(event, "weapon", weaponName, sizeof(weaponName))
	
	decl String:name[64];
	new victim = GetClientOfUserId(victimId);
	new attacker = GetClientOfUserId(attackerId);
	GetClientName(victim, name, sizeof(name));
	
	if(strcmp(weaponName, "knife") == 0) {
		AddSipToUserId(attackerId, 5, "You killed with a knife!");
	}
	else if (GetEventBool(event, "headshot")) {
		AddSipToUserId(attackerId, 2, "You killed with a headshot!");
	}	
	else {
		AddSipToUserId(attackerId, 1, "You killed!");
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
		if(IsClientInGame(i) && !IsFakeClient(i)) {
			new client = GetClientUserId(i);
						
			if (GetClientTeam(i) == winningTeamId) {
				AddSipToClient(client, 1, "You won the game!");
			}
			
			if (playerSip[i] != 0) {
				totalSips = totalSips + playerSip[i];
				decl String:name[64];
				GetClientName(i, name, sizeof(name));
				
				PrintToChat(client, "You have to take %d sips this round", playerSip[i]);
				PrintToChatAll("%s has to drink %d sip(s)", name, playerSip[i]);
			}
		}
	}
	PrintToChatAll("A total of %d sips were taken this round", totalSips);
}

public Event_RoundMvp(Handle:event, const String:name[], bool:dontBroadcast) {
	AddSipToUserId(GetEventInt(event, "userid"), 1, "You're the MVP!");
}
