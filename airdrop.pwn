#include <a_samp>

#define FILTERSCRIPTS

#if defined FILTERSCRIPTS

public OnFilterScriptInit()
{
	printf("Airdrop system successfully.");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#endif

#define MAX_DROPS (10)
#define COLOR_DROP (0) // Değeri 0'dan farklı yaparsanız girdiğiniz obje modelinde drop düşer. Örneğin: 19332.
#define DROP_SPEED (6.5) // Düşecek drop'un düşme hızıdır.

enum E_DROP {
	dropID,
	dropExists,
	Float:dropPos[4],
	dropActive,
	dropWeapon[5],
	dropAmmo[5],
	dropSkin,
	dropHealth,
	dropArmor,
	dropObject
};

new DropInfo[MAX_DROPS][E_DROP];

enum e_dropSpawn {
	Float:dropX,
	Float:dropY,
	Float:dropZ
};

static const Float:g_arrDropSpawn[][e_dropSpawn] = {
	{340.6458,-1486.5393,76.5391} // Random spawn olucak airdrop'ların X, Y, Z koordinatlarını girin.
};

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/createdrop", true))
	{
		for(new i = 0; i < MAX_DROPS; i++) if(!DropInfo[i][dropExists])
		{
			#if !COLOR_DROP
				DropInfo[i][dropID] = i;
				DropInfo[i][dropExists] = 1;
				DropInfo[i][dropActive] = 0;
				GetRandomWeapon(i);
				DropInfo[i][dropHealth] = 1;
				DropInfo[i][dropArmor] = 1;
				DropInfo[i][dropSkin] = random(312);
				
				new rand = random(sizeof(g_arrDropSpawn));
				DropInfo[i][dropPos][0] = g_arrDropSpawn[rand][dropX];
				DropInfo[i][dropPos][1] = g_arrDropSpawn[rand][dropY];
				DropInfo[i][dropPos][2] = g_arrDropSpawn[rand][dropZ];
				DropInfo[i][dropObject] = CreateObject(DropObject(), DropInfo[i][dropPos][0], DropInfo[i][dropPos][1], DropInfo[i][dropPos][2]+300, 0, 0, 0);
				MoveObject(DropInfo[i][dropObject], DropInfo[i][dropPos][0], DropInfo[i][dropPos][1], DropInfo[i][dropPos][2]-1, DROP_SPEED);
			#else
			#if (COLOR_DROP != 19332) && (COLOR_DROP != 19333) && (COLOR_DROP != 19334) && (COLOR_DROP != 19335) \
			 && (COLOR_DROP != 19336) && (COLOR_DROP != 19337) && (COLOR_DROP != 19338)
				#error Kullanilabilir drop modelleri icin "https://github.com/cngznNN/drop" adresini ziyaret edin!
				return SendClientMessage(playerid, -1, "Bir hata meydana geldi, yöneticiye haber verin.");
			#else
				DropInfo[i][dropID] = i;
				DropInfo[i][dropExists] = 1;
				DropInfo[i][dropActive] = 0;
				GetRandomWeapon(i);
				DropInfo[i][dropHealth] = 1;
				DropInfo[i][dropArmor] = 1;
				DropInfo[i][dropSkin] = random(312);
				
				new rand = random(sizeof(g_arrDropSpawn));
				DropInfo[i][dropPos][0] = g_arrDropSpawn[rand][dropX];
				DropInfo[i][dropPos][1] = g_arrDropSpawn[rand][dropY];
				DropInfo[i][dropPos][2] = g_arrDropSpawn[rand][dropZ];
				DropInfo[i][dropObject] = CreateObject(COLOR_DROP, DropInfo[i][dropPos][0], DropInfo[i][dropPos][1], DropInfo[i][dropPos][2]+300, 0, 0, 0);
				MoveObject(DropInfo[i][dropObject], DropInfo[i][dropPos][0], DropInfo[i][dropPos][1], DropInfo[i][dropPos][2]-1, DROP_SPEED);
			#endif
			#endif
			break;
		}
		return 1;
	}
	else if(!strcmp(cmdtext, "/drop", true))
	{
		new id = -1;
		if((id = Nearest_AirDrop(playerid)) != -1)
		{
		
			new string[128];
			format(string, sizeof(string), "Silahlar\n%s\n%s\n%s", (!DropInfo[id][dropHealth]) ? ("Boş Slot") : ("Sağlık"), (!DropInfo[id][dropArmor]) ? ("Boş Slot") : ("Çelik Yelek"),
			(DropInfo[id][dropSkin] == -1) ? ("Boş Slot") : ("Skin"));
			ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, "Airdrop", string, "Seç", "İptal");
			SetPVarInt(playerid, "DropID", id);
		}
		else SendClientMessage(playerid, -1, "Airdrop yakınlarında değilsiniz.");
		
		return 1;
	}
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == 100)
	{
		new id = GetPVarInt(playerid, "DropID");
		if(response)
		{
			GivePlayerWeapon(playerid, DropInfo[id][dropWeapon][listitem], DropInfo[id][dropAmmo][listitem]);
			DropInfo[id][dropWeapon][listitem] = 0;
			DropInfo[id][dropAmmo][listitem] = 0;
			DeletePVar(playerid, "DropID");
		}
		else
		{	
			new string[128];
			format(string, sizeof(string), "Silahlar\n%s\n%s\n%s", (!DropInfo[id][dropHealth]) ? ("Boş Slot") : ("Sağlık"), (!DropInfo[id][dropArmor]) ? ("Boş Slot") : ("Çelik Yelek"),
			(DropInfo[id][dropSkin] == -1) ? ("Boş Slot") : ("Skin"));
			ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, "Airdrop", string, "Seç", "İptal");
		}
		return 1;
	}
	if(dialogid == 0)
	{
		new id = GetPVarInt(playerid, "DropID");
		if(response)
		{
			if(!strcmp(inputtext, "Boş Slot"))
				return 0;
			
			switch(listitem)
			{
				case 0:
				{
					new string[512];
					string = "Silah\tCephane\n";
					for(new i = 0; i < 5; i++)
					{
						if(!DropInfo[id][dropWeapon][i])
							format(string, sizeof(string), "%sBoş Slot\n", string);
						else {
						format(string, sizeof(string), "%s%s\t%i\n",string, GetWeaponNameEx(DropInfo[id][dropWeapon][i]), DropInfo[id][dropAmmo][i]);
						}
					}
					ShowPlayerDialog(playerid, 100, DIALOG_STYLE_TABLIST_HEADERS, "Airdrop - Silahlar", string, "Seç", "Geri");
				}
				case 1:
					SetPlayerHealth(playerid, 100), DropInfo[id][dropHealth] = 0;
				case 2:
					SetPlayerArmour(playerid, 100), DropInfo[id][dropArmor] = 0;
				case 3:
					SetPlayerSkin(playerid, DropInfo[id][dropSkin]), DropInfo[id][dropSkin] = -1;
			}
		}
		DeletePVar(playerid, "DropID");
		return 1;
	}
	return 0;
}

