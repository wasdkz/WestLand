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
PutPlayerInSlotMachine(playerid) {
	if(Gambling[playerid] != G_STATE_NOT_GAMBLING) return true;
	Gambling[playerid] = G_STATE_READY;
	Slots[playerid][0] = random(5);
	Slots[playerid][1] = random(5);
	Slots[playerid][2] = random(5);
	SetPVarInt(playerid,"DigitsUse",0);
	SetPVarInt(playerid,"BALANCE",GetPVarInt(playerid,"BALANCE")-GetPVarInt(playerid,"BET"));
	for(new i; i < 15; i++) PlayerTextDrawShow(playerid,CasinoDraw[i][playerid]);
	ShowPlayerSlots(playerid,Slots[playerid][0],Slots[playerid][1],Slots[playerid][2]);
	TogglePlayerControllable(playerid,0);
	SlotCounter[playerid] = 30+random(18);
	SlotTimer[playerid] = SetTimerEx("Gambler",100,1,"d",playerid);
	Gambling[playerid] = G_STATE_GAMBLING;
	strin = "";
	format(strin,64,"~g~BALANCE: %d$~n~CTABKA: %d$",GetPVarInt(playerid,"BALANCE"),GetPVarInt(playerid,"BET"));
	PlayerTextDrawSetString(playerid, CasinoDraw[10][playerid], strin);
	return true;
}
ShowPlayerSlots(playerid,slot1,slot2,slot3) {
	for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit1[i]);
	for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit2[i]);
	for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit3[i]);
	TextDrawShowForPlayer(playerid,Digit1[slot1]);
	TextDrawShowForPlayer(playerid,Digit2[slot2]);
	TextDrawShowForPlayer(playerid,Digit3[slot3]);
}
HideSlotsForPlayer(playerid) {
	if(GetPVarInt(playerid, "UseCasino") < 1) {
		for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit1[i]);
		for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit2[i]);
		for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit3[i]);
	}
}
ExitPlayerFromSlotMachine(playerid) {
	if(Gambling[playerid] == G_STATE_NOT_GAMBLING) return false;
	HideSlotsForPlayer(playerid);
	SetPVarInt(playerid,"DigitsUse",1);
	Gambling[playerid] = G_STATE_NOT_GAMBLING;
	TogglePlayerControllable(playerid,1);
	strin = "";
	format(strin,64,"~g~BALANCE: %d$~n~CTABKA: %d$",GetPVarInt(playerid,"BALANCE"),GetPVarInt(playerid,"BET"));
	PlayerTextDrawSetString(playerid, CasinoDraw[10][playerid], strin);
	//SetPVarInt(playerid,"BALANCE",0);
	SetPVarInt(playerid,"UseCasino",0);
	return true;
}
public OnPlayerPressButton(playerid,buttonid) {
	if(buttonid >= gPDDoorButton[0] && buttonid <= gPDDoorButton[PD_DOOR_COUNT - 1]) {
		if(!IsACop(playerid)) return SendClientMessage(playerid,COLOR_GREY,"У вас нет карточки для открытия этой двери");
		new idb = buttonid - gPDDoorButton[0];
		new prison = GetPlayerVirtualWorld(playerid) - 1;
		if(prison < 0 || prison > 2) return SendClientMessage(playerid,COLOR_GREY,"Ошибка (#109)");
		if(idb >= 3)
		{
			if(!gPDCamStatus[idb-3]) {MoveDynamicObject(gPDDoors[idb][prison],gPDDoorOPos[idb][0],gPDDoorOPos[idb][1],gPDDoorOPos[idb][2],PD_DOOR_SPEED,gPDDoorOPos[idb][3],gPDDoorOPos[idb][4],gPDDoorOPos[idb][5]); gPDCamStatus[idb-3] = true;}
			else {MoveDynamicObject(gPDDoors[idb][prison],gPDDoorCPos[idb][0],gPDDoorCPos[idb][1],gPDDoorCPos[idb][2],PD_DOOR_SPEED,gPDDoorCPos[idb][3],gPDDoorCPos[idb][4],gPDDoorCPos[idb][5]); gPDCamStatus[idb-3] = false;}
		}
		else {
			MoveDynamicObject(gPDDoors[idb][prison],gPDDoorOPos[idb][0],gPDDoorOPos[idb][1],gPDDoorOPos[idb][2],PD_DOOR_SPEED,gPDDoorOPos[idb][3],gPDDoorOPos[idb][4],gPDDoorOPos[idb][5]);
			SetTimerEx("ReturnPDDoor",PD_DOOR_DELAY,false,"ii",idb,prison);
		}
	}
	else if(buttonid == LBizz[2][lStartCP][1]) {
		if(strcmp(LBizz[2][lOwner],NamePlayer(playerid)) != 0 && strcmp(LBizz[2][lWorker_1],NamePlayer(playerid)) != 0 && strcmp(LBizz[2][lWorker_2],NamePlayer(playerid)) != 0 && strcmp(LBizz[2][lWorker_3],NamePlayer(playerid)) != 0) return true;
		if(GardenSys == 0) {
			if(LBizz[2][lMaterials][1] < 3000) return SendClientMessage(playerid,COLOR_GREY,"Система поливки не активирована, так как в хранилище не хватает воды.");
			SendClientMessage(playerid,COLOR_GREEN,"Система поливки деревьев активирована!");
			GardenSys = SetTimer("GardenWater",60000,false);
			GardenTreesIDs[0][1] = CreateDynamicObject(18739,-1126.1414795,-1179.5426025,135.9438934,0.0000000,32.0000000,95.9999695); //object(water_fountain) (1)
			GardenTreesIDs[1][1] = CreateDynamicObject(18739,-1134.4792480,-1179.5299072,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (2)
			GardenTreesIDs[2][1] = CreateDynamicObject(18739,-1143.2884521,-1179.5372314,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (3)
			GardenTreesIDs[3][1] = CreateDynamicObject(18739,-1150.9256592,-1179.5240479,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (4)
			GardenTreesIDs[4][1] = CreateDynamicObject(18739,-1157.2978516,-1179.5069580,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (5)
			GardenTreesIDs[5][1] = CreateDynamicObject(18739,-1165.1959229,-1179.1090088,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (6)
			GardenTreesIDs[6][1] = CreateDynamicObject(18739,-1172.7094727,-1179.0806885,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (7)
			GardenTreesIDs[7][1] = CreateDynamicObject(18739,-1181.2512207,-1178.7420654,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (8)
			GardenTreesIDs[8][1] = CreateDynamicObject(18739,-1189.7171631,-1178.4058838,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (9)
			GardenTreesIDs[9][1] = CreateDynamicObject(18739,-1198.4675293,-1178.2845459,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (10)
			GardenTreesIDs[10][1] = CreateDynamicObject(18739,-1198.4667969,-1178.2841797,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (11)
			GardenTreesIDs[11][1] = CreateDynamicObject(18739,-1198.3828125,-1217.1727295,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (12)
			GardenTreesIDs[12][1] = CreateDynamicObject(18739,-1190.2800293,-1216.7119141,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (13)
			GardenTreesIDs[13][1] = CreateDynamicObject(18739,-1181.5462646,-1216.7003174,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (14)
			GardenTreesIDs[14][1] = CreateDynamicObject(18739,-1173.5833740,-1216.8035889,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (15)
			GardenTreesIDs[15][1] = CreateDynamicObject(18739,-1165.9040527,-1216.8552246,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (16)
			GardenTreesIDs[16][1] = CreateDynamicObject(18739,-1157.0633545,-1216.8422852,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (17)
			GardenTreesIDs[17][1] = CreateDynamicObject(18739,-1148.5070801,-1216.8726807,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (18)
			GardenTreesIDs[18][1] = CreateDynamicObject(18739,-1139.8868408,-1216.9835205,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (19)
			GardenTreesIDs[19][1] = CreateDynamicObject(18739,-1131.3605957,-1216.9169922,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (20)
			GardenTreesIDs[20][1] = CreateDynamicObject(18739,-1122.6877441,-1217.0886230,135.9438934,0.0000000,31.9976807,95.9985352); //object(water_fountain) (21)
			GardenTreesIDs[21][1] = CreateDynamicObject(18739,-1120.6265869,-1207.3936768,135.9438934,0.0000000,31.9976807,184.4985352); //object(water_fountain) (22)
			GardenTreesIDs[22][1] = CreateDynamicObject(18739,-1120.5341797,-1198.8654785,135.9438934,0.0000000,31.9976807,184.4934082); //object(water_fountain) (23)
			GardenTreesIDs[23][1] = CreateDynamicObject(18739,-1120.1329346,-1173.2701416,135.9438934,0.0000000,31.9976807,184.4934082); //object(water_fountain) (24)
			GardenTreesIDs[24][1] = CreateDynamicObject(18739,-1120.1893311,-1164.8179932,135.9438934,0.0000000,31.9976807,184.4934082); //object(water_fountain) (25)
			GardenTreesIDs[25][1] = CreateDynamicObject(18739,-1113.6398926,-1157.6981201,135.9438934,0.0000000,31.9976807,268.9934082); //object(water_fountain) (26)
			GardenTreesIDs[26][1] = CreateDynamicObject(18739,-1105.0268555,-1157.5688477,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (27)
			GardenTreesIDs[27][1] = CreateDynamicObject(18739,-1122.3319092,-1157.9891357,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (28)
			GardenTreesIDs[28][1] = CreateDynamicObject(18739,-1131.2149658,-1158.0885010,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (29)
			GardenTreesIDs[29][1] = CreateDynamicObject(18739,-1139.9439697,-1158.2553711,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (30)
			GardenTreesIDs[30][1] = CreateDynamicObject(18739,-1148.5076904,-1158.1420898,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (31)
			GardenTreesIDs[31][1] = CreateDynamicObject(18739,-1157.1123047,-1158.4083252,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (32)
			GardenTreesIDs[32][1] = CreateDynamicObject(18739,-1165.1225586,-1158.2705078,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (33)
			GardenTreesIDs[33][1] = CreateDynamicObject(18739,-1173.6054688,-1158.5175781,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (34)
			GardenTreesIDs[34][1] = CreateDynamicObject(18739,-1182.1293945,-1158.5673828,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (35)
			GardenTreesIDs[35][1] = CreateDynamicObject(18739,-1190.6782227,-1158.2934570,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (36)
			GardenTreesIDs[36][1] = CreateDynamicObject(18739,-1199.1958008,-1158.0260010,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (37)
			GardenTreesIDs[37][1] = CreateDynamicObject(18739,-1198.0822754,-1192.3742676,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (38)
			GardenTreesIDs[38][1] = CreateDynamicObject(18739,-1189.1816406,-1192.3037109,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (39)
			GardenTreesIDs[39][1] = CreateDynamicObject(18739,-1180.9313965,-1192.2387695,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (40)
			GardenTreesIDs[40][1] = CreateDynamicObject(18739,-1172.3305664,-1192.1708984,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (41)
			GardenTreesIDs[41][1] = CreateDynamicObject(18739,-1163.8298340,-1192.1040039,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (42)
			GardenTreesIDs[42][1] = CreateDynamicObject(18739,-1154.8035889,-1192.0319824,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (43)
			GardenTreesIDs[43][1] = CreateDynamicObject(18739,-1146.3275146,-1191.9645996,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (44)
			GardenTreesIDs[44][1] = CreateDynamicObject(18739,-1137.8269043,-1191.8969727,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (45)
			GardenTreesIDs[45][1] = CreateDynamicObject(18739,-1129.3507080,-1191.8293457,135.9438934,0.0000000,31.9976807,268.9892578); //object(water_fountain) (46)
			GardenTreesIDs[46][1] = CreateDynamicObject(18739,-1207.7949219,-1210.6511230,135.9438934,0.0000000,75.9976807,354.9892578); //object(water_fountain) (47)
			GardenTreesIDs[47][1] = CreateDynamicObject(18739,-1207.9765625,-1201.4537354,135.9438934,0.0000000,75.9924316,354.9847412); //object(water_fountain) (48)
			GardenTreesIDs[48][1] = CreateDynamicObject(18739,-1206.6721191,-1184.2822266,135.9438934,0.0000000,75.9924316,354.9847412); //object(water_fountain) (49)
			GardenTreesIDs[49][1] = CreateDynamicObject(18739,-1206.0893555,-1175.7606201,135.9438934,0.0000000,75.9924316,2.9847412); //object(water_fountain) (50)
			GardenTreesIDs[50][1] = CreateDynamicObject(18739,-1205.8166504,-1167.1398926,135.9438934,0.0000000,75.9924316,2.9827881); //object(water_fountain) (51)
		}
		else {
			SendClientMessage(playerid,COLOR_GREEN,"Система поливки деревьев отключена!");
			KillTimer(GardenSys);
			GardenSys = 0;
			for(new i;i < 51;i++) {
				if(GardenTreesIDs[i][1] != 0) DestroyDynamicObject(GardenTreesIDs[i][1]);
			}
		}
	}
	else SendClientMessage(playerid,COLOR_RED,"server error #9516 - пожалуйста, сообщите администрации о данной кнопке.");
	return 1;
}
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
	static
		tuning_str[11],
		text[32],
		Float:x,
		Float:y,
		Float:z,
		Float:angle,
		vehmodel,
		c;

	strin = "",c = GetPlayerVehicleID(playerid),vehmodel = GetVehicleModel(c);
	GetPlayerPos(playerid,x,y,z);
	GetPlayerFacingAngle(playerid, angle);
	x += floatsin(-angle, degrees);
	y += floatcos(-angle, degrees);

	if(GetPVarInt(playerid,"GMinerMode") == 1) {
		for(new i;i < GetPVarInt(playerid,"GMinerG_One");i++) {

			format(strin,sizeof(strin),"GMiner_CTD%i",i);
			if(PlayerText:GetPVarInt(playerid,strin) == playertextid) {
				ApplyAnimation(playerid, "BOMBER","BOM_Plant_Loop",4.0,1,0,0,0,0);
				DeletePVar(playerid,strin);
				SetPVarInt(playerid,"SearchedGMiner",GetPVarInt(playerid,"SearchedGMiner")+1);
				PlayerTextDrawDestroy(playerid,playertextid);
				strin = "";
				format(strin,sizeof(strin),"4ucto: %i/%i",GetPVarInt(playerid,"SearchedGMiner"),GetPVarInt(playerid,"GMinerG_One"));
				GameTextForPlayer(playerid, strin, 750, 4);
				if(GetPVarInt(playerid,"SearchedGMiner") == GetPVarInt(playerid,"GMinerG_One")) {
					for(new ix;ix < GetPVarInt(playerid,"GMinerG_One");ix++) {
						strin = "";
						format(strin,sizeof(strin),"GMiner_CTD%i",ix);
						if(GetPVarInt(playerid,"GMiner_CTD") != 0) PlayerTextDrawDestroy(playerid,PlayerText:GetPVarInt(playerid,strin));
					}
					strin = "";
					format(strin,sizeof(strin),"В промытой породе найдено {33AA33}%f грамм, {FFFF00}Вы можете потом сдать её в помещении, где устройство на данную работу.",float(GetPVarInt(playerid,"GMinerG_One"))/1000);
					SendClientMessage(playerid,COLOR_YELLOW,strin);
					TextDrawHideForPlayer(playerid,FULLBOX);
					DisablePlayerCheckpoint(playerid);
					SetPVarInt(playerid,"GMinerG_NotGived",GetPVarInt(playerid,"GMinerG_NotGived")+GetPVarInt(playerid,"GMinerG_One"));
					SetPVarInt(playerid, "GMiner", 1);
					SendClientMessage(playerid, COLOR_PAYCHEC, "Наполните тарелку породой снова.");
					if(IsPlayerAttachedObjectSlotUsed(playerid, 4)) RemovePlayerAttachedObject(playerid, 4);
					SetPlayerSpecialAction(playerid,0);
					format(spect,32,"AMOUNT: %f GRAMM",float(GetPVarInt(playerid,"GMinerG_NotGived"))/1000);
					TextDrawSetString(MinerDraw[playerid],spect);
					CancelSelectTextDraw(playerid);
					ClearAnimTextVar(playerid);
					DeletePVar(playerid,"GMinerG_One");
					DeletePVar(playerid,"SearchedGMiner");
				}
				break;
			}
		}
		return true;
	}
	if(GetPVarInt(playerid,"GetLBRudaMode") == 1) {
		for(new i;i < GetPVarInt(playerid,"GetLBRudaRand");i++) {
			strin = "";
			format(strin,16,"GLB_CTD%i",i);
			if(PlayerText:GetPVarInt(playerid,strin) == playertextid) {
				DeletePVar(playerid,strin);
				SetPVarInt(playerid,"SearchedLBRuda",GetPVarInt(playerid,"SearchedLBRuda")+1);
				PlayerTextDrawDestroy(playerid,playertextid);
				strin = "";
				format(strin,16,"B3RTO: %i/%i",GetPVarInt(playerid,"SearchedLBRuda"),GetPVarInt(playerid,"GetLBRudaRand"));
				GameTextForPlayer(playerid, strin, 750, 4);
				if(GetPVarInt(playerid,"SearchedLBRuda") == GetPVarInt(playerid,"GetLBRudaRand")) {
					for(new ix;ix < GetPVarInt(playerid,"GetLBRudaRand");ix++) {
						strin = "";
						format(strin,16,"GLB_CTD%i",ix);
						if(GetPVarInt(playerid,"GLB_CTD") != 0) PlayerTextDrawDestroy(playerid,PlayerText:GetPVarInt(playerid,strin));
					}
					TextDrawHideForPlayer(playerid,FULLBOX);
					DisablePlayerCheckpoint(playerid);
					SetPlayerCheckpoint(playerid,378.2361,2537.6560,55.4018,2.0);
					SetPVarInt(playerid,"GetLBRuda",2);
					CancelSelectTextDraw(playerid);
					ClearAnimTextVar(playerid);
					DeletePVar(playerid,"SearchedLBRuda");
					SetPVarInt(playerid,"LBObj1",CreateDynamicObject(1303,0.0,0.0,0.0,0.0,0.0,0.0,-1,-1,-1));
					AttachDynamicObjectToVehicle(GetPVarInt(playerid,"LBObj1"),GetPlayerVehicleID(playerid), 0.1257000,3.3577000,-0.5887000,0.0000000,308.3410000,272.0670000);
					SetPVarInt(playerid,"LBObj2",CreateDynamicObject(1304,0.0,0.0,0.0,0.0,0.0,0.0,-1,-1,-1));
					AttachDynamicObjectToVehicle(GetPVarInt(playerid,"LBObj2"),GetPlayerVehicleID(playerid),-0.7601000,3.2347000,-0.1899000,0.0000000,309.8600000,323.3580000);
					SetPVarInt(playerid,"LBObj3",CreateDynamicObject(1304,0.0,0.0,0.0,0.0,0.0,0.0,-1,-1,-1));
					AttachDynamicObjectToVehicle(GetPVarInt(playerid,"LBObj3"),GetPlayerVehicleID(playerid), 0.7584000,3.1391000,-0.1899000,0.0000000,309.8580000,323.3550000);
					SetPVarInt(playerid,"LBObj4",CreateDynamicObject(1304,0.0,0.0,0.0,0.0,0.0,0.0,-1,-1,-1));
					AttachDynamicObjectToVehicle(GetPVarInt(playerid,"LBObj4"),GetPlayerVehicleID(playerid), -0.0504000,3.1648000,-0.1899000,0.0000000,343.2850000,323.3550000);
					SetPlayerRaceCheckpoint(playerid,1,-1361.3854,2107.0049,41.0793,-1361.3854,2107.0049,41.0793,5.0);
					SendClientMessageEx(playerid,COLOR_GREEN,"Вы загрузили %i кг породы",GetPVarInt(playerid,"GetLBRudaRand"));
					DeletePVar(playerid,"GetLBRudaMode");
				}
				break;
			}
		}
		return true;
	}
	if(GetPVarInt(playerid, "jobkrub_step") == 2 && GetPVarInt(playerid, "jobkrub_putcage_status")) {
		new
		numberMarshrut = GetPVarInt(playerid, "jobkrub_numberMarshrut"),
		numberPirs = GetPVarInt(playerid, "jobkrub_numberPirs");
		if(playertextid == PTD_crubjob[playerid][4]) // UP
		{
			if(GetPVarInt(playerid, "jobkrub_putcage_height") <= 1) return SendClientMessage(playerid, -1, "Клетка максимально поднята.");
			SetPVarInt(playerid, "jobkrub_putcage_height", GetPVarInt(playerid, "jobkrub_putcage_height")-1);
			DestroyDynamicObject(objects_krubjob[playerid][0]);
			objects_krubjob[playerid][0] = CreateDynamicObject(964, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 300.0);
			AttachDynamicObjectToVehicle(objects_krubjob[playerid][0], krub_car[numberPirs], 0.000000, -6.295096, (GetPVarInt(playerid, "jobkrub_putcage_height") == 1) ? (1.519998) : (1.519998-(2.415033*GetPVarInt(playerid, "jobkrub_putcage_height")-1)), 0.000000, 0.000000, 0.000000);
			setPlayerPanelCage(playerid, GetPVarInt(playerid, "jobkrub_putcage_height"));
		}
		else if(playertextid == PTD_crubjob[playerid][5]) // DOWN
		{
			SetPVarInt(playerid, "jobkrub_putcage_height", GetPVarInt(playerid, "jobkrub_putcage_height")+1);
			DestroyDynamicObject(objects_krubjob[playerid][0]);
			objects_krubjob[playerid][0] = CreateDynamicObject(964, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 300.0);
			AttachDynamicObjectToVehicle(objects_krubjob[playerid][0], krub_car[numberPirs], 0.000000, -6.295096, (GetPVarInt(playerid, "jobkrub_putcage_height") == 1) ? (1.519998) : (1.519998-(2.415033*GetPVarInt(playerid, "jobkrub_putcage_height")-1)), 0.000000, 0.000000, 0.000000);
			setPlayerPanelCage(playerid, GetPVarInt(playerid, "jobkrub_putcage_height"));
			if(GetPVarInt(playerid, "jobkrub_putcage_height") >= 10) // полностью опустили клетку
			{
				for(new o = 0; o < 11; o++) DestroyDynamicObject(objects_krubjob[playerid][o]);
				DeletePVar(playerid, "jobkrub_putcage_status");
				DeletePVar(playerid, "jobkrub_putcage_height");
				SetPVarInt(playerid, "jobkrub_putcage_point_count", GetPVarInt(playerid, "jobkrub_putcage_point_count")+1);
				strin = "";
				format(strin, sizeof strin, "DOWN CAGE: %i/6", GetPVarInt(playerid, "jobkrub_putcage_point_count")), GameTextForPlayer(playerid, strin, 2000, 3);
				showPlayerPanelCage(playerid, 0, 0);
				if(GetPVarInt(playerid, "jobkrub_putcage_point_count") == 6) // конец маршрута
				{
					DeletePVar(playerid, "jobkrub_putcage_point_count");
					SetPVarInt(playerid, "jobkrub_step", 3);
					SetPVarInt(playerid,"FishRCP", RCPID_JOBKRUB_MARSHRUT_TAKE);
					SetPlayerRaceCheckpoint(playerid, 2, krub_marshruts[numberMarshrut][0][0], krub_marshruts[numberMarshrut][0][1], krub_marshruts[numberMarshrut][0][2], krub_marshruts[numberMarshrut][1][0], krub_marshruts[numberMarshrut][1][1], krub_marshruts[numberMarshrut][1][2], 5.0);
					SendClientMessage(playerid, -1, "Отлично! Возвращайтесь в начало и собирайте клетки.");
					SetPVarInt(playerid, "jobkrub_takecage_point_count", 0);
					SetPVarInt(playerid, "jobkrub_price", 0);
					return 1;
				}
				new mars = GetPVarInt(playerid, "jobkrub_putcage_point_count");
				SetPlayerRaceCheckpoint(playerid, 2, krub_marshruts[numberMarshrut][mars][0], krub_marshruts[numberMarshrut][mars][1], krub_marshruts[numberMarshrut][mars][2], krub_marshruts[numberMarshrut][(mars < 5) ? (mars+1) : (mars)][0], krub_marshruts[numberMarshrut][(mars < 5) ? (mars+1) : (mars)][1], krub_marshruts[numberMarshrut][(mars < 5) ? (mars+1) : (mars)][2], 5.0);
			}
		}
	}
	if(GetPVarInt(playerid, "jobkrub_step") == 3 && GetPVarInt(playerid, "jobkrub_takecage_status")) {
		new numberMarshrut = GetPVarInt(playerid, "jobkrub_numberMarshrut"), numberPirs = GetPVarInt(playerid, "jobkrub_numberPirs");
		if(playertextid == PTD_crubjob[playerid][4]) // UP
		{
			SetPVarInt(playerid, "jobkrub_takecage_height", GetPVarInt(playerid, "jobkrub_takecage_height")-1);
			DestroyDynamicObject(objects_krubjob[playerid][0]);
			objects_krubjob[playerid][0] = CreateDynamicObject(964, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 300.0);
			AttachDynamicObjectToVehicle(objects_krubjob[playerid][0], krub_car[numberPirs], 0.000000, -6.295096, (GetPVarInt(playerid, "jobkrub_takecage_height") == 1) ? (1.519998) : (1.519998-(2.415033*GetPVarInt(playerid, "jobkrub_takecage_height")-1)), 0.000000, 0.000000, 0.000000);
			setPlayerPanelCage(playerid, GetPVarInt(playerid, "jobkrub_takecage_height"));
			if(GetPVarInt(playerid, "jobkrub_takecage_height") == 0) // полностью подняли клетку
			{
				objectsOnCar_krubjob[playerid][GetPVarInt(playerid, "jobkrub_takecage_point_count")] = CreateDynamicObject(964, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 300.0);
				AttachDynamicObjectToVehicle(objectsOnCar_krubjob[playerid][GetPVarInt(playerid, "jobkrub_takecage_point_count")], krub_car[GetPVarInt(playerid, "jobkrub_numberPirs")], coordinationObjectOnCar[GetPVarInt(playerid, "jobkrub_takecage_point_count")][0], coordinationObjectOnCar[GetPVarInt(playerid, "jobkrub_takecage_point_count")][1], coordinationObjectOnCar[GetPVarInt(playerid, "jobkrub_takecage_point_count")][2], 0.000000, 0.000000, 0.000000);
				for(new o = 0; o < 11; o++) DestroyDynamicObject(objects_krubjob[playerid][o]);
				DeletePVar(playerid, "jobkrub_takecage_status");
				DeletePVar(playerid, "jobkrub_takecage_height");
				SetPVarInt(playerid, "jobkrub_takecage_point_count", GetPVarInt(playerid, "jobkrub_takecage_point_count")+1);
				new randKrub = random(50);
				SetPVarInt(playerid, "jobkrub_price", GetPVarInt(playerid, "jobkrub_price")+randKrub);
				strin = "";
				format(strin, sizeof strin, "DOWN CAGE: %i/6 (krub: %d)", GetPVarInt(playerid, "jobkrub_takecage_point_count"), randKrub), GameTextForPlayer(playerid, strin, 2000, 3);
				showPlayerPanelCage(playerid, 0, 0);
				new randkrub;
				randkrub = random(50);
				SetPVarInt(playerid, "jobkrub_price", GetPVarInt(playerid, "jobkrub_price")+randkrub);
				if(GetPVarInt(playerid, "jobkrub_takecage_point_count") == 6) // конец маршрута
				{
					DeletePVar(playerid, "jobkrub_takecage_point_count");
					SetPVarInt(playerid, "jobkrub_step", 4);
					SetPVarInt(playerid,"FishRCP",RCPID_JOBKRUB_RETURN_PIRS);
					SetPlayerRaceCheckpoint(playerid, 2, coordinationWaterPirs[numberPirs][0], coordinationWaterPirs[numberPirs][1], coordinationWaterPirs[numberPirs][2], coordinationWaterPirs[numberPirs][0], coordinationWaterPirs[numberPirs][1], coordinationWaterPirs[numberPirs][2], 4.0);
					SendClientMessage(playerid, -1, "Отлично! Возвращайтесь на базу.");
					return 1;
				}
				new mars = GetPVarInt(playerid, "jobkrub_takecage_point_count");
				SetPlayerRaceCheckpoint(playerid, 2, krub_marshruts[numberMarshrut][mars][0], krub_marshruts[numberMarshrut][mars][1], krub_marshruts[numberMarshrut][mars][2], krub_marshruts[numberMarshrut][(mars < 5) ? (mars+1) : (mars)][0], krub_marshruts[numberMarshrut][(mars < 5) ? (mars+1) : (mars)][1], krub_marshruts[numberMarshrut][(mars < 5) ? (mars+1) : (mars)][2], 5.0);
			}
		}
		else if(playertextid == PTD_crubjob[playerid][5]) // DOWN
		{
			if(GetPVarInt(playerid, "jobkrub_takecage_height") >= 9) return SendClientMessage(playerid, -1, "Клетка максимально опущена.");
			SetPVarInt(playerid, "jobkrub_takecage_height", GetPVarInt(playerid, "jobkrub_takecage_height")+1);
			DestroyDynamicObject(objects_krubjob[playerid][0]);
			objects_krubjob[playerid][0] = CreateDynamicObject(964, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 300.0);
			AttachDynamicObjectToVehicle(objects_krubjob[playerid][0], krub_car[numberPirs], 0.000000, -6.295096, (GetPVarInt(playerid, "jobkrub_takecage_height") == 1) ? (1.519998) : (1.519998-(2.415033*GetPVarInt(playerid, "jobkrub_takecage_height")-1)), 0.000000, 0.000000, 0.000000);
			setPlayerPanelCage(playerid, GetPVarInt(playerid, "jobkrub_takecage_height"));
		}
		return true;
	}
	if(PlayerRegs[playerid] || PlayerLogin[playerid]) {
		if(playertextid == RegDraws[5][playerid]) {
			if(PlayerRegs[playerid]) return SPD(playerid,1,DIALOG_STYLE_PASSWORD,"{96e300}Пароль","{ffffff}Введите пароль:","Готово","Закрыть");
			if(PlayerLogin[playerid]) return SPD(playerid,2,DIALOG_STYLE_PASSWORD,"{96e300}Пароль","{ffffff}Введите пароль:","Готово","");
		}
		if(playertextid == RegDraws[6][playerid]) {
			if(PlayerRegs[playerid]) return SPD(playerid,3,DIALOG_STYLE_INPUT,"{96e300}Почта - Email","{ffffff}Введите Ваш E-Mail адрес:", "Готово", "Закрыть");
			if(PlayerLogin[playerid]) return SPD(playerid,0,0,"{96e300}Защитный код", "Внимание: Вы не устанавливали защитный код!", "Закрыть", "");
		}
		if(playertextid == RegDraws[7][playerid]) return SPD(playerid,4,2,"{96e300}Пол","{ffffff}Мужской\nЖенский","Готово","Закрыть");
		if(playertextid == RegDraws[13][playerid]) return ClickContinue(playerid);
		return true;
	}
	if(InTuning[playerid]) {
		if(playertextid == TuningTD[4][playerid])//left1
		{
			SetPVarInt(playerid,"Selected1",GetPVarInt(playerid,"Selected1")-1);
			if(GetPVarInt(playerid,"Selected1") < 1)
			{
				SetPVarInt(playerid,"Selected1",1);
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"NEONS");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"WHITE");
				SetPVarInt(playerid,"Neons",2);
			}
			else if(GetPVarInt(playerid,"Selected1") == 1)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"WHEELS");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Shadow");
				SetPVarInt(playerid,"Wheels",9);
			}
			else if(GetPVarInt(playerid,"Selected1") == 2)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"SPOILERS");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Not Available");
				if(vehmodel == 562 || vehmodel == 560 || vehmodel == 565 || vehmodel == 561 || vehmodel == 559 || vehmodel == 558) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"X-Flow");
				}
				SetPVarInt(playerid,"Spoilers",2);
			}
			else if(GetPVarInt(playerid,"Selected1") == 3)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"HYDRAULICS");
				SetPVarInt(playerid,"Spoilers",0);
				SetPVarInt(playerid,"Wheels",0);
				SetPVarInt(playerid,"Neons",0);
				SetPVarInt(playerid,"Hydraulics",1);
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"-");
			}
			else if(GetPVarInt(playerid,"Selected1") == 4)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"H.BUMPER");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Not Available");
				if(vehmodel == 562 || vehmodel == 560 || vehmodel == 565 || vehmodel == 561 || vehmodel == 559 || vehmodel == 558) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"X-Flow");
				}
				SetPVarInt(playerid,"HBumper",2);
			}
			else if(GetPVarInt(playerid,"Selected1") == 5)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"B.BUMPER");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Not Available");
				if(vehmodel == 562 || vehmodel == 560 || vehmodel == 565 || vehmodel == 561 || vehmodel == 559 || vehmodel == 558) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"X-Flow");
				}
				SetPVarInt(playerid,"BBumper",2);
			}
			else if(GetPVarInt(playerid,"Selected1") == 6)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"NITRO");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"x2");
				SetPVarInt(playerid,"Nitro",4);
			}
			else if(GetPVarInt(playerid,"Selected1") == 7)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"NEONS");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"WHITE");
				SetPVarInt(playerid,"Neons",2);
			}
			TuningCamera(playerid);
		}
		if(playertextid == TuningTD[6][playerid])//right1
		{
			SetPVarInt(playerid,"Selected1",GetPVarInt(playerid,"Selected1")+1);
			if(GetPVarInt(playerid,"Selected1") == 1)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"WHEELS");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Shadow");
				SetPVarInt(playerid,"Wheels",9);
			}
			else if(GetPVarInt(playerid,"Selected1") == 2)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"SPOILERS");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Not Available");
				if(vehmodel == 562 || vehmodel == 560 || vehmodel == 565 || vehmodel == 561 || vehmodel == 559 || vehmodel == 558) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"X-Flow");
				}
				SetPVarInt(playerid,"Spoilers",2);
			}
			else if(GetPVarInt(playerid,"Selected1") == 3)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"HYDRAULICS");
				SetPVarInt(playerid,"Spoilers",0);
				SetPVarInt(playerid,"Wheels",0);
				SetPVarInt(playerid,"Neons",0);
				SetPVarInt(playerid,"Hydraulics",1);
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"-");
			}
			else if(GetPVarInt(playerid,"Selected1") == 4)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"H.BUMPER");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Not Available");
				if(vehmodel == 562 || vehmodel == 560 || vehmodel == 565 || vehmodel == 561 || vehmodel == 559 || vehmodel == 558) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"X-Flow");
				}
				SetPVarInt(playerid,"HBumper",2);
			}
			else if(GetPVarInt(playerid,"Selected1") == 5)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"B.BUMPER");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Not Available");
				if(vehmodel == 562 || vehmodel == 560 || vehmodel == 565 || vehmodel == 561 || vehmodel == 559 || vehmodel == 558) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"X-Flow");
				}
				SetPVarInt(playerid,"BBumper",2);
			}
			else if(GetPVarInt(playerid,"Selected1") == 6)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"NITRO");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"x2");
				SetPVarInt(playerid,"Nitro",4);
			}
			else if(GetPVarInt(playerid,"Selected1") == 7)
			{
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"NEONS");
				SetPVarInt(playerid,"Selected2",1);
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"WHITE");
				SetPVarInt(playerid,"Neons",2);
			}
			else if(GetPVarInt(playerid,"Selected1") > 7)
			{
				SetPVarInt(playerid,"Selected1",1);
				PlayerTextDrawSetString(playerid,TuningTD[2][playerid],"WHEELS");
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Shadow");
				SetPVarInt(playerid,"Wheels",9);
			}
			TuningCamera(playerid);
		}
		if(playertextid == TuningTD[5][playerid])//left2
		{
			NullComponents(playerid);
			if(GetPVarInt(playerid,"Selected1") == 1)//колёса
			{
				SetPVarInt(playerid,"Selected2",GetPVarInt(playerid,"Selected2")-1);
				if(GetPVarInt(playerid,"Selected2") < 1) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Shadow");
					SetPVarInt(playerid,"Wheels",8);
					SetPVarInt(playerid,"Selected2",1);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[7]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 1) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Shadow");
					SetPVarInt(playerid,"Wheels",9);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[0]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 2) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Mega");
					NullComponents(playerid);
					SetPVarInt(playerid,"Wheels",2);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[1]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 3) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Wires");
					SetPVarInt(playerid,"Wheels",3);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[2]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 4) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Classic");
					SetPVarInt(playerid,"Wheels",4);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[3]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 5) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Twist");
					SetPVarInt(playerid,"Wheels",5);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[4]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 6) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Grove");
					SetPVarInt(playerid,"Wheels",6);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[5]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 7) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Atomic");
					SetPVarInt(playerid,"Wheels",7);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[6]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 8) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Dollar");
					SetPVarInt(playerid,"Wheels",8);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[7]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
			}
			else if(GetPVarInt(playerid,"Selected1") == 2)//спойлеры
			{
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Not Available");
				if(vehmodel == 562 || vehmodel == 560 || vehmodel == 565 || vehmodel == 561 || vehmodel == 559 || vehmodel == 558) {
					SetPVarInt(playerid,"Selected2",GetPVarInt(playerid,"Selected2")-1);
					if(GetPVarInt(playerid,"Selected2") < 1) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Alien");
						SetPVarInt(playerid,"Spoilers",3);
						SetPVarInt(playerid,"Selected2",2);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceSpoilers[1]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
					else if(GetPVarInt(playerid,"Selected2") == 1) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"X-Flow");
						SetPVarInt(playerid,"Spoilers",2);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceSpoilers[0]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
					else if(GetPVarInt(playerid,"Selected2") == 2) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Alien");
						SetPVarInt(playerid,"Spoilers",3);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceSpoilers[1]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
				}
			}
			else if(GetPVarInt(playerid,"Selected1") == 3)//гидравлика
			{
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"-");
				SetPVarInt(playerid,"Spoilers",0);
				SetPVarInt(playerid,"Wheels",0);
				SetPVarInt(playerid,"Hydraulics",1);
				SetPVarInt(playerid,"Selected2",1);
				format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceHydraulics);
				GameTextForPlayer(playerid, tuning_str, 2000, 1);
			}
			else if(GetPVarInt(playerid,"Selected1") == 4)//передний бампер
			{
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Not Available");
				if(vehmodel == 562 || vehmodel == 560 || vehmodel == 565 || vehmodel == 561 || vehmodel == 559 || vehmodel == 558  || vehmodel == 534  || vehmodel == 536  || vehmodel == 535  || vehmodel == 576) {
					SetPVarInt(playerid,"Selected2",GetPVarInt(playerid,"Selected2")-1);
					if(GetPVarInt(playerid,"Selected2") < 1) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Alien");
						SetPVarInt(playerid,"HBumper",3);
						SetPVarInt(playerid,"Selected2",2);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceHBumper[1]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
					else if(GetPVarInt(playerid,"Selected2") == 1) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"X-Flow");
						SetPVarInt(playerid,"HBumper",2);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceHBumper[0]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
					else if(GetPVarInt(playerid,"Selected2") == 2) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Alien");
						SetPVarInt(playerid,"HBumper",3);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceHBumper[1]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
				}
			}
			else if(GetPVarInt(playerid,"Selected1") == 5)//задний бампер
			{
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Not Available");
				if(vehmodel == 562 || vehmodel == 560 || vehmodel == 565 || vehmodel == 561 || vehmodel == 559 || vehmodel == 558  || vehmodel == 534  || vehmodel == 536  || vehmodel == 535  || vehmodel == 576) {
					SetPVarInt(playerid,"Selected2",GetPVarInt(playerid,"Selected2")-1);
					if(GetPVarInt(playerid,"Selected2") < 1) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Alien");
						SetPVarInt(playerid,"BBumper",3);
						SetPVarInt(playerid,"Selected2",2);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceBBumper[1]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
					else if(GetPVarInt(playerid,"Selected2") == 1) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"X-Flow");
						SetPVarInt(playerid,"BBumper",2);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceBBumper[0]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
					else if(GetPVarInt(playerid,"Selected2") == 2) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Alien");
						SetPVarInt(playerid,"BBumper",3);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceBBumper[1]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
				}
			}
			else if(GetPVarInt(playerid,"Selected1") == 6)//нитро
			{
				SetPVarInt(playerid,"Selected2",GetPVarInt(playerid,"Selected2")-1);
				if(GetPVarInt(playerid,"Selected2") < 1) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"x10");
					SetPVarInt(playerid,"Nitro",3);
					SetPVarInt(playerid,"Selected2",3);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNitro[2]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 1) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"x2");
					SetPVarInt(playerid,"Nitro",4);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNitro[1]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 2) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"x5");
					SetPVarInt(playerid,"Nitro",2);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNitro[2]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 3) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"x10");
					SetPVarInt(playerid,"Nitro",3);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNitro[0]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
			}
			else if(GetPVarInt(playerid,"Selected1") == 7)//неоны
			{
				SetPVarInt(playerid,"Selected2",GetPVarInt(playerid,"Selected2")-1);
				if(GetPVarInt(playerid,"Selected2") < 1) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"YELLOW");
					SetPVarInt(playerid,"Neons",6);
					SetPVarInt(playerid,"Selected2",5);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNeons[3]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 1) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"WHITE");
					SetPVarInt(playerid,"Neons",2);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNeons[0]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 2) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"RED");
					SetPVarInt(playerid,"Neons",3);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNeons[1]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 3) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"GREEN");
					SetPVarInt(playerid,"Neons",4);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNeons[2]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 4) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"BLUE");
					SetPVarInt(playerid,"Neons",5);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNeons[3]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 5) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"YELLOW");
					SetPVarInt(playerid,"Neons",6);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNeons[4]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
			}
		}
		if(playertextid == TuningTD[7][playerid])//right2
		{
			NullComponents(playerid);
			if(GetPVarInt(playerid,"Selected1") == 1)//колёса
			{
				SetPVarInt(playerid,"Selected2",GetPVarInt(playerid,"Selected2")+1);
				if(GetPVarInt(playerid,"Selected2") == 1) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Shadow");
					SetPVarInt(playerid,"Wheels",9);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[0]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 2) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Mega");
					NullComponents(playerid);
					SetPVarInt(playerid,"Wheels",2);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[1]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 3) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Wires");
					SetPVarInt(playerid,"Wheels",3);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[2]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 4) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Classic");
					SetPVarInt(playerid,"Wheels",4);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[3]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 5) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Twist");
					SetPVarInt(playerid,"Wheels",5);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[4]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 6) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Grove");
					SetPVarInt(playerid,"Wheels",6);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[5]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 7) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Atomic");
					SetPVarInt(playerid,"Wheels",7);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[6]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 8) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Dollar");
					SetPVarInt(playerid,"Wheels",8);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[7]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") > 8) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Shadow");
					SetPVarInt(playerid,"Wheels",9);
					SetPVarInt(playerid,"Selected2",1);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceWheels[0]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
			}
			else if(GetPVarInt(playerid,"Selected1") == 2)//спойлеры
			{
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Not Available");
				if(vehmodel == 562 || vehmodel == 560 || vehmodel == 565 || vehmodel == 561 || vehmodel == 559 || vehmodel == 558) {
					SetPVarInt(playerid,"Selected2",GetPVarInt(playerid,"Selected2")+1);if(GetPVarInt(playerid,"Selected2") == 1) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"X-Flow");
						SetPVarInt(playerid,"Spoilers",2);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceSpoilers[0]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
					else if(GetPVarInt(playerid,"Selected2") == 2) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Alien");
						SetPVarInt(playerid,"Spoilers",3);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceSpoilers[1]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
					else if(GetPVarInt(playerid,"Selected2") > 2) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Alien");
						SetPVarInt(playerid,"Spoilers",2);
						SetPVarInt(playerid,"Selected2",2);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceSpoilers[0]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
				}
			}
			else if(GetPVarInt(playerid,"Selected1") == 3)//гидравлика
			{
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"-");
				SetPVarInt(playerid,"Spoilers",0);
				SetPVarInt(playerid,"Wheels",0);
				SetPVarInt(playerid,"Hydraulics",1);
				SetPVarInt(playerid,"Selected2",1);
				format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceHydraulics);
				GameTextForPlayer(playerid, tuning_str, 2000, 1);
			}
			else if(GetPVarInt(playerid,"Selected1") == 4)//передний бампер
			{
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Not Available");
				if(vehmodel == 562 || vehmodel == 560 || vehmodel == 565 || vehmodel == 561 || vehmodel == 559 || vehmodel == 558  || vehmodel == 534  || vehmodel == 536  || vehmodel == 535  || vehmodel == 576) {
					SetPVarInt(playerid,"Selected2",GetPVarInt(playerid,"Selected2")+1);if(GetPVarInt(playerid,"Selected2") == 1) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"X-Flow");
						SetPVarInt(playerid,"HBumper",2);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceHBumper[0]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
					else if(GetPVarInt(playerid,"Selected2") == 2) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Alien");
						SetPVarInt(playerid,"HBumper",3);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceHBumper[1]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
					else if(GetPVarInt(playerid,"Selected2") > 2) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Alien");
						SetPVarInt(playerid,"HBumper",2);
						SetPVarInt(playerid,"Selected2",2);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceHBumper[0]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
				}
			}
			else if(GetPVarInt(playerid,"Selected1") == 5)//задний бампер
			{
				PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Not Available");
				if(vehmodel == 562 || vehmodel == 560 || vehmodel == 565 || vehmodel == 561 || vehmodel == 559 || vehmodel == 558  || vehmodel == 534  || vehmodel == 536  || vehmodel == 535  || vehmodel == 576) {
					SetPVarInt(playerid,"Selected2",GetPVarInt(playerid,"Selected2")+1);if(GetPVarInt(playerid,"Selected2") == 1) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"X-Flow");
						SetPVarInt(playerid,"BBumper",2);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceBBumper[0]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
					else if(GetPVarInt(playerid,"Selected2") == 2) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Alien");
						SetPVarInt(playerid,"BBumper",3);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceBBumper[1]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
					else if(GetPVarInt(playerid,"Selected2") > 2) {
						PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"Alien");
						SetPVarInt(playerid,"BBumper",2);
						SetPVarInt(playerid,"Selected2",2);
						format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceBBumper[0]);
						GameTextForPlayer(playerid, tuning_str, 2000, 1);
					}
				}
			}
			else if(GetPVarInt(playerid,"Selected1") == 6)//нитро
			{
				SetPVarInt(playerid,"Selected2",GetPVarInt(playerid,"Selected2")+1);
				if(GetPVarInt(playerid,"Selected2") == 1) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"x2");
					SetPVarInt(playerid,"Nitro",4);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNitro[0]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 2) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"x5");
					SetPVarInt(playerid,"Nitro",2);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNitro[1]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 3) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"x10");
					SetPVarInt(playerid,"Nitro",3);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNitro[2]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") > 3) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"x10");
					SetPVarInt(playerid,"Nitro",4);
					SetPVarInt(playerid,"Selected2",3);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNitro[0]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
			}
			else if(GetPVarInt(playerid,"Selected1") == 7)//неоны
			{
				SetPVarInt(playerid,"Selected2",GetPVarInt(playerid,"Selected2")+1);
				if(GetPVarInt(playerid,"Selected2") == 1) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"WHITE");
					SetPVarInt(playerid,"Neons",2);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNeons[0]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 2) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"RED");
					SetPVarInt(playerid,"Neons",3);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNeons[1]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 3) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"GREEN");
					SetPVarInt(playerid,"Neons",4);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNeons[2]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 4) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"BLUE");
					SetPVarInt(playerid,"Neons",5);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNeons[3]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") == 5) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"YELLOW");
					SetPVarInt(playerid,"Neons",6);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNeons[4]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
				else if(GetPVarInt(playerid,"Selected2") < 1) {
					PlayerTextDrawSetString(playerid,TuningTD[3][playerid],"YELLOW");
					SetPVarInt(playerid,"Neons",2);
					SetPVarInt(playerid,"Selected2",5);
					format(tuning_str,sizeof(tuning_str),"~g~PRICE: %d$~n~",_TuningPriceNeons[0]);
					GameTextForPlayer(playerid, tuning_str, 2000, 1);
				}
			}
		}
		if(playertextid == TuningTD[8][playerid]) if(GetPlayerCars(playerid)) SPD(playerid, 6675, 0, "Тюнинг", "Вы действительно хотите купить данную деталь?", "Да", "Отмена");
		if(playertextid == TuningTD[9][playerid])//apply
		{
			if(GetPlayerCars(playerid))
			{
				if(GetPVarInt(playerid,"Wheels") > 1) {
					//NullComponentid(playerid);
					if(GetPVarInt(playerid,"Wheels") == 0) PI[playerid][pWheels] = 0;
					else if(GetPVarInt(playerid,"Wheels") == 1) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1073);
					else if(GetPVarInt(playerid,"Wheels") == 2) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1074);
					else if(GetPVarInt(playerid,"Wheels") == 3) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1076);
					else if(GetPVarInt(playerid,"Wheels") == 4) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1077);
					else if(GetPVarInt(playerid,"Wheels") == 5) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1078);
					else if(GetPVarInt(playerid,"Wheels") == 6) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1081);
					else if(GetPVarInt(playerid,"Wheels") == 7) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1085);
					else if(GetPVarInt(playerid,"Wheels") == 8) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1083);
					else if(GetPVarInt(playerid,"Wheels") == 9) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1073);
				}
				if(GetPVarInt(playerid,"Hydraulics") == 1) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1087);
				if(GetPVarInt(playerid,"Nitro") > 1) {
					//NullComponentid(playerid);
					if(GetPVarInt(playerid,"Nitro") == 0) PI[playerid][pNitro] = 0;
					else if(GetPVarInt(playerid,"Nitro") == 1) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1008);
					else if(GetPVarInt(playerid,"Nitro") == 2) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1009);
					else if(GetPVarInt(playerid,"Nitro") == 3) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1010);
					else if(GetPVarInt(playerid,"Nitro") == 4) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),1008);
				}
				if(GetPVarInt(playerid,"Spoilers") > 1) {
					//NullComponentid(playerid);
					new TuneID[2];
					if(GetVehicleModel(c) == 562) TuneID[0] = 1146, TuneID[1] = 1147;
					else if(GetVehicleModel(c) == 560) TuneID[0] = 1138, TuneID[1] = 1139;
					else if(GetVehicleModel(c) == 565) TuneID[0] = 1049, TuneID[1] = 1050;
					else if(GetVehicleModel(c) == 561) TuneID[0] = 1058, TuneID[1] = 1060;
					else if(GetVehicleModel(c) == 559) TuneID[0] = 1158, TuneID[1] = 1162;
					else if(GetVehicleModel(c) == 558) TuneID[0] = 1063, TuneID[1] = 1064;
					if(GetPVarInt(playerid,"Spoilers") == 1) PI[playerid][pSpoilers] = 0;
					else if(GetPVarInt(playerid,"Spoilers") == 2) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),TuneID[0]);
					else if(GetPVarInt(playerid,"Spoilers") == 3) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),TuneID[1]);
				}
				if(GetPVarInt(playerid,"HBumper") > 1) {
					//NullComponentid(playerid);
					new TuneID[2];
					if(GetVehicleModel(c) == 562) TuneID[0] = 1171, TuneID[1] = 1172;
					else if(GetVehicleModel(c) == 560) TuneID[0] = 1169, TuneID[1] = 1170;
					else if(GetVehicleModel(c) == 575) TuneID[0] = 1174, TuneID[1] = 1175;
					else if(GetVehicleModel(c) == 565) TuneID[0] = 1152, TuneID[1] = 1153;
					else if(GetVehicleModel(c) == 561) TuneID[0] = 1155, TuneID[1] = 1157;
					else if(GetVehicleModel(c) == 559) TuneID[0] = 1160, TuneID[1] = 1173;
					else if(GetVehicleModel(c) == 558) TuneID[0] = 1165, TuneID[1] = 1166;
					else if(GetVehicleModel(c) == 534) TuneID[0] = 1179, TuneID[1] = 1185;
					else if(GetVehicleModel(c) == 536) TuneID[0] = 1181, TuneID[1] = 1182;
					else if(GetVehicleModel(c) == 535) TuneID[0] = 1188, TuneID[1] = 1189;
					else if(GetVehicleModel(c) == 576) TuneID[0] = 1190, TuneID[1] = 1191;
					if(GetPVarInt(playerid,"HBumper") == 1) PI[playerid][pHBumper] = 0;
					else if(GetPVarInt(playerid,"HBumper") == 2) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),TuneID[0]);
					else if(GetPVarInt(playerid,"HBumper") == 3) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),TuneID[1]);
				}
				if(GetPVarInt(playerid,"BBumper") > 1) {
					//NullComponentid(playerid);
					new TuneID[2];
					if(GetVehicleModel(c) == 562) TuneID[0] = 1148, TuneID[1] = 1149;
					else if(GetVehicleModel(c) == 560) TuneID[0] = 1140, TuneID[1] = 1141;
					else if(GetVehicleModel(c) == 575) TuneID[0] = 1176, TuneID[1] = 1177;
					else if(GetVehicleModel(c) == 565) TuneID[0] = 1150, TuneID[1] = 1151;
					else if(GetVehicleModel(c) == 561) TuneID[0] = 1154, TuneID[1] = 1156;
					else if(GetVehicleModel(c) == 559) TuneID[0] = 1159, TuneID[1] = 1161;
					else if(GetVehicleModel(c) == 558) TuneID[0] = 1167, TuneID[1] = 1168;
					else if(GetVehicleModel(c) == 534) TuneID[0] = 1178, TuneID[1] = 1180;
					else if(GetVehicleModel(c) == 536) TuneID[0] = 1183, TuneID[1] = 1184;
					else if(GetVehicleModel(c) == 535) TuneID[0] = 1186, TuneID[1] = 1187;
					else if(GetVehicleModel(c) == 576) TuneID[0] = 1192, TuneID[1] = 1193;
					if(GetPVarInt(playerid,"BBumper") == 1) PI[playerid][pBBumper] = 0;
					else if(GetPVarInt(playerid,"BBumper") == 2) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),TuneID[0]);
					else if(GetPVarInt(playerid,"BBumper") == 3) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),TuneID[1]);
				}
				if(GetPVarInt(playerid,"Neons") > 1) {
					//NullComponentid(playerid);
					new TuneID;
					if(GetPVarInt(playerid,"Neons") == 1) TuneID = 0;
					else if(GetPVarInt(playerid,"Neons") == 2) TuneID = 18652;
					else if(GetPVarInt(playerid,"Neons") == 3) TuneID = 18647;
					else if(GetPVarInt(playerid,"Neons") == 4) TuneID = 18649;
					else if(GetPVarInt(playerid,"Neons") == 5) TuneID = 18648;
					else if(GetPVarInt(playerid,"Neons") == 6) TuneID = 18650;
					DestroyDynamicObject(NeonObject[playerid][0]),DestroyDynamicObject(NeonObject[playerid][1]);
					if(TuneID != 0) {
						NeonObject[playerid][0] = CreateDynamicObject(TuneID,0,0,0,0,0,0,-1,-1,-1,150.0);
						AttachDynamicObjectToVehicle(NeonObject[playerid][0], GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
						NeonObject[playerid][1] = CreateDynamicObject(TuneID,0,0,0,0,0,0,-1,-1,-1,150.0);
						AttachDynamicObjectToVehicle(NeonObject[playerid][1], GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
					}
				}
			}
		}
		if(playertextid == TuningTD[10][playerid]) SPD(playerid, 6676, 0, "Тюнинг", "Вы действительно хотите выйти из СТО?", "Да", "Отмена");
		return true;
	}
	if(GetPVarInt(playerid,"UseCasino")) {
		if(playertextid == CasinoDraw[9][playerid]) {
			if(GetPVarInt(playerid, "BALANCE") > GetPVarInt(playerid,"BET")-1) {
				if(GetPVarInt(playerid, "BET") > 0) PutPlayerInSlotMachine(playerid);
			}
			else SendClientMessage(playerid, COLOR_GREY, "На вашем балансе не достаточно средств для игры!");
		}
		if(playertextid == CasinoDraw[11][playerid]) {
			if(GetPVarInt(playerid, "BET") > 1999) {
				SetPVarInt(playerid,"BET",GetPVarInt(playerid,"BET")+2000);
				strin = "";
				format(strin,sizeof(strin),"~g~BALANCE: %d$~n~CTABKA: %d$",GetPVarInt(playerid,"BALANCE"),GetPVarInt(playerid,"BET"));
				PlayerTextDrawSetString(playerid, CasinoDraw[10][playerid], strin);
			}
		}
		if(playertextid == CasinoDraw[12][playerid]) {
			if(GetPVarInt(playerid, "BET") > 3999) {
				SetPVarInt(playerid,"BET",GetPVarInt(playerid,"BET")-2000);
				strin = "";
				format(strin,sizeof(strin),"~g~BALANCE: %d$~n~CTABKA: %d$",GetPVarInt(playerid,"BALANCE"),GetPVarInt(playerid,"BET"));
				PlayerTextDrawSetString(playerid, CasinoDraw[10][playerid], strin);
			}
		}
		if(playertextid == CasinoDraw[13][playerid])//BET
			SPD(playerid, 6686, DIALOG_STYLE_INPUT, "Баланс", "Введите кол-во:", "Готово", "Отмена");

		if(playertextid == CasinoDraw[14][playerid]) {
			if(GetPVarInt(playerid,"DigitsUse") < 1) return true;
			ExitPlayerFromSlotMachine(playerid);
			for(new i;i<6;i++) TextDrawHideForPlayer(playerid,Digit1[i]);
			for(new i;i<6;i++) TextDrawHideForPlayer(playerid,Digit2[i]);
			for(new i;i<6;i++) TextDrawHideForPlayer(playerid,Digit3[i]);
			for(new i; i < 15; i++) PlayerTextDrawHide(playerid,CasinoDraw[i][playerid]);
			SetPVarInt(playerid,"UseCasino",0);
			CancelSelectTextDraw(playerid);
			if(GetPVarInt(playerid,"BALANCE") < 200) GameTextForPlayer(playerid,"~r~You loser.~n~_",5000,4);
			if(GetPVarInt(playerid,"BALANCE") > 0) GiveMoney(playerid,GetPVarInt(playerid,"BALANCE")),GameTextForPlayer(playerid,"~w~You winner.~n~_",5000,4);
			SetTimerEx("UseCasinoCloses", 1000, false, "d", playerid);
		}
		return true;
	}
	if(InShop[playerid]) {
		worldcar[playerid] = 1 + playerid;
		if(playertextid == AutoSalonTD[1][playerid]) {
			if((GetTickCount() - PlayerLastTick[playerid]) < 300) return 1;
			pPressed[playerid]++;
			DestroyVehicle(BuyVeh[playerid]);
			if(pPressed[playerid]>=sizeof(Cars_C)) pPressed[playerid]=0;
			BuyVeh[playerid] = CreateVehicle(Cars_C[pPressed[playerid]][0],536.2600,-1301.2469,16.2431,327.7638,ColorVeh[playerid][0]=random(10),ColorVeh[playerid][1]=random(10),10000);
			LinkVehicleToInterior(BuyVeh[playerid],0);
			SetPlayerInterior(playerid,0);
			SetVehicleVirtualWorld(BuyVeh[playerid], worldcar[playerid]);
			SetPlayerVirtualWorld(playerid,worldcar[playerid]);
			PutPlayerInVehicleEx(playerid,BuyVeh[playerid],0);
			SetPlayerCameraPos(playerid,528.9800,-1299.3888,18.5611);
			SetPlayerCameraLookAt(playerid,536.2600,-1301.2469,16.2431);
			strin = "";
			format(strin,sizeof(strin),"~w~%s",VehicleNameS[Cars_C[pPressed[playerid]][0]-400]);
			PlayerTextDrawSetString(playerid,AutoSalonTD[4][playerid],strin);
			strin = "";
			format(strin,sizeof(strin),"~g~$%d",Cars_C[pPressed[playerid]][1]);
			PlayerTextDrawSetString(playerid,AutoSalonTD[5][playerid],strin);
			SetColor[playerid] = 0;
			PlayerLastTick[playerid] = GetTickCount();
		}
		if(playertextid == AutoSalonTD[2][playerid]) {
			if((GetTickCount() - PlayerLastTick[playerid]) < 300) return 1;
			pPressed[playerid]--;
			DestroyVehicle(BuyVeh[playerid]);
			if(pPressed[playerid] < 0) pPressed[playerid]=sizeof(Cars_C)-1;
			BuyVeh[playerid] = CreateVehicle(Cars_C[pPressed[playerid]][0],536.2600,-1301.2469,16.2431,327.7638,ColorVeh[playerid][0]=random(10),ColorVeh[playerid][1]=random(10),10000);
			LinkVehicleToInterior(BuyVeh[playerid],0);
			SetPlayerInterior(playerid,0);
			SetVehicleVirtualWorld(BuyVeh[playerid], worldcar[playerid]);
			SetPlayerVirtualWorld(playerid,worldcar[playerid]);
			PutPlayerInVehicleEx(playerid,BuyVeh[playerid],0);
			SetPlayerCameraPos(playerid,528.9800,-1299.3888,18.5611);
			SetPlayerCameraLookAt(playerid,536.2600,-1301.2469,16.2431);
			strin = "";
			format(strin,sizeof(strin),"~w~%s",VehicleNameS[Cars_C[pPressed[playerid]][0]-400]);
			PlayerTextDrawSetString(playerid,AutoSalonTD[4][playerid],strin);
			strin = "";
			format(strin,sizeof(strin),"~g~$%d",Cars_C[pPressed[playerid]][1]);
			PlayerTextDrawSetString(playerid,AutoSalonTD[5][playerid],strin);
			SetColor[playerid] = 0;
			PlayerLastTick[playerid] = GetTickCount();
		}
		if(playertextid == AutoSalonTD[7][playerid]) {
			strin = "";
			format(strin,sizeof(strin),"{ffffff}Вы хотите купить {ff0000}%s\n{ffffff}Цена: {7dd400}%i$",VehicleNameS[GetVehicleModel(BuyVeh[playerid])-400],Cars_C[pPressed[playerid]][1]);
			SPD(playerid, 6666, 0, "Автосалон", strin, "Да", "Отмена");
		}
		if(playertextid == AutoSalonTD[9][playerid])
			SetPVarInt(playerid,"_selectedColor",0),SPD(playerid, D_HEAL+58, DIALOG_STYLE_LIST, "Автосалон", "Красный\nГолубой\nЖелтый\nЗеленый\nСерый\nОранжевый\nЧерный\nБелый", "Выбрать", "Отмена");
		return true;
	}
	if(MenuFish[playerid]) {
		if(playertextid == FishTD[2][playerid]) {
			MenuFishClose(playerid);
			CancelSelectTextDraw(playerid);
			MenuFish[playerid] = 0;
			return true;
		}
		if(playertextid == FishTD[4][playerid]) return SPD(playerid,0,DIALOG_STYLE_MSGBOX,"Информация","{ffffff}Цена: 5000$\nС помощью этой удочки можно словить рыбу от 20кг до 50кг\n\n{2F85D5}Кнопка BUY - {ffffff}благодаря этой кнопке вы можете купить более мощный спининг ","OK","");
		if(playertextid == FishTD[5][playerid]) return SPD(playerid,0,DIALOG_STYLE_MSGBOX,"Информация","{ffffff}Цена: 10000$\nС помощью этой удочки можно словить рыбу от 50кг до 100кг\n\n{2F85D5}Кнопка BUY - {ffffff}благодаря этой кнопке вы можете купить более мощный спининг ","OK","");
		if(playertextid == FishTD[6][playerid]) return SPD(playerid,0,DIALOG_STYLE_MSGBOX,"Информация","{ffffff}Цена: 15000$\nС помощью этой удочки можно словить рыбу от 150кг\n\n{2F85D5}Кнопка BUY - {ffffff}благодаря этой кнопке вы можете купить более мощный спининг ","OK","");
		if(playertextid == FishTD[7][playerid]) {
			if(PI[playerid][pSpining] == 1) return SendClientMessage(playerid,COLOR_RED,"У вас уже есть эта удочка");
			if(PI[playerid][pCash] < 5000) return SendClientMessageEx(playerid, COLOR_GREY, "У вас нет столько денег на руках");
			PI[playerid][pSpining] = 1;
			PI[playerid][pCash] -= 5000;
			SendClientMessage(playerid,COLOR_RED,"{F7C226}Вы купили новую удочку за {ffffff}5000$");
			return true;
		}
		if(playertextid == FishTD[8][playerid]) {
			if(PI[playerid][pSpining] == 2) return SendClientMessage(playerid,COLOR_RED,"У вас уже есть эта удочка");
			if(PI[playerid][pCash] < 10000) return SendClientMessageEx(playerid, COLOR_GREY, "У вас нет столько денег на руках");
			PI[playerid][pSpining] = 2;
			PI[playerid][pCash] -= 10000;
			SendClientMessage(playerid,COLOR_RED,"{F7C226}Вы купили новую удочку за {ffffff}10000$");
			return true;
		}
		if(playertextid == FishTD[9][playerid]) {
			if(PI[playerid][pSpining] == 3) return SendClientMessage(playerid,COLOR_RED,"У вас уже есть эта удочка");
			if(PI[playerid][pCash] < 15000) return SendClientMessageEx(playerid, COLOR_GREY, "У вас нет столько денег на руках");
			PI[playerid][pSpining] = 3;
			PI[playerid][pCash] -= 15000;
			SendClientMessage(playerid,COLOR_RED,"{F7C226}Вы купили новую удочку за {ffffff}15000$");
			return true;
		}
	}
	for(new i; i != 21; i++) {
        if(playertextid == inv_SlotsPTD[playerid][i]) {
			if(!GetPVarInt(playerid,"ChangeSlot")) {
                SetPVarInt(playerid,"SelectSlot",i);
                if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] != 0) {
                    SetPVarInt(playerid,"ChangeSlot",GetPVarInt(playerid,"SelectSlot"));

				    PlayerTextDrawBackgroundColor(playerid,inv_SlotsPTD[playerid][GetPVarInt(playerid,"ChangeSlot")], -65281);
				    PlayerTextDrawShow(playerid,inv_SlotsPTD[playerid][GetPVarInt(playerid,"ChangeSlot")]);
				}
			}
			else if(GetPVarInt(playerid,"ChangeSlot") != 0) {
                SetPVarInt(playerid,"SelectSlot",i);
                PlayerTextDrawBackgroundColor(playerid,inv_SlotsPTD[playerid][GetPVarInt(playerid,"ChangeSlot")], -86);
                PlayerTextDrawShow(playerid,inv_SlotsPTD[playerid][GetPVarInt(playerid,"ChangeSlot")]);
                UpdateInventory(playerid);
                ObjInventory(playerid);
                SetPVarInt(playerid,"ChangeSlot",0);
                SetPVarInt(playerid,"SelectSlot",0);
			}
        }
        return true;
    }
    if(GetPVarInt(playerid,"SpecID") > 0) {
		format(text, 32, "%d", GetPVarInt(playerid, "SpecID"));
		if(playertextid == SpecTD[7][playerid]) cmd::spec(playerid, text);
		if(playertextid == SpecTD[8][playerid]) cmd::spec(playerid, text);
		if(playertextid == SpecTD[1][playerid]) SlapPlayer(GetPVarInt(playerid, "SpecID"));
		if(playertextid == SpecTD[2][playerid]) cmd::gm(playerid, text);
		if(playertextid == SpecTD[3][playerid]) cmd::gmcar(playerid, text);
		if(playertextid == SpecTD[4][playerid]) SPD(playerid, D_ADMIN_PRISON_TIME, 1, " ", "Введите время (в сек), на которое вы хотите посадить игрока", "Далее", "Выход");
		if(playertextid == SpecTD[5][playerid]) cmd::stats(playerid, text);
		if(playertextid == SpecTD[6][playerid]) SPD(playerid, D_ADMIN_KICK_REASON, 1, " ", "Введите причину кика данного игрока", "Далее", "Выход");
		if(playertextid == SpecTD[10][playerid]) SPD(playerid, D_ADMIN_WARN_REASON, 1, " ", "Введите причину предупреждения данного игрока", "Далее", "Выход");
		if(playertextid == SpecTD[11][playerid]) SPD(playerid, D_ADMIN_MUTE_TIME_REASON, 1, " ", "Введите время и причину бана чата данного игрока (через запятую)", "Далее", "Выход");
		if(playertextid == SpecTD[15][playerid]) cmd::specoff(playerid, "");
	}
	return 1;
}
public OnPlayerClickTextDraw(playerid, Text:clickedid) {
    if(clickedid == inv_BoxTD[3]) {
		if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 0 && PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] == 0) return 1;
		if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] != 0 && PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] != 0)
		{
			if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 1) cmd::healme(playerid, "");
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 2) cmd::time(playerid, "");
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 3) {
				if(maskuse[playerid] == 0) {
					SetPlayerColor(playerid, 0x7a766700);
					maskuse[playerid] = 1;
					ApplyAnimation(playerid, "SHOP", "ROB_Shifty", 4.1, 0, 0, 0, 0, 0);
					SendClientMessage(playerid, COLOR_PAYCHEC, "Ваше местоположение скрыто на 10 минут!");
					SetPlayerChatBubble(playerid, "{FF9900}одевает маску", -1, 20.0, 500);
					GameTextForPlayer(playerid, "~b~ INVISABLE ON", 800, 4);
					PlayerPlaySound(playerid, 21000, 0.0, 0.0, 0.0);
					strin = "";
					format(strin, sizeof(strin), "%s достал(а) маску", NamePlayer(playerid));
					ProxDetector(20.0, playerid, strin, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					MaskTimer[playerid] = SetTimerEx("MaskOff", 600000, false, "d", playerid);
				}
				else {
					SetPlayerTeamColor(playerid);
					maskuse[playerid] = 0;
					PI[playerid][pMask]--;
					GameTextForPlayer(playerid, "~y~ INVISABLE OFF", 800, 4);
					PlayerPlaySound(playerid, 21001, 0.0, 0.0, 0.0);
					strin = "";
					format(strin, sizeof(strin), "%s снял(а) маску",  NamePlayer(playerid));
					ProxDetector(20.0, playerid, strin, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					KillTimer(MaskTimer[playerid]);
					if(PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] != 1) {
						PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] -= 1;
					}
					else {
						PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
						PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
					}
				}
			}
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 4) {
				SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DRINK_SPRUNK);
				SetHealth(playerid,PI[playerid][pHeal]+10);
				PI[playerid][pSprunk]--;
				strin = "";
				format(strin, 64, "%s достал(а) банку лимонада и открыл(а) ее", NamePlayer(playerid));
				ProxDetectorNew(playerid,25.0,COLOR_PURPLE,strin);
				PlayerPlaySound(playerid,42600,0.0,0.0,0.0);
				if(PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] != 1) {
					PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] -= 1;
				}
				else {
					PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
					PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
				}
			}
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 5) {
				if(PI[playerid][pShield] > 0) {
					if(!UsingShield[playerid]) {
						ResetShield[playerid] = 20;
						UsingShield[playerid] = true;
						SetPlayerAttachedObject(playerid, 6, 18637, 14, 0.0, 0.0, 0.0, 0.0, 180.0, 180.0);
						ShowSHBarForPlayer(playerid, PI[playerid][pShield]);
						ApplyAnimation(playerid, "PED", "WEAPON_CROUCH", 4.1, 0, 1, 1, 1, 0, 0);
					}
					else
					{
						SetPlayerAttachedObject(playerid, 6, 18637, 1, 0.15, -0.05, 0.18, 90, 0, 270);
						HideSHBarForPlayer(playerid);
						UsingShield[playerid] = false;
						ClearAnimations(playerid);
					}
				}
			}
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 6) {
				if(PI[playerid][pHunger] >= 100) return SendClientMessage(playerid,COLOR_GREY,"Вы не голодны!");
				if(PI[playerid][pHunger]+20 > 100) PI[playerid][pHunger] = 100,SendClientMessage(playerid,COLOR_YELLOW,"Вы полностью наелись!");
				else PI[playerid][pHunger] += 20,SendClientMessageEx(playerid,COLOR_YELLOW,"Ваша сытость повышена до %d",PI[playerid][pHunger]);
				strin = "";
				format(strin, 90, "%s съел(а) пиццу",NamePlayer(playerid));
				ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
				PlayerPlaySound(playerid, 32200, 0.0, 0.0, 0.0);
				ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.0, 0, 0, 0, 0, 0,1);
				PI[playerid][pFood][0]--;
				if(PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] != 1)
				PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] -= 1;
				else {
					PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
					PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
				}
			}
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 7) {
				if(PI[playerid][pHunger] >= 100) return SendClientMessage(playerid,COLOR_GREY,"Вы не голодны!");
				if(PI[playerid][pHunger]+20 > 100) PI[playerid][pHunger] = 100,SendClientMessage(playerid,COLOR_YELLOW,"Вы полностью наелись!");
				else PI[playerid][pHunger] += 20,SendClientMessageEx(playerid,COLOR_YELLOW,"Ваша сытость повышена до %d",PI[playerid][pHunger]);
				strin = "";
				format(strin, 90, "%s съел(а) гамбургер",NamePlayer(playerid));
				ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
				PlayerPlaySound(playerid, 32200, 0.0, 0.0, 0.0);
				ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.0, 0, 0, 0, 0, 0,1);
				PI[playerid][pFood][1]--;
				if(PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] != 1)
				PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] -= 1;
				else {
					PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
					PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
				}
			}
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 8) {
				if(PI[playerid][pHunger] >= 100) return SendClientMessage(playerid,COLOR_GREY,"Вы не голодны!");
				if(PI[playerid][pHunger]+20 > 100) PI[playerid][pHunger] = 100,SendClientMessage(playerid,COLOR_YELLOW,"Вы полностью наелись!");
				else PI[playerid][pHunger] += 20,SendClientMessageEx(playerid,COLOR_YELLOW,"Ваша сытость повышена до %d",PI[playerid][pHunger]);
				strin = "";
				format(strin, 90, "%s съел(а) кусочки курицы",NamePlayer(playerid));
				ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
				PlayerPlaySound(playerid, 32200, 0.0, 0.0, 0.0);
				ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.0, 0, 0, 0, 0, 0,1);
				PI[playerid][pFood][2]--;
				if(PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] != 1) {
					PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] -= 1;
				}
				else {
					PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
					PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
				}
			}
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 9) cmd::call(playerid, "");
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 10) SendClientMessage(playerid, -1, "Переодевалка еще не готова");
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 11) GiveWeapon(playerid, 5, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 12) GiveWeapon(playerid, 3, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 13) GiveWeapon(playerid, 4, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 14) GiveWeapon(playerid, 2, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 15) GiveWeapon(playerid, 6, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 16) GiveWeapon(playerid, 8, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 17) GiveWeapon(playerid, 14, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 18) GiveWeapon(playerid, 22, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 19) GiveWeapon(playerid, 23, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 20) GiveWeapon(playerid, 24, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 21) GiveWeapon(playerid, 25, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 22) GiveWeapon(playerid, 27, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 23) GiveWeapon(playerid, 28, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 24) GiveWeapon(playerid, 29, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 25) GiveWeapon(playerid, 32, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 26) GiveWeapon(playerid, 30, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 27) GiveWeapon(playerid, 31, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 28) GiveWeapon(playerid, 33, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 29) GiveWeapon(playerid, 34, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 30) GiveWeapon(playerid, 46, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 31) GiveWeapon(playerid, 41, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 32) GiveWeapon(playerid, 42, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 33) GiveWeapon(playerid, 43, PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1]),PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0,PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 34) {
				SetPlayerArmorAC(playerid, 100);
				PI[playerid][pArmur] = 100;
				SendClientMessage(playerid,COLOR_PAYCHEC,"Вы надели бронежилет.");
				strin = "";
				format(strin, 64, "%s одевает бронежилет", NamePlayer(playerid));
				ProxDetectorNew(playerid,25.0,COLOR_PURPLE,strin);
				if(PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] != 1) {
					PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] -= 1;
				}
				else {
					PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
					PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
				}
			}
			else if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 35) SPD(playerid,79,DIALOG_STYLE_INPUT,"Наркотики","{ffffff}Введите кол-во килограмм металла\nкоторое хотите использовать.","Готово","Отмена");
			OpenInventory(playerid);
			UpdateInventory(playerid);
			ObjInventory(playerid);
			SetPVarInt(playerid,"ChangeSlot",0);
			SetPVarInt(playerid,"SelectSlot",0);
			return true;
		}
	}
	if(clickedid == inv_BoxTD[5]) // drop
	{
		if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 0 && PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] == 0) return 1;
		strin = "";
		format(strin, sizeof(strin), "%s выкидывает предмет на землю", NamePlayer(playerid));
		ProxDetector(10.0, playerid, strin, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		DropInventory(playerid);
	}
	if(clickedid == inv_BoxTD[7]) // info
	{
		if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 0 && PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] == 0) return 1;
		strin = "";
		format(strin,sizeof(strin),"{ffffff}Предмет: {32CD32}%s{ffffff}\nКоличество: {32CD32}%d{ffffff}\nОписание: {32CD32}%s",Items_All[PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1]][invName],PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1],Items_All[PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1]][invText]);
		SPD(playerid,999,0,"Рюкзак",strin,"X","");
	}
	if(clickedid == inv_BoxTD[20]) // exit
	{
        CancelSelectTextDraw(playerid);
		for(new i; i < 6; i++) PlayerTextDrawHide(playerid,inv_OtherPTD[playerid][i]);
        for(new i; i < 21; i++) PlayerTextDrawHide(playerid,inv_SlotsPTD[playerid][i]);
        for(new i; i < 22; i++) TextDrawHideForPlayer(playerid,inv_BoxTD[i]);
        SetPVarInt(playerid,"DrawInv",0);
        SetPVarInt(playerid,"ChangeSlot",0);
        SetPVarInt(playerid,"SelectSlot",0);
	}
	if(clickedid == Text:INVALID_TEXT_DRAW) {
		if(InShop[playerid]) CloseAB(playerid);
		if(GetPVarInt(playerid,"UseCasino"))
		{
			if(GetPVarInt(playerid,"DigitsUse") < 1) return SelectTextDraw(playerid, COLOR_RED);
			ExitPlayerFromSlotMachine(playerid);
			for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit1[i]);
			for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit2[i]);
			for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit3[i]);
			for(new i; i < 15; i++) PlayerTextDrawHide(playerid,CasinoDraw[i][playerid]);
			if(GetPVarInt(playerid,"BALANCE") < 200) GameTextForPlayer(playerid,"~r~You loser.~n~_",5000,4);
			if(GetPVarInt(playerid,"BALANCE") > 0) PI[playerid][pCash] += GetPVarInt(playerid,"BALANCE"),GameTextForPlayer(playerid,"~w~You winner.~n~_",5000,4);
			SetPVarInt(playerid,"UseCasino",0);
		}
		if(GetPVarInt(playerid,"TuningCar")) return SPD(playerid, 6676, 0, "Тюнинг", "Вы действительно хотите выйти из СТО?", "Да", "Отмена");
		if(MenuFish[playerid]) return MenuFishClose(playerid);
		if(PlayerRegs[playerid] || PlayerLogin[playerid]) return SelectTextDraw(playerid, COLOR_YELLOW);
		if(GetPVarInt(playerid,"DrawInv") > 0)
		{
			for(new i; i < 6; i++) PlayerTextDrawHide(playerid,inv_OtherPTD[playerid][i]);
            for(new i; i < 21; i++) PlayerTextDrawHide(playerid,inv_SlotsPTD[playerid][i]);
		    for(new i; i < 22; i++) TextDrawHideForPlayer(playerid,inv_BoxTD[i]);
			SetPVarInt(playerid,"ChangeSlot",0);
			SetPVarInt(playerid,"SelectSlot",0);
			SetPVarInt(playerid,"DrawInv",0);
		}
		if(GetPVarInt(playerid,"jobkrub_putcage_status") >= 1)
		SelectTextDraw(playerid, 0xFFFFFF40);
		if(GetPVarInt(playerid,"jobkrub_takecage_status") >= 1)
		SelectTextDraw(playerid, 0xFFFFFF40);
		return true;
	}
	return 1;
}
public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ) {
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

 	if (weaponid < 22 || weaponid > 38 || hittype > 5)
		return 0;

	if(!(-20000.0 <= z <= 20000.0))
		return 0;

	if(IsPlayerInAnyVehicle(playerid)) return false;
	if(weaponid == 38) return false;
	if( hittype == BULLET_HIT_TYPE_PLAYER && (BadFloat(fX) || BadFloat(fY) || BadFloat(fZ)) ) {
		Kick(playerid);
		return 0;
	}
	if(hittype == 1 && hitid != INVALID_PLAYER_ID && IsAGreenZone(playerid))
	return ApplyAnimation(playerid, "FAT", "IDLE_tired",4.0,1,0,0,0,0,1),SetPVarInt(playerid,"AntiDM",8);
	if(IsWeaponWithAmmo(weaponid)) {
		new count = 0;
		if(weaponid != CurrentWeapon[playerid]) CurrentWeapon[playerid] = weaponid, CurrentAmmo[playerid] = GetPlayerWeaponAmmo(playerid,weaponid), count++;
		if(GetPlayerWeaponAmmo(playerid,weaponid) > CurrentAmmo[playerid] || GetPlayerWeaponAmmo(playerid,weaponid) < CurrentAmmo[playerid])
		{
			CurrentAmmo[playerid] = GetPlayerWeaponAmmo(playerid,weaponid);
			NoReloading[playerid] = 0;
			count++;
		}
		if(GetPlayerWeaponAmmo(playerid,weaponid) != 0 && GetPlayerWeaponAmmo(playerid,weaponid) == CurrentAmmo[playerid] && count == 0)
		{
			NoReloading[playerid]++;
			if(NoReloading[playerid] >= 5) {
				NoReloading[playerid] = 0;
				CurrentWeapon[playerid] = 0;
				CurrentAmmo[playerid] = 0;
				if(PI[playerid][pAdmLevel] < 1) NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (#3144)");
				return 0;
			}
		}
	}
	return true;
}
public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid) {
	new Float: health, Float: armour, Float: dmg;
	GetPlayerArmour(damagedid, armour);
	GetPlayerHealth(damagedid, health);
	if (armour > 0) {
		if (amount > armour)
		{
			dmg = amount - armour;
			health = health - dmg;
			SetPlayerArmour(damagedid, 0.0);
			SetPlayerHealth(damagedid, health);
			return 1;
		}
		armour = armour - amount;
		SetPlayerArmour(damagedid, armour);
	}
	if (armour < 1) {
		health = health - amount;
		if (health < 1) SetPlayerHealth(damagedid, 0);
		SetPlayerHealth(damagedid, health);
	}
	if(Tazer[playerid] == 1 && GetPlayerWeapon(playerid) == 23) {
		new Float:losehp;
		losehp = TAZE_LOSEHP;
		if(Tazed[damagedid] == 1) return 1;
		new Float:x, Float:y, Float:z;
		GetPlayerPos(damagedid, x, y, z);
		ClearAnimations(damagedid);
		ApplyAnimation(damagedid,"PED","KO_skid_front",4.1,0,1,1,1,0);
		Spark[damagedid] = CreateObject(TAZE_SPARK, x, y, z-3, 0, 0, 0);
		SetTimerEx("DestroySpark", TAZE_DESTROY, 0, "i", damagedid);
		SetTimerEx("TazedRemove", TAZE_TIMER, 0, "i", damagedid);
		Tazer[playerid] = 0;
		SetPVarInt(playerid,"laser",0);
		RemovePlayerAttachedObject(playerid, 0);
		ApplyAnimation(playerid,"COLT45","colt45_reload",4.1,1,1,1,1,1,1);
		Tazed[damagedid] = 1;
		if(!losehp) SetPlayerHealth(damagedid, health+amount);
	}
	new Float:Dmg[3];
	GetPlayerArmour(damagedid, Dmg[1]);
	GetPlayerHealth(damagedid, Dmg[0]);
	if(Dmg[1] > 0) {
		if(amount > Dmg[1])
		{
			Dmg[2] = amount - Dmg[1];
			Dmg[0] = Dmg[0] - Dmg[2];
			SetPlayerArmorAC(damagedid, 0.0);
			return SetHealth(damagedid, Dmg[0]);
		}
		Dmg[1] = Dmg[1] - amount;
		SetPlayerArmorAC(damagedid, Dmg[1]);
	}
	if(Dmg[1] < 1) {
		Dmg[0] = Dmg[0] - amount;
		SetHealth(damagedid, Dmg[0]);
	}
	return true;
}
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid) {
	if(GetPVarInt(playerid,"DrawInv")) {
		static inv_str[128];

		new Float:health,Float:armour;
		GetPlayerHealth(playerid,health);
		GetPlayerArmour(playerid,armour);

		PlayerTextDrawTextSize(playerid, inv_OtherPTD[playerid][2], _invTM_percent(health), 0.000000);
		PlayerTextDrawTextSize(playerid, inv_OtherPTD[playerid][2], _invTM_percent(armour), 0.000000);
		PlayerTextDrawTextSize(playerid, inv_OtherPTD[playerid][2], _invTM_percent(PI[playerid][pHunger]), 0.000000);

		PlayerTextDrawSetPreviewModel(playerid, inv_OtherPTD[playerid][5], GetPlayerSkin(playerid)),
		PlayerTextDrawSetPreviewRot(playerid, inv_OtherPTD[playerid][5], 0.000000, 0.000000, 27.000000, 0.913106);

	    format(inv_str,sizeof(inv_str),"€ѓOPOB’E:_%.0f%~n~ ~n~ЂPOH•:_%.0f%~n~ ~n~C‘TOCT’:_%d%",health, armour, PI[playerid][pHunger]), PlayerTextDrawSetString(playerid,inv_OtherPTD[playerid][3],inv_str);
	}
	if(issuerid != 65535) {
		if(GetPVarInt(playerid, "LessPil") > 0 && GetPVarInt(issuerid, "LessPil") > 0 && weaponid == 9) {
			new Float:shealth,Float:slx, Float:sly, Float:slz;
			GetPlayerHealth(issuerid, shealth);
			SetHealth(issuerid, shealth-10);
			GetPlayerPos(issuerid, slx, sly, slz);
			t_SetPlayerPos(issuerid, slx, sly, slz+10);
			PlayerPlaySound(issuerid, 1130, slx, sly, slz+10);
			SetPlayerArmedWeapon(issuerid,0);
		}
		if(GetPVarInt(playerid, "GMinerMode") == 1) {
			new Float:shealth,Float:slx, Float:sly, Float:slz;
			GetPlayerHealth(issuerid, shealth);
			SetHealth(issuerid, shealth-10);
			GetPlayerPos(issuerid, slx, sly, slz);
			t_SetPlayerPos(issuerid, slx, sly, slz+10);
			PlayerPlaySound(issuerid, 1130, slx, sly, slz+10);
			SetPlayerArmedWeapon(issuerid,0);
		}
	}
	if(issuerid != INVALID_PLAYER_ID && amount > 0 && UsingShield[playerid]) {
		new Float:playerPos[3];
		GetPlayerPos(issuerid, playerPos[0], playerPos[1], playerPos[2]);
		new angle = GetPlayerAngleToPoint(playerid, playerPos[0], playerPos[1]);
		if((angle >= 40 && angle <= 100) || (angle >= -310 && angle <= -250)) {
			new anim = GetPlayerAnimationIndex(playerid);
			switch(weaponid) {
			case 9, 35..40, 16..18, 49..51, 53, 54: {}
			default: {
					if(anim == 1274) {
						if(PI[playerid][pShield] >= 20) PI[playerid][pShield] -= 20,SetDamage(playerid, issuerid, 0);
						else {
							SetDamage(playerid, issuerid, (20*2));
							UsingShield[playerid] = false;
							RemovePlayerAttachedObject(playerid, 6);
							PI[playerid][pShield] = 0.0;
							ClearAnimations(playerid);
						}
						return UpdatePlayerShield(playerid, PI[playerid][pShield]);
					}
				}
			}
		}
	}
	return true;
}

// ^^^^^^^^^^^^^^^^^^^^^^^ [ stocks ] ^^^^^^^^^^^^^^^^^^^^^^^^

stock GetPlayer2DZoneNumb(playerid) {
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	for(new i = 0; i < sizeof(gSAZones); i++)
		if(x >= gSAZones[i][SAZONE_AREA][0] && x <= gSAZones[i][SAZONE_AREA][3] && y >= gSAZones[i][SAZONE_AREA][1] && y <= gSAZones[i][SAZONE_AREA][4])
			return i;

	return 0;
}

stock GetPlayerRankName(playerid) {
	new rank[40];
	rank = "";
	if(PI[playerid][pMember] > 0)
	{
		rank = FractionRank[PI[playerid][pMember]-1][PI[playerid][pRank]-1];
		return rank;
	}
	rank = "---";
	return rank;
}
stock GiveMoney(playerid, amount) PI[playerid][pCash]+=amount, GivePlayerMoney(playerid, amount);

stock SetMoney(playerid, amount) {
	PI[playerid][pCash] = amount;
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, amount);
}
stock GetMoney(playerid) return PI[playerid][pCash];
stock LoadPickups() {
    GaragePick = CreateDynamicPickup(1318, 23, 872.4926,708.3679,1039.8275);

	PirsTable[0] = CreateDynamicObject(19477, 2002.4, 949.9501, 303.5517, 0.0000, 0.0000, 90.0);
	SetDynamicObjectMaterialText(PirsTable[0], 0, "1 пирс: свободен", 130, "Arial", 34, 1, -1, 0, 1);

	PirsTable[1] = CreateDynamicObject(19477, 2002.4, 949.9501, 303.5517-0.25, 0.0000, 0.0000, 90.0);
	SetDynamicObjectMaterialText(PirsTable[1], 0, "2 пирс: свободен", 130, "Arial", 34, 1, -1, 0, 1);

	PirsTable[2] = CreateDynamicObject(19477, 2002.4, 949.9501, 303.5517-0.5, 0.0000, 0.0000, 90.0);
	SetDynamicObjectMaterialText(PirsTable[2], 0, "3 пирс: свободен", 130, "Arial", 34, 1, -1, 0, 1);

	PirsTable[3] = CreateDynamicObject(19477, 2002.4, 949.9501, 303.5517-0.75, 0.0000, 0.0000, 90.0);
	SetDynamicObjectMaterialText(PirsTable[3], 0, "4 пирс: свободен", 130, "Arial", 34, 1, -1, 0, 1);

	krub_marshruts[0][0][0] = -128.4010,krub_marshruts[0][0][1] = -1886.6324, 	krub_marshruts[0][0][2] = -0.3856;
	krub_marshruts[0][1][0] = -127.6826,krub_marshruts[0][1][1] = -2050.7385, 	krub_marshruts[0][1][2] = -0.2064;
	krub_marshruts[0][2][0] = -84.3117, krub_marshruts[0][2][1] = -2202.1987, 	krub_marshruts[0][2][2] = -0.5461;
	krub_marshruts[0][3][0] = 49.2982, 	krub_marshruts[0][3][1] = -2384.5054, 	krub_marshruts[0][3][2] = -0.5246;
	krub_marshruts[0][4][0] = 126.1628, krub_marshruts[0][4][1] = -2597.7336, 	krub_marshruts[0][4][2] = -0.0075;
	krub_marshruts[0][5][0] = 159.6115, krub_marshruts[0][5][1] = -2770.5767, 	krub_marshruts[0][5][2] = -0.3780;

	krub_marshruts[1][0][0] = 47.5163, 	krub_marshruts[1][0][1] = -1810.0233, 	krub_marshruts[1][0][2] = -0.3440;
	krub_marshruts[1][1][0] = 57.2600, 	krub_marshruts[1][1][1] = -1899.6796, 	krub_marshruts[1][1][2] = -0.1136;
	krub_marshruts[1][2][0] = 91.6969, 	krub_marshruts[1][2][1] = -2008.6724, 	krub_marshruts[1][2][2] = -0.4787;
	krub_marshruts[1][3][0] = 152.3719, krub_marshruts[1][3][1] = -2100.2781, 	krub_marshruts[1][3][2] = -0.0264;
	krub_marshruts[1][4][0] = 254.9006, krub_marshruts[1][4][1] = -2250.3110, 	krub_marshruts[1][4][2] = -0.4314;
	krub_marshruts[1][5][0] = 339.5017, krub_marshruts[1][5][1] = -2383.3218, 	krub_marshruts[1][5][2] = -0.1427;

	krub_marshruts[2][0][0] = 108.4260, krub_marshruts[2][0][1] = -1929.7310, 	krub_marshruts[2][0][2] = -0.1003;
	krub_marshruts[2][1][0] = 225.9564, krub_marshruts[2][1][1] = -2013.3167, 	krub_marshruts[2][1][2] = -0.0952;
	krub_marshruts[2][2][0] = 475.0978, krub_marshruts[2][2][1] = -2098.2097, 	krub_marshruts[2][2][2] = -0.1068;
	krub_marshruts[2][3][0] = 647.7400, krub_marshruts[2][3][1] = -2094.5320, 	krub_marshruts[2][3][2] = -0.0431;
	krub_marshruts[2][4][0] = 776.5416, krub_marshruts[2][4][1] = -2088.5032, 	krub_marshruts[2][4][2] = 0.0192;
	krub_marshruts[2][5][0] = 862.2403, krub_marshruts[2][5][1] = -2163.1184, 	krub_marshruts[2][5][2] = -0.0571;

	pickup_krubjob = CreateDynamicPickup(1275, 23, 2005.5111,956.0656,302.0517, -1, -1, -1, 100.0);
	midias[0] = CreateDynamicPickup(902, 2, -54.5660000,-2277.0056200,-50.4455000, -1, -1, -1, 100.0); //object(starfish) (1)
	CreateDynamicPickup(902, 2, -37.3450000,-2210.0258800,-54.5658000, -1, -1, -1, 100.0); //object(starfish) (2)
	CreateDynamicPickup(902, 2, -16.9473000,-2310.7197300,-49.1653000, -1, -1, -1, 100.0); //object(starfish) (3)
	CreateDynamicPickup(2782, 2, -31.5139000,-2234.1811500,-49.1880000, -1, -1, -1, 100.0); //object(cj_oyster_2) (1)
	CreateDynamicPickup(2782, 2, -43.7983000,-2243.8730500,-48.8721000, -1, -1, -1, 100.0); //object(cj_oyster_2) (2)
	CreateDynamicPickup(2782, 2, -61.7089000,-2216.3422900,-50.0873000, -1, -1, -1, 100.0); //object(cj_oyster_2) (3)
	CreateDynamicPickup(2782, 2, -57.1672000,-2233.1801800,-39.6340000, -1, -1, -1, 100.0); //object(cj_oyster_2) (4)
	CreateDynamicPickup(2782, 2, -45.2628000,-2272.2136200,-48.8721000, -1, -1, -1, 100.0); //object(cj_oyster_2) (5)
	CreateDynamicPickup(2782, 2, -51.4140000,-2289.5842300,-40.1739000, -1, -1, -1, 100.0); //object(cj_oyster_2) (6)
	CreateDynamicPickup(2782, 2, -64.0166000,-2300.5825200,-48.5519000, -1, -1, -1, 100.0); //object(cj_oyster_2) (7)
	CreateDynamicPickup(2782, 2, -62.4442000,-2300.2775900,-48.6338000, -1, -1, -1, 100.0); //object(cj_oyster_2) (8)
	CreateDynamicPickup(2782, 2, -64.1675000,-2299.8232400,-49.2732000, -1, -1, -1, 100.0); //object(cj_oyster_2) (9)
	CreateDynamicPickup(2782, 2, -73.7924000,-2331.0378400,-50.3169000, -1, -1, -1, 100.0); //object(cj_oyster_2) (10)
	CreateDynamicPickup(2782, 2, -76.9211000,-2318.5361300,-50.0719000, -1, -1, -1, 100.0); //object(cj_oyster_2) (11)
	CreateDynamicPickup(2782, 2, -60.7648000,-2338.5878900,-50.6204000, -1, -1, -1, 100.0); //object(cj_oyster_2) (12)
	CreateDynamicPickup(2782, 2, -64.8007000,-2351.7817400,-48.8721000, -1, -1, -1, 100.0); //object(cj_oyster_2) (13)
	CreateDynamicPickup(2782, 2, -90.8236000,-2354.5459000,-46.5015000, -1, -1, -1, 100.0); //object(cj_oyster_2) (14)
	CreateDynamicPickup(2782, 2, -46.5735000,-2371.5998500,-49.4779000, -1, -1, -1, 100.0); //object(cj_oyster_2) (15)
	CreateDynamicPickup(2782, 2, -22.9814000,-2390.2314500,-50.5774000, -1, -1, -1, 100.0); //object(cj_oyster_2) (16)
	CreateDynamicPickup(2782, 2, -3.9525000,-2371.9133300,-53.5691000, -1, -1, -1, 100.0); //object(cj_oyster_2) (17)
	CreateDynamicPickup(2782, 2, -2.7709000,-2370.4257800,-53.3415000, -1, -1, -1, 100.0); //object(cj_oyster_2) (18)
	CreateDynamicPickup(2782, 2, -7.2092000,-2350.8161600,-50.3276000, -1, -1, -1, 100.0); //object(cj_oyster_2) (19)
	CreateDynamicPickup(2782, 2, -20.4200000,-2359.0498000,-50.6024000, -1, -1, -1, 100.0); //object(cj_oyster_2) (20)
	CreateDynamicPickup(2782, 2, -33.5430000,-2355.4528800,-48.8721000, -1, -1, -1, 100.0); //object(cj_oyster_2) (21)
	CreateDynamicPickup(2782, 2, -29.9534000,-2348.5612800,-46.6947000, -1, -1, -1, 100.0); //object(cj_oyster_2) (22)
	CreateDynamicPickup(2782, 2, -18.6706000,-2339.5283200,-40.6972000, -1, -1, -1, 100.0); //object(cj_oyster_2) (23)
	CreateDynamicPickup(902, 2, -21.0637000,-2332.0649400,-49.1653000, -1, -1, -1, 100.0); //object(starfish) (4)
	CreateDynamicPickup(2782, 2, 53.3215000,-2400.6940900,-49.7765000, -1, -1, -1); //object(cj_oyster_2) (24)
	CreateDynamicPickup(2782, 2, 59.0973000,-2412.9990200,-48.1852000, -1, -1, -1, 100.0); //object(cj_oyster_2) (26)
	CreateDynamicPickup(2782, 2, 39.8136000,-2423.8867200,-49.5240000, -1, -1, -1, 100.0); //object(cj_oyster_2) (27)
	CreateDynamicPickup(2782, 2, 29.8116000,-2404.5554200,-49.7270000, -1, -1, -1, 100.0); //object(cj_oyster_2) (28)
	CreateDynamicPickup(2782, 2, 28.6519000,-2392.4074700,-48.8721000, -1, -1, -1, 100.0); //object(cj_oyster_2) (29)
	CreateDynamicPickup(2782, 2, 46.9873000,-2374.1994600,-46.9787000, -1, -1, -1, 100.0); //object(cj_oyster_2) (30)
	CreateDynamicPickup(2782, 2, 40.5018000,-2353.7170400,-46.1113000, -1, -1, -1, 100.0); //object(cj_oyster_2) (31)
	CreateDynamicPickup(2782, 2, 19.9080000,-2374.3442400,-56.4012000, -1, -1, -1, 100.0); //object(cj_oyster_2) (32)
	CreateDynamicPickup(2782, 2, 8.0190000,-2325.7346200,-50.0208000, -1, -1, -1, 100.0); //object(cj_oyster_2) (33)
	CreateDynamicPickup(2782, 2, -27.2726000,-2311.6596700,-48.0430000, -1, -1, -1, 100.0); //object(cj_oyster_2) (34)
	CreateDynamicPickup(2782, 2, -3.3125000,-2305.5026900,-48.9775000, -1, -1, -1, 100.0); //object(cj_oyster_2) (35)
	CreateDynamicPickup(2782, 2, -11.4163000,-2296.4213900,-50.3084000, -1, -1, -1, 100.0); //object(cj_oyster_2) (36)
	CreateDynamicPickup(2782, 2, -30.7467000,-2290.2519500,-48.9069000, -1, -1, -1, 100.0); //object(cj_oyster_2) (37)
	CreateDynamicPickup(2782, 2, -20.5880000,-2277.5524900,-52.5523000, -1, -1, -1, 100.0); //object(cj_oyster_2) (38)
	CreateDynamicPickup(2782, 2, -7.9842000,-2277.4155300,-54.1613000, -1, -1, -1, 100.0); //object(cj_oyster_2) (39)
	CreateDynamicPickup(2782, 2, 21.7287000,-2279.9121100,-48.4819000, -1, -1, -1, 100.0); //object(cj_oyster_2) (40)
	CreateDynamicPickup(2782, 2, 25.2741000,-2266.0073200,-48.8721000, -1, -1, -1, 100.0); //object(cj_oyster_2) (41)
	CreateDynamicPickup(2782, 2, 16.9655000,-2242.4387200,-48.8721000, -1, -1, -1, 100.0); //object(cj_oyster_2) (42)
	CreateDynamicPickup(2782, 2, 62.5394000,-2287.4118700,-44.9357000, -1, -1, -1, 100.0); //object(cj_oyster_2) (43)
	CreateDynamicPickup(2782, 2, 56.9894000,-2249.4340800,-48.2336000, -1, -1, -1, 100.0); //object(cj_oyster_2) (44)
	CreateDynamicPickup(2782, 2, 39.8502000,-2328.8837900,-50.1570000, -1, -1, -1, 100.0); //object(cj_oyster_2) (45)
	CreateDynamicPickup(2782, 2, 41.3868000,-2313.7790500,-49.5897000, -1, -1, -1, 100.0); //object(cj_oyster_2) (46)
	CreateDynamicPickup(2782, 2, 44.7652000,-2317.3505900,-46.8522000, -1, -1, -1, 100.0); //object(cj_oyster_2) (47)
	CreateDynamicPickup(2782, 2, 44.0317000,-2318.3064000,-46.2939000, -1, -1, -1, 100.0); //object(cj_oyster_2) (48)
	CreateDynamicPickup(2782, 2, 28.3925000,-2341.1428200,-48.8721000, -1, -1, -1, 100.0); //object(cj_oyster_2) (49)
	CreateDynamicPickup(2782, 2, 25.4487000,-2331.7627000,-48.8721000, -1, -1, -1, 100.0); //object(cj_oyster_2) (50)
	CreateDynamicPickup(2782, 2, 18.2683000,-2316.7451200,-48.8386000, -1, -1, -1, 100.0); //object(cj_oyster_2) (51)
	CreateDynamicPickup(2782, 2, 10.8244000,-2312.0681200,-46.8063000, -1, -1, -1, 100.0); //object(cj_oyster_2) (52)
	CreateDynamicPickup(2782, 2, 7.8700000,-2308.9458000,-47.4346000, -1, -1, -1, 100.0); //object(cj_oyster_2) (53)
	CreateDynamicPickup(2782, 2, 8.5421000,-2435.8806200,-46.3684000, -1, -1, -1, 100.0); //object(cj_oyster_2) (54)
	CreateDynamicPickup(2782, 2, 9.6438000,-2435.2021500,-46.3684000, -1, -1, -1, 100.0); //object(cj_oyster_2) (55)
	CreateDynamicPickup(2782, 2, 9.1883000,-2436.6213400,-46.3684000, -1, -1, -1, 100.0); //object(cj_oyster_2) (56)
	CreateDynamicPickup(2782, 2, -71.2829000,-2232.4926800,-54.5774000, -1, -1, -1, 100.0); //object(cj_oyster_2) (57)
	CreateDynamicPickup(2782, 2, -71.1348000,-2240.8120100,-53.1158000, -1, -1, -1, 100.0); //object(cj_oyster_2) (58)
	CreateDynamicPickup(2782, 2, -72.6066000,-2251.8557100,-50.7368000, -1, -1, -1, 100.0); //object(cj_oyster_2) (59)
	CreateDynamicPickup(2782, 2, -75.8244000,-2275.8676800,-54.0427000, -1, -1, -1, 100.0); //object(cj_oyster_2) (60)
	CreateDynamicPickup(2782, 2, -75.4903000,-2297.9465300,-50.9179000, -1, -1, -1, 100.0); //object(cj_oyster_2) (61)
	midias[1] = CreateDynamicPickup(2782, 2, -56.7199000,-2278.9397000,-50.6157000, -1, -1, -1, 100.0); //object(cj_oyster_2) (62)
	//
	CreateDynamicObject(19379,378.5710144,-1.5310000,1032.1230469,0.0000000,90.0000000,0.0000000); //object(wall027) (3)
	CreateDynamicObject(19368,373.4089966,-4.7300000,1033.9589844,0.0000000,0.0000000,0.0000000); //object(wall016) (1)
	CreateDynamicObject(19368,373.4085083,-1.5640000,1033.9589844,0.0000000,0.0000000,0.0000000); //object(wall016) (2)
	CreateDynamicObject(19368,373.4089966,1.5730000,1033.9589844,0.0000000,0.0000000,0.0000000); //object(wall016) (3)
	CreateDynamicObject(19368,383.0339966,1.4850000,1033.9589844,0.0000000,0.0000000,0.0000000); //object(wall016) (4)
	CreateDynamicObject(19368,383.0335083,-1.6520000,1033.9589844,0.0000000,0.0000000,0.0000000); //object(wall016) (5)
	CreateDynamicObject(19368,383.0339966,-4.7579999,1033.9589844,0.0000000,0.0000000,0.0000000); //object(wall016) (6)
	CreateDynamicObject(19368,375.0499878,3.1400001,1033.9589844,0.0000000,0.0000000,90.0000000); //object(wall016) (7)
	CreateDynamicObject(19368,378.2170105,3.1400502,1033.9589844,0.0000000,0.0000000,90.0000000); //object(wall016) (8)
	CreateDynamicObject(19368,381.3720093,3.1400001,1033.9589844,0.0000000,0.0000000,90.0000000); //object(wall016) (9)
	CreateDynamicObject(19368,381.4010010,-6.2649999,1033.9589844,0.0000000,0.0000000,90.0000000); //object(wall016) (10)
	CreateDynamicObject(19368,378.2239990,-6.2645998,1033.9589844,0.0000000,0.0000000,90.0000000); //object(wall016) (11)
	CreateDynamicObject(19368,375.1010132,-6.2649999,1033.9589844,0.0000000,0.0000000,90.0000000); //object(wall016) (12)
	CreateDynamicObject(19377,378.2739868,-1.5210000,1035.6599121,0.0000000,90.0000000,0.0000000); //object(wall025) (3)
	// место добычи золота
	new palata_tables = palata_tables = CreateDynamicObject(19477, -1373.1851, 2057.8454, 56.0017, 0.0000, 0.0000, 93.9380);//CreateDynamicObject(19477, -1373.1341, 2058.0241, 54.4332, -0.3999, 11.6999, 94.1513);
	SetDynamicObjectMaterialText(palata_tables, 0, "<< Золотой прииск >>", 130, "Tahoma", 48, 1, -1, -8092540, 1);

	palata_tables = CreateDynamicObject(19477, -1365.0842, 2100.2441, 44.8122, -3.4000, -11.1999, -127.9767);
	SetDynamicObjectMaterialText(palata_tables, 0, "Выдача породы", 120, "Tahoma", 44, 1, -1, 0, 1);

	LBizz[1][lObject] = CreateDynamicObject(19483, -1361.7292, 2106.2358, 42.1527, 0.8999, 0.0000, 36.8152);
	SetDynamicObjectMaterialText(palata_tables, 0, "Руды: 0x0 килограмм", 130, "Tahoma", 42, 1, -1, -12303292, 1);

	CreateDynamicObject(19471, -1361.767578,2106.212402,40.915527, 0.000000,0.000000,37.499996);// табличка для руды
	//
	CreateDynamicMapIcon(500.5708,-1358.3068,16.1657, 45, 0,-1,-1,-1,200.0); // Магазин одежды
	CreateDynamicMapIcon(1017.3256,-1549.7177,14.8594,30, 0,-1,-1,-1,200.0); // FBI
	CreateDynamicMapIcon(1481.3319,-1764.6432,18.7958,52, 0,-1,-1,-1,200.0); // Банк
	CreateDynamicMapIcon(1460.7948,-1363.3810,13.5469,19, 0,-1,-1,-1,200.0); // Мэрия
	CreateDynamicMapIcon(1177.0619,-1322.3219,14.2325,21, 0,-1,-1,-1,200.0); // Больница ЛС
	CreateDynamicMapIcon(1284.5100,-1332.4237,13.4712,36, 0,-1,-1,-1,200.0); // Автошкола
	CreateDynamicMapIcon(1558.8275,-1663.5156,6.2188, 30, 0,-1,-1,-1,200.0); // SAPD
	CreateDynamicMapIcon(1366.5776,-1279.5397,13.5469, 6, 0,-1,-1,-1,200.0); // Магазин оружий
	//
	FishJobPick[0] = CreateDynamicPickup(1275, 23, 326.5449,-1877.1675,901.9115,0,0);
	FishJobPick[1] = CreateDynamicPickup(1239, 23, 327.3812,-1884.7563,901.9893,0,0);
	ShahtaPick = CreateDynamicPickup(1275, 23, 495.2402,884.4384,3009.5884,1,5);
	//FarmPick[0] = CreateDynamicPickup(2228, 23, -384.7291,-1446.6842,25.7858,0,0);
	FarmPick[1] = CreateDynamicPickup(2228, 23, -1081.9622,-1639.3896,76.5859,0,0);
	cJobPick[0] = CreateDynamicPickup(1275, 23, -49.2835,-188.8889,928.7820,1,1);
	//MedCPick = CreateDynamicPickup(1275, 23, -2613.4961,-1655.1702,1660.2507,1,1);
	ePickup[0] = CreateDynamicPickup(1239, 23, 1124.4583,1270.7745,10.9078,2,2);
	BuyMetall = CreateDynamicPickup(19134, 23, 641.6887,891.0436,-42.6159,0,0);
	HotelPick = CreateDynamicPickup(19131,23,1714.8439,-1671.1849,20.2242,-1,18);
	//Колхоз
	Kolhoz = Create3DTextLabel("Состояние рабочих сил\nВсего рабочих: 0", 0x008080FF, -65.1434,110.3067,4.4177, 40.0, 0, 0);
	KolhozJobPickup[0] = CreateDynamicPickup(1239, 23, -65.0512,110.1186,3.1209, 0);
	KolhozJobPickup[1] = CreateDynamicPickup(1275, 23, -59.4166,103.1382,3.1229, 0);
	KolhozJobPickup[2] = CreateDynamicPickup(1274, 23, -61.0661,98.6025,3.1259, 0);
	//снаружи
	KolhozPickup[0] = CreateDynamicPickup(1318, 23, -47.2633,108.1302,3.3293, 0);
	KolhozPickup[1] = CreateDynamicPickup(1318, 23, -71.9255,97.1634,3.1172, 0);
	KolhozPickup[2] = CreateDynamicPickup(1318, 23, -58.8597,92.3216,3.1172, 0);
	//Внутри
	KolhozPickup[3] = CreateDynamicPickup(1318, 23, -55.4595,108.9164,3.1229, 0);
	KolhozPickup[4] = CreateDynamicPickup(1318, 23, -70.2420,96.2866,3.1259, 0);
	KolhozPickup[5] = CreateDynamicPickup(1318, 23, -60.6245,92.0067,3.1209, 0);
	//
	GetGun[0] = CreateDynamicPickup(353,23,1645.9854,-1621.9583,1583.8660,1,6);//SAPD
	GetGun[1] = CreateDynamicPickup(353,23,313.2028,296.1363,1000.0850,1,3);//FBI
	GetGun[2] = CreateDynamicPickup(353,23,-1374.5908,803.9024,1551.0859,-1,-1);//Army
	GetGun[3] = CreateDynamicPickup(353,23,-1346.0046,492.9919,11.2027,-1,-1);//VMF
	GetGun[4] = CreateDynamicPickup(353,23,1493.9117,-1362.2017,11.8859,-1,-1);//GOV
	CpJobs[0] = CreateDynamicPickup(1274,23,735.6561,-1423.9198,13.5374,0,0);
	GetGun[5] = CreateDynamicPickup(353,23,1645.9854,-1621.9583,1583.8660,2,6);//SFPD
	GetGun[6] = CreateDynamicPickup(353,23,1645.9854,-1621.9583,1583.8660,3,6);//LVPD
	FoodPick = CreateDynamicPickup(2867,23,1154.0596,-1336.0233,2495.3440,-1,-1);//food
	//
	CreateDynamicPickup(19131,23,686.6791,-1567.6246,14.5905,0,0);
	CreateDynamicPickup(19131,23,691.3149,-1567.6246,14.5905,0,0);
	CreateDynamicPickup(19131,23,695.7825,-1567.6246,14.5905,0,0);
	//
	BankPick = CreateDynamicPickup(1274, 23, 1512.3440,-1768.3522,13.6859,0,0);
	//
	CreateDynamic3DTextLabel("Нажмите 'H'\nЧтобы выехать",0xa4cd00FF,869.6716,719.5503,1039.8295,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("Выход", 0x317CDFAA, 872.4926,708.3679,1039.8275, 6.0, INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1, -1, -1);
	CreateDynamic3DTextLabel("BlackJack:\nНажмите 'ENTER'",0x33CCFFFF,1128.7073,-1.6476,1000.6797,15.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,12,1);
	CreateDynamic3DTextLabel("BlackJack:\nНажмите 'ENTER'",0x33CCFFFF,1125.0823,1.5977,1000.6797,15.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,12,1);
	CreateDynamic3DTextLabel("BlackJack:\nНажмите 'ENTER'",0x33CCFFFF,1125.1621,-5.0428,1000.6797,15.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,12,1);
	CreateDynamic3DTextLabel("Колесо удачи:\nНажмите 'ENTER'",0x33CCFFFF,1119.0302,-1.7804,1000.6910,15.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,12,1);
	CreateDynamic3DTextLabel("Игра кости:\nВведите /dice [id] [ставка].",0x33CCFFFF,1130.5620,-1.4281,1000.6797,15.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,12,1);
	CreateDynamic3DTextLabel("Введите:\n/tuning",0xa4cd00FF,686.6791,-1567.6246,14.5921,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("Введите:\n/tuning",0xa4cd00FF,691.3149,-1567.6246,14.5905,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("Введите:\n/tuning",0xa4cd00FF,695.7825,-1567.6246,14.5900,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("Покупка металла",COLOR_PAYCHEC,641.6887,891.0436,-42.6159,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("Нажмите 'H'\nЧтобы выехать",0xa4cd00FF,2222.3674,-2536.9604,2052.4434,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("Вход в дом",0x317CDFAA,1380.6390,-13.3978,1000.9246,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,18,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №1",0xBFF600FF,1708.7024,-1670.2324,23.7057+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №2",0xBFF600FF,1708.7043,-1665.0304,23.7044+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №3",0xBFF600FF,1708.7029,-1659.8270,23.7031+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №4",0xBFF600FF,1708.7021,-1654.5770,23.7018+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №5",0xBFF600FF,1708.7019,-1649.3079,23.6953+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №6",0xBFF600FF,1735.0483,-1642.2540,23.7578+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №7",0xBFF600FF,1735.0646,-1648.1945,23.7448+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №8",0xBFF600FF,1735.0820,-1654.0867,23.7318+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №9",0xBFF600FF,1735.0988,-1660.0123,23.7188+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №10",0xBFF600FF,1708.7017,-1670.2111,27.1953+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №11",0xBFF600FF,1708.7028,-1665.0184,27.1953+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №12",0xBFF600FF,1708.7098,-1659.7622,27.1953+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №13",0xBFF600FF,1708.7083,-1654.5234,27.1953+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №14",0xBFF600FF,1708.7184,-1649.2904,27.1953+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №15",0xBFF600FF,1735.0482,-1642.3508,27.2392+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №16",0xBFF600FF,1735.0631,-1648.2434,27.2304+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №17",0xBFF600FF,1735.0767,-1654.1727,27.2216+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	CreateDynamic3DTextLabel("{FFFF00}Комната №18",0xBFF600FF,1735.0927,-1660.0815,27.2128+1.5,5.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1,-1);
	//
	CreateDynamic3DTextLabel("Чтобы выйти из комнаты - /exithotel\nМеню комнаты - /hotel",COLOR_WHITE,-2168.4731,642.3249,1057.5938,3.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1,-1);
	CreateDynamic3DTextLabel("{FFFFFF}Покупка страховки",COLOR_BLACK, 1791.1073,-1710.7443,13.5489,12.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1, -1, -1);
	CreateDynamic3DTextLabel("{FFFFFF}Сдача на права",COLOR_BLACK, 1124.4583,1270.7745,10.9078,12.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1, -1, -1);
	CreateDynamic3DTextLabel("{FFFFFF}Устройство на работу",COLOR_BLACK, -1081.9622,-1639.3896,76.5859,12.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1, -1, -1);
	CreateDynamic3DTextLabel("{FFFFFF}Банковские услуги",COLOR_BLACK, 1512.3440,-1768.3522,13.6859,12.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1, -1, -1);
	CreateDynamic3DTextLabel("{FFFFFF}Трудоустройство",COLOR_BLACK, 1780.2455,-1703.5927,13.5629,12.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1, -1, -1);
	CreateDynamic3DTextLabel("{FFFFFF}Устройство на работу",COLOR_BLACK, 326.5449,-1877.1675,901.9115,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1, -1, -1);
	CreateDynamic3DTextLabel("{FFFFFF}Покупка удочек",COLOR_BLACK, 327.3812,-1884.7563,901.9893,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1, -1, -1);
	CreateDynamic3DTextLabel("Введите: /arrest",COLOR_LIGHTRED, 1568.7224,-1694.2434,5.8906+0.6,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1, -1, -1);
	CreateDynamic3DTextLabel("Чтобы купить наркотики\n\nвведите: /buydrugs",COLOR_YELLOW,331.5841,1123.0259,1083.6694,10.0);
	CreateDynamic3DTextLabel("Введите: /plist",COLOR_LIGHTGREEN, 2792.0034,-2456.1975,13.6326,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1, -1, -1);
	CreateDynamic3DTextLabel("Введите: /flist",COLOR_LIGHTGREEN, 248.7008,1445.8474,10.5919,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1, -1, -1);
	CreateDynamic3DTextLabel("{FFFFFF}Вы должны записаться в очередь!", COLOR_WHITE, 2522.1907,-1522.1350,23.8908,10.0);
	CreateDynamic3DTextLabel("<< Место добычи железа >>",0xFFFFFFFF, 416.7321,863.8525,3011.4116,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	CreateDynamic3DTextLabel("<< Место добычи железа >>",0xFFFFFFFF, 418.9579,878.6878,3011.7649,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	CreateDynamic3DTextLabel("<< Место добычи железа >>",0xFFFFFFFF, 430.3567,885.1015,3013.3110,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	CreateDynamic3DTextLabel("<< Место добычи железа >>",0xFFFFFFFF, 438.8086,885.2208,3013.8123,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	CreateDynamic3DTextLabel("<< Место добычи железа >>",0xFFFFFFFF, 438.8394,860.0536,3011.7625,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	CreateDynamic3DTextLabel("<< Место добычи железа >>",0xFFFFFFFF, 432.6754,860.3979,3012.6011,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	CreateDynamic3DTextLabel("<< Место добычи железа >>",0xFFFFFFFF, 423.9833,855.9692,3010.6992,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	CreateDynamic3DTextLabel("<< Место доставки железа >>",0xFFFFFFFF, 479.2834,866.8130,3008.5725,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	//
	BelayPick = CreateDynamicPickup(1241,23,727.5130,-1419.0669,13.5374,0,0);//страховка
	//
	CreateDynamicPickup(1247, 23, 1568.7224,-1694.2434,5.8906, -1, -1);//arrest
	ClotPick[0] = CreateDynamicPickup(1275, 23, 204.3595,-159.3505,1000.5234,-1,14); // Магазин одежды
	//
	Help = CreateDynamicPickup(1239, 23, 1109.3826,-1786.6215,16.5938,0,0); // Автовокзал
	//
	CreateDynamicMapIcon(542.0250,-1293.2084,17.2422, 55, 0,-1,-1,-1,200.0);
	//
	BuyCarPick[0] = CreateDynamicPickup(1239, 23, 547.5517,-1306.7711,16.3218,0,0);
	//
	CreateDynamicPickup(1239, 23, 2792.0034,-2456.1975,13.6326);
	CreateDynamicPickup(1239, 23, 248.7008,1445.8474,10.5919);
	//
	GruzPick[0] = CreateDynamicPickup(1275, 23, 1981.8635,-1991.0353,13.6615,0);
	//
	LessPick[0] = CreateDynamicPickup(1275, 23, -759.6343,-133.6706,65.7941,0);
	LessPick[1] = CreateDynamicPickup(1239, 23, -765.8640,-125.1859,65.5907,0);
	//
	LoadAmmoInfo[0][gBallas] = 0; LoadAmmoInfo[0][gVagos] = 0; LoadAmmoInfo[0][gGrove] = 0; LoadAmmoInfo[0][gAztek] = 0; LoadAmmoInfo[0][gRifa] = 0;
	//
	for(new i; i < sizeof(ATMInfo);i++) {
		new ATM;
		ATM = CreateObject(2754,ATMInfo[i][0],ATMInfo[i][1],ATMInfo[i][2],ATMInfo[i][3],ATMInfo[i][4],ATMInfo[i][5]);
		SetObjectMaterialText(ATM, "\nБанкомат\n        \n        \n        \n        \n        ", 2,OBJECT_MATERIAL_SIZE_256x256,"Tahoma", 48, 1, 0xFF000000, 0xFF9900AA, OBJECT_MATERIAL_TEXT_ALIGN_CENTER);//0xFFCD5C5C
	}
	for(new i = 1;i < MAX_VEHICLES;i ++) {
		for(new d;d < 10;d ++) VehicleSeat[i][d] = INVALID_PLAYER_ID;
	}
	for(new i; i < sizeof(Derevo); i++) gDerevo[i] = CreateObject(616,Derevo[i][0],Derevo[i][1],Derevo[i][2],0.0000000,0.0000000,0.0000000);
	return 1;
}
stock isAWaterPlayer(playerid) // 0 - не в воде, 1 - на воде, 2 - под водой
{
	if(GetPlayerAnimationIndex(playerid)) {
		new tanimlib[5], tanimname[16];
		GetAnimationName(GetPlayerAnimationIndex(playerid), tanimlib, 4, tanimname, 15);
		if(!strcmp(tanimlib, "SWIM"))
		{
			if(!strcmp(tanimname, "Swim_Glide", true) || !strcmp(tanimname, "Swim_Dive_Under", true) || !strcmp(tanimname, "Swim_Under", true)) return 2;
			else return 1;
		}
	}
	return 0;
}
stock Timer() {
	new newhour,newminute,newsecond;
	gettime(newhour, newminute, newsecond);
	if ((newhour > ghour) || (newhour == 0 && ghour == 23)) {
		ghour = newhour; PayDayTime(); SetWorldTime(newhour); SaveMoyor();
		if(ghour == 0 || ghour == 3 || ghour == 6 || ghour == 9 || ghour == 12 || ghour == 15 || ghour == 18 || ghour == 21 && TOTALGRUZ <= 0)
		{
			TOTALGRUZ = 500;
			strin = "";
			format(strin, 125, "{ffffff}Мешков: {e2ba00}%d из 500",TOTALGRUZ);
			Update3DTextLabelText(GruzText[0], COLOR_YELLOW, strin);
			SendClientMessageToAll(0x008D03AA,"[Грузчики]На склад привезли груз, ждем рабочих!");
		}
	}
	for(new i =0;i<sizeof(FrakCD);i++) {
		if(FrakCD[i] >0)
		{
			FrakCD[i] --;
			if(FrakCD[i] == 0) SendFMes(i,COLOR_LIGHTRED,"[F] Ваша банда снова может участвовать в захвате зон");
		}
	}
}
stock PayDayTime() {
	GetBizz(); GetHome();
	foreach(new i: Player) {
		if(PlayerLogged[i] != false)
		{
			new newhour,newminute,newsecond;
			gettime(newhour, newminute, newsecond);
			GameTextForPlayer(i, "PayDay", 5000, 1);
			SavePlayer(i);
			PayDay(i); GetExp(i);
		}
	}
}
stock PayDay(playerid) {
	new htax,hour,minute,second;
	gettime(hour,minute,second);
	new GZGANG[5];
	for(new i = 1; i <= TOTALGZ; i++) {
		if(GZInfo[i][gFrak] == 6) GZGANG[0]++;
		if(GZInfo[i][gFrak] == 7) GZGANG[1]++;
		if(GZInfo[i][gFrak] == 8) GZGANG[2]++;
		if(GZInfo[i][gFrak] == 9) GZGANG[3]++;
		if(GZInfo[i][gFrak] == 10) GZGANG[4]++;
	}
	if(IsTheMember(PI[playerid][pMember]))
	PI[playerid][pPayCheck] += FracPay[PI[playerid][pMember]-1]*PI[playerid][pRank];

	if(IsAGang(playerid)) {
		switch(PI[playerid][pMember])
		{
		case F_GROVE: PI[playerid][pPayCheck] += 60*GZGANG[0];
		case F_BALLAS: PI[playerid][pPayCheck] += 60*GZGANG[1];
		case F_AZTEC: PI[playerid][pPayCheck] += 60*GZGANG[2];
		case F_VAGOS: PI[playerid][pPayCheck] += 60*GZGANG[3];
		case F_RIFA: PI[playerid][pPayCheck] += 60*GZGANG[4];
		}
	}
	if(GetPVarInt(playerid, "GetHome") != 0) {
		SendClientMessage(playerid, COLOR_LIGHTRED, "<> Ваш дом был продан гос-ву за неуплату квартплаты.");
		SendClientMessage(playerid, COLOR_LIGHTRED, "<> Деньги за дом переведены на Ваш банковский счет!");
		PI[playerid][pHouseMoney] = 0;
		PI[playerid][pHouseDrugs] = 0;
		DeletePVar(playerid, "GetHome");
	}
	if(GetPVarInt(playerid, "_GetBizz_") > 0) {
		if(GetPlayerBizz(playerid) == 1)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ваш бизнес был закрыт по причине: отсутствие продуктов или отсутствие лицензии.",BizzInfo[GetPVarInt(playerid, "PlayerBizz")][bLockTime]);
			SendClientMessageEx(playerid, COLOR_LIGHTRED, "Если по истечению 12 часов бизнес будет закрыт, он будет продан гос-ву.");
			DeletePVar(playerid, "_GetBizz_");
		}
	}
	if(GetPVarInt(playerid, "GetBizz_") > 0 && GetPVarInt(playerid, "_GetBizz_") == 0) {
		if(GetPlayerBizz(playerid) == 1)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ваш бизнес закрыт уже %i час(а).",BizzInfo[GetPVarInt(playerid, "PlayerBizz")][bLockTime]);
			SendClientMessageEx(playerid, COLOR_LIGHTRED, "Если по истечению 12 часов бизнес будет закрыт, он будет продан гос-ву.");
			DeletePVar(playerid, "GetBizz_");
		}
	}
	if(GetPVarInt(playerid, "GetBizz") > 0) {
		SendClientMessage(playerid, COLOR_LIGHTRED,"Ваш бизнес был продан гос-ву за неуплату налогов.");
		SendClientMessage(playerid, COLOR_LIGHTRED,"Ваши деньги за бизнес были перечислены на ваш счет.");
		DeletePVar(playerid, "GetBizz");
	}
	PlusBankMoney(playerid, PI[playerid][pPayCheck]);
	//
	if(PI[playerid][pBelay] > 0) {
		if(PI[playerid][pBelay] < 1)
		{
			PI[playerid][pBelay] = 0;
			SendClientMessage(playerid,COLOR_LIGHTRED, "Срок контракта о страховки вашего здоровья истек!");
		}
		PI[playerid][pBelay] -= 1;
	}
	SetPlayerScore(playerid,PI[playerid][pLevel]);
	SendClientMessage(playerid, COLOR_GRAD1, "--------=== [ PAYDAY ] ===--------");
	SendClientMessageEx(playerid, COLOR_WHITE, "- Зарплата %d$",PI[playerid][pPayCheck]);
	PI[playerid][pPayCheck] = 0;
	new i = GetPVarInt(playerid, "PlayerHouse");
	if(GetPlayerHouse(playerid)) {
		if(!HouseInfo[i][hGrant])
		{
			if(!strcmp("E",HouseInfo[i][hDiscript],true)) htax = 100;
			if(!strcmp("C",HouseInfo[i][hDiscript],true)) htax = 150;
			if(!strcmp("B",HouseInfo[i][hDiscript],true)) htax = 200;
			if(!strcmp("A",HouseInfo[i][hDiscript],true)) htax = 250;
			if(!strcmp("S",HouseInfo[i][hDiscript],true)) htax = 700;
		}
		else {
			if(!strcmp("E",HouseInfo[i][hDiscript],true)) htax = 100/2;
			if(!strcmp("C",HouseInfo[i][hDiscript],true)) htax = 150/2;
			if(!strcmp("B",HouseInfo[i][hDiscript],true)) htax = 200/2;
			if(!strcmp("A",HouseInfo[i][hDiscript],true)) htax = 250/2;
			if(!strcmp("S",HouseInfo[i][hDiscript],true)) htax = 700/2;
		}
		SendClientMessageEx(playerid, COLOR_WHITE, "- Плата за дом: %d$", htax);
	}
	if(GetPlayerBizz(playerid)) SendClientMessageEx(playerid, COLOR_WHITE, "- Плата за бизнес: 100$");
	SendClientMessageEx(playerid, COLOR_WHITE, "- В банке: %d$", PI[playerid][pBank]);
	SendClientMessage(playerid, COLOR_GRAD1, "---------===============---------");
	SavePlayer(playerid);
	return 1;
}
stock findFreePirs() {
	for(new p = 0; p < MAX_PIRS; p++) if(!pirsinfo[p][statusp]) return p;
	return -1;
}
stock setPlayerPanelCage(playerid, height) {
	PlayerTextDrawHide(playerid, PTD_crubjob[playerid][15]), PlayerTextDrawDestroy(playerid, PTD_crubjob[playerid][15]);

	PTD_crubjob[playerid][15] = CreatePlayerTextDraw(playerid, 572.000000, (height == 1) ? (171.0) : (171.0+((18.75*height-1)-18.75)), "yashek");
	PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][15], 0);
	PlayerTextDrawFont(playerid,PTD_crubjob[playerid][15], 5);
	PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][15], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid,PTD_crubjob[playerid][15], -1);
	PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][15], 1);
	PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][15], 1);
	PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][15], 1);
	PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][15], 0);
	PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][15], 19.000000, 20.000000);
	PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][15], 964);
	PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][15], 0.000000, 0.000000, 0.000000, 1.000000);
	PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][15], 0);
	PlayerTextDrawShow(playerid, PTD_crubjob[playerid][15]);
	return 1;
}

stock showPlayerPanelCage(playerid, type, takeput) {
	if(type) {
		PTD_crubjob[playerid][0] = CreatePlayerTextDraw(playerid,462.000000, 139.000000, "box");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][0], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][0], 1);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][0], 0.500000, 25.100000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][0], 0);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][0], 0);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][0], 1);
		PlayerTextDrawSetShadow(playerid,PTD_crubjob[playerid][0], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][0], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][0], 1768515920);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][0], 605.000000, -88.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][0], 0);

		PTD_crubjob[playerid][1] = CreatePlayerTextDraw(playerid,467.000000, 144.000000, "box");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][1], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][1], 1);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][1], 0.500000, 25.100000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][1], 0);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][1], 0);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][1], 1);
		PlayerTextDrawSetShadow(playerid,PTD_crubjob[playerid][1], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][1], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][1], 512818981);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][1], 601.000000, -88.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][1], 0);

		PTD_crubjob[playerid][2] = CreatePlayerTextDraw(playerid,529.000000, 23.000000, "provod");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][2], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][2], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][2], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][2], 10145104);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][2], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][2], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][2], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][2], 0);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][2], 412.000000, 120.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][2], 16135);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][2], 90.000000, 0.000000, 115.000000, 1.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][2], 0);

		PTD_crubjob[playerid][3] = CreatePlayerTextDraw(playerid,459.000000, 165.000000, "niz");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][3], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][3], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][3], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][3], 512819008);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][3], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][3], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][3], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][3], 0);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][3], 150.000000, 39.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][3], 2606);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][3], 0.000000, 0.000000, 0.000000, 1.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][3], 0);

		PTD_crubjob[playerid][4] = CreatePlayerTextDraw(playerid,455.000000, 180.000000, "Strelka vverx");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][4], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][4], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][4], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][4], 16711935);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][4], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][4], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][4], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][4], 0); //255
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][4], 84.000000, 60.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][4], 19131);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][4], 0.000000, 90.000000, 270.000000, 0.899999);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][4], 1);

		PTD_crubjob[playerid][5] = CreatePlayerTextDraw(playerid,455.000000, 242.000000, "Strelka vniz");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][5], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][5], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][5], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][5], -16776961);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][5], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][5], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][5], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][5], 0); //16711935
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][5], 84.000000, 60.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][5], 19131);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][5], 0.000000, 90.000000, 90.000000, 0.899999);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][5], 1);

		PTD_crubjob[playerid][6] = CreatePlayerTextDraw(playerid,502.000000, 133.000000, "kater");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][6], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][6], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][6], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][6], -1);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][6], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][6], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][6], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][6], 0);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][6], 99.000000, 96.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][6], 453);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][6], 0.000000, 0.000000, 270.000000, 1.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][6], 0);

		PTD_crubjob[playerid][7] = CreatePlayerTextDraw(playerid,532.000000, 158.000000, "verevka");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][7], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][7], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][7], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][7], -1);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][7], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][7], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][7], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][7], 0);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][7], 99.000000, 96.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][7], 19087);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][7], 0.000000, 0.000000, 270.000000, 1.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][7], 0);

		PTD_crubjob[playerid][8] = CreatePlayerTextDraw(playerid,532.000000, 239.000000, "verevka");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][8], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][8], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][8], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][8], -1);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][8], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][8], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][8], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][8], 0);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][8], 99.000000, 96.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][8], 19087);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][8], 0.000000, 0.000000, 270.000000, 1.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][8], 0);

		PTD_crubjob[playerid][9] = CreatePlayerTextDraw(playerid,522.000000, 303.000000, "skalu");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][9], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][9], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][9], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][9], 780883967);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][9], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][9], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][9], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][9], 0);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][9], 99.000000, 96.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][9], 18228);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][9], 0.000000, 0.000000, 90.000000, 1.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][9], 0);

		PTD_crubjob[playerid][10] = CreatePlayerTextDraw(playerid,467.000000, 303.000000, "skalu");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][10], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][10], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][10], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][10], 780883967);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][10], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][10], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][10], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][10], 0);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][10], 99.000000, 96.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][10], 18228);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][10], 0.000000, 0.000000, 90.000000, 1.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][10], 0);

		PTD_crubjob[playerid][11] = CreatePlayerTextDraw(playerid,452.000000, 327.000000, "niz");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][11], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][11], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][11], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][11], 1018393087);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][11], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][11], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][11], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][11], 0);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][11], 162.000000, 90.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][11], 2606);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][11], 0.000000, 0.000000, 0.000000, 1.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][11], 0);

		PTD_crubjob[playerid][12] = CreatePlayerTextDraw(playerid,499.000000, 320.000000, "skalu");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][12], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][12], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][12], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][12], 780883967);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][12], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][12], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][12], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][12], 0);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][12], 95.000000, 75.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][12], 18228);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][12], 0.000000, 0.000000, 90.000000, 1.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][12], 0);

		PTD_crubjob[playerid][13] = CreatePlayerTextDraw(playerid,448.000000, 315.000000, "skalu");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][13], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][13], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][13], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][13], 780883967);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][13], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][13], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][13], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][13], 0);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][13], 99.000000, 96.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][13], 18228);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][13], 0.000000, 0.000000, 0.000000, 1.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][13], 0);

		PTD_crubjob[playerid][14] = CreatePlayerTextDraw(playerid,452.000000, 327.000000, "niz");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][14], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][14], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][14], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][14], 1018393087);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][14], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][14], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][14], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][14], 0);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][14], 162.000000, 90.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][14], 2606);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][14], 0.000000, 0.000000, 0.000000, 1.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][14], 0);

		if(takeput == 1) PTD_crubjob[playerid][15] = CreatePlayerTextDraw(playerid,572.000000, 171.0, "yashek");
		else PTD_crubjob[playerid][15] = CreatePlayerTextDraw(playerid,572.000000, 321.0, "yashek");
		PlayerTextDrawBackgroundColor(playerid,PTD_crubjob[playerid][15], 0);
		PlayerTextDrawFont(playerid,PTD_crubjob[playerid][15], 5);
		PlayerTextDrawLetterSize(playerid,PTD_crubjob[playerid][15], 0.500000, 1.000000);
		PlayerTextDrawColor(playerid,PTD_crubjob[playerid][15], -1);
		PlayerTextDrawSetOutline(playerid,PTD_crubjob[playerid][15], 1);
		PlayerTextDrawSetProportional(playerid,PTD_crubjob[playerid][15], 1);
		PlayerTextDrawUseBox(playerid,PTD_crubjob[playerid][15], 1);
		PlayerTextDrawBoxColor(playerid,PTD_crubjob[playerid][15], 0);
		PlayerTextDrawTextSize(playerid,PTD_crubjob[playerid][15], 19.000000, 20.000000);
		PlayerTextDrawSetPreviewModel(playerid, PTD_crubjob[playerid][15], 964);
		PlayerTextDrawSetPreviewRot(playerid, PTD_crubjob[playerid][15], 0.000000, 0.000000, 0.000000, 1.000000);
		PlayerTextDrawSetSelectable(playerid,PTD_crubjob[playerid][15], 0);

		///////
		for(new ptdh = 0; ptdh < 16; ptdh++) PlayerTextDrawShow(playerid, PTD_crubjob[playerid][ptdh]);
		SelectTextDraw(playerid, 0xFFFFFF40);
		return 1;
	}
	CancelSelectTextDraw(playerid);
	for(new ptdh = 0; ptdh < 16; ptdh++) PlayerTextDrawHide(playerid, PTD_crubjob[playerid][ptdh]), PlayerTextDrawDestroy(playerid, PTD_crubjob[playerid][ptdh]);
	return 1;
}
stock IsTheMember(member) {
	switch(member) {
	case 1,2,3,4,5,11,12,13,14,15,16,17: return 1;
	}
	return 0;
}
stock ClearBizz(i) {
	new playerid;
	sscanf(BizzInfo[i][bOwner], "u", playerid);
	if(IsPlayerConnected(playerid)) {
		PlusBankMoney(playerid, BizzInfo[i][bBuyPrice] / 2);
		SetPVarInt(playerid, "GetBizz", 1);
	}
	else
	{
		format(query,sizeof(query), "SELECT * FROM "TABLE_ACCOUNT" WHERE Name = '%s'",BizzInfo[i][bOwner]);
		mysql_function_query(cHandle, query, true, "BizzClear", "ii", i, playerid);
	}
	BizzInfo[i][bLock] = 0;
	BizzInfo[i][bLockTime] = 0;
	BizzInfo[i][bBuyPrice] = 0;
	BizzInfo[i][bMoney] = 0;
	BizzInfo[i][bLic] = 0;
	BizzInfo[i][bEnter] = 100;
	BizzInfo[i][bTill] = 50;
	strmid(BizzInfo[i][bOwner], "None", 0, strlen("None"), MAX_PLAYER_NAME);

	query = "";
	format(query, 512, "UPDATE "TABLE_BIZZ" SET owner='%s', block=%d, money=%d, bank=%d, lic=%d, penter=%d, till=%d, buyprice=%d, Mafia = '%s', product = %d WHERE id = %d LIMIT 1",
	BizzInfo[i][bOwner], BizzInfo[i][bLock], BizzInfo[i][bMoney], BizzInfo[i][bBank], BizzInfo[i][bLic], BizzInfo[i][bEnter], BizzInfo[i][bTill], BizzInfo[i][bBuyPrice],BizzInfo[i][bMafia],BizzInfo[i][bProduct],i);
	mysql_function_query(cHandle, query, false, "", "");
	UpdateBizz(i);
	return 1;
}
stock GetBizz() {
	for(new i = 1; i <= TOTALBIZZ; i++) {
		if(!strcmp(BizzInfo[i][bOwner],"None",true)) continue;
		if(BizzInfo[i][bMoney] < 100 || BizzInfo[i][bLock] == 1 && BizzInfo[i][bLockTime] >= 12) ClearBizz(i);
		else {
			new playerid;
			sscanf(BizzInfo[i][bOwner], "u", playerid);
			BizzPay[i] = 0;
			if(BizzInfo[i][bProduct] <= 0 || BizzInfo[i][bLic] == 0) {
				if(IsPlayerConnected(playerid)) {
					if(BizzInfo[i][bLockTime] == 0) SetPVarInt(playerid, "_GetBizz_", 1);
					BizzInfo[i][bLock] = 1;
					SetBizzInt(i, "block", BizzInfo[i][bLock]);
				}
			}
			if(BizzInfo[i][bLock] == 1) {
				BizzInfo[i][bLockTime]++;
				SetBizzInt(i, "locktime", BizzInfo[i][bLockTime]);
			}
			if(BizzInfo[i][bLockTime] > 1 && BizzInfo[i][bLockTime] < 12) {
				if(IsPlayerConnected(playerid)) SetPVarInt(playerid, "GetBizz_", 1);
			}
			BizzInfo[i][bMoney] -= 100;
			SetBizzInt(i, "money", BizzInfo[i][bMoney]);
		}
	}
	return 1;
}
stock GetHome() {
	new money;
	for(new i = 1; i <= TOTALHOUSE; i++) {
		if(!strcmp("None",HouseInfo[i][hOwner],true)) continue;
		if(!HouseInfo[i][hGrant])
		{
			if(!strcmp("E",HouseInfo[i][hDiscript],true)) money = 100;
			if(!strcmp("C",HouseInfo[i][hDiscript],true)) money = 150;
			if(!strcmp("B",HouseInfo[i][hDiscript],true)) money = 200;
			if(!strcmp("A",HouseInfo[i][hDiscript],true)) money = 250;
			if(!strcmp("S",HouseInfo[i][hDiscript],true)) money = 700;
		}
		else {
			if(!strcmp("E",HouseInfo[i][hDiscript],true)) money = 100/2;
			if(!strcmp("C",HouseInfo[i][hDiscript],true)) money = 150/2;
			if(!strcmp("B",HouseInfo[i][hDiscript],true)) money = 200/2;
			if(!strcmp("A",HouseInfo[i][hDiscript],true)) money = 250/2;
			if(!strcmp("S",HouseInfo[i][hDiscript],true)) money = 700/2;
		}
		if(HouseInfo[i][hOplata] >= money)
		{
			HouseInfo[i][hOplata] -= money;
			SetHouseInt(i, "hOplata", HouseInfo[i][hOplata]);
		}
		else {
			new ownerid;
			sscanf(HouseInfo[i][hOwner], "u", ownerid);
			if(IsPlayerConnected(ownerid) && PlayerLogged[ownerid] != false) {
				SetPVarInt(ownerid, "GetHome", 1);
				PlusBankMoney(ownerid, HouseInfo[i][hBuyPrice]), CheckBank(ownerid);
			}
			else {
				qurey = "";
				format(qurey, sizeof(qurey), "UPDATE "TABLE_ACCOUNT" SET Txt = '1', `PutMoney` = `PutMoney` + '%d' WHERE Name = '%s'", HouseInfo[i][hBuyPrice], HouseInfo[i][hOwner]);
				mysql_function_query(cHandle, qurey, false, "", "");
			}
			qurey = "";
			format(qurey, sizeof(qurey), "UPDATE "TABLE_HOUSE" SET hOwner = 'None', hOplata = '0', buyprice = '0', hLock = '0', hOutput = '0', hGrant = '0', hMedicine = '0' WHERE id = '%d'", i);
			mysql_function_query(cHandle, qurey, false, "", "");
			HouseInfo[i][hBuyPrice] = 0;
			HouseInfo[i][hOplata] = 0;
			strmid(HouseInfo[i][hOwner],"None",0,strlen("None"),MAX_PLAYER_NAME);
			HouseInfo[i][hLock] = 0;
			HouseInfo[i][hOutput] = 0;
			HouseInfo[i][hGrant] = 0;
			HouseInfo[i][hMedicine] = 0;
			UpdateHouse(i);
		}
	}
}


stock SetHealth(playerid, Float: Heal) {
	PI[playerid][pHeal] = Heal;
	return SetPlayerHealth(playerid, PI[playerid][pHeal]);
}

stock CreateTextDraws(playerid) {
	CasinoDraw[0][playerid] = CreatePlayerTextDraw(playerid, 463.647308, 133.916717, "usebox");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[0][playerid], 0.000000, 23.505769);
	PlayerTextDrawTextSize(playerid, CasinoDraw[0][playerid], 187.176513, 0.000000);
	PlayerTextDrawAlignment(playerid, CasinoDraw[0][playerid], 1);
	PlayerTextDrawColor(playerid, CasinoDraw[0][playerid], 0);
	PlayerTextDrawUseBox(playerid, CasinoDraw[0][playerid], true);
	PlayerTextDrawBoxColor(playerid, CasinoDraw[0][playerid], 184);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[0][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[0][playerid], 0);
	PlayerTextDrawFont(playerid, CasinoDraw[0][playerid], 0);

	CasinoDraw[1][playerid] = CreatePlayerTextDraw(playerid, 461.823638, 159.999908, "usebox");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[1][playerid], 0.000000, 20.352840);
	PlayerTextDrawTextSize(playerid, CasinoDraw[1][playerid], 189.058898, 0.000000);
	PlayerTextDrawAlignment(playerid, CasinoDraw[1][playerid], 1);
	PlayerTextDrawColor(playerid, CasinoDraw[1][playerid], 0);
	PlayerTextDrawUseBox(playerid, CasinoDraw[1][playerid], true);
	PlayerTextDrawBoxColor(playerid, CasinoDraw[1][playerid], -1523963197);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[1][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[1][playerid], 0);
	PlayerTextDrawFont(playerid, CasinoDraw[1][playerid], 0);
	PlayerTextDrawSetSelectable(playerid, CasinoDraw[1][playerid], true);

	CasinoDraw[2][playerid] = CreatePlayerTextDraw(playerid, 199.058822, 284.666717, "LD_POOL:ball");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[2][playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, CasinoDraw[2][playerid], 48.470581, 54.833312);
	PlayerTextDrawAlignment(playerid, CasinoDraw[2][playerid], 1);
	PlayerTextDrawColor(playerid, CasinoDraw[2][playerid], 102);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[2][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[2][playerid], 0);
	PlayerTextDrawFont(playerid, CasinoDraw[2][playerid], 4);

	CasinoDraw[3][playerid] = CreatePlayerTextDraw(playerid, 251.352874, 284.666717, "LD_POOL:ball");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[3][playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, CasinoDraw[3][playerid], 48.470581, 54.833312);
	PlayerTextDrawAlignment(playerid, CasinoDraw[3][playerid], 1);
	PlayerTextDrawColor(playerid, CasinoDraw[3][playerid], 102);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[3][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[3][playerid], 0);
	PlayerTextDrawFont(playerid, CasinoDraw[3][playerid], 4);

	CasinoDraw[4][playerid] = CreatePlayerTextDraw(playerid, 408.588043, 284.333221, "LD_POOL:ball");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[4][playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, CasinoDraw[4][playerid], 48.470581, 54.833312);
	PlayerTextDrawAlignment(playerid, CasinoDraw[4][playerid], 1);
	PlayerTextDrawColor(playerid, CasinoDraw[4][playerid], 102);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[4][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[4][playerid], 0);
	PlayerTextDrawFont(playerid, CasinoDraw[4][playerid], 4);

	CasinoDraw[5][playerid] = CreatePlayerTextDraw(playerid, 355.470306, 284.666717, "LD_POOL:ball");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[5][playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, CasinoDraw[5][playerid], 48.470581, 54.833312);
	PlayerTextDrawAlignment(playerid, CasinoDraw[5][playerid], 1);
	PlayerTextDrawColor(playerid, CasinoDraw[5][playerid], 102);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[5][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[5][playerid], 0);
	PlayerTextDrawFont(playerid, CasinoDraw[5][playerid], 4);

	CasinoDraw[6][playerid] = CreatePlayerTextDraw(playerid, 303.764312, 284.666717, "LD_POOL:ball");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[6][playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, CasinoDraw[6][playerid], 48.470581, 54.833312);
	PlayerTextDrawAlignment(playerid, CasinoDraw[6][playerid], 1);
	PlayerTextDrawColor(playerid, CasinoDraw[6][playerid], 102);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[6][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[6][playerid], 0);
	PlayerTextDrawFont(playerid, CasinoDraw[6][playerid], 4);

	CasinoDraw[7][playerid] = CreatePlayerTextDraw(playerid, 399.529205, 93.333305, "CASINO");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[7][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, CasinoDraw[7][playerid], -158.588165, 102.083320);
	PlayerTextDrawAlignment(playerid, CasinoDraw[7][playerid], 1);
	PlayerTextDrawColor(playerid, CasinoDraw[7][playerid], -1523963137);
	PlayerTextDrawBackgroundColor(playerid, CasinoDraw[7][playerid], 0x00000000);
	PlayerTextDrawUseBox(playerid, CasinoDraw[7][playerid], true);
	PlayerTextDrawBoxColor(playerid, CasinoDraw[7][playerid], 0);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[7][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[7][playerid], 1);
	PlayerTextDrawFont(playerid, CasinoDraw[7][playerid], 5);
	PlayerTextDrawSetProportional(playerid, CasinoDraw[7][playerid], 1);
	PlayerTextDrawSetPreviewModel(playerid, CasinoDraw[7][playerid], 7288);
	PlayerTextDrawSetPreviewRot(playerid, CasinoDraw[7][playerid], 0.000000, 0.000000, 90.000000, 1.000000);

	CasinoDraw[8][playerid] = CreatePlayerTextDraw(playerid, 462.235290, 196.916656, "_");
/*	PlayerTextDrawLetterSize(playerid, CasinoDraw[8][playerid], 0.000000, 6.615792);
	PlayerTextDrawTextSize(playerid, CasinoDraw[8][playerid], 188.117645, 0.000000);
	PlayerTextDrawAlignment(playerid, CasinoDraw[8][playerid], 1);
	PlayerTextDrawColor(playerid, CasinoDraw[8][playerid], 0);
	PlayerTextDrawUseBox(playerid, CasinoDraw[8][playerid], true);
	PlayerTextDrawBoxColor(playerid, CasinoDraw[8][playerid], 102);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[8][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[8][playerid], 0);
	PlayerTextDrawFont(playerid, CasinoDraw[8][playerid], 0);
*/
	CasinoDraw[9][playerid] = CreatePlayerTextDraw(playerid, 433.411773, 306.083312, "START");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[9][playerid], 0.407646, 1.430832);
	PlayerTextDrawTextSize(playerid, CasinoDraw[9][playerid], 8.411764, 42.583332);
	PlayerTextDrawAlignment(playerid, CasinoDraw[9][playerid], 2);
	PlayerTextDrawColor(playerid, CasinoDraw[9][playerid], -1);
	PlayerTextDrawUseBox(playerid, CasinoDraw[9][playerid], true);
	PlayerTextDrawBoxColor(playerid, CasinoDraw[9][playerid], 0);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[9][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[9][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CasinoDraw[9][playerid], 255);
	PlayerTextDrawFont(playerid, CasinoDraw[9][playerid], 1);
	PlayerTextDrawSetProportional(playerid, CasinoDraw[9][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, CasinoDraw[9][playerid], true);

	CasinoDraw[10][playerid] = CreatePlayerTextDraw(playerid, 322.882476, 163.750137, "_");//BALANCE\STABKA
	PlayerTextDrawLetterSize(playerid, CasinoDraw[10][playerid], 0.490000, 1.454166);
	PlayerTextDrawAlignment(playerid, CasinoDraw[10][playerid], 2);
	PlayerTextDrawColor(playerid, CasinoDraw[10][playerid], -1);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[10][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[10][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CasinoDraw[10][playerid], 255);
	PlayerTextDrawFont(playerid, CasinoDraw[10][playerid], 2);
	PlayerTextDrawSetProportional(playerid, CasinoDraw[10][playerid], 1);

	CasinoDraw[11][playerid] = CreatePlayerTextDraw(playerid, 380.294128, 306.083312, "+");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[11][playerid], 0.407646, 1.430832);
	PlayerTextDrawTextSize(playerid, CasinoDraw[11][playerid], 8.411764, 42.583332);
	PlayerTextDrawAlignment(playerid, CasinoDraw[11][playerid], 2);
	PlayerTextDrawColor(playerid, CasinoDraw[11][playerid], -1);
	PlayerTextDrawUseBox(playerid, CasinoDraw[11][playerid], true);
	PlayerTextDrawBoxColor(playerid, CasinoDraw[11][playerid], 0);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[11][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[11][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CasinoDraw[11][playerid], 255);
	PlayerTextDrawFont(playerid, CasinoDraw[11][playerid], 1);
	PlayerTextDrawSetProportional(playerid, CasinoDraw[11][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, CasinoDraw[11][playerid], true);

	CasinoDraw[12][playerid] = CreatePlayerTextDraw(playerid, 327.647125, 306.083312, "-");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[12][playerid], 0.407646, 1.430832);
	PlayerTextDrawTextSize(playerid, CasinoDraw[12][playerid], 8.411764, 42.583332);
	PlayerTextDrawAlignment(playerid, CasinoDraw[12][playerid], 2);
	PlayerTextDrawColor(playerid, CasinoDraw[12][playerid], -1);
	PlayerTextDrawUseBox(playerid, CasinoDraw[12][playerid], true);
	PlayerTextDrawBoxColor(playerid, CasinoDraw[12][playerid], 0);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[12][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[12][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CasinoDraw[12][playerid], 255);
	PlayerTextDrawFont(playerid, CasinoDraw[12][playerid], 1);
	PlayerTextDrawSetProportional(playerid, CasinoDraw[12][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, CasinoDraw[12][playerid], true);

	CasinoDraw[13][playerid] = CreatePlayerTextDraw(playerid, 275.941162, 306.083312, "ADD$");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[13][playerid], 0.407646, 1.430832);
	PlayerTextDrawTextSize(playerid, CasinoDraw[13][playerid], 8.411764, 42.583332);
	PlayerTextDrawAlignment(playerid, CasinoDraw[13][playerid], 2);
	PlayerTextDrawColor(playerid, CasinoDraw[13][playerid], -1);
	PlayerTextDrawUseBox(playerid, CasinoDraw[13][playerid], true);
	PlayerTextDrawBoxColor(playerid, CasinoDraw[13][playerid], 0);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[13][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[13][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CasinoDraw[13][playerid], 255);
	PlayerTextDrawFont(playerid, CasinoDraw[13][playerid], 1);
	PlayerTextDrawSetProportional(playerid, CasinoDraw[13][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, CasinoDraw[13][playerid], true);

	CasinoDraw[14][playerid] = CreatePlayerTextDraw(playerid, 223.294113, 306.083312, "EXIT");
	PlayerTextDrawLetterSize(playerid, CasinoDraw[14][playerid], 0.407646, 1.430832);
	PlayerTextDrawTextSize(playerid, CasinoDraw[14][playerid], 8.411764, 42.583332);
	PlayerTextDrawAlignment(playerid, CasinoDraw[14][playerid], 2);
	PlayerTextDrawColor(playerid, CasinoDraw[14][playerid], -1);
	PlayerTextDrawUseBox(playerid, CasinoDraw[14][playerid], true);
	PlayerTextDrawBoxColor(playerid, CasinoDraw[14][playerid], 0);
	PlayerTextDrawSetShadow(playerid, CasinoDraw[14][playerid], 0);
	PlayerTextDrawSetOutline(playerid, CasinoDraw[14][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CasinoDraw[14][playerid], 255);
	PlayerTextDrawFont(playerid, CasinoDraw[14][playerid], 1);
	PlayerTextDrawSetProportional(playerid, CasinoDraw[14][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, CasinoDraw[14][playerid], true);
	//
	RegDraws[0][playerid] = CreatePlayerTextDraw(playerid, 425.529296, 2.083334, "usebox");
	PlayerTextDrawLetterSize(playerid, RegDraws[0][playerid], 0.000000, 17.888118);
	PlayerTextDrawTextSize(playerid, RegDraws[0][playerid], 206.470535, 0.000000);
	PlayerTextDrawAlignment(playerid, RegDraws[0][playerid], 1);
	PlayerTextDrawColor(playerid, RegDraws[0][playerid], 0);
	PlayerTextDrawUseBox(playerid, RegDraws[0][playerid], true);
	PlayerTextDrawBoxColor(playerid, RegDraws[0][playerid], 255);
	PlayerTextDrawSetShadow(playerid, RegDraws[0][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[0][playerid], 0);
	PlayerTextDrawFont(playerid, RegDraws[0][playerid], 0);
	PlayerTextDrawSetPreviewModel(playerid, RegDraws[0][playerid], 0);
	PlayerTextDrawSetPreviewRot(playerid, RegDraws[0][playerid], 1.000000, 0.000000, 1.000000, 102.000000);

	RegDraws[1][playerid] = CreatePlayerTextDraw(playerid, 423.705871, -0.416666, "usebox");
	PlayerTextDrawLetterSize(playerid, RegDraws[1][playerid], 0.000000, 17.888101);
	PlayerTextDrawTextSize(playerid, RegDraws[1][playerid], 208.352966, 0.000000);
	PlayerTextDrawAlignment(playerid, RegDraws[1][playerid], 1);
	PlayerTextDrawColor(playerid, RegDraws[1][playerid], 0);
	PlayerTextDrawUseBox(playerid, RegDraws[1][playerid], true);
	PlayerTextDrawBoxColor(playerid, RegDraws[1][playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, RegDraws[1][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[1][playerid], 0);
	PlayerTextDrawFont(playerid, RegDraws[1][playerid], 0);
	PlayerTextDrawSetPreviewModel(playerid, RegDraws[1][playerid], 0);
	PlayerTextDrawSetPreviewRot(playerid, RegDraws[1][playerid], 1.000000, 0.000000, 1.000000, 102.000000);

	RegDraws[2][playerid] = CreatePlayerTextDraw(playerid, 248.470687, 75.250007, "ЊAPO‡’:");
	PlayerTextDrawLetterSize(playerid, RegDraws[2][playerid], 0.368117, 1.518333);
	PlayerTextDrawTextSize(playerid, RegDraws[2][playerid], 20.235300, 72.916648);
	PlayerTextDrawAlignment(playerid, RegDraws[2][playerid], 2);
	PlayerTextDrawColor(playerid, RegDraws[2][playerid], -1);
	PlayerTextDrawUseBox(playerid, RegDraws[2][playerid], true);
	PlayerTextDrawBoxColor(playerid, RegDraws[2][playerid], 255);
	PlayerTextDrawSetShadow(playerid, RegDraws[2][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[2][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[2][playerid], 51);
	PlayerTextDrawFont(playerid, RegDraws[2][playerid], 2);
	PlayerTextDrawSetProportional(playerid, RegDraws[2][playerid], 1);

	RegDraws[3][playerid] = CreatePlayerTextDraw(playerid, 248.529495, 97.250038, "ЊOЌTA:");
	PlayerTextDrawLetterSize(playerid, RegDraws[3][playerid], 0.368117, 1.518333);
	PlayerTextDrawTextSize(playerid, RegDraws[3][playerid], 20.235300, 72.916648);
	PlayerTextDrawAlignment(playerid, RegDraws[3][playerid], 2);
	PlayerTextDrawColor(playerid, RegDraws[3][playerid], -1);
	PlayerTextDrawUseBox(playerid, RegDraws[3][playerid], true);
	PlayerTextDrawBoxColor(playerid, RegDraws[3][playerid], 255);
	PlayerTextDrawSetShadow(playerid, RegDraws[3][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[3][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[3][playerid], 51);
	PlayerTextDrawFont(playerid, RegDraws[3][playerid], 2);
	PlayerTextDrawSetProportional(playerid, RegDraws[3][playerid], 1);

	RegDraws[4][playerid] = CreatePlayerTextDraw(playerid, 248.588348, 119.833389, "ЊO‡:");
	PlayerTextDrawLetterSize(playerid, RegDraws[4][playerid], 0.368117, 1.518333);
	PlayerTextDrawTextSize(playerid, RegDraws[4][playerid], 20.235300, 72.916648);
	PlayerTextDrawAlignment(playerid, RegDraws[4][playerid], 2);
	PlayerTextDrawColor(playerid, RegDraws[4][playerid], -1);
	PlayerTextDrawUseBox(playerid, RegDraws[4][playerid], true);
	PlayerTextDrawBoxColor(playerid, RegDraws[4][playerid], 255);
	PlayerTextDrawSetShadow(playerid, RegDraws[4][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[4][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[4][playerid], 51);
	PlayerTextDrawFont(playerid, RegDraws[4][playerid], 2);
	PlayerTextDrawSetProportional(playerid, RegDraws[4][playerid], 1);

	RegDraws[5][playerid] = CreatePlayerTextDraw(playerid, 355.470611, 74.750053, "BBECT…");
	PlayerTextDrawLetterSize(playerid, RegDraws[5][playerid], 0.368117, 1.518333);
	PlayerTextDrawTextSize(playerid, RegDraws[5][playerid], 23.058832, 128.916656);
	PlayerTextDrawAlignment(playerid, RegDraws[5][playerid], 2);
	PlayerTextDrawColor(playerid, RegDraws[5][playerid], -1);
	PlayerTextDrawUseBox(playerid, RegDraws[5][playerid], true);
	PlayerTextDrawBoxColor(playerid, RegDraws[5][playerid], 255);
	PlayerTextDrawSetShadow(playerid, RegDraws[5][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[5][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[5][playerid], 51);
	PlayerTextDrawFont(playerid, RegDraws[5][playerid], 2);
	PlayerTextDrawSetProportional(playerid, RegDraws[5][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, RegDraws[5][playerid], true);

	RegDraws[6][playerid] = CreatePlayerTextDraw(playerid, 355.529449, 97.333442, "BBECT…");
	PlayerTextDrawLetterSize(playerid, RegDraws[6][playerid], 0.368117, 1.518333);
	PlayerTextDrawTextSize(playerid, RegDraws[6][playerid], 23.058832, 128.916656);
	PlayerTextDrawAlignment(playerid, RegDraws[6][playerid], 2);
	PlayerTextDrawColor(playerid, RegDraws[6][playerid], -1);
	PlayerTextDrawUseBox(playerid, RegDraws[6][playerid], true);
	PlayerTextDrawBoxColor(playerid, RegDraws[6][playerid], 255);
	PlayerTextDrawSetShadow(playerid, RegDraws[6][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[6][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[6][playerid], 51);
	PlayerTextDrawFont(playerid, RegDraws[6][playerid], 2);
	PlayerTextDrawSetProportional(playerid, RegDraws[6][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, RegDraws[6][playerid], true);

	RegDraws[7][playerid] = CreatePlayerTextDraw(playerid, 355.588287, 119.916816, "B‘ЂPAT’");
	PlayerTextDrawLetterSize(playerid, RegDraws[7][playerid], 0.368117, 1.518333);
	PlayerTextDrawTextSize(playerid, RegDraws[7][playerid], 23.058832, 128.916656);
	PlayerTextDrawAlignment(playerid, RegDraws[7][playerid], 2);
	PlayerTextDrawColor(playerid, RegDraws[7][playerid], -1);
	PlayerTextDrawUseBox(playerid, RegDraws[7][playerid], true);
	PlayerTextDrawBoxColor(playerid, RegDraws[7][playerid], 255);
	PlayerTextDrawSetShadow(playerid, RegDraws[7][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[7][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[7][playerid], 51);
	PlayerTextDrawFont(playerid, RegDraws[7][playerid], 2);
	PlayerTextDrawSetProportional(playerid, RegDraws[7][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, RegDraws[7][playerid], true);

	RegDraws[8][playerid] = CreatePlayerTextDraw(playerid, 159.529449, -30.916650, "modelten");
	PlayerTextDrawLetterSize(playerid, RegDraws[8][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, RegDraws[8][playerid], 146.823562, 156.333282);
	PlayerTextDrawAlignment(playerid, RegDraws[8][playerid], 1);
	PlayerTextDrawColor(playerid, RegDraws[8][playerid], 109);
	PlayerTextDrawUseBox(playerid, RegDraws[8][playerid], true);
	PlayerTextDrawBoxColor(playerid, RegDraws[8][playerid], 0);
	PlayerTextDrawSetShadow(playerid, RegDraws[8][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[8][playerid], 1);
	PlayerTextDrawFont(playerid, RegDraws[8][playerid], 5);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[8][playerid], 0x00000000);
	PlayerTextDrawSetProportional(playerid, RegDraws[8][playerid], 1);
	PlayerTextDrawSetPreviewModel(playerid, RegDraws[8][playerid], 577);
	PlayerTextDrawSetPreviewRot(playerid, RegDraws[8][playerid], -6.000000, 0.000000, 7.000000, 1.000000);

	RegDraws[9][playerid] = CreatePlayerTextDraw(playerid, 159.588272, -35.749973, "model");
	PlayerTextDrawLetterSize(playerid, RegDraws[9][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, RegDraws[9][playerid], 146.823562, 156.333282);
	PlayerTextDrawAlignment(playerid, RegDraws[9][playerid], 1);
	PlayerTextDrawColor(playerid, RegDraws[9][playerid], -1523963137);
	PlayerTextDrawUseBox(playerid, RegDraws[9][playerid], true);
	PlayerTextDrawBoxColor(playerid, RegDraws[9][playerid], 0);
	PlayerTextDrawSetShadow(playerid, RegDraws[9][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[9][playerid], 1);
	PlayerTextDrawFont(playerid, RegDraws[9][playerid], 5);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[9][playerid], 0x00000000);
	PlayerTextDrawSetProportional(playerid, RegDraws[9][playerid], 1);
	PlayerTextDrawSetPreviewModel(playerid, RegDraws[9][playerid], 577);
	PlayerTextDrawSetPreviewVehCol(playerid, RegDraws[9][playerid], 3, 1);
	PlayerTextDrawSetPreviewRot(playerid, RegDraws[9][playerid], -10.000000, 0.000000, 7.000000, 1.000000);

	RegDraws[10][playerid] = CreatePlayerTextDraw(playerid, 302.529296, 14.583363, "WELCOME TO");
	PlayerTextDrawLetterSize(playerid, RegDraws[10][playerid], 0.430235, 1.821666);
	PlayerTextDrawAlignment(playerid, RegDraws[10][playerid], 1);
	PlayerTextDrawColor(playerid, RegDraws[10][playerid], -1);
	PlayerTextDrawSetShadow(playerid, RegDraws[10][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[10][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[10][playerid], 255);
	PlayerTextDrawFont(playerid, RegDraws[10][playerid], 2);
	PlayerTextDrawSetProportional(playerid, RegDraws[10][playerid], 1);

	RegDraws[11][playerid] = CreatePlayerTextDraw(playerid, 306.705810, 33.250019, LOGO_REGISTER);
	PlayerTextDrawLetterSize(playerid, RegDraws[11][playerid], 0.390235, 1.617500);
	PlayerTextDrawAlignment(playerid, RegDraws[11][playerid], 1);
	PlayerTextDrawColor(playerid, RegDraws[11][playerid], -1);
	PlayerTextDrawSetShadow(playerid, RegDraws[11][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[11][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[11][playerid], 255);
	PlayerTextDrawFont(playerid, RegDraws[11][playerid], 3);
	PlayerTextDrawSetProportional(playerid, RegDraws[11][playerid], 1);

	RegDraws[12][playerid] = CreatePlayerTextDraw(playerid, 285.176483, 12.833364, "_");
	PlayerTextDrawLetterSize(playerid, RegDraws[12][playerid], 0.964822, 4.190003);
	PlayerTextDrawTextSize(playerid, RegDraws[12][playerid], 416.941070, 11.083333);
	PlayerTextDrawAlignment(playerid, RegDraws[12][playerid], 1);
	PlayerTextDrawColor(playerid, RegDraws[12][playerid], -1);
	PlayerTextDrawUseBox(playerid, RegDraws[12][playerid], true);
	PlayerTextDrawBoxColor(playerid, RegDraws[12][playerid], 28);
	PlayerTextDrawSetShadow(playerid, RegDraws[12][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[12][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[12][playerid], 255);
	PlayerTextDrawFont(playerid, RegDraws[12][playerid], 3);
	PlayerTextDrawSetProportional(playerid, RegDraws[12][playerid], 1);

	RegDraws[13][playerid] = CreatePlayerTextDraw(playerid, 315.764678, 142.916687, "HA„M…TE, ЌTOЂ‘ ЊPOѓO‡„…T’");
	PlayerTextDrawLetterSize(playerid, RegDraws[13][playerid], 0.378000, 1.652500);
	PlayerTextDrawTextSize(playerid, RegDraws[13][playerid], 16.470592, 205.916687);
	PlayerTextDrawAlignment(playerid, RegDraws[13][playerid], 2);
	PlayerTextDrawColor(playerid, RegDraws[13][playerid], -1);
	PlayerTextDrawSetShadow(playerid, RegDraws[13][playerid], 1);
	PlayerTextDrawSetOutline(playerid, RegDraws[13][playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[13][playerid], 255);
	PlayerTextDrawFont(playerid, RegDraws[13][playerid], 1);
	PlayerTextDrawSetProportional(playerid, RegDraws[13][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, RegDraws[13][playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, RegDraws[13][playerid], 19461);
	PlayerTextDrawSetPreviewRot(playerid, RegDraws[13][playerid], 1.000000, -1.000000, 90.000000, 0.000000);

	RegDraws[14][playerid] = CreatePlayerTextDraw(playerid, 249.882369, 61.833335, "LD_POOL:ball");
	PlayerTextDrawLetterSize(playerid, RegDraws[14][playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, RegDraws[14][playerid], 122.352958, 7.000000);
	PlayerTextDrawAlignment(playerid, RegDraws[14][playerid], 1);
	PlayerTextDrawColor(playerid, RegDraws[14][playerid], 138);
	PlayerTextDrawSetShadow(playerid, RegDraws[14][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[14][playerid], 0);
	PlayerTextDrawFont(playerid, RegDraws[14][playerid], 4);
	PlayerTextDrawSetPreviewModel(playerid, RegDraws[14][playerid], 19461);
	PlayerTextDrawSetPreviewRot(playerid, RegDraws[14][playerid], 1.000000, -1.000000, 90.000000, 0.000000);

	RegDraws[15][playerid] = CreatePlayerTextDraw(playerid, 264.941162, 50.750007, "PE‚…CTPA‰…•");
	PlayerTextDrawLetterSize(playerid, RegDraws[15][playerid], 0.325294, 1.716666);
	PlayerTextDrawAlignment(playerid, RegDraws[15][playerid], 1);
	PlayerTextDrawColor(playerid, RegDraws[15][playerid], -1);
	PlayerTextDrawSetShadow(playerid, RegDraws[15][playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegDraws[15][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegDraws[15][playerid], 255);
	PlayerTextDrawFont(playerid, RegDraws[15][playerid], 2);
	PlayerTextDrawSetProportional(playerid, RegDraws[15][playerid], 1);
	//

	TuningTD[0][playerid] = CreatePlayerTextDraw(playerid, 427.411743, 332.833282, "usebox");
	PlayerTextDrawLetterSize(playerid, TuningTD[0][playerid], 0.000000, 10.419496);
	PlayerTextDrawTextSize(playerid, TuningTD[0][playerid], 191.411651, 0.000000);
	PlayerTextDrawAlignment(playerid, TuningTD[0][playerid], 1);
	PlayerTextDrawColor(playerid, TuningTD[0][playerid], 0);
	PlayerTextDrawUseBox(playerid, TuningTD[0][playerid], true);
	PlayerTextDrawBoxColor(playerid, TuningTD[0][playerid], -1061109505);
	PlayerTextDrawSetShadow(playerid, TuningTD[0][playerid], 0);
	PlayerTextDrawSetOutline(playerid, TuningTD[0][playerid], 0);
	PlayerTextDrawFont(playerid, TuningTD[0][playerid], 0);

	TuningTD[1][playerid] = CreatePlayerTextDraw(playerid, 426.058746, 334.416717, "usebox");
	PlayerTextDrawLetterSize(playerid, TuningTD[1][playerid], 0.000000, 10.090081);
	PlayerTextDrawTextSize(playerid, TuningTD[1][playerid], 192.823425, 0.000000);
	PlayerTextDrawAlignment(playerid, TuningTD[1][playerid], 1);
	PlayerTextDrawColor(playerid, TuningTD[1][playerid], 0);
	PlayerTextDrawUseBox(playerid, TuningTD[1][playerid], true);
	PlayerTextDrawBoxColor(playerid, TuningTD[1][playerid], 174);
	PlayerTextDrawSetShadow(playerid, TuningTD[1][playerid], 0);
	PlayerTextDrawSetOutline(playerid, TuningTD[1][playerid], 0);
	PlayerTextDrawFont(playerid, TuningTD[1][playerid], 0);

	TuningTD[2][playerid] = CreatePlayerTextDraw(playerid, 303.529449, 335.416595, "WHEELS");
	PlayerTextDrawLetterSize(playerid, TuningTD[2][playerid], 0.474940, 1.844999);
	PlayerTextDrawAlignment(playerid, TuningTD[2][playerid], 2);
	PlayerTextDrawColor(playerid, TuningTD[2][playerid], -1);
	PlayerTextDrawSetShadow(playerid, TuningTD[2][playerid], 2);
	PlayerTextDrawSetOutline(playerid, TuningTD[2][playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningTD[2][playerid], 51);
	PlayerTextDrawFont(playerid, TuningTD[2][playerid], 1);
	PlayerTextDrawSetProportional(playerid, TuningTD[2][playerid], 1);

	TuningTD[3][playerid] = CreatePlayerTextDraw(playerid, 303.588287, 356.833404, "Shadow");
	PlayerTextDrawLetterSize(playerid, TuningTD[3][playerid], 0.474940, 1.844999);
	PlayerTextDrawAlignment(playerid, TuningTD[3][playerid], 2);
	PlayerTextDrawColor(playerid, TuningTD[3][playerid], -1);
	PlayerTextDrawSetShadow(playerid, TuningTD[3][playerid], 2);
	PlayerTextDrawSetOutline(playerid, TuningTD[3][playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningTD[3][playerid], 51);
	PlayerTextDrawFont(playerid, TuningTD[3][playerid], 1);
	PlayerTextDrawSetProportional(playerid, TuningTD[3][playerid], 1);

	TuningTD[4][playerid] = CreatePlayerTextDraw(playerid, 229.647140, 334.833312, "LEFT1");
	PlayerTextDrawLetterSize(playerid, TuningTD[4][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, TuningTD[4][playerid], 34.352920, 20.416666);
	PlayerTextDrawAlignment(playerid, TuningTD[4][playerid], 1);
	PlayerTextDrawColor(playerid, TuningTD[4][playerid], -1);
	PlayerTextDrawUseBox(playerid, TuningTD[4][playerid], true);
	PlayerTextDrawBoxColor(playerid, TuningTD[4][playerid], 0);
	PlayerTextDrawSetShadow(playerid, TuningTD[4][playerid], 0);
	PlayerTextDrawSetOutline(playerid, TuningTD[4][playerid], 1);
	PlayerTextDrawFont(playerid, TuningTD[4][playerid], 5);
	PlayerTextDrawBackgroundColor(playerid, TuningTD[4][playerid], 0x00000000);
	PlayerTextDrawSetProportional(playerid, TuningTD[4][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TuningTD[4][playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, TuningTD[4][playerid], 19134);
	PlayerTextDrawSetPreviewRot(playerid, TuningTD[4][playerid], 0.000000, 90.000000, 90.000000, 1.000000);

	TuningTD[5][playerid] = CreatePlayerTextDraw(playerid, 229.235397, 355.666656, "LEFT2");
	PlayerTextDrawLetterSize(playerid, TuningTD[5][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, TuningTD[5][playerid], 34.352920, 20.416666);
	PlayerTextDrawAlignment(playerid, TuningTD[5][playerid], 1);
	PlayerTextDrawColor(playerid, TuningTD[5][playerid], -1);
	PlayerTextDrawUseBox(playerid, TuningTD[5][playerid], true);
	PlayerTextDrawBoxColor(playerid, TuningTD[5][playerid], 0);
	PlayerTextDrawSetShadow(playerid, TuningTD[5][playerid], 0);
	PlayerTextDrawSetOutline(playerid, TuningTD[5][playerid], 1);
	PlayerTextDrawFont(playerid, TuningTD[5][playerid], 5);
	PlayerTextDrawBackgroundColor(playerid, TuningTD[5][playerid], 0x00000000);
	PlayerTextDrawSetProportional(playerid, TuningTD[5][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TuningTD[5][playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, TuningTD[5][playerid], 19134);
	PlayerTextDrawSetPreviewRot(playerid, TuningTD[5][playerid], 0.000000, 90.000000, 90.000000, 1.000000);

	TuningTD[6][playerid] = CreatePlayerTextDraw(playerid, 340.823394, 334.499908, "RIGHT1");
	PlayerTextDrawLetterSize(playerid, TuningTD[6][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, TuningTD[6][playerid], 34.352920, 20.416666);
	PlayerTextDrawAlignment(playerid, TuningTD[6][playerid], 1);
	PlayerTextDrawColor(playerid, TuningTD[6][playerid], -1);
	PlayerTextDrawUseBox(playerid, TuningTD[6][playerid], true);
	PlayerTextDrawBoxColor(playerid, TuningTD[6][playerid], 0);
	PlayerTextDrawSetShadow(playerid, TuningTD[6][playerid], 0);
	PlayerTextDrawSetOutline(playerid, TuningTD[6][playerid], 1);
	PlayerTextDrawFont(playerid, TuningTD[6][playerid], 5);
	PlayerTextDrawBackgroundColor(playerid, TuningTD[6][playerid], 0x00000000);
	PlayerTextDrawSetProportional(playerid, TuningTD[6][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TuningTD[6][playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, TuningTD[6][playerid], 19134);
	PlayerTextDrawSetPreviewRot(playerid, TuningTD[6][playerid], 0.000000, 270.000000, 90.000000, 1.000000);

	TuningTD[7][playerid] = CreatePlayerTextDraw(playerid, 340.882232, 355.333374, "RIGHT2");
	PlayerTextDrawLetterSize(playerid, TuningTD[7][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, TuningTD[7][playerid], 34.352920, 20.416666);
	PlayerTextDrawAlignment(playerid, TuningTD[7][playerid], 1);
	PlayerTextDrawColor(playerid, TuningTD[7][playerid], -1);
	PlayerTextDrawUseBox(playerid, TuningTD[7][playerid], true);
	PlayerTextDrawBoxColor(playerid, TuningTD[7][playerid], 0);
	PlayerTextDrawSetShadow(playerid, TuningTD[7][playerid], 0);
	PlayerTextDrawSetOutline(playerid, TuningTD[7][playerid], 1);
	PlayerTextDrawFont(playerid, TuningTD[7][playerid], 5);
	PlayerTextDrawBackgroundColor(playerid, TuningTD[7][playerid], 0x00000000);
	PlayerTextDrawSetProportional(playerid, TuningTD[7][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TuningTD[7][playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, TuningTD[7][playerid], 19134);
	PlayerTextDrawSetPreviewRot(playerid, TuningTD[7][playerid], 0.000000, 270.000000, 90.000000, 1.000000);

	TuningTD[8][playerid] = CreatePlayerTextDraw(playerid, 201.882385, 406.583404, "BUY");
	PlayerTextDrawLetterSize(playerid, TuningTD[8][playerid], 0.427882, 2.142500);
	PlayerTextDrawAlignment(playerid, TuningTD[8][playerid], 1);
	PlayerTextDrawColor(playerid, TuningTD[8][playerid], -1);
	PlayerTextDrawSetShadow(playerid, TuningTD[8][playerid], 0);
	PlayerTextDrawSetOutline(playerid, TuningTD[8][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, TuningTD[8][playerid], 51);
	PlayerTextDrawFont(playerid, TuningTD[8][playerid], 2);
	PlayerTextDrawSetProportional(playerid, TuningTD[8][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TuningTD[8][playerid], true);

	TuningTD[9][playerid] = CreatePlayerTextDraw(playerid, 272.058227, 406.416717, "APPLY");
	PlayerTextDrawLetterSize(playerid, TuningTD[9][playerid], 0.427882, 2.142500);
	PlayerTextDrawAlignment(playerid, TuningTD[9][playerid], 1);
	PlayerTextDrawColor(playerid, TuningTD[9][playerid], -1);
	PlayerTextDrawSetShadow(playerid, TuningTD[9][playerid], 0);
	PlayerTextDrawSetOutline(playerid, TuningTD[9][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, TuningTD[9][playerid], 51);
	PlayerTextDrawFont(playerid, TuningTD[9][playerid], 2);
	PlayerTextDrawSetProportional(playerid, TuningTD[9][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TuningTD[9][playerid], true);

	TuningTD[10][playerid] = CreatePlayerTextDraw(playerid, 356.352447, 406.249938, "CANCEL");
	PlayerTextDrawLetterSize(playerid, TuningTD[10][playerid], 0.427882, 2.142500);
	PlayerTextDrawAlignment(playerid, TuningTD[10][playerid], 1);
	PlayerTextDrawColor(playerid, TuningTD[10][playerid], -1);
	PlayerTextDrawSetShadow(playerid, TuningTD[10][playerid], 0);
	PlayerTextDrawSetOutline(playerid, TuningTD[10][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, TuningTD[10][playerid], 51);
	PlayerTextDrawFont(playerid, TuningTD[10][playerid], 2);
	PlayerTextDrawSetProportional(playerid, TuningTD[10][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TuningTD[10][playerid], true);
	//
	AmountDraw[playerid] = TextDrawCreate(500.5, 190.0, "_");
	TextDrawBackgroundColor(AmountDraw[playerid], COLOR_BLACK);
	TextDrawLetterSize(AmountDraw[playerid],0.200000,1.000000);
	TextDrawFont(AmountDraw[playerid], 2);
	TextDrawColor(AmountDraw[playerid], COLOR_BLUE);
	TextDrawSetOutline(AmountDraw[playerid], 1);
	TextDrawSetProportional(AmountDraw[playerid],1);
	TextDrawSetShadow(AmountDraw[playerid],1);

	MinerDraw[playerid] = TextDrawCreate(500.5, 190.0, "_");
	TextDrawBackgroundColor(MinerDraw[playerid], COLOR_BLACK);
	TextDrawLetterSize(MinerDraw[playerid],0.200000,1.000000);
	TextDrawFont(MinerDraw[playerid], 2);
	TextDrawColor(MinerDraw[playerid], COLOR_BLUE);
	TextDrawSetOutline(MinerDraw[playerid], 1);
	TextDrawSetProportional(MinerDraw[playerid],1);
	TextDrawSetShadow(MinerDraw[playerid],1);

	ProcentDraw[playerid] = TextDrawCreate(500.5, 190.0, "_");
	TextDrawBackgroundColor(ProcentDraw[playerid], COLOR_BLACK);
	TextDrawLetterSize(ProcentDraw[playerid],0.200000,1.000000);
	TextDrawFont(ProcentDraw[playerid], 2);
	TextDrawColor(ProcentDraw[playerid], COLOR_BLUE);
	TextDrawSetOutline(ProcentDraw[playerid], 1);
	TextDrawSetProportional(ProcentDraw[playerid],1);
	TextDrawSetShadow(ProcentDraw[playerid],1);

	AmountLDraw[playerid] = TextDrawCreate(500.5, 200.0, "_");
	TextDrawBackgroundColor(AmountLDraw[playerid], COLOR_BLACK);
	TextDrawLetterSize(AmountLDraw[playerid],0.200000,1.000000);
	TextDrawFont(AmountLDraw[playerid], 2);
	TextDrawColor(AmountLDraw[playerid], COLOR_BLUE);
	TextDrawSetOutline(AmountLDraw[playerid], 1);
	TextDrawSetProportional(AmountLDraw[playerid],1);
	TextDrawSetShadow(AmountLDraw[playerid],1);

	GardenDraw[playerid] = TextDrawCreate(500.5, 190.0, "_");
	TextDrawBackgroundColor(GardenDraw[playerid], COLOR_BLACK);
	TextDrawLetterSize(GardenDraw[playerid],0.200000,1.000000);
	TextDrawFont(GardenDraw[playerid], 2);
	TextDrawColor(GardenDraw[playerid], COLOR_BLUE);
	TextDrawSetOutline(GardenDraw[playerid], 1);
	TextDrawSetProportional(GardenDraw[playerid],1);
	TextDrawSetShadow(GardenDraw[playerid],1);
	//Банды
	g_Capture[0][playerid] = TextDrawCreate(640.588195, 210.916656, "usebox");
	TextDrawLetterSize(g_Capture[0][playerid], 0.000000, 5.133005);
	TextDrawTextSize(g_Capture[0][playerid], 477.058837, 0.000000);
	TextDrawAlignment(g_Capture[0][playerid], 1);
	TextDrawColor(g_Capture[0][playerid], 0);
	TextDrawUseBox(g_Capture[0][playerid], true);
	TextDrawBoxColor(g_Capture[0][playerid], -5963635);
	TextDrawSetShadow(g_Capture[0][playerid], 0);
	TextDrawSetOutline(g_Capture[0][playerid], 0);
	TextDrawFont(g_Capture[0][playerid], 1);

	g_Capture[1][playerid] = TextDrawCreate(638.764953, 212.499984, "usebox");
	TextDrawLetterSize(g_Capture[1][playerid], 0.000000, 4.756540);
	TextDrawTextSize(g_Capture[1][playerid], 478.470581, 0.000000);
	TextDrawAlignment(g_Capture[1][playerid], 1);
	TextDrawColor(g_Capture[1][playerid], 0);
	TextDrawUseBox(g_Capture[1][playerid], true);
	TextDrawBoxColor(g_Capture[1][playerid], -85);
	TextDrawSetShadow(g_Capture[1][playerid], 0);
	TextDrawSetOutline(g_Capture[1][playerid], 0);
	TextDrawFont(g_Capture[1][playerid], 0);

	g_Capture[2][playerid] = TextDrawCreate(502.588378, 212.916717, "_");
	TextDrawLetterSize(g_Capture[2][playerid], 0.257058, 1.588334);
	TextDrawAlignment(g_Capture[2][playerid], 1);
	TextDrawColor(g_Capture[2][playerid], -5963521);
	TextDrawSetShadow(g_Capture[2][playerid], 0);
	TextDrawSetOutline(g_Capture[2][playerid], 1);
	TextDrawBackgroundColor(g_Capture[2][playerid], 255);
	TextDrawFont(g_Capture[2][playerid], 2);
	TextDrawSetProportional(g_Capture[2][playerid], 1);

	g_Capture[3][playerid] = TextDrawCreate(478.588256, 239.166610, "zahita");
	TextDrawLetterSize(g_Capture[3][playerid], 0.449999, 1.600000);
	TextDrawTextSize(g_Capture[3][playerid], 24.000000, 20.999998);
	TextDrawAlignment(g_Capture[3][playerid], 1);
	TextDrawColor(g_Capture[3][playerid], -1);
	TextDrawUseBox(g_Capture[3][playerid], true);
	TextDrawBackgroundColor(g_Capture[3][playerid], 0x00000000);
	TextDrawBoxColor(g_Capture[3][playerid], 0);
	TextDrawSetShadow(g_Capture[3][playerid], 0);
	TextDrawSetOutline(g_Capture[3][playerid], 1);
	TextDrawFont(g_Capture[3][playerid], 5);
	TextDrawSetProportional(g_Capture[3][playerid], 1);
	TextDrawSetPreviewModel(g_Capture[3][playerid], 19134);
	TextDrawSetPreviewRot(g_Capture[3][playerid], 0.000000, 0.000000, 90.000000, 1.000000);

	g_Capture[4][playerid] = TextDrawCreate(478.176513, 225.583297, "napad");
	TextDrawLetterSize(g_Capture[4][playerid], 0.449999, 1.600000);
	TextDrawTextSize(g_Capture[4][playerid], 24.470588, 20.999998);
	TextDrawAlignment(g_Capture[4][playerid], 1);
	TextDrawColor(g_Capture[4][playerid], -16776961);
	TextDrawUseBox(g_Capture[4][playerid], true);
	TextDrawBackgroundColor(g_Capture[4][playerid], 0x00000000);
	TextDrawBoxColor(g_Capture[4][playerid], 0);
	TextDrawSetShadow(g_Capture[4][playerid], 0);
	TextDrawSetOutline(g_Capture[4][playerid], 1);
	TextDrawFont(g_Capture[4][playerid], 5);
	TextDrawSetProportional(g_Capture[4][playerid], 1);
	TextDrawSetPreviewModel(g_Capture[4][playerid], 19134);
	TextDrawSetPreviewRot(g_Capture[4][playerid], 0.000000, 180.000000, 90.000000, 1.000000);

	g_Capture[5][playerid] = TextDrawCreate(480.941070, 212.916732, "ld_grav:timer");
	TextDrawLetterSize(g_Capture[5][playerid], 0.000000, 0.000000);
	TextDrawTextSize(g_Capture[5][playerid], 18.352943, 14.583317);
	TextDrawAlignment(g_Capture[5][playerid], 1);
	TextDrawColor(g_Capture[5][playerid], -1);
	TextDrawSetShadow(g_Capture[5][playerid], 0);
	TextDrawSetOutline(g_Capture[5][playerid], 0);
	TextDrawFont(g_Capture[5][playerid], 4);
	//FishDraw
	FishDraw[playerid] = TextDrawCreate(500.5, 190.0, "_");
	TextDrawBackgroundColor(FishDraw[playerid], COLOR_BLACK);
	TextDrawLetterSize(FishDraw[playerid],0.200000,1.000000);
	TextDrawFont(FishDraw[playerid], 2);
	TextDrawColor(FishDraw[playerid], COLOR_BLUE);
	TextDrawSetOutline(FishDraw[playerid], 1);
	TextDrawSetProportional(FishDraw[playerid],1);
	TextDrawSetShadow(FishDraw[playerid],1);

	AnimDraw[playerid] = TextDrawCreate(34.0, 430.0, "_");
	TextDrawBackgroundColor(AnimDraw[playerid], COLOR_BLACK);
	TextDrawLetterSize(AnimDraw[playerid],0.200000,1.000000);
	TextDrawFont(AnimDraw[playerid], 2);
	TextDrawColor(AnimDraw[playerid], COLOR_REDD);
	TextDrawSetOutline(AnimDraw[playerid], 1);
	TextDrawSetProportional(AnimDraw[playerid],1);
	TextDrawSetShadow(AnimDraw[playerid],1);
	//AutoSalon
	AutoSalonTD[0][playerid] = CreatePlayerTextDraw(playerid, 641.529418, 250.583328, "usebox");
	PlayerTextDrawLetterSize(playerid, AutoSalonTD[0][playerid], 0.000000, 2.016664);
	PlayerTextDrawTextSize(playerid, AutoSalonTD[0][playerid], 470.941162, 0.000000);
	PlayerTextDrawAlignment(playerid, AutoSalonTD[0][playerid], 1);
	PlayerTextDrawColor(playerid, AutoSalonTD[0][playerid], 0);
	PlayerTextDrawUseBox(playerid, AutoSalonTD[0][playerid], true);
	PlayerTextDrawBoxColor(playerid, AutoSalonTD[0][playerid], 6029171);
	PlayerTextDrawSetShadow(playerid, AutoSalonTD[0][playerid], 0);
	PlayerTextDrawSetOutline(playerid, AutoSalonTD[0][playerid], 0);
	PlayerTextDrawFont(playerid, AutoSalonTD[0][playerid], 0);

	AutoSalonTD[1][playerid] = CreatePlayerTextDraw(playerid, 463.058959, 121.333290, "left");
	PlayerTextDrawLetterSize(playerid, AutoSalonTD[1][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, AutoSalonTD[1][playerid], 52.235301, 36.166667);
	PlayerTextDrawAlignment(playerid, AutoSalonTD[1][playerid], 1);
	PlayerTextDrawColor(playerid, AutoSalonTD[1][playerid], -2139094785);
	PlayerTextDrawUseBox(playerid, AutoSalonTD[1][playerid], true);
	PlayerTextDrawBoxColor(playerid, AutoSalonTD[1][playerid], 0);
	PlayerTextDrawSetShadow(playerid, AutoSalonTD[1][playerid], 0);
	PlayerTextDrawSetOutline(playerid, AutoSalonTD[1][playerid], 0);
	PlayerTextDrawFont(playerid, AutoSalonTD[1][playerid], 5);
	PlayerTextDrawSetProportional(playerid, AutoSalonTD[1][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, AutoSalonTD[1][playerid], true);
	PlayerTextDrawBackgroundColor(playerid, AutoSalonTD[1][playerid], 0x00000000);
	PlayerTextDrawSetPreviewModel(playerid, AutoSalonTD[1][playerid], 19134);
	PlayerTextDrawSetPreviewRot(playerid, AutoSalonTD[1][playerid], 0.000000, 90.000000, 90.000000, 1.000000);

	AutoSalonTD[2][playerid] = CreatePlayerTextDraw(playerid, 596.764526, 121.333290, "right");
	PlayerTextDrawLetterSize(playerid, AutoSalonTD[2][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, AutoSalonTD[2][playerid], 52.235301, 36.166667);
	PlayerTextDrawAlignment(playerid, AutoSalonTD[2][playerid], 1);
	PlayerTextDrawColor(playerid, AutoSalonTD[2][playerid], -2139094785);
	PlayerTextDrawUseBox(playerid, AutoSalonTD[2][playerid], true);
	PlayerTextDrawBoxColor(playerid, AutoSalonTD[2][playerid], 0);
	PlayerTextDrawSetShadow(playerid, AutoSalonTD[2][playerid], 0);
	PlayerTextDrawSetOutline(playerid, AutoSalonTD[2][playerid], 0);
	PlayerTextDrawFont(playerid, AutoSalonTD[2][playerid], 5);
	PlayerTextDrawSetProportional(playerid, AutoSalonTD[2][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, AutoSalonTD[2][playerid], true);
	PlayerTextDrawBackgroundColor(playerid, AutoSalonTD[2][playerid], 0x00000000);
	PlayerTextDrawSetPreviewModel(playerid, AutoSalonTD[2][playerid], 19134);
	PlayerTextDrawSetPreviewRot(playerid, AutoSalonTD[2][playerid], 0.000000, 270.000000, 90.000000, 1.000000);

	AutoSalonTD[3][playerid] = CreatePlayerTextDraw(playerid, 481.823425, 129.583328, "usebox");
	PlayerTextDrawLetterSize(playerid, AutoSalonTD[3][playerid], 0.000000, 15.434645);
	PlayerTextDrawTextSize(playerid, AutoSalonTD[3][playerid], 470.941040, 0.000000);
	PlayerTextDrawAlignment(playerid, AutoSalonTD[3][playerid], 1);
	PlayerTextDrawColor(playerid, AutoSalonTD[3][playerid], 0);
	PlayerTextDrawUseBox(playerid, AutoSalonTD[3][playerid], true);
	PlayerTextDrawBoxColor(playerid, AutoSalonTD[3][playerid], 643427472);
	PlayerTextDrawSetShadow(playerid, AutoSalonTD[3][playerid], 0);
	PlayerTextDrawSetOutline(playerid, AutoSalonTD[3][playerid], 0);
	PlayerTextDrawFont(playerid, AutoSalonTD[3][playerid], 0);

	AutoSalonTD[4][playerid] = CreatePlayerTextDraw(playerid, 558.117187, 130.083267, "Sunrice");
	PlayerTextDrawLetterSize(playerid, AutoSalonTD[4][playerid], 0.364352, 2.375833);
	PlayerTextDrawTextSize(playerid, AutoSalonTD[4][playerid], 4.705882, 165.666687);
	PlayerTextDrawAlignment(playerid, AutoSalonTD[4][playerid], 2);
	PlayerTextDrawColor(playerid, AutoSalonTD[4][playerid], -1);
	PlayerTextDrawUseBox(playerid, AutoSalonTD[4][playerid], true);
	PlayerTextDrawBoxColor(playerid, AutoSalonTD[4][playerid], 6029171);
	PlayerTextDrawSetShadow(playerid, AutoSalonTD[4][playerid], 0);
	PlayerTextDrawSetOutline(playerid, AutoSalonTD[4][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, AutoSalonTD[4][playerid], 41215);
	PlayerTextDrawFont(playerid, AutoSalonTD[4][playerid], 2);
	PlayerTextDrawSetProportional(playerid, AutoSalonTD[4][playerid], 1);

	AutoSalonTD[5][playerid] = CreatePlayerTextDraw(playerid, 558.117492, 161.000061, "285781$");
	PlayerTextDrawLetterSize(playerid, AutoSalonTD[5][playerid], 0.450941, 2.270832);
	PlayerTextDrawTextSize(playerid, AutoSalonTD[5][playerid], 8.000000, 167.416610);
	PlayerTextDrawAlignment(playerid, AutoSalonTD[5][playerid], 2);
	PlayerTextDrawColor(playerid, AutoSalonTD[5][playerid], 8388863);
	PlayerTextDrawUseBox(playerid, AutoSalonTD[5][playerid], true);
	PlayerTextDrawBoxColor(playerid, AutoSalonTD[5][playerid], 6029171);
	PlayerTextDrawSetShadow(playerid, AutoSalonTD[5][playerid], 0);
	PlayerTextDrawSetOutline(playerid, AutoSalonTD[5][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, AutoSalonTD[5][playerid], 41215);
	PlayerTextDrawFont(playerid, AutoSalonTD[5][playerid], 2);
	PlayerTextDrawSetProportional(playerid, AutoSalonTD[5][playerid], 1);

	AutoSalonTD[6][playerid] = CreatePlayerTextDraw(playerid, 559.117492, 191.750045, "Fuel: ~g~130L");
	PlayerTextDrawLetterSize(playerid, AutoSalonTD[6][playerid], 0.450470, 2.194998);
	PlayerTextDrawTextSize(playerid, AutoSalonTD[6][playerid], -0.941176, 169.166641);
	PlayerTextDrawAlignment(playerid, AutoSalonTD[6][playerid], 2);
	PlayerTextDrawColor(playerid, AutoSalonTD[6][playerid], -1523963137);
	PlayerTextDrawUseBox(playerid, AutoSalonTD[6][playerid], true);
	PlayerTextDrawBoxColor(playerid, AutoSalonTD[6][playerid], 6029171);
	PlayerTextDrawSetShadow(playerid, AutoSalonTD[6][playerid], 0);
	PlayerTextDrawSetOutline(playerid, AutoSalonTD[6][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, AutoSalonTD[6][playerid], 41215);
	PlayerTextDrawFont(playerid, AutoSalonTD[6][playerid], 2);
	PlayerTextDrawSetProportional(playerid, AutoSalonTD[6][playerid], 1);

	AutoSalonTD[7][playerid] = CreatePlayerTextDraw(playerid, 523.764648, 228.083297, "Buymod");
	PlayerTextDrawLetterSize(playerid, AutoSalonTD[7][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, AutoSalonTD[7][playerid], 73.882354, 69.416671);
	PlayerTextDrawAlignment(playerid, AutoSalonTD[7][playerid], 1);
	PlayerTextDrawColor(playerid, AutoSalonTD[7][playerid], 7858687);
	PlayerTextDrawUseBox(playerid, AutoSalonTD[7][playerid], true);
	PlayerTextDrawBoxColor(playerid, AutoSalonTD[7][playerid], 0);
	PlayerTextDrawSetShadow(playerid, AutoSalonTD[7][playerid], 0);
	PlayerTextDrawSetOutline(playerid, AutoSalonTD[7][playerid], 1);
	PlayerTextDrawFont(playerid, AutoSalonTD[7][playerid], 5);
	PlayerTextDrawSetProportional(playerid, AutoSalonTD[7][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, AutoSalonTD[7][playerid], true);
	PlayerTextDrawBackgroundColor(playerid, AutoSalonTD[7][playerid], 0x00000000);
	PlayerTextDrawSetPreviewModel(playerid, AutoSalonTD[7][playerid], 19131);
	PlayerTextDrawSetPreviewRot(playerid, AutoSalonTD[7][playerid], 0.000000, 90.000000, 90.000000, 1.000000);

	AutoSalonTD[8][playerid] = CreatePlayerTextDraw(playerid, 562.823364, 255.499984, "Buy");
	PlayerTextDrawLetterSize(playerid, AutoSalonTD[8][playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, AutoSalonTD[8][playerid], 2);
	PlayerTextDrawColor(playerid, AutoSalonTD[8][playerid], -1);
	PlayerTextDrawSetShadow(playerid, AutoSalonTD[8][playerid], 0);
	PlayerTextDrawSetOutline(playerid, AutoSalonTD[8][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, AutoSalonTD[8][playerid], 41215);
	PlayerTextDrawFont(playerid, AutoSalonTD[8][playerid], 2);
	PlayerTextDrawSetProportional(playerid, AutoSalonTD[8][playerid], 1);

	AutoSalonTD[9][playerid] = CreatePlayerTextDraw(playerid, 559.176330, 221.333297, "~g~select color");
	PlayerTextDrawLetterSize(playerid, AutoSalonTD[9][playerid], 0.429294, 2.241666);
	PlayerTextDrawTextSize(playerid, AutoSalonTD[9][playerid], 21.647066, 169.166671);
	PlayerTextDrawAlignment(playerid, AutoSalonTD[9][playerid], 2);
	PlayerTextDrawColor(playerid, AutoSalonTD[9][playerid], -1523963137);
	PlayerTextDrawUseBox(playerid, AutoSalonTD[9][playerid], true);
	PlayerTextDrawBoxColor(playerid, AutoSalonTD[9][playerid], 6029170);
	PlayerTextDrawSetShadow(playerid, AutoSalonTD[9][playerid], 0);
	PlayerTextDrawSetOutline(playerid, AutoSalonTD[9][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, AutoSalonTD[9][playerid], 41215);
	PlayerTextDrawFont(playerid, AutoSalonTD[9][playerid], 2);
	PlayerTextDrawSetProportional(playerid, AutoSalonTD[9][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, AutoSalonTD[9][playerid], true);
	//FishRod
	FishTD[0][playerid] = CreatePlayerTextDraw(playerid, 469.115875, 108.249992, "usebox");
	PlayerTextDrawLetterSize(playerid, FishTD[0][playerid], 0.000000, 16.548841);
	PlayerTextDrawTextSize(playerid, FishTD[0][playerid], 167.136154, 0.000000);
	PlayerTextDrawAlignment(playerid, FishTD[0][playerid], 1);
	PlayerTextDrawColor(playerid, FishTD[0][playerid], 0);
	PlayerTextDrawUseBox(playerid, FishTD[0][playerid], true);
	PlayerTextDrawBoxColor(playerid, FishTD[0][playerid], -201);
	PlayerTextDrawSetShadow(playerid, FishTD[0][playerid], 0);
	PlayerTextDrawSetOutline(playerid, FishTD[0][playerid], 0);
	PlayerTextDrawFont(playerid, FishTD[0][playerid], 0);

	FishTD[1][playerid] = CreatePlayerTextDraw(playerid, 318.125946, 105.583351, "SPINING BUY");
	PlayerTextDrawLetterSize(playerid, FishTD[1][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, FishTD[1][playerid], -29.048316, 294.583251);
	PlayerTextDrawAlignment(playerid, FishTD[1][playerid], 2);
	PlayerTextDrawColor(playerid, FishTD[1][playerid], -2139062017);
	PlayerTextDrawUseBox(playerid, FishTD[1][playerid], true);
	PlayerTextDrawBoxColor(playerid, FishTD[1][playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, FishTD[1][playerid], 0);
	PlayerTextDrawSetOutline(playerid, FishTD[1][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, FishTD[1][playerid], -1);
	PlayerTextDrawFont(playerid, FishTD[1][playerid], 2);
	PlayerTextDrawSetProportional(playerid, FishTD[1][playerid], 1);

	FishTD[2][playerid] = CreatePlayerTextDraw(playerid, 453.528656, 104.416664, "x");
	PlayerTextDrawLetterSize(playerid, FishTD[2][playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, FishTD[2][playerid], 1);
	PlayerTextDrawColor(playerid, FishTD[2][playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, FishTD[2][playerid], 0);
	PlayerTextDrawSetOutline(playerid, FishTD[2][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, FishTD[2][playerid], -1);
	PlayerTextDrawFont(playerid, FishTD[2][playerid], 2);
	PlayerTextDrawSetProportional(playerid, FishTD[2][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, FishTD[2][playerid], true);

	FishTD[3][playerid] = CreatePlayerTextDraw(playerid, 177.569534, 125.416679, "1~n~~n~2~n~~n~3");
	PlayerTextDrawLetterSize(playerid, FishTD[3][playerid], 0.495915, 2.930000);
	PlayerTextDrawTextSize(playerid, FishTD[3][playerid], -0.468521, 13.999999);
	PlayerTextDrawAlignment(playerid, FishTD[3][playerid], 2);
	PlayerTextDrawColor(playerid, FishTD[3][playerid], -2139062017);
	PlayerTextDrawUseBox(playerid, FishTD[3][playerid], true);
	PlayerTextDrawBoxColor(playerid, FishTD[3][playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, FishTD[3][playerid], 0);
	PlayerTextDrawSetOutline(playerid, FishTD[3][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, FishTD[3][playerid], -1);
	PlayerTextDrawFont(playerid, FishTD[3][playerid], 2);
	PlayerTextDrawSetProportional(playerid, FishTD[3][playerid], 1);

	FishTD[4][playerid] = CreatePlayerTextDraw(playerid, 69.809692, 120.166664, "Spining1");
	PlayerTextDrawLetterSize(playerid, FishTD[4][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, FishTD[4][playerid], 312.035400, 139.416687);
	PlayerTextDrawAlignment(playerid, FishTD[4][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, FishTD[4][playerid], 0x00000000);
	PlayerTextDrawColor(playerid, FishTD[4][playerid], -5963521);
	PlayerTextDrawUseBox(playerid, FishTD[4][playerid], true);
	PlayerTextDrawBoxColor(playerid, FishTD[4][playerid], 0);
	PlayerTextDrawSetShadow(playerid, FishTD[4][playerid], 0);
	PlayerTextDrawSetOutline(playerid, FishTD[4][playerid], 1);
	PlayerTextDrawFont(playerid, FishTD[4][playerid], 5);
	PlayerTextDrawSetProportional(playerid, FishTD[4][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, FishTD[4][playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, FishTD[4][playerid], 18632);
	PlayerTextDrawSetPreviewRot(playerid, FishTD[4][playerid], 75.000000, 50.000000, 90.000000, 1.000000);

	FishTD[5][playerid] = CreatePlayerTextDraw(playerid, 69.872650, 170.749969, "Spining2");
	PlayerTextDrawLetterSize(playerid, FishTD[5][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, FishTD[5][playerid], 312.035400, 139.416687);
	PlayerTextDrawAlignment(playerid, FishTD[5][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, FishTD[5][playerid], 0x00000000);
	PlayerTextDrawColor(playerid, FishTD[5][playerid], -5963521);
	PlayerTextDrawUseBox(playerid, FishTD[5][playerid], true);
	PlayerTextDrawBoxColor(playerid, FishTD[5][playerid], 0);
	PlayerTextDrawSetShadow(playerid, FishTD[5][playerid], 0);
	PlayerTextDrawSetOutline(playerid, FishTD[5][playerid], 1);
	PlayerTextDrawFont(playerid, FishTD[5][playerid], 5);
	PlayerTextDrawSetProportional(playerid, FishTD[5][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, FishTD[5][playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, FishTD[5][playerid], 18632);
	PlayerTextDrawSetPreviewRot(playerid, FishTD[5][playerid], 75.000000, 50.000000, 90.000000, 1.000000);

	FishTD[6][playerid] = CreatePlayerTextDraw(playerid, 68.998565, 223.666641, "Spining3");
	PlayerTextDrawLetterSize(playerid, FishTD[6][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, FishTD[6][playerid], 312.035400, 139.416687);
	PlayerTextDrawAlignment(playerid, FishTD[6][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, FishTD[6][playerid], 0x00000000);
	PlayerTextDrawColor(playerid, FishTD[6][playerid], -5963521);
	PlayerTextDrawUseBox(playerid, FishTD[6][playerid], true);
	PlayerTextDrawBoxColor(playerid, FishTD[6][playerid], 0);
	PlayerTextDrawSetShadow(playerid, FishTD[6][playerid], 0);
	PlayerTextDrawSetOutline(playerid, FishTD[6][playerid], 1);
	PlayerTextDrawFont(playerid, FishTD[6][playerid], 5);
	PlayerTextDrawSetProportional(playerid, FishTD[6][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, FishTD[6][playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, FishTD[6][playerid], 18632);
	PlayerTextDrawSetPreviewRot(playerid, FishTD[6][playerid], 75.000000, 50.000000, 90.000000, 1.000000);

	FishTD[7][playerid] = CreatePlayerTextDraw(playerid, 441.815917, 125.416748, "BUY");
	PlayerTextDrawLetterSize(playerid, FishTD[7][playerid], 0.531522, 2.632499);//0.531522
	PlayerTextDrawTextSize(playerid, FishTD[7][playerid], 14.655929, 47.250000);
	PlayerTextDrawAlignment(playerid, FishTD[7][playerid], 2);
	PlayerTextDrawColor(playerid, FishTD[7][playerid], -2139062017);
	PlayerTextDrawUseBox(playerid, FishTD[7][playerid], true);
	PlayerTextDrawBoxColor(playerid, FishTD[7][playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, FishTD[7][playerid], 0);
	PlayerTextDrawSetOutline(playerid, FishTD[7][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, FishTD[7][playerid], -1);
	PlayerTextDrawFont(playerid, FishTD[7][playerid], 2);
	PlayerTextDrawSetProportional(playerid, FishTD[7][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, FishTD[7][playerid], true);

	FishTD[8][playerid] = CreatePlayerTextDraw(playerid, 441.878906, 177.749984, "BUY");
	PlayerTextDrawLetterSize(playerid, FishTD[8][playerid], 0.531522, 2.632499);
	PlayerTextDrawTextSize(playerid, FishTD[8][playerid], 14.655929, 47.250000);
	PlayerTextDrawAlignment(playerid, FishTD[8][playerid], 2);
	PlayerTextDrawColor(playerid, FishTD[8][playerid], -2139062017);
	PlayerTextDrawUseBox(playerid, FishTD[8][playerid], true);
	PlayerTextDrawBoxColor(playerid, FishTD[8][playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, FishTD[8][playerid], 0);
	PlayerTextDrawSetOutline(playerid, FishTD[8][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, FishTD[8][playerid], -1);
	PlayerTextDrawFont(playerid, FishTD[8][playerid], 2);
	PlayerTextDrawSetProportional(playerid, FishTD[8][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, FishTD[8][playerid], true);

	FishTD[9][playerid] = CreatePlayerTextDraw(playerid, 441.641925, 233.583389, "BUY");
	PlayerTextDrawLetterSize(playerid, FishTD[9][playerid], 0.531522, 2.632499);
	PlayerTextDrawTextSize(playerid, FishTD[9][playerid], 14.155929, 47.250000);
	PlayerTextDrawAlignment(playerid, FishTD[9][playerid], 2);
	PlayerTextDrawColor(playerid, FishTD[9][playerid], -2139062017);
	PlayerTextDrawUseBox(playerid, FishTD[9][playerid], true);
	PlayerTextDrawBoxColor(playerid, FishTD[9][playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, FishTD[9][playerid], 0);
	PlayerTextDrawSetOutline(playerid, FishTD[9][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, FishTD[9][playerid], -1);
	PlayerTextDrawFont(playerid, FishTD[9][playerid], 2);
	PlayerTextDrawSetProportional(playerid, FishTD[9][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, FishTD[9][playerid], true);
	//Спидометр
	SpeedDraw[0][playerid] = CreatePlayerTextDraw(playerid, 456.588256, 439.583312, "usebox");
	PlayerTextDrawLetterSize(playerid, SpeedDraw[0][playerid], 0.000000, -10.362957);
	PlayerTextDrawTextSize(playerid, SpeedDraw[0][playerid], 630.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, SpeedDraw[0][playerid], 1);
	PlayerTextDrawColor(playerid, SpeedDraw[0][playerid], 0);
	PlayerTextDrawUseBox(playerid, SpeedDraw[0][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpeedDraw[0][playerid], -5963690);
	PlayerTextDrawSetShadow(playerid, SpeedDraw[0][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpeedDraw[0][playerid], 0);
	PlayerTextDrawFont(playerid, SpeedDraw[0][playerid], 0);
	PlayerTextDrawSetPreviewModel(playerid, SpeedDraw[0][playerid], 185);
	PlayerTextDrawSetPreviewRot(playerid, SpeedDraw[0][playerid], 0.000000, 0.000000, 0.000000, 1.000000);

	SpeedDraw[1][playerid] = CreatePlayerTextDraw(playerid, 632.117675, 352.666687, "usebox");
	PlayerTextDrawLetterSize(playerid, SpeedDraw[1][playerid], 0.000000, 8.951848);
	PlayerTextDrawTextSize(playerid, SpeedDraw[1][playerid], 519.882385, 0.000000);
	PlayerTextDrawAlignment(playerid, SpeedDraw[1][playerid], 1);
	PlayerTextDrawColor(playerid, SpeedDraw[1][playerid], 0);
	PlayerTextDrawUseBox(playerid, SpeedDraw[1][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpeedDraw[1][playerid], 255);
	PlayerTextDrawSetShadow(playerid, SpeedDraw[1][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpeedDraw[1][playerid], 0);
	PlayerTextDrawFont(playerid, SpeedDraw[1][playerid], 0);

	SpeedDraw[2][playerid] = CreatePlayerTextDraw(playerid, 456.470642, 350.583343, "model");
	PlayerTextDrawLetterSize(playerid, SpeedDraw[2][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, SpeedDraw[2][playerid], 64.470603, 85.166656);
	PlayerTextDrawAlignment(playerid, SpeedDraw[2][playerid], 1);
	PlayerTextDrawColor(playerid, SpeedDraw[2][playerid], -1);
	PlayerTextDrawUseBox(playerid, SpeedDraw[2][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpeedDraw[2][playerid], 0);
	PlayerTextDrawSetShadow(playerid, SpeedDraw[2][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpeedDraw[2][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpeedDraw[2][playerid], 255);
	PlayerTextDrawFont(playerid, SpeedDraw[2][playerid], 5);
	PlayerTextDrawSetProportional(playerid, SpeedDraw[2][playerid], 1);
	PlayerTextDrawSetPreviewModel(playerid, SpeedDraw[2][playerid], 411);
	PlayerTextDrawSetPreviewRot(playerid, SpeedDraw[2][playerid], -10.000000, 0.000000, -20.000000, 1.050000);

	SpeedDraw[3][playerid] = CreatePlayerTextDraw(playerid, 488.588073, 421.999908, "_");
	PlayerTextDrawLetterSize(playerid, SpeedDraw[3][playerid], 0.259411, 1.075000);
	PlayerTextDrawTextSize(playerid, SpeedDraw[3][playerid], 24.470598, 58.916687);
	PlayerTextDrawAlignment(playerid, SpeedDraw[3][playerid], 2);
	PlayerTextDrawColor(playerid, SpeedDraw[3][playerid], -1);
	PlayerTextDrawUseBox(playerid, SpeedDraw[3][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpeedDraw[3][playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, SpeedDraw[3][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpeedDraw[3][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, SpeedDraw[3][playerid], 255);
	PlayerTextDrawFont(playerid, SpeedDraw[3][playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpeedDraw[3][playerid], 1);

	SpeedDraw[4][playerid] = CreatePlayerTextDraw(playerid, 488.470458, 354.083343, "_");
	PlayerTextDrawLetterSize(playerid, SpeedDraw[4][playerid], 0.424117, 1.290832);
	PlayerTextDrawTextSize(playerid, SpeedDraw[4][playerid], 20.235294, 58.916645);
	PlayerTextDrawAlignment(playerid, SpeedDraw[4][playerid], 2);
	PlayerTextDrawColor(playerid, SpeedDraw[4][playerid], -1);
	PlayerTextDrawUseBox(playerid, SpeedDraw[4][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpeedDraw[4][playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, SpeedDraw[4][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpeedDraw[4][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, SpeedDraw[4][playerid], 255);
	PlayerTextDrawFont(playerid, SpeedDraw[4][playerid], 2);
	PlayerTextDrawSetProportional(playerid, SpeedDraw[4][playerid], 1);

	SpeedDraw[5][playerid] = CreatePlayerTextDraw(playerid, 524.705871, 354.083282, "_");
	PlayerTextDrawLetterSize(playerid, SpeedDraw[5][playerid], 0.430705, 1.716667);
	PlayerTextDrawTextSize(playerid, SpeedDraw[5][playerid], 627.293945, 186.083328);
	PlayerTextDrawAlignment(playerid, SpeedDraw[5][playerid], 1);
	PlayerTextDrawColor(playerid, SpeedDraw[5][playerid], -1);
	PlayerTextDrawUseBox(playerid, SpeedDraw[5][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpeedDraw[5][playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, SpeedDraw[5][playerid], 1);
	PlayerTextDrawSetOutline(playerid, SpeedDraw[5][playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, SpeedDraw[5][playerid], 255);
	PlayerTextDrawFont(playerid, SpeedDraw[5][playerid], 2);
	PlayerTextDrawSetProportional(playerid, SpeedDraw[5][playerid], 1);

	SpeedDraw[6][playerid] = CreatePlayerTextDraw(playerid, 575.999816, 406.583282, "_");
	PlayerTextDrawLetterSize(playerid, SpeedDraw[6][playerid], 0.333764, 1.413333);
	PlayerTextDrawTextSize(playerid, SpeedDraw[6][playerid], 110.117675, 103.249992);
	PlayerTextDrawAlignment(playerid, SpeedDraw[6][playerid], 2);
	PlayerTextDrawColor(playerid, SpeedDraw[6][playerid], -1);
	PlayerTextDrawUseBox(playerid, SpeedDraw[6][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpeedDraw[6][playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, SpeedDraw[6][playerid], 1);
	PlayerTextDrawSetOutline(playerid, SpeedDraw[6][playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, SpeedDraw[6][playerid], 255);
	PlayerTextDrawFont(playerid, SpeedDraw[6][playerid], 2);
	PlayerTextDrawSetProportional(playerid, SpeedDraw[6][playerid], 1);
	//
	SkinCost[playerid] = TextDrawCreate(490.352783, 136.500000, "_");
	TextDrawLetterSize(SkinCost[playerid], 0.391176, 2.241666);
	TextDrawTextSize(SkinCost[playerid], 636.234985, 111.416664);
	TextDrawAlignment(SkinCost[playerid], 1);
	TextDrawColor(SkinCost[playerid], -570425345);
	TextDrawUseBox(SkinCost[playerid], true);
	TextDrawBoxColor(SkinCost[playerid], 849);
	TextDrawSetShadow(SkinCost[playerid], 2);
	TextDrawSetOutline(SkinCost[playerid], 0);
	TextDrawBackgroundColor(SkinCost[playerid], 255);
	TextDrawFont(SkinCost[playerid], 2);
	TextDrawSetProportional(SkinCost[playerid], 1);

	SpecTD[0][playerid] = CreatePlayerTextDraw(playerid, -0.468376, 317.916625, "PANEL");
	PlayerTextDrawLetterSize(playerid, SpecTD[0][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, SpecTD[0][playerid], 642.811218, 134.749908);
	PlayerTextDrawAlignment(playerid, SpecTD[0][playerid], 1);
	PlayerTextDrawColor(playerid, SpecTD[0][playerid], -2147483536);
	PlayerTextDrawUseBox(playerid, SpecTD[0][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[0][playerid], 0);
	PlayerTextDrawSetShadow(playerid, SpecTD[0][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[0][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[0][playerid], 51);
	PlayerTextDrawFont(playerid, SpecTD[0][playerid], 5);
	PlayerTextDrawSetProportional(playerid, SpecTD[0][playerid], 1);
	PlayerTextDrawSetPreviewModel(playerid, SpecTD[0][playerid], 19131);
	PlayerTextDrawSetPreviewRot(playerid, SpecTD[0][playerid], 0.000000, 90.000000, 0.000000, 0.000000);

	SpecTD[1][playerid] = CreatePlayerTextDraw(playerid, 28.579818, 320.833312, "SLAP");
	PlayerTextDrawLetterSize(playerid, SpecTD[1][playerid], 0.442972, 2.124999);
	PlayerTextDrawTextSize(playerid, SpecTD[1][playerid], 11.244508, 40.833328);
	PlayerTextDrawAlignment(playerid, SpecTD[1][playerid], 2);
	PlayerTextDrawColor(playerid, SpecTD[1][playerid], -16776961);
	PlayerTextDrawUseBox(playerid, SpecTD[1][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[1][playerid], 89);
	PlayerTextDrawSetShadow(playerid, SpecTD[1][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[1][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[1][playerid], -203);
	PlayerTextDrawFont(playerid, SpecTD[1][playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpecTD[1][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SpecTD[1][playerid], true);

	SpecTD[2][playerid] = CreatePlayerTextDraw(playerid, 81.585662, 320.833312, "GM");
	PlayerTextDrawLetterSize(playerid, SpecTD[2][playerid], 0.442972, 2.124999);
	PlayerTextDrawTextSize(playerid, SpecTD[2][playerid], 11.244508, 40.833328);
	PlayerTextDrawAlignment(playerid, SpecTD[2][playerid], 2);
	PlayerTextDrawColor(playerid, SpecTD[2][playerid], -16776961);
	PlayerTextDrawUseBox(playerid, SpecTD[2][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[2][playerid], 89);
	PlayerTextDrawSetShadow(playerid, SpecTD[2][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[2][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[2][playerid], -203);
	PlayerTextDrawFont(playerid, SpecTD[2][playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpecTD[2][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SpecTD[2][playerid], true);

	SpecTD[3][playerid] = CreatePlayerTextDraw(playerid, 143.961929, 320.833312, "GMCAR");
	PlayerTextDrawLetterSize(playerid, SpecTD[3][playerid], 0.442972, 2.124999);
	PlayerTextDrawTextSize(playerid, SpecTD[3][playerid], 11.244508, 55.416652);
	PlayerTextDrawAlignment(playerid, SpecTD[3][playerid], 2);
	PlayerTextDrawColor(playerid, SpecTD[3][playerid], -16776961);
	PlayerTextDrawUseBox(playerid, SpecTD[3][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[3][playerid], 89);
	PlayerTextDrawSetShadow(playerid, SpecTD[3][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[3][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[3][playerid], -203);
	PlayerTextDrawFont(playerid, SpecTD[3][playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpecTD[3][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SpecTD[3][playerid], true);

	SpecTD[4][playerid] = CreatePlayerTextDraw(playerid, 215.240112, 320.833312, "PRISON");
	PlayerTextDrawLetterSize(playerid, SpecTD[4][playerid], 0.442972, 2.124999);
	PlayerTextDrawTextSize(playerid, SpecTD[4][playerid], 11.244508, 55.999992);
	PlayerTextDrawAlignment(playerid, SpecTD[4][playerid], 2);
	PlayerTextDrawColor(playerid, SpecTD[4][playerid], -16776961);
	PlayerTextDrawUseBox(playerid, SpecTD[4][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[4][playerid], 89);
	PlayerTextDrawSetShadow(playerid, SpecTD[4][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[4][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[4][playerid], -203);
	PlayerTextDrawFont(playerid, SpecTD[4][playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpecTD[4][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SpecTD[4][playerid], true);

	SpecTD[5][playerid] = CreatePlayerTextDraw(playerid, 413.767364, 320.833312, "STATS");
	PlayerTextDrawLetterSize(playerid, SpecTD[5][playerid], 0.442972, 2.124999);
	PlayerTextDrawTextSize(playerid, SpecTD[5][playerid], 11.244508, 46.083328);
	PlayerTextDrawAlignment(playerid, SpecTD[5][playerid], 2);
	PlayerTextDrawColor(playerid, SpecTD[5][playerid], -16776961);
	PlayerTextDrawUseBox(playerid, SpecTD[5][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[5][playerid], 89);
	PlayerTextDrawSetShadow(playerid, SpecTD[5][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[5][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[5][playerid], -203);
	PlayerTextDrawFont(playerid, SpecTD[5][playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpecTD[5][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SpecTD[5][playerid], true);

	SpecTD[6][playerid] = CreatePlayerTextDraw(playerid, 473.801208, 320.833312, "KICK");
	PlayerTextDrawLetterSize(playerid, SpecTD[6][playerid], 0.442972, 2.124999);
	PlayerTextDrawTextSize(playerid, SpecTD[6][playerid], 11.244508, 40.833328);
	PlayerTextDrawAlignment(playerid, SpecTD[6][playerid], 2);
	PlayerTextDrawColor(playerid, SpecTD[6][playerid], -16776961);
	PlayerTextDrawUseBox(playerid, SpecTD[6][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[6][playerid], 89);
	PlayerTextDrawSetShadow(playerid, SpecTD[6][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[6][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[6][playerid], -203);
	PlayerTextDrawFont(playerid, SpecTD[6][playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpecTD[6][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SpecTD[6][playerid], true);

	SpecTD[7][playerid] = CreatePlayerTextDraw(playerid, 241.288391, 293.416595, "left");
	PlayerTextDrawLetterSize(playerid, SpecTD[7][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, SpecTD[7][playerid], 67.467048, 50.166671);
	PlayerTextDrawAlignment(playerid, SpecTD[7][playerid], 1);
	PlayerTextDrawColor(playerid, SpecTD[7][playerid], -16776961);
	PlayerTextDrawUseBox(playerid, SpecTD[7][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[7][playerid], 0);
	PlayerTextDrawSetShadow(playerid, SpecTD[7][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[7][playerid], 1);
	PlayerTextDrawFont(playerid, SpecTD[7][playerid], 5);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[7][playerid], 0x00000000);
	PlayerTextDrawSetProportional(playerid, SpecTD[7][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SpecTD[7][playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, SpecTD[7][playerid], 19134);
	PlayerTextDrawSetPreviewRot(playerid, SpecTD[7][playerid], 0.000000, 90.000000, 90.000000, 1.000000);

	SpecTD[8][playerid] = CreatePlayerTextDraw(playerid, 331.307647, 293.249908, "right");
	PlayerTextDrawLetterSize(playerid, SpecTD[8][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, SpecTD[8][playerid], 67.467048, 50.166671);
	PlayerTextDrawAlignment(playerid, SpecTD[8][playerid], 1);
	PlayerTextDrawColor(playerid, SpecTD[8][playerid], -16776961);
	PlayerTextDrawUseBox(playerid, SpecTD[8][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[8][playerid], 0);
	PlayerTextDrawSetShadow(playerid, SpecTD[8][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[8][playerid], 1);
	PlayerTextDrawFont(playerid, SpecTD[8][playerid], 5);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[8][playerid], 0x00000000);
	PlayerTextDrawSetProportional(playerid, SpecTD[8][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SpecTD[8][playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, SpecTD[8][playerid], 19134);
	PlayerTextDrawSetPreviewRot(playerid, SpecTD[8][playerid], 0.000000, 270.000000, 90.000000, 1.000000);

	SpecTD[9][playerid] = CreatePlayerTextDraw(playerid, 320.000091, 299.833251, "1");
	PlayerTextDrawLetterSize(playerid, SpecTD[9][playerid], 0.564787, 3.653333);
	PlayerTextDrawTextSize(playerid, SpecTD[9][playerid], 0.000000, 126.583358);
	PlayerTextDrawAlignment(playerid, SpecTD[9][playerid], 2);
	PlayerTextDrawColor(playerid, SpecTD[9][playerid], -1);
	PlayerTextDrawUseBox(playerid, SpecTD[9][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[9][playerid], 22);
	PlayerTextDrawSetShadow(playerid, SpecTD[9][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[9][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[9][playerid], -1523963137);
	PlayerTextDrawFont(playerid, SpecTD[9][playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpecTD[9][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SpecTD[9][playerid], true);

	SpecTD[10][playerid] = CreatePlayerTextDraw(playerid, 535.709106, 320.833312, "WARN");
	PlayerTextDrawLetterSize(playerid, SpecTD[10][playerid], 0.442972, 2.124999);
	PlayerTextDrawTextSize(playerid, SpecTD[10][playerid], 11.244508, 44.333328);
	PlayerTextDrawAlignment(playerid, SpecTD[10][playerid], 2);
	PlayerTextDrawColor(playerid, SpecTD[10][playerid], -16776961);
	PlayerTextDrawUseBox(playerid, SpecTD[10][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[10][playerid], 89);
	PlayerTextDrawSetShadow(playerid, SpecTD[10][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[10][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[10][playerid], -203);
	PlayerTextDrawFont(playerid, SpecTD[10][playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpecTD[10][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SpecTD[10][playerid], true);

	SpecTD[11][playerid] = CreatePlayerTextDraw(playerid, 599.490966, 320.833312, "MUTE");
	PlayerTextDrawLetterSize(playerid, SpecTD[11][playerid], 0.442972, 2.124999);
	PlayerTextDrawTextSize(playerid, SpecTD[11][playerid], 11.244508, 40.833328);
	PlayerTextDrawAlignment(playerid, SpecTD[11][playerid], 2);
	PlayerTextDrawColor(playerid, SpecTD[11][playerid], -16776961);
	PlayerTextDrawUseBox(playerid, SpecTD[11][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[11][playerid], 89);
	PlayerTextDrawSetShadow(playerid, SpecTD[11][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[11][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[11][playerid], -203);
	PlayerTextDrawFont(playerid, SpecTD[11][playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpecTD[11][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SpecTD[11][playerid], true);

	SpecTD[12][playerid] = CreatePlayerTextDraw(playerid, 319.531890, 420.583343, "FLAWLESS RP");
	PlayerTextDrawLetterSize(playerid, SpecTD[12][playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, SpecTD[12][playerid], 0.468521, 114.916656);
	PlayerTextDrawAlignment(playerid, SpecTD[12][playerid], 2);
	PlayerTextDrawColor(playerid, SpecTD[12][playerid], -1523963137);
	PlayerTextDrawUseBox(playerid, SpecTD[12][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[12][playerid], -1523963252);
	PlayerTextDrawSetShadow(playerid, SpecTD[12][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[12][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[12][playerid], -1);
	PlayerTextDrawFont(playerid, SpecTD[12][playerid], 3);
	PlayerTextDrawSetProportional(playerid, SpecTD[12][playerid], 1);

	SpecTD[13][playerid] = CreatePlayerTextDraw(playerid, 641.999816, 178.250015, "usebox");
	PlayerTextDrawLetterSize(playerid, SpecTD[13][playerid], 0.000000, 13.122016);
	PlayerTextDrawTextSize(playerid, SpecTD[13][playerid], 496.975006, 0.000000);
	PlayerTextDrawAlignment(playerid, SpecTD[13][playerid], 1);
	PlayerTextDrawColor(playerid, SpecTD[13][playerid], 0);
	PlayerTextDrawUseBox(playerid, SpecTD[13][playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecTD[13][playerid], 102);
	PlayerTextDrawSetShadow(playerid, SpecTD[13][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[13][playerid], 0);
	PlayerTextDrawFont(playerid, SpecTD[13][playerid], 0);

	SpecTD[14][playerid] = CreatePlayerTextDraw(playerid, 572.533386, 181.416702, "_");
	PlayerTextDrawLetterSize(playerid, SpecTD[14][playerid], 0.271493, 1.454166);
	PlayerTextDrawAlignment(playerid, SpecTD[14][playerid], 2);
	PlayerTextDrawColor(playerid, SpecTD[14][playerid], -1523963137);
	PlayerTextDrawSetShadow(playerid, SpecTD[14][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[14][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[14][playerid], -167);
	PlayerTextDrawFont(playerid, SpecTD[14][playerid], 2);
	PlayerTextDrawSetProportional(playerid, SpecTD[14][playerid], 1);

	SpecTD[15][playerid] = CreatePlayerTextDraw(playerid, 319.063171, 340.666503, "close");
	PlayerTextDrawLetterSize(playerid, SpecTD[15][playerid], 0.625695, 2.305833);
	PlayerTextDrawAlignment(playerid, SpecTD[15][playerid], 2);
	PlayerTextDrawColor(playerid, SpecTD[15][playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, SpecTD[15][playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecTD[15][playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecTD[15][playerid], -1523963137);
	PlayerTextDrawFont(playerid, SpecTD[15][playerid], 3);
	PlayerTextDrawSetProportional(playerid, SpecTD[15][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SpecTD[15][playerid], true);
	//
	ShieldBar[playerid] = CreatePlayerTextDraw(playerid, 608.0,59.6,"_");//Max - 608.0 | Min - 550.5
	PlayerTextDrawLetterSize(playerid, ShieldBar[playerid],0.0,0.135);
	PlayerTextDrawUseBox(playerid, ShieldBar[playerid],1);
	PlayerTextDrawBoxColor(playerid, ShieldBar[playerid],0x6053F3FF);
	PlayerTextDrawTextSize(playerid, ShieldBar[playerid],546.5,0.0);
	//
	InventoryTextDraws(playerid);
	return 1;
}
stock InventoryTextDraws(playerid) {
	inv_OtherPTD[playerid][0] = CreatePlayerTextDraw(playerid, 10.941151, 306.667236, "progressbar_player"),
	PlayerTextDrawTextSize(playerid, inv_OtherPTD[playerid][0], 174.470458, 0.000000);
	PlayerTextDrawBoxColor(playerid, inv_OtherPTD[playerid][0], -1523963137);
	inv_OtherPTD[playerid][1] = CreatePlayerTextDraw(playerid, 10.941151, 331.167358, "progressbar_player"),
	PlayerTextDrawTextSize(playerid, inv_OtherPTD[playerid][1], 99.176345, 0.000000);
	PlayerTextDrawBoxColor(playerid, inv_OtherPTD[playerid][1], -1061109505);
	inv_OtherPTD[playerid][2] = CreatePlayerTextDraw(playerid, 10.941151, 355.667419, "progressbar_player"),
	PlayerTextDrawTextSize(playerid, inv_OtherPTD[playerid][2], 8.352898, 0.000000);
	PlayerTextDrawBoxColor(playerid, inv_OtherPTD[playerid][2], -2139094785);

	for(new T; T != 3; T++) {
		PlayerTextDrawLetterSize(playerid, inv_OtherPTD[playerid][T], 0.000000, 1.482350);
		PlayerTextDrawAlignment(playerid, inv_OtherPTD[playerid][T], 1);
		PlayerTextDrawColor(playerid, inv_OtherPTD[playerid][T], -1);
		PlayerTextDrawUseBox(playerid, inv_OtherPTD[playerid][T], 1);
		PlayerTextDrawSetShadow(playerid, inv_OtherPTD[playerid][T], 0);
		PlayerTextDrawSetOutline(playerid, inv_OtherPTD[playerid][T], 0);
		PlayerTextDrawBackgroundColor(playerid, inv_OtherPTD[playerid][T], 255);
		PlayerTextDrawFont(playerid, inv_OtherPTD[playerid][T], 1);
		PlayerTextDrawSetProportional(playerid, inv_OtherPTD[playerid][T], 1);
		PlayerTextDrawSetShadow(playerid, inv_OtherPTD[playerid][T], 0);
	}
	inv_OtherPTD[playerid][3] = CreatePlayerTextDraw(playerid, 89.999992, 306.083343, "€ѓOPOB’E:_100%~n~ ~n~ЂPOH•:_54%~n~ ~n~C‘TOCT’:_1%");
	PlayerTextDrawLetterSize(playerid, inv_OtherPTD[playerid][3], 0.274823, 1.366666);
	PlayerTextDrawAlignment(playerid, inv_OtherPTD[playerid][3], 2);
	PlayerTextDrawColor(playerid, inv_OtherPTD[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, inv_OtherPTD[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, inv_OtherPTD[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, inv_OtherPTD[playerid][3], 255);
	PlayerTextDrawFont(playerid, inv_OtherPTD[playerid][3], 2);
	PlayerTextDrawSetProportional(playerid, inv_OtherPTD[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, inv_OtherPTD[playerid][3], 0);

	inv_OtherPTD[playerid][4] = CreatePlayerTextDraw(playerid, 89.058830, 283.333526, "~w~Mansur_Taukenov_(~y~0~w~)");
	PlayerTextDrawLetterSize(playerid, inv_OtherPTD[playerid][4], 0.135529, 0.643332);
	PlayerTextDrawTextSize(playerid, inv_OtherPTD[playerid][4], 0.000000, 74.470588);
	PlayerTextDrawAlignment(playerid, inv_OtherPTD[playerid][4], 2);
	PlayerTextDrawColor(playerid, inv_OtherPTD[playerid][4], -1);
	PlayerTextDrawUseBox(playerid, inv_OtherPTD[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, inv_OtherPTD[playerid][4], 255);
	PlayerTextDrawSetShadow(playerid, inv_OtherPTD[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, inv_OtherPTD[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, inv_OtherPTD[playerid][4], 255);
	PlayerTextDrawFont(playerid, inv_OtherPTD[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, inv_OtherPTD[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, inv_OtherPTD[playerid][4], 0);

	inv_OtherPTD[playerid][5] = CreatePlayerTextDraw(playerid, 34.411754, 152.583297, "_");
	PlayerTextDrawLetterSize(playerid, inv_OtherPTD[playerid][5], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, inv_OtherPTD[playerid][5], 105.058822, 119.166656);
	PlayerTextDrawAlignment(playerid, inv_OtherPTD[playerid][5], 1);
	PlayerTextDrawColor(playerid, inv_OtherPTD[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, inv_OtherPTD[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, inv_OtherPTD[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, inv_OtherPTD[playerid][5], 0);
	PlayerTextDrawFont(playerid, inv_OtherPTD[playerid][5], 5);
	PlayerTextDrawSetProportional(playerid, inv_OtherPTD[playerid][5], 0);
	PlayerTextDrawSetShadow(playerid, inv_OtherPTD[playerid][5], 0);
	PlayerTextDrawSetPreviewModel(playerid, inv_OtherPTD[playerid][5], 187);
	PlayerTextDrawSetPreviewRot(playerid, inv_OtherPTD[playerid][5], 0.000000, 0.000000, 27.000000, 0.913106);

	inv_SlotsPTD[playerid][0] = CreatePlayerTextDraw(playerid, 200.000000, 200.000000, "_");
	inv_SlotsPTD[playerid][0 + 1] = CreatePlayerTextDraw(playerid, 450.000000, 150.000000, "_");
	inv_SlotsPTD[playerid][1 + 1] = CreatePlayerTextDraw(playerid, 492.000000, 150.000000, "_");
	inv_SlotsPTD[playerid][2 + 1] = CreatePlayerTextDraw(playerid, 534.000000, 150.000000, "_");
	inv_SlotsPTD[playerid][3 + 1] = CreatePlayerTextDraw(playerid, 576.000000, 150.000000, "_");
	inv_SlotsPTD[playerid][4 + 1] = CreatePlayerTextDraw(playerid, 450.000000, 192.000000, "_");
	inv_SlotsPTD[playerid][5 + 1] = CreatePlayerTextDraw(playerid, 492.000000, 192.000000, "_");
	inv_SlotsPTD[playerid][6 + 1] = CreatePlayerTextDraw(playerid, 534.000000, 192.000000, "_");
	inv_SlotsPTD[playerid][7 + 1] = CreatePlayerTextDraw(playerid, 576.000000, 192.000000, "_");
	inv_SlotsPTD[playerid][8 + 1] = CreatePlayerTextDraw(playerid, 450.000000, 234.000000, "_");
	inv_SlotsPTD[playerid][9 + 1] = CreatePlayerTextDraw(playerid, 492.000000, 234.000000, "_");
	inv_SlotsPTD[playerid][10 + 1] = CreatePlayerTextDraw(playerid, 534.000000, 234.000000, "_");
	inv_SlotsPTD[playerid][11 + 1] = CreatePlayerTextDraw(playerid, 576.000000, 234.000000, "_");
	inv_SlotsPTD[playerid][12 + 1] = CreatePlayerTextDraw(playerid, 450.000000, 276.000000, "_");
	inv_SlotsPTD[playerid][13 + 1] = CreatePlayerTextDraw(playerid, 492.000000, 276.000000, "_");
	inv_SlotsPTD[playerid][14 + 1] = CreatePlayerTextDraw(playerid, 534.000000, 276.000000, "_");
	inv_SlotsPTD[playerid][15 + 1] = CreatePlayerTextDraw(playerid, 576.000000, 276.000000, "_");
	inv_SlotsPTD[playerid][16 + 1] = CreatePlayerTextDraw(playerid, 450.000000, 318.000000, "_");
	inv_SlotsPTD[playerid][17 + 1] = CreatePlayerTextDraw(playerid, 492.000000, 318.000000, "_");
	inv_SlotsPTD[playerid][18 + 1] = CreatePlayerTextDraw(playerid, 534.000000, 318.000000, "_");
	inv_SlotsPTD[playerid][19 + 1] = CreatePlayerTextDraw(playerid, 576.000000, 318.000000, "_");

	for(new T = 1; T != 21; T++) {
		PlayerTextDrawLetterSize(playerid, inv_SlotsPTD[playerid][T], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, inv_SlotsPTD[playerid][T], 39.820030, 40.000000);
		PlayerTextDrawAlignment(playerid, inv_SlotsPTD[playerid][T], 1);
		PlayerTextDrawColor(playerid, inv_SlotsPTD[playerid][T], -1);
		PlayerTextDrawSetShadow(playerid, inv_SlotsPTD[playerid][T], 0);
		PlayerTextDrawSetOutline(playerid, inv_SlotsPTD[playerid][T], 0);
		PlayerTextDrawBackgroundColor(playerid, inv_SlotsPTD[playerid][T], -86);
		PlayerTextDrawFont(playerid, inv_SlotsPTD[playerid][T], 5);
		PlayerTextDrawSetProportional(playerid, inv_SlotsPTD[playerid][T], 0);
		PlayerTextDrawSetShadow(playerid, inv_SlotsPTD[playerid][T], 0);
		PlayerTextDrawSetPreviewModel(playerid, inv_SlotsPTD[playerid][T], 0);
		PlayerTextDrawSetPreviewRot(playerid, inv_SlotsPTD[playerid][T], 0.000000, 0.000000, 0.000000, 88.0);
		PlayerTextDrawSetSelectable(playerid, inv_SlotsPTD[playerid][T], true);
	}
	return 1;
}
stock LoadVehicle() {
	new addob;
	//ПИРС
	krub_car[0] = CreateVehicleEx(453,-26.4172000,-1610.2412100,0.0000000,129.9320000,7,7,60*60*24); //Reefer
	krub_car[1] = CreateVehicleEx(453,-41.4888000,-1621.2956500,0.0000000,129.9300000,7,7,60*60*24); //Reefer
	krub_car[2] = CreateVehicleEx(453,-56.0707000,-1635.5103800,0.0000000,129.9300000,7,7,60*60*24); //Reefer
	krub_car[3] = CreateVehicleEx(453,-73.5288000,-1648.3623000,0.0000000,129.9300000,7,7,60*60*24); //Reefer
	//Колхоз
	CombineVeh[0] = CreateVehicleEx(532,-152.8497000,-143.2959000,4.2269000,348.0000000,-1,-1,300); //Combine
	CreateVehicleEx(532,-143.6777000,-145.3535000,4.2269000,347.9970000,-1,-1,300); //Combine
	CreateVehicleEx(532,-186.6234000,-138.0701000,4.2269000,347.9970000,-1,-1,300); //Combine
	CreateVehicleEx(532,-251.3860000,-126.9883000,4.2269000,347.9920000,-1,-1,300); //Combine
	CreateVehicleEx(532,-177.7305000,-139.7305000,4.2269000,347.9870000,-1,-1,300); //Combine
	CreateVehicleEx(532,-242.2432000,-128.8057000,4.2269000,347.9870000,-1,-1,300); //Combine
	CreateVehicleEx(532,-275.4650000,-119.4399000,4.1685000,343.9870000,-1,-1,300); //Combine
	CreateVehicleEx(532,-285.3461000,-118.4639000,3.5198000,343.9820000,-1,-1,300); //Combine
	CreateVehicleEx(532,-17.4859000,-168.8496000,2.9526000,347.9970000,-1,-1,300); //Combine
	CreateVehicleEx(532,-61.4003000,-161.6207000,4.2269000,347.9970000,-1,-1,300); //Combine
	CreateVehicleEx(532,-52.1640600,-163.4033000,4.2269000,347.9920000,-1,-1,300); //Combine
	CreateVehicleEx(532,-27.5625000,-165.9570000,3.6139000,347.9920000,-1,-1,300); //Combine
	CreateVehicleEx(532,33.7019000,-173.7373000,1.7191000,353.9920000,-1,-1,300); //Combine
	CreateVehicleEx(532,24.5064000,-173.0039000,1.7191000,353.9920000,-1,-1,300); //Combine
	CreateVehicleEx(532,58.8318000,-174.7457000,2.1657000,353.9910000,-1,-1,300); //Combine
	CombineVeh[1] = CreateVehicleEx(532,67.7919900,-174.7705000,2.4098000,353.9910000,-1,-1,300); //Combine
	//
	FlyVeh[0] = CreateVehicleEx(512,170.9106000,22.7743000,2.2286000,86.0000000,137,86,300); //Cropdust
	CreateVehicleEx(512,169.0430000,35.1865200,2.5653000,85.9950000,137,86,300); //Cropdust
	CreateVehicleEx(512,156.3530000,23.7335000,2.1051000,87.9950000,137,86,300); //Cropdust
	FlyVeh[1] = CreateVehicleEx(512,155.5723000,35.0263700,2.4071000,83.9950000,137,86,300); //Cropdust
	//
	TraktorVeh[0] = CreateVehicleEx(531,-211.6090000,-143.0302000,3.0440000,80.0000000,137,86,300); //Tractor
	CreateVehicleEx(531,-209.2393000,-126.6299000,3.1236000,81.9970000,137,86,300); //Tractor
	CreateVehicleEx(531,-209.7246000,-130.0381000,3.1236000,81.9960000,137,86,300); //Tractor
	CreateVehicleEx(531,-220.3114000,-127.9152000,3.1236000,260.0000000,137,86,300); //Tractor
	CreateVehicleEx(531,-210.5674000,-136.3545000,3.1236000,79.9970000,137,86,300); //Tractor
	CreateVehicleEx(531,-211.2471000,-139.4582000,3.1236000,80.0000000,137,86,300); //Tractor
	CreateVehicleEx(531,-210.1406000,-133.2686000,3.1236000,79.9970000,137,86,300); //Tractor
	CreateVehicleEx(531,-222.7188000,-141.2793000,3.0245000,261.9970000,137,86,300); //Tractor
	CreateVehicleEx(531,-2.2970000,-170.1520000,0.8411000,261.9910000,137,86,300); //Tractor
	CreateVehicleEx(531,-220.8477000,-131.0322000,3.1236000,259.9910000,137,86,300); //Tractor
	CreateVehicleEx(531,-221.4414000,-134.2461000,3.1236000,259.9910000,137,86,300); //Tractor
	CreateVehicleEx(531,-222.0273000,-137.6426000,3.1236000,261.9970000,137,86,300); //Tractor
	CreateVehicleEx(531,-219.7080000,-124.5254000,3.1236000,259.9910000,137,86,300); //Tractor
	CreateVehicleEx(531,-1.1943400,-163.2734000,0.7698000,259.9910000,137,86,300); //Tractor
	CreateVehicleEx(531,-1.7207000,-166.6904000,0.8037000,259.9910000,137,86,300); //Tractor
	CreateVehicleEx(531,-2.6330000,-173.9797000,0.8614000,259.9910000,137,86,300); //Tractor
	CreateVehicleEx(531,9.3353000,-165.5248000,0.6158000,83.9860000,137,86,300); //Tractor
	CreateVehicleEx(531,-3.1855500,-177.5908000,0.8926000,259.9860000,137,86,300); //Tractor
	CreateVehicleEx(531,-3.6376900,-181.3916000,0.9068000,261.9860000,137,86,300); //Tractor
	CreateVehicleEx(531,7.7854000,-176.8831000,0.6158000,83.9840000,137,86,300); //Tractor
	CreateVehicleEx(531,8.9074000,-169.3340000,0.6158000,83.9840000,137,86,300); //Tractor
	CreateVehicleEx(531,8.4150400,-172.9805000,0.6158000,83.9790000,137,86,300); //Tractor
	CreateVehicleEx(531,7.4171000,-180.0604000,0.6158000,83.9790000,137,86,300); //Tractor
	TraktorVeh[1] = CreateVehicleEx(531,7.0607000,-183.1021000,0.6577000,83.9790000,137,86,300); //Tractor
	//
	RentBike[0] = CreateVehicleEx(510,1560.9580078,-2263.9560547,13.2170000,90.0000000,86,1,6000);
	CreateVehicleEx(510,1560.9580078,-2260.8059082,13.2159996,90.0000000,86,1,6000); //
	CreateVehicleEx(510,1560.9580078,-2257.6140137,13.2159996,90.0000000,86,1,6000); //
	CreateVehicleEx(510,1560.9580078,-2254.3049316,13.2170000,90.0000000,86,1,6000); //
	CreateVehicleEx(510,1560.9580078,-2251.0681152,13.2170000,90.0000000,86,1,6000); //
	CreateVehicleEx(510,1560.9580078,-2247.6708984,13.2170000,90.0000000,86,1,6000); //
	CreateVehicleEx(510,1560.9580078,-2244.4499512,13.2170000,90.0000000,86,1,6000); //
	CreateVehicleEx(510,1560.9580078,-2240.8449707,13.2170000,90.0000000,86,1,6000); //
	CreateVehicleEx(510,1560.9580078,-2237.9929199,13.2170000,90.0000000,86,1,6000); //
	CreateVehicleEx(510,1560.9580078,-2234.7619629,13.2170000,90.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1382.2189941,13.2270002,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1380.9909668,13.2279997,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1379.8540039,13.2279997,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1378.7790527,13.2270002,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1377.6700439,13.2270002,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1376.6090088,13.2270002,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1375.5279541,13.2270002,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1374.4589844,13.2270002,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1373.4139404,13.2279997,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1372.2309570,13.2200003,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1371.1479492,13.2209997,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1367.8499756,13.2220001,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1368.8640137,13.2209997,270.0000000,86,1,6000);
	CreateVehicleEx(510,1187.3929443,-1370.1669922,13.2209997,270.0000000,86,1,6000);
	CreateVehicleEx(510,562.4470215,-1258.9520264,16.9120007,108.0000000,86,1,6000);
	CreateVehicleEx(510,562.8129883,-1260.1650391,16.9120007,107.9956055,86,1,6000);
	CreateVehicleEx(510,563.0789795,-1261.3730469,16.9120007,107.9956055,86,1,6000);
	CreateVehicleEx(510,563.3670044,-1262.5520020,16.9120007,107.9956055,86,1,6000);
	CreateVehicleEx(510,563.5770264,-1263.5600586,16.9120007,107.9956055,86,1,6000);
	CreateVehicleEx(510,563.7988281,-1264.7070312,16.9120007,107.9956055,86,1,6000);
	CreateVehicleEx(510,564.0319824,-1265.9160156,16.9120007,107.9956055,86,1,6000);
	CreateVehicleEx(510,564.2343750,-1267.1210938,16.9120007,107.9956055,86,1,6000);
	CreateVehicleEx(510,564.4769897,-1268.2950439,16.9120007,107.9956055,86,1,6000);
	CreateVehicleEx(510,564.7160034,-1269.4449463,16.9120007,107.9956055,86,1,6000);
	CreateVehicleEx(510,1446.7590332,-1376.1369629,13.2170000,270.0000000,86,1,6000);
	CreateVehicleEx(510,1446.7590332,-1377.4549561,13.2170000,270.0000000,86,1,6000);
	CreateVehicleEx(510,1446.7590332,-1378.8070068,13.2170000,270.0000000,86,1,6000);
	CreateVehicleEx(510,1446.7590332,-1380.1219482,13.2170000,270.0000000,86,1,6000);
	CreateVehicleEx(510,1446.7590332,-1381.7320557,13.2170000,270.0000000,86,1,6000);
	CreateVehicleEx(510,1446.7590332,-1383.3100586,13.2170000,270.0000000,86,1,6000);
	CreateVehicleEx(510,1446.7590332,-1384.6419678,13.2170000,270.0000000,86,1,6000);
	CreateVehicleEx(510,1446.7590332,-1386.1910400,13.2170000,270.0000000,86,1,6000);
	CreateVehicleEx(510,1446.7590332,-1387.6789551,13.2170000,270.0000000,86,1,6000);
	CreateVehicleEx(510,1446.7590332,-1389.1400146,13.2170000,270.0000000,86,1,6000);
	CreateVehicleEx(510,1446.7590332,-1390.7149658,13.2170000,270.0000000,86,1,6000);
	CreateVehicleEx(510,2190.8740234,-1774.3170166,13.2229996,90.0000000,86,1,6000);
	CreateVehicleEx(510,2190.8740234,-1776.6850586,13.2229996,90.0000000,86,1,6000);
	CreateVehicleEx(510,2190.8740234,-1775.5560303,13.2229996,90.0000000,86,1,6000);
	CreateVehicleEx(510,2190.8740234,-1778.1020508,13.2229996,90.0000000,86,1,6000);
	CreateVehicleEx(510,2190.8740234,-1779.3349609,13.2229996,90.0000000,86,1,6000);
	CreateVehicleEx(510,2190.8740234,-1780.5340576,13.2229996,90.0000000,86,1,6000);
	CreateVehicleEx(510,2190.8740234,-1781.8759766,13.2229996,90.0000000,86,1,6000);
	CreateVehicleEx(510,2190.8740234,-1783.0810547,13.2229996,90.0000000,86,1,6000);
	CreateVehicleEx(510,2190.8740234,-1784.1719971,13.2229996,90.0000000,86,1,6000);
	CreateVehicleEx(510,2355.2958984,-1994.0629883,13.2080002,90.0000000,86,1,6000);
	CreateVehicleEx(510,2355.2958984,-1995.5300293,13.2080002,90.0000000,86,1,6000);
	CreateVehicleEx(510,2355.2958984,-1996.8420410,13.2100000,90.0000000,86,1,6000);
	CreateVehicleEx(510,2355.2958984,-1998.0500488,13.2100000,90.0000000,86,1,6000);
	CreateVehicleEx(510,2355.2958984,-1999.5129395,13.2089996,90.0000000,86,1,6000);
	CreateVehicleEx(510,2355.2958984,-2000.7149658,13.2080002,90.0000000,86,1,6000);
	CreateVehicleEx(510,2355.2958984,-2002.0209961,13.2080002,90.0000000,86,1,6000);
	CreateVehicleEx(510,1790.2320557,-1883.1800537,13.2390003,180.0000000,86,1,6000);
	CreateVehicleEx(510,1791.5930176,-1883.1800537,13.2399998,180.0000000,86,1,6000);
	CreateVehicleEx(510,1792.8149414,-1883.1800537,13.2410002,180.0000000,86,1,6000);
	CreateVehicleEx(510,1794.0789795,-1883.1800537,13.2419996,180.0000000,86,1,6000);
	CreateVehicleEx(510,1795.2669678,-1883.1800537,13.2430000,180.0000000,86,1,6000);
	CreateVehicleEx(510,1796.5860596,-1883.1800537,13.2440004,180.0000000,86,1,6000);
	CreateVehicleEx(510,1797.8399658,-1883.1800537,13.2449999,180.0000000,86,1,6000);
	CreateVehicleEx(510,1799.1459961,-1883.1800537,13.2449999,180.0000000,86,1,6000);
	CreateVehicleEx(510,1800.4389648,-1883.1800537,13.2460003,180.0000000,86,1,6000);
	CreateVehicleEx(510,1801.6479492,-1883.1800537,13.2469997,180.0000000,86,1,6000);
	CreateVehicleEx(510,1085.2889404,-1802.8759766,13.2729998,0.0000000,86,1,6000);
	CreateVehicleEx(510,1086.5799561,-1802.8759766,13.2720003,0.0000000,86,1,6000);
	CreateVehicleEx(510,1087.8759766,-1802.8759766,13.2729998,0.0000000,86,1,6000);
	CreateVehicleEx(510,1089.3110352,-1802.8759766,13.2729998,0.0000000,86,1,6000);
	CreateVehicleEx(510,1090.8649902,-1802.8759766,13.2729998,0.0000000,86,1,6000);
	CreateVehicleEx(510,1092.2569580,-1802.8759766,13.2740002,0.0000000,86,1,6000);
	CreateVehicleEx(510,1093.8609619,-1802.8759766,13.2740002,0.0000000,86,1,6000);
	CreateVehicleEx(510,1095.3680420,-1802.8759766,13.2740002,0.0000000,86,1,6000);
	CreateVehicleEx(510,1096.7309570,-1802.8759766,13.2749996,0.0000000,86,1,6000);
	CreateVehicleEx(510,1342.958984375,-1755.5350341797,13.022000312805,270,86,1,6000);
	CreateVehicleEx(510,1342.958984375,-1754.04296875,13.026000022888,270,86,1,6000);
	CreateVehicleEx(510,1342.958984375,-1752.7919921875,13.029999732971,270,86,1,6000);
	CreateVehicleEx(510,1342.958984375,-1751.4350585938,13.032999992371,270,86,1,6000);
	CreateVehicleEx(510,1342.958984375,-1749.9880371094,13.036999702454,270,86,1,6000);
	CreateVehicleEx(510,1342.958984375,-1748.6910400391,13.041000366211,270,86,1,6000);
	CreateVehicleEx(510,1342.958984375,-1747.4759521484,13.043999671936,270,86,1,6000);
	CreateVehicleEx(510,1342.958984375,-1746.248046875,13.046999931335,270,86,1,6000);
	RentBike[1] = CreateVehicleEx(510,1098.0780029,-1802.8759766,13.2749996,0.0000000,86,1,6000);
	//
	PDcar[0] = CreateVehicleEx(596,1558.8014,-1711.3660,5.6104,359.5564,0,1,1000); //
	PDcar[1] = CreateVehicleEx(596,1563.1395,-1711.3534,5.6116,359.1625,0,1,1000); //
	PDcar[2] = CreateVehicleEx(596,1566.3644,-1711.3555,5.6111,0.2191,0,1,1000); //
	PDcar[3] = CreateVehicleEx(596,1570.2467,-1711.2629,5.6124,0.2103,0,1,1000); //
	PDcar[4] = CreateVehicleEx(596,1574.3468,-1711.1990,5.6120,0.2747,0,1,1000); //
	PDcar[5] = CreateVehicleEx(596,1578.5591,-1711.1484,5.6109,359.3940,0,1,1000); //
	PDcar[6] = CreateVehicleEx(596,1583.4923,-1711.0844,5.6117,358.5572,0,1,1000); //
	PDcar[7] = CreateVehicleEx(596,1587.4712,-1711.0510,5.6113,359.0681,0,1,1000); //
	PDcar[8] = CreateVehicleEx(596,1591.4742,-1711.0812,5.6113,1.1999,0,1,1000); //
	PDcar[9] = CreateVehicleEx(596,1595.5752,-1710.9966,5.6116,0.3633,0,1,1000); //
	PDcar[10] = CreateVehicleEx(523,1545.7740,-1684.3679,5.4624,89.6988,0,1,1000); //
	PDcar[11] = CreateVehicleEx(523,1545.7905,-1680.2521,5.4561,86.1176,0,1,1000); //
	PDcar[12] = CreateVehicleEx(523,1545.9222,-1676.3115,5.4518,89.5226,0,1,1000); //
	PDcar[13] = CreateVehicleEx(523,1546.0250,-1672.0103,5.4589,87.9224,0,1,1000); //
	PDcar[14] = CreateVehicleEx(523,1546.1267,-1668.0244,5.4590,90.6312,0,1,1000); //
	PDcar[15] = CreateVehicleEx(427,1544.8068,-1663.0225,6.0225,89.1391,0,1,1000); //
	PDcar[16] = CreateVehicleEx(427,1544.7842,-1659.0350,6.0225,89.6844,0,1,1000); //
	PDcar[17] = CreateVehicleEx(601,1545.2870,-1655.0380,5.6494,89.9802,0,1,1000); //
	PDcar[18] = CreateVehicleEx(601,1545.3555,-1650.9889,5.6494,89.2807,0,1,1000); //
	PDcar[19] = CreateVehicleEx(497,1552.1901,-1611.1724,13.5590,90.7937,0,1,1000); //
	PDcar[20] = CreateVehicleEx(596,1535.741943,-1669.011962,13.2030,0.0,0,1,1000); //
	PDcar[21] = CreateVehicleEx(596,1535.741943,-1677.083984,13.2030,0.0,0,1,1000); //
	//
	LVPDcar[0] = CreateVehicleEx(528,2268.2695,2430.0938,3.3171,358.6068,0,1,900); // lvpdbtr
	CreateVehicleEx(528,2263.9670,2430.1416,3.3177,1.4797,0,1,900); // lvpdbtr
	CreateVehicleEx(601,2246.4668,2430.2537,3.0330,358.8506,0,1,900); // lvpdbtrvoda
	CreateVehicleEx(427,2240.3972,2442.6682,3.4036,271.4677,0,1,900); // lvpdswat
	CreateVehicleEx(427,2240.4106,2447.0754,3.4058,270.0402,0,1,900); // lvpdswat
	CreateVehicleEx(599,2272.5317,2473.7097,3.4714,0.1665,0,1,900); // lvpdranger
	CreateVehicleEx(599,2277.1033,2473.7627,3.4720,358.9612,0,1,900); // lvpdranger
	CreateVehicleEx(599,2281.4683,2473.8914,3.4715,359.7398,0,1,900); // lvpdranger
	CreateVehicleEx(598,2298.0623,2464.5388,3.0151,270.2421,0,1,900); // lvpdcar
	CreateVehicleEx(598,2297.9556,2460.4087,3.0232,271.0115,0,1,900); // lvpdcar
	CreateVehicleEx(598,2298.2161,2455.8787,3.0152,270.4524,0,1,900); // lvpdcar
	CreateVehicleEx(598,2298.2314,2451.5583,3.0229,269.8048,0,1,900); // lvpdcar
	CreateVehicleEx(598,2314.8003,2455.3889,3.0077,91.1429,0,1,900); // lvpdcar
	CreateVehicleEx(598,2314.8572,2460.4841,3.0074,91.8853,0,1,900); // lvpdcar
	CreateVehicleEx(598,2314.9209,2465.3906,3.0045,91.5347,0,1,900); // lvpdcar
	CreateVehicleEx(598,2315.1702,2470.2319,3.0205,89.5300,0,1,900); // lvpdcar
	CreateVehicleEx(598,2315.0566,2475.4482,3.0461,89.8078,0,1,900); // lvpdcar
	CreateVehicleEx(598,2314.9263,2480.1689,3.0197,89.2964,0,1,900); // lvpdcar
	CreateVehicleEx(523,2298.9216,2429.1909,2.8418,4.5826,0,1,900); // lvpdmoto
	CreateVehicleEx(523,2303.5938,2429.3633,2.8414,1.8499,0,1,900); // lvpdmoto
	CreateVehicleEx(523,2307.9351,2429.3860,2.8416,357.4909,0,1,900); // lvpdmoto
	CreateVehicleEx(523,2312.2292,2429.5088,2.8375,2.2066,0,1,900); // lvpdmoto
	CreateVehicleEx(523,2316.3352,2429.6118,2.8396,357.8275,0,1,900); // lvpdmoto
	CreateVehicleEx(497,2321.7639,2478.5476,38.9019,182.9352,0,1,900); // lvpdvert
	addob = CreateVehicleEx(482,2268.0413,2473.4277,3.3912,359.7198,0,0,-1); //  буритто
	AttachDynamicObjectToVehicle(CreateDynamicObject(19420,0.0,0.0,0.0,0.0,0.0,0.0),addob,0.0,0.8,0.9,0.0,0.0,0.0);
	LVPDcar[1] = CreateVehicleEx(497,2334.9746,2477.6904,38.8246,179.8571,0,1,900); // lvpdvert
	//
	SFPDcar[0] = CreateVehicleEx(601,-1639.2742,670.0042,-5.4486,269.8602,0,1,900); // sfpdvoda
	CreateVehicleEx(427,-1639.0233,682.1505,-5.0854,270.1815,0,1,900); // sfpdswat
	CreateVehicleEx(427,-1638.9888,686.3229,-5.0856,270.0407,0,1,900); // sfpdswat
	CreateVehicleEx(599,-1620.8568,692.8153,-4.9987,180.1635,0,1,900); // sfpdranger
	CreateVehicleEx(599,-1616.5930,692.8578,-5.0127,177.9342,0,1,900); // sfpdranger
	CreateVehicleEx(599,-1612.8293,692.7169,-5.0470,179.3193,0,1,900); // sfpdranger
	CreateVehicleEx(528,-1600.0597,676.2303,-5.1872,1.3288,0,1,900); // sfpdbtr
	CreateVehicleEx(528,-1596.2113,676.2355,-5.1945,356.3854,0,1,900); // sfpdbtr
	CreateVehicleEx(597,-1572.9147,706.0131,-5.4700,91.6360,0,1,900); // sfpdcar
	CreateVehicleEx(597,-1572.7220,710.3838,-5.4738,90.0642,0,1,900); // sfpdcar
	CreateVehicleEx(597,-1572.8831,714.5292,-5.5070,89.9968,0,1,900); // sfpdcar
	CreateVehicleEx(597,-1572.8605,718.1851,-5.4748,91.9907,0,1,900); // sfpdcar
	CreateVehicleEx(597,-1572.9169,722.1935,-5.4729,87.0568,0,1,900); // sfpdcar
	CreateVehicleEx(597,-1572.6735,726.5764,-5.4806,89.1766,0,1,900); // sfpdcar
	CreateVehicleEx(597,-1572.6223,730.6839,-5.4703,86.7548,0,1,900); // sfpdcar
	CreateVehicleEx(597,-1572.2717,742.8502,-5.4749,91.1999,0,1,900); // sfpdcar
	CreateVehicleEx(597,-1572.2643,738.7764,-5.4715,91.3459,0,1,900); // sfpdcar
	CreateVehicleEx(597,-1572.7437,734.6852,-5.5109,91.2371,0,1,900); // sfpdcar
	CreateVehicleEx(523,-1588.2140,750.4854,-5.6770,180.7430,0,1,900); // sfpdmoto
	CreateVehicleEx(523,-1592.1270,750.2172,-5.6754,177.9434,0,1,900); // sfpdmoto
	CreateVehicleEx(523,-1595.9806,750.4556,-5.6752,180.8003,0,1,900); // sfpdmoto
	CreateVehicleEx(523,-1600.3767,750.3168,-5.6756,177.7568,0,1,900); // sfpdmoto
	CreateVehicleEx(523,-1604.4688,750.4863,-5.6745,169.9970,0,1,900); // sfpdmoto
	addob = CreateVehicleEx(482,-1622.8169,653.5810,-5.1181,89.7575,0,0,-1); //  буритто
	AttachDynamicObjectToVehicle(CreateDynamicObject(19420,0.0,0.0,0.0,0.0,0.0,0.0),addob,0.0,0.8,0.9,0.0,0.0,0.0);
	SFPDcar[1] = CreateVehicleEx(497,-1679.0399,705.5018,30.7489,91.9520,0,1,900); // sfpdvert
	//
	ArmyCar[0] = CreateVehicleEx(407,332.9339905,2072.7670898,18.0109997,90.0000000,104,1,6000); //Firetruck
	CreateVehicleEx(553,307.4218750,2060.9023438,19.8759995,180.0000000,55,55,6000); //Nevada
	CreateVehicleEx(470,369.2709961,1947.6820068,18.1889992,89.0000000,-1,-1,6000); //Patriot
	CreateVehicleEx(470,369.2709961,1943.6590576,18.1040001,88.9947510,-1,-1,6000); //Patriot
	CreateVehicleEx(470,369.2709961,1939.7850342,18.0620003,88.9947510,-1,-1,6000); //Patriot
	CreateVehicleEx(470,369.2709961,1935.5989990,18.0179996,88.9947510,-1,-1,6000); //Patriot
	CreateVehicleEx(470,369.2705078,1931.3349609,17.9740009,88.9947510,-1,-1,6000); //Patriot
	CreateVehicleEx(470,369.0790100,1926.9019775,17.9270000,88.9947510,-1,-1,6000); //Patriot
	CreateVehicleEx(470,369.0700073,1922.1870117,17.8780003,88.9947510,-1,-1,6000); //Patriot
	CreateVehicleEx(470,369.0669861,1917.7380371,17.8309994,88.9947510,-1,-1,6000); //Patriot
	CreateVehicleEx(470,369.0499878,1913.2020264,17.7919998,88.9947510,-1,-1,6000); //Patriot
	CreateVehicleEx(470,369.0450134,1908.8149414,17.7819996,88.9947510,-1,-1,6000); //Patriot
	CreateVehicleEx(470,369.0000000,1904.4229736,17.7730007,88.9947510,-1,-1,6000); //Patriot
	CreateVehicleEx(470,369.0000000,1899.6920166,17.7619991,88.9947510,-1,-1,6000); //Patriot
	CreateVehicleEx(437,327.9599915,1951.2230225,18.3260002,268.0000000,55,55,6000); //Coach
	CreateVehicleEx(432,272.5830078,1946.3149414,17.7399998,0.0000000,-1,-1,6000); //Rhino
	CreateVehicleEx(432,281.6059875,1946.3149414,17.7399998,0.0000000,-1,-1,6000); //Rhino
	CreateVehicleEx(432,281.6059875,1965.1989746,17.7399998,180.0000000,-1,-1,6000); //Rhino
	CreateVehicleEx(432,272.5830078,1965.1989746,17.7399998,180.0000000,-1,-1,6000); //Rhino
	//CreateVehicleEx(548,224.0420074,2020.3979492,19.5489998,0.0000000,-1,-1,6000); //Cargobob
	CreateVehicleEx(487,213.8190002,2003.7960205,17.9130001,270.0000000,55,1,6000); //Maverick
	CreateVehicleEx(487,232.2339935,2003.8499756,17.9060001,270.0000000,55,1,6000); //Maverick
	CreateVehicleEx(487,231.8919983,2024.5469971,17.9130001,270.0000000,55,1,6000); //Maverick
	CreateVehicleEx(487,212.2630005,2024.8800049,17.9060001,270.0000000,55,1,6000); //Maverick
	CreateVehicleEx(425,271.4939880,1933.2159424,18.4920006,236.0000000,55,1,6000); //Hunter
	CreateVehicleEx(425,284.3900146,1933.5300293,18.4920006,235.9973145,55,1,6000); //Hunter
	CreateVehicleEx(520,278.8540039,2018.3890381,18.5599995,270.0000000,-1,-1,6000); //Hydra
	ArmyCar[1] = CreateVehicleEx(520,278.8540039,2029.4079590,18.5599995,270.0000000,-1,-1,1000); //Hydra
	// Матовозы
	ArmyMatCar[0] = CreateVehicleEx(433,271.1700134,1979.7979736,18.2110004,0.0000000,114,114,300); //Barcks
	CreateVehicleEx(433,276.4270020,1979.7979736,18.2110004,0.0000000,114,114,300); //Barcks
	CreateVehicleEx(433,281.7929993,1979.7979736,18.2110004,0.0000000,114,114,300); //Barcks
	CreateVehicleEx(433,271.1700134,1999.0489502,18.2110004,180.0000000,114,114,300); //Barcks
	CreateVehicleEx(433,276.4270020,1999.0489502,18.2110004,180.0000000,114,114,300); //Barcks
	CreateVehicleEx(433,281.7929993,1999.0489502,18.2110004,180.0000000,114,114,300); //Barcks
	CreateVehicleEx(433,274.8160095,1987.0930176,18.2110004,270.0000000,114,114,300); //Barcks
	ArmyMatCar[1] = CreateVehicleEx(433,274.8160095,1991.5389404,18.2110004,270.0000000,114,114,300); //Barcks
	//
	VMFCar[0] = CreateVehicleEx(445,-1528.2779541016,420.5,7.2979998588562,180,61,61,6000);
	CreateVehicleEx(445,-1531.4709472656,420.5,7.2979998588562,180,61,61,6000);
	CreateVehicleEx(445,-1534.7590332031,420.5,7.2979998588562,180,61,61,6000);
	CreateVehicleEx(445,-1537.9399414063,420.5,7.2979998588562,180,61,61,6000);
	CreateVehicleEx(445,-1541.4630126953,420.5,7.2979998588562,180,61,61,6000);
	CreateVehicleEx(500,-1528.2779541016,400,7.2979998588562,0,61,61,6000);
	CreateVehicleEx(500,-1531.4709472656,400,7.2979998588562,0,61,61,6000);
	CreateVehicleEx(500,-1534.7590332031,400,7.2979998588562,0,61,61,6000);
	CreateVehicleEx(500,-1537.9399414063,400,7.2979998588562,0,61,61,6000);
	CreateVehicleEx(500,-1541.4630126953,400,7.2979998588562,0,61,61,6000);
	CreateVehicleEx(472,-1445,386.26800537109,0,270,61,61,6000);
	CreateVehicleEx(430,-1444,351.42098999023,0,270,61,61,6000);
	CreateVehicleEx(472,-1445,390.41799926758,0,270,61,61,6000);
	CreateVehicleEx(430,-1444,357.64898681641,0,270,61,61,6000);
	CreateVehicleEx(476,-1434.1259765625,499.90899658203,19.405000686646,0,61,61,6000);
	CreateVehicleEx(484,-1439.4439697266,430.13400268555,0,270,61,61,6000);
	CreateVehicleEx(595,-1444.2270507813,394.79699707031,0,270,61,61,6000);
	CreateVehicleEx(484,-1439.4439697266,423.49600219727,0,270,61,61,6000);
	VMFCar[1] = CreateVehicleEx(417,-1607.1240234375,286.28201293945,6.1820001602173,0,61,61,6000);
	// Ballas
	GangCar[0] = CreateVehicleEx(566,2457.3549805,-1344.0629883,23.8920002,48.9166260,85,85,1000); //Tahoma
	CreateVehicleEx(566,2457.4599609,-1339.7840576,23.8920002,48.4771729,85,85,1000); //Tahoma
	CreateVehicleEx(566,2457.5029297,-1335.5169678,23.8999996,48.4771729,85,85,1000); //Tahoma
	CreateVehicleEx(566,2457.3010254,-1331.2960205,23.8999996,48.4771729,85,85,1000); //Tahoma
	CreateVehicleEx(468,2480.4370117,-1353.5150146,27.2240009,60.0000000,85,85,1000); //Sanchez
	CreateVehicleEx(468,2480.4370117,-1351.5310059,27.1940002,59.9963379,85,85,1000); //Sanchez
	CreateVehicleEx(412,2457.5249023,-1359.6290283,23.9500008,47.1752930,85,85,1000); //Voodoo
	CreateVehicleEx(412,2457.5070801,-1355.5479736,23.9500008,47.1752930,85,85,1000); //Voodoo
	GangCar[1] = CreateVehicleEx(412,2457.4729004,-1363.9040527,23.9500008,47.1752930,85,85,1000); //Voodoo
	GangAmmoCar[0] = CreateVehicleEx(498,2456.8320,-1320.8734,23.9819,180.000000,85,85,10000);
	// Grove
	GangCar[2] = CreateVehicleEx(492,2491.4799805,-1680.9969482,13.2370005,358.7640381,86,86,1000); //Greenwood
	CreateVehicleEx(492,2500.4550781,-1680.1140137,13.2659998,9.3298340,86,86,1000); //Greenwood
	CreateVehicleEx(492,2488.3889160,-1680.9560547,13.2349997,358.7640381,86,86,1000); //Greenwood
	CreateVehicleEx(492,2496.9951172,-1680.5279541,13.2519999,9.3273926,86,86,1000); //Greenwood
	CreateVehicleEx(468,2499.4079590,-1686.5150146,13.2419996,39.9987793,86,86,1000); //Sanchez
	CreateVehicleEx(468,2498.0339355,-1686.7130127,13.2360001,39.9957275,86,86,1000); //Sanchez
	CreateVehicleEx(600,2485.1020508,-1681.1979980,13.1759996,358.7640381,86,86,1000); //Picador
	CreateVehicleEx(600,2481.8911133,-1681.1120605,13.1730003,358.7640381,86,86,1000); //Picador
	GangCar[3] = CreateVehicleEx(600,2479.0739746,-1681.0300293,13.1789999,358.7640381,86,86,1000); //Picador
	GangAmmoCar[1] = CreateVehicleEx(498,2505.3645,-1694.9377,13.6233,0.01000,86,86,10000);
	// Vagos
	GangCar[4] = CreateVehicleEx(467,2273.5419922,-1035.3189697,51.0149994,137.4993896,6,6,1000); //Oceanic
	CreateVehicleEx(467,2276.0729980,-1037.5140381,50.3339996,136.5325928,6,6,1000); //Oceanic
	CreateVehicleEx(467,2278.4628906,-1039.5980225,49.6969986,136.5325928,6,6,1000); //Oceanic
	CreateVehicleEx(467,2270.6740723,-1032.9389648,51.7630005,137.4993896,6,6,1000); //Oceanic
	CreateVehicleEx(468,2260.9008789,-1030.6450195,52.5439987,230.0000000,6,6,1000); //Sanchez
	CreateVehicleEx(468,2259.7219238,-1031.9899902,52.7890015,229.9987793,6,6,1000); //Sanchez
	CreateVehicleEx(474,2263.9489746,-1036.4150391,52.2630005,137.7905273,6,6,1000); //Hermes
	CreateVehicleEx(474,2266.2971191,-1038.3649902,51.6510010,137.7905273,6,6,1000); //Hermes
	GangCar[5] = CreateVehicleEx(474,2261.4790039,-1034.3730469,52.9570007,137.7905273,6,6,1000); //Hermes
	GangAmmoCar[2] = CreateVehicleEx(498,2271.0837,-1024.4092,53.1373,225.1190,6,6,10000);
	// Aztecas
	GangCar[6] = CreateVehicleEx(534,1702.1949463,-2107.3889160,13.3699999,269.9725342,2,2,1000); //Remington
	CreateVehicleEx(534,1694.6914062,-2107.2460938,13.1878996,269.9725342,2,2,1000); //Remington
	CreateVehicleEx(534,1686.5740000,-2107.3569000,13.1877000,270.9085000,2,2,1000); //Remington
	CreateVehicleEx(468,1664.3769531,-2107.8730469,13.3070002,210.0000000,2,2,1000); //Sanchez
	CreateVehicleEx(468,1662.9329834,-2107.8730469,13.3070002,209.9981689,2,2,1000); //Sanchez
	CreateVehicleEx(567,1684.2661000,-2119.3743000,13.4102000,318.1743000,2,2,1000); //Savanna
	CreateVehicleEx(567,1689.3480000,-2119.4617000,13.3995000,322.0142000,2,2,1000); //Savanna
	CreateVehicleEx(567,1694.1562500,-2119.5947266,13.3828001,325.5798340,2,2,1000); //Savanna
	GangCar[7] = CreateVehicleEx(567,1698.2709961,-2119.6970215,13.5249996,325.5798340,2,2,1000); //Savanna
	GangAmmoCar[3] = CreateVehicleEx(498,1666.8739,-2115.2034,13.6151,270.0373,2,2,10000);
	// Rifa
	GangCar[8] = CreateVehicleEx(529,2140.7958984,-1631.1009521,13.2939997,248.0000000,87,87,1000); //Willard
	CreateVehicleEx(529,2147.4289551,-1633.8149414,13.3129997,247.9948730,87,87,1000); //Willard
	CreateVehicleEx(529,2154.0778809,-1636.0489502,13.6389999,251.9948730,87,87,1000); //Willard
	CreateVehicleEx(529,2160.1030273,-1638.0310059,13.9329996,251.9948730,87,87,1000); //Willard
	CreateVehicleEx(468,2136.7749023,-1605.0839844,14.0070000,190.0000000,87,87,1000); //Sanchez
	CreateVehicleEx(468,2135.3249512,-1604.6180420,14.0019999,189.9975586,87,87,1000); //Sanchez
	CreateVehicleEx(518,2149.1970215,-1623.0739746,13.3570004,249.9938965,87,87,1000); //Buccaneer
	CreateVehicleEx(518,2142.5239258,-1620.2340088,13.1079998,249.9989014,87,87,1000); //Buccaneer
	GangCar[9] = CreateVehicleEx(518,2157.9790039,-1626.1280518,13.7410002,249.9938965,87,87,1000); //Buccaneer
	GangAmmoCar[4] = CreateVehicleEx(498,2166.7253,-1607.7760,14.4197,158.6395,87,87,10000);
	//
	gPDDoorButton[0] = CreateButton(1643.87, -1630.96, 1584.52, 0.0);
	gPDDoorButton[1] = CreateButton(1622.11, -1628.24, 1584.52, 90.0);
	gPDDoorButton[2] = CreateButton(1618.39, -1628.15, 1584.52,90.0);
	gPDDoors[0][0] = CreateDynamicObject(1495, 1642.08, -1630.95, 1582.80,   0.00, 0.00, 0.00,1,6);
	gPDDoors[1][0] = CreateDynamicObject(1495, 1622.06, -1629.98, 1582.80,   0.00, 0.00, 90.00,1,6);
	gPDDoors[2][0] = CreateDynamicObject(1495, 1618.50, -1629.97, 1582.80,   0.00, 0.00, 90.00,1,6);
	gPDDoors[3][0] = CreateDynamicObject(19302, 1614.30, -1630.91, 1584.11,   0.00, 0.00, 0.00,1,6);
	gPDDoors[4][0] = CreateDynamicObject(19302, 1610.29, -1629.28, 1584.11,   0.00, 0.00, -90.00,1,6);
	gPDDoors[5][0] = CreateDynamicObject(19302, 1614.30, -1627.51, 1584.11,   0.00, 0.00, -180.00,1,6);

	gPDDoors[0][1] = CreateDynamicObject(1495, 1642.08, -1630.95, 1582.80,   0.00, 0.00, 0.00,2,6);
	gPDDoors[1][1] = CreateDynamicObject(1495, 1622.06, -1629.98, 1582.80,   0.00, 0.00, 90.00,2,6);
	gPDDoors[2][1] = CreateDynamicObject(1495, 1618.50, -1629.97, 1582.80,   0.00, 0.00, 90.00,2,6);
	gPDDoors[3][1] = CreateDynamicObject(19302, 1614.30, -1630.91, 1584.11,   0.00, 0.00, 0.00,2,6);
	gPDDoors[4][1] = CreateDynamicObject(19302, 1610.29, -1629.28, 1584.11,   0.00, 0.00, -90.00,2,6);
	gPDDoors[5][1] = CreateDynamicObject(19302, 1614.30, -1627.51, 1584.11,   0.00, 0.00, -180.00,2,6);

	gPDDoors[0][2] = CreateDynamicObject(1495, 1642.08, -1630.95, 1582.80,   0.00, 0.00, 0.00,3,6);
	gPDDoors[1][2] = CreateDynamicObject(1495, 1622.06, -1629.98, 1582.80,   0.00, 0.00, 90.00,3,6);
	gPDDoors[2][2] = CreateDynamicObject(1495, 1618.50, -1629.97, 1582.80,   0.00, 0.00, 90.00,3,6);
	gPDDoors[3][2] = CreateDynamicObject(19302, 1614.30, -1630.91, 1584.11,   0.00, 0.00, 0.00,3,6);
	gPDDoors[4][2] = CreateDynamicObject(19302, 1610.29, -1629.28, 1584.11,   0.00, 0.00, -90.00,3,6);
	gPDDoors[5][2] = CreateDynamicObject(19302, 1614.30, -1627.51, 1584.11,   0.00, 0.00, -180.00,3,6);
	gPDDoorButton[3] = CreateButton(1615.46, -1630.84, 1584.49, 355.0); // cam1
	gPDDoorButton[4] = CreateButton(1610.34, -1630.48, 1584.49, 269.0); // cam2
	gPDDoorButton[5] = CreateButton(1612.80, -1627.67, 1584.49, 178.0); // cam3

	gPDCamArea[0] = CreateDynamicRectangle(1610.6860,-1633.6836,1615.8539,-1631.3563,-1,6);
	gPDCamArea[1] = CreateDynamicRectangle(1607.6161,-1632.9540,1609.8140,-1628.0160,-1,6);
	gPDCamArea[2] = CreateDynamicRectangle(1610.6862,-1627.1437,1615.8534,-1624.8464,-1,6);
	// MEDICS
	ambucile[0] = CreateVehicleEx(416,1130.7219,-1367.3760,13.8391,89.1575,1,3,6000);
	CreateVehicleEx(416,1130.7247,-1362.4501,13.8403,90.5229,1,3,6000);
	CreateVehicleEx(416,1130.7433,-1357.3695,13.8402,89.8687,1,3,6000);
	CreateVehicleEx(416,1130.7727,-1352.3392,13.8402,90.9424,1,3,6000);
	CreateVehicleEx(416,1130.7495,-1347.2850,13.8398,90.0173,1,3,6000);
	CreateVehicleEx(563,1163.2800293,-1351.3680420,27.5730000,270.0000000,1,3,6000); //Raindance
	CreateVehicleEx(487,1161.3819580,-1366.0489502,26.9139996,270.0000000,1,3,6000); //Maverick
	ambucile[1] = CreateVehicleEx(416,1130.6416,-1342.2468,13.8403,90.3495,1,3,6000);
	// MERIA
	mercar[0] = CreateVehicleEx(490,1502.8759766,-1337.9350586,14.0000000,270.0000000,1,1,1000); //FBI Rancher
	CreateVehicleEx(490,1502.8759766,-1334.0312500,14.0000000,270.0000000,1,1,1000); //FBI Rancher
	CreateVehicleEx(421,1502.7889404,-1330.4780273,14.0000000,270.0000000,1,1,1000); //Washington
	CreateVehicleEx(421,1502.7889404,-1327.4520264,14.0000000,270.0000000,1,1,1000); //Washington
	CreateVehicleEx(421,1502.7889404,-1324.1070557,14.0000000,270.0000000,1,1,1000); //Washington
	CreateVehicleEx(487,1494.3439941406,-1385.1879882813,23.882,270.0000000,1,0,1000);
	CreateVehicleEx(487,1494.1469726563,-1368.0789794922,23.882,270.0000000,1,0,1000);
	mercar[1] = CreateVehicleEx(409,1501.8420410,-1318.0749512,14.0000000,0.0000000,1,1,1000); //Stretch
	// Fuel
	fuelcar[0] = CreateVehicleEx(583,285.5172,1394.7618,10.1267,92.0947,1,1,6000); //
	CreateVehicleEx(583,285.6495,1391.8717,10.1305,92.1380,1,1,6000); //
	CreateVehicleEx(583,285.7787,1388.7703,10.1264,92.2174,1,1,6000); //
	CreateVehicleEx(583,285.9521,1385.6863,10.1264,94.4238,1,1,6000); //
	CreateVehicleEx(583,286.1293,1382.5796,10.1265,94.0490,1,1,6000); //
	CreateVehicleEx(583,286.2761,1379.4426,10.1264,92.8482,1,1,6000); //
	CreateVehicleEx(583,286.3885,1376.5985,10.1264,92.0819,1,1,6000); //
	CreateVehicleEx(403,283.5932,1366.8313,11.1921,89.7761,2,2,6000); //
	CreateVehicleEx(403,283.7147,1362.2080,11.1926,89.5164,2,2,6000); //
	CreateVehicleEx(403,283.6336,1357.1893,11.2216,89.7186,2,2,6000); //
	CreateVehicleEx(403,283.5963,1352.5117,11.1817,89.7769,2,2,6000); //
	CreateVehicleEx(403,283.6777,1347.7845,11.1648,89.7439,2,2,6000); //
	CreateVehicleEx(403,283.5008,1342.9812,11.1682,89.0126,2,2,6000); //
	CreateVehicleEx(584,281.5816,1442.2512,11.6653,90.5705,1,1,6000); //
	CreateVehicleEx(584,281.5816,1446.2512,11.6653,90.5705,1,1,6000); //
	CreateVehicleEx(584,281.5816,1450.2512,11.6653,90.5705,1,1,6000); //
	CreateVehicleEx(584,281.5816,1454.2512,11.6653,90.5705,1,1,6000); //
	CreateVehicleEx(584,281.5816,1458.2512,11.6653,90.5705,1,1,6000); //
	CreateVehicleEx(584,281.5816,1462.2512,11.6653,90.5705,1,1,6000); //
	CreateVehicleEx(584,281.5816,1466.2512,11.6653,90.5705,1,1,6000); //
	CreateVehicleEx(584,281.5816,1470.2512,11.6653,90.5705,1,1,6000); //
	fuelcar[1] = CreateVehicleEx(583,286.5170,1373.5460,10.1264,92.8148,1,1,6000); //
	// Product
	jobproduct[0] = CreateVehicleEx(456,2786.5605,-2417.7188,13.8075,91.2355,-1,-1,60);
	CreateVehicleEx(456,2788.2126,-2494.3130,13.8072,91.2355,-1,-1,60);
	CreateVehicleEx(440,2737.9542,-2388.6167,13.7532,179.9226,-1,-1,60);
	CreateVehicleEx(440,2741.5295,-2388.6218,13.7531,179.9226,-1,-1,60);
	CreateVehicleEx(440,2745.1663,-2388.6270,13.7531,179.9226,-1,-1,60);
	CreateVehicleEx(440,2748.7155,-2388.6328,13.7531,179.9226,-1,-1,60);
	CreateVehicleEx(440,2746.6423,-2462.8911,13.7525,272.3864,-1,-1,60);
	CreateVehicleEx(440,2746.7739,-2466.1138,13.7879,272.3806,-1,-1,60);
	CreateVehicleEx(440,2752.3909,-2388.6169,13.7603,179.6397,-1,-1,60);
	CreateVehicleEx(440,2746.5908,-2459.5146,13.7636,270.5418,-1,-1,60);
	CreateVehicleEx(440,2746.7878,-2447.9821,13.7620,268.9051,-1,-1,60);
	CreateVehicleEx(440,2746.8450,-2444.7056,13.7622,268.9051,-1,-1,60);
	CreateVehicleEx(440,2746.8850,-2441.3806,13.7623,268.9051,-1,-1,60);
	jobproduct[1] = CreateVehicleEx(440,2746.9553,-2469.3800,13.7879,272.3806,-1,-1,60);
	// SAN
	sancar[0] = CreateVehicleEx(582,1666.2640380859,-1693.5739746094,15.764,90.0000000,1,3,1000); //Newsvan
	CreateVehicleEx(582,1666.2640380859,-1697.6639404297,15.764,90.0000000,1,3,1000); //Newsvan
	CreateVehicleEx(582,1666.2640380859,-1711.7419433594,15.764,90.0000000,1,3,1000); //Newsvan
	CreateVehicleEx(582,1666.2640380859,-1716.3389892578,15.764,90.0000000,1,3,1000); //Newsvan
	CreateVehicleEx(582,1666.2640380859,-1702.0460205078,15.764,90.0000000,1,3,1000); //Newsvan
	sancar[1] = CreateVehicleEx(582,1666.2640380859,-1706.9489746094,15.764,90.0000000,1,3,1000); //Newsvan
	// Mechanics
	mechanics[0] = CreateVehicleEx(525,1560.0000000,-2338.4309082,13.5369997,90.0000000,1,0,5015); //Tow Truck
	mechanics[1] = CreateVehicleEx(525,1560.0000000,-2335.2050781,13.5369997,90.0000000,1,0,5015); //Tow Truck
	mechanics[2] = CreateVehicleEx(525,1560.0000000,-2331.8869629,13.5369997,90.0000000,1,0,5015); //Tow Truck
	mechanics[3] = CreateVehicleEx(525,1560.0000000,-2321.9899902,13.5369997,90.0000000,1,0,5015); //Tow Truck
	mechanics[4] = CreateVehicleEx(525,1560.0000000,-2325.2280273,13.5369997,90.0000000,1,0,5015); //Tow Truck
	mechanics[5] = CreateVehicleEx(525,1560.0000000,-2328.3720703,13.5369997,90.0000000,1,0,5015); //Tow Truck
	mechanics[6] = CreateVehicleEx(525,1560.0000000,-2318.7670898,13.5349998,90.0000000,1,0,5015); //Tow Truck
	mechanics[7] = CreateVehicleEx(525,1560.0000000,-2315.4890137,13.5349998,90.0000000,1,0,5015); //Tow Truck
	mechanics[8] = CreateVehicleEx(525,1560.0000000,-2312.3259277,13.5349998,90.0000000,1,0,5015); //Tow Truck
	mechanics[9] = CreateVehicleEx(525,1560.0000000,-2309.1459961,13.5349998,90.0000000,1,0,5015); //Tow Truck
	// Рыболов
	fishcar[0] = CreateVehicleEx(453,343.7179871,-1919.3580322,0.0000000,270.0000000,-1,-1,000); //Reefer
	CreateVehicleEx(453,343.7179871,-1913.2659912,0.0000000,270.0000000,-1,-1,9000); //Reefer
	CreateVehicleEx(453,343.7179871,-1907.5140381,0.0000000,270.0000000,-1,-1,9000); //Reefer
	CreateVehicleEx(453,330.0000000,-1919.3580322,0.0000000,90.0000000,-1,-1,9000); //Reefer
	CreateVehicleEx(453,330.0000000,-1913.2659912,0.0000000,90.0000000,-1,-1,9000); //Reefer
	fishcar[1] = CreateVehicleEx(453,330.0000000,-1907.5140381,0.0000000,90.0000000,-1,-1,9000); //Reefer
	// FBI
	fbicar[0] = CreateVehicleEx(497,966.9349976,-1528.6099854,13.8310003,220.0000000,0,0,1000); //Police Maverick
	CreateVehicleEx(490,980.4780273,-1523.6970215,13.8760004,209.9957275,0,0,1000); //FBI Rancher
	CreateVehicleEx(490,976.4349976,-1523.6970215,13.8760004,209.9957275,0,0,1000); //FBI Rancher
	CreateVehicleEx(490,972.1599731,-1523.6970215,13.8769999,209.9957275,0,0,1000); //FBI Rancher
	CreateVehicleEx(426,994.5629883,-1523.5150146,13.3760004,180.0000000,0,0,1000); //Premier
	CreateVehicleEx(426,990.8060303,-1523.4730225,13.3760004,180.0000000,0,0,1000); //Premier
	CreateVehicleEx(426,987.3564453,-1523.2480469,13.3750000,180.0000000,0,0,1000); //Premier
	CreateVehicleEx(521,984.2849731,-1521.9160156,13.2130003,210.0000000,0,0,1000); //FCR-900
	fbicar[1] = CreateVehicleEx(521,982.5219727,-1521.9160156,13.2130003,210.0000000,0,0,1000); //FCR-900
	// Автошкола
	schoolcar[0] = CreateVehicleEx(405,1281.5500488,-1362.9799805,13.4565182,58.0000000,1,1,815); //Sentinel
	CreateVehicleEx(405,1281.5500488,-1359.2619629,13.4705181,57.9968262,1,1,815); //Sentinel
	CreateVehicleEx(405,1281.5500488,-1355.6190186,13.4915180,57.9968262,1,1,815); //Sentinel
	CreateVehicleEx(405,1281.5500488,-1351.8590088,13.5005178,57.9968262,1,1,815); //Sentinel
	schoolcar[1] = CreateVehicleEx(405,1281.5500488,-1347.8239746,13.5005178,57.9968262,1,1,815); //Sentinel
	// Автошкола
	liccar[0] = CreateVehicleEx(426,1281.3000488,-1295.7769775,13.1730003,122.0000000,-1,1,815); //Premier
	liccar[1] = CreateVehicleEx(426,1281.3000488,-1299.6149902,13.1770000,121.9976807,-1,1,815); //Premier
	liccar[2] = CreateVehicleEx(426,1281.3000488,-1303.6159668,13.1949997,121.9976807,-1,1,815); //Premier
	liccar[3] = CreateVehicleEx(426,1281.3000488,-1307.5059814,13.1960001,121.9976807,-1,1,815); //Premier
	liccar[4] = CreateVehicleEx(426,1281.3000488,-1319.2989502,13.1980000,121.9976807,-1,1,815); //Premier
	liccar[5] = CreateVehicleEx(426,1281.3000488,-1315.3229980,13.1969995,121.9976807,-1,1,815); //Premier
	liccar[6] = CreateVehicleEx(426,1281.3000488,-1311.5880127,13.1960001,121.9976807,-1,1,815); //Premier
	return 1;
}
stock SetPlayerNickName(playerid, nick[]) {
	qurey = "";
	format(qurey, sizeof(qurey), "UPDATE `"TABLE_ACCOUNT"` SET `Name`='%s' WHERE `Name`='%s'", nick, NamePlayer(playerid));
	mysql_function_query(cHandle, qurey, false, "", "");
	format(qurey, sizeof(qurey), "UPDATE `"TABLE_HOUSE"` SET `hOwner`='%s' WHERE `hOwner`='%s'", nick, NamePlayer(playerid));
	mysql_function_query(cHandle, qurey, false, "", "");
	format(qurey, sizeof(qurey), "UPDATE `"TABLE_BIZZ"` SET `owner`='%s' WHERE `owner`='%s'", nick, NamePlayer(playerid));
	mysql_function_query(cHandle, qurey, false, "", "");
	format(qurey, sizeof(qurey), "UPDATE `"TABLE_CARS"` SET `owner`='%s' WHERE `owner`='%s'", nick, NamePlayer(playerid));
	mysql_function_query(cHandle, qurey, false, "", "");
	format(qurey, sizeof(qurey), "UPDATE `"TABLE_PARK"` SET `owner`='%s' WHERE `owner`='%s'", nick, NamePlayer(playerid));
	mysql_function_query(cHandle, qurey, false, "", "");
	SetPlayerName(playerid, nick);
}
stock SetHouseInt(idx, stolb[], znach) {
	qurey = "";
	format(qurey, sizeof(qurey), "UPDATE "TABLE_HOUSE" SET  %s = '%d' WHERE id = '%d'", stolb, znach, idx);
	return mysql_function_query(cHandle, qurey, false, "", "");
}
stock SetHouseStr(idx, stolb[], znach[]) {
	qurey = "";
	format(qurey, sizeof(qurey), "UPDATE "TABLE_HOUSE" SET  %s = '%s' WHERE id = '%d'", stolb, znach, idx);
	return mysql_function_query(cHandle, qurey, false, "", "");
}
stock SetCarsInt(idx, stolb[], znach) {
	qurey = "";
	format(qurey, sizeof(qurey), "UPDATE `"TABLE_CARS"` SET `%s` = '%d' WHERE `id` = '%d' LIMIT 1", stolb, znach, idx);
	return mysql_function_query(cHandle, qurey, false, "", "");
}

stock SetBizzInt(idx, stolb[], znach) {
	qurey = "";
	format(qurey, sizeof(qurey), "UPDATE "TABLE_BIZZ" SET  %s = '%d' WHERE id = '%d' LIMIT 1", stolb, znach, idx);
	return mysql_function_query(cHandle, qurey, false, "", "");
}
stock SetOtherInt(stolb[], znach) {
	format(qurey, sizeof(qurey), "UPDATE "TABLE_WAREHOUSE" SET  %s = '%d'", stolb, znach);
	return mysql_function_query(cHandle, query, false, "", "");
}
stock SetOtherStr(stolb[], znach[]) {
	qurey = "";
	format(qurey, sizeof(qurey), "UPDATE "TABLE_WAREHOUSE" SET  %s = '%s'", stolb, znach);
	return mysql_function_query(cHandle, qurey, false, "", "");
}
stock SetParkInt(idx, stolb[], znach) {
	qurey = "";
	format(qurey, sizeof(qurey), "UPDATE "TABLE_PARK" SET  %s = '%d' WHERE id = '%d' LIMIT 1", stolb, znach, idx);
	return mysql_function_query(cHandle, qurey, false, "", "");
}
stock TimeConverter(seconds)//Конвертер секунды в минуты и секунды
{
	new minutes = floatround(seconds/60);//кол. целых минут
	seconds -= minutes*60;  //остаток
	strin = "";
	format(strin, sizeof(strin), "%02d:%02d", minutes, seconds);//преобразовываем
	return strin;//возвращаем строку символов
}

stock SaveWarehouse() {
	query = "";
	format(query,sizeof(query),"UPDATE `warehouse` SET `SV_Mats` = '%d', `VMF_Mats` = '%d', `G_Metal` = '%d', `B_Metal` = %d, `A_Metal` = %d, `V_Metal` = %d, `R_Metal` = %d",
	ArmyMats[0],ArmyMats[1],Metal[6],Metal[7],Metal[8],Metal[9],Metal[10]);
	mysql_query(query, -1, -1, cHandle);
	//
	query = "";
	format(query,sizeof(query),"UPDATE `warehouse` SET `G_Mats` = '%d', `B_Mats` = '%d', `A_Mats` = %d, `V_Mats` = %d, `R_Mats` = %d",Mats[6],Mats[7],Mats[8],Mats[9],Mats[10]);
	mysql_query(query, -1, -1, cHandle);
	//
	query = "";
	format(query,sizeof(query),"UPDATE `warehouse` SET `G_Drugs` = '%d', `B_Drugs` = '%d', `A_Drugs` = %d, `V_Drugs` = %d, `R_Drugs` = %d",Drugs[6],Drugs[7],Drugs[8],Drugs[9],Drugs[10]);
	mysql_query(query, -1, -1, cHandle);
}
stock SaveGZ(idx) {
	query = "";
	format(query, sizeof(query), "UPDATE `"TABLE_GANGZONE"` SET fraction = %i WHERE id = %i",GZInfo[idx][gFrak], idx);
	mysql_function_query(cHandle, query, false, "", "");
	return 1;
}

stock GetGangZoneColor(gangzonex) {
	new zx;
	switch(GZInfo[gangzonex][gFrak]) {
	case 6: zx = 0x00FF1465; // Grove
	case 7: zx = 0xFF00EB65; // Ballas
	case 8: zx = 0x00EBFF65; // Aztecas
	case 9: zx = 0xFFC80065; // Vagos
	case 10: zx = 0x007fffAA; // Rifa
	default: zx = 0xFFBE0065; // ALL
	}
	return zx;
}

stock SetPlayerTeamColor(playerid) {
	switch(PI[playerid][pMember]) {
	case 1: return SetPlayerColor(playerid,0xCCFF0022);
	case 2: return SetPlayerColor(playerid,0x004eff22);
	case 3: return SetPlayerColor(playerid,0xFF660022);
	case 4: return SetPlayerColor(playerid,0x66330022);
	case 5: return SetPlayerColor(playerid,0x0FF33322);
	case 6: return SetPlayerColor(playerid,0x33993322);//grove
	case 7: return SetPlayerColor(playerid,0xCC009922);//ballas
	case 8: return SetPlayerColor(playerid,0x66FFFF22);//aztec
	case 9: return SetPlayerColor(playerid,0xFFFF0022);//vagos
	case 10: return SetPlayerColor(playerid,0x139BECFF);//rifa 0x110CE7FF
	case 11: return SetPlayerColor(playerid,0x313131AA);//fbi
	case 12: return SetPlayerColor(playerid,0x139BECFF);//licensers
	case 13: return SetPlayerColor(playerid,0x66330022);//armylv
	case 14: return SetPlayerColor(playerid,0x004eff22);//sfpd
	case 15: return SetPlayerColor(playerid,0x004eff22);//lvpd
	default: SetPlayerColor(playerid, 0xFFFFFF22);
	}
	return true;
}


stock UpdateWarehouse() {
	new GZGANG[5];
	for(new i = 1; i <= TOTALGZ; i++) {
		if(GZInfo[i][gFrak] == 6) GZGANG[0]++;
		if(GZInfo[i][gFrak] == 7) GZGANG[1]++;
		if(GZInfo[i][gFrak] == 8) GZGANG[2]++;
		if(GZInfo[i][gFrak] == 9) GZGANG[3]++;
		if(GZInfo[i][gFrak] == 10) GZGANG[4]++;
	}
	qurey = "";
	format(qurey, 244, "{ffffff}Количество\nтерриторий: {95e200}%d{219c00}\n\n\nСклад\n%s\n\n{ffffff}Наркотики: {e2ba00}%d из 20000 г\n{ffffff}Патроны: {e2ba00}%d из 50000 шт\n{ffffff}Металл: {e2ba00}%d из 3000 кг",GZGANG[0],Fraction[5],Drugs[6],Mats[6],Metal[6]);
	Update3DTextLabelText(WareHouse[0], COLOR_YELLOW, qurey);
	qurey = "";
	format(qurey, 244, "{ffffff}Количество\nтерриторий: {95e200}%d{aa2098}\n\n\nСклад\n%s\n\n{ffffff}Наркотики: {e2ba00}%d из 20000 г\n{ffffff}Патроны: {e2ba00}%d из 50000 шт\n{ffffff}Металл: {e2ba00}%d из 3000 кг",GZGANG[1],Fraction[6],Drugs[7],Mats[7],Metal[7]);
	Update3DTextLabelText(WareHouse[1], COLOR_YELLOW, qurey);
	qurey = "";
	format(qurey, 244, "{ffffff}Количество\nтерриторий: {95e200}%d{27c1bf}\n\n\nСклад\n%s\n\n{ffffff}Наркотики: {e2ba00}%d из 20000 г\n{ffffff}Патроны: {e2ba00}%d из 50000 шт\n{ffffff}Металл: {e2ba00}%d из 3000 кг",GZGANG[2],Fraction[7],Drugs[8],Mats[8],Metal[8]);
	Update3DTextLabelText(WareHouse[2], COLOR_YELLOW, qurey);
	qurey = "";
	format(qurey, 244, "{ffffff}Количество\nтерриторий: {95e200}%d{cebb39}\n\n\nСклад\n%s\n\n{ffffff}Наркотики: {e2ba00}%d из 20000 г\n{ffffff}Патроны: {e2ba00}%d из 50000 шт\n{ffffff}Металл: {e2ba00}%d из 3000 кг",GZGANG[3],Fraction[8],Drugs[9],Mats[9],Metal[9]);
	Update3DTextLabelText(WareHouse[3], COLOR_YELLOW, qurey);
	qurey = "";
	format(qurey, 244, "{ffffff}Количество\nтерриторий: {95e200}%d{cebb39}\n\n\nСклад\n%s\n\n{ffffff}Наркотики: {e2ba00}%d из 20000 г\n{ffffff}Патроны: {e2ba00}%d из 50000 шт\n{ffffff}Металл: {e2ba00}%d из 3000 кг",GZGANG[4],Fraction[9],Drugs[10],Mats[10],Metal[10]);
	Update3DTextLabelText(WareHouse[11], COLOR_YELLOW, qurey);
	qurey = "";
	format(qurey, 124, "{72c100}<< Патронов на складе >>\n{e2ba00}%d из 50000 шт",ArmyMats[0]);
	Update3DTextLabelText(WareHouse[4], COLOR_YELLOW, qurey);
	qurey = "";
	format(qurey, 124, "{72c100}<< Патронов на складе >>\n{e2ba00}%d из 50000 шт",ArmyMats[1]);
	Update3DTextLabelText(WareHouse[5], COLOR_YELLOW, qurey);
	qurey = "";
	format(qurey, 124, "{72c100}<< Патронов на складе >>\n{e2ba00}%d из 50000 шт",ArmyMats[0]);
	Update3DTextLabelText(WareHouse[6], COLOR_YELLOW, qurey);
	return 1;
}


stock LoadWarehouse() {
	new GZGANG[5];
	for(new i = 1; i <= TOTALGZ; i++) {
		if(GZInfo[i][gFrak] == 6) GZGANG[0]++;
		if(GZInfo[i][gFrak] == 7) GZGANG[1]++;
		if(GZInfo[i][gFrak] == 8) GZGANG[2]++;
		if(GZInfo[i][gFrak] == 9) GZGANG[3]++;
		if(GZInfo[i][gFrak] == 10) GZGANG[4]++;
	}
	qurey = "";
	format(qurey, 244, "{ffffff}Количество\nтерриторий: {95e200}%d{219c00}\n\n\nСклад\n%s\n\n{ffffff}Наркотики: {e2ba00}%d из 20000 г\n{ffffff}Патроны: {e2ba00}%d из 50000 шт\n{ffffff}Металл: {e2ba00}%d из 3000 кг",GZGANG[0],Fraction[5],Drugs[6],Mats[6],Metal[6]);
	WareHouse[0] = Create3DTextLabel(qurey,COLOR_YELLOW,2501.8079,-1716.3955,1154.5859,8.0,1,5);

	qurey = "";
	format(qurey, 244, "{ffffff}Количество\nтерриторий: {95e200}%d{aa2098}\n\n\nСклад\n%s\n\n{ffffff}Наркотики: {e2ba00}%d из 20000 г\n{ffffff}Патроны: {e2ba00}%d из 50000 шт\n{ffffff}Металл: {e2ba00}%d из 3000 кг",GZGANG[1],Fraction[6],Drugs[7],Mats[7],Metal[7]);
	WareHouse[1] = Create3DTextLabel(qurey,COLOR_YELLOW,2049.2117,-1157.0398,1147.6160,8.0,2,5);

	qurey = "";
	format(qurey, 244, "{ffffff}Количество\nтерриторий: {95e200}%d{27c1bf}\n\n\nСклад\n%s\n\n{ffffff}Наркотики: {e2ba00}%d из 20000 г\n{ffffff}Патроны: {e2ba00}%d из 50000 шт\n{ffffff}Металл: {e2ba00}%d из 3000 кг",GZGANG[2],Fraction[7],Drugs[8],Mats[8],Metal[8]);
	WareHouse[2] = Create3DTextLabel(qurey,COLOR_YELLOW,1857.3606,-2056.3352,1049.3259,8.0,3,5);

	qurey = "";
	format(qurey, 244, "{ffffff}Количество\nтерриторий: {95e200}%d{cebb39}\n\n\nСклад\n%s\n\n{ffffff}Наркотики: {e2ba00}%d из 20000 г\n{ffffff}Патроны: {e2ba00}%d из 50000 шт\n{ffffff}Металл: {e2ba00}%d из 3000 кг",GZGANG[3],Fraction[8],Drugs[9],Mats[9],Metal[9]);
	WareHouse[3] = Create3DTextLabel(qurey,COLOR_YELLOW,2422.6169,-1075.6224,1047.8049,8.0,4,5);

	qurey = "";
	format(qurey, 244, "{ffffff}Количество\nтерриторий: {95e200}%d{cebb39}\n\n\nСклад\n%s\n\n{ffffff}Наркотики: {e2ba00}%d из 20000 г\n{ffffff}Патроны: {e2ba00}%d из 50000 шт\n{ffffff}Металл: {e2ba00}%d из 3000 кг",GZGANG[4],Fraction[9],Drugs[10],Mats[10],Metal[10]);
	WareHouse[11] = Create3DTextLabel(qurey,COLOR_YELLOW,2492.6770,-1549.6503,1519.9659,8.0,5,5);

	qurey = "";
	format(qurey, 124, "{72c100}<< Патронов на складе >>\n{e2ba00}%d из 50000 шт",ArmyMats[0]);
	WareHouse[4] = Create3DTextLabel(qurey,COLOR_YELLOW,-1384.3207,809.8448,1550.0859+1,8.0,2,10);

	qurey = "";
	format(qurey, 124, "{72c100}<< Патронов на складе >>\n{e2ba00}%d из 50000 шт",ArmyMats[1]);
	WareHouse[5] = Create3DTextLabel(qurey,COLOR_YELLOW,-1521.9741,480.8362,7.1875,10.0,0,0);

	qurey = "";
	format(qurey, 124, "{72c100}<< Патронов на складе >>\n{e2ba00}%d из 50000 шт",ArmyMats[0]);
	WareHouse[6] = Create3DTextLabel(qurey,COLOR_YELLOW,320.6225,1979.2566,1117.6406-5,10.0,0,0);//17.6406-5,10.0,0,0);

	qurey = "";
	format(qurey, 125, "{ffffff}Мешков: {e2ba00}%d из 500",TOTALGRUZ);
	GruzText[0] = Create3DTextLabel(qurey,COLOR_YELLOW,2042.6589,-1958.3080,14.3957,8.0,0,0);
	return 1;
}

stock PlayerToKvadrat(playerid,Float:min_x,Float:min_y,Float:max_x,Float:max_y) {
	GetPlayerPos(playerid, PI[playerid][pPos][0],PI[playerid][pPos][1],PI[playerid][pPos][2]);
	if((PI[playerid][pPos][0] <= max_x && PI[playerid][pPos][0] >= min_x) && (PI[playerid][pPos][1] <= max_y && PI[playerid][pPos][1] >= min_y)) return 1;
	return 0;
}

stock IsPlayerInRangeOfPlayer(Float:radi, playerid, targetid) {
	if(PlayerLogged[playerid] && PlayerLogged[targetid]) {
		GetPlayerPos(targetid, PI[targetid][pPos][0],PI[targetid][pPos][1],PI[targetid][pPos][2]);
		if(IsPlayerInRangeOfPoint(playerid, radi, PI[targetid][pPos][0],PI[targetid][pPos][1],PI[targetid][pPos][2])) return 1;
	}
	return 0;
}
stock Convert(seconds, stringTo[], size = sizeof(stringTo)) {
	stringTo[0] = 0x0;
	new result[4];
	result[0] = floatround(seconds / (3600 * 24));
	result[1] = floatround(seconds / 3600);
	result[2] = floatround((seconds / 60) - (result[1] * 60));
	result[3] = floatround(seconds - ((result[1] * 3600) + (result[2] * 60)));
	switch(result[0]) {
	case 0: {
			switch(result[1]) {
			case 0:
				format(stringTo,size,"%02d:%02d",result[2],result[3]);
			default:
				format(stringTo,size,"%d:%02d:%02d",result[1],result[2],result[3]);
			}
		}
	}
	return stringTo;
}
stock LoadMyCar(playerid,carnid=0) {
	if(GetPlayerCars(playerid) == 0) return 1;
	new c = PI[playerid][pCars][carnid];
	if(c < 1 || c > 2000) return 1;
	new carid = CarInfo[c][cID];
	if(carid < 1 || carid > 2000) return 1;
	Fuel[carid] = CarInfo[c][cFuel];
	strin = "";
	format(strin,32,"{000000}%d-%c II SA",c,CarInfo[c][cOwner][0]);
	SetVehicleNumberPlate(carid, strin);
	Iter_Add(MAX_CARS,carid);
	if(PI[playerid][pNitro] == 1009 || PI[playerid][pNitro] == 1008 || PI[playerid][pNitro] == 1010) AC_AddVehicleComponent(carid,PI[playerid][pNitro]);
	if(PI[playerid][pWheels] != 0) AC_AddVehicleComponent(carid,PI[playerid][pWheels]);
	if(PI[playerid][pHBumper] != 0) AC_AddVehicleComponent(carid,PI[playerid][pHBumper]);
	if(PI[playerid][pBBumper] != 0) AC_AddVehicleComponent(carid,PI[playerid][pBBumper]);
	if(PI[playerid][pSpoilers] != 0) AC_AddVehicleComponent(carid,PI[playerid][pSpoilers]);
	if(PI[playerid][pHydraulics] != 0) AC_AddVehicleComponent(carid,PI[playerid][pHydraulics]);
	if(PI[playerid][pNeons] != 0) {
		NeonObject[playerid][0] = CreateDynamicObject(PI[playerid][pNeons],0,0,0,0,0,0,-1,-1,-1,150.0);
		AttachDynamicObjectToVehicle(NeonObject[playerid][0], carid, -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
		NeonObject[playerid][1] = CreateDynamicObject(PI[playerid][pNeons],0,0,0,0,0,0,-1,-1,-1,150.0);
		AttachDynamicObjectToVehicle(NeonObject[playerid][1], carid, 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
	}
	return true;
}
stock GetPlayerCar(playerid,number) {
	new car = 0;
	for(new i = 1; i <= TOTALCARS;i++) {
		if(!strcmp(CarInfo[i][cOwner],NamePlayer(playerid),true)) {
			PI[playerid][pCars][car] = i;
			car++;
		}
	}
	return PI[playerid][pCars][number];
}

stock GetPlayerCars(playerid) {
	new car = 0;
	for(new i = 1; i <= TOTALCARS;i++) {
		if(!strcmp(CarInfo[i][cOwner],NamePlayer(playerid),true)) PI[playerid][pCars][car] = i,car++;
	}
	return car;
}
stock CarDoors(vehicleid, status) {
	if(vehicleid==INVALID_VEHICLE_ID)return 0;
	new eengine, elights, ealarm, edoors, ebonnet, eboot, eobjective;
	GetVehicleParamsEx(vehicleid, eengine, elights, ealarm, edoors, ebonnet, eboot, eobjective);
	SetVehicleParamsEx(vehicleid, eengine, elights, ealarm, status, ebonnet, eboot, eobjective);
	return 1;
}

stock ParkStats(playerid, idx) {
	strin = "";
	format(strin, 512, "{ffffff}Бизнес:\t\t\t{cccccc}%s{ffffff}\n\nВладелец:\t\t\t{c6dd00}%s{ffffff}\nНа счету:\t\t\t{63de00}%d${ffffff}\n\nРаботают:\t\t\t{c6dd00}%d чел{ffffff}\nАвтомобилей:\t\t{c6dd00}%d",BizzPark[idx][tName], BizzPark[idx][tOwner], BizzPark[idx][tBank], GetPlayersJob(), GetCarsPark(idx));
	SPD(playerid, 0, 0, BizzPark[idx][tName], strin, "Закрыть", "");
	return 1;
}
stock BizzStats(playerid, idx) {
	strin = "";
	if(BizzInfo[idx][bType] != 2) {
		format(strin, 512, "{ffffff}Бизнес:\t\t\t%s\n\nНа счету бизнеса:\t\t%i$\nВсего заработано:\t\t%i$\nВ этом часу заработано:\t%i$\nЦена за товар:\t\t%i%\n\nПродуктов:\t\t\t%i / 20000\n\nСтатус:\t\t\t\t%s\nЛицензия на бизнес:\t\t%s",
		BizzInfo[idx][bName], BizzInfo[idx][bBank], BizzInfo[idx][bMoney], BizzPay[idx], BizzInfo[idx][bTill], BizzInfo[idx][bProduct]
		,(!BizzInfo[idx][bLock])?("Открыт") : ("Закрыт"),(!BizzInfo[idx][bLic])?("Нет"):("Да"));
	}
	else
	{
		format(strin, 512, "{ffffff}Бизнес:\t\t\t%s\n\nНа счету бизнеса:\t\t%i$\nВсего заработано:\t\t%i$\nВ этом часу заработано:\t%i$\nЦена за 1 литр:\t\t%i$\n\nТоплива:\t\t\t%i / 50000\n\nСтатус:\t\t\t\t%s\nЛицензия на бизнес:\t\t%s",
		BizzInfo[idx][bName], BizzInfo[idx][bBank], BizzInfo[idx][bMoney], BizzPay[idx], BizzInfo[idx][bTill] / 3, BizzInfo[idx][bProduct]
		,(!BizzInfo[idx][bLock])?("Открыт") : ("Закрыт"),(!BizzInfo[idx][bLic])?("Нет"):("Да"));
	}
	SPD(playerid, 0, 0, "Статистика бизнеса", strin, "Закрыть", "");
	return 1;
}

stock MagazineList(playerid, idx) {
	SetPVarInt(playerid, "PlayerBizzz", idx);
	if(BizzInfo[idx][bProduct] < 50) return SendClientMessage(playerid, COLOR_GREY, "В бизнесе нет продуктов!");
	strin = "";
	format(strin, 512, "1. Телефон\t\t\t%i$\n2. Номер телефона\t\t%i$\n3. Телефонная книга\t\t%i$\n4. Веревка\t\t\t%i$\n5. Маска\t\t\t%i$\n6. Парашют\t\t\t%i$\n7. Фотоаппарат\t\t\t%i$\n8. Цветы\t\t\t%i$\n9. Аптечка\t\t\t%i$\n10. Лотерейный билет\t\t%i$\n11. Пачка сигарет\t\t%i$",
	BizzInfo[idx][bTill]*14, BizzInfo[idx][bTill]*3, BizzInfo[idx][bTill]*5, BizzInfo[idx][bTill]*4,  BizzInfo[idx][bTill]*5,  BizzInfo[idx][bTill]*7,  BizzInfo[idx][bTill]*10,  BizzInfo[idx][bTill]*4,  BizzInfo[idx][bTill]*3,  BizzInfo[idx][bTill]*2,  BizzInfo[idx][bTill]*6);
	SPD(playerid, 30, 2, "Магазин 24/7", strin, "Принять", "Отмена");
	return 1;
}
stock EatList(playerid, idx) {
	SetPVarInt(playerid, "PlayerBizzz", idx);
	if(BizzInfo[idx][bProduct] < 50) return SendClientMessage(playerid, COLOR_GREY, "В бизнесе нет продуктов!");
	strin = "";
	if(GetPlayerInterior(playerid) == 5)
	format(strin, 512, "Маленькая пицца{33AAFF}\t%i {ffffff}долларов\nСредняя пицца\t{33AAFF}%i {ffffff}долларов\nБольшая пицца\t{33AAFF}%i {ffffff}долларов",BizzInfo[idx][bTill]*4, BizzInfo[idx][bTill]*7, BizzInfo[idx][bTill]*10);
	if(GetPlayerInterior(playerid) == 10)
	format(strin, 512, "Бургер\t\t\t{33AAFF}%i {ffffff}долларов\nБольшой бургер\t{33AAFF}%i {ffffff}долларов\nГамбургер\t\t{33AAFF}%i {ffffff}долларов",BizzInfo[idx][bTill]*4, BizzInfo[idx][bTill]*7, BizzInfo[idx][bTill]*10);
	if(GetPlayerInterior(playerid) == 9)
	format(strin, 512, "Кусочки курица\t\t{33AAFF}%i {ffffff}долларов\nКусок куринной ножки\t\t{33AAFF}%i {ffffff}долларов\nКуринная ножка\t\t{33AAFF}%i {ffffff}долларов",BizzInfo[idx][bTill]*4, BizzInfo[idx][bTill]*7, BizzInfo[idx][bTill]*10);
	SPD(playerid, 31, 2, "Закусочная", strin, "Принять", "Отмена");
	return 1;
}
stock ClubList(playerid, idx) {
	SetPVarInt(playerid, "PlayerBizzz", idx);
	if(BizzInfo[idx][bProduct] < 50) return SendClientMessage(playerid, COLOR_GREY,"В баре нет напитков!");
	strin = "";
	format(strin, 512, "Вода\t\t\t{33AAFF}%i {ffffff}долларов\nСода\t\t\t{33AAFF}%i {ffffff}долларов\nКока-кола\t\t{33AAFF}%i {ffffff}долларов\nПиво\t\t\t{33AAFF}%i {ffffff}долларов\nВодка\t\t\t{33AAFF}%i {ffffff}долларов\nКоньяк\t\t\t{33AAFF}%i {ffffff}долларов\nАбсент\t\t\t{33AAFF}%i {ffffff}долларов",
	BizzInfo[idx][bTill]*4, BizzInfo[idx][bTill]*7, BizzInfo[idx][bTill]*10, BizzInfo[idx][bTill]*15, BizzInfo[idx][bTill]*20, BizzInfo[idx][bTill]*25, BizzInfo[idx][bTill]*30);
	SPD(playerid, 32, 2, "24/7", strin, "Принять", "Отмена");
	return 1;
}
stock FoodList(playerid) {
	strin = "";
	format(strin, 512, "Сода{33AAFF}\t\t\t5 {ffffff}долларов\nКвас\t\t\t{33AAFF}15 {ffffff}долларов\nСок\t\t\t{33AAFF}20 {ffffff}долларов\
	\nЛимонад\t\t{33AAFF}30 {ffffff}долларов\nГамбургер\t\t{33AAFF}35 {ffffff}долларов\nМаленькая пицца\t{33AAFF}40 {ffffff}долларов\nБольшая пицца\t{33AAFF}70 {ffffff}долларов");
	SPD(playerid, 34, 2, "Столовая", strin, "Принять", "Отмена");
	return 1;
}
stock UpdateHouse(idx) {
	DestroyDynamicMapIcon(HouseInfo[idx][hMIcon]);
	DestroyDynamicPickup(HouseInfo[idx][hPickup]);
	DestroyDynamicPickup(HouseInfo[idx][hMedPickup]);
	if(!strcmp(HouseInfo[idx][hOwner],"None",true)) {
		HouseInfo[idx][hMIcon] = CreateDynamicMapIcon(HouseInfo[idx][hEntrx], HouseInfo[idx][hEntry], HouseInfo[idx][hEntrz], 31, 0,-1,-1,-1,160.0);
		HouseInfo[idx][hPickup] = CreateDynamicPickup(1273, 23, HouseInfo[idx][hEntrx], HouseInfo[idx][hEntry], HouseInfo[idx][hEntrz]);
	}
	else
	{
		HouseInfo[idx][hMIcon] = CreateDynamicMapIcon(HouseInfo[idx][hEntrx], HouseInfo[idx][hEntry], HouseInfo[idx][hEntrz], 32, 0,-1,-1,-1,160.0);
		HouseInfo[idx][hPickup] = CreateDynamicPickup(1272, 23, HouseInfo[idx][hEntrx], HouseInfo[idx][hEntry], HouseInfo[idx][hEntrz]);
	}
	if(HouseInfo[idx][hMedicine] == 1) {
		switch(HouseInfo[idx][hType])
		{
		case 1: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,152.5929,1380.0516,1088.3672,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 2: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,239.7793,1069.9396,1084.1875,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 3: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,2320.6421,-1026.1470,1050.2109,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 4: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,231.9268,1187.5726,1080.2578,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 5: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,239.0229,1110.2178,1080.9922,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 6: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,2335.7024,-1146.1272,1050.7101,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 7: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,2244.9993,-1077.1807,1049.0234,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 8: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,2188.8677,-1201.4576,1049.0308,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 9: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,2362.4221,-1134.7852,1050.8826,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 12: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,2280.1199,-1135.3749,1050.8984,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 13: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,2213.8435,-1077.9104,1050.4844,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 16: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,2812.4951,-1168.0574,1029.1719,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 17: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,2230.6099,-1108.6124,1050.8828,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 18: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,2264.5967,-1140.5990,1050.6328,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 19: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,247.8775,302.5932,999.1484,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 20: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,2453.9688,-1706.0438,1013.5078,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		case 21: {HouseInfo[idx][hMedPickup]=CreateDynamicPickup(1240,23,272.3441,307.1946,999.1484,321,HouseInfo[idx][hVirtual],HouseInfo[idx][hInt]);}
		}
	}
	return 1;
}
stock UpdateBizz(idx) {
	DestroyDynamic3DTextLabel(LABELBIZZ[idx]);
	if(BizzInfo[idx][bType] != 2) {
		strin = "";
		if(!strcmp(BizzInfo[idx][bOwner],"None",true))
		{
			strin = "";
			format(strin, 190, "<< Бизнес продается >>\nНазвание: %s\nЦена: %d", BizzInfo[idx][bName],BizzInfo[idx][bPrice]);
			LABELBIZZ[idx] = CreateDynamic3DTextLabel(strin,COLOR_YELLOW,BizzInfo[idx][bEntrx],BizzInfo[idx][bEntry],BizzInfo[idx][bEntrz],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
		}
		else {
			strin = "";
			format(strin, 90, "Владелец: %s\nНазвание: %s", BizzInfo[idx][bOwner], BizzInfo[idx][bName]);
			LABELBIZZ[idx] = CreateDynamic3DTextLabel(strin,COLOR_GREEN,BizzInfo[idx][bEntrx],BizzInfo[idx][bEntry],BizzInfo[idx][bEntrz],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
		}
	}
	else
	{
		strin = "";
		if(!strcmp(BizzInfo[idx][bOwner],"None",true))
		{
			strin = "";
			format(strin, 190, "<< Бизнес продается >>\nНазвание: %s\nЦена за 1 литр - %i долларов\nЦена покупки: %d", BizzInfo[idx][bName], BizzInfo[idx], BizzInfo[idx][bTill] / 3,BizzInfo[idx][bPrice]);
			LABELBIZZ[idx] = CreateDynamic3DTextLabel(strin,COLOR_YELLOW,BizzInfo[idx][bEntrx],BizzInfo[idx][bEntry],BizzInfo[idx][bEntrz],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
		}
		else {
			strin = "";
			format(strin, 90, "Владелец: %s\nНазвание: %s\nЦена за 1 литр - %i долларов",  BizzInfo[idx][bOwner], BizzInfo[idx][bName], BizzInfo[idx], BizzInfo[idx][bTill] /3);
			LABELBIZZ[idx] = CreateDynamic3DTextLabel(strin,COLOR_GREEN,BizzInfo[idx][bEntrx],BizzInfo[idx][bEntry],BizzInfo[idx][bEntrz],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
		}
	}
	return 1;
}
stock NonPass(const tm_strin[]) {
	if(strfind(tm_strin,"123456",true) != -1 || strfind(tm_strin,"654321",true) != -1 || strfind(tm_strin,"112233",true) != -1 || strfind(tm_strin,"332211",true) != -1
			|| strfind(tm_strin,"123321",true) != -1 || strfind(tm_strin,"321123",true) != -1 || strfind(tm_strin,"000000",true) != -1 || strfind(tm_strin,"000000",true) != -1
			|| strfind(tm_strin,"111111",true) != -1 || strfind(tm_strin,"222222",true) != -1 || strfind(tm_strin,"333333",true) != -1 || strfind(tm_strin,"444444",true) != -1
			|| strfind(tm_strin,"555555",true) != -1 || strfind(tm_strin,"666666",true) != -1 || strfind(tm_strin,"777777",true) != -1 || strfind(tm_strin,"888888",true) != -1
			|| strfind(tm_strin,"999999",true) != -1 || strfind(tm_strin,"101010",true) != -1 || strfind(tm_strin,"010101",true) != -1) return 1;
	return 0;
}
stock Float:GetAngleToPoint(Float:X, Float:Y, Float:A, Float:x, Float:y) {
	new Float:angle = 185.0 - atan2(X-x, Y-y);
	A -= (angle - 5.0);
	return A;
}
stock GetPlayerAngleToPoint(playerid, Float:x, Float:y) {
	new Float:ix, Float:iy, Float:iz, Float:a;
	GetPlayerFacingAngle(playerid, a);
	GetPlayerPos(playerid, ix, iy, iz);
	return floatround(GetAngleToPoint(ix, iy, a, x, y));
}
stock UpdatePark(idx) {
	DestroyDynamic3DTextLabel(LABELPARK[idx]);
	strin = "";
	if(!strcmp(BizzPark[idx][tOwner],"None",true)) {
		strin = "";
		format(strin, 190, "<< Бизнес продается >>\nНазвание: %s\nЦена: %d", BizzPark[idx][tName],BizzPark[idx][tCost]);
		LABELPARK[idx] = CreateDynamic3DTextLabel(strin,COLOR_YELLOW,BizzPark[idx][tX],BizzPark[idx][tY],BizzPark[idx][tZ],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	}
	else
	{
		strin = "";
		format(strin, 90, "Название: %s\nВладелец: %s", BizzPark[idx][tName], BizzPark[idx][tOwner]);
		LABELPARK[idx] = CreateDynamic3DTextLabel(strin,COLOR_GREEN,BizzPark[idx][tX],BizzPark[idx][tY],BizzPark[idx][tZ],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	}
	return 1;
}

stock GetPlayerHouse(playerid) {
	new house = 0;
	for(new i = 1; i <= TOTALHOUSE;i++) {
		if(!strcmp(HouseInfo[i][hOwner],NamePlayer(playerid),true)) house++, SetPVarInt(playerid, "PlayerHouse", i);
	}
	return house;
}
stock GetPlayerBizz(playerid) {
	new bizz = 0;
	for(new i = 1; i <= TOTALBIZZ;i++) {
		if(!strcmp(BizzInfo[i][bOwner],NamePlayer(playerid),true)) bizz++, SetPVarInt(playerid, "PlayerBizz", i);
	}
	return bizz;
}

stock GetPlayerPark(playerid) {
	new bizz = 0;
	for(new i = 1; i <= TOTALPARK;i++) {
		if(!strcmp(BizzPark[i][tOwner],NamePlayer(playerid),true)) bizz++, SetPVarInt(playerid, "BizzPark", i);
	}
	return bizz;
}

stock GetPlayersJob() {
	new bizz = 0;
	foreach(new i: Player) {
		if(GetPVarInt(i, "PriceTaxi") > 0) bizz++;
	}
	return bizz;
}

stock GetCarsPark(idx) {
	new bizz = 0;
	for(new i = 1; i <= TOTALCARSPARK;i++)
	if(BizzCarsPark[i][tcPID] == idx && BizzCarsPark[i][tcStatus] == 1) bizz++;
	return bizz;
}

stock LeaveFractionPlayer(playerid) {
	if(PI[playerid][pMember] == F_VMF) PI[playerid][pArmyBilet] = 1;
	if(PI[playerid][pMember] == F_ARMY) PI[playerid][pArmyBilet] = 2;
	SendClientMessage(playerid, COLOR_WHITE, "Теперь вы снова - гражданский!");
	PI[playerid][pFracSkin] = 0, PI[playerid][pMember] = 0, PI[playerid][pRank] = 0; PI[playerid][pLeader] = 0;
	SpawnPlayer(playerid), ResetWeapon(playerid);
	GunCheckTime[playerid] = 5;
	return true;
}

stock SPD(playerid, dialogid, style, caption[], info[], button1[], button2[]) {
	SetPVarInt(playerid,"DialogID",dialogid);
	if(GetPVarInt(playerid,"RentBMX") != 0)
	return RemovePlayerFromVehicleEx(playerid);
	ShowPlayerDialog(playerid, dialogid, style, caption, info, button1, button2);
	return 1;
}

stock GetPlayerID(string[]) {
	foreach(new i: Player) {
		if(IsPlayerConnected(i)) {
			if(strcmp(NamePlayer(i), string, true, strlen(string)) == 0) return i;
		}
	}
	return INVALID_PLAYER_ID;
}
stock SendAdminMessage(color, tm_strin[]) {
	foreach(new i: Player) {
		if(PlayerLogged[i] != false && PI[i][pAdmLevel] > 0 && SendAdmin[i]) SendClientMessage(i, color, tm_strin);
	}
	return true;
}
stock SendHelperMessage(color, tm_strin[]) {
	foreach(new i: Player) {
		if(PlayerLogged[i] != false && PI[i][pHelpLevel] > 0 && SendHelper[i]) SendClientMessage(i, color, tm_strin);
	}
	return true;
}
// F Чат
stock SendFMes(family, color, tm_strin[]) {
	foreach(new i: Player) {
		if(PlayerLogged[i] != false && PI[i][pMember] == family && SendFamily[i]) SendClientMessage(i, color, tm_strin);
	}
	return true;
}
// D
stock SendDMes(color, tm_strin[]) {
	foreach(new i: Player) {
	if(SendFamily[i])
	if(PlayerLogged[i] != false && PI[i][pMember] == F_GOV || PI[i][pMember] == 2 || PI[i][pMember] == F_SFPD || PI[i][pMember] == F_LVPD || PI[i][pMember] == 4 || PI[i][pMember] == 5 || PI[i][pMember] == 11 || PI[i][pMember] == 13) SendClientMessage(i, color, tm_strin);
	}
	return true;
}
//
stock IsACop(playerid) {
	if(PI[playerid][pMember] == F_SAPD || PI[playerid][pMember] == F_FBI || PI[playerid][pMember] == F_SFPD || PI[playerid][pMember] == F_LVPD) return 1;
	return 0;
}

stock IsAGang(playerid) {
	if(PI[playerid][pMember] == F_GROVE || PI[playerid][pMember] == F_BALLAS || PI[playerid][pMember] == F_AZTEC || PI[playerid][pMember] == F_VAGOS || PI[playerid][pMember] == F_RIFA) return 1;
	return 0;
}

stock IsAArmy(playerid) {
	if(PI[playerid][pMember] == F_VMF || PI[playerid][pMember] == F_ARMY) return 1;
	return 0;
}
stock SetPlayerCriminal(playerid, killerid[], reason[]) {
	PI[playerid][pCrimes]++;
	strmid(PI[playerid][pWantedWho], killerid, 0, strlen(killerid), MAX_PLAYER_NAME);
	strmid(PI[playerid][pWantedReason], reason, 0, strlen(reason), 32);
	SetPlayerWantedLevel(playerid,PI[playerid][pWanted]);
	SendClientMessageEx(playerid, COLOR_LIGHTRED,"Вы совершили преступление: [ %s ]. Сообщает: %s.",reason, killerid);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Ваш уровень розыска: %i", PI[playerid][pWanted]);
	foreach(new i: Player)
	if(PlayerLogged[i] != false && IsACop(i)) SendClientMessageEx(i, COLOR_ORANGE, "Рация: %s. Преступление: %s. Подозреваемый: %s", killerid, reason, NamePlayer(playerid));
	return 1;
}

stock GetJobName(playerid) {
	new rangname[32];
	switch(PI[playerid][pJob]) {
	case 1: rangname = "Водитель такси";
	case 2: rangname = "Водитель автобуса";
	case 3: rangname = "Развозчик продуктов";
	case 4: rangname = "Автомеханик";
	case 5: rangname = "Развозчик топлива";
	default: rangname = "Нет";
	}
	return rangname;
}

stock GetExp(playerid) {
	PI[playerid][pExp]++;
	if(PI[playerid][pExp] >= PI[playerid][pLevel]*4) {
		SendClientMessage(playerid, 0xFF0000FF, "Ваш опыт игры повышен, поздравляем!");
		PI[playerid][pLevel]++;
		PI[playerid][pExp] = 0;
		SetPlayerScore(playerid, PI[playerid][pLevel]);
	}
	return 1;
}
stock timestamp_to_date(unix_timestamp = 0, & year = 1970, & month  = 1, & day = 1, & hour = 0, & minute = 0, & second = 0) {
	year = unix_timestamp / 31557600;
	unix_timestamp -= year * 31557600;
	year += 1970;

	if ( year % 4 == 0 ) unix_timestamp -= 21600;

	day = unix_timestamp / 86400;

	switch ( day )
	{
	case 0..30 : { second = day; month =  1; }
	case 31..58 : { second = day - 31; month = 2; }
	case 59..89 : { second = day - 59; month = 3; }
	case 90..119 : { second = day - 90; month = 4; }
	case 120..150 : { second = day - 120; month = 5; }
	case 151..180 : { second = day - 151; month = 6; }
	case 181..211 : { second = day - 181; month = 7; }
	case 212..242 : { second = day - 212; month = 8; }
	case 243..272 : { second = day - 243; month = 9; }
	case 273..303 : { second = day - 273; month = 10; }
	case 304..333 : { second = day - 304; month = 11; }
	case 334..366 : { second = day - 334; month = 12; }
	}
	unix_timestamp -= day * 86400;
	hour = unix_timestamp / 3600;

	unix_timestamp -= hour * 3600;
	minute = unix_timestamp / 60;

	unix_timestamp -= minute * 60;
	day = second + 1;
	second = unix_timestamp;
}
stock date(formatStr[] = "%dd.%mm.%yyyy, %hh:%ii:%ss", timestamp = 0) {
	const sizeOfOutput = 128;
	new yyyy, mm, dd, h, m, s,
	pos, foundPos, searchStartPos, outStrLen,
	tmpNumStr[5], outStr[sizeOfOutput];
	timestamp_to_date( timestamp+36000, yyyy,mm,dd, h,m,s );

	memcpy( outStr, formatStr, 0, (sizeOfOutput - 1)*4 );
	outStr[sizeOfOutput - 1] = 0;
	outStrLen = strlen(outStr);
	searchStartPos = 0;
	foundPos = strfind( outStr, "%yyyy", false, searchStartPos );

	while( foundPos != -1 ) {
		format( tmpNumStr, 5, "%04d", yyyy );

		for ( pos = 0; tmpNumStr[pos] != 0 && pos < 4; pos++ )
		outStr[foundPos + pos] = tmpNumStr[pos];

		for ( pos += foundPos; pos < outStrLen; pos++ )
		outStr[pos] = outStr[pos + 1];

		outStr[pos] = 0;
		outStrLen = strlen(outStr);
		searchStartPos = foundPos + 4;

		if ( searchStartPos < outStrLen )
		foundPos = strfind( outStr, "%yyyy", false, searchStartPos );
		else break;
	}
	searchStartPos = 0;
	foundPos = strfind( outStr, "%yy", false, searchStartPos );

	while( foundPos != -1 )
	{
		format( tmpNumStr, 5, "%04d", yyyy );

		for ( pos = 0; tmpNumStr[pos] != 0 && pos < 2; pos++ )
		outStr[foundPos + pos] = tmpNumStr[pos + 2];

		for ( pos += foundPos; pos <= outStrLen; pos++ )
		outStr[pos] = outStr[pos + 1];

		outStr[pos] = 0;
		outStrLen = strlen(outStr);
		searchStartPos = foundPos + 2;

		if ( searchStartPos < outStrLen )
		foundPos = strfind( outStr, "%yy", false, searchStartPos );
		else break;
	}
	foundPos = 0;
	foundPos = strfind( outStr, "%mm", false, foundPos );

	while ( foundPos != -1 )
	{
		format( tmpNumStr, 3, "%02d", mm );

		for ( pos = 0; tmpNumStr[pos] != 0 && pos < 2; pos++ )
		outStr[foundPos + pos] = tmpNumStr[pos];

		for ( pos += foundPos; pos <= outStrLen; pos++ )
		outStr[pos] = outStr[pos + 1];

		outStr[pos] = 0;
		outStrLen = strlen(outStr);
		foundPos += 2;

		if ( foundPos < outStrLen )
		foundPos = strfind( outStr, "%mm", false, foundPos );
		else break;
	}
	foundPos = 0;
	foundPos = strfind( outStr, "%m", false, foundPos );

	while ( foundPos != -1 )
	{
		format( tmpNumStr, 3, "%d", mm );

		for ( pos = 0; tmpNumStr[pos] != 0 && pos < 2; pos++ )
		outStr[foundPos + pos] = tmpNumStr[pos];

		if ( mm < 10 )
		{
			for ( pos += foundPos; pos <= outStrLen; pos++ )
			outStr[pos] = outStr[pos + 1];

			outStr[pos] = 0;
			outStrLen = strlen(outStr);
			foundPos++;
		}
		else
		foundPos += 2;

		if ( foundPos < outStrLen )
		foundPos = strfind( outStr, "%m", false, foundPos );
		else break;
	}
	foundPos = 0;
	foundPos = strfind( outStr, "%dd", false, foundPos );

	while ( foundPos != -1 )
	{
		format( tmpNumStr, 3, "%02d", dd );

		for ( pos = 0; tmpNumStr[pos] != 0 && pos < 2; pos++ )
		outStr[foundPos + pos] = tmpNumStr[pos];

		for ( pos += foundPos; pos <= outStrLen; pos++ )
		outStr[pos] = outStr[pos + 1];

		outStr[pos] = 0;
		outStrLen = strlen(outStr);
		foundPos += 2;

		if ( foundPos < outStrLen )
		foundPos = strfind( outStr, "%dd", false, foundPos );
		else break;
	}
	foundPos = 0;
	foundPos = strfind( outStr, "%d", false, foundPos );

	while ( foundPos != -1 )
	{
		format( tmpNumStr, 3, "%d", dd );

		for ( pos = 0; tmpNumStr[pos] != 0 && pos < 2; pos++ )
		outStr[foundPos + pos] = tmpNumStr[pos];

		if ( dd < 10 )
		{
			for ( pos += foundPos; pos <= outStrLen; pos++ )
			outStr[pos] = outStr[pos + 1];

			outStr[pos] = 0;
			outStrLen = strlen(outStr);
			foundPos++;
		}
		else
		foundPos += 2;

		if ( foundPos < outStrLen )
		foundPos = strfind( outStr, "%d", false, foundPos );
		else break;
	}
	foundPos = 0;
	foundPos = strfind( outStr, "%hh", false, foundPos );

	while ( foundPos != -1 )
	{
		format( tmpNumStr, 3, "%02d", h );

		for ( pos = 0; tmpNumStr[pos] != 0 && pos < 2; pos++ )
		outStr[foundPos + pos] = tmpNumStr[pos];

		for ( pos += foundPos; pos <= outStrLen; pos++ )
		outStr[pos] = outStr[pos + 1];

		outStr[pos] = 0;
		outStrLen = strlen(outStr);
		foundPos += 2;

		if ( foundPos < outStrLen )
		foundPos = strfind( outStr, "%hh", false, foundPos );
		else break;
	}
	foundPos = 0;
	foundPos = strfind( outStr, "%h", false, foundPos );

	while ( foundPos != -1 )
	{
		format( tmpNumStr, 3, "%d", h );

		for ( pos = 0; tmpNumStr[pos] != 0 && pos < 2; pos++ )
		outStr[foundPos + pos] = tmpNumStr[pos];

		if ( h < 10 )
		{
			for ( pos += foundPos; pos <= outStrLen; pos++ )
			outStr[pos] = outStr[pos + 1];

			outStr[pos] = 0;
			outStrLen = strlen(outStr);
			foundPos++;
		}
		else
		foundPos += 2;

		if ( foundPos < outStrLen )
		foundPos = strfind( outStr, "%h", false, foundPos );
		else break;
	}
	foundPos = 0;
	foundPos = strfind( outStr, "%ii", false, foundPos );

	while ( foundPos != -1 )
	{
		format( tmpNumStr, 3, "%02d", m );

		for ( pos = 0; tmpNumStr[pos] != 0 && pos < 2; pos++ )
		outStr[foundPos + pos] = tmpNumStr[pos];

		for ( pos += foundPos; pos <= outStrLen; pos++ )
		outStr[pos] = outStr[pos + 1];

		outStr[pos] = 0;
		outStrLen = strlen(outStr);
		foundPos += 2;

		if ( foundPos < outStrLen )
		foundPos = strfind( outStr, "%ii", false, foundPos );
		else break;
	}
	foundPos = 0;
	foundPos = strfind( outStr, "%i", false, foundPos );

	while ( foundPos != -1 )
	{
		format( tmpNumStr, 3, "%d", m );

		for ( pos = 0; tmpNumStr[pos] != 0 && pos < 2; pos++ )
		outStr[foundPos + pos] = tmpNumStr[pos];

		if ( m < 10 )
		{
			for ( pos += foundPos; pos <= outStrLen; pos++ )
			outStr[pos] = outStr[pos + 1];

			outStr[pos] = 0;
			outStrLen = strlen(outStr);
			foundPos++;
		}
		else
		foundPos += 2;

		if ( foundPos < outStrLen )
		foundPos = strfind( outStr, "%i", false, foundPos );
		else break;
	}
	foundPos = 0;
	foundPos = strfind( outStr, "%ss", false, foundPos );

	while ( foundPos != -1 )
	{
		format( tmpNumStr, 3, "%02d", s );

		for ( pos = 0; tmpNumStr[pos] != 0 && pos < 2; pos++ )
		outStr[foundPos + pos] = tmpNumStr[pos];

		for ( pos += foundPos; pos <= outStrLen; pos++ )
		outStr[pos] = outStr[pos + 1];

		outStr[pos] = 0;
		outStrLen = strlen(outStr);
		foundPos += 2;

		if ( foundPos < outStrLen )
		foundPos = strfind( outStr, "%ss", false, foundPos );
		else break;
	}
	foundPos = 0;
	foundPos = strfind( outStr, "%s", false, foundPos );

	while ( foundPos != -1 )
	{
		format( tmpNumStr, 3, "%d", s );

		for ( pos = 0; tmpNumStr[pos] != 0 && pos < 2; pos++ )
		outStr[foundPos + pos] = tmpNumStr[pos];

		if ( s < 10 )
		{
			for ( pos += foundPos; pos <= outStrLen; pos++ )
			outStr[pos] = outStr[pos + 1];

			outStr[pos] = 0;
			outStrLen = strlen(outStr);
			foundPos++;
		}
		else
		foundPos += 2;

		if ( foundPos < outStrLen )
		foundPos = strfind( outStr, "%s", false, foundPos );
		else break;
	}
	return outStr;
}
stock ProxDetectorNew(playerid,Float:Radi=10.0,color,text[]) {
	GetPlayerPos(playerid,PI[playerid][pPos][0],PI[playerid][pPos][1],PI[playerid][pPos][2]);
	SendClientMessage(playerid,color,text);
	foreach(new i: StreamedPlayers[playerid]) {
		if(IsPlayerInRangeOfPoint(i,Radi,PI[playerid][pPos][0],PI[playerid][pPos][1],PI[playerid][pPos][2]))
		{
			if(GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && GetPlayerInterior(playerid) == GetPlayerInterior(i))SendClientMessage(i,color,text);
		}
	}
}
stock CheckString(text[]) {
	for(new i = 0;i<sizeof(WebSites);i++) {
		if(strfind(text,WebSites[i],true) != -1) return 1;
	}
	return 0;
}
stock NonAD(const str[]) {
	if(strfind(str,""NameSite"",true) != -1 || strfind(str,"0.0.0.0:7777",true) != -1) return 1;
	return 0;
}
stock IsIP(const str[]) {
	for(new cIP[4]; cIP[0] != strlen(str)+1; cIP[0]++) {
		switch(str[cIP[0]])
		{
		case '.', ' ', ':', ',', '*', '/', ';', '\\', '|','_' : continue;
		case '0' .. '9': cIP[1]++;
		}
		if(cIP[1] ==1) cIP[2] = cIP[0];
		if(cIP[1] >= 9)
		{
			new strx[16];
			new l[4][4];
			cIP[3] = cIP[0]+8;
			strmid(strx,str,cIP[2],cIP[3],16);
			for(new i =strlen(strx);i>8;i--) {
				switch(strx[i]) {
				case '0' .. '9','.', ' ', ':', ',', '*', '/', ';', '\\', '|','_': continue;
				default: strx[i] =0;
				}
			}
			for(new i =0;i<sizeof(delimiters);i++) {
				split(strx,l,delimiters[i]);
				if(strlen(l[0]) == 1 ||strlen(l[1]) == 1 ||strlen(l[2]) == 1 ||strlen(l[3]) == 1) continue;
				if(strlen(l[0]) >3 ||strlen(l[1]) >3 ||strlen(l[2]) >3) continue;
				else return 1;
			}
		}
	}
	return 0;
}
stock split(const strsrc[], strdest[][], delimiter) {
	new i, li;
	new aNum;
	new len;
	while(i <= strlen(strsrc)) {
		if(strsrc[i]==delimiter || i==strlen(strsrc))
		{
			len = strmid(strdest[aNum], strsrc, li, i, 128);
			strdest[aNum][len] = 0;
			li = i+1;
			aNum++;
		}
		i++;
	}
	return 1;
}

stock IsTextRussian(text[]) {
	if(strfind(text, "а", true) != -1) return 1; if(strfind(text, "б", true) != -1) return 1; if(strfind(text, "в", true) != -1) return 1;
	if(strfind(text, "г", true) != -1) return 1; if(strfind(text, "д", true) != -1) return 1; if(strfind(text, "е", true) != -1) return 1;
	if(strfind(text, "ё", true) != -1) return 1; if(strfind(text, "ж", true) != -1) return 1; if(strfind(text, "з", true) != -1) return 1;
	if(strfind(text, "и", true) != -1) return 1; if(strfind(text, "й", true) != -1) return 1; if(strfind(text, "к", true) != -1) return 1;
	if(strfind(text, "л", true) != -1) return 1; if(strfind(text, "м", true) != -1) return 1; if(strfind(text, "н", true) != -1) return 1;
	if(strfind(text, "о", true) != -1) return 1; if(strfind(text, "п", true) != -1) return 1; if(strfind(text, "р", true) != -1) return 1;
	if(strfind(text, "с", true) != -1) return 1; if(strfind(text, "т", true) != -1) return 1; if(strfind(text, "у", true) != -1) return 1;
	if(strfind(text, "ф", true) != -1) return 1; if(strfind(text, "х", true) != -1) return 1; if(strfind(text, "ц", true) != -1) return 1;
	if(strfind(text, "ч", true) != -1) return 1; if(strfind(text, "ш", true) != -1) return 1; if(strfind(text, "щ", true) != -1) return 1;
	if(strfind(text, "ъ", true) != -1) return 1; if(strfind(text, "ы", true) != -1) return 1; if(strfind(text, "ь", true) != -1) return 1;
	if(strfind(text, "э", true) != -1) return 1; if(strfind(text, "ю", true) != -1) return 1; if(strfind(text, "я", true) != -1) return 1;
	return 0;
}
stock UpdateKolhozPlayers(playerid, statets) {
	new playerinjob;
	if(PlayerInKolhoz[playerid] != statets ) {
		if(statets)playerinjob ++;
		else playerinjob --;
		//

		format(strin,128,"Состояние рабочих сил:\nПомошников: %d\nТрактористов: %d\nКомбайнеров: %d\nЛетчиков: %dВсего рабочих: %d",playerinjob);
		strin = "";
		format(strin,128,"Состояние рабочих сил\nВсего рабочих: %d",playerinjob);
		Update3DTextLabelText(Kolhoz, 0xFFFFFFFF, strin);
	}
	PlayerInKolhoz[playerid] = statets;
	OnOneLevelJob[playerid] = 0;
	return 1;
}
stock GiveFarmMoney(playerid) {
	switch(SelectFarmJob[playerid]) {
	    case 1: {
			strin = "";
			format(strin, sizeof(strin), "Вы заработали %d", OnLevelKol[playerid]*500);
			SendClientMessage(playerid, -1, strin);
			GiveMoney(playerid, OnLevelKol[playerid]*500);
	    }
	    case 4: {
			strin = "";
			format(strin, sizeof(strin), "Вы заработали %d", OnLevelKol[playerid]*1000);
			SendClientMessage(playerid, -1, strin);
			GiveMoney(playerid, OnLevelKol[playerid]*1000);
	    }
	}
}
stock SetFarmCheck(playerid) {
	if(SelectFarmJob[playerid] == 2) {
		switch(FarmData[playerid][0])
		{
		case 0: {
				if(FarmData[playerid][1] > sizeof(Tractor_1) - 1) {
					FarmData[playerid][1] = 0;
					FarmData[playerid][0]++;
					if(FarmData[playerid][0] > 3) FarmData[playerid][0] = 0;
					SendClientMessage(playerid, -1, "Вы заработали 400");
					GiveMoney(playerid, 400);
					DisablePlayerCheckpoint(playerid);
				}
				else {
					SetPlayerCheckpoint(playerid, Tractor_1[FarmData[playerid][1]][0], Tractor_1[FarmData[playerid][1]][1], Tractor_1[FarmData[playerid][1]][2] , 2.0);
					FarmData[playerid][1]++;
				}
			}
		case 1: {
				if(FarmData[playerid][1] > sizeof(Tractor_2) - 1) {
					FarmData[playerid][1] = 0;
					FarmData[playerid][0]++;
					if(FarmData[playerid][0] > 3) FarmData[playerid][0] = 0;
					SendClientMessage(playerid, -1, "Вы заработали 400");
					GiveMoney(playerid, 400);
					DisablePlayerCheckpoint(playerid);
				}
				else {
					SetPlayerCheckpoint(playerid, Tractor_2[FarmData[playerid][1]][0], Tractor_2[FarmData[playerid][1]][1], Tractor_2[FarmData[playerid][1]][2] , 2.0);
					FarmData[playerid][1]++;
				}
			}
		case 2: {
				if(FarmData[playerid][1] > sizeof(Tractor_3) - 1) {
					FarmData[playerid][1] = 0;
					FarmData[playerid][0]++;
					if(FarmData[playerid][0] > 3) FarmData[playerid][0] = 0;
					SendClientMessage(playerid, -1, "Вы заработали 400");
					GiveMoney(playerid, 400);
					DisablePlayerCheckpoint(playerid);
				}
				else {
					SetPlayerCheckpoint(playerid, Tractor_3[FarmData[playerid][1]][0], Tractor_3[FarmData[playerid][1]][1], Tractor_3[FarmData[playerid][1]][2] , 2.0);
					FarmData[playerid][1]++;
				}
			}
		case 3: {
				if(FarmData[playerid][1] > sizeof(Tractor_4) - 1) {
					FarmData[playerid][1] = 0;
					FarmData[playerid][0]++;
					if(FarmData[playerid][0] > 3) FarmData[playerid][0] = 0;
					SendClientMessage(playerid, -1, "Вы заработали 400");
					GiveMoney(playerid, 400);
					DisablePlayerCheckpoint(playerid);
				}
				else {
					SetPlayerCheckpoint(playerid, Tractor_4[FarmData[playerid][1]][0], Tractor_4[FarmData[playerid][1]][1], Tractor_4[FarmData[playerid][1]][2] , 2.0);
					FarmData[playerid][1]++;
				}
			}
		}
	}
	else if(SelectFarmJob[playerid] == 3) {
		switch(FarmData[playerid][0])
		{
		case 0: {
				if(FarmData[playerid][1] > sizeof(Combain_1)) {
					FarmData[playerid][1] = 0;
					FarmData[playerid][0]++;
					if(FarmData[playerid][0] > 2) FarmData[playerid][0] = 0;
					SendClientMessage(playerid, -1, "Вы заработали 600");
					GiveMoney(playerid, 600);
					DisablePlayerCheckpoint(playerid);
				}
				else {
					SetPlayerCheckpoint(playerid, Combain_1[FarmData[playerid][1]][0], Combain_1[FarmData[playerid][1]][1], Combain_1[FarmData[playerid][1]][2] , 2.0);
					FarmData[playerid][1]++;
				}
			}
		case 1: {
				if(FarmData[playerid][1] > sizeof(Combain_2)) {
					FarmData[playerid][1] = 0;
					FarmData[playerid][0]++;
					if(FarmData[playerid][0] > 2) FarmData[playerid][0] = 0;
					SendClientMessage(playerid, -1, "Вы заработали 600");
					GiveMoney(playerid, 600);
					DisablePlayerCheckpoint(playerid);
				}
				else {
					SetPlayerCheckpoint(playerid, Combain_2[FarmData[playerid][1]][0], Combain_2[FarmData[playerid][1]][1], Combain_2[FarmData[playerid][1]][2] , 2.0);
					FarmData[playerid][1]++;
				}
			}
		case 2: {
				if(FarmData[playerid][1] > sizeof(Combain_3)) {
					FarmData[playerid][1] = 0;
					FarmData[playerid][0]++;
					if(FarmData[playerid][0] > 2) FarmData[playerid][0] = 0;
					SendClientMessage(playerid, -1, "Вы заработали 600");
					GiveMoney(playerid, 600);
					DisablePlayerCheckpoint(playerid);
				}
				else {
					SetPlayerCheckpoint(playerid, Combain_3[FarmData[playerid][1]][0], Combain_3[FarmData[playerid][1]][1], Combain_3[FarmData[playerid][1]][2] , 2.0);
					FarmData[playerid][1]++;
				}
			}
		}
	}
}
stock AC_AddVehicleComponent(vehicleid, componentid) {
	new slot = GetVehicleComponentType(componentid);
	for(new i = 0, l = MAX_PLAYERS; i < l; i++) {
		if(!IsPlayerConnected(i)) continue;
		if(GetPlayerVehicleID(i) == vehicleid) AC_PI[i][pMod][slot] = 2, AC_PI[i][pMod][14] = vehicleid;
	}
	return AddVehicleComponent(vehicleid, componentid);
}

stock AC_RemoveVehicleComponent(vehicleid, componentid) {
	new slot = GetVehicleComponentType(componentid);
	for(new i = 0, l = MAX_PLAYERS; i < l; i++) {
		if(!IsPlayerConnected(i)) continue;
		if(GetPlayerVehicleID(i) == vehicleid) AC_PI[i][pMod][slot] = -1, AC_PI[i][pMod][14] = vehicleid;
	}
	return RemoveVehicleComponent(vehicleid, componentid);
}
stock SetVehicleNumber(vehid, number[] = "none"){
	if(strcmp(number, "none", false)) {
		SetVehicleNumberPlate(vehid, number);
	}
	else {
		if(vehid > 999) {
			strin = "";
			format(strin, sizeof strin, "%c%c%04i%c", ('A'+random(26)), ('A'+random(26)), vehid, ('A'+random(26)));
		}
		else {
			strin = "";
			format(strin, sizeof strin, "%c%c%03i%c", ('A'+random(26)), ('A'+random(26)), vehid, ('A'+random(26)));
		}
		SetVehicleNumberPlate(vehid, strin);
	}
}
stock settext(string[], const text[]) return strmid(string, text, 0, strlen(text), 255);
stock GetHouseZone(h) {
	new zone[32],bool:getzone;
	for(new i=0; i<sizeof(gSAZones); i++) {
		if(HouseInfo[h][hEntrx] >= gSAZones[i][SAZONE_AREA][0] && HouseInfo[h][hEntrx] <= gSAZones[i][SAZONE_AREA][3]
				&& HouseInfo[h][hEntry] >= gSAZones[i][SAZONE_AREA][1] && HouseInfo[h][hEntry] <= gSAZones[i][SAZONE_AREA][4])
		{
			settext(zone, gSAZones[i][SAZONE_NAME]);
			getzone = true;
			break;
		}
	}
	if(!getzone) zone = "Неизвестно";
	return zone;
}
stock GoPlayerAnimation(playerid, Float:X, Float:Y, Float:Z) {
	if(IsPlayerInAnyVehicle(playerid)) return false;
	if(IsPlayerInRangeOfPoint(playerid, 2.0, X, Y, Z)) {
		ApplyAnimation(playerid, "PED", "IDLE_STANCE", 4.1, 0, 1, 1, 0, 0, 1);
		return 1;
	}
	else if(IsPlayerInRangeOfPoint(playerid, 4.0, X, Y, Z)) {
		ApplyAnimation(playerid, "PED", "WALK_PLAYER", 4.1, 0, 1, 1, 0, 0, 1);
		return 2;
	}
	else if(IsPlayerInRangeOfPoint(playerid, 7.0, X, Y, Z)) {
		ApplyAnimation(playerid, "PED", "RUN_GANG1", 4.1, 0, 1, 1, 0, 0, 1);
		return 3;
	}
	ApplyAnimation(playerid, "PED", "SPRINT_PANIC", 4.1, 0, 1, 1, 0, 0, 1);
	return 4;
}

stock PlayerSeatedToVehicle(playerid, vehicleid) {
	new Float:X, Float:Y, Float:Z;
	GetVehiclePos(vehicleid, X, Y, Z);
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, X, Y, Z)) return false;
	for(new i = 1; i < 4; i ++) {
		new passenger = VehicleSeat[vehicleid][i];
		if(passenger == INVALID_PLAYER_ID)
		{
			PutPlayerInVehicleEx(playerid, vehicleid, i);
			return true;
		}
	}
	return false;
}
stock TurnPlayerFaceToPlayer(playerid, facingtoid) {
	new Float:x, Float:y, Float:z;
	GetPlayerPos(facingtoid, x, y, z);
	SetPlayerFaceToPoint(playerid, x, y);
	return true;
}

stock SetPlayerFaceToPoint(playerid, Float:X, Float:Y) {
	new Float:angle;
	new Float:misc = 5.0;
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	angle = 180.0-atan2(x-X,y-Y);
	angle += misc;
	misc *= -1;
	SetPlayerFacingAngle(playerid, angle+misc);
	return true;
}
stock ShiftCords(style, &Float:x, &Float:y, &Float:z, Float:a, Float:distance) {
	switch(style) {
	case 0: {
			x += (distance * floatsin(-a, degrees));
			y += (distance * floatcos(-a, degrees));
		}
	case 1: {
			x -= (distance * floatsin(-a, degrees));
			y -= (distance * floatcos(-a, degrees));
		}
	default: return false;
	}
	return true;
}
stock CheckPlayerGoCuff(playerid) {
	if(GotoInfo[playerid][gtID] != INVALID_PLAYER_ID) CheckPlayerGoCuffRecursion(GotoInfo[playerid][gtID]);
	GotoInfo[playerid][gtX] = 0.0;
	GotoInfo[playerid][gtY] = 0.0;
	GotoInfo[playerid][gtZ] = 0.0;
	GotoInfo[playerid][gtTPX] = 0.0;
	GotoInfo[playerid][gtTPY] = 0.0;
	GotoInfo[playerid][gtTPZ] = 0.0;
	GotoInfo[playerid][gtID] = INVALID_PLAYER_ID;
	GotoInfo[playerid][gtGoID] = INVALID_PLAYER_ID;
	GotoInfo[playerid][gtState] = 0;
	GotoInfo[playerid][gtStayed] = 0;
	return true;
}
stock CheckPlayerGoCuffRecursion(playerid) {
	GotoInfo[playerid][gtX] = 0.0;
	GotoInfo[playerid][gtY] = 0.0;
	GotoInfo[playerid][gtZ] = 0.0;
	GotoInfo[playerid][gtTPX] = 0.0;
	GotoInfo[playerid][gtTPY] = 0.0;
	GotoInfo[playerid][gtTPZ] = 0.0;
	GotoInfo[playerid][gtID] = INVALID_PLAYER_ID;
	GotoInfo[playerid][gtGoID] = INVALID_PLAYER_ID;
	GotoInfo[playerid][gtState] = 0;
	GotoInfo[playerid][gtStayed] = 0;
	return true;
}
stock KickEx(playerid) return SetTimerEx("PlayerKick",250,false,"d", playerid);
stock CreatePlayer(playerid, pass[]) {
	new ip[16],data[16];
	format(data, 16, "%s",date("%dd.%mm.%yyyy",gettime()));
	GetPlayerIp(playerid, ip, 16);

	PI[playerid][pCash] = BONUS_CASH;
	PI[playerid][pLevel] = BONUS_LEVEL;
	PI[playerid][pDonateCash] = BONUS_DONATECASH;

	query = "";
	format(query, sizeof(query), "INSERT INTO "TABLE_ACCOUNT" (Name, Password, Email, Skin, RegDate, RegIp, Cash, Level, DonateCash) VALUES ('%s', '%s', '%s', %d, '%s', '%s', '%d', '%d', '%d')",
	NamePlayer(playerid), pass, PI[playerid][pEmail], PI[playerid][pSkin], data, ip, PI[playerid][pCash],PI[playerid][pLevel],PI[playerid][pDonateCash]);
	mysql_function_query(cHandle, query, false, "", "");

	query = "";
	format(query,sizeof(query), "SELECT * FROM "TABLE_ACCOUNT" WHERE Name = '%s' LIMIT 1",NamePlayer(playerid));
	mysql_function_query(cHandle, query, true, "LoadPlayer", "i",playerid);

	SendClientMessage(playerid, COLOR_PAYCHEC, "Поздравляем вы успешно зарегистрировались!");
	SendClientMessage(playerid, COLOR_PAYCHEC, "Подсказка: Вы можете устроиться на работу в Бирже труда (( /gps - Важные места ))");
	SendClientMessage(playerid, COLOR_PAYCHEC, "Подсказка: Для устройства на работу необходимо открыть счет в банке (( /gps - Важные места ))");
	SendClientMessage(playerid, COLOR_PAYCHEC, "Подсказка: Вам необходимо получить водительские права в автошколе (( /gps - Важные места ))");

	return SavePlayer(playerid);
}

stock SavePlayer(playerid) {
	if(PlayerLogged[playerid] != true) return 1;
	query = "";
	format(query,sizeof(query),"UPDATE `"TABLE_ACCOUNT"` SET \
		`Admin` = %d, `AdmKey` = '%s', `Muted` = %d, `Heal` = '%f', `Cash` = %d, `Sex` = %d, `Skin` = %d, `FracSkin` = %d WHERE `Name` = '%s'",
	PI[playerid][pAdmLevel],PI[playerid][pAdmKey],PI[playerid][pMuted],PI[playerid][pHeal],PI[playerid][pCash],PI[playerid][pSex],PI[playerid][pSkin],PI[playerid][pFracSkin],NamePlayer(playerid)
	);
	mysql_query(query, -1, -1, cHandle);
	//
	query = "";
	format(query,sizeof(query),"UPDATE `"TABLE_ACCOUNT"` SET \
		`Level` = %d, `Exp` = %d, `Leader` = %d, `Member` = %d, `Rank` = %d, `Warn` = %d, `Job` = %d, `Jail` = %d, `JailTime` = %d WHERE `Name` = '%s'",
	PI[playerid][pLevel],PI[playerid][pExp],PI[playerid][pLeader],PI[playerid][pMember],PI[playerid][pRank],PI[playerid][pWarn],PI[playerid][pJob],PI[playerid][pJail],PI[playerid][pJailTime],NamePlayer(playerid)
	);
	mysql_query(query, -1, -1, cHandle);
	//
	format(PI[playerid][pInvSlots],60,"%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i",PI[playerid][pInvSlot][0],PI[playerid][pInvSlot][1],PI[playerid][pInvSlot][2],PI[playerid][pInvSlot][3],PI[playerid][pInvSlot][4],PI[playerid][pInvSlot][5],PI[playerid][pInvSlot][6],
	PI[playerid][pInvSlot][7],PI[playerid][pInvSlot][8],PI[playerid][pInvSlot][9],PI[playerid][pInvSlot][10],PI[playerid][pInvSlot][11],PI[playerid][pInvSlot][12],PI[playerid][pInvSlot][13],PI[playerid][pInvSlot][14],PI[playerid][pInvSlot][15],PI[playerid][pInvSlot][16],PI[playerid][pInvSlot][17],
	PI[playerid][pInvSlot][18],PI[playerid][pInvSlot][19]);
	format(PI[playerid][pInvKols],80,"%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i",PI[playerid][pInvKol][0],PI[playerid][pInvKol][1],PI[playerid][pInvKol][2],PI[playerid][pInvKol][3],PI[playerid][pInvKol][4],PI[playerid][pInvKol][5],PI[playerid][pInvKol][6],
	PI[playerid][pInvKol][7],PI[playerid][pInvKol][8],PI[playerid][pInvKol][9],PI[playerid][pInvKol][10],PI[playerid][pInvKol][11],PI[playerid][pInvKol][12],PI[playerid][pInvKol][13],PI[playerid][pInvKol][14],PI[playerid][pInvKol][15],PI[playerid][pInvKol][16],PI[playerid][pInvKol][17],
	PI[playerid][pInvKol][18],PI[playerid][pInvKol][19]);
	format(PI[playerid][pFoods],16,"%i,%i,%i",PI[playerid][pFood][0],PI[playerid][pFood][1],PI[playerid][pFood][2]);
	format(PI[playerid][pItems],32,"%i,%i,%i,%i,%i",PI[playerid][pItem][0],PI[playerid][pItem][1],PI[playerid][pItem][2],PI[playerid][pItem][3],PI[playerid][pItem][4]);
	format(PI[playerid][pPhones],16,"%i,%i,%i",PI[playerid][pPhone][0],PI[playerid][pPhone][1],PI[playerid][pPhone][2]);
	format(PI[playerid][pLics],40,"%i,%i,%i,%i,%i",PI[playerid][pLic][0],PI[playerid][pLic][1],PI[playerid][pLic][2],PI[playerid][pLic][3],PI[playerid][pLic][4]);
	format(PI[playerid][pGunSkills],60,"%i,%i,%i,%i,%i,%i",PI[playerid][pGunSkill][0],PI[playerid][pGunSkill][1],PI[playerid][pGunSkill][2],PI[playerid][pGunSkill][3],PI[playerid][pGunSkill][4],PI[playerid][pGunSkill][5]);
	//
	query = "";
	format(query,sizeof(query),"UPDATE `"TABLE_ACCOUNT"` SET \
		`Phone` = '%s', `Licenses` = '%s', `GunSkills` = '%s', `PayCheck` = %d, `Txt` = %d, `PutMoney` = %d, `FarmLevel` = %d , `FarmSkill` = %d WHERE `Name` = '%s'",
	PI[playerid][pPhones],PI[playerid][pLics],PI[playerid][pGunSkills],PI[playerid][pPayCheck],PI[playerid][pTxt],PI[playerid][pPutMoney],Level[playerid],Skill[playerid],NamePlayer(playerid)
	);
	mysql_query(query, -1, -1, cHandle);
	//
	query = "";
	format(query,sizeof(query),"UPDATE `"TABLE_ACCOUNT"` SET `InvSlots` = '%s', `InvKols` = '%s', `Foods` = '%s', `Items` = '%s' WHERE `Name` = '%s'",PI[playerid][pInvSlots],PI[playerid][pInvKols],PI[playerid][pFoods],PI[playerid][pItems],NamePlayer(playerid));
	mysql_query(query, -1, -1, cHandle);
	//
	format(PI[playerid][pStuff],30,"%i,%i,%i",PI[playerid][pStuf][0],PI[playerid][pStuf][1],PI[playerid][pStuf][2]);
	format(PI[playerid][pJobAmounts],50,"%i,%i,%i",PI[playerid][pJobAmount][0],PI[playerid][pJobAmount][1],PI[playerid][pJobAmount][2]);

	query = "";
	format(query,sizeof(query),"UPDATE `"TABLE_ACCOUNT"` SET `Stuff` = '%s', `JobAmount` = '%s', `Helper` = '%d' WHERE `Name` = '%s'",PI[playerid][pStuff],PI[playerid][pJobAmounts],PI[playerid][pHelpLevel],NamePlayer(playerid));
	mysql_query(query, -1, -1, cHandle);
	//
	query = "";
	format(query,sizeof(query),"UPDATE `"TABLE_ACCOUNT"` SET \
		`Belay` = %d, `WantedTime` = %d, `Wanted` = %d, `HouseMoney` = %d, `HouseDrugs` = %d, `Spining` = %d WHERE `Name` = '%s'",
	PI[playerid][pBelay],PI[playerid][pWantedTime],PI[playerid][pWanted],PI[playerid][pHouseMoney],PI[playerid][pHouseDrugs],PI[playerid][pSpining],NamePlayer(playerid)
	);
	mysql_query(query, -1, -1, cHandle);
	//
	query = "";
	format(query,sizeof(query),"UPDATE `"TABLE_ACCOUNT"` SET \
		`Hotel` = '%d', `HotelNumber` = '%d', `Spawn` = '%d', `Hunger` = %d, `Grain` = '%d', `DonateCash` = '%d' WHERE `Name` = '%s'",
	PI[playerid][pHotel],PI[playerid][pHotelNumber],PI[playerid][pSpawn],PI[playerid][pHunger],PI[playerid][pGrains],PI[playerid][pDonateCash],NamePlayer(playerid)
	);
	mysql_query(query, -1, -1, cHandle);
	//
	query = "";
	format(query,sizeof(query),"UPDATE `"TABLE_ACCOUNT"` SET \
		`Wheels` = %d, `Hydraulics` = %d, `Nitro` = %d, `Spoilers` = %d, `HBumper` = %d, `BBumper` = %d, `Neons` = %d WHERE `Name` = '%s'",
	PI[playerid][pWheels],PI[playerid][pHydraulics],PI[playerid][pNitro],PI[playerid][pSpoilers],PI[playerid][pHBumper],PI[playerid][pBBumper],PI[playerid][pNeons],NamePlayer(playerid)
	);
	mysql_query(query, -1, -1, cHandle);
	//
	query = "";
	format(query,sizeof(query),"UPDATE `"TABLE_ACCOUNT"` SET \
		`Watch` = %d, `Smoke` = %d, `Mask` = %d, `Aptechka`, `Sprunk` = %d, `ArmyBilet` = %d WHERE `Name` = '%s'",
	PI[playerid][pWatch],PI[playerid][pSmoke],PI[playerid][pMask],PI[playerid][pAptechka],PI[playerid][pSprunk],PI[playerid][pArmyBilet],NamePlayer(playerid)
	);
	mysql_query(query, -1, -1, cHandle);
	//
	if(GetPVarInt(playerid, "GunCheat") == 0) {
		for(new i = 0; i < 13; i++)
		GetPlayerWeaponData(playerid, i, PI[playerid][pGun][i], PI[playerid][pAmmo][i]);

		format(PI[playerid][pGuns],40,"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
		PI[playerid][pGun][0],PI[playerid][pGun][1],PI[playerid][pGun][2],PI[playerid][pGun][3],PI[playerid][pGun][4],PI[playerid][pGun][5],
		PI[playerid][pGun][6],PI[playerid][pGun][7],PI[playerid][pGun][8],PI[playerid][pGun][9],PI[playerid][pGun][10],PI[playerid][pGun][11],PI[playerid][pGun][12]);
		format(PI[playerid][pAmmos],128,"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
		PI[playerid][pAmmo][0],PI[playerid][pAmmo][1],PI[playerid][pAmmo][2],PI[playerid][pAmmo][3],PI[playerid][pAmmo][4],PI[playerid][pAmmo][5],
		PI[playerid][pAmmo][6],PI[playerid][pAmmo][7],PI[playerid][pAmmo][8],PI[playerid][pAmmo][9],PI[playerid][pAmmo][10],PI[playerid][pAmmo][11],PI[playerid][pAmmo][12]);
		query = "";
		format(query,sizeof(query),"UPDATE `"TABLE_ACCOUNT"` SET `Guns` = '%s', `Ammos` = '%s' WHERE `Name` = '%s'",PI[playerid][pGuns],PI[playerid][pAmmos],NamePlayer(playerid));
		mysql_query(query, -1, -1, cHandle);
	}
	return 1;
}
//
stock SaveMoyor() {
	format(LicPrices,120,"%i,%i,%i,%i,%i",LicPrice[0],LicPrice[1],LicPrice[2],LicPrice[3],LicPrice[4]);
	format(FracPays,120,"%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i",FracPay[0],FracPay[1],FracPay[2],FracPay[3],FracPay[4],FracPay[5],FracPay[6],FracPay[7],FracPay[8],FracPay[9],FracPay[10],FracPay[11],FracPay[12],FracPay[13],FracPay[14],FracPay[15],FracPay[16],FracPay[17],FracPay[18],FracPay[19]);

	query = "";
	format(query,sizeof(query),"UPDATE `warehouse` SET `LicPrice` = '%s', `FracPay` = '%s', `SAMoney` = %d",LicPrices,FracPays,SAMoney);
	mysql_query(query, -1, -1, cHandle);
	return 1;
}
stock OnPlayerLoginServer(i, password[]) {
	strin = "";
	format(strin, sizeof(strin),"SELECT * FROM "TABLE_ACCOUNT" WHERE `Name` = '%s' AND `Password` = '%s'", NamePlayer(i), password);
	mysql_function_query(cHandle, strin, true, "LoginCallback","d", i);
	return 1;
}
stock SendClientMessageEx(playerid, color, const str[], {Float,_}:...) {
	new
		args,
		start,
		end,
		string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args
	// bу #WАSD 3.O6.2O15
	if (args > 12) {
		#emit ADDR.pri str
		#emit STOR.pri start

		for (end = start + (args - 12); end > start; end -= 4)
		{
			#emit LREF.pri end
			#emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string
		#emit PUSH.C args
		#emit SYSREQ.C format

		SendClientMessage(playerid, color, string);

		#emit LCTRL 5
		#emit SCTRL 4
		#emit RETN
	}
	return SendClientMessage(playerid, color, str);
}
stock SpeedVehicle(playerid) {
	new Float:ST[4];
	if(IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid),ST[0],ST[1],ST[2]);
	else GetPlayerVelocity(playerid,ST[0],ST[1],ST[2]);
	ST[3] = floatsqroot(floatpower(floatabs(ST[0]), 2.0) + floatpower(floatabs(ST[1]), 2.0) + floatpower(floatabs(ST[2]), 2.0)) * 213.3;
	return floatround(ST[3]);
}
stock IsAPlane(carid) {
	new m = GetVehicleModel(carid);
	if(m==592 ||m==577 ||m==511 ||m==512 ||m==593 ||m==520 ||m==553 ||m==476 ||m==519 ||m==460 ||m==513
			||m==548 ||m==417 ||m==487 ||m==488 ||m==497 ||m==563 ||m==447 ||m==469 || m == 548 || m == 425
			|| m == 487 || m == 488 || m == 497) return 1;
	return 0;
}
stock IsABoat(vid) {
	switch(GetVehicleModel(vid)) {
	case 472,473,493,595,484,430,453,452,446,454:return 1;
	}
	return 0;
}
stock SetVehiclePosEx(vehicleid, Float:X, Float:Y, Float:Z) {
	SetVehiclePos(vehicleid ,X,Y,Z);
	UpdateVehiclePos(vehicleid, 0);
}
stock CreateVehicleEx(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2, respawn_delay) {
	new carid = CreateVehicle(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2, respawn_delay);
	VehInfo[carid][vPos][0] = x;
	VehInfo[carid][vPos][1] = y;
	VehInfo[carid][vPos][2] = z;
	VehInfo[carid][vPos][3] = angle;
	VehInfo[carid][vColor1] = color1;
	VehInfo[carid][vColor2] = color2;
	Fuel[carid] = 200;
	Iter_Add(MAX_CARS,carid);
	return carid;
}
stock DestroyVehicleEx(vehicleid) {
	DestroyVehicle(vehicleid);
	Iter_Remove(MAX_CARS, vehicleid);
}
stock ResetCarInfo(playerid) {
	IDVEH[playerid]=-1;
	UseEnter[playerid] = false;
}
stock Punish(playerid) {
	if(InShop[playerid]) return true;
	ResetCarInfo(playerid);
	IDVEH[playerid] = GetPlayerVehicleID(playerid);
	if(CarTPWarn[playerid] > 0) KillTimer(AntiTPTimer[playerid]);
	CarTPWarn[playerid]++;
	AntiTPTimer[playerid] = SetTimerEx("ClearTP", 10000, false, "i", playerid);
	if(CarTPWarn[playerid] == 3) NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (#1225)");
	else strin = "";
	format(strin, 256, "[Античит]: Игрок %s (ID: %i) подозревается в читерстве (TP in CAR)", NamePlayer(playerid), playerid),SendAdminMessage(COLOR_LIGHTRED, strin);
	return true;
}

stock PutPlayerInVehicleEx(playerid, vehicleid, seatid) {
	UseEnter[playerid] = true;
	IDVEH[playerid] = vehicleid;
	PutPlayerInVehicle(playerid, vehicleid, seatid);
	SetTimerEx("AntiNopPutPlayerInVehicle" , 1000, false, "i", playerid);
	return 1;
}
stock RemovePlayerFromVehicleEx(playerid) {
	RemovePlayerFromVehicle(playerid);
	SetTimerEx("AntiRemovePlayerFromVehicle" , 2500, false,"i",playerid);
	return 1;
}
stock ShowLicenses(playerid, SendID) {
	if(!IsPlayerConnected(SendID)) return SendClientMessageEx(playerid, -1, "Данный игрок не подключён.");
	if(PlayerLogged[SendID] == false) return SendClientMessageEx(playerid, -1, "Данный игрок не авторизован.");
	strin = "";
	format(strin,sizeof(strin),"Лицензии %s\n\n{ffffff}Водительские права:\t\t\t%s\n{ffffff}Водный транспорт:\t\t\t%s\n{ffffff}Воздушный транспорт:\t\t%s\n{ffffff}Лицензия на оружие:\t\t\t%s\n{ffffff}Лицензия на бизнес:\t\t\t%s",
	NamePlayer(playerid),
	(!PI[playerid][pLic][0]) ? ("{FF6347}Нет"):("{9ACD32}Да"),
	(!PI[playerid][pLic][1]) ? ("{FF6347}Нет"):("{9ACD32}Да"),
	(!PI[playerid][pLic][2]) ? ("{FF6347}Нет"):("{9ACD32}Да"),
	(!PI[playerid][pLic][3]) ? ("{FF6347}Нет"):("{9ACD32}Да"),
	(!PI[playerid][pLic][4]) ? ("{FF6347}Нет"):("{9ACD32}Да")
	);
	if(playerid == SendID) SPD(playerid,0,0,"{96e300}Ваши лицензии",strin,"Закрыть",""),
	format(strin, 90, "%s осматривает лицензии", NamePlayer(playerid));
	else
	{
		new Float:ppos[3];
		GetPlayerPos(SendID,ppos[0],ppos[1],ppos[2]);
		if(!IsPlayerInRangeOfPoint(playerid, 1.5, ppos[0],ppos[1],ppos[2])) return true;
		SPD(SendID,0,0,"{96e300}Лицензии",strin,"Закрыть",""),
		format(strin, 90, "%s осматривает лицензии %s'a", NamePlayer(SendID),NamePlayer(playerid));
	}
	ProxDetectorNew(playerid,30.0,COLOR_PURPLE,strin);
	return true;
}
stock IsPlayerInBandOnline(bandid) {
	foreach(new i: Player) {
		if(PlayerLogged[i] == false) continue;
		if(PI[i][pMember] == bandid) return 1;
	}
	return 0;
}
stock KickTimerStart(playerid, textkick[]) {
	if(GetPVarInt(playerid, "Kicker") == 1) return true;
	if(strlen(textkick) < 2) return SetPVarInt(playerid, "Kicker", 1), SetTimerEx("Kicking", 1000, false, "d", playerid);
	SetPVarInt(playerid, "Kicker", 1);
	SendClientMessage(playerid,0xff2400FF,textkick);
	SetTimerEx("Kicking", 1000, false, "d", playerid);
	return true;
}
stock FullFura(playerid,i) {
	SendClientMessage(playerid, COLOR_PAYCHEC, "Фургон заполнен, можете ехать!");
	GiveInventory(playerid,37,-200);
	SetVehicleParamsEx(i,false,false, false,false,false,false,false);
	SetPVarInt(playerid,"UseAmmos",0);
	RemovePlayerAttachedObject(playerid, 1);
	ApplyAnimation(playerid,"CARRY","crry_prtial",4.0,0,0,0,0,1,0);
	if(Start[i] == 1) {
		DestroyDynamicPickup(AmmoPickup[i]);
		Delete3DTextLabel(AmmoText[i]);
		Start[i] = 0;
	}
	return 1;
}
stock OpenInventory(playerid) {
	new inv_str[128];

	new Float:health,Float:armour;
	GetPlayerHealth(playerid,health);
	GetPlayerArmour(playerid,armour);

	PlayerTextDrawTextSize(playerid, inv_OtherPTD[playerid][2], _invTM_percent(health), 0.000000);
	PlayerTextDrawTextSize(playerid, inv_OtherPTD[playerid][2], _invTM_percent(armour), 0.000000);
	PlayerTextDrawTextSize(playerid, inv_OtherPTD[playerid][2], _invTM_percent(PI[playerid][pHunger]), 0.000000);

	PlayerTextDrawSetPreviewModel(playerid, inv_OtherPTD[playerid][5], GetPlayerSkin(playerid)),
	PlayerTextDrawSetPreviewRot(playerid, inv_OtherPTD[playerid][5], 0.000000, 0.000000, 27.000000, 0.913106);

    format(inv_str,sizeof(inv_str),"€ѓOPOB’E:_%.0f%~n~ ~n~ЂPOH•:_%.0f%~n~ ~n~C‘TOCT’:_%d%",health, armour, PI[playerid][pHunger]), PlayerTextDrawSetString(playerid,inv_OtherPTD[playerid][3],inv_str);
	format(inv_str,sizeof(inv_str),"~w~%s_(~y~%d~w~)",NamePlayer(playerid),playerid), PlayerTextDrawSetString(playerid,inv_OtherPTD[playerid][4],inv_str);

	for(new i; i < 6; i++) PlayerTextDrawShow(playerid,inv_OtherPTD[playerid][i]);
	for(new i; i < 22; i++) TextDrawShowForPlayer(playerid,inv_BoxTD[i]);
    for(new i; i < 21; i++) {
	    PlayerTextDrawShow(playerid,inv_SlotsPTD[playerid][i]);
        if(PI[playerid][pInvSlot][i] == 0) PlayerTextDrawSetPreviewModel(playerid,inv_SlotsPTD[playerid][i + 1], 19461),PlayerTextDrawSetPreviewRot(playerid, inv_SlotsPTD[playerid][i + 1], 0.000000, 0.000000, 0.000000, 88.000000);
        else PlayerTextDrawSetPreviewModel(playerid,inv_SlotsPTD[playerid][i + 1], Items_All[PI[playerid][pInvSlot][i]][invObject]),PlayerTextDrawSetPreviewRot(playerid, inv_SlotsPTD[playerid][i + 1], Items_All[PI[playerid][pInvSlot][i]][POSTDx], Items_All[PI[playerid][pInvSlot][i]][POSTDy], Items_All[PI[playerid][pInvSlot][i]][POSTDz], Items_All[PI[playerid][pInvSlot][i]][POSTDc]);
	    PlayerTextDrawBackgroundColor(playerid, inv_SlotsPTD[playerid][i + 1], -86);
	}
	return 1;
}

stock ObjInventory(playerid) {
    if(GetPVarInt(playerid,"ChangeSlot") == GetPVarInt(playerid,"SelectSlot")) return SetPVarInt(playerid,"ChangeSlot",0);
	if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] != 0 && PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] != PI[playerid][pInvSlot][GetPVarInt(playerid,"ChangeSlot") - 1]) return SetPVarInt(playerid,"ChangeSlot",0);
    if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == PI[playerid][pInvSlot][GetPVarInt(playerid,"ChangeSlot") - 1]) {
        PI[playerid][pInvSlot][GetPVarInt(playerid,"ChangeSlot") - 1] = 0;
        PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] += PI[playerid][pInvKol][GetPVarInt(playerid,"ChangeSlot") - 1];
        PI[playerid][pInvKol][GetPVarInt(playerid,"ChangeSlot") - 1] = 0;
    }
	if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] == 0) {
        PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = PI[playerid][pInvSlot][GetPVarInt(playerid,"ChangeSlot") - 1];
        PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = PI[playerid][pInvKol][GetPVarInt(playerid,"ChangeSlot") - 1];
        PI[playerid][pInvSlot][GetPVarInt(playerid,"ChangeSlot") - 1] = 0;
        PI[playerid][pInvKol][GetPVarInt(playerid,"ChangeSlot") - 1] = 0;
    }
	return 1;
}

stock UpdateInventory(playerid) {
    if(GetPVarInt(playerid,"ChangeSlot") == GetPVarInt(playerid,"SelectSlot")) return SetPVarInt(playerid,"ChangeSlot",0);
	if(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] != 0 && PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] != PI[playerid][pInvSlot][GetPVarInt(playerid,"ChangeSlot") - 1]) return SetPVarInt(playerid,"ChangeSlot",0);
    if(PI[playerid][pInvSlot][GetPVarInt(playerid,"ChangeSlot") - 1] != 0) {
	    PlayerTextDrawSetPreviewModel(playerid,inv_SlotsPTD[playerid][GetPVarInt(playerid,"ChangeSlot")], 19461),PlayerTextDrawSetPreviewRot(playerid, inv_SlotsPTD[playerid][GetPVarInt(playerid,"ChangeSlot")], 0.000000, 0.000000, 0.000000, 88.000000);
		PlayerTextDrawBackgroundColor(playerid, inv_SlotsPTD[playerid][GetPVarInt(playerid,"SelectSlot")], -86);
     	PlayerTextDrawSetPreviewModel(playerid,inv_SlotsPTD[playerid][GetPVarInt(playerid,"SelectSlot")], Items_All[PI[playerid][pInvSlot][GetPVarInt(playerid,"ChangeSlot") - 1]][invObject]);
		PlayerTextDrawSetPreviewRot(playerid, inv_SlotsPTD[playerid][GetPVarInt(playerid,"SelectSlot")], Items_All[PI[playerid][pInvSlot][GetPVarInt(playerid,"ChangeSlot") - 1]][POSTDx], Items_All[PI[playerid][pInvSlot][GetPVarInt(playerid,"ChangeSlot") - 1]][POSTDy], Items_All[PI[playerid][pInvSlot][GetPVarInt(playerid,"ChangeSlot") - 1]][POSTDz], Items_All[PI[playerid][pInvSlot][GetPVarInt(playerid,"ChangeSlot") - 1]][POSTDc]);
     	PlayerTextDrawShow(playerid,inv_SlotsPTD[playerid][GetPVarInt(playerid,"ChangeSlot")]);
	    PlayerTextDrawShow(playerid,inv_SlotsPTD[playerid][GetPVarInt(playerid,"SelectSlot")]);
	}
	return 1;
}

stock GiveInventoryRavno(playerid, item, amount) {
	for(new i = 0; i < MAX_ITEMS; i++) {
        if(PI[playerid][pInvSlot][i] != 0) continue;
        PI[playerid][pInvSlot][i] = item;
        PI[playerid][pInvKol][i] = amount;
        switch(item) {
		case 1: PI[playerid][pAptechka] = amount;
		case 2: PI[playerid][pWatch] = 1;
		case 3: PI[playerid][pMask] = amount;
		case 5: PI[playerid][pShield] = 100.0,SetPlayerAttachedObject(playerid, 6, 18637, 1, 0.15, -0.05, 0.18, 90, 0, 270);
		case 9: PI[playerid][pPhone][0] = 1;
		case 35: PI[playerid][pStuf][0] = amount;
		case 36: PI[playerid][pStuf][1] = amount;
		case 37: PI[playerid][pStuf][2] = amount;
        }
		return true;
	}
	return false;
}
stock GiveInventory(playerid, item, amount) {
    for(new i = 0; i < MAX_ITEMS; i++) {
        if(PI[playerid][pInvSlot][i] != item) continue;
        PI[playerid][pInvKol][i] += amount;
        switch(item) {
		case 1: PI[playerid][pAptechka] += amount;
		case 2: PI[playerid][pWatch] = 1;
		case 3: PI[playerid][pMask] += amount;
		case 5: PI[playerid][pShield] = 100.0,SetPlayerAttachedObject(playerid, 6, 18637, 1, 0.15, -0.05, 0.18, 90, 0, 270);
		case 9: PI[playerid][pPhone][0] = 1;
		case 35: PI[playerid][pStuf][0] += amount;
		case 36: PI[playerid][pStuf][1] += amount;
		case 37: PI[playerid][pStuf][2] += amount;
        }
        return true;
    }
    for(new i = 0; i < MAX_ITEMS; i++) {
        if(PI[playerid][pInvSlot][i] != 0) continue;
        PI[playerid][pInvSlot][i] = item;
        PI[playerid][pInvKol][i] = amount;
        switch(item) {
		case 1: PI[playerid][pAptechka] = amount;
		case 2: PI[playerid][pWatch] = 1;
		case 3: PI[playerid][pMask] = amount;
		case 5: PI[playerid][pShield] = 100.0,SetPlayerAttachedObject(playerid, 6, 18637, 1, 0.15, -0.05, 0.18, 90, 0, 270);
		case 9: PI[playerid][pPhone][0] = 1;
		case 35: PI[playerid][pStuf][0] = amount;
		case 36: PI[playerid][pStuf][1] = amount;
		case 37: PI[playerid][pStuf][2] = amount;
        }
        return true;
    }
	return false;
}
stock DropInventory(playerid) {
	for(new i; i < MAX_OBJECT; i++) {
		if(ObjectInv[i][obiDrop][0] == 0) {
			new Float:x,Float:y,Float:z;
			GetPlayerPos(playerid,x,y,z);
			ObjectInv[i][obiDrop][0] = PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1];
			ObjectInv[i][obiDrop][1] = PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1];
			ObjectInv[i][obiDropPos][0] = x;
			ObjectInv[i][obiDropPos][1] = y;
			ObjectInv[i][obiDropPos][2] = z;
			switch(PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1]) {
			    case 1: PI[playerid][pAptechka] = 0;
			    case 2: PI[playerid][pWatch] = 0;
			    case 3: PI[playerid][pMask] = 0;
			    case 4: PI[playerid][pSprunk] = 0;
			    case 5: PI[playerid][pShield] = 0.0,RemovePlayerAttachedObject(playerid, 6),UsingShield[playerid] = false;
			    case 6: PI[playerid][pFood][0] = 0;
			    case 7: PI[playerid][pFood][1] = 0;
			    case 8: PI[playerid][pFood][2] = 0;
			    case 9: PI[playerid][pPhone][0] = 0;
			    case 35: PI[playerid][pStuf][0] = 0;
			    case 36: PI[playerid][pStuf][1] = 0;
			    case 37: PI[playerid][pStuf][2] = 0;
			}
			ObjectInv[i][obiObject] = CreateObject(Items_All[PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1]][invObject], ObjectInv[i][obiDropPos][0], ObjectInv[i][obiDropPos][1], ObjectInv[i][obiDropPos][2]-1, 80.0, 0.0, 0.0);
			PI[playerid][pInvSlot][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			PI[playerid][pInvKol][GetPVarInt(playerid,"SelectSlot") - 1] = 0;
			SetPVarInt(playerid,"SelectSlot",0);
			SetPVarInt(playerid,"ChangeSlot",0);
			OpenInventory(playerid);
			break;
		}
	}
}
stock NullFishJob(playerid) {
	if(GetPVarInt(playerid,"FishJob") == JOB_KRUB) {
		SetPlayerSkin(playerid, GetPVarInt(playerid,"FishSkin"));
		DeletePVar(playerid,"FishSkin");
		DeletePVar(playerid,"FishJob");
		DeletePVar(playerid,"FishCP");
		DisablePlayerCheckpoint(playerid);
		pirsinfo[GetPVarInt(playerid, "jobkrub_numberPirs")][statusp] = false;
		strdel(pirsinfo[GetPVarInt(playerid, "jobkrub_numberPirs")][renter], 0, 24);
		strin = "";
		format(strin, 96, "%i пирс: свободен", GetPVarInt(playerid, "jobkrub_numberPirs")+1);
		SetDynamicObjectMaterialText(PirsTable[GetPVarInt(playerid, "jobkrub_numberPirs")], 0, strin, 130, "Arial", 34, 1, -1, 0, 1);

		format(strin, 96, "Пирс №%i: -", GetPVarInt(playerid, "jobkrub_numberPirs")+1);
		UpdateDynamic3DTextLabelText(pirsinfo[GetPVarInt(playerid, "jobkrub_numberPirs")][renter_3d], 0xFFFFCCFF, strin);
		DeletePVar(playerid, "jobkrub_numberPirs");
		DeletePVar(playerid, "jobkrub_numberMarshrut");
		DeletePVar(playerid, "jobkrub_step");
		DeletePVar(playerid, "jobkrub_price");
		for(new i = 0; i < 6; i++) if(objectsOnCar_krubjob[playerid][i] != 0)DestroyDynamicObject(objectsOnCar_krubjob[playerid][i]);
		//			for(new i = 0; i < GetPVarInt(playerid, "jobkrub_putcage_point_count"); i++) DestroyDynamicObject(objectsOnCar_krubjob[playerid][i]);
		return 1;
	}
	else if(GetPVarInt(playerid,"FishJob") == JOB_MIDIA) {
		SetPlayerSkin(playerid, GetPVarInt(playerid,"FishSkin"));
		DeletePVar(playerid,"FishSkin");
		if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);
		DeletePVar(playerid,"FishJob");
		DeletePVar(playerid,"FishOxygen");
		DeletePVar(playerid,"midii");
		DeletePVar(playerid,"FishRCP");
		DisablePlayerRaceCheckpoint(playerid);
		PlayerTextDrawDestroy(playerid, PTD_midii[playerid]);
		DestroyPlayerProgressBar(playerid, boxygen[playerid]);
		PlayerTextDrawDestroy(playerid, PTD_oxygen[playerid]);
		boxygen[playerid] = INVALID_PLAYER_BAR_ID;
		return 1;
	}
	return true;
}
stock GeneratePassword(size) {
	new bigletters[26][] = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"},
	smallletters[26][] = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"},
	numbers[10][] = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"},
	password[128];
	if(size > sizeof(password)) size = sizeof(password);
	for(new i = 0; i < size; i ++) {
		switch(random(3))
		{
		case 0: strcat(password, bigletters[random(sizeof(bigletters))]);
		case 1: strcat(password, smallletters[random(sizeof(smallletters))]);
		case 2: strcat(password, numbers[random(sizeof(numbers))]);
		}
	}
	return password;
}
stock IsTowCar(vehicleid) {
	if(vehicleid >= mechanics[0] && vehicleid <= mechanics[9]) return 1;
	return 0;
}
stock AdvertList(playerid) {
	strin = "";
	for(new i = 1; i <= TOTALADVERT[0];i++) {
		format(strin, sizeof(strin), "№%i - Прислал: %s\n",i, AI[i][aName]);
		strcat(strin, strin);
	}
	if(TOTALADVERT[0] == 0) return SPD(playerid, 0, 0, "Объявления", "Нет объявлений для проверки!", "Закрыть", "");
	SPD(playerid, D_NMENU+5, 2, "Объявления", strin, "Принять", "Отмена");
	return true;
}
stock NewsPanel(playerid) {
	strin = "";
	format(strin, 512, "Объявления - %i",TOTALADVERT);
	new full;
	switch(PI[playerid][pMember]) {
	case F_SAN: full = 0;
	}
	format(strin, 512, "%s\n{9ACD32}- Пригласить в эфир\n{FF6347}- Выпроводить из эфира\n%s\n%s\n{9ACD32}- Объявления [Новых %i]", !Ether[playerid] ? ("{9ACD32}- Войти в эфир") : ("{FF6347}- Выйти из эфира"),
	!EtherCall[full] ? ("{9ACD32}- Включить прием звонков в эфир") : ("{FF6347}- Выключить прием звонков в эфир"),
	!EtherSms[full] ? ("{9ACD32}- Включить прием смс в эфир") : ("{FF6347}- Выключить прием смс в эфир"),TOTALADVERT[full]);
	SPD(playerid, D_NMENU, 2, "San Andreas News", strin, "Принять", "Отмена");
	return true;
}
stock StartSpecPanel(playerid, specid) {
	if(PI[playerid][pAdmLevel] < 1 || !IsPlayerConnected(specid)) return true;
	new Float:Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	if(GetPVarInt(playerid, "Spectrate") == 0) {
		SetPVarFloat(playerid, "PosSpecX", Pos[0]); SetPVarFloat(playerid, "PosSpecY", Pos[1]); SetPVarFloat(playerid, "PosSpecZ", Pos[2]);
		SetPVarInt(playerid, "SpecInt", GetPlayerInterior(playerid)); SetPVarInt(playerid, "SpecVT", GetPlayerVirtualWorld(playerid));
	}
	SpecPanelOpen(playerid);
	TogglePlayerSpectating(playerid, 1);
	SetPVarInt(playerid, "SpecID", specid);
	SetPVarInt(playerid, "Spectrate", 1);
	SetPlayerInterior(playerid, GetPlayerInterior(specid));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(specid));
	if(!IsPlayerInAnyVehicle(specid)) return PlayerSpectatePlayer(playerid, specid);
	else return PlayerSpectateVehicle(playerid, GetPlayerVehicleID(specid));
}
stock StopRecon(playerid, reason[]) {
	if(PI[playerid][pAdmLevel] < 1 || GetPVarInt(playerid, "Spectrate") == 0) return true;
	SetSpawnInfo(playerid, 255, PI[playerid][pFracSkin], 0, 0, 0, 1.0, -1, -1, -1, -1, -1, -1);
	SpawnPlayer(playerid);
	KillTimer(ReconTimer);
	TogglePlayerSpectating(playerid, 0);
	DeletePVar(playerid, "SpecID");
	GameTextForPlayer(playerid, reason, 1500, 4);
	return true;
}
stock SpecPanelOpen(playerid) {
	ReconTimer = SetTimerEx("UpdateSpecPanel", 1000, true, "d", playerid);
	for(new i;i<16;i++) PlayerTextDrawShow(playerid, SpecTD[i][playerid]);
}
stock SpecPanelClose(playerid) {
	KillTimer(ReconTimer);
	if(PI[playerid][pFracSkin] > 0) SetPlayerSkin(playerid,PI[playerid][pFracSkin]);
	else SetPlayerSkin(playerid, PI[playerid][pSkin]);
	SetPlayerTeamColor(playerid);
	for(new i;i<16;i++) PlayerTextDrawHide(playerid, SpecTD[i][playerid]);
	SpawnPlayer(playerid);
	return true;
}
stock SlapPlayer(ids) {
	new Float:Pos[3];
	GetPlayerPos(ids, Pos[0], Pos[1], Pos[2]);
	t_SetPlayerPos(ids, Pos[0], Pos[1], Pos[2] + 8);
	PlayerPlaySound(ids, 1130, Pos[0], Pos[1], Pos[2] + 5);
	return true;
}
stock GetCoordBootVehicle(vehicleid, &Float:x, &Float:y, &Float:z) {
	new Float:angle,Float:distance;
	GetVehicleModelInfo(GetVehicleModel(vehicleid), 1, x, distance, z);
	distance = distance/2 + 0.1;
	GetVehiclePos(vehicleid, x, y, z);
	GetVehicleZAngle(vehicleid, angle);
	x += (distance * floatsin(-angle+180, degrees));
	y += (distance * floatcos(-angle+180, degrees));
	return 1;
}
stock UpdateGardenAllCPs() {
	foreach(new i : Player) {
		for(new x; x < 76; x++) {
			if(GardenCheckpoints[x] != 0) {
				if(GetPVarInt(i,"Collector") == 0)TogglePlayerDynamicCP(i, GardenCheckpoints[x], 0);
				else TogglePlayerDynamicCP(i, GardenCheckpoints[x], 1);
			}
		}
	}
}
stock SetPlayerArmorAC(playerid, Float: Armor) {
	if(IsPlayerConnected(playerid)) PlayerArmor[playerid] = Armor,SetPlayerArmour(playerid, Armor);
	return 1;
}
stock UpdatePlayerShield(playerid,Float:amount) {
	new Float:Shield = amount/1.74;
	if(Shield > 57.5) Shield = 57.5;
	else if(Shield < 0.0) Shield = 0.0;
	PlayerTextDrawHide(playerid, ShieldBar[playerid]);
	PlayerTextDrawDestroy(playerid, ShieldBar[playerid]);
	ShieldBar[playerid] = CreatePlayerTextDraw(playerid,550.5+Shield,59.6,"_");//Max - 608.0 | Min - 550.5
	PlayerTextDrawLetterSize(playerid, ShieldBar[playerid],0.0,0.135);
	PlayerTextDrawUseBox(playerid, ShieldBar[playerid],1);
	PlayerTextDrawBoxColor(playerid, ShieldBar[playerid],0x6053F3FF);
	PlayerTextDrawTextSize(playerid, ShieldBar[playerid],546.0,0.0);
	if(amount <= 0) HideSHBarForPlayer(playerid);
	return true;
}
stock ShowSHBarForPlayer(playerid, Float:amount) {
	if(amount > 0) {
		PlayerTextDrawShow(playerid, ShieldBar[playerid]);
		TextDrawShowForPlayer(playerid, ShieldBG[0]);
		TextDrawShowForPlayer(playerid, ShieldBG[1]);
		return true;
	}
	return false;
}
stock HideSHBarForPlayer(playerid) {
	PlayerTextDrawHide(playerid, ShieldBar[playerid]);
	TextDrawHideForPlayer(playerid, ShieldBG[0]);
	TextDrawHideForPlayer(playerid, ShieldBG[1]);
	return true;
}
stock gtimestamp_to_date(unix_timestamp = 0,&year = 1970,&month = 1,&day  = 1,&hour =  0,&minute = 0,&second = 0) {
	year = unix_timestamp / 31557600;
	unix_timestamp -= year * 31557600;
	year += 1970;
	if ( year % 4 == 0 ) unix_timestamp -= 21600;
	day = unix_timestamp / 86400;
	switch ( day ) {
	case  0..30 : { second = day;    month = 1; }
	case  31..58 : { second = day - 31; month = 2; }
	case  59..89 : { second = day - 59; month = 3; }
	case 90..119 : { second = day - 90; month = 4; }
	case 120..150 : { second = day - 120; month = 5; }
	case 151..180 : { second = day - 151; month = 6; }
	case 181..211 : { second = day - 181; month = 7; }
	case 212..242 : { second = day - 212; month = 8; }
	case 243..272 : { second = day - 243; month = 9; }
	case 273..303 : { second = day - 273; month = 10; }
	case 304..333 : { second = day - 304; month = 11; }
	case 334..366 : { second = day - 334; month = 12; }
	}
	unix_timestamp -= day * 86400;
	hour = unix_timestamp / 3600;
	unix_timestamp -= hour * 3600;
	minute = unix_timestamp / 60;
	unix_timestamp -= minute * 60;
	day = second + 1;
	second = unix_timestamp;
	strin = "";
	format(strin,30,"%d.%d.%d %d:%d:%d",day,month,year,hour,minute,second);
}
stock BuyCar(playerid, idx) {
	new cost[MAX_PLAYERS], model[MAX_PLAYERS];
	switch(InShop[playerid]) {
	case 1: cost[playerid]=Cars_C[pPressed[playerid]][1], model[playerid] = Cars_C[pPressed[playerid]][0];
	}
	if(GetMoney(playerid) < cost[playerid]) return SendClientMessage(playerid, COLOR_GREY, "У Вас нет столько денег!");
	CancelSelectTextDraw(playerid);
	InShop[playerid] = 0;
	SetPVarInt(playerid, "AntiBreik", 3);
	TogglePlayerControllable(playerid,1);
	GiveMoney(playerid, -cost[playerid]);
	for(new i; i < 10; i++) PlayerTextDrawHide(playerid, AutoSalonTD[i][playerid]);
	t_SetPlayerPos(playerid,546.9677,-1304.2036,16.3125);
	SetPlayerFacingAngle(playerid, 187.9844);
	SetPlayerInterior(playerid,0);
	SetPlayerVirtualWorld(playerid,0);
	SetCameraBehindPlayer(playerid);
	PI[playerid][pWheels] = 0; PI[playerid][pSpoilers] = 0; PI[playerid][pHydraulics] = 0; PI[playerid][pHBumper] = 0; PI[playerid][pBBumper] = 0; PI[playerid][pNitro] = 0; PI[playerid][pNeons] = 0;
	TOTALCARS++;
	new Float:RandCarSpawn[5][6] = {
		{560.5084,-1278.2411,15.7517,11.0112},
		{556.8583,-1279.3284,15.7553,11.0112},
		{553.3029,-1280.1244,15.7563,11.0112},
		{549.5696,-1281.0592,15.7582,11.0112},
		{545.6177,-1281.8063,15.7581,11.0112}
	};
	new RSpawn = random(5);
	CarInfo[TOTALCARS][cX] = RandCarSpawn[RSpawn][0];
	CarInfo[TOTALCARS][cY] = RandCarSpawn[RSpawn][1];
	CarInfo[TOTALCARS][cZ] = RandCarSpawn[RSpawn][2];
	CarInfo[TOTALCARS][cFa] = RandCarSpawn[RSpawn][3];
	strmid(CarInfo[TOTALCARS][cOwner],NamePlayer(playerid),0,strlen(NamePlayer(playerid)),MAX_PLAYER_NAME);
	CarInfo[TOTALCARS][cModel] = model[playerid];
	CarInfo[TOTALCARS][cLock] = 1;
	new colors[2];
	colors[0] = random(10);
	colors[1] = random(10);
	if(GetPVarInt(playerid,"_selectedColor") != 0) {
		colors[0] = GetPVarInt(playerid,"_selectedColor"),colors[1] = GetPVarInt(playerid,"_selectedColor");
	}
	CarInfo[TOTALCARS][cColor][0] = colors[0];
	CarInfo[TOTALCARS][cColor][1] = colors[1];
	CarInfo[TOTALCARS][cFuel] = 200;
	CarInfo[TOTALCARS][id] = TOTALCARS;
	if(PI[playerid][pPremium] < gettime()) PI[playerid][pCars][(PI[playerid][pCars][0]==0)?0:1] = CarInfo[TOTALCARS][id];
	else {
		if(PI[playerid][pCars][0]==0) PI[playerid][pCars][0] = CarInfo[TOTALCARS][id];
		else PI[playerid][pCars][(PI[playerid][pCars][1]==0)?1:2] = CarInfo[TOTALCARS][id];
	}
	format(CarInfo[TOTALCARS][cColors], 16, "%d, %d",CarInfo[TOTALCARS][cColor][0],CarInfo[TOTALCARS][cColor][1]);
	strmid(CarInfo[TOTALCARS][cOwner],NamePlayer(playerid),0,strlen(NamePlayer(playerid)),MAX_PLAYER_NAME);
	query = "";
	format(query,sizeof(query),"INSERT INTO "TABLE_CARS" (id,owner,clock,model,colors,fuel,x,y,z,fa) VALUES (%d,'%s',%d,%d,'%s',%d,'%f','%f','%f','%f')",TOTALCARS,CarInfo[TOTALCARS][cOwner],CarInfo[TOTALCARS][cLock],CarInfo[TOTALCARS][cModel],CarInfo[TOTALCARS][cColors],CarInfo[TOTALCARS][cFuel],CarInfo[TOTALCARS][cX],CarInfo[TOTALCARS][cY],CarInfo[TOTALCARS][cZ],CarInfo[TOTALCARS][cFa]);
	mysql_function_query(cHandle, query, false, "", "");
	CarInfo[idx][cFuel] = 150;
	CarInfo[idx][cColor][0]=ColorVeh[playerid][0];
	CarInfo[idx][cColor][1]=ColorVeh[playerid][1];
	CarInfo[idx][id] = idx;
	CarInfo[TOTALCARS][cID] = CreateVehicle(CarInfo[TOTALCARS][cModel], CarInfo[TOTALCARS][cX], CarInfo[TOTALCARS][cY], CarInfo[TOTALCARS][cZ], CarInfo[TOTALCARS][cFa], CarInfo[TOTALCARS][cColor][0], CarInfo[TOTALCARS][cColor][1], 90000);
	strin = "";
	format(strin, sizeof(strin), "{ff4f00}Владелец: {ffffff}%s\n{ff4f00}ID: {ffffff}%d", CarInfo[TOTALCARS][cOwner], CarInfo[TOTALCARS][cID]);
	CarInfo[TOTALCARS][cText] = Create3DTextLabel(strin, 0x33AAFFFF, 0.0, 0.0, 0.0, 50.0, 0, 1);
	Attach3DTextLabelToVehicle(CarInfo[TOTALCARS][cText], CarInfo[TOTALCARS][cID], 0.0, 0.0, 1.25);
	format(CarInfo[idx][cColors], 16, "%d, %d",CarInfo[idx][cColor][0],CarInfo[idx][cColor][1]);
	strmid(CarInfo[idx][cOwner],NamePlayer(playerid),0,strlen(NamePlayer(playerid)),MAX_PLAYER_NAME);
	SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы купили транспорт: %s за %d$. (( Автообиль припаркован у автосалона))",VehicleNameS[GetVehicleModel(BuyVeh[playerid])-400],cost[playerid]);
	DestroyVehicle(BuyVeh[playerid]);
	query = "";
	format(query, sizeof(query), "UPDATE "TABLE_CARS" SET clock = %i, model = %i,colors = '%s', x = '%f', y='%f', z='%f', fa='%f', fuel = %i WHERE id = %i",CarInfo[idx][cLock],CarInfo[idx][cModel],CarInfo[idx][cColors],CarInfo[idx][cX], CarInfo[idx][cY], CarInfo[idx][cZ], CarInfo[idx][cFa], CarInfo[idx][cFuel], idx);
	mysql_function_query(cHandle, query, false, "", "");
	LoadMyCar(playerid);
	DeletePVar(playerid,"_selectedColor");
	return 1;
}
stock J_SetPlayerDamageHealth(playerid,Float:health) {
	if(health < 0.0) health = 0.0;
	if(SetPlayerHealth(playerid,health)) { PI[playerid][pHeal] = health; DamageHealth[playerid] = health; return 1; }
	return false;
}
stock J_SetPlayerDamageArmour(playerid,Float:armour) {
	if(armour < 0.0) armour = 0.0;
	if(SetPlayerArmour(playerid,armour)) { PI[playerid][pArmur] = armour; DamageArmour[playerid] = armour; return 1; }
	return false;
}
stock CloseLoginPanel(playerid) {
	for(new i;i<16;i++) PlayerTextDrawDestroy(playerid,RegDraws[i][playerid]);
	t_SetPlayerPos(playerid, 1750.0978,-1258.1825,378.4566);
	SetPlayerCameraPos(playerid, 1750.0978,-1258.1825,378.4566);
	SetPlayerCameraLookAt(playerid, 1619.6040,-1381.2323,316.0449);
	CancelSelectTextDraw(playerid);
	PlayerLogin[playerid] = 0;
	return true;
}
stock ClickContinue(playerid) {
	if(PlayerRegs[playerid] > 0) {
		if(PlayerRegister[0][playerid] == 0) return SendClientMessage(playerid,COLOR_LIGHTRED,"Заполнены не все поля!");
		if(PlayerRegister[1][playerid] == 0) return SendClientMessage(playerid,COLOR_LIGHTRED,"Заполнены не все поля!");
		if(PlayerRegister[2][playerid] == 0) return SendClientMessage(playerid,COLOR_LIGHTRED,"Заполнены не все поля!");
		PlayerRegs[playerid] = 0;
		GetPlayerIp(playerid,PI[playerid][pRegIp],16);
		GetPVarString(playerid,"RegPass",PI[playerid][pPassword],128);
		GetPVarString(playerid,"RegMail",PI[playerid][pEmail],64);
		ClothesRound[playerid] = 1; PlayerLogged[playerid] = true;
		SetSpawnInfo(playerid, 0, 0, 1480.0984,-1369.8914,121.9811,266.7302, 0, 0, 0, 0, 0, 0);
		SpawnPlayer(playerid);
	}
	if(PlayerLogin[playerid] > 0) {
		if(PlayerLogins[0][playerid] == 0) return SendClientMessage(playerid,COLOR_LIGHTRED,"Заполнены не все поля!");
		if(PlayerLogins[1][playerid] == 0) return SendClientMessage(playerid,COLOR_LIGHTRED,"Заполнены не все поля!");
		PlayerLogin[playerid] = 0;
		SetTimerEx("Unfreez",3100,false,"i",playerid);
	}
	KillTimer(EnterTimer[playerid]);
	EnterTimer[playerid] = SetTimerEx("PlayerKick",240000,false,"d",playerid);
	CancelSelectTextDraw(playerid);
	return true;
}

stock ExitTuning(playerid) {
	SetPVarInt(playerid,"TuningCar",0);
	InTuning[playerid] = 0;
	for(new i; i < 11; i++) PlayerTextDrawHide(playerid,TuningTD[i][playerid]);
	NullComponents(playerid),TuningCamera(playerid),SetCameraBehindPlayer(playerid);
	SetVehiclePosEx(GetPlayerVehicleID(playerid), 691.3149,-1568.6337,14.5905);
	return 1;
}
stock TuningCamera(playerid) {
	SetPlayerCameraLookAt(playerid,2222.7085,-2529.8962,2052.1497);
	if(GetPVarInt(playerid,"Selected1") == 0) SetCameraBehindPlayer(playerid);
	else if(GetPVarInt(playerid,"Selected1") == 1) SetPlayerCameraPos(playerid,2220.5288,-2526.0508,2052.4458);
	else if(GetPVarInt(playerid,"Selected1") == 2) SetPlayerCameraPos(playerid,2224.0405,-2533.5942,2052.4458);
	else if(GetPVarInt(playerid,"Selected1") == 3) SetPlayerCameraPos(playerid,2220.7229,-2525.9919,2052.4458);
	else if(GetPVarInt(playerid,"Selected1") == 4) SetPlayerCameraPos(playerid,2222.5396,-2525.3142,2052.4458);
	else if(GetPVarInt(playerid,"Selected1") == 5) SetPlayerCameraPos(playerid,2222.4316,-2534.9326,2052.4434);
	else if(GetPVarInt(playerid,"Selected1") == 6) SetPlayerCameraPos(playerid,2222.8474,-2533.4060,2052.4434);
	else if(GetPVarInt(playerid,"Selected1") == 7) SetPlayerCameraPos(playerid,2219.7971,-2532.9419,2052.4434);
}
stock LoadTuningCar(playerid) {
	if(PI[playerid][pNitro] == 1009 || PI[playerid][pNitro] == 1008 || PI[playerid][pNitro] == 1010) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),PI[playerid][pNitro]);
	if(PI[playerid][pWheels] != 0) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),PI[playerid][pWheels]);
	if(PI[playerid][pHBumper] != 0) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),PI[playerid][pHBumper]);
	if(PI[playerid][pBBumper] != 0) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),PI[playerid][pBBumper]);
	if(PI[playerid][pSpoilers] != 0) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),PI[playerid][pSpoilers]);
	if(PI[playerid][pHydraulics] != 0) AC_AddVehicleComponent(GetPlayerVehicleID(playerid),PI[playerid][pHydraulics]);
	if(PI[playerid][pNeons] != 0) {
		NeonObject[playerid][0] = CreateDynamicObject(PI[playerid][pNeons],0,0,0,0,0,0,-1,-1,-1,150.0);
		AttachDynamicObjectToVehicle(NeonObject[playerid][0], GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
		NeonObject[playerid][1] = CreateDynamicObject(PI[playerid][pNeons],0,0,0,0,0,0,-1,-1,-1,150.0);
		AttachDynamicObjectToVehicle(NeonObject[playerid][1], GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
	}
}
stock NullComponentid(playerid) {
	new componentid;
	for (new i; i < 14; i++){
		componentid = GetVehicleComponentInSlot(GetPlayerVehicleID(playerid), i);
		if (componentid != 0) AC_RemoveVehicleComponent(GetPlayerVehicleID(playerid), componentid);
		DestroyDynamicObject(NeonObject[playerid][0]),DestroyDynamicObject(NeonObject[playerid][1]);
		LoadTuningCar(playerid);
	}
	return 1;
}
stock NullComponents(playerid) {
	SetPVarInt(playerid,"Nitro",0);
	SetPVarInt(playerid,"Wheels",0);
	SetPVarInt(playerid,"Hydraulics",0);
	SetPVarInt(playerid,"Spoilers",0);
	SetPVarInt(playerid,"HBumper",0);
	SetPVarInt(playerid,"BBumper",0);
}
stock MenuFishOpen(playerid) {
	for(new i; i < 10; i++) PlayerTextDrawShow(playerid, FishTD[i][playerid]);
	return true;
}
stock MenuFishClose(playerid) {
	for(new i; i < 10; i++) PlayerTextDrawHide(playerid, FishTD[i][playerid]),MenuFish[playerid] = 0;
	return true;
}
stock CloseAB(playerid) {
	if(InShop[playerid]) {
		SetPVarInt(playerid, "AntiBreik", 3);
		DestroyVehicle(BuyVeh[playerid]);
		for(new i; i < 10; i++) PlayerTextDrawHide(playerid, AutoSalonTD[i][playerid]);
		t_SetPlayerPos(playerid,546.9677,-1304.2036,16.3125);
		SetPlayerFacingAngle(playerid, 187.9844);
		TogglePlayerControllable(playerid,0);
		SetTimerEx("Unfreez",2500,false,"i",playerid);
		SetPlayerInterior(playerid,0);
		SetPlayerVirtualWorld(playerid,0);
		SetCameraBehindPlayer(playerid);
	}
	return 1;
}
stock StartEngine(playerid) {
	if(PlayerLogged[playerid] != true || InShop[playerid] > 0) return 1;
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;
	if(GetPVarInt(playerid,"ENgined") == gettime()) return 1;
	SetPVarInt(playerid,"ENgined",gettime());
	new veID = GetPlayerVehicleID(playerid);
	if(GetVehicleModel(veID) != 481 && GetVehicleModel(veID) != 509 && GetVehicleModel(veID) != 510) {
		if(Fuel[veID] <= 0) return SendClientMessage(playerid, COLOR_GREY, "В авто нет бензина!");
		new Float:vehhealth;
		GetVehicleHealth(veID, vehhealth);
		if(Engine[veID] == false)
		{
			if(vehhealth <= 400) return SendClientMessage(playerid, COLOR_GREY, "Машина сломана!");
			GetVehicleParamsEx(GetPlayerVehicleID(playerid),engine,lights,alarm,doors,bonnet,boot,objective);
			if(vehhealth <= 1000 && vehhealth >= 815) {
				Light[veID] = true;
				SetVehicleParamsEx(GetPlayerVehicleID(playerid),VEHICLE_PARAMS_ON,VEHICLE_PARAMS_ON,alarm,doors,bonnet,boot,objective);
				Engine[GetPlayerVehicleID(playerid)] = true;
				SetPlayerChatBubble(playerid, "завел(а) двигатель", COLOR_PURPLE, 30.0, 7000);
			}
			else if(vehhealth <= 815 && vehhealth >= 715) {
				switch(random(5)) {
				case 1,4: {
						SendClientMessage(playerid,COLOR_GREY,"Двигатель не завелся из-за повреждений, попробуйте еще раз.");
						SetPlayerChatBubble(playerid, "заводит двигатель (неудачно)", COLOR_PURPLE, 30.0, 7000);
					}
				default: {
						Light[veID] = true;
						SetVehicleParamsEx(GetPlayerVehicleID(playerid),VEHICLE_PARAMS_ON,VEHICLE_PARAMS_ON,alarm,doors,bonnet,boot,objective);
						Engine[GetPlayerVehicleID(playerid)] = true;
						SetPlayerChatBubble(playerid, "завел(а) двигатель", COLOR_PURPLE, 30.0, 7000);
					}
				}
			}
			else if(vehhealth <= 715 && vehhealth >= 615) {
				switch(random(6)) {
				case 1,5,2: {
						SendClientMessage(playerid,COLOR_GREY,"Двигатель не завелся из-за повреждений, попробуйте еще раз.");
						SetPlayerChatBubble(playerid, "заводит двигатель (неудачно)", COLOR_PURPLE, 30.0, 7000);
					}
				default: {
						Light[veID] = true;
						SetVehicleParamsEx(GetPlayerVehicleID(playerid),VEHICLE_PARAMS_ON,VEHICLE_PARAMS_ON,alarm,doors,bonnet,boot,objective);
						Engine[GetPlayerVehicleID(playerid)] = true;
						SetPlayerChatBubble(playerid, "завел(а) двигатель", COLOR_PURPLE, 30.0, 7000);
					}
				}
			}
			else if(vehhealth <= 615 && vehhealth >= 400) {
				switch(random(8)) {
				case 1,5,2,4,3: {
						SendClientMessage(playerid,COLOR_GREY,"Двигатель не завелся из-за повреждений, попробуйте еще раз.");
						SetPlayerChatBubble(playerid, "заводит двигатель (неудачно)", COLOR_PURPLE, 30.0, 7000);
					}
				default: {
						Light[veID] = true;
						SetVehicleParamsEx(GetPlayerVehicleID(playerid),VEHICLE_PARAMS_ON,VEHICLE_PARAMS_ON,alarm,doors,bonnet,boot,objective);
						Engine[GetPlayerVehicleID(playerid)] = true;
						SetPlayerChatBubble(playerid, "завел(а) двигатель", COLOR_PURPLE, 30.0, 7000);
					}
				}
			}
		}
		else {
			Light[veID] = false;
			SetVehicleParamsEx(GetPlayerVehicleID(playerid),VEHICLE_PARAMS_OFF,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective);
			Engine[GetPlayerVehicleID(playerid)] = false;
			SetPlayerChatBubble(playerid, "отключил(а) двигатель", COLOR_PURPLE, 30.0, 7000);
		}
	}
	return 1;
}
stock PlusBankMoney(playerid, amount) {
	PI[playerid][pBank] += amount;
	query = "";
	format(query, 256, "UPDATE `bank` SET `money` = `money` + '%d' WHERE fix = '1' AND playerid = '%d'", amount, PI[playerid][pID]);
	mysql_function_query(cHandle, query, false, "", "");
	CheckBank(playerid);
}
stock MinusBankMoney(playerid, amount) {
	PI[playerid][pBank] -= amount;
	query = "";
	format(query, 256, "UPDATE `bank` SET `money` = `money` - '%d' WHERE fix = '1' AND playerid = '%d'", amount, PI[playerid][pID]);
	mysql_function_query(cHandle, query, false, "", "");
	CheckBank(playerid);
}
stock ChangeSkin(playerid) {
	if(PI[playerid][pMember] == F_GOV && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_SAPD && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_SAN && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_VMF && PI[playerid][pRank] >= 16) return 1;
	if(PI[playerid][pMember] == F_HLS && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_GROVE && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_BALLAS && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_AZTEC && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_VAGOS && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_RIFA && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_FBI && PI[playerid][pRank] >= 11) return 1;
	if(PI[playerid][pMember] == F_LIC && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_ARMY && PI[playerid][pRank] >= 12) return 1;
	if(PI[playerid][pMember] == F_SFPD && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_LVPD && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_HSF && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_HLV && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_MAFIA && PI[playerid][pRank] >= 6) return 1;
	return 0;
}
stock InvitePlayer(playerid) {
	if(PI[playerid][pMember] == F_GOV && PI[playerid][pRank] >= 7) return 1;
	if(PI[playerid][pMember] == F_SAPD && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_SAN && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_VMF && PI[playerid][pRank] >= 16) return 1;
	if(PI[playerid][pMember] == F_HLS && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_GROVE && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_BALLAS && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_AZTEC && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_VAGOS && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_RIFA && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_FBI && PI[playerid][pRank] >= 11) return 1;
	if(PI[playerid][pMember] == F_LIC && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_ARMY && PI[playerid][pRank] >= 12) return 1;
	if(PI[playerid][pMember] == F_SFPD && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_LVPD && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_HSF && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_HLV && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_MAFIA && PI[playerid][pRank] >= 7) return 1;
	return 0;
}
stock UnInvitePlayer(playerid) {
	if(PI[playerid][pMember] == F_GOV && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_SAPD && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_SAN && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_VMF && PI[playerid][pRank] >= 16) return 1;
	if(PI[playerid][pMember] == F_HLS && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_GROVE && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_BALLAS && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_AZTEC && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_VAGOS && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_RIFA && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_FBI && PI[playerid][pRank] >= 11) return 1;
	if(PI[playerid][pMember] == F_LIC && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_ARMY && PI[playerid][pRank] >= 12) return 1;
	if(PI[playerid][pMember] == F_SFPD && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_LVPD && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_HSF && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_HLV && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_MAFIA && PI[playerid][pRank] >= 7) return 1;
	return 0;
}
stock GiveRankPlayer(playerid) {
	if(PI[playerid][pMember] == F_GOV && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_SAPD && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_SAN && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_VMF && PI[playerid][pRank] >= 14) return 1;
	if(PI[playerid][pMember] == F_HLS && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_GROVE && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_BALLAS && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_AZTEC && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_VAGOS && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_RIFA && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_FBI && PI[playerid][pRank] >= 10) return 1;
	if(PI[playerid][pMember] == F_LIC && PI[playerid][pRank] >= 9) return 1;
	if(PI[playerid][pMember] == F_ARMY && PI[playerid][pRank] >= 11) return 1;
	if(PI[playerid][pMember] == F_SFPD && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_LVPD && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_HSF && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_HLV && PI[playerid][pRank] >= 8) return 1;
	if(PI[playerid][pMember] == F_MAFIA && PI[playerid][pRank] >= 7) return 1;
	return 0;
}
stock MySQLGetInt(data[], &variable, row = 0) variable = cache_get_field_content_int(row, data);
stock MySQLGetStr(data[], variable[], t_size, row = 0) cache_get_field_content(row, data, variable, 1, t_size);
stock BadFloat(Float:x) {
	if(x >= 10.0 || x <= -10.0) return true;
	return false;
}
stock IsWeaponWithAmmo(weaponid) {
	switch(weaponid) {
	case 16..18, 22..39, 41..42: return 1;
	default: return 0;
	}
	return 0;
}
stock GetPlayerWeaponAmmo(playerid,weaponid) {
	new wd[2][13];
	for(new i; i<13; i++) GetPlayerWeaponData(playerid,i,wd[0][i],wd[1][i]);
	for(new i; i<13; i++)
	if(weaponid == wd[0][i]) return wd[1][i];
	return 0;
}
stock GetDistanceBetweenPlayers(playerid, playerid2) {
	new Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2;
	new Float:tmpdis;
	GetPlayerPos(playerid, x1, y1, z1);
	GetPlayerPos(playerid2, x2, y2, z2);
	tmpdis = floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
	return floatround(tmpdis);
}
stock IsPlayerInWater(playerid) {
	new anim = GetPlayerAnimationIndex(playerid);
	if (((anim >=  1538) && (anim <= 1542)) || (anim == 1544) || (anim == 1250) || (anim == 1062)) return 1;
	return 0;
}
stock IsPlayerAiming(playerid) {
	new anim = GetPlayerAnimationIndex(playerid);
	if (((anim >= 1160) && (anim <= 1163)) || (anim == 1167) || (anim == 1365) ||
			(anim == 1643) || (anim == 1453) || (anim == 220)) return 1;
	return 0;
}
stock ToggleVehicleEngine(vid) {
	GetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(engine == VEHICLE_PARAMS_UNSET || engine == VEHICLE_PARAMS_OFF) SetVehicleParamsEx(vid,VEHICLE_PARAMS_ON,lights,alarm,doors,bonnet,boot,objective);
	else SetVehicleParamsEx(vid,VEHICLE_PARAMS_OFF,lights,alarm,doors,bonnet,boot,objective);
}
stock ToggleVehicleLights(vid) {
	GetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(lights == VEHICLE_PARAMS_UNSET || lights == VEHICLE_PARAMS_OFF) SetVehicleParamsEx(vid,engine,VEHICLE_PARAMS_ON,alarm,doors,bonnet,boot,objective);
	else SetVehicleParamsEx(vid,engine,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective);
}
stock ToggleVehicleDoorsLocked(vid) {
	GetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(doors == VEHICLE_PARAMS_UNSET || doors == VEHICLE_PARAMS_OFF) SetVehicleParamsEx(vid,engine,lights,alarm,VEHICLE_PARAMS_ON,bonnet,boot,objective);
	else SetVehicleParamsEx(vid,engine,lights,alarm,VEHICLE_PARAMS_OFF,bonnet,boot,objective);
}
stock ToggleVehicleHood(vid) {
	GetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(bonnet == VEHICLE_PARAMS_UNSET || bonnet == VEHICLE_PARAMS_OFF) SetVehicleParamsEx(vid,engine,lights,alarm,doors,VEHICLE_PARAMS_ON,boot,objective);
	else SetVehicleParamsEx(vid,engine,lights,alarm,doors,VEHICLE_PARAMS_OFF,boot,objective);
}
stock ToggleVehicleTrunk(vid) {
	GetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(boot == VEHICLE_PARAMS_UNSET || boot == VEHICLE_PARAMS_OFF) SetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,VEHICLE_PARAMS_ON,objective);
	else SetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,VEHICLE_PARAMS_OFF,objective);
}
stock SetVehicleEngineState(vid, setstate) {
	GetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(setstate) SetVehicleParamsEx(vid,VEHICLE_PARAMS_ON,lights,alarm,doors,bonnet,boot,objective);
	else SetVehicleParamsEx(vid,VEHICLE_PARAMS_OFF,lights,alarm,doors,bonnet,boot,objective);
}
stock SetVehicleLightsState(vid, setstate) {
	GetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(setstate) SetVehicleParamsEx(vid,engine,VEHICLE_PARAMS_ON,alarm,doors,bonnet,boot,objective);
	else SetVehicleParamsEx(vid,engine,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective);
}
stock SetVehicleDoorsLockedState(vid, setstate) {
	GetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(setstate) SetVehicleParamsEx(vid,engine,lights,alarm,VEHICLE_PARAMS_ON,bonnet,boot,objective);
	else SetVehicleParamsEx(vid,engine,lights,alarm,VEHICLE_PARAMS_OFF,bonnet,boot,objective);
}
stock SetVehicleHoodState(vid, setstate) {
	GetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(setstate) SetVehicleParamsEx(vid,engine,lights,alarm,doors,VEHICLE_PARAMS_ON,boot,objective);
	else SetVehicleParamsEx(vid,engine,lights,alarm,doors,VEHICLE_PARAMS_OFF,boot,objective);
}
stock SetVehicleTrunkState(vid, setstate) {
	GetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(setstate) SetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,VEHICLE_PARAMS_ON,objective);
	else SetVehicleParamsEx(vid,engine,lights,alarm,doors,bonnet,VEHICLE_PARAMS_OFF,objective);
}
stock ResetWeapon(playerid) {
	ResetPlayerWeapons(playerid);
	for(new i = 0; i < 13; i++) {
		PI[playerid][pGun][i] = 0;
		PI[playerid][pAmmo][i] = 0;
	}
}
stock SetWeaponNew(playerid) {
	for(new i; i < 13; i++) {
		if(PI[playerid][pGun][i] != 0 && PI[playerid][pAmmo][i] != 0) GiveWeapon(playerid, PI[playerid][pGun][i], PI[playerid][pAmmo][i]);
	}
	return 1;
}
stock GiveWeapon(playerid, weaponid, ammo) {
	GunCheckTime[playerid] = 5;
	switch(weaponid) {
	case 1: PI[playerid][pAmmo][0] += ammo, PI[playerid][pGun][0] = weaponid;
	case 2..9: PI[playerid][pAmmo][1] += ammo, PI[playerid][pGun][1] = weaponid;
	case 22..24: PI[playerid][pAmmo][2] += ammo, PI[playerid][pGun][2] = weaponid;
	case 25..27: PI[playerid][pAmmo][3] += ammo, PI[playerid][pGun][3] = weaponid;
	case 28,29,32: PI[playerid][pAmmo][4] += ammo, PI[playerid][pGun][4] = weaponid;
	case 30,31: PI[playerid][pAmmo][5] += ammo, PI[playerid][pGun][5] = weaponid;
	case 33,34: PI[playerid][pAmmo][6] += ammo, PI[playerid][pGun][6] = weaponid;
	case 35..38: PI[playerid][pAmmo][7] += ammo, PI[playerid][pGun][7] = weaponid;
	case 16..18,39: PI[playerid][pAmmo][8] += ammo, PI[playerid][pGun][8] = weaponid;
	case 41..43: PI[playerid][pAmmo][9] += ammo, PI[playerid][pGun][9] = weaponid;
	case 10..15: PI[playerid][pAmmo][10] += ammo, PI[playerid][pGun][10] = weaponid;
	case 44,45,46: PI[playerid][pAmmo][11] += ammo, PI[playerid][pGun][11] = weaponid;
	case 40: PI[playerid][pAmmo][12] += ammo, PI[playerid][pGun][12] = weaponid;
	}
	GiveWeapon(playerid, weaponid, ammo);
}
stock CheckWeapon(playerid) {
	if(GunCheckTime[playerid] == 0) {
		new weapon[2][13];
		for(new i = 0; i < 13; i++) {
			GetPlayerWeaponData(playerid, i, weapon[0][i], weapon[1][i]);
			if(PI[playerid][pAmmo][i] < weapon[1][i]-1) GunCheat(playerid);
			else PI[playerid][pAmmo][i] = weapon[1][i];
		}
	}
	else GunCheckTime[playerid] --;
}
stock GunCheat(playerid) {
	ResetWeapon(playerid);
	SetPVarInt(playerid, "GunCheat", 1);
	format(PI[playerid][pGuns],40,"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
	PI[playerid][pGun][0],PI[playerid][pGun][1],PI[playerid][pGun][2],PI[playerid][pGun][3],PI[playerid][pGun][4],PI[playerid][pGun][5],
	PI[playerid][pGun][6],PI[playerid][pGun][7],PI[playerid][pGun][8],PI[playerid][pGun][9],PI[playerid][pGun][10],PI[playerid][pGun][11],PI[playerid][pGun][12]);
	format(PI[playerid][pAmmos],160,"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
	PI[playerid][pAmmo][0],PI[playerid][pAmmo][1],PI[playerid][pAmmo][2],PI[playerid][pAmmo][3],PI[playerid][pAmmo][4],PI[playerid][pAmmo][5],
	PI[playerid][pAmmo][6],PI[playerid][pAmmo][7],PI[playerid][pAmmo][8],PI[playerid][pAmmo][9],PI[playerid][pAmmo][10],PI[playerid][pAmmo][11],PI[playerid][pAmmo][12]);
	query = "";
	format(query, sizeof(query), "UPDATE "TABLE_ACCOUNT" SET Guns = '%s', Ammos = '%s' WHERE Name = '%s'", PI[playerid][pGuns], PI[playerid][pAmmos], NamePlayer(playerid));
	NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (#1144)");
	return 1;
}
stock MobileCrash(playerid) {
	new caller = Mobile[playerid];
	SendClientMessage(caller, COLOR_GRAD2, "Абонент положил трубку");
	SetPlayerSpecialAction(caller,SPECIAL_ACTION_STOPUSECELLPHONE);
	CellTime[caller] = -1;
	CellTime[playerid] = -1;
	Mobile[caller] = INVALID_PLAYER_ID;
	if(EtherCalled[playerid] == true) EtherCalled[playerid] = false;
	if(EtherCalled[caller] == true) EtherCalled[caller] = false;
	Mobile[playerid] = INVALID_PLAYER_ID;
	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
	DeletePVar(playerid, "CallTime");
	DeletePVar(caller, "CallTime");
	return true;
}
stock ResetPlayerWeaponEx(playerid) {
	ResetPlayerWeapons(playerid);
	for(new i = 0; i < 13; i++) {
		PI[playerid][pGun][i] = 0;
		PI[playerid][pAmmo][i] = 0;
	}
	return true;
}
stock OnPlayerAmmoChange(playerid, newammo, oldammo) {
	if(newammo >= oldammo) return true;
	switch(GetPlayerWeapon(playerid)) {
	case 24: {
			SetPVarInt(playerid, "SkillD",GetPVarInt(playerid, "SkillD") +(oldammo-newammo));
			if(GetPVarInt(playerid, "SkillD") >= 7 && PI[playerid][pGunSkill][1] < 100) {
				PI[playerid][pGunSkill][1]++;
				SetPVarInt(playerid, "SkillD",0);
				SetPlayerSkills(playerid);
			}
		}
	case 23: {
			SetPVarInt(playerid, "SkillSD",GetPVarInt(playerid, "SkillSD") +(oldammo-newammo));
			if(GetPVarInt(playerid, "SkillSD") >= 10 && PI[playerid][pGunSkill][0] < 100) {
				PI[playerid][pGunSkill][0]++;
				SetPVarInt(playerid, "SkillSD",0);
				SetPlayerSkills(playerid);
			}
		}
	case 25: {
			SetPVarInt(playerid, "SkillShot",GetPVarInt(playerid, "SkillShot") +(oldammo-newammo));
			if(GetPVarInt(playerid, "SkillShot") >= 7 && PI[playerid][pGunSkill][2] < 100) {
				PI[playerid][pGunSkill][2]++;
				SetPVarInt(playerid, "SkillShot",0);
				SetPlayerSkills(playerid);
			}
		}
	case 29: {
			SetPVarInt(playerid, "SkillMP5",GetPVarInt(playerid, "SkillMP5") +(oldammo-newammo));
			if(GetPVarInt(playerid, "SkillMP5") >= 25 && PI[playerid][pGunSkill][3] < 100) {
				PI[playerid][pGunSkill][3]++;
				SetPVarInt(playerid, "SkillMP5",0);
				SetPlayerSkills(playerid);
			}
		}
	case 30: {
			SetPVarInt(playerid, "SkillAk47",GetPVarInt(playerid, "SkillAk47") +(oldammo-newammo));
			if(GetPVarInt(playerid, "SkillAk47") >= 35 && PI[playerid][pGunSkill][4] < 100) {
				PI[playerid][pGunSkill][4]++;
				SetPVarInt(playerid, "SkillAk47",0);
				SetPlayerSkills(playerid);
			}
		}
	case 31: {
			SetPVarInt(playerid, "SkillM4",GetPVarInt(playerid, "SkillM4") +(oldammo-newammo));
			if(GetPVarInt(playerid, "SkillM4") >= 35 && PI[playerid][pGunSkill][5] < 100) {
				PI[playerid][pGunSkill][5]++;
				SetPVarInt(playerid, "SkillM4",0);
				SetPlayerSkills(playerid);
			}
		}
	}
	return true;
}
stock SetPlayerSkills(playerid){
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED, PI[playerid][pGunSkill][0]*10);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, PI[playerid][pGunSkill][1]*10);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, PI[playerid][pGunSkill][2]*10);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, PI[playerid][pGunSkill][3]*10);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, PI[playerid][pGunSkill][4]*10);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, PI[playerid][pGunSkill][5]*10);
	return true;
}
stock ToDevelopSkills(Slashes) {
	new SlashesAndPoints[120];
	for(new i = 0; i < Slashes; i++) strcat(SlashesAndPoints,"|");
	return SlashesAndPoints;
}
stock PreloadAnimLibs(playerid) {
	PreloadAnimLib(playerid,"DANCING");
	PreloadAnimLib(playerid,"PAULNMAC");
	PreloadAnimLib(playerid,"PARK");
	PreloadAnimLib(playerid,"CRACK");
	PreloadAnimLib(playerid,"MISC");
	PreloadAnimLib(playerid,"SWEET");
	PreloadAnimLib(playerid,"SPRAYCAN");
	PreloadAnimLib(playerid,"SHOP");
	PreloadAnimLib(playerid,"RYDER");
	PreloadAnimLib(playerid,"RIOT");
	PreloadAnimLib(playerid,"BAR");
	PreloadAnimLib(playerid,"BEACH");
	PreloadAnimLib(playerid,"benchpress");
	PreloadAnimLib(playerid,"BSKTBALL");
	PreloadAnimLib(playerid,"CAMERA");
	PreloadAnimLib(playerid,"CAR");
	PreloadAnimLib(playerid,"CAR_CHAT");
	PreloadAnimLib(playerid,"COP_AMBIENT");
	PreloadAnimLib(playerid,"GHANDS");
	PreloadAnimLib(playerid,"GRAFFITI");
	PreloadAnimLib(playerid,"GRAVEYARD");
	PreloadAnimLib(playerid,"INT_HOUSE");
	PreloadAnimLib(playerid,"INT_OFFICE");
	PreloadAnimLib(playerid,"LOWRIDER");
	PreloadAnimLib(playerid,"MEDIC");
	PreloadAnimLib(playerid,"WAYFARER");
	PreloadAnimLib(playerid,"FIGHT_D");
	return animsload[playerid] = true;
}
stock FuelList(playerid) {
	strin = "";
	for(new i = 1; i <= TOTALFUEL; i++) {
		format(strin, sizeof(strin), "№%i - Заказал: %s\n",i, FuelInfo[i][pName]);
		strcat(strin, strin);
	}
	if(TOTALFUEL == 0) return SPD(playerid, 0, 0, "Заказы", "Новых заказов нет", "Закрыть", "");
	SPD(playerid, DIALOG_JOB+126, 2, "Заказы", strin, "Принять", "Отмена");
	return 1;
}
stock ProductList(playerid) {
	strin = "";
	for(new i = 1; i <= TOTALPRODUCT; i++) {
		format(strin, sizeof(strin), "№%i - Заказал: %s\n",i, ProductInfo[i][pName]);
		strcat(strin, strin);
	}
	if(TOTALPRODUCT == 0) return SPD(playerid, 0, 0, "Заказы", "Новых заказов нет", "Закрыть", "");
	SPD(playerid, D_HEAL+23, 2, "Заказы", strin, "Принять", "Отмена");
	return 1;
}
stock IsAGreenZone(playerid) {
	return (PlayerToPoint(40.0,playerid,1630.0225,-1632.3418,1583.8660)
	|| PlayerToPoint(40.0,playerid,1622.4684,-1628.9377,1583.8660)
	|| PlayerToPoint(40.0,playerid,1626.0885,-1622.4032,1584.6252)
	|| PlayerToPoint(40.0,playerid,1639.7754,-1628.9772,1583.8660)
	|| PlayerToPoint(40.0,playerid,1646.0507,-1629.4857,1583.8660)
	|| PlayerToPoint(40.0,playerid,1650.9159,-1622.2788,1583.8660)
	|| PlayerToPoint(40.0,playerid,1611.9158,-1629.3627,1583.8660)
	|| PlayerToPoint(40.0,playerid,1622.1125,-1643.0399,1583.8660)
	|| PlayerToPoint(40.0,playerid,1511.0818,-1764.0999,13.6859)
	|| PlayerToPoint(40.0,playerid,1522.8810,-1764.0929,13.6859)
	|| PlayerToPoint(50.0,playerid,-2036.5078,-112.9454,17.5559)
	|| PlayerToPoint(50.0,playerid,-2042.0210,-105.6318,17.5559)
	|| PlayerToPoint(50.0,playerid,1471.1627,-1370.6836,46.9359)
	|| PlayerToPoint(50.0,playerid,1482.7050,-1370.8337,46.9359)
	|| PlayerToPoint(50.0,playerid,1480.4019,-1380.5142,46.9359)
	|| PlayerToPoint(50.0,playerid,1480.3961,-1391.6913,46.9359)
	|| PlayerToPoint(50.0,playerid,1495.4442,-1359.9368,11.8859)
	|| PlayerToPoint(50.0,playerid,1484.2057,-1358.7529,12.2866)
	|| PlayerToPoint(50.0,playerid,332.9813,178.4796,944.0239)
	|| PlayerToPoint(50.0,playerid,323.1827,177.9898,944.0219)
	|| PlayerToPoint(50.0,playerid,315.2453,178.1817,944.0219)
	|| PlayerToPoint(50.0,playerid,307.1941,179.2707,944.0239)
	|| PlayerToPoint(50.0,playerid,307.3406,166.8630,944.0236)) ? true : false;
}
