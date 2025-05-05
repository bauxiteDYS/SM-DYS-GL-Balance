#pragma semicolon 1
#pragma newdecls required

#include <sdktools>
#include <sdkhooks>
#include <dhooks>


// default radius 225 damage 85

static bool _late_load;

float g_spawnTime[2048];
bool g_fullDamage[2048];

public Plugin myinfo = {
	name = "Dys GL balance",
	description = "Modifies GL to be a bit more balanced",
	author = "bauxite",
	version = "0.1.0",
	url = "",
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	_late_load = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	if (_late_load)
	{
		for (int client = 1; client <= MaxClients; ++client)
		{
			if (!IsClientInGame(client))
			{
				continue;
			}
			if (!SDKHookEx(client, SDKHook_OnTakeDamage, OnTakeDamage))
			{
				ThrowError("Failed to SDKHook");
			}
			else
			{
				PrintToServer("Hook ok!");
			}
		}
	}
}

public void OnClientPutInServer(int client)
{
	if (!SDKHookEx(client, SDKHook_OnTakeDamage, OnTakeDamage))
	{
		ThrowError("Failed to SDKHook");
	}
}

public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3])
{	
	/*
	PrintToServer("victim %d", victim);
	PrintToServer("attacker %d", attacker);
	PrintToServer("inflictor %d", inflictor);
	PrintToServer("damage %f", damage);
	*/
	
	if (!IsValidEntity(inflictor))
	{
		return Plugin_Continue;
	}
	
	char sWeapon[16 + 1];

	if (!GetEntityClassname(inflictor, sWeapon, sizeof(sWeapon)))
	{
		return Plugin_Continue;
	}
	
	if (!StrEqual(sWeapon,"launcher_grenade"))
	{
		return Plugin_Continue;
	}
	
	if(victim == attacker)
	{
		return Plugin_Continue;
	}
	
	if(!g_fullDamage[inflictor])
	{
		damage = 61.0;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(!IsValidEntity(entity))
	{
		return;
	}
	
	if(StrEqual(classname, "launcher_grenade", false))
	{
		SDKHook(entity, SDKHook_Spawn, OnNadeSpawn);
	}
}

Action OnNadeSpawn(int entity)
{
	g_spawnTime[entity] = GetGameTime();
	g_fullDamage[entity] = false;
	
	CreateTimer(0.3, SetNadeDamage, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Continue;
}

public Action SetNadeDamage(Handle timer, int entRef)
{
	int entity = EntRefToEntIndex(entRef);
	
	if(!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	
	g_fullDamage[entity] = true;
	
	return Plugin_Stop;
}
