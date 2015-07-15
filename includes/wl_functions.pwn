/*
	Copyright (C) 2015  Mansur "#WASD" Taukenov
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
stock NewKick(playerid, reason[], color = COLOR_LIGHTRED) {
	if(!IsPlayerNPC(playerid)) {
		if(GetPVarInt(playerid, "kicked") == 1) return 1;
		SendClientMessage(playerid, color, reason);
		SetPVarInt(playerid, "kicked", 1);
		#if defined TM_DEBUG
			printf("[Античит]: %s (%d) был кикнут. Причина: %s",NamePlayer(playerid),playerid,reason);
		#endif
		SetTimerEx("KickPublic", 200, false, "d", playerid);
	}
	return 1;
}
t_SetPlayerPos(playerid, Float:x, Float:y, Float:z) {
	SetPlayerPos(playerid, x, y, z);
	PI[playerid][pPos][0] = x;
	PI[playerid][pPos][1] = y;
	PI[playerid][pPos][2] = z;
	SetPVarInt(playerid, "AntiBreik", 3);
	return 1;
}
Float:GetXYInFrontOfPlayers(playerid, &Float:x, &Float:y, Float:distance) {
	new Float:a;
	GetPlayerPos(playerid, x, y, a);
	if (IsPlayerInAnyVehicle(playerid))
	GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	else
	GetPlayerFacingAngle(playerid, a);
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
	return a;
}
Float:GetDistanceBetweenPoints(Float:X, Float:Y, Float:Z, Float:PointX, Float:PointY, Float:PointZ) {
	new Float:Distance;Distance = floatabs(floatsub(X, PointX)) + floatabs(floatsub(Y, PointY)) + floatabs(floatsub(Z, PointZ));
	return Distance;
}
GoAnim(playerid,alib[],aanim[],Float:atime,amove,ax,ay,az,af,ac) {
	ApplyAnimation(playerid,alib,aanim,atime,amove,ax,ay,az,af,ac);
	SetPVarInt(playerid,"Animation", 1),TextDrawShowForPlayer(playerid, AnimDraw[playerid]);
	return 1;
}
ChatBubbleMe(playerid, text[]) {
	SetPlayerChatBubble(playerid, text, 0x8fcb00AA, 20.0, 5000);
	return 0;
}
ChatBubble(playerid, text[]) {
	SetPlayerChatBubble(playerid, text, 0x96E300AA, 20.0, 5000);
	return 0;
}
Text:CreateSprite(Float:X,Float:Y,Nameb[],Float:Width,Float:Height) {
	new Text:RetSprite;
	RetSprite = TextDrawCreate(X, Y, Nameb);
	TextDrawFont(RetSprite, 4);
	TextDrawColor(RetSprite,0xFFFFFFFF);
	TextDrawTextSize(RetSprite,Width,Height);
	return RetSprite;
}
ProxDetector(Float: radi, playerid, ptext[], col1, col2, col3, col4, col5) {
	new Float: Radius;
	GetPlayerPos(playerid,PI[playerid][pPos][0],PI[playerid][pPos][1],PI[playerid][pPos][2]);
	SendClientMessage(playerid, col1, ptext);
	foreach(new i: StreamedPlayers[playerid]) {
		Radius = GetPlayerDistanceFromPoint(i, PI[playerid][pPos][0],PI[playerid][pPos][1],PI[playerid][pPos][2]);
		if(PlayerLogged[i] == false || Radius > radi || GetPlayerInterior(playerid) != GetPlayerInterior(i) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(i)) continue;
		if (Radius < radi / 16) SendClientMessage(i, col1, ptext);
		else if(Radius < radi / 8) SendClientMessage(i, col2, ptext);
		else if(Radius < radi / 4) SendClientMessage(i, col3, ptext);
		else if(Radius < radi / 4) SendClientMessage(i, col4, ptext);
		else if(Radius < radi / 2) SendClientMessage(i, col5, ptext);

	}
	return 1;
}
IsNumeric(const text[]) {
	for (new i = 0, j = strlen(text); i < j; i++) {
		if (text[i] > '9' || text[i] < '0') return false;
	}
	return true;
}
loadBasketBalls() {
	for(new i=0; i < sizeof(BBallsInfo); i++) {
		if(BBallsInfo[i][EBallType] == IS_DYNAMIC_OBJECT) {
			BBallsInfo[i][EBallObjectID] = CreateDynamicObject(BBallsInfo[i][EBallModelID],BBallsInfo[i][EBallX], BBallsInfo[i][EBallY],BBallsInfo[i][EBallZ], BBallsInfo[i][EBallRotX], BBallsInfo[i][EBallRotY], BBallsInfo[i][EBallRotZ],BBallsInfo[i][EBallVW],BBallsInfo[i][EBallInt]);
		}
	}
}
loadBaskets() {
	new bBallScoreLabel[128];
	for(new i=0; i < sizeof(BallBasketInfo); i++) {
		if(BallBasketInfo[i][EBasketType] == IS_DYNAMIC_OBJECT) {
			BallBasketInfo[i][EBasketObjectID] = CreateDynamicObject(BallBasketInfo[i][EBasketModelID],BallBasketInfo[i][EBasketX], BallBasketInfo[i][EBasketY],BallBasketInfo[i][EBasketZ], BallBasketInfo[i][EBasketRotX], BallBasketInfo[i][EBasketRotY], BallBasketInfo[i][EBasketRotZ],BallBasketInfo[i][EBasketVW],BallBasketInfo[i][EBasketInt]);
		}
		format(bBallScoreLabel, sizeof(bBallScoreLabel), "{FFFFFF}Забито: %d", BallBasketInfo[i][EBasketScore]);
		BallBasketInfo[i][EBasketText] = CreateDynamic3DTextLabel(bBallScoreLabel, 0xFFFFFFFF, BallBasketInfo[i][EBasketX], BallBasketInfo[i][EBasketY],BallBasketInfo[i][EBasketZ]+0.25, 50.0,INVALID_PLAYER_ID, INVALID_VEHICLE_ID,0,BallBasketInfo[i][EBasketVW], BallBasketInfo[i][EBasketInt]);
	}
}
isAtBBall(playerid, Float: radi = 1.5) {
	for(new i=0;i<sizeof(BBallsInfo);i++) {
		if(IsPlayerInRangeOfPoint(playerid, radi, BBallsInfo[i][EBallX], BBallsInfo[i][EBallY],BBallsInfo[i][EBallZ])) {
			return 1;
		}
	}
	return 0;
}
getClosestBBall(playerid, Float: radi = 1.5) {
	for(new i=0;i<sizeof(BBallsInfo);i++) {
		if(IsPlayerInRangeOfPoint(playerid, radi, BBallsInfo[i][EBallX], BBallsInfo[i][EBallY],BBallsInfo[i][EBallZ])) {
			return i;
		}
	}
	return -1;
}
getBBallArea(ballid) return BBallsInfo[ballid][EBBallArea];
checkPlayingState(playerid) {
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
		if(isPlayingBasketBall(playerid)) {
			if(isAtBBall(playerid, 30.0)) {
				if(hasBall(playerid)) {
					loadBBallAnims(playerid, BASKETBALL_RUN);
					playBounceSoundForPeople(playerid, 20.0);
				}
			}
			else exitBBallGame(playerid);
		}
	}
	return 1;
}
joiningOrLeavingBBall(playerid) {
	if(GetPVarInt(playerid, "WasToySlotUsed") == 0 && isAtBBall(playerid))
	tryPickUpBall(playerid);
}
exitBBallGame(playerid) {
	SendClientMessage(playerid, COLOR_GREY, "Вы вышли из баскетбольного матча!");
	SetPVarInt(playerid, "BrosilBBall", 0);
	new areaid = getAreaUserIsPlayingAt(playerid);
	destroyBBallPVars(playerid);
	tryDropBall(playerid);
	checkBBallGameState(areaid);
	unloadBBallAnims(playerid);
}
checkBBallGameState(areaid) {
	if(getAmountPlayingAtArea(areaid) < 1)
	restartBasketScores(areaid);
}
destroyBBallPVars(playerid) DeletePVar(playerid, "BasketBallArea");
tryDropBall(playerid) {
	new ballid = getLastBallID(playerid);
	if(getBallOwner(ballid) == playerid) {
		respawnBall(ballid);
		removeBallFromPlayer(playerid);
	}
}
respawnBall(ballid) {
	BBallsInfo[ballid][EBallObjectID] = CreateDynamicObject(BBallsInfo[ballid][EBallModelID],BBallsInfo[ballid][EBallX], BBallsInfo[ballid][EBallY],BBallsInfo[ballid][EBallZ], BBallsInfo[ballid][EBallRotX], BBallsInfo[ballid][EBallRotY], BBallsInfo[ballid][EBallRotZ],0,0);
	setBallOwner(-1, ballid);
}
removeBallFromPlayer(playerid) {
	RemovePlayerAttachedObject(playerid, SDK_BASKETBALL_SLOT);
	if(GetPVarType(playerid, "WasToySlotUsed") != PLAYER_VARTYPE_NONE) {
		if(GetPVarInt(playerid, "WasToySlotUsed") == 1) {
			SetPlayerAttachedObject(playerid, SDK_BASKETBALL_SLOT, SDK_BASKETBALL_MDL, 6);
			DeletePVar(playerid, "WasToySlotUsed");
		}
	}
	return 1;
}
tryPickUpBall(playerid) {
	if(isAtBBall(playerid)) {
		new ballindex = getClosestBBall(playerid);
		if(ballIsNotBeingUsed(ballindex)) {
			DestroyDynamicObject(BBallsInfo[ballindex][EBallObjectID]);
			pickupBBall(playerid, ballindex);
		}
		else joinBBallGame(playerid, ballindex);
	}
}
ballIsNotBeingUsed(ballid) {
	if(BBallsInfo[ballid][EBBallOwner] != -1)
	return 0;
	return 1;
}
pickupBBall(playerid, ballid) {
	joinBBallGame(playerid, ballid);
	attachBBallToPlayer(playerid, ballid);
	ApplyAnimation(playerid,"BSKTBALL","BBALL_pickup",4.0,0,0,0,0,0);
}
joinBBallGame(playerid, ballindex) {
	if(!isPlayingBasketBall(playerid)) {
		SetPVarInt(playerid, "BrosilBBall", 0);
		strin = "";
		format(strin, 90, "%s поднимает мяч с земли", NamePlayer(playerid));
		ProxDetectorNew(playerid,15.0,COLOR_PURPLE,strin);
		SetPVarInt(playerid, "ExitBBall", 1);
		SendClientMessage(playerid, COLOR_PAYCHEC, "Вы присоединились к баскетбольному матчу, чтобы покинуть (( введите /exit ))");
		SendClientMessage(playerid, COLOR_PAYCHEC, "Управление: Клавиши 'ПКМ+SHIFT' - пасануть мяч,клавиша 'Пробел' - отобрать мяч,'Прыжок' - забить.");
	}
	new areaid = getBBallArea(ballindex);
	setUserAreaIsPlayingAt(playerid, areaid);
}
setLastBallID(playerid, ballid)
SetPVarInt(playerid, "LastBallID", ballid);
getLastBallID(playerid) {
	if(GetPVarType(playerid, "LastBallID") != PLAYER_VARTYPE_NONE) return GetPVarInt(playerid, "LastBallID");
	return -1;
}
setUserAreaIsPlayingAt(playerid, area)
SetPVarInt(playerid, "BasketBallArea", area);
getAreaUserIsPlayingAt(playerid) {
	if(GetPVarType(playerid, "BasketBallArea") != PLAYER_VARTYPE_NONE) return GetPVarInt(playerid, "BasketBallArea");
	return -1;
}
getAmountPlayingAtArea(areaid) {
	new count;
	foreach(new i: Player) {
		if(GetPVarType(i, "BasketBallArea") != PLAYER_VARTYPE_NONE)
		{
			if(GetPVarInt(i, "BasketBallArea") == areaid) count++;
		}
	}
	return count;
}
attachBBallToPlayer(playerid, ballid) {
	if(IsPlayerAttachedObjectSlotUsed(playerid, SDK_BASKETBALL_SLOT)) {
		SetPlayerAttachedObject(playerid, SDK_BASKETBALL_SLOT, SDK_BASKETBALL_MDL, 6);
		SetPVarInt(playerid, "WasToySlotUsed", 1);
	}
	else SetPlayerAttachedObject(playerid, SDK_BASKETBALL_SLOT, SDK_BASKETBALL_MDL, 6);
	setBallOwner(playerid, ballid);
	loadBBallAnims(playerid);
}
getBallOwner(ballid) return BBallsInfo[ballid][EBBallOwner];
setBallOwner(playerid, ballid) {
	setLastBallID(playerid, ballid);
	BBallsInfo[ballid][EBBallOwner] = playerid;
}
isPlayingBasketBall(playerid) {
	if(GetPVarType(playerid, "BasketBallArea") != PLAYER_VARTYPE_NONE) return 1;
	return 0;
}
loadBBallAnims(playerid, anim = BASKETBALL_WALK) {
	switch(anim) {
	case BASKETBALL_WALK: ApplyAnimation(playerid,"BSKTBALL","BBALL_walk",4.1,1,1,1,1,1);
	case BASKETBALL_RUN: ApplyAnimation(playerid,"BSKTBALL","BBALL_run",4.1,1,1,1,1,1);
	case BASKETBALL_DUNK: ApplyAnimation(playerid, "BSKTBALL", "BBALL_DNK", 4.0, 0, 0, 0, 0, 0);
	case BASKETBALL_DEFENSE: ApplyAnimation(playerid, "BSKTBALL", "BBALL_DEF_LOOP", 4.0, 1, 0, 0, 0, 0);
	}
	return true;
}
unloadBBallAnims(playerid) {
	ClearAnimations(playerid);
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 1.0, 0, 0, 0, 0, 0);
}
playBounceSoundForPeople(playerid, Float: radi = 5.0) {
	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(playerid, X, Y, Z);
	foreach(new i: Player) {
		if(PlayerLogged[i]) {
			if(IsPlayerInRangeOfPoint(i, radi, X, Y, Z)) {
				PlayerPlaySound(i, 4602, X, Y, Z);
			}
		}
	}
	return true;
}
tryMarkOpponent(playerid) {
	if(!basketballTackleCool(playerid)) {
		if(!hasBall(playerid)) {
			new opponentid = getClosestBBallOpponentID(playerid, 1.5);
			if(opponentid != -1) sendBBall(playerid, opponentid, 0);
		}
	}
	return true;
}
basketballTackleCool(playerid) {
	new time = GetPVarInt(playerid, "SDKTackleCoolDown");
	new timenow = gettime();
	if(SDK_TACKLE_COOLDOWN-(timenow-time) > 0) return 0;
	SetPVarInt(playerid, "SDKTackleCoolDown", gettime());
	return 1;
}
tryPassBall(playerid) {
	if(hasBall(playerid)) {
		new sendto = GetPlayerTargetPlayer(playerid);
		if(sendto != INVALID_PLAYER_ID)
		sendBBall(playerid, sendto, 1);
	}
	return true;
}
sendBBall(playerid, opponentid, calculatedist) {
	new ballid = getLastBallID(playerid);
	if(getAreaUserIsPlayingAt(playerid) != getAreaUserIsPlayingAt(opponentid)) return 1;
	if(ballid != -1) {
		unloadBBallAnims(playerid);
		if(calculatedist != 1) {
			removeBallFromPlayer(opponentid);
			attachBBallToPlayer(playerid, ballid);
		}
		else moveBallPhys(playerid, ballid, opponentid);
	}
	return 1;
}
moveBallPhys(playerid, ballid, opponentid) {
	removeBallFromPlayer(playerid);
	attachBBallToPlayer(opponentid, ballid);
}
getClosestBBallOpponentID(playerid, Float: radi = 2.0) {
	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(playerid, X, Y, Z);
	foreach(new i: Player) {
		if(PlayerLogged[i]) {
			if(isPlayingBasketBall(i) && i != playerid) {
				if(IsPlayerInRangeOfPoint(i, radi, X, Y, Z)) {
					if(getAreaUserIsPlayingAt(i) == getAreaUserIsPlayingAt(playerid)) {
						if(hasBall(i)) {
							return i;
						}
					}
				}
			}
		}
	}
	return -1;
}
hasBall(playerid) {
	new ballid = getLastBallID(playerid);
	new getactualballowner = getBallOwner(ballid);
	if(playerid != getactualballowner) return 0;
	return 1;
}
tryScoreBBall(playerid) {
	if(isAtBasketBallBasket(playerid, 6.0)) {
		if(hasBall(playerid)) grantScore(playerid);
	}
	return 1;
}
grantScore(playerid) {
	if(GetPVarInt(playerid, "BrosilBBall") > 1) return true;
	new basketid = getClosestBasketBallBasket(playerid, 6.0);
	TogglePlayerControllable(playerid, 0);
	new result = random(2);
	if(result == 1){
		SetTimerEx("Unfreez",100,false,"i",playerid);
		strin = "";
		format(strin, 90, "%s кидает мяч в кольцо {ff0000}[Неудачно]", NamePlayer(playerid));
		ProxDetectorNew(playerid,30.0,COLOR_PURPLE,strin);
		SetPVarInt(playerid, "BrosilBBall", 3);
		untryDropBall(playerid);
	}else{
		new score = getBasketScore(basketid);
		setBasketScore(basketid, score+1);
		resyncBasketLabel(basketid);
		SetPlayerPos(playerid, BallBasketInfo[basketid][EBasketX], BallBasketInfo[basketid][EBasketY],BallBasketInfo[basketid][EBasketZ]-3.0);
		SetTimerEx("Unfreez",1500,false,"i",playerid);
		strin = "";
		format(strin, 90, "%s кидает мяч в кольцо {33AA33}[Удачно]", NamePlayer(playerid));
		ProxDetectorNew(playerid,30.0,COLOR_PURPLE,strin);
		SetPVarInt(playerid, "BrosilBBall", 0);
		tryDropBall(playerid);
	}
	loadBBallAnims(playerid, BASKETBALL_DUNK);
	return true;
}
untryDropBall(playerid) {
	new basketid = getClosestBasketBallBasket(playerid, 6.0);
	new ballid = getLastBallID(playerid);
	if(getBallOwner(ballid) == playerid) {
		BBallsInfo[getClosestBBall(playerid)][EBallX] = BallBasketInfo[basketid][EBasketX];
		BBallsInfo[getClosestBBall(playerid)][EBallY] = BallBasketInfo[basketid][EBasketY];
		BBallsInfo[getClosestBBall(playerid)][EBallZ] = BallBasketInfo[basketid][EBasketZ]-3.67;
		BBallsInfo[ballid][EBallObjectID] = CreateDynamicObject(BBallsInfo[ballid][EBallModelID],BBallsInfo[ballid][EBallX],BBallsInfo[ballid][EBallY],BBallsInfo[ballid][EBallZ], BBallsInfo[ballid][EBallRotX], BBallsInfo[ballid][EBallRotY], BBallsInfo[ballid][EBallRotZ],BBallsInfo[ballid][EBallVW],BBallsInfo[ballid][EBallInt]);
		setBallOwner(-1, ballid);
		removeBallFromPlayer(playerid);
	}
	return true;
}
isAtBasketBallBasket(playerid, Float: radi = 5.0) {
	for(new i=0;i<sizeof(BallBasketInfo);i++) {
		if(IsPlayerInRangeOfPoint(playerid, radi, BallBasketInfo[i][EBasketX], BallBasketInfo[i][EBasketY],BallBasketInfo[i][EBasketZ])) return 1;
	}
	return 0;
}
getClosestBasketBallBasket(playerid, Float: radi = 3.0) {
	for(new i=0;i<sizeof(BallBasketInfo);i++) {
		if(IsPlayerInRangeOfPoint(playerid, radi, BallBasketInfo[i][EBasketX], BallBasketInfo[i][EBasketY],BallBasketInfo[i][EBasketZ])) return i;
	}
	return -1;
}
resyncBasketLabel(basketid) {
	strin = "";
	format(strin, sizeof(strin), "{FFFFFF}Забито: %d", BallBasketInfo[basketid][EBasketScore]);
	UpdateDynamic3DTextLabelText(BallBasketInfo[basketid][EBasketText],0xFFFFFFFF,strin);
}
restartBasketScores(areaid) {
	for(new i=0;i<sizeof(BallBasketInfo);i++) {
		if(BallBasketInfo[i][EBasketArea] == areaid) {
			setBasketScore(i, 0);
			resyncBasketLabel(i);
		}
	}
	return true;
}
getBasketScore(basketid) return BallBasketInfo[basketid][EBasketScore];
setBasketScore(basketid, amount) BallBasketInfo[basketid][EBasketScore] = amount;

function: RemoveObjects(playerid) {
	// сад
	RemoveBuildingForPlayer(playerid, 11623,-872.875,1975.35938,59.58594,0.25);
	RemoveBuildingForPlayer(playerid, 3276,-1088.5282,-1214.328,129.49326,0.25);
	RemoveBuildingForPlayer(playerid, 3276,-1088.5282,-1203.12671,129.59554,0.25);
	RemoveBuildingForPlayer(playerid, 3276,-1088.5282,-1189.7937,129.48123,0.25);
	RemoveBuildingForPlayer(playerid, 17007,-1071.92187,-1170.21094,128.21875,0.25);
	RemoveBuildingForPlayer(playerid, 691,-1073.80469,-1234.75781,128.07813,0.25);
	RemoveBuildingForPlayer(playerid, 708,-1084.16406,-1217.55469,128.44531,0.25);
	RemoveBuildingForPlayer(playerid, 708,-1073.57031,-1187.22656,128.00781,0.25);
	RemoveBuildingForPlayer(playerid, 1454,-1129.53906,-1156.79687,129.01563,0.25);
	RemoveBuildingForPlayer(playerid, 1454,-1133.0625,-1156.79687,129.01563,0.25);
	RemoveBuildingForPlayer(playerid, 1454,-1136.58594,-1156.79687,129.01563,0.25);
	RemoveBuildingForPlayer(playerid, 1454,-1140.10937,-1156.79687,129.01563,0.25);
	RemoveBuildingForPlayer(playerid, 1454,-1143.63281,-1156.79687,129.01563,0.25);
	RemoveBuildingForPlayer(playerid, 1454,-1147.15625,-1156.79687,129.01563,0.25);
	RemoveBuildingForPlayer(playerid, 1454,-1150.67969,-1156.79687,129.01563,0.25);
	RemoveBuildingForPlayer(playerid, 1454,-1154.20312,-1156.79687,129.01563,0.25);
	RemoveBuildingForPlayer(playerid, 1454,-1157.73437,-1156.79687,129.01563,0.25);
	RemoveBuildingForPlayer(playerid, 1454,-1161.25781,-1156.79687,129.01563,0.25);
	RemoveBuildingForPlayer(playerid, 1454,-1164.78125,-1156.79687,129.01563,0.25);
	RemoveBuildingForPlayer(playerid, 3374,-1175.14722,-1170.86719,130.46483,0.25);
	RemoveBuildingForPlayer(playerid, 3374,-1182.35559,-1170.24878,130.64095,0.25);
	RemoveBuildingForPlayer(playerid, 3374,-1189.92957,-1168.76086,131.20915,0.25);
	RemoveBuildingForPlayer(playerid, 3374,-1196.92932,-1170.578,129.95901,0.25);
	RemoveBuildingForPlayer(playerid, 3374,-1204.06519,-1169.27185,129.88263,0.25);
	RemoveBuildingForPlayer(playerid, 3374, -1206.1406, -1169.8359, 129.7031, 0.25);
	RemoveBuildingForPlayer(playerid, 3374, -1198.8672, -1169.8359, 129.7031, 0.25);
	RemoveBuildingForPlayer(playerid, 3374, -1191.6016, -1169.8359, 129.7031, 0.25);
	RemoveBuildingForPlayer(playerid, 3374, -1184.3281, -1169.8359, 129.7031, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -1088.4063, -1215.0625, 129.0625, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -1088.4063, -1191.6875, 129.0625, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -1088.4063, -1203.3750, 129.0625, 0.25);
	RemoveBuildingForPlayer(playerid, 3374, -1177.0547, -1169.8359, 129.7031, 0.25);
	// interior gold minner
	RemoveBuildingForPlayer(playerid, 1812,416.24219,2540.33594,8.97656,0.25);
	RemoveBuildingForPlayer(playerid, 2115,418.6875,2539.59375,8.99219,0.25);
	RemoveBuildingForPlayer(playerid, 1748,418.27344,2541.0625,9.78906,0.25);
	// pirs
	RemoveBuildingForPlayer(playerid, 1447, -74.8203, -1607.2578, 3.4609, 0.25);
	RemoveBuildingForPlayer(playerid, 1412, -70.4141, -1604.3750, 3.4609, 0.25);
	RemoveBuildingForPlayer(playerid, 1447, -66.2891, -1601.2266, 3.2109, 0.25);
	RemoveBuildingForPlayer(playerid, 1413, -53.8125, -1585.8594, 3.0859, 0.25);
	RemoveBuildingForPlayer(playerid, 1447, -50.8281, -1581.7656, 3.1641, 0.25);
	RemoveBuildingForPlayer(playerid, 1412, -47.5547, -1577.6484, 3.1641, 0.25);
	RemoveBuildingForPlayer(playerid, 1412, -44.5625, -1573.3672, 3.1641, 0.25);
	RemoveBuildingForPlayer(playerid, 1438, -88.1094, -1598.7188, 1.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1370, -86.5703, -1595.1406, 2.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 3173, -93.0938, -1593.5234, 1.5547, 0.25);
	RemoveBuildingForPlayer(playerid, 1462, -93.6797, -1588.0781, 1.5078, 0.25);
	RemoveBuildingForPlayer(playerid, 3174, -75.1719, -1596.3047, 1.6797, 0.25);
	RemoveBuildingForPlayer(playerid, 1438, -79.2578, -1593.4688, 1.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1447, -74.8203, -1607.2578, 3.4609, 0.25);
	RemoveBuildingForPlayer(playerid, 1370, -72.4141, -1596.7734, 2.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 1370, -74.1875, -1583.9922, 2.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 3175, -101.8203, -1577.6875, 1.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1457, -91.0156, -1576.6250, 3.1953, 0.25);
	RemoveBuildingForPlayer(playerid, 1370, -100.8203, -1580.4219, 2.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 3175, -77.9375, -1581.3125, 1.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1472, -75.5859, -1581.0703, 2.0234, 0.25);
	RemoveBuildingForPlayer(playerid, 727, -73.8203, -1569.1719, 1.3516, 0.25);
	RemoveBuildingForPlayer(playerid, 3173, -90.6406, -1562.9375, 1.5547, 0.25);
	RemoveBuildingForPlayer(playerid, 1438, -77.0625, -1542.6016, 1.6172, 0.25);
	RemoveBuildingForPlayer(playerid, 1447, -66.2891, -1601.2266, 3.2109, 0.25);
	RemoveBuildingForPlayer(playerid, 1457, -71.0000, -1574.0859, 3.1953, 0.25);
	RemoveBuildingForPlayer(playerid, 3175, -64.3828, -1572.2109, 1.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1438, -62.2734, -1569.2891, 1.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1370, -61.6641, -1573.4609, 2.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 1413, -53.8125, -1585.8594, 3.0859, 0.25);
	RemoveBuildingForPlayer(playerid, 1438, -56.0625, -1575.6563, 1.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1447, -50.8281, -1581.7656, 3.1641, 0.25);
	RemoveBuildingForPlayer(playerid, 1370, -64.0000, -1550.2578, 2.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 3175, -55.2813, -1557.4531, 1.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1370, -56.1563, -1560.4609, 2.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 727, -49.3984, -1560.0078, 1.4609, 0.25);
	RemoveBuildingForPlayer(playerid, 3174, -44.2891, -1561.3125, 1.6797, 0.25);
	RemoveBuildingForPlayer(playerid, 1370, -43.7422, -1563.6875, 2.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 3173, -67.2344, -1544.2188, 1.5547, 0.25);
	// autobuy
	RemoveBuildingForPlayer(playerid, 6482, 536.1328, -1291.6797, 23.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 730, 516.2109, -1326.3984, 14.7031, 0.25);
	RemoveBuildingForPlayer(playerid, 1266, 520.3516, -1307.0547, 29.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 507.5625, -1315.8594, 13.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 6357, 505.0547, -1269.9375, 28.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 1308, 510.6797, -1290.6953, 15.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 1260, 520.3438, -1307.0625, 29.6797, 0.25);
	RemoveBuildingForPlayer(playerid, 6337, 536.1328, -1291.6797, 23.4688, 0.25);
	// jobhouse
	RemoveBuildingForPlayer(playerid, 6147, 743.1563, -1428.6563, 16.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 6193, 717.1953, -1490.9844, 15.7578, 0.25);
	RemoveBuildingForPlayer(playerid, 6134, 743.1563, -1428.6563, 16.7266, 0.25);
	// gruz
	RemoveBuildingForPlayer(playerid, 4982, 1892.5391, -2012.8281, 21.3750, 0.25);
	RemoveBuildingForPlayer(playerid, 1308, 1971.4609, -1980.6094, 12.6406, 0.25);
	RemoveBuildingForPlayer(playerid, 3723, 2197.7500, -1993.3594, 14.9922, 0.25);
	RemoveBuildingForPlayer(playerid, 5313, 2043.9922, -2016.8672, 25.0547, 0.25);
	RemoveBuildingForPlayer(playerid, 5316, 2043.9922, -2016.8672, 25.0547, 0.25);
	RemoveBuildingForPlayer(playerid, 5346, 2016.3125, -1968.9219, 17.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 5357, 2177.9922, -2006.7578, 23.2891, 0.25);
	RemoveBuildingForPlayer(playerid, 5312, 2068.9609, -2013.4766, 24.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 5291, 2177.9922, -2006.7578, 23.2891, 0.25);
	RemoveBuildingForPlayer(playerid, 1412, 1989.0859, -1982.4766, 13.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 1412, 1983.8125, -1982.4766, 13.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 1412, 1978.5313, -1982.4766, 13.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 3286, 2042.1953, -1986.0859, 38.3281, 0.25);
	RemoveBuildingForPlayer(playerid, 3722, 2197.7500, -1993.3594, 14.9922, 0.25);
	RemoveBuildingForPlayer(playerid, 5169, 2016.3125, -1968.9219, 17.6250, 0.25);
	// kortel
	RemoveBuildingForPlayer(playerid, 11618, -688.1172, 939.1797, 11.1250, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -698.9609, 909.6719, 11.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -687.3125, 909.6016, 11.9844, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -710.6094, 909.7422, 11.9453, 0.25);
	RemoveBuildingForPlayer(playerid, 11491, -688.1094, 928.1328, 12.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 669, -712.0703, 928.3047, 11.5391, 0.25);
	RemoveBuildingForPlayer(playerid, 11490, -688.1172, 939.1797, 11.1250, 0.25);
	RemoveBuildingForPlayer(playerid, 11631, -691.5938, 942.7188, 13.8750, 0.25);
	RemoveBuildingForPlayer(playerid, 11663, -688.1172, 939.1797, 11.1250, 0.25);
	RemoveBuildingForPlayer(playerid, 11666, -688.1406, 934.8203, 14.3906, 0.25);
	RemoveBuildingForPlayer(playerid, 11664, -685.0938, 941.9141, 13.1406, 0.25);
	RemoveBuildingForPlayer(playerid, 11665, -685.1719, 935.6953, 13.3203, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -709.3203, 991.1641, 12.0313, 0.25);
	RemoveBuildingForPlayer(playerid, 700, -700.6563, 984.1406, 11.5547, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -697.6719, 990.9922, 12.0078, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -686.0234, 990.8203, 11.9844, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -665.5625, 912.9453, 11.9766, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -675.6641, 909.5313, 12.0078, 0.25);
	RemoveBuildingForPlayer(playerid, 1223, -657.3828, 907.2578, 8.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 1223, -673.2891, 920.3203, 10.9141, 0.25);
	RemoveBuildingForPlayer(playerid, 1223, -683.0703, 920.4844, 10.9141, 0.25);
	RemoveBuildingForPlayer(playerid, 1223, -656.9297, 915.7578, 10.5625, 0.25);
	RemoveBuildingForPlayer(playerid, 1223, -664.8516, 920.0625, 10.9141, 0.25);
	RemoveBuildingForPlayer(playerid, 700, -658.8203, 936.1797, 11.2500, 0.25);
	RemoveBuildingForPlayer(playerid, 669, -656.5781, 974.4688, 11.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -674.3750, 990.6484, 11.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -662.7266, 990.4766, 11.9453, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -650.1953, 928.1953, 11.8750, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -645.8828, 937.9063, 11.9453, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -645.7109, 949.5547, 11.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -645.5391, 961.2031, 11.9844, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -645.3672, 972.8516, 12.0078, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -645.1953, 984.5000, 12.0313, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -651.0781, 990.3047, 11.9219, 0.25);
	//колхоз
	RemoveBuildingForPlayer(playerid, 1308, 9.0234, 15.1563, -5.7109, 0.25);
	RemoveBuildingForPlayer(playerid, 13052, -69.0469, 86.8359, 2.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 13053, -59.9531, 110.4609, 13.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 13057, -120.0234, -77.9063, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 13477, -21.9453, 101.3906, 4.5313, 0.25);
	RemoveBuildingForPlayer(playerid, 13488, -81.5703, -79.4453, 4.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 672, -112.4766, -158.2422, 2.8750, 0.25);
	RemoveBuildingForPlayer(playerid, 672, -149.3359, -160.5078, 3.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -124.4297, -136.6172, 2.9453, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -108.0234, -114.6563, 2.9453, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -119.0156, -112.8672, 2.9063, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -88.6328, -112.6484, 2.9063, 0.25);
	RemoveBuildingForPlayer(playerid, 672, 65.7891, -168.7266, 0.2188, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -100.7813, -110.4609, 2.9063, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -123.5156, -106.2266, 2.9063, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -135.2734, -104.4453, 2.9063, 0.25);
	RemoveBuildingForPlayer(playerid, 13367, -120.0234, -77.9063, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 1428, -116.0000, -77.2500, 15.6797, 0.25);
	RemoveBuildingForPlayer(playerid, 13489, -81.5703, -79.4453, 4.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 1428, -118.5000, -75.9375, 5.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1428, -116.7578, -76.3516, 3.5391, 0.25);
	RemoveBuildingForPlayer(playerid, 705, -58.6328, -66.6250, 2.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 672, -140.6016, -44.9531, 2.8750, 0.25);
	RemoveBuildingForPlayer(playerid, 12917, -99.9922, -40.3047, 1.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 3374, -50.0156, 3.1797, 3.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 12914, -75.1797, 12.1719, 3.7188, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -10.9141, 15.3828, 2.8906, 0.25);
	RemoveBuildingForPlayer(playerid, 12918, -72.0391, 18.4453, 1.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 672, -35.7109, 18.1016, 3.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -94.5234, 31.6172, 2.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -90.5313, 42.1484, 2.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -81.8984, 56.8516, 2.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -71.8359, 58.8750, 2.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 3374, -92.8672, 58.3438, 3.5703, 0.25);
	RemoveBuildingForPlayer(playerid, 3374, -91.9453, 47.8125, 3.5703, 0.25);
	RemoveBuildingForPlayer(playerid, 12915, -69.0469, 86.8359, 2.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 3374, -41.2500, 98.4141, 3.4609, 0.25);
	RemoveBuildingForPlayer(playerid, 3374, -36.0156, 96.1875, 3.5703, 0.25);
	RemoveBuildingForPlayer(playerid, 12912, -59.9531, 110.4609, 13.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 12913, -21.9453, 101.3906, 4.5313, 0.25);
	RemoveBuildingForPlayer(playerid, 759, -25.0625, 104.7578, 1.7422, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -32.6484, 121.0938, 2.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -23.6563, 114.0000, 2.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 672, -71.7109, 135.3438, 1.8281, 0.25);
	RemoveBuildingForPlayer(playerid, 3276, -34.9297, 131.5469, 2.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 705, -71.2422, 174.6641, 1.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 672, 153.1953, 23.0313, 0.0938, 0.25);
	//пляж?
	RemoveBuildingForPlayer(playerid, 1283, 2176.4141, -1132.4453, 26.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 1283, 2166.2734, -1119.2266, 27.5703, 0.25);
	RemoveBuildingForPlayer(playerid, 1297, 2185.3828, -1116.0703, 27.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 1283, 2187.0625, -1120.8125, 26.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 1283, 2190.4688, -1105.7188, 27.0703, 0.25);
	RemoveBuildingForPlayer(playerid, 1297, 2191.3984, -1128.0547, 27.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1283, 2218.2656, -1112.5234, 27.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 1297, 2228.9688, -1127.6172, 28.1641, 0.25);
	RemoveBuildingForPlayer(playerid, 1311, 2240.7891, -1140.3438, 28.9922, 0.25);
	RemoveBuildingForPlayer(playerid, 1297, 2256.9609, -1139.2188, 29.1328, 0.25);
	RemoveBuildingForPlayer(playerid, 1297, 1065.7109, -1841.9141, 15.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 17002, 52.8906, -1532.0313, 7.7422, 0.25);
	//Рыболов
	RemoveBuildingForPlayer(playerid, 3778, 337.4531, -1875.0000, 3.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3615, 337.4531, -1875.0000, 3.4063, 0.25);
	// ВМФ
	RemoveBuildingForPlayer(playerid, 968, -1526.4375, 481.3828, 6.9063, 0.25);
	RemoveBuildingForPlayer(playerid, 966, -1526.3906, 481.3828, 6.1797, 0.25);
	RemoveBuildingForPlayer(playerid, 10829, -1523.2578, 486.7969, 6.1563, 0.25);
	// КПП Лос Сантос
	RemoveBuildingForPlayer(playerid, 17002, 52.8906, -1532.0313, 7.7422, 0.25);
	//
	RemoveBuildingForPlayer(playerid, 1290, 1080.8438, -1777.4922, 18.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1077.3672, -1750.3984, 14.3125, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1080.8438, -1750.1797, 18.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1083.5156, -1750.3984, 14.3125, 0.25);
	//
	RemoveBuildingForPlayer(playerid, 785, 2330.6484, -742.6016, 127.3906, 0.25);
	RemoveBuildingForPlayer(playerid, 791, 2330.6484, -742.6016, 127.3906, 0.25);
	RemoveBuildingForPlayer(playerid, 696, 2373.8750, -740.6172, 130.1328, 0.25);
	RemoveBuildingForPlayer(playerid, 696, 2375.3047, -666.7266, 131.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 790, 2389.1172, -728.3281, 126.8438, 0.25);
	//
	RemoveBuildingForPlayer(playerid, 5931, 1114.3125, -1348.1016, 17.9844, 0.25);
	RemoveBuildingForPlayer(playerid, 5810, 1114.3125, -1348.1016, 17.9844, 0.25);
	RemoveBuildingForPlayer(playerid, 5993, 1110.8984, -1328.8125, 13.8516, 0.25);
	RemoveBuildingForPlayer(playerid, 5811, 1131.1953, -1380.4219, 17.0703, 0.25);
	RemoveBuildingForPlayer(playerid, 1440, 1141.9844, -1346.1094, 13.2656, 0.25);
	RemoveBuildingForPlayer(playerid, 1440, 1148.6797, -1385.1875, 13.2656, 0.25);
	// СВ
	RemoveBuildingForPlayer(playerid, 16094, 191.1406, 1870.0391, 21.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 347.1953, 1799.2656, 18.7578, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 342.9375, 1796.2891, 18.7578, 0.25);
	RemoveBuildingForPlayer(playerid, 16096, 120.5078, 1934.0313, 19.8281, 0.25);
	return true;
}
function: OPConnect(playerid) {
	new Symbol, strs[128], __IP[ 64 ], PlayerName[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
	if(PlayerName[0] < 'A' || PlayerName[0] > 'Z') return NewKick(playerid,"НикНейм должен быть в формате: Имя_Фамилия!");
	for(new A = 1; A < strlen(PlayerName); A++) {
		if(PlayerName[A] == '_') {
			if(Symbol == 1 || PlayerName[A+1] < 'A' || PlayerName[A+1] > 'Z' || A+2 == strlen(PlayerName)) return NewKick(playerid,"НикНейм должен быть в формате: Имя_Фамилия!");
			Symbol = 1;
			A++;
			continue;
		}
		if(PlayerName[A] < 'a' || PlayerName[A] > 'z') return NewKick(playerid,"НикНейм должен быть в формате: Имя_Фамилия!");
	}
	if(!Symbol) return NewKick(playerid,"НикНейм должен быть в формате: Имя_Фамилия!");
	GetPlayerIp( playerid, __IP, 64 );
	if ( slotUsed{ playerid } && !strcmp( playersIP[ playerid ], __IP, true ) ) return Ban( playerid );
	GetPlayerIp( playerid, playersIP[ playerid ], 64 );
	slotUsed{ playerid } = 1;

	mysql_real_escape_string(NamePlayer(playerid), NamePlayer(playerid));
	format(strs, sizeof(strs),"SELECT * FROM bans WHERE `name` = '%s'", NamePlayer(playerid));
	mysql_function_query(cHandle, strs, true, "CheckBanPlayer","d", playerid);
	EnterTimer[playerid] = SetTimerEx("PlayerKick",80000,false,"i",playerid);

	InterpolateCameraPos(playerid,291.2647,-1253.8707,152.0083,1430.1914,-1739.1036,131.4550,30000,CAMERA_MOVE);
	InterpolateCameraLookAt(playerid,291.2647,-1253.8707,152.0083,1430.1914,-1739.1036,131.4550,30000,CAMERA_MOVE);

	ResetNew(playerid);
	ResetCarInfo(playerid);
	ResetWeapon(playerid);
	ResetPlayerWeapons(playerid);
	strin = "";
	format(strin, sizeof(strin), "[A] Игрок %s (ID: %d) присоеденился(ась) к серверу",NamePlayer(playerid), playerid);
	SendAdminMessage(COLOR_LIGHTRED, strin);
	for(new x = 1;x<=TOTALGZ;x++) GangZoneShowForPlayer(playerid,GZInfo[x][id],GetGangZoneColor(x));
	return true;
}
function: LoadGZ() {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return 1;
	for(new idx; idx != rows; idx++) {
		GZInfo[idx+1][id] = cache_get_field_content_int(idx, "id", cHandle);
		GZInfo[idx+1][gCoords][0] = cache_get_field_content_float(idx, "ginfo1", cHandle);
		GZInfo[idx+1][gCoords][1] = cache_get_field_content_float(idx, "ginfo2", cHandle);
		GZInfo[idx+1][gCoords][2] = cache_get_field_content_float(idx, "ginfo3", cHandle);
		GZInfo[idx+1][gCoords][3] = cache_get_field_content_float(idx, "ginfo4", cHandle);
		GZInfo[idx+1][gFrak] = cache_get_field_content_int(idx, "fraction", cHandle);
		TOTALGZ++;
		GZInfo[idx+1][id] = GangZoneCreate(GZInfo[idx+1][gCoords][0],GZInfo[idx+1][gCoords][1],GZInfo[idx+1][gCoords][2],GZInfo[idx+1][gCoords][3]);
		ZoneOnBattle[idx+1] = 0;
		GZSafeTime[idx+1] = 0;
	}
	#if defined TM_DEBUG
	    print("************** [MySQL INFO] **************");
		printf("[MySQL]: Гангзон загружено - %d",TOTALGZ);
	#endif
	UpdateWarehouse();
	return 1;
}
function: LoadEnters() {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return 1;
	for(new idx; idx != rows; idx++) {
		EntersInfo[idx+1][id] = cache_get_field_content_int(idx, "id", cHandle);
		EntersInfo[idx+1][pX] = cache_get_field_content_float(idx, "x", cHandle);
		EntersInfo[idx+1][pY] = cache_get_field_content_float(idx, "y", cHandle);
		EntersInfo[idx+1][pZ] = cache_get_field_content_float(idx, "z", cHandle);
		EntersInfo[idx+1][pM] = cache_get_field_content_int(idx, "m", cHandle);
		EntersInfo[idx+1][pT] = cache_get_field_content_int(idx, "t", cHandle);
		EntersInfo[idx+1][pI] = cache_get_field_content_int(idx, "i", cHandle);
		EntersInfo[idx+1][pV] = cache_get_field_content_int(idx, "v", cHandle);
		EntersInfo[idx+1][ptX] = cache_get_field_content_float(idx, "tx", cHandle);
		EntersInfo[idx+1][ptY] = cache_get_field_content_float(idx, "ty", cHandle);
		EntersInfo[idx+1][ptZ] = cache_get_field_content_float(idx, "tz", cHandle);
		EntersInfo[idx+1][ptFa] = cache_get_field_content_float(idx, "tfa", cHandle);
		EntersInfo[idx+1][ptI] = cache_get_field_content_int(idx, "ti", cHandle);
		EntersInfo[idx+1][ptV] = cache_get_field_content_int(idx, "tv", cHandle);
		cache_get_field_content(idx, "name", EntersInfo[idx+1][pName], cHandle, sizeof(qurey));
		EntersInfo[idx+1][pP] = CreateDynamicPickup(EntersInfo[idx+1][pM], 23, EntersInfo[idx+1][pX], EntersInfo[idx+1][pY], EntersInfo[idx+1][pZ],EntersInfo[idx+1][pV]);
		CreateDynamic3DTextLabel(EntersInfo[idx+1][pName], 0x317CDFAA, EntersInfo[idx+1][pX], EntersInfo[idx+1][pY], EntersInfo[idx+1][pZ], 5.0, INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1, EntersInfo[idx+1][pV], EntersInfo[idx+1][pI]);
		TOTALENTERS++;
	}
	return 1;
}
function: LoadPark() {
	new rows,fields;
	cache_get_data(rows,fields);
	strin = "";
	if(rows < 1) return 1;
	for(new idx; idx != rows; idx++) {
		BizzPark[idx+1][tID] = cache_get_field_content_int(idx, "id", cHandle);
		cache_get_field_content(idx, "name", BizzPark[idx+1][tName], cHandle, sizeof(qurey));
		cache_get_field_content(idx, "owner", BizzPark[idx+1][tOwner], cHandle, sizeof(qurey));
		BizzPark[idx+1][tBank] = cache_get_field_content_int(idx, "bank", cHandle);
		BizzPark[idx+1][tTarif] = cache_get_field_content_int(idx, "tarif", cHandle);
		BizzPark[idx+1][tCost] = cache_get_field_content_int(idx, "cost", cHandle);
		BizzPark[idx+1][tX] = cache_get_field_content_float(idx, "X", cHandle);
		BizzPark[idx+1][tY] = cache_get_field_content_float(idx, "Y", cHandle);
		BizzPark[idx+1][tZ] = cache_get_field_content_float(idx, "Z", cHandle);

		format(strin, 120, "Бизнес: %s\nВладелец: %s", BizzPark[idx+1][tName], BizzPark[idx+1][tOwner]);
		LABELPARK[idx+1] = CreateDynamic3DTextLabel(strin,COLOR_YELLOW,BizzPark[idx+1][tX],BizzPark[idx+1][tY],BizzPark[idx+1][tZ],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
		TOTALPARK++;
	}
	return 1;
}
function: LoadCarsPark() {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return 1;
	for(new idx; idx != rows; idx++) {
		BizzCarsPark[idx+1][tcID] = cache_get_field_content_int(idx, "id", cHandle);
		BizzCarsPark[idx+1][tcPID] = cache_get_field_content_int(idx, "pid", cHandle);
		BizzCarsPark[idx+1][tcModel] = cache_get_field_content_int(idx, "model", cHandle);
		BizzCarsPark[idx+1][tcFuel] = cache_get_field_content_int(idx, "fuel", cHandle);
		BizzCarsPark[idx+1][tcStatus] = cache_get_field_content_int(idx, "status", cHandle);
		BizzCarsPark[idx+1][tcX] = cache_get_field_content_float(idx, "X", cHandle);
		BizzCarsPark[idx+1][tcY] = cache_get_field_content_float(idx, "Y", cHandle);
		BizzCarsPark[idx+1][tcZ] = cache_get_field_content_float(idx, "Z", cHandle);
		BizzCarsPark[idx+1][tcFa] = cache_get_field_content_float(idx, "Fa", cHandle);
		if(BizzCarsPark[idx+1][tcStatus] != 0)
		{
			BizzCarsPark[idx+1][tcVehicle] = CreateVehicleEx(BizzCarsPark[idx+1][tcModel], BizzCarsPark[idx+1][tcX], BizzCarsPark[idx+1][tcY], BizzCarsPark[idx+1][tcZ], BizzCarsPark[idx+1][tcFa], 6, 1,1200);
			Fuel[BizzCarsPark[idx+1][tcVehicle]] = BizzCarsPark[idx+1][tcFuel];
		}
		TOTALCARSPARK++;
	}
	return 1;
}
function: LoadHouse() {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return 1;
	for(new idx; idx != rows; idx++) {
		HouseInfo[idx+1][id] = cache_get_field_content_int(idx, "id", cHandle);
		HouseInfo[idx+1][hEntrx] = cache_get_field_content_float(idx, "hEntrx", cHandle);
		HouseInfo[idx+1][hEntry] = cache_get_field_content_float(idx, "hEntry", cHandle);
		HouseInfo[idx+1][hEntrz] = cache_get_field_content_float(idx, "hEntrz", cHandle);
		HouseInfo[idx+1][hExitx] = cache_get_field_content_float(idx, "hExitx", cHandle);
		HouseInfo[idx+1][hExity] = cache_get_field_content_float(idx, "hExity", cHandle);
		HouseInfo[idx+1][hExitz] = cache_get_field_content_float(idx, "hExitz", cHandle);
		HouseInfo[idx+1][hEx] = cache_get_field_content_float(idx, "hEx", cHandle);
		HouseInfo[idx+1][hEy] = cache_get_field_content_float(idx, "hEy", cHandle);
		HouseInfo[idx+1][hEz] = cache_get_field_content_float(idx, "hEz", cHandle);
		HouseInfo[idx+1][hEp] = cache_get_field_content_float(idx, "hEp", cHandle);
		HouseInfo[idx+1][hCarx] = cache_get_field_content_float(idx, "carx", cHandle);
		HouseInfo[idx+1][hCary] = cache_get_field_content_float(idx, "cary", cHandle);
		HouseInfo[idx+1][hCarz] = cache_get_field_content_float(idx, "carz", cHandle);
		HouseInfo[idx+1][hCarfa] = cache_get_field_content_float(idx, "carfa", cHandle);
		cache_get_field_content(idx, "hDiscript", HouseInfo[idx+1][hDiscript], cHandle, sizeof(qurey));
		cache_get_field_content(idx, "hOwner", HouseInfo[idx+1][hOwner], cHandle, sizeof(qurey));
		HouseInfo[idx+1][hPrice] = cache_get_field_content_int(idx, "hPrice", cHandle);
		HouseInfo[idx+1][hBuyPrice] = cache_get_field_content_int(idx, "buyprice", cHandle);
		HouseInfo[idx+1][hInt] = cache_get_field_content_int(idx, "hInt", cHandle);
		HouseInfo[idx+1][hType] = cache_get_field_content_int(idx, "hType", cHandle);
		HouseInfo[idx+1][hVirtual] = cache_get_field_content_int(idx, "hVirtual", cHandle);
		HouseInfo[idx+1][hLock] = cache_get_field_content_int(idx, "hLock", cHandle);
		HouseInfo[idx+1][hOplata] = cache_get_field_content_int(idx, "hOplata", cHandle);
		HouseInfo[idx+1][hOutput] = cache_get_field_content_int(idx, "hOutput", cHandle);
		HouseInfo[idx+1][hGrant] = cache_get_field_content_int(idx, "hGrant", cHandle);
		HouseInfo[idx+1][hMedicine] = cache_get_field_content_int(idx, "hMedicine", cHandle);
		HouseInfo[idx+1][hSafe] = cache_get_field_content_int(idx, "hSafe", cHandle);
		HouseInfo[idx+1][hLocker] = cache_get_field_content_int(idx, "hLocker", cHandle);
		if(!strcmp(HouseInfo[idx+1][hOwner],"None",true))
		{
			HouseInfo[idx+1][hMIcon] = CreateDynamicMapIcon(HouseInfo[idx+1][hEntrx], HouseInfo[idx+1][hEntry], HouseInfo[idx+1][hEntrz], 31, 0,-1,-1,-1,160.0);
			HouseInfo[idx+1][hPickup] = CreateDynamicPickup(1273, 23, HouseInfo[idx+1][hEntrx], HouseInfo[idx+1][hEntry], HouseInfo[idx+1][hEntrz]);
		}
		else {
			HouseInfo[idx+1][hMIcon] = CreateDynamicMapIcon(HouseInfo[idx+1][hEntrx], HouseInfo[idx+1][hEntry], HouseInfo[idx+1][hEntrz], 32, 0,-1,-1,-1,160.0);
			HouseInfo[idx+1][hPickup] = CreateDynamicPickup(1272, 23, HouseInfo[idx+1][hEntrx], HouseInfo[idx+1][hEntry], HouseInfo[idx+1][hEntrz]);
		}
		if(HouseInfo[idx][hMedicine] == 1)
		{
			switch(HouseInfo[idx+1][hType]) {
			case 1: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,152.5929,1380.0516,1088.3672,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 2: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,239.7793,1069.9396,1084.1875,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 3: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,2320.6421,-1026.1470,1050.2109,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 4: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,231.9268,1187.5726,1080.2578,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 5: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,239.0229,1110.2178,1080.9922,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 6: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,2335.7024,-1146.1272,1050.7101,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 7: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,2244.9993,-1077.1807,1049.0234,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 8: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,2188.8677,-1201.4576,1049.0308,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 9: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,2362.4221,-1134.7852,1050.8826,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 12: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,2280.1199,-1135.3749,1050.8984,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 13: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,2213.8435,-1077.9104,1050.4844,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 16: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,2812.4951,-1168.0574,1029.1719,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 17: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,2230.6099,-1108.6124,1050.8828,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 18: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,2264.5967,-1140.5990,1050.6328,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 19: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,247.8775,302.5932,999.1484,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 20: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,2453.9688,-1706.0438,1013.5078,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			case 21: {HouseInfo[idx+1][hMedPickup]=CreateDynamicPickup(1240,23,272.3441,307.1946,999.1484,321,HouseInfo[idx+1][hVirtual],HouseInfo[idx+1][hInt]);}
			}
		}
		TOTALHOUSE++;
	}
	#if defined TM_DEBUG
		printf("[MySQL]: Домов загружено - %d",TOTALHOUSE);
	#endif
	return 1;
}
function: LoadCars() {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return 1;
	for(new idx; idx < rows; idx++) {
		CarInfo[idx+1][id] = cache_get_field_content_int(idx, "id", cHandle);
		cache_get_field_content(idx, "owner", CarInfo[idx+1][cOwner], cHandle, sizeof(qurey));
		CarInfo[idx+1][cModel] = cache_get_field_content_int(idx, "model", cHandle);
		CarInfo[idx+1][cFuel] = cache_get_field_content_int(idx, "fuel", cHandle);
		cache_get_field_content(idx, "colors", CarInfo[idx+1][cColors], cHandle, sizeof(qurey));
		CarInfo[idx+1][cLock] = cache_get_field_content_int(idx, "clock", cHandle);
		CarInfo[idx+1][cX] = cache_get_field_content_float(idx, "x", cHandle);
		CarInfo[idx+1][cY] = cache_get_field_content_float(idx, "y", cHandle);
		CarInfo[idx+1][cZ] = cache_get_field_content_float(idx, "z", cHandle);
		CarInfo[idx+1][cFa] = cache_get_field_content_float(idx, "fa", cHandle);
		sscanf(CarInfo[idx+1][cColors], "p<,>a<i>[2]",CarInfo[idx+1][cColor]);
		CarInfo[idx+1][cID] = CreateVehicle(CarInfo[idx+1][cModel], CarInfo[idx+1][cX], CarInfo[idx+1][cY], CarInfo[idx+1][cZ], CarInfo[idx+1][cFa], CarInfo[idx+1][cColor][0], CarInfo[idx+1][cColor][1], 90000);
		if(CarInfo[idx+1][cID] == 65535) continue;
		strin = "";
		format(strin, sizeof(strin), "{ff4f00}Владелец: {ffffff}%s\n{ff4f00}ID: {ffffff}%d", CarInfo[idx+1][cOwner], CarInfo[idx+1][cID]);
		CarInfo[idx+1][cText] = Create3DTextLabel(strin, 0x33AAFFFF, 0.0, 0.0, 0.0, 50.0, 0, 1);
		Attach3DTextLabelToVehicle(CarInfo[idx+1][cText], CarInfo[idx+1][cID], 0.0, 0.0, 1.25);
		switch(CarInfo[idx+1][cLock])
		{
		case 0: IsLocked[CarInfo[idx+1][cID]] = false;
		case 1: IsLocked[CarInfo[idx+1][cID]] = true;
		}
		CarDoors(CarInfo[idx+1][cID], CarInfo[idx+1][cLock]);
		TOTALCARS++;
	}
	#if defined TM_DEBUG
		printf("[MySQL]: Личных машин загружено - %d",TOTALCARS);
	#endif
	return 1;
}
function: LoadLBizz() {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return 1;
	for(new idx; idx < rows; idx++) {

		LBizz[idx+1][lID] = cache_get_field_content_int(idx, "id", cHandle);
		cache_get_field_content(idx, "name", LBizz[idx+1][lName], cHandle, sizeof(qurey));
		cache_get_field_content(idx, "owner", LBizz[idx+1][lOwner], cHandle, sizeof(qurey));
		cache_get_field_content(idx, "worker1", LBizz[idx+1][lWorker_1], cHandle, sizeof(qurey));
		cache_get_field_content(idx, "worker2", LBizz[idx+1][lWorker_2], cHandle, sizeof(qurey));
		cache_get_field_content(idx, "worker3", LBizz[idx+1][lWorker_3], cHandle, sizeof(qurey));
		LBizz[idx+1][lPrice] = cache_get_field_content_int(idx, "price", cHandle);
		LBizz[idx+1][lCost] = cache_get_field_content_int(idx, "cost", cHandle);
		LBizz[idx+1][lMaterials][0] = cache_get_field_content_int(idx, "materials", cHandle);
		TOTALLBIZZ++;
	}
	// gold miner
	strin = "";
	format(strin,192,"Породы: %d килограмм",LBizz[1][lMaterials][0]);
	SetDynamicObjectMaterialText(LBizz[1][lObject], 0, strin, 130, "Tahoma", 35, 1, -1, -12303292, 1);
	CreateDynamic3DTextLabel("Устройство на работу",0xFFFFFFFF,378.9607,2540.8916,55.4018,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	CreateDynamic3DTextLabel("Место сдачи найденного золота",0xFFFFFFFF,378.2361,2537.6560,55.4018,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	LBizz[1][lCars][0] = CreateVehicleEx(543,-1370.0924,2074.1138,52.0427,89.2304,1,1,5000); // zoloto_sadler_1
	CreateVehicleEx(543,-1367.5579,2048.3723,52.2632,273.7960,1,1,5000); // zoloto_sadler_2
	LBizz[1][lCars][1] = CreateVehicleEx(486,-1384.5829,2055.7117,52.6261,2.7410,1,1,5000); // zoloto_dozer_1
	LBizz[1][lStartCP][0] = CreateDynamicPickup(2228,23,378.9607,2540.8916,55.4018, -1, -1,5000);
	LBizz[1][lStartCP][1] = CreateDynamicPickup(1210,23,378.2361,2537.6560,55.4018, -1, -1,5000);
	LBizz[1][lPickWork][0] = CreateDynamicPickup(19468, 23, -1360.6578,2101.7634,44.8636,-1,-1,5000);
	LBizz[1][lPickWork][1] = CreateDynamicPickup(19468, 23, -1361.9170,2102.9060,44.8636,-1,-1,5000);
	LBizz[1][lPickWork][2] = CreateDynamicPickup(19468, 23, -1363.2994,2103.8806,44.8636,-1,-1,5000);
	LBizz[1][lPickWork][3] = CreateDynamicPickup(19468, 23, -1364.7501,2105.2170,44.8636,-1,-1,5000);
	// сад

	LBizz[2][lCars][0] = CreateVehicleEx(422,-1073.3121338,-1203.7252197,129.2987976,179.9939575,-1,-1,900); //Bobcat
	LBizz[2][lCars][1] = CreateVehicleEx(422,-1070.1447754,-1203.5422363,129.2987976,184.0000000,-1,-1,900); //Bobcat
	GardenSmallCar = CreateVehicleEx(572,-1078.9373,-1203.4443,128.7986,179.9942627,86,1,5000); //Mower
	GardenWaterTruck = CreateVehicleEx(524,-1109.1920,-1183.1692,129.8433,173.2935,86,1,5000); //DFT-30

	LBizz[2][lStartCP][0] = CreateDynamicPickup(2228,23,-1064.6805,-1210.5090,129.2559, -1, -1);

	LBizz[2][lStartCP][1] = CreateButton(-1119.93, -1219.13, 129.80, -98.0);//CreateDynamicCP(-1119.1193,-1218.9299,129.2188, 1.5);
	CreateDynamic3DTextLabel("Управление системой поливки",0xFFFFFFFF,-1119.1193,-1218.9299,129.2188,10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);

	CreateDynamic3DTextLabel("Устройство на работу",0xFFFFFFFF,-1064.6805,-1210.5090,129.2559,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	for(new i;i<76;i++) {
		GardenTreesIDs[i][0] = CreateDynamicObject(737,GardenTrees[i][0],GardenTrees[i][1],GardenTrees[i][2],0.0,0.0,0.0);
		GardenTreesIs[i] = 410+random(30);
		GardenCheckpoints[i] = CreateDynamicCP(GardenTrees[i][0],GardenTrees[i][1],129.21875, 2.25);
	}
	CreateDynamicObject(11435, -1093.157958,-1177.025146,125.293319, 179.399902,-1.500001,0.600000);
	LBizz[2][lObject] = CreateDynamicObject(19477, -1093.6906, -1177.1851, 129.7187, 0.0000, 0.0000, 178.5585);

	format(strin,32,"%i литров",LBizz[2][lMaterials][1]);
	SetDynamicObjectMaterialText(LBizz[2][lObject], 0, strin, 130, "Arial", 37, 1, 0xFF5E6B92, -8092540, 1);
	CreateVehicleEx(486,-1322.8311768,-1614.6990967,-55.6311989,333.9998779,-1,-1,9999999); //Dozer

	#if defined TM_DEBUG
		printf("[MySQL]: Предприятий загружено - %d",TOTALLBIZZ);
	    print("************** [MySQL INFO] **************");
	#endif
	return 1;
}
function: LoadBizz() {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return 1;
	for(new idx; idx != rows; idx++) {

		BizzInfo[idx+1][id] = cache_get_field_content_int(idx, "id", cHandle);
		cache_get_field_content(idx, "owner", BizzInfo[idx+1][bOwner], cHandle, sizeof(qurey));
		BizzInfo[idx+1][bType] = cache_get_field_content_int(idx, "type", cHandle);
		BizzInfo[idx+1][bPrice] = cache_get_field_content_int(idx, "price", cHandle);
		BizzInfo[idx+1][bBuyPrice] = cache_get_field_content_int(idx, "buyprice", cHandle);
		BizzInfo[idx+1][bMoney] = cache_get_field_content_int(idx, "money", cHandle);
		BizzInfo[idx+1][bBank] = cache_get_field_content_int(idx, "bank", cHandle);
		BizzInfo[idx+1][bLic] = cache_get_field_content_int(idx, "lic", cHandle);
		BizzInfo[idx+1][bEntrx] = cache_get_field_content_float(idx, "x", cHandle);
		BizzInfo[idx+1][bEntry] = cache_get_field_content_float(idx, "y", cHandle);
		BizzInfo[idx+1][bEntrz] = cache_get_field_content_float(idx, "z", cHandle);
		BizzInfo[idx+1][bExitx] = cache_get_field_content_float(idx, "xt", cHandle);
		BizzInfo[idx+1][bExity] = cache_get_field_content_float(idx, "yt", cHandle);
		BizzInfo[idx+1][bExitz] = cache_get_field_content_float(idx, "zt", cHandle);
		BizzInfo[idx+1][bMenux] = cache_get_field_content_float(idx, "menux", cHandle);
		BizzInfo[idx+1][bMenuy] = cache_get_field_content_float(idx, "menuy", cHandle);
		BizzInfo[idx+1][bMenuz] = cache_get_field_content_float(idx, "menuz", cHandle);
		BizzInfo[idx+1][bInt] = cache_get_field_content_int(idx, "vint", cHandle);
		BizzInfo[idx+1][bVirtual] = cache_get_field_content_int(idx, "virt", cHandle);
		BizzInfo[idx+1][bMIcon] = cache_get_field_content_int(idx, "icon", cHandle);
		BizzInfo[idx+1][bINx] = cache_get_field_content_float(idx, "INx", cHandle);
		BizzInfo[idx+1][bINy] = cache_get_field_content_float(idx, "INy", cHandle);
		BizzInfo[idx+1][bINz] = cache_get_field_content_float(idx, "INz", cHandle);
		BizzInfo[idx+1][bINp] = cache_get_field_content_float(idx, "INp", cHandle);
		BizzInfo[idx+1][bEx] = cache_get_field_content_float(idx, "Ex", cHandle);
		BizzInfo[idx+1][bEy] = cache_get_field_content_float(idx, "Ey", cHandle);
		BizzInfo[idx+1][bEz] = cache_get_field_content_float(idx, "Ez", cHandle);
		BizzInfo[idx+1][bEp] = cache_get_field_content_float(idx, "Ep", cHandle);
		cache_get_field_content(idx, "name", BizzInfo[idx+1][bName], cHandle, sizeof(qurey));
		BizzInfo[idx+1][bEnter] = cache_get_field_content_int(idx, "penter", cHandle);
		BizzInfo[idx+1][bLock] = cache_get_field_content_int(idx, "block", cHandle);
		BizzInfo[idx+1][bProduct] = cache_get_field_content_int(idx, "product", cHandle);
		BizzInfo[idx+1][bTill] = cache_get_field_content_int(idx, "till", cHandle);
		BizzInfo[idx+1][bLockTime] = cache_get_field_content_int(idx, "locktime", cHandle);
		cache_get_field_content(idx, "Mafia", BizzInfo[idx+1][bMafia], cHandle, sizeof(qurey));
		if(BizzInfo[idx+1][bType] > 2) BizzInfo[idx+1][bIcon] = CreateDynamicMapIcon(BizzInfo[idx+1][bEntrx],BizzInfo[idx+1][bEntry],BizzInfo[idx+1][bEntrz], BizzInfo[idx+1][bMIcon], 0,-1,-1,-1,160.0);
		if(BizzInfo[idx+1][bType] != 2)
		{
			BizzInfo[idx+1][bPickup] = CreateDynamicPickup(19132,23, BizzInfo[idx+1][bEntrx],BizzInfo[idx+1][bEntry],BizzInfo[idx+1][bEntrz]);
			BizzInfo[idx+1][bPickupExit] = CreateDynamicPickup(19132, 23, BizzInfo[idx+1][bExitx],BizzInfo[idx+1][bExity],BizzInfo[idx+1][bExitz], BizzInfo[idx+1][bVirtual]);
			BizzInfo[idx+1][bMenu] = CreateDynamicCP(BizzInfo[idx+1][bMenux],BizzInfo[idx+1][bMenuy],BizzInfo[idx+1][bMenuz], 1.0,BizzInfo[idx+1][bVirtual],BizzInfo[idx+1][bInt]);
			strin = "";
			if(!strcmp(BizzInfo[idx+1][bOwner],"None",true)) {

				format(strin, 190, "<< Бизнес продается >>\nНазвание: %s\nЦена: %d", BizzInfo[idx+1][bName],BizzInfo[idx+1][bPrice]);
				LABELBIZZ[idx+1] = CreateDynamic3DTextLabel(strin,COLOR_YELLOW,BizzInfo[idx+1][bEntrx],BizzInfo[idx+1][bEntry],BizzInfo[idx+1][bEntrz],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
				Update3DTextLabelText(LABELBIZZ[idx], COLOR_YELLOW, strin);

			}
			else {
				format(strin, 190, "Владелец: %s\nНазвание: %s", BizzInfo[idx+1][bOwner], BizzInfo[idx+1][bName]);
				LABELBIZZ[idx+1] = CreateDynamic3DTextLabel(strin,COLOR_GREEN,BizzInfo[idx+1][bEntrx],BizzInfo[idx+1][bEntry],BizzInfo[idx+1][bEntrz],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
			}
		}
		else {
			if(!strcmp(BizzInfo[idx+1][bOwner],"None",true)) {
				format(strin, 190, "<< Бизнес продается >>\nНазвание: %s\nЦена за 1 литр - %i долларов\nЦена покупки: %d", BizzInfo[idx+1][bName], BizzInfo[idx+1][bTill] / 3,BizzInfo[idx+1][bPrice]);
				LABELBIZZ[idx+1] = CreateDynamic3DTextLabel(strin,COLOR_YELLOW,BizzInfo[idx+1][bEntrx],BizzInfo[idx+1][bEntry],BizzInfo[idx+1][bEntrz],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
				Update3DTextLabelText(LABELBIZZ[idx+1], COLOR_YELLOW, strin);
			}
			else {
				format(strin, 90, "Владелец: %s\nНазвание: %s\nЦена за 1 литр - %i долларов",  BizzInfo[idx+1][bOwner], BizzInfo[idx+1][bName], BizzInfo[idx+1][bTill] / 3);
				LABELBIZZ[idx+1] = CreateDynamic3DTextLabel(strin,COLOR_GREEN,BizzInfo[idx+1][bEntrx],BizzInfo[idx+1][bEntry],BizzInfo[idx+1][bEntrz],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
			}
		}
		TOTALBIZZ++;
	}
	#if defined TM_DEBUG
		printf("[MySQL]: Бизнесов загружено - %d",TOTALBIZZ);
	#endif
	return 1;
}
function: LoadPlayer(playerid) {
	PI[playerid][pID] = cache_get_field_content_int(0, "id", cHandle);
	cache_get_field_content(0, "Name", NamePlayer(playerid), cHandle, sizeof(qurey));
	cache_get_field_content(0, "Password", PI[playerid][pPassword], cHandle, sizeof(qurey));
	cache_get_field_content(0, "Email", PI[playerid][pEmail], cHandle, sizeof(qurey));
	PI[playerid][pTxt] = cache_get_field_content_int(0, "Txt", cHandle);
	PI[playerid][pPutMoney] = cache_get_field_content_int(0, "PutMoney", cHandle);
	PI[playerid][pAdmLevel] = cache_get_field_content_int(0, "Admin", cHandle);
	cache_get_field_content(0, "AdmKey", PI[playerid][pAdmKey], cHandle, sizeof(qurey));
	PI[playerid][pMuted] = cache_get_field_content_int(0, "Muted", cHandle);
	PI[playerid][pHeal] = cache_get_field_content_float(0, "Heal", cHandle);
	PI[playerid][pCash] = cache_get_field_content_int(0, "Cash", cHandle);
	PI[playerid][pSex] = cache_get_field_content_int(0, "Sex", cHandle);
	cache_get_field_content(0, "RegIp", PI[playerid][pRegIp], cHandle, sizeof(qurey));
	PI[playerid][pSkin] = cache_get_field_content_int(0, "Skin", cHandle);
	PI[playerid][pFracSkin] = cache_get_field_content_int(0, "FracSkin", cHandle);
	PI[playerid][pLevel] = cache_get_field_content_int(0, "Level", cHandle);
	PI[playerid][pExp] = cache_get_field_content_int(0, "Exp", cHandle);
	PI[playerid][pLeader] = cache_get_field_content_int(0, "Leader", cHandle);
	PI[playerid][pMember] = cache_get_field_content_int(0, "Member", cHandle);
	PI[playerid][pRank] = cache_get_field_content_int(0, "Rank", cHandle);
	PI[playerid][pWarn] = cache_get_field_content_int(0, "Warn", cHandle);
	PI[playerid][pJob] = cache_get_field_content_int(0, "Job", cHandle);
	PI[playerid][pSpining] = cache_get_field_content_int(0, "Spining", cHandle);
	PI[playerid][pJail] = cache_get_field_content_int(0, "Jail", cHandle);
	PI[playerid][pArmyBilet] = cache_get_field_content_int(0, "ArmyBilet", cHandle);
	PI[playerid][pHelpLevel] = cache_get_field_content_int(0, "Helper", cHandle);
	PI[playerid][pWatch] = cache_get_field_content_int(0, "Watch", cHandle);
	PI[playerid][pSprunk] = cache_get_field_content_int(0, "Sprunk", cHandle);
	PI[playerid][pAptechka] = cache_get_field_content_int(0, "Aptechka", cHandle);
	PI[playerid][pMask] = cache_get_field_content_int(0, "Mask", cHandle);
	PI[playerid][pHotel] = cache_get_field_content_int(0, "Hotel", cHandle);
	PI[playerid][pHotelNumber] = cache_get_field_content_int(0, "HotelNumber", cHandle);
	PI[playerid][pHunger] = cache_get_field_content_int(0, "Hunger", cHandle);
	PI[playerid][pSpawn] = cache_get_field_content_int(0, "Spawn", cHandle);
	PI[playerid][pHouseDrugs] = cache_get_field_content_int(0, "HouseDrugs", cHandle);
	PI[playerid][pHouseMoney] = cache_get_field_content_int(0, "HouseMoney", cHandle);
	PI[playerid][pSmoke] = cache_get_field_content_int(0, "Smoke", cHandle);
	PI[playerid][pBelay] = cache_get_field_content_int(0, "Belay", cHandle);
	PI[playerid][pWanted] = cache_get_field_content_int(0, "Wanted", cHandle);
	PI[playerid][pWantedTime] = cache_get_field_content_int(0, "WantedTime", cHandle);
	Skill[playerid] = cache_get_field_content_int(0, "FarmSkill", cHandle);
	Level[playerid] = cache_get_field_content_int(0, "FarmLevel", cHandle);
	PI[playerid][pJailTime] = cache_get_field_content_int(0, "JailTime", cHandle);
	PI[playerid][pPayCheck] = cache_get_field_content_int(0, "PayCheck", cHandle);
	PI[playerid][pDonateCash] = cache_get_field_content_int(0, "DonateCash", cHandle);
	PI[playerid][pNews] = cache_get_field_content_int(0, "News", cHandle);
	PI[playerid][pGrains] = cache_get_field_content_int(0, "Grains", cHandle);
	//
	PI[playerid][pWheels] = cache_get_field_content_int(0, "Wheels", cHandle);
	PI[playerid][pHydraulics] = cache_get_field_content_int(0, "Hydraulics", cHandle);
	PI[playerid][pNitro] = cache_get_field_content_int(0, "Nitro", cHandle);
	PI[playerid][pHBumper] = cache_get_field_content_int(0, "HBumper", cHandle);
	PI[playerid][pBBumper] = cache_get_field_content_int(0, "BBumper", cHandle);
	PI[playerid][pSpoilers] = cache_get_field_content_int(0, "Spoilers", cHandle);
	PI[playerid][pNeons] = cache_get_field_content_int(0, "Neons", cHandle);
	//
	cache_get_field_content(0, "InvKols", PI[playerid][pInvKols], cHandle, sizeof(qurey));
	sscanf(PI[playerid][pInvKols], "p<,>a<i>[20]", PI[playerid][pInvKol]);
	cache_get_field_content(0, "InvSlots", PI[playerid][pInvSlots], cHandle, sizeof(qurey));
	sscanf(PI[playerid][pInvSlots], "p<,>a<i>[20]", PI[playerid][pInvSlot]);
	cache_get_field_content(0, "Foods", PI[playerid][pFoods], cHandle, sizeof(qurey));
	sscanf(PI[playerid][pFoods], "p<,>a<i>[3]", PI[playerid][pFood]);
	cache_get_field_content(0, "Items", PI[playerid][pItems], cHandle, sizeof(qurey));
	sscanf(PI[playerid][pItems], "p<,>a<i>[5]", PI[playerid][pItem]);
	cache_get_field_content(0, "Licenses", PI[playerid][pLics], cHandle, sizeof(qurey));
	sscanf(PI[playerid][pLics], "p<,>a<i>[5]",PI[playerid][pLic]);
	//
	cache_get_field_content(0, "Phone", PI[playerid][pPhones], cHandle, sizeof(qurey));
	sscanf(PI[playerid][pPhones], "p<,>a<i>[3]", PI[playerid][pPhone]);
	cache_get_field_content(0, "Stuff", PI[playerid][pStuff], cHandle, sizeof(qurey));
	sscanf(PI[playerid][pStuff], "p<,>a<i>[3]",PI[playerid][pStuf]);
	cache_get_field_content(0, "GunSkills", PI[playerid][pGunSkills], cHandle, sizeof(qurey));
	sscanf(PI[playerid][pGunSkills], "p<,>a<i>[6]",PI[playerid][pGunSkill]);
	cache_get_field_content(0, "JobAmount", PI[playerid][pJobAmounts], cHandle, sizeof(qurey));
	sscanf(PI[playerid][pJobAmounts], "p<,>a<i>[3]",PI[playerid][pJobAmount]);
	//
	cache_get_field_content(0, "Guns", PI[playerid][pGuns], cHandle, sizeof(qurey));
	sscanf(PI[playerid][pGuns], "p<,>a<i>[13]",PI[playerid][pGun]);
	cache_get_field_content(0, "Ammos", PI[playerid][pAmmos], cHandle, sizeof(qurey));
	sscanf(PI[playerid][pAmmos], "p<,>a<i>[13]",PI[playerid][pAmmo]);
	//
	SetPlayerWantedLevel(playerid,PI[playerid][pWanted]);
	SetSpawnInfo(playerid, 255, PI[playerid][pSkin], 0, 0, 0, 1.0, -1, -1, -1, -1, -1, -1);
	PlayerLogged[playerid] = true;
	KillTimer(EnterTimer[playerid]);
	LoadMyCar(playerid);
	SetHealth(playerid, PI[playerid][pHeal]);
	SetMoney(playerid, PI[playerid][pCash]);
	GetPlayerIp(playerid,PI[playerid][pConnectIp],16);
	if(PI[playerid][pTxt] == 1) {
		SendClientMessageEx(playerid, COLOR_RED, "Ваш дом был продан гос-ву за неуплату налогов!"),SendClientMessageEx(playerid, COLOR_RED, "Деньги за дом были переведены на Ваш банковский счет.");
		PlusBankMoney(playerid, PI[playerid][pPutMoney]);
		PI[playerid][pTxt] = 0, PI[playerid][pPutMoney] = 0;
		SavePlayer(playerid);
	}
	CheckBank(playerid);
	SpawnPlayer(playerid);
	return 1;
}

function: GlobalAfkCheck() {
	foreach(new i: Player) {
		if(!PlayerLogged[i]) continue;
		if(GetPVarInt(i,"AFK_Tick") > 10000)
		{
			SetPVarInt(i,"AFK_Tick",1);
			SetPVarInt(i,"AFK_Check",0);
		}
		if(GetPVarInt(i,"AFK_Check") < GetPVarInt(i,"AFK_Tick") && GetPlayerState(i))
		{
			SetPVarInt(i,"AFK_Check",GetPVarInt(i,"AFK_Tick"));
			SetPVarInt(i,"AFK_Time",0);
		}
		if(GetPVarInt(i,"AFK_Check") == GetPVarInt(i,"AFK_Tick") && GetPlayerState(i))
		{
			SetPVarInt(i,"AFK_Time",GetPVarInt(i,"AFK_Time") + 1);
			if(GetPVarInt(i, "AFK_Time") > 2) {
				new CB[30];
				Convert(GetPVarInt(i,"AFK_Time")-2,CB);
				strins(CB,"На паузе: ",0);
				SetPlayerChatBubble(i,CB,COLOR_LIGHTRED,20.0,1200);
			}
		}
		if(GetPVarInt(i,"AFK_Time") >= 900 && PI[i][pAdmLevel] < 1)
		{
			if(PI[i][pAdmLevel] == 0 && AdminLogged[i] == false) NewKick(i,"Вы кикнуты т.к были не активны более 10 минут!");
		}
	}
}
function: OnPlayerRegCheck(playerid) {
	if(IsPlayerConnected(playerid)) {
		new rows, fields;
		cache_get_data(rows, fields);
		for(new c = 0; c < 19; c++) SendClientMessage(playerid, -1, " ");
		if(rows) LoadingToServer(playerid,0);
		else LoadingToServer(playerid,1);
	}
	return 1;
}
function: SeloLoad(playerid) {
	ApplyAnimation(playerid,"CARRY","crry_prtial",4.0,1,1,1,1,1,1);
	SetPlayerAttachedObject(playerid, 2, 2384, 5, 0.01, 0.1, 0.2, 100, 10, 85);
	SetPlayerCheckpoint(playerid,-22.2324,-186.5984,928.7820-1,3.0);
	SetPVarInt(playerid,"loadid",20);
	return true;
}
function: LoginCallback(i) {
	new rows, fields;
	cache_get_data(rows, fields);
	if(!rows) {
		if(GetPVarInt(i, "wrongPass") == 2) return CloseLoginPanel(i),NewKick(i,"Вы более 3 раз ввели неверно пароль!");
		SetPVarInt(i, "wrongPass", GetPVarInt(i, "wrongPass")+1);
		SendClientMessageEx(i, COLOR_YELLOW, "Неверный пароль, осталось попыток ввода: %i из 3",3 - GetPVarInt(i, "wrongPass"));
		KillTimer(EnterTimer[i]),EnterTimer[i] = SetTimerEx("PlayerKick",30000,false,"d",i);
		SPD(i, 2, DIALOG_STYLE_PASSWORD, "{96e300}Пароль", "{ffffff}Введите пароль:", "Готово", "");
		return 1;
	}
	PlayerRegs[i] = 0;
	PlayerLogin[i] = 0;
	LoadPlayer(i);
	ClickContinue(i);
	return 1;
}
function: FuelCheck() {
	foreach(new p: Player) {
		if(PI[p][pHunger] > 0) PI[p][pHunger] -= 1;
		if(PI[p][pHunger] < 1) PI[p][pHunger] = 0;
	}
	foreach(new i: MAX_CARS) {
		if(IsAPlane(i) || IsABoat(i) || GetVehicleModel(i) == 481 || GetVehicleModel(i) == 509 || GetVehicleModel(i) == 510) continue;
		if(Engine[i] && Fuel[i] > 0) Fuel[i]--;
		if(Fuel[i] <= 0)
		{
			foreach(new p: Player) {
				if(PlayerLogged[p] == false) continue;
				if(IsPlayerInVehicle(p,i)) {
					if(GetPlayerState(p) == PLAYER_STATE_DRIVER) {
						if(Engine[GetPlayerVehicleID(p)] == true) SendClientMessage(p, COLOR_GREY, "В авто закончился бензин!");
					}
				}
				break;
			}
			Engine[i] = false;
			GetVehicleParamsEx(i,engine,lights,alarm,doors,bonnet,boot,objective);
			SetVehicleParamsEx(i,VEHICLE_PARAMS_OFF,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective);
		}
	}
	return 1;
}
function: UpdateSpeedometr(playerid) {
	if(GetPlayerState(playerid) == 2) {
		new Float:Health,ktext[20],btext[20],etext[20],ltext[20];
		GetVehicleHealth(GetPlayerVehicleID(playerid),Health);
		if(IsLocked[GetPlayerVehicleID(playerid)] == true) PlayerTextDrawSetString(playerid, SpeedDraw[6][playerid],"doors: ~r~lock~n~");
		else PlayerTextDrawSetString(playerid, SpeedDraw[6][playerid],"doors: ~g~open~n~");
		if(Bonnets[GetPlayerVehicleID(playerid)] == false) ktext = "~r~K"; else if(Bonnets[GetPlayerVehicleID(playerid)] == true) ktext = "~g~K";
		if(Engine[GetPlayerVehicleID(playerid)] == false) etext = "~r~E"; else if(Engine[GetPlayerVehicleID(playerid)] == true) etext = "~g~E";
		if(Boots[GetPlayerVehicleID(playerid)] == false) btext = "~r~B"; else if(Boots[GetPlayerVehicleID(playerid)] == true) btext = "~g~B";
		if(Light[GetPlayerVehicleID(playerid)] == false) ltext = "~r~L"; else if(Light[GetPlayerVehicleID(playerid)] == true) ltext = "~g~L";
		strin = "";
		format(strin, sizeof(strin), "%s %s %s %s",etext,ltext,ktext,btext);
		PlayerTextDrawSetString(playerid,SpeedDraw[4][playerid],strin);
		format(SpeedString, 56,"S: %d km/h~n~F: %d L.~n~H: %d h.",SpeedVehicle(playerid) / 2,Fuel[GetPlayerVehicleID(playerid)],floatround(Health / 10));
		PlayerTextDrawSetString(playerid,SpeedDraw[5][playerid],SpeedString);
		strin = "";
		format(strin, sizeof(strin), "~w~%s",VehicleNameS[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
		PlayerTextDrawSetString(playerid, SpeedDraw[3][playerid], strin);
	}
}
function: AntiNopPutPlayerInVehicleEx(playerid) {
	if(!IsPlayerInAnyVehicle(playerid)) {
		if(PI[playerid][pAdmLevel] == 0 && AdminLogged[playerid] == false) NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (#1107)");
	}
}
function: AntiRemovePlayerFromVehicle(playerid) {
	if(IsPlayerInAnyVehicle(playerid)) {
		if(PI[playerid][pAdmLevel] == 0 && AdminLogged[playerid] == false) NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (#1108)");
	}
}
function: UpdateVehiclePos(vehicleid, type) {
	if(type == 1) BanCar[vehicleid] = false;
	GetVehiclePos(vehicleid, VehInfo[vehicleid][vPos][0], VehInfo[vehicleid][vPos][1], VehInfo[vehicleid][vPos][2]);
	GetVehicleZAngle(vehicleid, VehInfo[vehicleid][vPos][3]);
	return 1;
}
function: Stats(playerid,targetid) {
	new atext[20],dtext[20],ptext[20],btext[20],SubName[24],FracName[35],RankName[35];
	atext =  ""; SubName = ""; FracName = ""; RankName = "";

	new c = PI[playerid][pCars][0], CarStr[2][50];
	if(c != 0) {
		if(CarInfo[c][cModel] < 400) format(CarStr[0], 50, "Нет");
		else format(CarStr[0], 50, "%s ID %d", VehicleNameS[CarInfo[c][cModel]-400], CarInfo[c][cID]);
	}
	else format(CarStr[0], 50, "Нет");

	c = PI[playerid][pCars][1];
	if(c != 0) {
		if(CarInfo[c][cModel] < 400) format(CarStr[1], 50, "Нет");
		else format(CarStr[1], 50, "%s ID %d", VehicleNameS[CarInfo[c][cModel]-400], CarInfo[c][cID]);
	}
	else format(CarStr[1], 50, "Нет");

	if(GetPlayerHouse(targetid) == 0) dtext = "Нету"; else if(GetPlayerHouse(targetid) == 1) dtext = "Есть";
	if(PI[targetid][pSex] == 0) atext = "Мужчина"; else if(PI[targetid][pSex] == 1) atext = "Женщина";
	if(PI[targetid][pPhone][0] == 0) ptext = "Нету"; else if(PI[targetid][pPhone][0] == 1) ptext = "Есть";
	if(PI[targetid][pBelay] < 1) btext = "Нет"; else if(PI[targetid][pBelay] > 0) btext = "Есть";
	if(PI[targetid][pMember] > 0) FracName = Fraction[PI[targetid][pMember]-1]; else FracName = "---";

	new msg[] = "{ffffff}Имя:\t\t\t\t{3289ff}%s\n{ffffff}Уровень:\t\t\t%d\nОчки опыта:\t\t\t%d из %d\nНомер телефона:\t\t%i\n\
	Уровень розыска:\t\t%d\nНаркотики:\t\t\t%d\nМеталл:\t\t\t%d\nПатроны:\t\t\t%d\nПол:\t\t\t\t%s\n\nРабота:\t\t\t%s\nОрганизация:\t\t\t%s\nДолжность:\t\t\t%s\nСтраховка:\t\t\t%s\n\nПервое авто:\t\t\t%s\nВторое авто:\t\t\t%s\nДом:\t\t\t\t%s";
	strin = "";
	format(strin, 2000, msg, NamePlayer(targetid), PI[targetid][pLevel], PI[targetid][pExp], PI[targetid][pLevel]*4, PI[targetid][pPhone][1],PI[targetid][pWanted],PI[targetid][pStuf][0],PI[targetid][pStuf][1],PI[targetid][pStuf][2], atext, GetJobName(targetid),FracName, GetPlayerRankName(playerid), btext, CarStr[0], CarStr[1],GetPlayerHouse((targetid)) ? ("Есть") : ("Нет"));
	SPD(playerid,19,DIALOG_STYLE_MSGBOX,"{96e300}Статистика игрока",strin,"Назад","Закрыть");
}
function: GmTestCar(playerid,gm,Float:hp) {
	new Float:heal,Float:hm,text[54];
	GetVehicleHealth(GetPlayerVehicleID(gm),heal); hm = hp - heal;
	if(hm == 0) text = "{ff0000}Игрок возможно использует ГМ car.";
	else text = "{05e900}ГМ car не обноружено.";
	strin = "";
	format(strin,sizeof(strin),"До: %.1f\nПосле: %.1f\nHP Уменьшилось на: %.1f\n\n%s",hp,heal,hm,text);
	SPD(playerid,0,0,NamePlayer(gm),strin,"Закрыть","");
	SetVehicleHealth(GetPlayerVehicleID(gm),hp);
}
function: GmTest(playerid,gm,Float:hp) {
	new Float:heal,Float:hm,text[54];
	GetPlayerHealth(gm, heal); hm = hp - heal;
	if(hm == 0) text = "{ff0000}Игрок возможно использует ГМ.";
	else text = "{05e900}ГМ не обноружено.";
	strin = "";
	format(strin,sizeof(strin),"До: %.1f\nПосле: %.1f\nHP Уменьшилось на: %.1f\n\n%s",hp,heal,hm,text);
	SPD(playerid,0,0,NamePlayer(gm),strin,"Закрыть","");
	SetHealth(gm, hp);
}
function: KillGetTimer(killerid) {
	SetPlayerWantedLevel(killerid,PI[killerid][pWanted]);
	strin = "";
	format(strin,144,"Рация: В районе '%s' был найден труп. Подозреваемый: %s", gSAZones[GetPlayer2DZoneNumb(killerid)][SAZONE_NAME],NamePlayer(killerid));
	foreach(new i: Player) {
		if(PlayerLogged[i] != false && IsACop(i)) SendClientMessageEx(i, COLOR_ORANGE, strin),PlayerPlaySound(i, 2600+random(6), 0.0, 0.0, 0.0);
	}
	SendClientMessage(killerid, COLOR_LIGHTRED,"Труп был найден полицией, а вы были объявлены в розыск.");
	SendClientMessageEx(killerid, COLOR_YELLOW, "Ваш уровень розыска: %i", PI[killerid][pWanted]);
	PlayerPlaySound(killerid, 2600+random(6), 0.0, 0.0, 0.0);
	SavePlayer(killerid);
	return 1;
}
function: ProxDetectorS(Float:radi, playerid, targetid) {
	if(IsPlayerConnected(playerid)&&IsPlayerConnected(targetid)) {
		new Float:posx, Float:posy, Float:posz;
		new Float:oldposx, Float:oldposy, Float:oldposz;
		new Float:tempposx, Float:tempposy, Float:tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		GetPlayerPos(targetid, posx, posy, posz);
		tempposx = (oldposx -posx);
		tempposy = (oldposy -posy);
		tempposz = (oldposz -posz);
		if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
		{
			return true;
		}
	}
	return false;
}
function: ClearAnimTextVar(playerid) {
	ApplyAnimation(playerid,"CARRY","crry_prtial",4.0,0,0,0,0,0);
	DeletePVar(playerid,"Animation");
	return 1;
}
function: ClearAnimText(playerid) return ApplyAnimation(playerid, "CARRY", "crry_prtial",4.0,0,0,0,0,0,1);
function: CollectorGet(playerid) {
	new tmpt = GetPVarInt(playerid,"Collector_LTree")-1;
	if(tmpt == -1) return true;
	GardenTreesIs[tmpt]-=1;
	if(GardenTreesIs[tmpt]<=0) {
		DestroyDynamicObject(GardenTreesIDs[tmpt][0]);
		DestroyDynamicCP(GardenCheckpoints[tmpt]);
		GardenTreesIDs[tmpt][0] = CreateDynamicObject(780,GardenTrees[tmpt][0],GardenTrees[tmpt][1],GardenTrees[tmpt][2],0.0,0.0,0.0);
		GardenTreesIs[tmpt]=-1;
		DeletePVar(playerid,"Collector_LTree");
	}
	GameTextForPlayer(playerid, "+1", 750, 3);
	SetPVarInt(playerid,"Collector_Treed",GetPVarInt(playerid,"Collector_Treed")+1);
	SetPVarInt(playerid, "Collector_NotGived",GetPVarInt(playerid, "Collector_NotGived")+1);
	if(GetPVarInt(playerid,"Collector_NotGived") >= 30) {
		SetPlayerAttachedObject(playerid,4,19091,5,0.135999,0.072000,0.140999,10.600007,35.499988,178.599975,0.264999,0.075000,0.352000),SetPlayerSpecialAction(playerid,SPECIAL_ACTION_CARRY);
		if(GardenCPicks[0] == 0 && GardenCPicks[1] == 0)
		{
			for(new idx;idx < 76;idx++) {
				if(GardenCheckpoints[idx] != 0) TogglePlayerDynamicCP(playerid, GardenCheckpoints[idx], 0);
			}
			SetPlayerCheckpoint(playerid,-1082.6498,-1195.5306,129.2188,2.0),SendClientMessage(playerid,COLOR_YELLOW,"Ящик заполнен, положите его на склад.");
		}
		else SendClientMessage(playerid,COLOR_YELLOW,"Ящик заполнен, положите его в машину.");
	}
	DeletePVar(playerid,"Collector_Getting");
	ApplyAnimation(playerid, "CAMERA", "picstnd_out", 4.1, 0, 1, 1, 1, 1, 1);
	SetTimerEx("ClearAnimTextVar",750,false,"i",playerid);
	return 1;
}
function: timer_rockp(playerid) {
	DestroyObject(rock_a[playerid]);
	KillTimer(timer_rock);
}
function: ResetAntiFloodPick(playerid) return SetPVarInt(playerid, "PickupID", -1);
function: Startload(playerid) {
	TogglePlayerControllable(playerid, 1);
	new tmpcar = GetPlayerVehicleID(playerid);
	new Float:X,Float:Y,Float:Z;
	GetVehiclePos(tmpcar, X, Y, Z);
	GetXYInFrontOfPlayers(playerid, X, Y, -4.5);
	SetVehicleParamsEx(tmpcar,VEHICLE_PARAMS_OFF,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective);
	AmmoPickup[tmpcar] = CreateDynamicPickup(2358,23,X,Y,Z+0.5);
	strin = "";
	switch(PI[playerid][pMember]) {
	case F_BALLAS: {
			strin = "";
			format(strin, sizeof(strin), "%d/2000",LoadAmmoInfo[tmpcar-GangAmmoCar[0]][gBallas]);
			AmmoText[tmpcar] = Create3DTextLabel(strin,COLOR_YELLOW,X,Y,Z+0.3,40.0,0,1);
		}
	case F_VAGOS: {
			strin = "";
			format(strin, sizeof(strin), "%d/2000",LoadAmmoInfo[tmpcar-GangAmmoCar[2]][gVagos]);
			AmmoText[tmpcar] = Create3DTextLabel(strin,COLOR_YELLOW,X,Y,Z+0.3,40.0,0,1);
		}
	case F_GROVE: {
			strin = "";
			format(strin, sizeof(strin), "%d/2000",LoadAmmoInfo[tmpcar-GangAmmoCar[1]][gGrove]);
			AmmoText[tmpcar] = Create3DTextLabel(strin,COLOR_YELLOW,X,Y,Z+0.3,40.0,0,1);
		}
	case F_AZTEC: {
			strin = "";
			format(strin, sizeof(strin), "%d/2000",LoadAmmoInfo[tmpcar-GangAmmoCar[3]][gAztek]);
			AmmoText[tmpcar] = Create3DTextLabel(strin,COLOR_YELLOW,X,Y,Z+0.3,40.0,0,1);
		}
	case F_RIFA: {
			strin = "";
			format(strin, sizeof(strin), "%d/2000",LoadAmmoInfo[tmpcar-GangAmmoCar[4]][gRifa]);
			AmmoText[tmpcar] = Create3DTextLabel(strin,COLOR_YELLOW,X,Y,Z+0.3,40.0,0,1);
		}
	}
	SendClientMessage(playerid, COLOR_PAYCHEC, "Процесс загрузки патронов начался!");
	RemovePlayerFromVehicleEx(playerid);
	Start[tmpcar] = 1;
	KillTimer(loadtimer);
	loadtimers = 0;
	return true;
}
function: AdminFly(playerid) {
	if(!IsPlayerConnected(playerid))
	return flying[playerid] = false;
	if(flying[playerid]) {
		if(!IsPlayerInAnyVehicle(playerid))
		{
			new keys, ud, lr, Float:x[2], Float:y[2], Float:z;
			GetPlayerKeys(playerid, keys, ud, lr);
			GetPlayerVelocity(playerid, x[0], y[0], z);
			if(ud == KEY_UP) {
				GetPlayerCameraPos(playerid, x[0], y[0], z);
				GetPlayerCameraFrontVector(playerid, x[1], y[1], z);
				ApplyAnimation(playerid, "PARACHUTE", "FALL_SkyDive_Accel", 4.1, 1, 1, 1, 1, 1);
				SetPlayerToFacePos(playerid, x[0] + x[1], y[0] + y[1]);
				SetPlayerVelocity(playerid, x[1], y[1], z);
			}
			else SetPlayerVelocity(playerid, 0.0, 0.0, 0.01);
		}
		SetTimerEx("AdminFly", 100, 0, "d", playerid);
	}
	return 0;
}
function: Float:SetPlayerToFacePos(playerid, Float:X, Float:Y) {
	new Float:pX1, Float:pY1, Float:pZ1, Float:ang;
	if(!IsPlayerConnected(playerid)) return 0.0;
	GetPlayerPos(playerid, pX1, pY1, pZ1);
	if( Y > pY1 ) ang = (-acos((X - pX1) / floatsqroot((X - pX1)*(X - pX1) + (Y - pY1)*(Y - pY1))) - 90.0);
	else if( Y < pY1 && X < pX1 ) ang = (acos((X - pX1) / floatsqroot((X - pX1)*(X - pX1) + (Y - pY1)*(Y - pY1))) - 450.0);
	else if( Y < pY1 ) ang = (acos((X - pX1) / floatsqroot((X - pX1)*(X - pX1) + (Y - pY1)*(Y - pY1))) - 90.0);
	if(X > pX1) ang = (floatabs(floatabs(ang) + 180.0));
	else ang = (floatabs(ang) - 180.0);
	ang += 180.0;
	SetPlayerFacingAngle(playerid, ang);
	return ang;
}
function: MaskOff(playerid){
	SetPlayerTeamColor(playerid);
	maskuse[playerid] = 0;
	PI[playerid][pMask]--;
	for(new i = 0; i < MAX_ITEMS; i++){
		if(PI[playerid][pInvSlot][i] == 17) {
			if(PI[playerid][pInvKol][i] != 1) PI[playerid][pInvKol][i] -= 1;
			else PI[playerid][pInvSlot][i] = 0,PI[playerid][pInvKol][i] = 0;
		}
	}
	SetPlayerChatBubble(playerid, "{FF9900}Снимает маску", -1, 20.0, 500);
	GameTextForPlayer(playerid, "~y~ INVISABLE OFF", 800, 4);
	PlayerPlaySound(playerid, 21001, 0.0, 0.0, 0.0);
	return true;
}
function: DeleteAccount(playerid,deletename[]) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(!rows) return SendClientMessage(playerid, COLOR_GREY, "Данный игрок не найден в базе данных!");
	query = "";
	format(query, sizeof(query), "DELETE FROM "TABLE_ACCOUNT" WHERE name = '%s'",deletename);
	mysql_function_query(cHandle, query, false, "", "");
	SendClientMessageEx(playerid, COLOR_LIGHTRED, "Вы удалили акаунт игрока: %s", deletename);
	return 1;
}
function: UnBanPlayer(playerid,unbanname[]) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(!rows) return SendClientMessage(playerid, COLOR_GREY, "Данный игрок не найден в базе данных!");
	query = "";
	format(query, sizeof(query), "DELETE FROM bans WHERE name = '%s'",unbanname);
	mysql_function_query(cHandle, query, false, "", "");
	SendClientMessageEx(playerid, COLOR_LIGHTRED, "Вы разбанили игрока: %s", unbanname);
	return 1;
}
function: OffUninvite(playerid,name[]) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows) {
		new uninviteid;
		sscanf(name, "u", uninviteid);
		if(IsPlayerConnected(uninviteid) && PlayerLogged[uninviteid] != false) return SendClientMessage(playerid, COLOR_GREY, "Данный игрок онлайн!");
		query = "";
		format(query, 256, "UPDATE "TABLE_ACCOUNT" SET Member = '0', Leader = '0', Rank = '0', Guns = '0,0,0,0,0,0,0,0,0,0,0,0,0', Ammos = '0,0,0,0,0,0,0,0,0,0,0,0,0' WHERE Name = '%s'", name);
		mysql_function_query(cHandle, query, false, "", "");
		SendClientMessageEx(playerid, COLOR_GREEN, "Вы уволили: %s из %s",name,Fraction[PI[playerid][pMember]-1]);
	}
	else SendClientMessage(playerid, COLOR_LIGHTRED, "Игрок не состоит в Вашей организации!");
	return 1;
}
function: UpdateSpecPanel(playerid) {
	if(!IsPlayerConnected(GetPVarInt(playerid, "SpecID"))) return StopRecon(playerid, "~r~SPEC: PLAYER DISCONNECT");
	new text[1048], Float:health, Float:vhealth, Float:armour;
	GetPlayerHealth(GetPVarInt(playerid, "SpecID"), health);
	GetVehicleHealth(GetPlayerVehicleID(GetPVarInt(playerid, "SpecID")), vhealth);
	GetPlayerArmour(GetPVarInt(playerid, "SpecID"), armour);
	format(text, sizeof(text), "%s~n~Health: %d~n~Armour: %d~n~Health Car: %d~n~Money: %d$~n~Warns: %d/3~n~Ping: %d~n~Speed: %d km/h",NamePlayer(GetPVarInt(playerid, "SpecID")),floatround(health, floatround_round),floatround(armour, floatround_round),floatround(vhealth, floatround_round),PI[GetPVarInt(playerid, "SpecID")][pCash],PI[GetPVarInt(playerid, "SpecID")][pWarn],GetPlayerPing(GetPVarInt(playerid, "SpecID")),SpeedVehicle(GetPVarInt(playerid, "SpecID"))/2);
	PlayerTextDrawSetString(playerid, SpecTD[14][playerid], text);
	format(text, sizeof(text), "%d", GetPVarInt(playerid, "SpecID"));
	PlayerTextDrawSetString(playerid, SpecTD[9][playerid], text);
	return true;
}
function: Gambler(playerid) {
	if(Gambling[playerid] != G_STATE_GAMBLING) {
		KillTimer(SlotTimer[playerid]);
		SlotTimer[playerid] = -1;
		Gambling[playerid] = G_STATE_NOT_GAMBLING;
		return false;
	}
	SlotCounter[playerid] -= 1;
	new slot = SlotCounter[playerid];
	if(slot < 10) Slots[playerid][2]+=random(3)+1;
	else if(slot < 20) {
		Slots[playerid][1]+=random(3)+1;
		Slots[playerid][2]+=random(3)+1;
	}
	else {
		Slots[playerid][0]+=random(3)+1;
		Slots[playerid][1]+=random(3)+1;
		Slots[playerid][2]+=random(3)+1;
	}
	if(Slots[playerid][0] >= 6) Slots[playerid][0] = 0;
	if(Slots[playerid][1] >= 6) Slots[playerid][1] = 0;
	if(Slots[playerid][2] >= 6) Slots[playerid][2] = 0;
	ShowPlayerSlots(playerid,Slots[playerid][0],Slots[playerid][1],Slots[playerid][2]);
	if(SlotCounter[playerid] == 0) {
		KillTimer(SlotTimer[playerid]);
		SlotTimer[playerid] = -1;
		Gambling[playerid] = G_STATE_DISPLAY;
		SetTimerEx("PlayAgainTimer",600,false,"i",playerid);
		if(Slots[playerid][0] == Slots[playerid][1] && Slots[playerid][0] == Slots[playerid][2]) {
			new Multiplier=Random(2000,12000);
			switch(Slots[playerid][0]) {
			case 0: Multiplier = 2000;   // Cherries
			case 1: Multiplier = 4000;   // Grapes
			case 2: Multiplier = 6000;   // 69's
			case 3: Multiplier = 8000;   // Bells
			case 4: Multiplier = 10000;  // Bar
			case 5: Multiplier = 12000;  // Double Bars
			}
			new money = GetPVarInt(playerid,"BET") + Multiplier;
			strin = "";
			format(strin,sizeof(strin),"~w~Winner: ~g~+%d$~w~!~n~_",money);
			GameTextForPlayer(playerid,strin,4000,4);
			SetPVarInt(playerid,"BALANCE",GetPVarInt(playerid,"BALANCE")+money);
			Slots[playerid][0] = random(5);
			Slots[playerid][1] = random(5);
			Slots[playerid][2] = random(5);
			strin = "";
			format(strin,64,"~g~BALANCE: %d$~n~CTABKA: %d$",GetPVarInt(playerid,"BALANCE"),GetPVarInt(playerid,"BET"));
			PlayerTextDrawSetString(playerid, CasinoDraw[10][playerid], strin);
		}
		else {
			if(Slots[playerid][0] == Slots[playerid][1] || Slots[playerid][1] == Slots[playerid][2] || Slots[playerid][0] == Slots[playerid][2]) {
				strin = "";
				format(strin,sizeof(strin),"~w~Loser: ~r~-%d$~w~!~n~_",GetPVarInt(playerid,"BET"));
				GameTextForPlayer(playerid,strin,4000,4);
			}
		}
		return true;
	}
	return false;
}
function: Random(min, max) {
	new a = random(max - min) + min;
	return a;
}
function: GatDerevo(playerid) {
	KillTimer(DerevoTimer[playerid]);
	DestroyObject(gDerevo[GetPVarInt(playerid, "Derevo")]);
	DisablePlayerCheckpoint(playerid);
	DerevoP[GetPVarInt(playerid, "Derevo")] = CreateDynamicPickup(1463, 3,Derevo[GetPVarInt(playerid, "Derevo")][0],Derevo[GetPVarInt(playerid, "Derevo")][1],Derevo[GetPVarInt(playerid, "Derevo")][2]+1.5,-1,-1,playerid);
	return 0;
}
function: GateBus() {
	MoveObject(Object[1],1217.2049561,-1842.4620361,13.1660004-0.004,0.004, 0.00000000,269.0000000,0.00000000);
	GateOpened[0] = 0;
	return 0;
}
function: GateBusTy() {
	MoveObject(Object[2],1273.5322266,-1842.4619141,13.1660004-0.004,0.004, 0.00000000,269.0000000,0.00000000);
	GateOpened[1] = 0;
	return 0;
}
function: GateA51() {
	MoveObject(Object[7],348.9490051, 1800.5999756, 18.100000, 5.0);
	GateOpened[5] = 0;
	return 0;
}
function: GateTaxi() {
	MoveObject(Object[3],1101.8370361,-1736.0090332,13.2410002-0.004,0.004, 0.00000000,269.0000000,90.00000000);
	GateOpened[2] = 0;
	return 0;
}
function: GateLspd() {
	MoveObject(Object[6],1544.682495, -1630.980000, 13.215000-0.004,0.004, 0.00000000,90.0000000,90.00000000);
	GateOpened[7] = 0;
	return 0;
}
function: Gate51() {
	MoveObject(Object[4], 285.793, 1821.920, 19.887, 5.0);
	GateOpened[3] = 0;
	return 0;
}
function: Gate51a() {
	MoveObject(Object[5], 135.614, 1941.291, 21.577, 5.0);
	GateOpened[4] = 0;
	return 0;
}
function: GateBunker51() {
	MoveObject(Object[8], 214.677,1875.406,13.891, 5.0);
	GateOpened[6] = 0;
	return 0;
}
function: PlayerKick(playerid) {
	if(PlayerLogged[playerid] != true) {
		KillTimer(EnterTimer[playerid]);
		NewKick(playerid, "Время на ввод данных ограничено (4 минуты).");
	}
}
function: GardenWater() {
	for(new i; i < 76; i++) {
		if(GardenTreesIs[i] == 0) {
			DestroyDynamicObject(GardenTreesIDs[i][0]);
			GardenTreesIDs[i][0] = CreateDynamicObject(737,GardenTrees[i][0],GardenTrees[i][1],GardenTrees[i][2],0.0,0.0,0.0);
			//			MoveDynamicObject(GardenTreesIDs[i][0],GardenTrees[i][0],GardenTrees[i][1],GardenTrees[i][2],0.5);
			GardenCheckpoints[i] = CreateDynamicCP(GardenTrees[i][0],GardenTrees[i][1],129.21875, 2.25);
			GardenTreesIs[i] = 75;
			if(i < 51) DestroyDynamicObject(GardenTreesIDs[i][1]);
		}
	}
	GardenSys = 0;
	LBizz[2][lMaterials][1] -= 3000;
	strin = "";
	format(strin,32,"%i литров",LBizz[2][lMaterials][1]);
	SetDynamicObjectMaterialText(LBizz[2][lObject], 0, strin, 130, "Arial", 37, 1, 0xFF5E6B92, -8092540, 1);
	UpdateGardenAllCPs();
	return 1;
}
function: GardenEnd(playerid) {
	DisablePlayerCheckpoint(playerid);
	new rand = random(sizeof(TreeSad));
	SetPlayerCheckpoint(playerid,TreeSad[rand][0],TreeSad[rand][1],TreeSad[rand][2],3.0);
	ClearAnimations(playerid);
	SetPVarInt(playerid, "Garden", 1);
	spect = "";
	format(spect,32,"AMOUNT: %d KG",AmmountWood[playerid]);
	TextDrawSetString(GardenDraw[playerid],spect);
	return true;
}
function: PlayerToPoint(Float:radi, playerid, Float:x, Float:y, Float:z) {
	new Float:oldposx, Float:oldposy, Float:oldposz;
	new Float:tempposx, Float:tempposy, Float:tempposz;
	GetPlayerPos(playerid, oldposx, oldposy, oldposz);
	tempposx = (oldposx -x);
	tempposy = (oldposy -y);
	tempposz = (oldposz -z);
	if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi))) return true;
	return false;
}
function: GardenAnimation(playerid) ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,1,1,1,1,0),TogglePlayerControllable(playerid,true);

function: KickPublic(playerid) {
	if(IsPlayerConnected(playerid)) {
		ResetPlayerWeapons(playerid);
		DeletePVar(playerid, "kicked");
		Kick(playerid);
	}
}
function: SecTimer() {
	for(new i; i != 20; i++)
	if(FrakCD[i] > 0) FrakCD[i]--;

	GzCheck();
	CheckBasketBall();
	for(new i = 1; i <= TOTALGZ; i++) {
		if(GZSafeTime[i] > 0)
		GZSafeTime[i]--;

	}
	if(TOTALDEREVO == 37) {
		for(new i; i < sizeof(Derevo); i++)
		{
			DestroyObject(gDerevo[i]);
			gDerevo[i] = CreateObject(616,Derevo[i][0],Derevo[i][1],Derevo[i][2],0.0000000,0.0000000,0.0000000);
		}
		TOTALDEREVO = 0;
	}
	GlobalAfkCheck();

	foreach(new i: Player) {
		if(!PlayerLogged[i]) continue;
		if(PI[i][pHunger] < 1) SetHealth(i,PI[i][pHeal] - 0.1);
		SetPlayerProgressBarValue(i, HungerBar[i], PI[i][pHunger]);
		UpdatePlayerProgressBar(i, HungerBar[i]);
		if(GetPVarInt(i, "BrosilBBall") > 0)  SetPVarInt(i, "BrosilBBall", -1);
		if(GetPVarInt(i,"FishJob") == JOB_MIDIA)
		{
			if(GetPVarInt(i, "score_midii") == 1) {
				PTD_midii[i] = CreatePlayerTextDraw(i, 609.599609, 131.413314, "MIDII:_0/30");
				PlayerTextDrawLetterSize(i, PTD_midii[i], 0.338799, 1.032532);
				PlayerTextDrawAlignment(i, PTD_midii[i], 3);
				PlayerTextDrawColor(i, PTD_midii[i], -65281);
				PlayerTextDrawSetShadow(i, PTD_midii[i], 0);
				PlayerTextDrawSetOutline(i, PTD_midii[i], 1);
				PlayerTextDrawBackgroundColor(i, PTD_midii[i], 51);
				PlayerTextDrawFont(i, PTD_midii[i], 2);
				PlayerTextDrawSetProportional(i, PTD_midii[i], 1);
				PlayerTextDrawShow(i, PTD_midii[i]);
				DeletePVar(i, "score_midii");
			}
			else if(GetPVarInt(i, "score_midii") > 1) SetPVarInt(i, "score_midii", GetPVarInt(i, "score_midii") - 1);
			if(boxygen[i] == INVALID_PLAYER_BAR_ID) continue;
			if(isAWaterPlayer(i) == 2) {
				if(GetPVarInt(i,"FishOxygen") == 0) {
					SetHealth(i, 0);
					SendClientMessage(i, -1, "Закончился кислород.");
					PlayerTextDrawHide(i, PTD_oxygen[i]);
					PlayerTextDrawDestroy(i, PTD_oxygen[i]);
				}
				else if(GetPVarInt(i,"FishOxygen") > 0 && GetPVarInt(i,"FishOxygen") < 600) {
					SetHealth(i, 200);
					SetPVarInt(i,"FishOxygen",GetPVarInt(i,"FishOxygen")-1);
					SetPlayerProgressBarValue(i, boxygen[i], GetPVarInt(i,"FishOxygen"));
					UpdatePlayerProgressBar(i, boxygen[i]);
					new stroxygen[5+1];
					format(stroxygen, sizeof stroxygen, "%i:%i", GetPVarInt(i,"FishOxygen") / 60, GetPVarInt(i,"FishOxygen") - (60 * (GetPVarInt(i,"FishOxygen") / 60)));
					PlayerTextDrawSetString(i, PTD_oxygen[i], stroxygen);
				}
			}
		}
		if(IDVEH[i] != -1 && IsPlayerConnected(i) && IsPlayerInAnyVehicle(i) && !UseEnter[i] && IDVEH[i] != GetPlayerVehicleID(i)) Punish(i);
		if(Level[i] == 1 && Skill[i] >= 1000)
			Level[i]++, SendClientMessage(i, -1, "Ваш навык работы на ферме повышен (/fskill)");
		if(Level[i] == 2 && Skill[i] >= 2000)
			Level[i]++, SendClientMessage(i, -1, "Ваш навык работы на ферме повышен (/fskill)");
		if(Level[i] == 3 && Skill[i] >= 3000)
			Level[i]++, SendClientMessage(i, -1, "Ваш навык работы на ферме повышен (/fskill)");

		CheckWeapon(i);
		TCheckSpeed(i);
		new Gun = 0;
		GunLoop:
		if(GetPlayerWeapon(i) == BanWeap[Gun])
		{
			if(PI[i][pAdmLevel] < 1) {
				ResetWeapon(i);
				GunCheckTime[i] = 5;
			}
		}
		Gun++;
		if(Gun < sizeof(BanWeap)) goto GunLoop;
		new Float:Pos_x,Float:Pos_y,Float:Pos_z;
		new anim = GetPlayerAnimationIndex(i);
		GetPlayerVelocity(i,Pos_x,Pos_y,Pos_z);
		if((Pos_x <= -0.800000  || Pos_y <= -0.800000 || Pos_z <= -0.800000) && (anim == 1008 || anim == 1539))
			if(PI[i][pAdmLevel] < 1) NewKick(i,"[Античит]: Вы кикнуты по подозрению в читерстве (Fly Hacking)");

		new Float:x, Float:y, Float:z;
		GetPlayerPos(i, x, y, z);
		if((!IsPlayerInRangeOfPoint(i, 2.0, x, y, z)) && (IsPlayerInRangeOfPoint(i, 3.0, AC_PI[i][pClicked][0], AC_PI[i][pClicked][1], AC_PI[i][pClicked][2])))
		if(PI[i][pAdmLevel] < 1) NewKick(i,"[Античит]: Вы кикнуты по подозрению в читерстве (#1512)");
		if(PI[i][pAdmLevel] == 0)
		{
			new Float:vhelti; GetVehicleHealth(GetPlayerVehicleID(i), vhelti);
			if(GetPlayerState(i) == PLAYER_STATE_DRIVER) {
				if(vhelti < AutoHelti[i])
				AutoHelti[i] = vhelti;

				if(GetPVarInt(i, "VehicleRepair") == 1) {
					AutoHelti[i] = vhelti;
					SetPVarInt(i, "VehicleRepair", 0);
				}
				if(IsPlayerInRangeOfPoint(i, 15, 719.9484,-457.3498,16.4282) || IsPlayerInRangeOfPoint(i, 15, -1420.6052,2584.6243,55.9356) || IsPlayerInRangeOfPoint(i, 15, -99.7463,1116.9677,19.8340)|| IsPlayerInRangeOfPoint(i, 15, 2063.4375,-1831.9276,13.6391)||
						IsPlayerInRangeOfPoint(i, 15, -2425.9333,1022.5239,50.4900) || IsPlayerInRangeOfPoint(i, 15, 1974.0004,2162.5266,11.1561) || IsPlayerInRangeOfPoint(i, 15, 487.5558,-1739.5125,11.2265)|| IsPlayerInRangeOfPoint(i, 15, 1025.3940,-1024.2563,32.1938)||
						IsPlayerInRangeOfPoint(i, 15, 2393.6174,1489.2686,10.9246)||IsPlayerInRangeOfPoint(i, 15, -1905.1163,283.4408,41.1392)) {
					AutoHelti[i] = vhelti;
					SetPVarInt(i, "VehicleRepair", 1);
				}
				if(vhelti > AutoHelti[i] && GetPlayerInterior(i) == 0 && GetPVarInt(i, "VehicleRepair") == 0) {
					if(!IsPlayerInRangeOfPoint(i, 15, 719.9484,-457.3498,16.4282) || !IsPlayerInRangeOfPoint(i, 15, -1420.6052,2584.6243,55.9356) || !IsPlayerInRangeOfPoint(i, 15, -99.7463,1116.9677,19.8340)|| !IsPlayerInRangeOfPoint(i, 15, 2063.4375,-1831.9276,13.6391)||
							!IsPlayerInRangeOfPoint(i, 15, -2425.9333,1022.5239,50.4900) || !IsPlayerInRangeOfPoint(i, 15, 1974.0004,2162.5266,11.1561) || !IsPlayerInRangeOfPoint(i, 15, 487.5558,-1739.5125,11.2265)|| !IsPlayerInRangeOfPoint(i, 15, 1025.3940,-1024.2563,32.1938)||
							!IsPlayerInRangeOfPoint(i, 15, 2393.6174,1489.2686,10.9246)||!IsPlayerInRangeOfPoint(i, 15, -1905.1163,283.4408,41.1392)) {
						if(InShop[i] > 0) return 1;
						if(InTuning[i] > 0) return 1;
						if(PI[i][pAdmLevel] < 1) NewKick(i,"[Античит]: Вы кикнуты по подозрению в читерстве (#1264)");
					}
				}
			}
		}
		new weapons[13][3];
		if(PI[i][pAdmLevel] < 3)
		{
			for (new j = 0; j < 13; j++) {
				if(!IsPlayerInAnyVehicle(i)) {
					GetPlayerWeaponData(i, j, weapons[j][1], weapons[j][2]);
					if(weapons[j][1] == 27 || weapons[j][1] == 19
							|| weapons[j][1] == 20 || weapons[j][1] == 21 || weapons[j][1] == 35 || weapons[j][1] == 36 || weapons[j][1] == 39 || weapons[j][1] == 40 || weapons[j][1] == 44 || weapons[j][1] == 45
							|| weapons[j][1] == 38 || weapons[j][1] == 32 || weapons[j][1] == 28 || weapons[j][1] == 18 || weapons[j][1] == 37 || weapons[j][1] == 16)
					ResetWeapon(i),NewKick(i,"[Античит]: Вы кикнуты по подозрению в читерстве (#1145)");

				}
			}
		}
		if(GetPVarInt(i,"GetGun") > 0) SetPVarInt(i,"GetGun",GetPVarInt(i,"GetGun") - 1);
		CheckHealArmour[i]--;
		if(CheckHealArmour[i] == 0)
		{
			new Float:Armour,Float:Heal;
			GetPlayerHealth(i, Heal); GetPlayerArmour(i, Armour);
			if(PI[i][pArmur] < Armour) SetPlayerArmour(i, PI[i][pArmur]); else PI[i][pArmur] = Armour;
			if(PI[i][pHeal] < Heal) SetHealth(i, PI[i][pHeal]); else PI[i][pHeal] = Heal;
			CheckHealArmour[i] = 5;
		}
		if(GetPVarInt(i, "AntiBreik") > 0) SetPVarInt(i, "AntiBreik", GetPVarInt(i, "AntiBreik") - 1);
		if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_USEJETPACK)
		if(PI[i][pAdmLevel] == 0 && AdminLogged[i] == false) NewKick(i,"[Античит]: Вы кикнуты по подозрению в читерстве (#1102)");

		if(GetPlayerState(i) == PLAYER_STATE_DRIVER) {
			if(!GetPVarInt(i, "LicTest")) {
				new vehicleid = GetPlayerVehicleID(i);
				if(GetVehicleModel(vehicleid) != 462 && GetVehicleModel(vehicleid) != 481 && GetVehicleModel(vehicleid) != 509 && GetVehicleModel(vehicleid) != 510) {
					if(PI[i][pLic][0] == 0) RemovePlayerFromVehicleEx(i);
				}
			}
		}
		if(GetPlayerPing(i) > 20000)
		if(PI[i][pAdmLevel] < 1) NewKick(i,"[Античит]: Вы кикнуты по подозрению в читерстве (High Ping)");
		if(acstruct[i][checkmaptp] == 1) {
			new Float:dis = GetPlayerDistanceFromPoint(i, acstruct[i][maptp][0], acstruct[i][maptp][1], acstruct[i][maptp][2]);
			if(dis < 5.0) {
				new Float:disd = GetPlayerDistanceFromPoint(i, acstruct[i][LastOnFootPosition][0], acstruct[i][LastOnFootPosition][1], acstruct[i][LastOnFootPosition][2]);
				if(disd > 25.0) {
					if(PI[i][pAdmLevel] < 1) NewKick(i,"[Античит]: Вы кикнуты по подозрению в читерстве (Teleport)");
				}
			}
			acstruct[i][checkmaptp] = 0;
		}
		if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_USEJETPACK)
		{
			if(PI[i][pAdmLevel] < 1) NewKick(i,"[Античит]: Вы кикнуты по подозрению в читерстве (Jetpack)");
		}
		if(GetPVarInt(i, "FindPlayer") == 1)
		{
			if(!IsPlayerConnected(GetPVarInt(i, "PlayerFind"))) return GangZoneDestroy(cgangzone[i]), SendClientMessage(i, COLOR_GREY, "Преступник скрылся"), DeletePVar(i, "FindPlayer");
			if(cfindtimer[i] != 0 && cfindtimer[i] <= gettime()) {
				GangZoneDestroy(cgangzone[i]);
				SendClientMessage(i, COLOR_GREY, "Преступник скрылся");
				DeletePVar(i, "FindPlayer");
			}
		}
		if(GetPVarInt(i, "TimeDM") > 0)
		{
			SetPVarInt(i, "TimeDM", GetPVarInt(i, "TimeDM") - 1);
			if(GetPVarInt(i, "TimeDM") == 0) {
				ApplyAnimation(i,"CARRY","crry_prtial",4.0,0,0,0,0,0);
				DeletePVar(i, "TimeDM");
			}
		}
		if(EtherCalled[i] == true)
		{
			if(PI[i][pBank] > CallPrice[PI[i][pNews]-1])
			MinusBankMoney(i, CallPrice[PI[i][pNews]-1]);
			else {
				new caller = Mobile[i];
				SendClientMessage(caller, COLOR_GRAD2, "Недостаточно средств на счету...");
				SetPlayerSpecialAction(caller,SPECIAL_ACTION_STOPUSECELLPHONE);
				CellTime[caller] = -1;
				CellTime[i] = -1;
				Mobile[caller] = INVALID_PLAYER_ID;
				if(EtherCalled[i] == true) EtherCalled[i] = false;
				if(EtherCalled[caller] == true) EtherCalled[caller] = false;
				SendClientMessage(i,  COLOR_GRAD2, "Недостаточно средств на счету...");
				Mobile[i] = INVALID_PLAYER_ID;
				SetPlayerSpecialAction(i,SPECIAL_ACTION_STOPUSECELLPHONE);
			}
		}
		// Автобус ганг
		if(GetPVarInt(i, "TimeBus") > 0)
		{
			SetPVarInt(i, "TimeBus", GetPVarInt(i, "TimeBus") - 1);
			strin = "";
			format(strin,24,"~y~STOP:%i",GetPVarInt(i, "TimeBus"));
			GameTextForPlayer(i, strin, 2000, 6);
			if(GetPVarInt(i, "TimeBus") == 0) {
				DeletePVar(i, "TimeBus");
				new type = GetPVarInt(i, "TypeBus"), p = pPressed[i];
				SetPVarInt(i, "BusStop", 1);
				if(type == 1) SetPlayerRaceCheckpoint(i,0,VLS_001[p][0],VLS_001[p][1],VLS_001[p][2],VLS_001[p][3],VLS_001[p][4],VLS_001[p][5],5.0);//LS_001[p][0],LS_001[p][1],LS_001[p][2],LS_001[p][3],LS_001[p][4],LS_001[p][5],5.0
				if(type == 2) SetPlayerRaceCheckpoint(i,0,LS_002[p][0],LS_002[p][1],LS_002[p][2],LS_002[p][3],LS_002[p][4],LS_002[p][5],5.0);
				if(type == 3) SetPlayerRaceCheckpoint(i,0,VLS_001[p][0],VLS_001[p][1],VLS_001[p][2],VLS_001[p][3],VLS_001[p][4],VLS_001[p][5],5.0);
			}
		}
		if(GetPVarInt(i, "BusTime") > 0)
		{
			SetPVarInt(i, "BusTime", GetPVarInt(i, "BusTime") - 1);
			strin = "";
			format(strin,24,"~r~%i",GetPVarInt(i, "BusTime"));
			GameTextForPlayer(i, strin, 2000, 6);
			if(GetPVarInt(i, "BusTime") == 0) {
				SendClientMessageEx(i, COLOR_PAYCHEC, "Рабочий день завершен. Вами заработано: %i долларов", GetPVarInt(i, "BusMoney"));
				SendClientMessage(i, COLOR_PAYCHEC, "Деньги будут перечислены на счет во время зарплаты");
				PI[i][pPayCheck] += GetPVarInt(i, "BusMoney");
				SetVehicleToRespawn(GetPVarInt(i, "RentBus"));
				DeletePVar(i, "BusTime");
				DeletePVar(i, "RentBus");
				DeletePVar(i, "TypeBus");
				DeletePVar(i, "PriceBus");
				DeletePVar(i, "BusStop");
				DeletePVar(i, "BusMoney");
				pPressed[i] = 0;
			}
		}
		if(AntiDM[i] > 0)
		{
			AntiDM[i]--;
			if(AntiDM[i] <= 0) TogglePlayerControllable(i, 1);
		}
		if(PI[i][pJail] == 1 && PI[i][pJailTime] > 0)
		{
			PI[i][pJailTime]--;
			if(PI[i][pJailTime] <= 0) {
				PI[i][pJail] = 0;
				SetPVarInt(i, "AntiBreik", 3);
				SendClientMessage(i,COLOR_GREY,"Вы были отпущены из тюрьмы!");
				SetPlayerTeamColor(i);
				SetPlayerInterior(i,0);
				SetPlayerVirtualWorld(i,0);
				t_SetPlayerPos(i,1552.4495,-1675.5881,16.1953);
				SetPlayerFacingAngle(i,88.2715);
				SetCameraBehindPlayer(i);
			}
		}
		//
		if(ToCallTime[i] != 0)
		{
			ToCallTime[i] --;
			if(ToCallTime[i] <= 0) {
				GameTextForPlayer(i, "~r~Client is lost", 3000, 1);
				DisablePlayerCheckpoint(i);
			}
		}
		if(GetPVarInt(i, "LicTime") > 0)
		{
			SetPVarInt(i, "LicTime", GetPVarInt(i, "LicTime") - 1);
			strin = "";
			format(strin,30,"~r~%d",GetPVarInt(i, "LicTime"));
			GameTextForPlayer(i, strin, 2000, 6);
			if(GetPVarInt(i, "LicTime") == 0) {
				SendClientMessage(i, COLOR_LIGHTRED, "Время истекло, вы провалили экзамен по вождению!");
				DeletePVar(i, "LicTime");
				DeletePVar(i, "LicTest");
				DeletePVar(i, "LicTestHealth");
				DeletePVar(i, "LicTestError");
			}
		}
		if(PI[i][pMuted] > 0)
		{
			PI[i][pMuted]--;
			if(PI[i][pMuted] <= 0) PI[i][pMuted] = 0, SendClientMessage(i, COLOR_LIGHTRED, "Вы снова можете писать в чат!");
		}
	}
	for(new vid=0; vid<MAX_VEHICLES; vid++) {
		if(Start[vid] == 1 && SpeedVehicle(vid) > 10)
		{
			DestroyDynamicPickup(AmmoPickup[vid]);
			Delete3DTextLabel(AmmoText[vid]);
			Start[vid] = 0;
		}
	}
	Timer();
	return 1;
}
function: ADTimer() {
	foreach(new i: Player) {
		if(!PlayerLogged[i]) continue;
		if(PI[i][pHeal] < 10) SendClientMessage(i, COLOR_LIGHTRED,"Вы слишком голодны, вам нужно поесть!");
		SavePlayer(i);
	}
	SaveMoyor();
	SaveWarehouse();

	SendClientMessageToAll(COLOR_WHITE,"{3caa3c}Будем рады видеть Вас на нашем сайте - {ffffff}"NameSite"");
	SendClientMessageToAll(COLOR_WHITE,"{3caa3c}Вся полезная информация о сервере на форуме проекта {ffffff}"NameSite"/forum");
}
function: ResetNew(playerid) {
	for(new pInfo:i; i < pInfo; ++i) PI[playerid][i] = 0;
	for(new o; o < 2; o++) AmountLBizz[playerid][o] = 0;
	PI[playerid][pHunger] = 100;
	selectcar[playerid] = 0;
	caringarage[playerid] = 0;
	CheckNewBank[playerid] = 0;
	GunCheckTime[playerid] = 0;
	GetPlayerTransfer[playerid] = INVALID_PLAYER_ID;
	GotoInfo[playerid][gtID] = INVALID_PLAYER_ID;
	GotoInfo[playerid][gtState] = 0;
	GotoInfo[playerid][gtX] = 0.0;
	GotoInfo[playerid][gtY] = 0.0;
	GotoInfo[playerid][gtZ] = 0.0;
	GotoInfo[playerid][gtTPX] = 0.0;
	GotoInfo[playerid][gtTPY] = 0.0;
	GotoInfo[playerid][gtTPZ] = 0.0;

	SendAdmin[playerid] = 1;
	SendHelper[playerid] = 1;
	PlayerLogged[playerid] = false;
	PlayerRegs[playerid] = 0;
	PlayerLogin[playerid] = 0;
	InShop[playerid] = 0;
	InTuning[playerid] = 0;
	AntiDM[playerid] = 0;
	OpenedMM[playerid] = 0;
	SendFamily[playerid] = 1;
	PlayerArmor[playerid] = 0.00;
	maskuse[playerid] = 0;
	ClothesRound[playerid] = 0;
	SelectCharPlace[playerid] = 0;
	Mobile[playerid] = INVALID_PLAYER_ID;
	CellTime[playerid] = -1;
	ZapretDice[playerid] = 0;
	KostiName[playerid] = 999;
	KostiMoney[playerid] = 0;
	AutoHelti[playerid] = 1000;
	SpeedM[1][playerid] = 0;
	CheckHealArmour[playerid] = 0;
	TicketOffer[playerid] = 999;
	TicketMoney[playerid] = 0;
	FuelTime[playerid] = 0;
	ProductTime[playerid] = 0;
	CarTPWarn[playerid] = 0;
	MenuFish[playerid] = 0;
	Fishjob[playerid] = 0;
	FishBegin[playerid] = 0;
	FishStart[playerid] = 0;
	PlayerFish[playerid] = 0;
	FishMojno[playerid] = 0;
	StartGarden[playerid] = 0;
	Level[playerid] = 1;
	OnOneLevelJob[playerid] = 0;
	OnLevelKol[playerid] = 0;
	InPlayerPoint[playerid] = 0;
	Skill[playerid] = 0;
	GetPlayerOption[playerid] = 0;
	lotto_var[playerid] = 0;

	PlayerCuffed[playerid] = false;
	AdminLogged[playerid] = false;
	EtherCalled[playerid] = false;
	UsingShield[playerid] = false;
	EtherLive[playerid] = false;
	BunnyUse[playerid] = false;
	Damaged[playerid] = false;
	Ether[playerid] = false;
	PPC[playerid] = false;
	EtherCall[0] = false;
	EtherCall[1] = false;
	EtherSms[0] = false;
	EtherSms[1] = false;
	Phone[playerid] = true;

	SetPVarInt(playerid,"MedCardReg",0);
	SetPVarInt(playerid,"SdohNaCapte",0);
	SetPVarInt(playerid,"laser",0);
	SetPVarInt(playerid,"_idDerevoPos",0);
	SetPVarInt(playerid,"SelectSlot",0);
	SetPVarInt(playerid,"ChangeSlot",0);
	SetPVarInt(playerid,"PickupID", -1);
	SetPVarInt(playerid,"InvizCheat",0);
	SetPVarInt(playerid,"AntiBreik", 500);
	SetPVarInt(playerid,"DialogID",-1);
	SetPVarInt(playerid,"ExitBBall", 0);
	SetPVarInt(playerid,"BrosilBBall", 0);
	SetPVarInt(playerid,"laser", 0);
	SetPVarInt(playerid,"DrawInv", 0);
	SetPVarInt(playerid,"UseCasino", 0);

	ApplyAnimation(playerid,"INT_OFFICE","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"BD_FIRE","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"BEACH","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"benchpress","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"BOMBER","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"BSKTBALL","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"CAR","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"COP_AMBIENT","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"CRACK","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"CARRY","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"DANCING","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"DEALER","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"FAT","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"FOOD","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"GANGS","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"GHANDS","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"GRAFFITI","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"GRAVEYARD","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"MISC","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"SNM","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"VENDING","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"OTB","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"SMOKING","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"SMOKING","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"SHOP","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"RIOT","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"CAR_CHAT","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"CHAINSAW","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"CAMERA","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"SWORD","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid,"SKATE","null",0.0,0,0,0,0,0);
	ApplyAnimation(playerid, "CARRY", "putdwn", 0.0, 0, 0, 0, 0, 0,0);

	animsload[playerid] = true;

	NullComponents(playerid);
	PlayerLastTick[playerid] = GetTickCount();
	Gambling[playerid] = G_STATE_NOT_GAMBLING;
	SlotTimer[playerid] = -1;
	UpdatePlayerShield(playerid, 0.0);
	CheckPlayerGoCuff(playerid);
	GangZoneShowForPlayer(playerid, MafiaZone[0], 0x30B90022);
	return false;
}
function: CheckBanPlayer(playerid) {
	if(IsPlayerConnected(playerid)) {
		new rows, fields;
		cache_get_data(rows, fields);
		new banName[32],banAdmin[32],banReason[32],banData,unBanD,data[16],undata[16];
		if(rows) {
			cache_get_field_content(0, "name", banName, cHandle, sizeof(qurey));
			cache_get_field_content(0, "whobanned", banAdmin, cHandle, sizeof(qurey));
			cache_get_field_content(0, "reason", banReason, cHandle, sizeof(qurey));
			banData = cache_get_field_content_int(0, "bandate", cHandle);
			unBanD = cache_get_field_content_int(0, "unbandate", cHandle);
			format(data, 16, "%s",date("%dd.%mm.%yyyy",banData));
			format(undata, 16, "%s",date("%dd.%mm.%yyyy",unBanD));
			strin = "";
			format(strin, 256, "{FF6347}Аккаунт: %s заблокирован!\nЗаблокировал: {90cb1d}%s{FF6347}\nПричина блокировки: {90cb1d}%s{FF6347}\nДата бана: {90cb1d}%s{FF6347} / Дата разбана: {90cb1d}%s", banName, banAdmin, banReason, data, undata);
			SPD(playerid, 0, 0, "{cacaca}Аккаунт заблокирован!", strin, "Закрыть","");
			NewKick(playerid,"Для выхода из игры используйте /q(uit)");
		}
		else {
			mysql_real_escape_string(NamePlayer(playerid), NamePlayer(playerid));
			strin = "";
			format(strin, sizeof(strin),"SELECT `Name` FROM "TABLE_ACCOUNT" WHERE `Name` = '%s'", NamePlayer(playerid));
			mysql_function_query(cHandle, strin, true, "OnPlayerRegCheck","d", playerid);
		}
	}
	return 1;
}
function: GzCheck() {
	for(new i = 1; i <= TOTALGZ; i++) {
		if(ZoneOnBattle[i] == 1 && GZSafeTime[i] == 0) {
			// Считаем игроков на терре
			foreach(new xp: Player) {
				if(PlayerLogged[xp] == false) continue;
				if(GetPVarInt(xp,"GangWar") == 1 || GetPVarInt(xp, "SdohNaCapte") == 1) {
					for(new t; t < 6; t++) TextDrawShowForPlayer(xp, g_Capture[t][xp]);
					SetPVarInt(xp,"GangWar",2);
				}
				if(PI[xp][pMember] == GZInfo[i][gNapad] || PI[xp][pMember] == GZInfo[i][gFrak]) {
					if(GetPVarInt(xp, "GangWar") == 2) {
						spect = "";
						format(spect,64,"Time: %s~n~%s: %d~n~%s: %d",TimeConverter(ZoneTimer[i]),Fraction[GZInfo[i][gNapad]-1], GangCD[GZInfo[i][gNapad]],Fraction[GZInfo[i][gFrak]-1], GangCD[GZInfo[i][gFrak]]);
						TextDrawSetString(g_Capture[2][xp],spect);
					}
					else {
						DeletePVar(xp, "GangWar");
						for(new t; t < 6; t++) TextDrawHideForPlayer(xp, g_Capture[t][xp]);
					}
				}
			}
			ZoneTimer[i] -=1;
			//
			if(ZoneTimer[i] <=0 && GangCD[GZInfo[i][gFrak]] > GangCD[GZInfo[i][gNapad]]) {
				foreach(new xp: Player) {
					if(PlayerLogged[xp] == false) continue;
					DeletePVar(xp, "GangWar");
					for(new t;t<6;t++) TextDrawHideForPlayer(xp, g_Capture[t][xp]);
				}
				SendFMes(GZInfo[i][gFrak],COLOR_GREEN, "Вам удалось отстоять территорию!");
				SendFMes(GZInfo[i][gNapad],COLOR_LIGHTRED, "Вам не удалось захватить новую территорию!");
				ZoneOnBattle[i] = 0;
				GangZoneStopFlashForAll(GZInfo[i][id]);
			}
			else if(ZoneTimer[i] <=0 && GangCD[GZInfo[i][gNapad]] > GangCD[GZInfo[i][gFrak]]) {
				foreach(new xp: Player) {
					if(PlayerLogged[xp] == false) continue;
					DeletePVar(xp, "GangWar");
					for(new t;t<6;t++) TextDrawHideForPlayer(xp, g_Capture[t][xp]);
				}
				SendFMes(GZInfo[i][gNapad],COLOR_GREEN, "Вам удалось захватить новую территорию!");
				SendFMes(GZInfo[i][gFrak],COLOR_LIGHTRED, "Вам не удалось отстоять свою территорию!");
				GZInfo[i][gFrak] = GZInfo[i][gNapad];
				ZoneOnBattle[i] = 0;
				GZInfo[i][gNapad] = 0;
				GangCD[GZInfo[i][gFrak]] = 0;
				GangCD[GZInfo[i][gNapad]] = 0;
				GangZoneStopFlashForAll(GZInfo[i][id]);
				GangZoneHideForAll(GZInfo[i][id]);
				GangZoneShowForAll(GZInfo[i][id],GetGangZoneColor(i));
				SaveGZ(i);
			}
			// Если счет равный то даем приемущество напавшим
			else if(ZoneTimer[i] <=0 && GangCD[GZInfo[i][gNapad]] == GangCD[GZInfo[i][gFrak]]) {
				foreach(new xp: Player) {
					if(PlayerLogged[xp] == false) continue;
					DeletePVar(xp, "GangWar");
					for(new t;t<6;t++) TextDrawHideForPlayer(xp, g_Capture[t][xp]);
				}
				SendFMes(GZInfo[i][gNapad],COLOR_GREEN, "Вам удалось захватить новую территорию!");
				SendFMes(GZInfo[i][gFrak],COLOR_LIGHTRED, "Вам не удалось отстоять свою территорию!");
				GZInfo[i][gFrak] = GZInfo[i][gNapad];
				ZoneOnBattle[i] = 0;
				GZInfo[i][gNapad] = 0;
				GangCD[GZInfo[i][gFrak]] = 0;
				GangCD[GZInfo[i][gNapad]] = 0;
				GangZoneStopFlashForAll(GZInfo[i][id]);
				GangZoneHideForAll(GZInfo[i][id]);
				GangZoneShowForAll(GZInfo[i][id],GetGangZoneColor(i));
				SaveGZ(i);
			}
		}
	}
	return 1;
}
function: LoadWare() {
	new rows,fields;
	cache_get_data(rows,fields);

	ArmyMats[0] = cache_get_field_content_int(0, "SV_Mats", cHandle);
	ArmyMats[1] = cache_get_field_content_int(0, "VMF_Mats", cHandle);

	Metal[6] = cache_get_field_content_int(0, "G_Metal", cHandle);
	Metal[7] = cache_get_field_content_int(0, "B_Metal", cHandle);
	Metal[8] = cache_get_field_content_int(0, "A_Metal", cHandle);
	Metal[9] = cache_get_field_content_int(0, "V_Metal", cHandle);
	Metal[10] = cache_get_field_content_int(0, "R_Metal", cHandle);
	//
	Mats[6] = cache_get_field_content_int(0, "G_Mats", cHandle);
	Mats[7] = cache_get_field_content_int(0, "B_Mats", cHandle);
	Mats[8] = cache_get_field_content_int(0, "A_Mats", cHandle);
	Mats[9] = cache_get_field_content_int(0, "V_Mats", cHandle);
	Mats[10] = cache_get_field_content_int(0, "R_Mats", cHandle);
	//
	Drugs[6] = cache_get_field_content_int(0, "G_Drugs", cHandle);
	Drugs[7] = cache_get_field_content_int(0, "B_Drugs", cHandle);
	Drugs[8] = cache_get_field_content_int(0, "A_Drugs", cHandle);
	Drugs[9] = cache_get_field_content_int(0, "V_Drugs", cHandle);
	Drugs[10] = cache_get_field_content_int(0, "R_Drugs", cHandle);
	//
	cache_get_field_content(0, "LicPrice", LicPrices, cHandle, sizeof(qurey));
	sscanf(LicPrices, "p<,>a<i>[5]",LicPrice);
	cache_get_field_content(0, "FracPay", FracPays, cHandle, sizeof(qurey));
	sscanf(FracPays, "p<,>a<i>[20]",FracPay);
	SAMoney = cache_get_field_content_int(0, "SAMoney", cHandle);
	//
	UpdateWarehouse();
	return 1;
}
function: LoadingToServer(playerid,type) {
	CreateTextDraws(playerid);
	TogglePlayerControllable(playerid, false);

	switch(type) {
	case 0: SetTimerEx("OnPlayerJoinAuto",100,false,"i",playerid);
	case 1: SetTimerEx("OnPlayerJoin",100,false,"i",playerid);
	}
	return true;
}
function: OnPlayerJoin(playerid) {
	PlayerRegs[playerid] = 1;
	PlayerLogin[playerid] = 0;
	TogglePlayerControllable(playerid, false);
	PlayerRegister[0][playerid] = 0; PlayerRegister[1][playerid] = 0; PlayerRegister[2][playerid] = 0;
	t_SetPlayerPos(playerid, 1750.0978,-1258.1825,3378.4566);
	SetPlayerCameraPos(playerid, 1750.0978,-1258.1825,378.4566);
	SetPlayerCameraLookAt(playerid, 1619.6040,-1381.2323,316.0449);
	SelectTextDraw(playerid, COLOR_YELLOW);
	SendClientMessageEx(playerid, COLOR_PAYCHEC, "Добро пожаловать на {FFFFFF}"NameServer"{a4cd00}.");
	for(new i;i<16;i++) PlayerTextDrawShow(playerid,RegDraws[i][playerid]);
	return true;
}
function: OnPlayerJoinAuto(playerid) {
	PlayerLogin[playerid] = 1;
	PlayerRegs[playerid] = 0;
	for(new i;i<16;i++) PlayerTextDrawShow(playerid,RegDraws[i][playerid]);
	PlayerTextDrawSetString(playerid, RegDraws[3][playerid], "€.KOѓ:");
	PlayerTextDrawSetString(playerid, RegDraws[15][playerid], "ABTOP…€A‰…•");
	PlayerTextDrawHide(playerid,RegDraws[4][playerid]);
	PlayerTextDrawHide(playerid,RegDraws[7][playerid]);
	PlayerLogins[0][playerid] = 0; PlayerLogins[1][playerid] = 1;
	t_SetPlayerPos(playerid, 1750.0978,-1258.1825,3378.4566);
	SetPlayerCameraPos(playerid, 1750.0978,-1258.1825,378.4566);
	SetPlayerCameraLookAt(playerid, 1619.6040,-1381.2323,316.0449);
	SelectTextDraw(playerid, COLOR_YELLOW);
	SendClientMessageEx(playerid, COLOR_PAYCHEC, "Добро пожаловать на {FFFFFF}"NameServer"{a4cd00}.");
	return true;
}
function: ReturnPDDoor(idx,prison) return MoveDynamicObject(gPDDoors[idx][prison],gPDDoorCPos[idx][0],gPDDoorCPos[idx][1],gPDDoorCPos[idx][2],PD_DOOR_SPEED,gPDDoorCPos[idx][3],gPDDoorCPos[idx][4],gPDDoorCPos[idx][5]);
function: Unfreez(playerid) {
	TogglePlayerControllable(playerid,1);
	ClearAnimations(playerid);
	if(GetPVarInt(playerid, "Gruz") > 0 && GetPVarInt(playerid, "GruzYes") > 0 || GetPVarInt(playerid, "UseAmmos") > 0) ApplyAnimation(playerid,"CARRY","crry_prtial",4.1,0,1,1,1,1);
}
function: DrugEffectGone(playerid) {
	new time[3];
	gettime(time[0], time[1], time[2]);
	SetPlayerTime(playerid, time[0], time[1]);
	SetPlayerWeather(playerid, 7);
	SetPlayerDrunkLevel(playerid, 0);
	return 1;
}
function: SetDamage(playerid, issuerid, Float:damage) {
	if(DamageArmour[playerid] > 0.0) {
		DamageArmour[playerid] -= damage;
		if(DamageArmour[playerid] <= 0.0) {
			DamageHealth[playerid] += DamageArmour[playerid];
			if(DamageHealth[playerid] <= 0.0) {
				if(issuerid != INVALID_PLAYER_ID) ApplyAnimation(playerid,"PED","BIKE_fall_off",4.1, 0, 1, 1, 0, 0, 1);
			}
			J_SetPlayerDamageHealth(playerid,DamageHealth[playerid]-damage);
		}
		J_SetPlayerDamageArmour(playerid,DamageArmour[playerid]);
	}
	else {
		if((DamageHealth[playerid]-damage) <= 0.0) {
			DamageHealth[playerid] = 0.0;
			DamageArmour[playerid] = 0.0;
			if(issuerid != INVALID_PLAYER_ID) ApplyAnimation(playerid,"PED","BIKE_fall_off",4.1, 0, 1, 1, 0, 0, 1);
		}
		J_SetPlayerDamageHealth(playerid,DamageHealth[playerid]-damage);
	}
	return true;
}
function: UseCasinoCloses(playerid) {
	ExitPlayerFromSlotMachine(playerid);
	for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit1[i]);
	for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit2[i]);
	for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit3[i]);
	for(new i; i < 15; i++) PlayerTextDrawHide(playerid,CasinoDraw[i][playerid]);
	SetPVarInt(playerid,"UseCasino",0);
}
function: FishEnd(playerid) {
	new fish = random(20);
	if(PI[playerid][pSpining] == 1) fish = random(50);
	if(PI[playerid][pSpining] == 2) fish = random(75);
	if(PI[playerid][pSpining] == 3) fish = random(150);
	PlayerFish[playerid] += fish;
	SendClientMessageEx(playerid,COLOR_PAYCHEC ,"Вы словили %i кг рыбы, всего поймано рыбы: %i кг", fish, PlayerFish[playerid]);
	TogglePlayerControllable(playerid, 1);
	return 1;
}
function: FishEndMojna(playerid) return FishMojno[playerid] = 1;
function: DestroySpark(playerid) return DestroyObject(Spark[playerid]);
function: TazedRemove(playerid) {
	TogglePlayerControllable(playerid, 1);
	ClearAnimations(playerid);
	Tazed[playerid] = 0;
	return 1;
}
function: LoadAccountBank(playerid) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return SPD(playerid,0,0,"Ваши счета", "{ff7d3d}У Вас еще нет открытых счетов.", "Закрыть", "");
	strin = "";
	new name[54],ida;
	for(new idx; idx != rows; idx++) {
		cache_get_field_content(idx, "name", name, cHandle, sizeof(qurey));
		ida = cache_get_field_content_int(idx, "id", cHandle);
		format(strin, sizeof(strin), "%s №%d\n", name, ida);
		strcat(strin, strin);
	}
	mysql_free_result();
	CheckBank(playerid);
	SPD(playerid,4001,2,"Ваши счета",strin,"Выбрать","Отмена");
	return 1;
}
function: GetPinAccountBank(playerid) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return SPD(playerid,0,0,"Не верный PIN-код", "{ff7d3d}Не верно указан PIN-код счета.", "Закрыть", "");
	mysql_free_result();
	CheckBank(playerid);
	SPD(playerid,4004,2,"Список операций", "1. Информация о счете\n2. Снять деньги\n3. Положить деньги\n4. Домашний счет\n5. Счёт бизнеса\n6. Изменить PIN-код", "Принять", "Отмена");
	return 1;
}
function: SpawnTimer(playerid) {
	Spawned[playerid] = true;
	KillTimer(TIMER_Spawn[playerid]);
	return 1;
}
function: TCheckSpeed(playerid) {
	foreach(new i: Player) {
		if(IsPlayerInAnyVehicle(playerid) && !GetPVarInt(playerid, "Fall") && (!IsAPlane(GetPlayerVehicleID(playerid)) || !IsABoat(GetPlayerVehicleID(playerid))))
		{
			SpeedM[0][playerid] = GetVehicleSpeeds(GetPlayerVehicleID(playerid));
			if(SpeedM[0][playerid] > 180) {
				SpeedM[2][playerid] = SpeedM[0][playerid]-SpeedM[1][playerid];
				if(SpeedM[2][playerid] > 62) {
					strin = "";
					format(strin, 256, "[Античит]: Игрок %s (ID: %i) подозревается в читерстве (Speed Hack)", NamePlayer(playerid), playerid);
					SendAdminMessage(0xFF6347AA, strin);
					NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (Speed Hack)");
				}
			}
			SpeedM[1][playerid] = SpeedM[0][playerid];
		}
	}
	FallingChecker();
	return 1;
}
function: FallingChecker() {
	new Float:x,Float:y,Float:z,Float:d;
	foreach(new i: Player) {
		if(IsPlayerConnected(i))
		{
			GetPlayerPos(i,x,y,z);
			d = floatsqroot((x-LastPos[0][i] * x-LastPos[0][i]) + (y-LastPos[1][i] * y-LastPos[1][i]));
			if(d < 10 && (LastPos[2][i] - z) > 5) OnPlayerFall(i);
			LastPos[0][i] = x;
			LastPos[1][i] = y;
			LastPos[2][i] = z;
		}
	}
	return 1;
}
function: ShowPassForPlayer(playerid, targetplayerid) {
	if(!IsPlayerConnected(targetplayerid)) return SendClientMessage(playerid, COLOR_GREY, T_OFFLINE);
	if(PlayerLogged[targetplayerid] == false) return SendClientMessage(playerid, COLOR_GREY, T_NOLOGGED);
	if(!IsPlayerInRangeOfPlayer(8.0, playerid, targetplayerid)) return SendClientMessage(playerid, COLOR_GREY, "Игрок слишком далеко!");
	new mtext[MAX_PLAYER_NAME], FracName[35];
	FracName = "";
	if(PI[playerid][pMember] > 0) FracName = Fraction[PI[playerid][pMember]-1]; else FracName = "---";
	if(PI[playerid][pSex] == 1) format(mtext, sizeof(mtext), "Женский");
	else format(mtext, sizeof(mtext), "Мужской");
	new vtext[40];
	if(PI[playerid][pArmyBilet] == 1) vtext = "Военно-морской флот";
	if(PI[playerid][pArmyBilet] == 2) vtext = "Сухопутные войска";
	if(PI[playerid][pArmyBilet] == 0) vtext = "Не служил(а)";
	strin = "";
	format(strin, 532, "{FF6347}---------------------------------------------------------\n{FFFFFF}Имя: %s\nПол: %s\nВ штате: %d лет\nРабота: %s\nОрганизация: %s\nРанг: %s\nВоенный билет: %s\nПреступлений: %d\nУровень розыска: %d\n{FF6347}---------------------------------------------------------",
	NamePlayer(playerid),mtext,PI[playerid][pLevel],GetJobName(playerid),FracName,GetPlayerRankName(playerid),vtext,PI[playerid][pCrimes], PI[playerid][pWanted]);
	SPD(targetplayerid, 0, 0, "---------------[ Пасспорт ]---------------", strin, "Закрыть", "");
	if(IsACop(targetplayerid)) {
		if(PI[playerid][pWanted] > 0) {
			strin = "";
			format(strin, 532, "{FF6347}---------------------------------------------------------\n{FFFFFF}Имя: %s\nПол: %s\nВ штате: %d лет\nРабота: %s\nОрганизация: \t%s\nРанг: %s\nВоенный билет: %s\nПреступлений: %d\nУровень розыска: %d\n{FF6347}---------------------------------------------------------\n{FFFFFF}Внимание! Данный человек в розыске.\n{FF6347}---------------------------------------------------------",
			NamePlayer(playerid),mtext,PI[playerid][pLevel],GetJobName(playerid),FracName,GetPlayerRankName(playerid),vtext,PI[playerid][pCrimes], PI[playerid][pWanted]);
			SPD(targetplayerid, 0, 0, "---------------[ Пасспорт ]---------------", strin, "Закрыть", "");
		}
	}
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Вы показали свой паспорт %s'у", NamePlayer(targetplayerid));
	SendClientMessageEx(targetplayerid, COLOR_LIGHTBLUE, "%s показал вам свой паспорт", NamePlayer(playerid));
	strin = "";
	format(strin, sizeof(strin), "%s показал(a) свой паспорт %s'у", NamePlayer(playerid), NamePlayer(targetplayerid));
	ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
	return true;
}
function: OnPlayerFall(playerid) {
	if(GetPVarInt(playerid, "Fall")) return 1;
	SetTimerEx("Reactivate",8000,false,"i",playerid);
	SetPVarInt(playerid, "Fall",1);
	SpeedM[0][playerid] = GetVehicleSpeeds(GetPlayerVehicleID(playerid));
	SpeedM[1][playerid] = SpeedM[0][playerid];
	SpeedM[2][playerid] = 0;
	return 1;
}
function: Reactivate(playerid) {
	SpeedM[0][playerid] = GetVehicleSpeeds(GetPlayerVehicleID(playerid));
	SpeedM[1][playerid] = SpeedM[0][playerid];
	SpeedM[2][playerid] = 0;
	SetPVarInt(playerid, "Fall", 0);
	return 1;
}
stock GetVehicleSpeeds( vehicleid ) {
	new Float:x, Float:y, Float:z, vel;
	GetVehicleVelocity( vehicleid, x, y, z );
	vel = floatround( floatsqroot( x*x + y*y + z*z ) * 180 );
	return vel;
}
function: FracMember(playerid) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return SendClientMessage(playerid, COLOR_ORANGE, "В данной фракции нет игроков!");
	qurey = ""; strin = "";
	strcat(qurey,"Ник - Ранг\n\n");
	new Name[24],Member,Rank;
	for(new idx; idx != rows; idx++) {
		cache_get_field_content(idx, "Name", Name, cHandle, sizeof(qurey));
		Rank = cache_get_field_content_int(idx, "Rank", cHandle);
		Member = cache_get_field_content_int(idx, "Member", cHandle);
		format(strin,sizeof(strin),"{ffffff}%s - {0078ff}%s{ffffff} | %i\n",Name,FractionRank[Member-1][Rank-1],Rank);
		strcat(qurey, strin);
	}
	SPD(playerid,0,0,Fraction[GetPVarInt(playerid,"ShowAll")],qurey,"Закрыть","");
	return 1;
}
function: InfoAccountBank(playerid) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return 1;
	strin = "";
	new aid,amoney,name[24];
	aid = cache_get_field_content_int(0, "id", cHandle);
	amoney = cache_get_field_content_int(0, "money", cHandle);
	cache_get_field_content(0, "name", name, cHandle, sizeof(qurey));
	CheckBank(playerid);
	format(strin, sizeof(strin), "{ffffff}Номер счета:\t\t\t{81cb00}№%d{ffffff}\nНазначение:\t\t\t{81cb00}%s{ffffff}\nБаланс:\t\t\t{61bc00}{81cb00}%d$", aid,name,amoney);
	SPD(playerid,4010,0, "Информация о счете", strin, "Вернутся", "");
	return 1;
}
function: GetBankMoney(playerid,money) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return 1;
	strin = "";
	new bmoney;
	bmoney = cache_get_field_content_int(0, "money", cHandle);
	if(bmoney >= money) {
		query = "";
		format(query, 256, "UPDATE `bank` SET `money` = `money` - '%d' WHERE id = '%d'", money, GetPVarInt(playerid,"AccountBank"));
		mysql_function_query(cHandle, query, false, "", "");
		GiveMoney(playerid,money);
		CheckBank(playerid);
		strin = "";
		format(strin, sizeof(strin), "{ffffff}Счет:\t\t\t\t{f26c00}№%d{ffffff}\nВы сняли:\t\t\t{7eb900}%d$\n{ffffff}Старый баланс:\t\t{7eb900}%d$\n{ffffff}Текущий баланс:\t\t{7eb900}%d$", GetPVarInt(playerid,"AccountBank"),money,bmoney,bmoney-money);
		SPD(playerid,4010,0, "Операция прошла успешно", strin, "Вернутся", "");
	}
	else SPD(playerid,4010,0, "Снять деньги", "{ff7d3d}На вышем счете недостаточно средств.", "Вернутся", "");
	return 1;
}
function: PutBankMoney(playerid,money) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return 1;
	strin = "";
	new bmoney;
	bmoney = cache_get_field_content_int(0, "money", cHandle);
	if(GetMoney(playerid) >= money) {
		query = "";
		format(query, 256, "UPDATE `bank` SET `money` = `money` + '%d' WHERE id = '%d'", money, GetPVarInt(playerid,"AccountBank"));
		mysql_function_query(cHandle, query, false, "", "");
		GiveMoney(playerid,-money);
		CheckBank(playerid);
		strin = "";
		format(strin, sizeof(strin), "{ffffff}Счет:\t\t\t\t{f26c00}№%d{ffffff}\nВы положили:\t\t{7eb900}%d$\n{ffffff}Старый баланс:\t\t{7eb900}%d$\n{ffffff}Текущий баланс:\t\t{7eb900}%d$", GetPVarInt(playerid,"AccountBank"),money,bmoney,bmoney+money);
		SPD(playerid,4010,0, "Операция прошла успешно", strin, "Вернутся", "");
	}
	else SPD(playerid,4010,0, "Положить деньги", "{ff7d3d}У Вас нет столько наличных.", "Вернутся", "");
	return 1;
}
function: LogAccountBank(playerid) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return SPD(playerid,1009,0, "История переводов", "{ff7d3d}История переводов пуста.", "Вернутся", "");
	strin = "";
	CheckBank(playerid);
	new data[24],outid,bmoney;
	for(new idx; idx != rows; idx++) {
		outid = cache_get_field_content_int(idx, "outid", cHandle);
		bmoney = cache_get_field_content_int(idx, "money", cHandle);
		cache_get_field_content(idx, "data", data, cHandle, sizeof(qurey));
		format(strin, sizeof(strin), "{f26c00}%s{ffffff} | Перевод {7eb900}%d${ffffff} на счет {f26c00}№%d\n", data,bmoney,outid);
		strcat(strin, strin);
	}
	mysql_free_result();
	SPD(playerid,4010,0, "История операций", strin, "Вернутся", "");
	return 1;
}
function: CheckBank(playerid) {
	query = "";
	format(query, sizeof(query), "SELECT * FROM bank WHERE fix = '1' AND playerid = '%d'", PI[playerid][pID]);
	mysql_function_query(cHandle, query, true, "CheckBankMoney", "d", playerid);
	return 1;
}
function: CheckBankMoney(playerid) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows < 1) return CheckNewBank[playerid] = 1;
	PI[playerid][pBank] = cache_get_field_content_int(0, "money", cHandle);
	return 1;
}
function: PlayerPlaySoundDelay(playerid,soundid) return PlayerPlaySound(playerid,soundid,0.0,0.0,0.0);
function: GrainSTART(playerid) {
	new met[10];
	format(met,sizeof(met),"~y~+%d",GetPVarInt(playerid, "grains"));
	GameTextForPlayer(playerid, met, 2000, 1);
	GiveInventory(playerid,35,GetPVarInt(playerid, "grains"));
	DeletePVar(playerid,"grains");
	SavePlayer(playerid);
	return true;
}
function: MySQL_CHECHELPERS(playerid) {
	new rows, fields, AName[MAX_PLAYER_NAME];
	cache_get_data(rows, fields);
	strin = "";
	if(!rows) return 1;
	for(new i = 0; i < rows; i++) {
		MySQLGetStr("Name", AName, sizeof(AName), i);
		format(strin, sizeof(strin), "%s{c0c0c0}%d. {cd00cd}%s\n", strin, i + 1, AName);
	}
	SPD(playerid,0,DIALOG_STYLE_MSGBOX, "{30C3F0}Хелперы", strin, "Ok", "");
	return 1;
}
function: MySQL_CHECHADMINS(playerid) {
	new rows, fields, ALevel, AName[MAX_PLAYER_NAME];
	cache_get_data(rows, fields);
	strin = "";
	if(!rows) return 1;
	for(new i = 0; i < rows; i++) {
		MySQLGetStr("Name", AName, sizeof(AName), i);
		MySQLGetInt("Admin", ALevel, i);

		format(strin, sizeof(strin), "%s{c0c0c0}%d. {cd00cd}%s {00ccff}| %d\n", strin, i + 1, AName, ALevel);
	}
	SPD(playerid,0,DIALOG_STYLE_MSGBOX, "{30C3F0}Админы", strin, "Ok", "");
	return 1;
}
function: ReFill(playerid) {
	Fuel[GetPlayerVehicleID(playerid)]++;
	SetPVarInt(playerid, "Filling", GetPVarInt(playerid, "Filling") + 1);
	if(GetPVarInt(playerid, "Refueling") <= GetPVarInt(playerid, "Filling")) {
		KillTimer(ReFuelTimer[playerid]);
		DeletePVar(playerid, "Refueling");
		DeletePVar(playerid, "Filling");
		TogglePlayerControllable(playerid, true);
	}
	return 1;
}
function: GetDonateMoney(playerid,codes) {
	new rows, fields;
	cache_get_data(rows, fields);
	strin = "";
	if(rows) {
		new MoneyGP;
		BaseGetInt("Money",MoneyGP);
		PI[playerid][pDonateCash] += MoneyGP;

		format(strin, 128,"{FFFFFF}Ваш счёт пополнен{ffa500} %d {FFFFFF}DonateMoney.",MoneyGP);
		SPD(playerid, 000, DIALOG_STYLE_MSGBOX, "{FFFFFF}Донат:", strin,"Ок", "");

		format(strin, 100,"UPDATE "TABLE_DONATE" SET Status = '0' WHERE Code = '%d'",codes);
		mysql_function_query(cHandle, strin, true, "", "d", playerid);
	}
	else SPD(playerid, 000, DIALOG_STYLE_MSGBOX, "ERROR", "Ошибка! Этот код либо не существует, либо не действителен.","Ок", "");
	return true;
}
function: BaseGetInt(fieldi[],&permi) permi = cache_get_field_content_int(0, fieldi, cHandle);
function: CheckBasketBall() {
	foreach(new i: Player) {
		if(PlayerLogged[i]) checkPlayingState(i);
	}
}
function: showAdmins(playerid, queryl[]) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows) {
		strin = "",qurey = "";
		new admin_lvl, name_str[24], status_str[32], list_str[1024];
		while(--rows >= 0) {
		    admin_lvl = cache_get_field_content_int(rows, "Admin");
			cache_get_field_content(rows, "Name", name_str, cHandle, 24);
			status_str = "{E40C0C}Не в сети{FFFFFF}";
			if(IsPlayerConnected(GetPlayerID(name_str))) status_str = "{2CE40C}В сети{FFFFFF}";
			format(strin,sizeof(strin),"%s\t%d\t%s\n",name_str,admin_lvl,status_str);
			strcat(qurey,strin);
		}
		format(list_str,sizeof(list_str),"Ник администратора\tУровень администрирования\tСтатус\n%s",qurey);
		SPD(playerid,D_HEAL+57,DIALOG_STYLE_TABLIST_HEADERS,"Список администрации",list_str,"Назад","");
	}
	return true;
}
function: showLeaders(playerid, queryl[]) {
	new rows,fields;
	cache_get_data(rows,fields);
	if(rows) {
		strin = "",qurey = "";
		new leader, name_str[24], status_str[32], fracname_str[32], list_str[1024];
		while(--rows >= 0) {
		    leader = cache_get_field_content_int(rows, "Leader");
			cache_get_field_content(rows, "Name", name_str, cHandle, 24);

			fracname_str = "Неизвестно",status_str = "{E40C0C}Не в сети{FFFFFF}";

			switch(leader) {
				case 1: fracname_str = "Правительство";
				case 2: fracname_str = "SAPD";
				case 3: fracname_str = "SA News";
				case 4: fracname_str = "Военно-морской Флот";
				case 5: fracname_str = "Больница LS";
				case 6: fracname_str = "The Grove Street";
				case 7: fracname_str = "The Ballas";
				case 8: fracname_str = "Varios Los Aztecas";
				case 9: fracname_str = "The Vagos";
				case 10: fracname_str = "The Rifa";
				case 11: fracname_str = "FBI";
				case 12: fracname_str = "Автошкола";
				case 13: fracname_str = "Сухопутные Войска";
				case 14: fracname_str = "SFPD";
				case 15: fracname_str = "LVPD";
				case 16: fracname_str = "Больница SF";
				case 17: fracname_str = "Больница LV";
				case 18: fracname_str = "Колумбийский наркокортель";
			}
			if(IsPlayerConnected(GetPlayerID(name_str))) status_str = "{2CE40C}В сети{FFFFFF}";
			format(strin,sizeof(strin),"%s\t%s\t%s\n",name_str,fracname_str,status_str);
			strcat(qurey,strin);
		}
		format(list_str,sizeof(list_str),"Ник игрока\tОрганизация\tСтатус\n%s",qurey);
		SPD(playerid,D_HEAL+57,DIALOG_STYLE_TABLIST_HEADERS,"Список лидеров",list_str,"Назад","");
	}
	return true;
}
function: GameModeExitDelay() GameModeExit();
