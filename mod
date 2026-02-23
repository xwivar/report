#include <open.mp>
#include <Pawn.CMD>

/*
     ___      _
    / __| ___| |_ _  _ _ __
    \__ \/ -_)  _| || | '_ \
    |___/\___|\__|\_,_| .__/
                      |_|
*/


#pragma dynamic 65536





















#define MAX_REPORTS 9
#define REPORTS_PER_PAGE 3

enum DialogIDs {
    DIALOG_NONE,
    DIALOG_REPORT,
    DIALOG_REPORTS,
    DIALOG_MANAGE_REPORT
}

enum Report {
    bool:rExists,
    rAuthor,
    rText[128]
};


new reports[MAX_REPORTS][Report];

new playerReports[MAX_PLAYERS][REPORTS_PER_PAGE];
new playerReportsPage[MAX_PLAYERS];
new playerCurrentReport[MAX_PLAYERS];
new reportsQueue[MAX_REPORTS];
new reportsAmount;

cmd:report(playerid) {
    ShowPlayerDialog(playerid, DIALOG_REPORT, DIALOG_STYLE_INPUT, "Репорт", "Напишите свой репорт:", "Отправить", "Отмена");
}

stock ShowPlayerReportsDialog(playerid, page) {
    if (reportsAmount <= REPORTS_PER_PAGE * page) {
        if (reportsAmount && page) 
            return ShowPlayerReportsDialog(playerid, page - 1)
        return SendClientMessage(playerid, -1, "Больше нет репортов");
    }
    new str[4096];
    if (page != 0) 
        strcat(str, "Предыдущая страница\n");
        
    playerReportsPage[playerid] = page;

    for (new i = page * REPORTS_PER_PAGE, j = 0; i < reportsAmount && i < REPORTS_PER_PAGE * (page + 1); j++, i++) {
        new report = reportsQueue[i];
        new name[MAX_PLAYER_NAME];
        GetPlayerName(reports[report][rAuthor], name);
        playerReports[playerid][j] = reportsQueue[i];
        format(str, sizeof(str), "%s%s\t%s\n", str, name, reports[report][rText]);
    }
    
    if (reportsAmount > (page + 1) * REPORTS_PER_PAGE) strcat(str, "Следующая страница");
    return ShowPlayerDialog(playerid, DIALOG_REPORTS, DIALOG_STYLE_LIST, "Репорты", str, "Выбор", "Отмена");
}

cmd:reports(playerid) {
    ShowPlayerReportsDialog(playerid, 0);
}

stock TryCreateReport(playerid, text[]) {
    if (reportsAmount == MAX_REPORTS) return false;

    for (new i = 0; i < MAX_REPORTS; i++)
        if(!reports[i][rExists]) {
            reports[i][rAuthor] = playerid;
            format(reports[i][rText], 128, "%s", text);
            reports[i][rExists] = true;
            reportsQueue[reportsAmount] = i;
            reportsAmount++;
            return true;
    }
    return false;
}

stock DeleteReport(reportid) {
    new reportidx;
    reports[reportid][rExists] = false;
    for (;reportidx < MAX_REPORTS; reportidx++) {
        if (reportsQueue[reportidx] == reportid) {
            break;
        }
    }

    for (new i = reportidx; i < reportsAmount - 1; i++) {
        reportsQueue[i] = reportsQueue[i + 1];
    }

    reportsAmount--;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    for (new i = 0; i < strlen(inputtext); i++)
        if (inputtext[i] == '%')
            inputtext[i] = '#';
    
    switch(dialogid) {
        case DIALOG_REPORT: {
            if (!response) return 1;
            if (!strlen(inputtext)) return SendClientMessage(playerid, -1, "Напишите что-нибудь");
            if (!TryCreateReport(playerid, inputtext)) return SendClientMessage(playerid, -1, "Не удалось создать репорт");
            return SendClientMessage(playerid, -1, "Успешно создан репорт");
        }
        case DIALOG_REPORTS: {
            if (!response) return 1;
            if (listitem == 0 && playerReportsPage[playerid] != 0) return ShowPlayerReportsDialog(playerid, playerReportsPage[playerid] - 1);
            if (listitem == REPORTS_PER_PAGE && playerReportsPage[playerid] == 0 || listitem == REPORTS_PER_PAGE + 1 && playerReportsPage[playerid] != 0) return ShowPlayerReportsDialog(playerid, playerReportsPage[playerid] + 1);
            
            new chosenReport = reportsQueue[(playerReportsPage[playerid] == 0 ? listitem : listitem - 1) + playerReportsPage[playerid] * REPORTS_PER_PAGE];
            if (!reports[chosenReport][rExists]) return ShowPlayerReportsDialog(playerid, playerReportsPage[playerid]);
            playerCurrentReport[playerid] = chosenReport;
            return ShowPlayerDialog(playerid, DIALOG_MANAGE_REPORT, DIALOG_STYLE_INPUT, "Title", reports[chosenReport][rText], "Ответ", "Отмена");
        }
        case DIALOG_MANAGE_REPORT: {
            if (!response) return 1;
            
            SendClientMessage(reports[playerCurrentReport[playerid]][rAuthor], -1, "Вам ответили:");
            SendClientMessage(reports[playerCurrentReport[playerid]][rAuthor], -1, inputtext);
            DeleteReport(playerCurrentReport[playerid]);
            return ShowPlayerReportsDialog(playerid, playerReportsPage[playerid]);
        }
    }
	return 1;
}