stock GetWeaponNameEx(wid)
{
	new gunname[32];
	switch (wid)
	{
		case 	1 .. 17, 22 .. 43,  46 :  GetWeaponName(wid,gunname,sizeof(gunname));
		case 	0:		format(gunname,32,"%s","Fist");
		case 	18:	format(gunname,32,"%s","Molotov Cocktail");
		case 	44:	format(gunname,32,"%s","Night Vis Goggles");
		case 	45:	format(gunname,32,"%s","Thermal Goggles");
		default:	format(gunname,32,"%s","Invalid Weapon Id");
	
	}
	return gunname;
}

stock Nearest_AirDrop(playerid, Float:radius=3.0)
{
	new Float:x, Float:y, Float:z;
	for(new i = 0; i < MAX_DROPS; i++) if(DropInfo[i][dropExists])
	{
		GetObjectPos(DropInfo[i][dropObject], x, y, z);
		if(IsPlayerInRangeOfPoint(playerid, radius, x, y, z) && GetPlayerInterior(playerid) == 0)
			return i;
	}
	return -1;
}

public OnObjectMoved(objectid)
{
	for(new i = 0; i < MAX_DROPS; i++)
	{
		if(objectid == DropInfo[i][dropObject])
			DropInfo[i][dropActive] = 1;
	}
	return 1;
}

stock DropObject()
{
	new object = random(7);
	switch(object)
	{
		case 0: object = 19337;
		case 1: object = 19335;
		case 2: object = 19332;
		case 3: object = 19333;
		case 4: object = 19334;
		case 5: object = 19336;
		case 6: object = 19338;
	}
	return object;
}

stock GetRandomWeapon(dropid)
{
	new random1 = RandomEx(22, 24);
	new random2 = RandomEx(25, 27);
	new random3 = RandomEx(28, 31);
	new random4 = RandomEx(32, 34);
	new random5 = RandomEx(35, 38);
	
	new arandom1 = RandomEx(75, 500);
	new arandom2 = RandomEx(75, 500);
	new arandom3 = RandomEx(75, 500);
	new arandom4 = RandomEx(75, 500);
	new arandom5 = RandomEx(75, 500);
	
	DropInfo[dropid][dropWeapon][0] = random1;
	DropInfo[dropid][dropWeapon][1] = random2;
	DropInfo[dropid][dropWeapon][2] = random3;
	DropInfo[dropid][dropWeapon][3] = random4;
	DropInfo[dropid][dropWeapon][4] = random5;
	
	DropInfo[dropid][dropAmmo][0] = arandom1;
	DropInfo[dropid][dropAmmo][1] = arandom2;
	DropInfo[dropid][dropAmmo][2] = arandom3;
	DropInfo[dropid][dropAmmo][3] = arandom4;
	DropInfo[dropid][dropAmmo][4] = arandom5;
	return 1;
}

stock RandomEx(min, max)
{
	new rand = random(max-min+1)+min;
	return rand;
}

// Code by cngznNN