stock DeletePlayerReports(playerid) {
    for (new i = 0; i < MAX_REPORTS; i++) 
        if(reports[i][rAuthor] == playerid && reports[i][rExists])
            DeleteReport(i);
}

public OnPlayerDisconnect(playerid, reason)
{
    DeletePlayerReports(playerid)
	return 1;
}




















main()
{
	printf("123");
	printf("  -------------------------------");
	printf("  |  My first open.mp gamemode! |");
	printf("  -------------------------------");
	printf(" ");
}

public OnGameModeInit()
{
	SetGameModeText("My first open.mp gamemode!");
	AddPlayerClass(0, 2495.3547, -1688.2319, 13.6774, 351.1646, WEAPON_M4, 500, WEAPON_KNIFE, 1, WEAPON_COLT45, 100);
	AddStaticVehicle(522, 2493.7583, -1683.6482, 12.9099, 270.8069, -1, -1);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

/*
      ___
     / __|___ _ __  _ __  ___ _ _
    | (__/ _ \ '  \| '  \/ _ \ ' \
     \___\___/_|_|_|_|_|_\___/_||_|

*/

public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 217.8511, -98.4865, 1005.2578);
	SetPlayerFacingAngle(playerid, 113.8861);
	SetPlayerInterior(playerid, 15);
	SetPlayerCameraPos(playerid, 215.2182, -99.5546, 1006.4);
	SetPlayerCameraLookAt(playerid, 217.8511, -98.4865, 1005.2578);
	ApplyAnimation(playerid, "benchpress", "gym_bp_celebrate", 4.1, true, false, false, false, 0, SYNC_NONE);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerInterior(playerid, 0);
	return 1;
}

public OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

/*
     ___              _      _ _    _
    / __|_ __  ___ __(_)__ _| (_)__| |_
    \__ \ '_ \/ -_) _| / _` | | (_-<  _|
    |___/ .__/\___\__|_\__,_|_|_/__/\__|
        |_|
*/

public OnFilterScriptInit()
{
	printf(" ");
	printf("  -----------------------------------------");
	printf("  |  Error: Script was loaded incorrectly |");
	printf("  -----------------------------------------");
	printf(" ");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
	return 1;
}

public OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerGiveDamageActor(playerid, damaged_actorid, Float:amount, WEAPON:weaponid, bodypart)
{
	return 1;
}

public OnActorStreamIn(actorid, forplayerid)
{
	return 1;
}

public OnActorStreamOut(actorid, forplayerid)
{
	return 1;
}

public OnPlayerEnterGangZone(playerid, zoneid)
{
	return 1;
}

public OnPlayerLeaveGangZone(playerid, zoneid)
{
	return 1;
}

public OnPlayerEnterPlayerGangZone(playerid, zoneid)
{
	return 1;
}

public OnPlayerLeavePlayerGangZone(playerid, zoneid)
{
	return 1;
}

public OnPlayerClickGangZone(playerid, zoneid)
{
	return 1;
}

public OnPlayerClickPlayerGangZone(playerid, zoneid)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnClientCheckResponse(playerid, actionid, memaddr, retndata)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerFinishedDownloading(playerid, virtualworld)
{
	return 1;
}

public OnPlayerRequestDownload(playerid, DOWNLOAD_REQUEST:type, crc)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 0;
}

public OnPlayerSelectObject(playerid, SELECT_OBJECT:type, objectid, modelid, Float:fX, Float:fY, Float:fZ)
{
	return 1;
}

public OnPlayerEditObject(playerid, playerobject, objectid, EDIT_RESPONSE:response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	return 1;
}

public OnPlayerEditAttachedObject(playerid, EDIT_RESPONSE:response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnPlayerPickUpPlayerPickup(playerid, pickupid)
{
	return 1;
}

public OnPickupStreamIn(pickupid, playerid)
{
	return 1;
}

public OnPickupStreamOut(pickupid, playerid)
{
	return 1;
}

public OnPlayerPickupStreamIn(pickupid, playerid)
{
	return 1;
}

public OnPlayerPickupStreamOut(pickupid, playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)
{
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart)
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, CLICK_SOURCE:source)
{
	return 1;
}

public OnPlayerWeaponShot(playerid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	return 1;
}

public OnIncomingConnection(playerid, ip_address[], port)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	return 1;
}

public OnTrailerUpdate(playerid, vehicleid)
{
	return 1;
}

public OnVehicleSirenStateChange(playerid, vehicleid, newstate)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnEnterExitModShop(playerid, enterexit, interiorid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	return 1;
}

public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z)
{
	return 1;
}
