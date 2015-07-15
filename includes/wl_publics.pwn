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
public OnGameModeInit() {
	cHandle = mysql_connect(mysql_host, mysql_user, mysql_db, mysql_pass);

	SetGameModeText(ModeServer);
	SendRconCommand("hostname "HostName"");
	SendRconCommand("rcon_password "RconPass"");
	SendRconCommand("weburl "NameSite"");

	if(mysql_ping() != 0) SendRconCommand("weburl "NameSite""),printf("- Подключение к базе `%s` успешно", mysql_db);
	else SendRconCommand("hostname "NameServer" | Технические работы"),SendRconCommand("password 239932"),printf("- Подключение к базе `%s` не успешно", mysql_db);

	mysql_debug(false);
	mysql_set_charset("cp1251_general_ci");
	mysql_function_query(cHandle,"SET NAMES 'cp1251'", false, "", "");
	mysql_function_query(cHandle,"SET CHARACTER SET 'cp1251'", false, "", "");

	ManualVehicleEngineAndLights();
	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(2);
	DisableInteriorEnterExits();
	SetNameTagDrawDistance(10.0);
	LimitPlayerMarkerRadius(80.0);
	//
	MafiaZone[0] = GangZoneCreate(-75.999237, 1627.809814, 436.000762, 2171.809814);
	//
	SkinMenu = CreateMenu("Skins", 1, 50.0, 150.0, 140.0);
	AddMenuItem(SkinMenu,0,"Next >>");
	AddMenuItem(SkinMenu,0,"<< Previous");
	AddMenuItem(SkinMenu,0,"Save");
	//
	ShopMenu = CreateMenu("Choose", 1, 50.0, 150.0, 140.0);
	AddMenuItem(ShopMenu,0,"Next >>");
	AddMenuItem(ShopMenu,0,"<< Previous");
	AddMenuItem(ShopMenu,0,"Buy");
	AddMenuItem(ShopMenu,0,"Exit");
	// Загрузка из MySQL
	mysql_function_query(cHandle,"SELECT * FROM `"TABLE_GANGZONE"`", true, "LoadGZ", "");
	mysql_function_query(cHandle,"SELECT * FROM `"TABLE_HOUSE"` ORDER BY  `"TABLE_HOUSE"`.`id` ASC ",true, "LoadHouse","");
	mysql_function_query(cHandle,"SELECT * FROM `"TABLE_CARS"`",true, "LoadCars","");
	mysql_function_query(cHandle,"SELECT * FROM `"TABLE_BIZZ"` ORDER BY  `"TABLE_BIZZ"`.`id` ASC ",true, "LoadBizz","");
	mysql_function_query(cHandle,"SELECT * FROM `"TABLE_LBIZZ"` ORDER BY  `"TABLE_LBIZZ"`.`id` ASC ",true, "LoadLBizz","");
	mysql_function_query(cHandle,"SELECT * FROM `"TABLE_PARK"` ORDER BY  `"TABLE_PARK"`.`id` ASC ",true, "LoadPark","");
	mysql_function_query(cHandle,"SELECT * FROM `"TABLE_CARPARK"` ORDER BY  `"TABLE_CARPARK"`.`id` ASC ",true, "LoadCarsPark","");
	mysql_function_query(cHandle,"SELECT * FROM `"TABLE_ENTERS"`", true, "LoadEnters", "");
	mysql_function_query(cHandle,"SELECT * FROM `"TABLE_WAREHOUSE"`", true, "LoadWare", "");
	// Загрузка
	loadBasketBalls();
	LoadWarehouse();
	loadBaskets();
	LoadVehicle();
	LoadObjects();
	LoadPickups();

	for(new i = 0; i < 15; i++) {
		if(StatusMedHeal[i] == false)
		MedHealText3D[i] = CreateDynamic3DTextLabel("<< Койка свободна >>\nНажмите \"F\" что бы занять",0xD1B221FF, InMedHeal[i][0], InMedHeal[i][1], InMedHeal[i][2],3.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
	}
	//
	new p = GetMaxPlayers();
	for(new i=0; i < p; i++) SetPVarInt(i, "laser", 0);
	Create3DTextLabel("Чтобы купить оружие нажмите {0080FF}'ALT'",0xFFFFFFFF,295.3856,-38.5151,1001.5156,5.0,0,1);
	//
	Scene_Created = false,Derby_Created = false;
	// Загрузка цен на тюнинг
	_TuningPriceWheels[0] = PRICE_SHADOW,_TuningPriceWheels[1] = PRICE_MEGA,_TuningPriceWheels[2] = PRICE_WIRES,_TuningPriceWheels[3] = PRICE_CLASSIC,_TuningPriceWheels[4] = PRICE_TWIST,_TuningPriceWheels[5] = PRICE_GROVE,_TuningPriceWheels[6] = PRICE_ATOMIC,_TuningPriceWheels[7] = PRICE_DOLLAR;
	_TuningPriceSpoilers[0] = PRICE_SPOILER_XFLOW,_TuningPriceSpoilers[1] = PRICE_SPOILER_ALIEN;
	_TuningPriceHydraulics = PRICE_HYDRAULICS;
	_TuningPriceHBumper[0] = PRICE_HBUMPER_XFLOW,_TuningPriceHBumper[1] = PRICE_HBUMPER_ALIEN,_TuningPriceBBumper[0] = PRICE_BBUMPER_XFLOW,_TuningPriceBBumper[1] = PRICE_BBUMPER_ALIEN;
	_TuningPriceNitro[0] = PRICE_NITRO_2X,_TuningPriceNitro[1] = PRICE_NITRO_5X,_TuningPriceNitro[2] = PRICE_NITRO_10X;
	_TuningPriceNeons[0] = PRICE_NEONS_WHITE,_TuningPriceNeons[1] = PRICE_NEONS_RED,_TuningPriceNeons[2] = PRICE_NEONS_GREEN,_TuningPriceNeons[3] = PRICE_NEONS_BLUE,_TuningPriceNeons[4] = PRICE_NEONS_YELLOW;
	//
	CpSlotM[0] = CreateDynamicCP(1124.9230,3.0072,1000.6797, 0.4, 1, 12, -1, 1.9);
	CpSlotM[1] = CreateDynamicCP(1126.8895,3.0070,1000.6797, 0.4, 1, 12, -1, 1.9);
	CpSlotM[2] = CreateDynamicCP(1132.8976,-1.6607,1000.6797, 0.4, 1, 12, -1, 1.9);
	CpSlotM[3] = CreateDynamicCP(1135.0234,0.6129,1000.6797, 0.4, 1, 12, -1, 1.9);
	CpSlotM[4] = CreateDynamicCP(1135.1809,-3.8680,1000.6797, 0.4, 1, 12, -1, 1.9);
	CpWareHouse[0] = CreateDynamicCP(2501.8079,-1716.3955,1154.5859-1, 1.4, 1, 5);
	CpWareHouse[1] = CreateDynamicCP(2049.2825,-1157.0313,1147.6160-1, 1.4, 2, 5);
	CpWareHouse[2] = CreateDynamicCP(1857.3606,-2056.3352,1049.3259-1, 1.4, 3, 5);
	CpWareHouse[3] = CreateDynamicCP(2422.6169,-1075.6224,1047.8049-1, 1.4, 4, 5);
	CpWareHouse[4] = CreateDynamicCP(2492.6760,-1549.7338,1519.9659-1, 1.4, 5, 5);
	CpGunArmy[0] = CreateDynamicCP(-1384.3207,809.8448,1550.0859+1, 1.4, 2, 10);
	//
	CreateDynamicObject(19168, 1636.269775, -1618.910400, 1585.371337, 90.100051, 0.00, 0.00);
	CreateDynamicObject(19169, 1637.751098, -1618.913208, 1585.367553, 90.300056, 0.00, 0.00);
	CreateDynamicObject(19170, 1636.272216, -1618.910644, 1583.880371, 89.900054, 0.00, 0.00);
	CreateDynamicObject(19171, 1637.751220, -1618.912231, 1583.879882, 89.999954, 0.00, 0.00);
	CreateDynamicObject(19280, 2197.4951172,-1972.0550537,15.0419998,   90.00, 90.00, 0.00);
	CreateDynamicObject(19280, 2200.4951172,-1972.0550537,15.0419998,   90.00, 90.00, 0.00);
	//
	HungerText = TextDrawCreate(609.671630, 30.666666, "usebox");
	TextDrawLetterSize(HungerText, 0.000000, 0.456638);
	TextDrawTextSize(HungerText, 544.295471, 0.000000);
	TextDrawAlignment(HungerText, 1);
	TextDrawColor(HungerText, 0);
	TextDrawUseBox(HungerText, true);
	TextDrawBoxColor(HungerText, 255);
	TextDrawSetShadow(HungerText, 0);
	TextDrawSetOutline(HungerText, 0);
	TextDrawFont(HungerText, 0);

	URL[0] = TextDrawCreate(593.412109, 1.166639, "O");
	TextDrawLetterSize(URL[0], 0.449999, 1.600000);
	TextDrawTextSize(URL[0], 34.352947, 35.583404);
	TextDrawAlignment(URL[0], 1);
	TextDrawColor(URL[0], -16776961);
	TextDrawBackgroundColor(URL[0], 0x00000000);
	TextDrawUseBox(URL[0], true);
	TextDrawBoxColor(URL[0], 0);
	TextDrawSetShadow(URL[0], 0);
	TextDrawSetOutline(URL[0], 1);
	TextDrawFont(URL[0], 5);
	TextDrawSetProportional(URL[0], 1);
	TextDrawSetPreviewModel(URL[0], 1956);
	TextDrawSetPreviewRot(URL[0], 90.000000, 0.000000, 0.000000, 1.000000);

	URL[1] = TextDrawCreate(525.705810, 3.333342, "~w~Your");//"~r~W~w~est~r~L~w~and"
	TextDrawLetterSize(URL[1], 0.450470, 1.955832);
	TextDrawAlignment(URL[1], 1);
	TextDrawColor(URL[1], -16776961);
	TextDrawSetShadow(URL[1], 1);
	TextDrawSetOutline(URL[1], 0);
	TextDrawBackgroundColor(URL[1], 255);
	TextDrawFont(URL[1], 1);
	TextDrawSetProportional(URL[1], 1);

	URL[2] = TextDrawCreate(545.411987, 13.999980, "RolePlay");
	TextDrawLetterSize(URL[2], 0.395411, 1.343333);
	TextDrawAlignment(URL[2], 1);
	TextDrawColor(URL[2], -1);
	TextDrawUseBox(URL[2], true);
	TextDrawBoxColor(URL[2], 0);
	TextDrawSetShadow(URL[2], 1);
	TextDrawSetOutline(URL[2], 0);
	TextDrawBackgroundColor(URL[2], 255);
	TextDrawFont(URL[2], 0);
	TextDrawSetProportional(URL[2], 1);

	URL[3] = TextDrawCreate(606.588439, 6.416678, "1");
	TextDrawLetterSize(URL[3], 0.659412, 2.486666);
	TextDrawAlignment(URL[3], 1);
	TextDrawColor(URL[3], -5963521);
	TextDrawSetShadow(URL[3], 0);
	TextDrawSetOutline(URL[3], 0);
	TextDrawBackgroundColor(URL[3], 255);
	TextDrawFont(URL[3], 2);
	TextDrawSetProportional(URL[3], 1);
	// CASINO
	new Float:Y = 200.083343;
	// Cherries (x25)
	Digit1[0] = CreateSprite(210.823440,Y,"LD_SLOT:cherry",70,70);
	Digit2[0] = CreateSprite(292.294158,Y,"LD_SLOT:cherry",70,70);
	Digit3[0] = CreateSprite(372.823547,Y,"LD_SLOT:cherry",70,70);
	// grapes (x100)
	Digit1[1] = CreateSprite(210.823440,Y,"LD_SLOT:grapes",70,70);
	Digit2[1] = CreateSprite(292.294158,Y,"LD_SLOT:grapes",70,70);
	Digit3[1] = CreateSprite(372.823547,Y,"LD_SLOT:grapes",70,70);
	// 69's (x250)
	Digit1[2] = CreateSprite(210.823440,Y,"LD_SLOT:r_69",70,70);
	Digit2[2] = CreateSprite(292.294158,Y,"LD_SLOT:r_69",70,70);
	Digit3[2] = CreateSprite(372.823547,Y,"LD_SLOT:r_69",70,70);
	// bells (x500)
	Digit1[3] = CreateSprite(210.823440,Y,"LD_SLOT:bell",70,70);
	Digit2[3] = CreateSprite(292.294158,Y,"LD_SLOT:bell",70,70);
	Digit3[3] = CreateSprite(372.823547,Y,"LD_SLOT:bell",70,70);
	// Bars [1 bar] (x1000)
	Digit1[4] = CreateSprite(210.823440,Y,"LD_SLOT:bar1_o",70,70);
	Digit2[4] = CreateSprite(292.294158,Y,"LD_SLOT:bar1_o",70,70);
	Digit3[4] = CreateSprite(372.823547,Y,"LD_SLOT:bar1_o",70,70);
	// Bars [2 bar] (x2000)
	Digit1[5] = CreateSprite(210.823440,Y,"LD_SLOT:bar2_o",70,70);
	Digit2[5] = CreateSprite(292.294158,Y,"LD_SLOT:bar2_o",70,70);
	Digit3[5] = CreateSprite(372.823547,Y,"LD_SLOT:bar2_o",70,70);
	//
	ShieldBG[0] = TextDrawCreate(610.0,57.8,"_");
	TextDrawLetterSize(ShieldBG[0],0.0,0.57);
	TextDrawUseBox(ShieldBG[0],1);
	TextDrawBoxColor(ShieldBG[0],0x000000FF);
	TextDrawTextSize(ShieldBG[0],544.5,0.0);

	ShieldBG[1] = TextDrawCreate(608.0,59.6,"_");
	TextDrawLetterSize(ShieldBG[1],0.0,0.135);
	TextDrawUseBox(ShieldBG[1],1);
	TextDrawBoxColor(ShieldBG[1],0xB8CEF6FF);
	TextDrawTextSize(ShieldBG[1],546.5,0.0);
	//
	inv_BoxTD[0] = TextDrawCreate(6.123077, 127.583274, "box");
	TextDrawLetterSize(inv_BoxTD[0], 0.000000, 28.447046);
	TextDrawTextSize(inv_BoxTD[0], 178.595565, 0.000000);
	TextDrawAlignment(inv_BoxTD[0], 1);
	TextDrawColor(inv_BoxTD[0], -1);
	TextDrawUseBox(inv_BoxTD[0], 1);
	TextDrawBoxColor(inv_BoxTD[0], 55);
	TextDrawSetShadow(inv_BoxTD[0], 0);
	TextDrawSetOutline(inv_BoxTD[0], 0);
	TextDrawBackgroundColor(inv_BoxTD[0], 255);
	TextDrawFont(inv_BoxTD[0], 1);
	TextDrawSetProportional(inv_BoxTD[0], 1);
	TextDrawSetShadow(inv_BoxTD[0], 0);

	inv_BoxTD[1] = TextDrawCreate(447.176483, 127.583274, "box");
	TextDrawLetterSize(inv_BoxTD[1], 0.000000, 28.447046);
	TextDrawTextSize(inv_BoxTD[1], 619.646789, 0.000000);
	TextDrawAlignment(inv_BoxTD[1], 1);
	TextDrawColor(inv_BoxTD[1], -1);
	TextDrawUseBox(inv_BoxTD[1], 1);
	TextDrawBoxColor(inv_BoxTD[1], 55);
	TextDrawSetShadow(inv_BoxTD[1], 0);
	TextDrawSetOutline(inv_BoxTD[1], 0);
	TextDrawBackgroundColor(inv_BoxTD[1], 255);
	TextDrawFont(inv_BoxTD[1], 1);
	TextDrawSetProportional(inv_BoxTD[1], 1);
	TextDrawSetShadow(inv_BoxTD[1], 0);

	inv_BoxTD[2] = TextDrawCreate(448.058776, 148.583328, "_");
	TextDrawLetterSize(inv_BoxTD[2], 0.000000, 0.000000);
	TextDrawTextSize(inv_BoxTD[2], 169.999816, 212.499984);
	TextDrawAlignment(inv_BoxTD[2], 1);
	TextDrawColor(inv_BoxTD[2], -1);
	TextDrawSetShadow(inv_BoxTD[2], 0);
	TextDrawSetOutline(inv_BoxTD[2], 0);
	TextDrawBackgroundColor(inv_BoxTD[2], 255);
	TextDrawFont(inv_BoxTD[2], 5);
	TextDrawSetProportional(inv_BoxTD[2], 0);
	TextDrawSetShadow(inv_BoxTD[2], 0);
	TextDrawSetPreviewModel(inv_BoxTD[2], 19637);
	TextDrawSetPreviewRot(inv_BoxTD[2], 0.000000, 0.000000, 90.000000, 0.294550);

	inv_BoxTD[3] = TextDrawCreate(448.058746, 362.666717, "_");	// use button
	TextDrawLetterSize(inv_BoxTD[3], 0.000000, 0.000000);
	TextDrawTextSize(inv_BoxTD[3], 68.352798, 18.249990);
	TextDrawAlignment(inv_BoxTD[3], 1);
	TextDrawColor(inv_BoxTD[3], -1);
	TextDrawSetShadow(inv_BoxTD[3], 0);
	TextDrawSetOutline(inv_BoxTD[3], 0);
	TextDrawBackgroundColor(inv_BoxTD[3], 255);
	TextDrawFont(inv_BoxTD[3], 5);
	TextDrawSetProportional(inv_BoxTD[3], 0);
	TextDrawSetShadow(inv_BoxTD[3], 0);
	TextDrawSetSelectable(inv_BoxTD[3], true);
	TextDrawSetPreviewModel(inv_BoxTD[3], 19637);
	TextDrawSetPreviewRot(inv_BoxTD[3], 0.000000, 0.000000, 90.000000, 0.294550);

	inv_BoxTD[4] = TextDrawCreate(453.294128, 365.583404, "…CЊO‡’€OBAT’");
	TextDrawLetterSize(inv_BoxTD[4], 0.240941, 1.238332);
	TextDrawAlignment(inv_BoxTD[4], 1);
	TextDrawColor(inv_BoxTD[4], -1);
	TextDrawSetShadow(inv_BoxTD[4], 0);
	TextDrawSetOutline(inv_BoxTD[4], 0);
	TextDrawBackgroundColor(inv_BoxTD[4], 255);
	TextDrawFont(inv_BoxTD[4], 1);
	TextDrawSetProportional(inv_BoxTD[4], 1);
	TextDrawSetShadow(inv_BoxTD[4], 0);

	inv_BoxTD[5] = TextDrawCreate(517.705810, 362.666778, "_");	// drop button
	TextDrawLetterSize(inv_BoxTD[5], 0.000000, 0.000000);
	TextDrawTextSize(inv_BoxTD[5], 50.941017, 18.249990);
	TextDrawAlignment(inv_BoxTD[5], 1);
	TextDrawColor(inv_BoxTD[5], -1);
	TextDrawSetShadow(inv_BoxTD[5], 0);
	TextDrawSetOutline(inv_BoxTD[5], 0);
	TextDrawBackgroundColor(inv_BoxTD[5], 255);
	TextDrawFont(inv_BoxTD[5], 5);
	TextDrawSetProportional(inv_BoxTD[5], 0);
	TextDrawSetShadow(inv_BoxTD[5], 0);
	TextDrawSetSelectable(inv_BoxTD[5], true);
	TextDrawSetPreviewModel(inv_BoxTD[5], 19637);
	TextDrawSetPreviewRot(inv_BoxTD[5], 0.000000, 0.000000, 90.000000, 0.294550);

	inv_BoxTD[6] = TextDrawCreate(521.528625, 365.583404, "B‘ЂPOC…T’");
	TextDrawLetterSize(inv_BoxTD[6], 0.240941, 1.238332);
	TextDrawAlignment(inv_BoxTD[6], 1);
	TextDrawColor(inv_BoxTD[6], -1);
	TextDrawSetShadow(inv_BoxTD[6], 0);
	TextDrawSetOutline(inv_BoxTD[6], 0);
	TextDrawBackgroundColor(inv_BoxTD[6], 255);
	TextDrawFont(inv_BoxTD[6], 1);
	TextDrawSetProportional(inv_BoxTD[6], 1);
	TextDrawSetShadow(inv_BoxTD[6], 0);

	inv_BoxTD[7] = TextDrawCreate(569.941162, 362.666687, "_");	// info button
	TextDrawLetterSize(inv_BoxTD[7], 0.000000, 0.000000);
	TextDrawTextSize(inv_BoxTD[7], 48.117485, 18.249990);
	TextDrawAlignment(inv_BoxTD[7], 1);
	TextDrawColor(inv_BoxTD[7], -1);
	TextDrawSetShadow(inv_BoxTD[7], 0);
	TextDrawSetOutline(inv_BoxTD[7], 0);
	TextDrawBackgroundColor(inv_BoxTD[7], 255);
	TextDrawFont(inv_BoxTD[7], 5);
	TextDrawSetProportional(inv_BoxTD[7], 0);
	TextDrawSetShadow(inv_BoxTD[7], 0);
	TextDrawSetSelectable(inv_BoxTD[7], true);
	TextDrawSetPreviewModel(inv_BoxTD[7], 19637);
	TextDrawSetPreviewRot(inv_BoxTD[7], 0.000000, 0.000000, 90.000000, 0.294550);

	inv_BoxTD[8] = TextDrawCreate(575.383850, 365.583404, "CBEѓEH…•");
	TextDrawLetterSize(inv_BoxTD[8], 0.240941, 1.238332);
	TextDrawAlignment(inv_BoxTD[8], 1);
	TextDrawColor(inv_BoxTD[8], -1);
	TextDrawSetShadow(inv_BoxTD[8], 0);
	TextDrawSetOutline(inv_BoxTD[8], 0);
	TextDrawBackgroundColor(inv_BoxTD[8], 255);
	TextDrawFont(inv_BoxTD[8], 1);
	TextDrawSetProportional(inv_BoxTD[8], 1);
	TextDrawSetShadow(inv_BoxTD[8], 0);

	inv_BoxTD[9] = TextDrawCreate(529.058959, 129.333297, "P”K€AK");
	TextDrawLetterSize(inv_BoxTD[9], 0.400000, 1.600000);
	TextDrawAlignment(inv_BoxTD[9], 2);
	TextDrawColor(inv_BoxTD[9], -1);
	TextDrawSetShadow(inv_BoxTD[9], 0);
	TextDrawSetOutline(inv_BoxTD[9], 0);
	TextDrawBackgroundColor(inv_BoxTD[9], 255);
	TextDrawFont(inv_BoxTD[9], 2);
	TextDrawSetProportional(inv_BoxTD[9], 1);
	TextDrawSetShadow(inv_BoxTD[9], 0);

	inv_BoxTD[10] = TextDrawCreate(48.058818, 148.499938, "_");
	TextDrawLetterSize(inv_BoxTD[10], 0.000000, 0.000000);
	TextDrawTextSize(inv_BoxTD[10], 81.999824, 145.416717);
	TextDrawAlignment(inv_BoxTD[10], 1);
	TextDrawColor(inv_BoxTD[10], -1);
	TextDrawSetShadow(inv_BoxTD[10], 0);
	TextDrawSetOutline(inv_BoxTD[10], 0);
	TextDrawBackgroundColor(inv_BoxTD[10], 255);
	TextDrawFont(inv_BoxTD[10], 5);
	TextDrawSetProportional(inv_BoxTD[10], 0);
	TextDrawSetShadow(inv_BoxTD[10], 0);
	TextDrawSetPreviewModel(inv_BoxTD[10], 19637);
	TextDrawSetPreviewRot(inv_BoxTD[10], 0.000000, 0.000000, 90.000000, 0.294550);

	inv_BoxTD[11] = TextDrawCreate(51.882354, 153.083312, "box");
	TextDrawLetterSize(inv_BoxTD[11], 0.000000, 15.129418);
	TextDrawTextSize(inv_BoxTD[11], 126.470603, 0.000000);
	TextDrawAlignment(inv_BoxTD[11], 1);
	TextDrawColor(inv_BoxTD[11], -1);
	TextDrawUseBox(inv_BoxTD[11], 1);
	TextDrawBoxColor(inv_BoxTD[11], -122);
	TextDrawSetShadow(inv_BoxTD[11], 0);
	TextDrawSetOutline(inv_BoxTD[11], 0);
	TextDrawBackgroundColor(inv_BoxTD[11], 255);
	TextDrawFont(inv_BoxTD[11], 1);
	TextDrawSetProportional(inv_BoxTD[11], 1);
	TextDrawSetShadow(inv_BoxTD[11], 0);

	inv_BoxTD[12] = TextDrawCreate(50.882343, 225.083328, "_");
	TextDrawLetterSize(inv_BoxTD[12], 0.000000, 0.000000);
	TextDrawTextSize(inv_BoxTD[12], 77.294120, 90.000000);
	TextDrawAlignment(inv_BoxTD[12], 1);
	TextDrawColor(inv_BoxTD[12], -1);
	TextDrawSetShadow(inv_BoxTD[12], 0);
	TextDrawSetOutline(inv_BoxTD[12], 0);
	TextDrawBackgroundColor(inv_BoxTD[12], 0);
	TextDrawFont(inv_BoxTD[12], 5);
	TextDrawSetProportional(inv_BoxTD[12], 0);
	TextDrawSetShadow(inv_BoxTD[12], 0);
	TextDrawSetPreviewModel(inv_BoxTD[12], 1953);
	TextDrawSetPreviewRot(inv_BoxTD[12], 8.000000, 0.000000, 0.000000, 1.000000);

	inv_BoxTD[13] = TextDrawCreate(90.470741, 129.333297, "…HЃOPMA‰…•");
	TextDrawLetterSize(inv_BoxTD[13], 0.400000, 1.600000);
	TextDrawAlignment(inv_BoxTD[13], 2);
	TextDrawColor(inv_BoxTD[13], -1);
	TextDrawSetShadow(inv_BoxTD[13], 0);
	TextDrawSetOutline(inv_BoxTD[13], 0);
	TextDrawBackgroundColor(inv_BoxTD[13], 255);
	TextDrawFont(inv_BoxTD[13], 2);
	TextDrawSetProportional(inv_BoxTD[13], 1);
	TextDrawSetShadow(inv_BoxTD[13], 0);

	inv_BoxTD[14] = TextDrawCreate(7.588231, 302.500000, "_");
	inv_BoxTD[15] = TextDrawCreate(7.588231, 327.000000, "_");
	inv_BoxTD[16] = TextDrawCreate(7.588231, 351.500000, "_");

	for(new T = 14; T != 17; T++) {
		TextDrawLetterSize(inv_BoxTD[T], 0.000000, 0.000000);
		TextDrawTextSize(inv_BoxTD[T], 169.999755, 21.750061);
		TextDrawAlignment(inv_BoxTD[T], 1);
		TextDrawColor(inv_BoxTD[T], -1);
		TextDrawSetShadow(inv_BoxTD[T], 0);
		TextDrawSetOutline(inv_BoxTD[T], 0);
		TextDrawBackgroundColor(inv_BoxTD[T], 255);
		TextDrawFont(inv_BoxTD[T], 5);
		TextDrawSetProportional(inv_BoxTD[T], 0);
		TextDrawSetShadow(inv_BoxTD[T], 0);
		TextDrawSetPreviewModel(inv_BoxTD[T], 19637);
		TextDrawSetPreviewRot(inv_BoxTD[T], 0.000000, 0.000000, 90.000000, 0.294550);
	}
	inv_BoxTD[17] = TextDrawCreate(10.941152, 306.666625, "box_bg_bars");
	inv_BoxTD[18] = TextDrawCreate(10.941152, 331.166717, "box_bg_bars");
	inv_BoxTD[19] = TextDrawCreate(10.941151, 355.667236, "box_bg_bars");

	for(new T = 17; T != 20; T++) {
		TextDrawLetterSize(inv_BoxTD[T], 0.000000, 1.482350);
		TextDrawTextSize(inv_BoxTD[T], 174.470458, 0.000000);
		TextDrawAlignment(inv_BoxTD[T], 1);
		TextDrawColor(inv_BoxTD[T], -1);
		TextDrawUseBox(inv_BoxTD[T], 1);
		TextDrawBoxColor(inv_BoxTD[T], 223);
		TextDrawSetShadow(inv_BoxTD[T], 0);
		TextDrawSetOutline(inv_BoxTD[T], 0);
		TextDrawBackgroundColor(inv_BoxTD[T], 255);
		TextDrawFont(inv_BoxTD[T], 1);
		TextDrawSetProportional(inv_BoxTD[T], 1);
		TextDrawSetShadow(inv_BoxTD[T], 0);
	}
	inv_BoxTD[20] = TextDrawCreate(621.705627, 125.249977, "LD_SPAC:white");	// close X button
	TextDrawLetterSize(inv_BoxTD[20], 0.000000, 0.000000);
	TextDrawTextSize(inv_BoxTD[20], 17.000000, 20.000000);
	TextDrawAlignment(inv_BoxTD[20], 1);
	TextDrawColor(inv_BoxTD[20], 55);
	TextDrawSetShadow(inv_BoxTD[20], 0);
	TextDrawSetOutline(inv_BoxTD[20], 0);
	TextDrawBoxColor(inv_BoxTD[20], 55);
	TextDrawFont(inv_BoxTD[20], 4);
	TextDrawSetProportional(inv_BoxTD[20], 0);
	TextDrawSetShadow(inv_BoxTD[20], 0);
	TextDrawSetSelectable(inv_BoxTD[20], true);

	inv_BoxTD[21] = TextDrawCreate(625.529357, 128.166702, "x");
	TextDrawLetterSize(inv_BoxTD[21], 0.400000, 1.600000);
	TextDrawAlignment(inv_BoxTD[21], 1);
	TextDrawColor(inv_BoxTD[21], -16777120);
	TextDrawSetShadow(inv_BoxTD[21], 0);
	TextDrawSetOutline(inv_BoxTD[21], 0);
	TextDrawBackgroundColor(inv_BoxTD[21], 255);
	TextDrawFont(inv_BoxTD[21], 2);
	TextDrawSetProportional(inv_BoxTD[21], 1);
	TextDrawSetShadow(inv_BoxTD[21], 0);
	//
	FULLBOX = TextDrawCreate(-7.000000, 1.000000, "BOX");
	TextDrawBackgroundColor(FULLBOX, 0);
	TextDrawFont(FULLBOX, 1);
	TextDrawLetterSize(FULLBOX, 0.500000, 50.399993);
	TextDrawColor(FULLBOX, 0);
	TextDrawSetOutline(FULLBOX, 0);
	TextDrawSetProportional(FULLBOX, 1);
	TextDrawSetShadow(FULLBOX, 1);
	TextDrawUseBox(FULLBOX, 1);
	TextDrawBoxColor(FULLBOX, 170);
	TextDrawTextSize(FULLBOX, 640.000000, 0.000000);
	TextDrawSetSelectable(FULLBOX, 0);
	for(new i = 0; i < 20; i++) point[i] = CreateObject(19179, 1637.004150, -1618.938842, 1584.636230, 90.0, 0.0, 0.0);
	//
	for(new i; i < sizeof(TreeSad); i++) gTreeSad[i] = CreateObject(673,TreeSad[i][0],TreeSad[i][1],72.8000031,0.0000000,0.0000000,0.0000000);
	Iter_Init(StreamedPlayers);
	SetTimer("ADTimer", 1000*60*10, true);
	SetTimer("SecTimer", 1000, true);
	SetTimer("FuelCheck", 23000, true);
	return 1;
}
public OnGameModeExit() {
	Iter_Clear(MAX_CARS);
	DestroyAllDynamicObjects();
	DestroyAllDynamicPickups();
	DestroyAllDynamicCPs();
	DestroyAllDynamic3DTextLabels();
	mysql_close(cHandle);
	foreach(new i: Player) SavePlayer(i);
	return 1;
}
public OnPlayerRequestClass(playerid, classid) {
	InterpolateCameraPos(playerid,291.2647,-1253.8707,152.0083,1430.1914,-1739.1036,131.4550,30000,CAMERA_MOVE);
	InterpolateCameraLookAt(playerid,291.2647,-1253.8707,152.0083,1430.1914,-1739.1036,131.4550,30000,CAMERA_MOVE);

	RemovePlayerAttachedObject(playerid,0);
	if(PlayerLogged[playerid] != false) {
		SetSpawnInfo(playerid, 255, PI[playerid][pSkin], 0, 0, 0, 1.0, -1, -1, -1, -1, -1, -1);
		return SpawnPlayer(playerid);
	}
	for(new x = 1;x<=TOTALGZ;x++) GangZoneShowForPlayer(playerid,GZInfo[x][id],GetGangZoneColor(x));
	animload[playerid] = false;
	animsload[playerid] = false;
	return 1;
}
public OnPlayerConnect(playerid) {
	GetPlayerName(playerid, PI[playerid][pName_str], MAX_PLAYER_NAME);
    OPConnect(playerid);
    RemoveObjects(playerid);
	return 1;
}
public OnPlayerDisconnect(playerid, reason) {
	slotUsed{ playerid } = 0;
	if(PlayerLogged[playerid] != false) SavePlayer(playerid);
	if(isPlayingBasketBall(playerid)) exitBBallGame(playerid);
	KillTimer(EnterTimer[playerid]);
	ResetCarInfo(playerid);
	DeletePVar(playerid,"MedCardReg");
	DeletePVar(playerid,"InvizCheat");
	DeletePVar(playerid,"laser");
	if(OnOneLevelJob[playerid] == 1) UpdateKolhozPlayers(playerid, 0);
	if(maskuse[playerid] == 1) maskuse[playerid] = 0,KillTimer(MaskTimer[playerid]);
	if(Iter_Count(StreamedPlayers[playerid]) != 0) Iter_Clear(StreamedPlayers[playerid]);
	if(GetPVarInt(playerid,"DrawInv") > 0) DeletePVar(playerid,"DrawInv");
	if(GetPVarInt(playerid,"LBObj1") != 0) {
		DestroyDynamicObject(GetPVarInt(playerid,"LBObj1"));
		DestroyDynamicObject(GetPVarInt(playerid,"LBObj2"));
		DestroyDynamicObject(GetPVarInt(playerid,"LBObj3"));
		DestroyDynamicObject(GetPVarInt(playerid,"LBObj4"));
	}
	if(GetPVarInt(playerid,"Collector_MWO1") != 0) {
		DestroyDynamicObject(GetPVarInt(playerid,"Collector_MWO1"));
		DestroyDynamicObject(GetPVarInt(playerid,"Collector_MWO2"));
		DestroyDynamicObject(GetPVarInt(playerid,"Collector_MWO3"));
		DestroyDynamicObject(GetPVarInt(playerid,"Collector_MWO4"));
	}
	if(GetPVarInt(playerid,"GetLBTimer") != 0) KillTimer(GetPVarInt(playerid,"GetLBTimer"));
	if(GetPVarInt(playerid,"GMiner_WTimer") != 0) KillTimer(GetPVarInt(playerid,"GMiner_WTimer"));
	for(new i; i < MAX_PLAYER_ATTACHED_OBJECTS; i++) {
		if(IsPlayerAttachedObjectSlotUsed(playerid, i)) RemovePlayerAttachedObject(playerid, i);
	}
	//
	switch(reason) {
	case 0: {
			strin = "";
			format(strin, sizeof(strin), "[A] Игрок %s (ID: %d) отключился(ась) от сервера (Crash)", NamePlayer(playerid), playerid);
			SendAdminMessage(COLOR_LIGHTRED, strin);
		}
	case 1: {
			strin = "";
			format(strin, sizeof(strin), "[A] Игрок %s (ID: %d) отключился(ась) от сервера (Left)", NamePlayer(playerid), playerid);
			SendAdminMessage(COLOR_LIGHTRED, strin);
		}
	case 2: {
			strin = "";
			format(strin, sizeof(strin), "[A] Игрок %s (ID: %d) отключился(ась) от сервера (Kicked)", NamePlayer(playerid), playerid);
			SendAdminMessage(COLOR_LIGHTRED, strin);
		}
	}
	Spawned[playerid] = false;
	Damaged[playerid] = false;
	//
	PlayerTextDrawDestroy(playerid,ShieldBar[playerid]);
	PlayerTextDrawDestroy(playerid,PTD_midii[playerid]);
	PlayerTextDrawDestroy(playerid,PTD_oxygen[playerid]);

	for(new i; i < 10; i++) PlayerTextDrawDestroy(playerid,FishTD[i][playerid]);
	for(new i; i < 16; i++) PlayerTextDrawDestroy(playerid,PTD_crubjob[playerid][i]);
	for(new i; i < 16; i++) PlayerTextDrawDestroy(playerid,RegDraws[i][playerid]);
	for(new i; i < 7; i++) 	PlayerTextDrawDestroy(playerid,SpeedDraw[i][playerid]);
	for(new i; i < 10; i++) PlayerTextDrawDestroy(playerid,AutoSalonTD[i][playerid]);
	for(new i; i < 11; i++) PlayerTextDrawDestroy(playerid,TuningTD[i][playerid]);
	for(new i; i < 15; i++) PlayerTextDrawDestroy(playerid,CasinoDraw[i][playerid]);
	for(new i; i < 21; i++) PlayerTextDrawDestroy(playerid,inv_SlotsPTD[i][playerid]);
	for(new i; i < 6; i++) PlayerTextDrawDestroy(playerid,inv_OtherPTD[i][playerid]);
	for(new i; i < 16; i++) PlayerTextDrawDestroy(playerid,SpecTD[i][playerid]);
	for(new i; i < 4; i++) 	PlayerTextDrawDestroy(playerid,InvTD[i][playerid]);

	for(new i; i < 6; i++)  TextDrawHideForPlayer(playerid,Digit1[i]);
	for(new i; i < 6; i++)  TextDrawHideForPlayer(playerid,Digit2[i]);
	for(new i; i < 6; i++)  TextDrawHideForPlayer(playerid,Digit3[i]);
	for(new i; i < 5; i++)  TextDrawDestroy(g_Capture[i][playerid]);
	for(new i; i < 5; i++)  TextDrawHideForPlayer(playerid, URL[i]);
	for(new i; i < 22; i++) TextDrawHideForPlayer(playerid, inv_BoxTD[i]);

	TextDrawDestroy(SkinCost[playerid]);
	TextDrawDestroy(AnimDraw[playerid]);
	TextDrawDestroy(FishDraw[playerid]);
	TextDrawDestroy(GardenDraw[playerid]);
	TextDrawDestroy(ProcentDraw[playerid]);
	TextDrawDestroy(AmountLDraw[playerid]);
	TextDrawDestroy(AmountDraw[playerid]);
	TextDrawDestroy(AmountDraw[playerid]);

	ExitPlayerFromSlotMachine(playerid);
	if(SlotTimer[playerid] != -1) KillTimer(SlotTimer[playerid]);
	//
	if(GetPVarInt(playerid, "ProductID") > 0) {
		DisablePlayerRaceCheckpoint(playerid);
		Delete3DTextLabel(ProductInfo[GetPVarInt(playerid, "ProductID")][pText3D]);
		ProductInfo[GetPVarInt(playerid, "ProductID")][pStatus] = false;
	}
	//
	if(InShop[playerid] > 0) DestroyVehicle(BuyVeh[playerid]);
	//
	if(GetPVarInt(playerid, "SetHeal") > 0) DeletePVar(playerid, "SetHeal");
	if(GetPVarInt(playerid, "MedHealPlay") > 0) {
		new i = GetPVarInt(playerid, "MedHealPlace")-1;
		StatusMedHeal[i] = false;
		UpdateDynamic3DTextLabelText(MedHealText3D[i],0xD1B221FF,"<< Койка свободена! >>\nНажмите \"F\" что бы занять");
		DeletePVar(playerid, "MedHealPlay"),DeletePVar(playerid, "MedHealTime"),DeletePVar(playerid, "MedHealPlace");
	}
	if(GetPVarInt(playerid, "PriceTaxi") > 0) {
		PI[playerid][pPayCheck] += GetPVarInt(playerid, "TaxiMoney");
		DestroyDynamic3DTextLabel(TaxiText3D[playerid]);
		DeletePVar(playerid, "PriceTaxi");
		DeletePVar(playerid, "TaxiMoney");
	}
	if(GetPVarInt(playerid, "Miner") > 0) {
		DeletePVar(playerid, "OldMinerSkin");
		DeletePVar(playerid, "Miner");
		DeletePVar(playerid, "MinerCount");
		DeletePVar(playerid, "MinerKG_One");
		DestroyObject(rock_a[playerid]);
		KillTimer(timer_rock);
	}
	if(GetPVarInt(playerid, "Gruz") > 0) {
		DeletePVar(playerid, "OldGruzSkin");
		DeletePVar(playerid, "Gruz");
	}
	if(GetPVarInt(playerid, "LessPil") > 0) {
		DeletePVar(playerid, "OldLessSkin");
		DeletePVar(playerid, "LessPil");
		DeletePVar(playerid, "LessProc");
		DeletePVar(playerid, "Derevo");
		DeletePVar(playerid, "LessStatus");
	}
	if(GetPVarInt(playerid,"Animation") > 0) {
		DeletePVar(playerid, "Animation");
	}
	if(GetPVarInt(playerid, "PriceBus") > 0) {
		PI[playerid][pPayCheck] += GetPVarInt(playerid, "BusMoney");
		Delete3DTextLabel(BusText3D[playerid]);
		DeletePVar(playerid, "BusTime");
		DeletePVar(playerid, "RentBus");
		DeletePVar(playerid, "TypeBus");
		DeletePVar(playerid, "PriceBus");
		DeletePVar(playerid, "BusStop");
		DeletePVar(playerid, "BusMoney");
	}
	return 1;
}

public OnPlayerSpawn(playerid) {
	if(PlayerLogged[playerid] != true) SetTimerEx("PlayerKickChech",30000,false,"d",playerid);
	if(GetPVarInt(playerid,"K_Times") != 0) ResetWeapon(playerid);
	SetPVarInt(playerid,"K_Times",0);
	SetPlayerSkills(playerid);
	PreloadAnimLibs(playerid);
	ResetPlayerWeapons(playerid);
	GunCheckTime[playerid] = 5;
	CheckHealArmour[playerid] = 5;
	SetPVarInt(playerid,"InvizCheat",1);
	SetMoney(playerid, PI[playerid][pCash]);
	SetPlayerScore(playerid,PI[playerid][pLevel]);
	if(Level[playerid] < 1) Level[playerid] = 1;
	static Float:Heal;
	if(GetPlayerHealth(playerid, Heal) < 20) SetHealth(playerid, 50);
	TIMER_Spawn[playerid] = SetTimerEx("SpawnTimer",3000,true,"i",playerid);
	//
	if(GetPVarInt(playerid,"GMiner") != 0) {
		DeletePVar(playerid, "GMiner");
		DeletePVar(playerid, "GMinerCount");
		DeletePVar(playerid, "GMinerG_One");
		DeletePVar(playerid, "GMinerG_NotGived");
		SetPlayerSpecialAction(playerid,0);
		DisablePlayerCheckpoint(playerid);
	}
	if(GetPVarInt(playerid,"Collector") != 0) {
		DeletePVar(playerid, "Collector");
		DeletePVar(playerid, "Collector_LTree");
		DeletePVar(playerid, "Collector_Treed");
		DeletePVar(playerid, "Collector_NotGived");
		SetPlayerSpecialAction(playerid,0);
		DisablePlayerCheckpoint(playerid);
	}
	for(new idx; idx < 76; idx++) if(GardenCheckpoints[idx] != 0) TogglePlayerDynamicCP(playerid, GardenCheckpoints[idx], 0);
	for(new i; i < 5; i++) TextDrawShowForPlayer(playerid,URL[i]);
	for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit1[i]);
	for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit2[i]);
	for(new i; i < 6; i++) TextDrawHideForPlayer(playerid,Digit3[i]);
	for(new i; i < 15; i++) PlayerTextDrawHide(playerid,CasinoDraw[i][playerid]);

	GotoInfo[playerid][gtID] = INVALID_PLAYER_ID; GotoInfo[playerid][gtState] = 0; GotoInfo[playerid][gtX] = 0.0; GotoInfo[playerid][gtY] = 0.0; GotoInfo[playerid][gtZ] = 0.0;
	GotoInfo[playerid][gtTPX] = 0.0; GotoInfo[playerid][gtTPY] = 0.0; GotoInfo[playerid][gtTPZ] = 0.0; CheckPlayerGoCuff(playerid);

	SetPlayerTeamColor(playerid);
	SetPVarInt(playerid, "AntiBreik", 3);
	if(GetPlayerColor(playerid) == 0xFF)
	if(PI[playerid][pAdmLevel] == 0 && AdminLogged[playerid] == false) NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (#1103)");
	HungerBar[playerid] = CreatePlayerProgressBar(playerid, 549.00, 31.00, 57.50, 3.19, 0xA4CD00FF, 100.0);
	ShowPlayerProgressBar(playerid, HungerBar[playerid]);
	SetPlayerProgressBarValue(playerid, HungerBar[playerid], PI[playerid][pHunger]);
	UpdatePlayerProgressBar(playerid, HungerBar[playerid]);
	//
	if(PI[playerid][pFracSkin] > 0) SetPlayerSkin(playerid,PI[playerid][pFracSkin]);
	else SetPlayerSkin(playerid, PI[playerid][pSkin]);
	//
	if(GetPVarInt(playerid, "SpecBool") == 1) {
		DeletePVar(playerid, "SpecBool");
		PI[playerid][pPos][0] = GetPVarFloat(playerid, "SpecX");
		PI[playerid][pPos][1] = GetPVarFloat(playerid, "SpecY");
		PI[playerid][pPos][2] = GetPVarFloat(playerid, "SpecZ");
		PI[playerid][pPos][3] = GetPVarFloat(playerid, "SpecFA");
		new inter = GetPVarInt(playerid, "SpecInt"), world = GetPVarInt(playerid, "SpecWorld");
		DeletePVar(playerid, "SpecX");
		DeletePVar(playerid, "SpecY");
		DeletePVar(playerid, "SpecZ");
		DeletePVar(playerid, "SpecFA");
		DeletePVar(playerid, "SpecInt");
		DeletePVar(playerid, "SpecWorld");
		t_SetPlayerPos(playerid, PI[playerid][pPos][0],PI[playerid][pPos][1],PI[playerid][pPos][2]);
		SetPlayerFacingAngle(playerid, PI[playerid][pPos][3]);
		SetPlayerVirtualWorld(playerid, world);
		SetPlayerInterior(playerid, inter);
		SetPlayerTeamColor(playerid);
		SetPlayerScore(playerid, PI[playerid][pLevel]);
		if(PI[playerid][pWanted] > 0) SetPlayerWantedLevel(playerid, PI[playerid][pWanted]);
		return 1;
	}
	if(PI[playerid][pJail] && PI[playerid][pJailTime]) {
		if(PI[playerid][pFracSkin] > 0) SetPlayerSkin(playerid,PI[playerid][pFracSkin]);
		else SetPlayerSkin(playerid, PI[playerid][pSkin]);
		new camid = -1;
		if(camid == -1)
		{
			camid = random(3);
			t_SetPlayerPos(playerid,camSpawn[camid][0],camSpawn[camid][1],camSpawn[camid][2]);
			SetPlayerFacingAngle(playerid,camSpawn[camid][3]);
			SetPlayerColor(playerid, 0xFFFF0011);
			SetPlayerInterior(playerid, 6);
			SetPlayerVirtualWorld(playerid, 1);
		}
		return 1;
	}
	if(GetPVarInt(playerid, "Death") == 1) {
		SetHealth(playerid, 20);
		if(PI[playerid][pFracSkin] > 0) SetPlayerSkin(playerid,PI[playerid][pFracSkin]);
		else SetPlayerSkin(playerid, PI[playerid][pSkin]);
		t_SetPlayerPos(playerid,-2610.0642,-1653.6028,1660.2400);
		SetPlayerFacingAngle(playerid, 20.7831);
		SetPlayerInterior(playerid,1);
		SetPlayerVirtualWorld(playerid, 1);
		TogglePlayerControllable(playerid,0);
		SendClientMessageEx(playerid, COLOR_YELLOW, "Чтобы начать курс лечения, займите свободную койку!");
		SetTimerEx("Unfreez",3000,false,"i",playerid);
		DeletePVar(playerid, "Death");
		return 1;
	}
	if(ClothesRound[playerid] == 1) {
		SendClientMessage(playerid, COLOR_REDD, "<> Используйте клавишу 'Быстрый бег' (пробел по умолчанию)");
		SendClientMessage(playerid, COLOR_REDD, "<> Используйте клавишу 'Вверх,вниз' (W,S по умолчанию)");
		SendClientMessage(playerid, COLOR_REDD, "<> Если у вас пропало меню - нажмите 'Enter'");
		SetPlayerVirtualWorld(playerid, playerid);
		SetPlayerInterior(playerid,18);
		PI[playerid][pRank] = 0;PI[playerid][pMember] = 0;PI[playerid][pAdmLevel] = 0;
		SetPlayerInterior(playerid,14);
		t_SetPlayerPos(playerid,1480.0984,-1369.8914,121.9811);
		SetPlayerFacingAngle(playerid, 2.5123);
		SetPlayerCameraPos(playerid,1480.0277,-1364.4063,122.7142);
		SetPlayerCameraLookAt(playerid,1480.0984,-1369.8914,121.9811);
		TogglePlayerControllable(playerid, false);
		ShowMenuForPlayer(SkinMenu,playerid);
		if(!PI[playerid][pSex])
		{
			SelectCharPlace[playerid] = 0;
			SetPlayerSkin(playerid, JoinRegF[SelectCharPlace[playerid]][0]);
		}
		else {
			SelectCharPlace[playerid] = 0;
			SetPlayerSkin(playerid, JoinRegM[SelectCharPlace[playerid]][0]);
		}
		for(new i; i < 16; i++) PlayerTextDrawDestroy(playerid,RegDraws[i][playerid]);
	}
	else if(ClothesRound[playerid] == 2) {
		SendClientMessage(playerid, COLOR_REDD, "<> Используйте клавишу 'Быстрый бег' (пробел по умолчанию)");
		SendClientMessage(playerid, COLOR_REDD, "<> Используйте клавишу 'Вверх,вниз' (W,S по умолчанию)");
		SendClientMessage(playerid, COLOR_REDD, "<> Если у вас пропало меню - нажмите 'Enter'");
		SetPlayerVirtualWorld(playerid, playerid);
		SetPlayerInterior(playerid,14);
		t_SetPlayerPos(playerid, 215.0519,-155.5064,1000.5234);
		SetPlayerFacingAngle(playerid, 91.8908);
		SetPlayerCameraPos(playerid,212.2030,-155.6162,1000.5306);
		SetPlayerCameraLookAt(playerid,213.7042,-155.6230,1000.5234);
		TogglePlayerControllable(playerid, 0);
		ShowMenuForPlayer(ShopMenu,playerid);
		TextDrawShowForPlayer(playerid,SkinCost[playerid]);
		if(PI[playerid][pSex] == 0)
		{
			SelectCharPlace[playerid] = 0;
			SetPlayerSkin(playerid, JoinShopF[SelectCharPlace[playerid]][0]);
			// Цена
			strin = "";
			format(strin,sizeof(strin),"~g~$%d",JoinShopF[SelectCharPlace[playerid]][1]);
			TextDrawSetString(SkinCost[playerid],strin);
		}
		else {
			SelectCharPlace[playerid] = 0;
			SetPlayerSkin(playerid, JoinShopM[SelectCharPlace[playerid]][0]);
			// Цена
			strin = "";
			format(strin,sizeof(strin),"~g~$%d",JoinShopM[SelectCharPlace[playerid]][1]);
			TextDrawSetString(SkinCost[playerid],strin);
		}
	}
	else
	{
		if(PI[playerid][pHotel] && PI[playerid][pSpawn] == 3)
		{
			for(new i;i<16;i++) PlayerTextDrawDestroy(playerid,RegDraws[i][playerid]);
			t_SetPlayerPos(playerid,-2158.6987,642.1813,1057.5938);
			SetPlayerInterior(playerid, 1);
			SetPlayerVirtualWorld(playerid,playerid);
			SetPlayerTeamColor(playerid);
		}
		else if(GetPlayerHouse(playerid) && PI[playerid][pSpawn] <= 1)
		{
			for(new i;i<16;i++) PlayerTextDrawHide(playerid,RegDraws[i][playerid]);
			if(PI[playerid][pFracSkin] > 0) SetPlayerSkin(playerid,PI[playerid][pFracSkin]);
			else SetPlayerSkin(playerid, PI[playerid][pSkin]);
			for(new i = 1; i <= TOTALHOUSE;i++) {
				if(!strcmp(HouseInfo[i][hOwner],NamePlayer(playerid),true)) {
					t_SetPlayerPos(playerid,HouseInfo[i][hExitx],HouseInfo[i][hExity],HouseInfo[i][hExitz]);
					SetPlayerInterior(playerid,HouseInfo[i][hInt]);
					SetPlayerVirtualWorld(playerid,HouseInfo[i][hVirtual]);
					SetPlayerFacingAngle(playerid, -90.0);
					SetPVarInt(playerid, "PlayerHouse", i);
					SetWeaponNew(playerid);
					return 1;
				}
			}
		}
		else if(PI[playerid][pMember])
		{
			for(new i;i<16;i++) PlayerTextDrawDestroy(playerid,RegDraws[i][playerid]);
			new fracid = PI[playerid][pMember] -1;
			SetPlayerVirtualWorld(playerid,FractionSpawnData[fracid][1]);
			SetPlayerInterior(playerid,FractionSpawnData[fracid][0]);
			t_SetPlayerPos(playerid,FractionSpawn[fracid][0],FractionSpawn[fracid][1],FractionSpawn[fracid][2]);
			SetCameraBehindPlayer(playerid);
			SetPlayerTeamColor(playerid);
			SetWeaponNew(playerid);
			if(PI[playerid][pMember] == F_HLS) {
				SetPVarInt(playerid, "SetHeal", 1);
			}
			TogglePlayerControllable(playerid,0);
			SetTimerEx("Unfreez",3000,false,"i",playerid);
		}
		else {
			for(new i;i<16;i++) PlayerTextDrawDestroy(playerid,RegDraws[i][playerid]);
			t_SetPlayerPos(playerid,1642.1331,-2240.2520,13.4956);
			SetPlayerFacingAngle(playerid, 275.2630);
			SetPlayerInterior(playerid,0);
			SetPlayerVirtualWorld(playerid, 0);
			SetWeaponNew(playerid);
			TogglePlayerControllable(playerid,0);
			SetTimerEx("Unfreez",500,false,"i",playerid);
			return 1;
		}
	}
	if(GetPVarInt(playerid,"FishJob") != JOB_KRUB) return 1;
	new step = GetPVarInt(playerid, "jobkrub_step");
	if(step == 1 || step == 5) if(IsPlayerAttachedObjectSlotUsed(playerid, 0)) RemovePlayerAttachedObject(playerid, 0);
	else if(step == 2 || step == 3) {
		if((step == 2 && GetPVarInt(playerid, "jobkrub_putcage_status")) || (step == 3 && GetPVarInt(playerid, "jobkrub_takecage_status"))) showPlayerPanelCage(playerid, 0, 0);
		for(new o = 0; o < 11; o++) DestroyDynamicObject(objects_krubjob[playerid][o]);
	}
	strin = "";
	format(strin, 96, "%i пирс: свободен", GetPVarInt(playerid, "jobkrub_numberPirs")+1);
	SetDynamicObjectMaterialText(PirsTable[GetPVarInt(playerid, "jobkrub_numberPirs")], 0, strin, 130, "Arial", 34, 1, -1, 0, 1);
	strin = "";
	format(strin, 96, "Пирс №%i: -", GetPVarInt(playerid, "jobkrub_numberPirs")+1);
	UpdateDynamic3DTextLabelText(pirsinfo[GetPVarInt(playerid, "jobkrub_numberPirs")][renter_3d], 0xFFFFCCFF, strin);
	SetVehicleToRespawn(krub_car[GetPVarInt(playerid, "jobkrub_numberPirs")]);
	pirsinfo[GetPVarInt(playerid, "jobkrub_numberPirs")][statusp] = false;
	strdel(pirsinfo[GetPVarInt(playerid, "jobkrub_numberPirs")][renter], 0, 24);
	for(new i = 0; i < GetPVarInt(playerid, "jobkrub_putcage_point_count"); i++) DestroyDynamicObject(objectsOnCar_krubjob[playerid][i]);
	return 1;
}
public OnPlayerDeath(playerid, killerid, reason) {
	if(OnOneLevelJob[playerid] == 1) UpdateKolhozPlayers(playerid, 0);
	if(IsPlayerAttachedObjectSlotUsed(playerid, 0)) RemovePlayerAttachedObject(playerid, 0);
	if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);
	if(IsPlayerAttachedObjectSlotUsed(playerid, 2)) RemovePlayerAttachedObject(playerid, 2);
	if(IsPlayerAttachedObjectSlotUsed(playerid, 3)) RemovePlayerAttachedObject(playerid, 3);
	if(IsPlayerAttachedObjectSlotUsed(playerid, 4)) RemovePlayerAttachedObject(playerid, 4);
	SetPVarInt(playerid,"K_Times",GetPVarInt(playerid,"K_Times") + 1);
	if(GetPVarInt(playerid,"K_Times") > 1 && PI[playerid][pAdmLevel] <= 0) return NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (#1127)");
	if(GetPVarInt(playerid, "MedHealPlay") > 0) {
		new i = GetPVarInt(playerid, "MedHealPlace")-1;
		StatusMedHeal[i] = false;
		UpdateDynamic3DTextLabelText(MedHealText3D[i],0xD1B221FF,"<< Койка свободена! >>\nНажмите \"F\" что бы занять");
		DeletePVar(playerid, "MedHealPlay"),DeletePVar(playerid, "MedHealTime"),DeletePVar(playerid, "MedHealPlace");
	}
	if(isPlayingBasketBall(playerid)) {
		exitBBallGame(playerid);
		SetPVarInt(playerid, "BrosilBBall", 0);
		SetPVarInt(playerid, "ExitBBall", 0);
	}
	if(GetPVarInt(playerid, "GangWar") > 0) SetPVarInt(playerid,"SdohNaCapte",1);
	//
	CheckPlayerGoCuff(playerid);
	GotoInfo[playerid][gtID] = INVALID_PLAYER_ID;
	GotoInfo[playerid][gtGoID] = INVALID_PLAYER_ID;
	//
	BunnyUse[playerid] = false;
	GunCheckTime[playerid] = 5;
	SetPVarInt(playerid,"UseAmmos",0);
	Spawned[playerid] = false;
	Damaged[playerid] = false;
	SetPVarInt(playerid, "Death", 1);
	SetPVarInt(playerid, "HealDeath", 1);
	DisablePlayerCheckpoint(playerid);
	if(InShop[playerid] > 0) DestroyVehicle(BuyVeh[playerid]);
	KillTimer(STimer[playerid]);
	if(maskuse[playerid] == 1) maskuse[playerid] = 0,KillTimer(MaskTimer[playerid]);
	for(new i;i<7;i++)PlayerTextDrawHide(playerid, SpeedDraw[i][playerid]);
	//
	for(new t;t<6;t++) TextDrawHideForPlayer(playerid, g_Capture[t][playerid]);
	TextDrawHideForPlayer(playerid,AnimDraw[playerid]);
	TextDrawHideForPlayer(playerid,GardenDraw[playerid]);
	TextDrawHideForPlayer(playerid,FishDraw[playerid]);
	TextDrawHideForPlayer(playerid,ProcentDraw[playerid]);
	TextDrawHideForPlayer(playerid,AmountLDraw[playerid]);
	TextDrawHideForPlayer(playerid,AmountDraw[playerid]);
	TextDrawHideForPlayer(playerid,MinerDraw[playerid]);
	//
	for(new i; i < 10; i++)PlayerTextDrawHide(playerid, AutoSalonTD[i][playerid]);
	TextDrawHideForPlayer(playerid,SkinCost[playerid]);

	if(killerid != INVALID_PLAYER_ID) {
		if(!IsACop(killerid) || GetPVarInt(killerid, "GangWar") != 2) {
			PI[killerid][pWanted]++;
			if(PI[killerid][pWanted]-1 == 0) PI[killerid][pWantedTime] = 1800 + random(300);
			SendClientMessage(killerid, COLOR_LIGHTRED,"Вы убили человека, вам лучше покинуть данное место, пока не узнали полицейские.");
			SetTimerEx("KillGetTimer",25000+random(45000),0,"i",killerid);
		}
	}
	if(GetPVarInt(playerid,"FishJob") == JOB_KRUB) {
		RemovePlayerAttachedObject(playerid, 0);
		RemovePlayerAttachedObject(playerid, 1);
		SendClientMessage(playerid, -1, "Вы уволились с работы краболова.");
		new step = GetPVarInt(playerid, "jobkrub_step");
		if(step == 1 || step == 5) if(IsPlayerAttachedObjectSlotUsed(playerid, 0)) RemovePlayerAttachedObject(playerid, 0);
		else if(step == 2 || step == 3)
		{
			if((step == 2 && GetPVarInt(playerid, "jobkrub_putcage_status")) || (step == 3 && GetPVarInt(playerid, "jobkrub_takecage_status"))) showPlayerPanelCage(playerid, 0, 0);
			for(new o = 0; o < 11; o++) DestroyDynamicObject(objects_krubjob[playerid][o]);
		}

		strin = "";
		format(strin, 96, "%i пирс: свободен", GetPVarInt(playerid, "jobkrub_numberPirs")+1);
		SetDynamicObjectMaterialText(PirsTable[GetPVarInt(playerid, "jobkrub_numberPirs")], 0, strin, 130, "Arial", 34, 1, -1, 0, 1);

		strin = "";
		format(strin, 96, "Пирс №%i: -", GetPVarInt(playerid, "jobkrub_numberPirs")+1);
		UpdateDynamic3DTextLabelText(pirsinfo[GetPVarInt(playerid, "jobkrub_numberPirs")][renter_3d], 0xFFFFCCFF, strin);
		SetVehicleToRespawn(krub_car[GetPVarInt(playerid, "jobkrub_numberPirs")]);
		pirsinfo[GetPVarInt(playerid, "jobkrub_numberPirs")][statusp] = false;
		strdel(pirsinfo[GetPVarInt(playerid, "jobkrub_numberPirs")][renter], 0, 24);
		for(new i = 0; i < 6; i++) if(objectsOnCar_krubjob[playerid][i] != 0) DestroyDynamicObject(objectsOnCar_krubjob[playerid][i]);
		//		return 1;
	}
	else if(GetPVarInt(playerid,"FishJob") == JOB_MIDIA) {
		SetPlayerSkin(playerid, GetPVarInt(playerid,"FishSkin"));
		DeletePVar(playerid,"FishSkin");
		RemovePlayerAttachedObject(playerid, 1);
		DeletePVar(playerid,"FishJob");
		SendClientMessage(playerid, -1, "Вы уволились с работы водолаза.");
		DeletePVar(playerid,"FishOxygen");
		DeletePVar(playerid,"FishRCP");
	}
	if(Ether[playerid] == true) {
		new CB[16];
		Ether[playerid] = false;
		Convert(GetPVarInt(playerid,"InEther"),CB);
		strin = "";
		if(EtherSms[PI[playerid][pNews]-1] == true)
		format(strin, 90, "[F] %s выключил прием СМС",NamePlayer(playerid)), SendFMes(PI[playerid][pMember], COLOR_LIGHTRED, strin);
		if(EtherCall[PI[playerid][pNews]-1] == true)
		format(strin, 90, "[F] %s выключил прием звонков",NamePlayer(playerid)), SendFMes(PI[playerid][pMember], COLOR_LIGHTRED, strin);

		format(strin, 90, "[F] %s вышел(а) из прямого эфира (Время в эфире: %s, звонков: %i, СМС: %i)",NamePlayer(playerid), CB, CallNews[PI[playerid][pNews]-1],SmsNews[PI[playerid][pNews]-1]);
		SendFMes(PI[playerid][pMember], COLOR_LIGHTRED, strin);
		EtherSms[PI[playerid][pNews]-1] = false;
		EtherCall[PI[playerid][pNews]-1] = false;
		SmsNews[PI[playerid][pNews]-1] = 0;
		CallNews[PI[playerid][pNews]-1] = 0;
		DeletePVar(playerid, "InEther");
		if(Mobile[playerid] != INVALID_PLAYER_ID) MobileCrash(playerid);
	}
	if(EtherLive[playerid] == true) {
		EtherLive[playerid] = false;
		DeletePVar(playerid, "Etherfrac");
		SendClientMessage(playerid, COLOR_LIGHTRED, "Вы вышли из прямого эфира");
	}
	if(killerid != INVALID_PLAYER_ID && killerid != 65535 && PI[killerid][pJailTime] > 0) SendClientMessage(killerid, COLOR_LIGHTRED, "За убийство игрока в камере, вы получаете к сроку дополнительные 10 минут."), PI[killerid][pJailTime] += 600, GameTextForPlayer(killerid,"JAILTIME: +300 SEC",1050,4);
	if(GetPVarInt(playerid, "ProductID") > 0) {
		DisablePlayerRaceCheckpoint(playerid);
		Delete3DTextLabel(ProductInfo[GetPVarInt(playerid, "ProductID")][pText3D]);
		ProductInfo[GetPVarInt(playerid, "ProductID")][pStatus] = false;
		DeletePVar(playerid, "ProductID");
	}
	//
	for(new i = 1;i<=TOTALGZ;i++) {
		if(ZoneOnBattle[i] == 1 && GetPVarInt(playerid, "GangWar") == 2 && GetPVarInt(killerid, "GangWar") == 2)
		{
			if(PI[killerid][pMember] == GZInfo[i][gFrak] && PI[playerid][pMember] == GZInfo[i][gNapad]) GangCD[GZInfo[i][gFrak]] += 1;
			else if(PI[killerid][pMember] == GZInfo[i][gNapad] && PI[playerid][pMember] == GZInfo[i][gFrak]) GangCD[GZInfo[i][gNapad]] += 1;
		}
	}
	if(GetPVarInt(playerid, "GangWar") > 0) DeletePVar(playerid, "GangWar");
	if(GetPVarInt(playerid, "SetHeal") > 0) DeletePVar(playerid, "SetHeal");
	//
	if(GetPVarInt(playerid, "LicTest") > 0) {
		DeletePVar(playerid, "LicTest");
		DeletePVar(playerid, "LicTestHealth");
		DeletePVar(playerid, "LicTestError");
		SendClientMessage(playerid, COLOR_LIGHTRED, "Вы провалили экзамен по важдению!");
	}
	if(GetPVarInt(playerid, "Miner") > 0) {
		DeletePVar(playerid, "OldMinerSkin");
		DeletePVar(playerid, "Miner");
		DeletePVar(playerid, "MinerCount");
		DeletePVar(playerid, "MinerKG_One");
	}
	if(GetPVarInt(playerid, "Gruz") > 0) {
		DeletePVar(playerid, "OldGruzSkin");
		DeletePVar(playerid, "Gruz");
	}
	if(GetPVarInt(playerid, "LessPil") > 0) {
		DeletePVar(playerid, "OldLessSkin");
		DeletePVar(playerid, "LessPil");
		DeletePVar(playerid, "Derevo");
		DeletePVar(playerid, "LessProc");
		DeletePVar(playerid, "LessStatus");
	}
	if(GetPVarInt(playerid,"Animation") > 0) {
		DeletePVar(playerid, "Animation");
	}
	if(GetPVarInt(playerid,"PriceBus") > 0) {
		PI[playerid][pPayCheck] += GetPVarInt(playerid, "BusMoney");
		Delete3DTextLabel(BusText3D[playerid]);
		DeletePVar(playerid, "BusTime");
		DeletePVar(playerid, "RentBus");
		DeletePVar(playerid, "TypeBus");
		DeletePVar(playerid, "PriceBus");
		DeletePVar(playerid, "BusStop");
		DeletePVar(playerid, "BusMoney");
	}
	ResetWeapon(playerid);
	SavePlayer(playerid);
	return 1;
}
public OnVehicleSpawn(vehicleid) {
	if(vehicleid == LBizz[2][lCars][0])
	if(GardenCPicks[0] != 0) DestroyDynamicPickup(GardenCPicks[0]),DestroyDynamic3DTextLabel(GardenCText[0]),GardenCPicks[0] = 0;

	if(vehicleid == LBizz[2][lCars][1])
	if(GardenCPicks[1] != 0) DestroyDynamicPickup(GardenCPicks[1]),DestroyDynamic3DTextLabel(GardenCText[1]),GardenCPicks[1] = 0;

	if(Start[vehicleid] == 1) {
		Delete3DTextLabel(AmmoText[vehicleid]);
		DestroyDynamicPickup(AmmoPickup[vehicleid]);
		Start[vehicleid] = 0;
	}
	if(GetVehicleModel(vehicleid) == 481 && GetVehicleModel(vehicleid) == 509 && GetVehicleModel(vehicleid) == 510 && GetVehicleModel(vehicleid) == 462) Fuel[vehicleid] = 200;
	SetVehicleParamsEx(vehicleid,false,false, false,IsLocked[vehicleid],false,false,false);
	Engine[vehicleid] = false;
	SetVehicleNumber(vehicleid);
	return 1;
}

public OnVehicleDeath(vehicleid, killerid) {
	if(vehicleid == LBizz[2][lCars][0]) {
		for(new i;i < 34;i++) if(GardenBObjects[0][i] != 0) DestroyDynamicObject(GardenBObjects[0][i]);
		GardenCarsIs[0][0] = 0;
	}
	else if(vehicleid == LBizz[2][lCars][1]) {
		for(new i;i < 34;i++) if(GardenBObjects[1][i] != 0) DestroyDynamicObject(GardenBObjects[1][i]);
		GardenCarsIs[1][0] = 0;
	}
	foreach(new i: Player) {
		if(PlayerLogged[i] == false) continue;
		if(IsPlayerInVehicle(i, vehicleid) && GetPlayerState(i) != 2)
		{
			if(GetPVarInt(i, "PriceBus") > 0) {
				SendClientMessageEx(i, COLOR_PAYCHEC, "Рабочий день завершен. Вами заработано: %i$", GetPVarInt(i, "BusMoney"));
				SendClientMessage(i, COLOR_PAYCHEC, "Деньги будут перечислены на счет во время зарплаты");
				PI[i][pPayCheck] += GetPVarInt(i, "BusMoney");
				SetVehicleToRespawn(GetPVarInt(i, "RentBus"));
				Delete3DTextLabel(BusText3D[i]);
				DeletePVar(i, "PriceBus");
				DeletePVar(i, "TypeBus");
				DeletePVar(i, "RentBus");
				DeletePVar(i, "BusStop");
				DeletePVar(i, "TimeBus");
				DeletePVar(i, "BusMoney");
				pPressed[i] = 0;
			}
		}
	}
	foreach(new i: Player) {
		if(PlayerLogged[i] == false) continue;
		if(IsPlayerInVehicle(i, vehicleid) && GetPlayerState(i) != 2)
		{
			if(GetPVarInt(i,"Collector_MTrucking") != 0) DisablePlayerRaceCheckpoint(i),DeletePVar(i,"Collector_MTrucking");
			if(GetPVarInt(i,"Collector_MGetting") != 0) DisablePlayerRaceCheckpoint(i),DeletePVar(i,"Collector_MGetting");
			if(GetPVarInt(i,"Collector_MWatering") != 0) DisablePlayerRaceCheckpoint(i),DeletePVar(i,"Collector_MWatering");
		}
	}
	return 1;
}

public OnPlayerText(playerid, text[]) {
	if(PlayerLogged[playerid] != true) {
		SendClientMessage(playerid,COLOR_LIGHTRED,"Необходима авторизация!");
		return 0;
	}
	if(PI[playerid][pMuted] > 0) {
		SendClientMessage(playerid, COLOR_PURPLE, "У Вас бан чата!");
		return 0;
	}
	if(GetPVarInt(playerid,"AntiFlood") > gettime()) {
		SendClientMessage(playerid, COLOR_GREY, "Не флуди!");
		return 0;
	}
	new result[64];
	new sendername[24];
	for(new i;i < strlen(result);i++) {
		new a[2],c=0;
		for(new j = 0;j < strlen(result);j++)
		{
			strmid(a,result,i+j,i+j+1,2);
			if('0' <= a[0] <= '9')c+=1;
		}
		if(c == 10)
		{
			PI[playerid][pMuted] = 3*3600;
			SendClientMessage(playerid, 0xFFFFFFAA, " Слишком много цифр");
			SendClientMessage(playerid, 0xFFFFFFAA, " Идет анализ твоего сообщения, ты заткнут(а) на 20 сек");
			strin = "";
			format(strin,sizeof(strin)," Внимание. %s[%d] пытался отправить текст: %s",sendername, playerid, result);
			return SendAdminMessage(COLOR_GREEN,strin);
		}
	}
	if(IsIP(text) && !NonAD(text) || CheckString(text) && !NonAD(text)) {
		PI[playerid][pMuted] = 3*3600;
		strin = "";
		format(strin,144,"[Реклама!] %s[%d]: %s",NamePlayer(playerid),playerid,text);
		SendAdminMessage(COLOR_GREEN,strin);
		strin = "";
		format(strin,144,"%s[%d]: Reg IP: %s / Connect IP: %s",NamePlayer(playerid),playerid,PI[playerid][pRegIp],PI[playerid][pConnectIp]);
		SendAdminMessage(COLOR_GREEN,strin);
		SendClientMessage(playerid,COLOR_RED,"Вы получили затычку чата на 3 часа!");
		return 0;
	}
	if(EtherLive[playerid] == true) {
		strin = "";
		format(strin, 144, "[SA NEWS] Прямой эфир: %s: %s", NamePlayer(playerid), text);
		SendClientMessageToAll(COLOR_PAYCHEC,strin);
		return 0;
	}
	if(Mobile[playerid] != INVALID_PLAYER_ID) {
	    if(Ether[playerid] == false) {
	        SendClientMessageEx(playerid, -1, "%d %d", Mobile[playerid], Ether[playerid]);
			strin = "";
			format(strin, 144, "[Телефон] %s: %s", NamePlayer(playerid), text);
			ProxDetector(20.0, playerid, strin,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
			if(Mobile[Mobile[playerid]] == playerid) SendClientMessage(Mobile[playerid], COLOR_YELLOW, strin);
			return 0;
		}
	}
	if(strcmp(text, "xD", true) == 0 || strcmp(text, "xd", true) == 0 || strcmp(text, "xD", true) == 0 || strcmp(text, "хД", true) == 0 ) {
		strin = "";
		format(strin, 60, "%s смеётся", NamePlayer(playerid));
		ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
		return 0;
	}
	if(strcmp(text, "xDD", true) == 0 || strcmp(text, "xDDD", true) == 0 || strcmp(text, ":DDDD", true) == 0 || strcmp(text, ":DDD", true) == 0 || strcmp(text, ":DD", true) == 0) {
		strin = "";
		format(strin, 60, "%s валяется от смеха", NamePlayer(playerid));
		ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
		return 0;
	}
	if(strcmp(text, ")", true) == 0 || strcmp(text, "))", true) == 0) {
		strin = "";
		format(strin, 60, "%s улыбается", NamePlayer(playerid));
		ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
		return 0;
	}
	if(strcmp(text, "(", true) == 0 || strcmp(text, "((", true) == 0) {
		strin = "";
		format(strin, 60, "%s расстроился", NamePlayer(playerid));
		ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
		return 0;
	}
	if(strcmp(text, ":D", true) == 0) {
		strin = "";
		format(strin, 60, "%s хохочет во весь голос", NamePlayer(playerid));
		ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
		return 0;
	}
	if(IsAGang(playerid)) {
		if(strcmp(text, "Привет", true) == 0 || strcmp(text, "Здарова", true) == 0 || strcmp(text, "qq", true) == 0 || strcmp(text, "Privet", true) == 0 || strcmp(text, "Zdarova", true) == 0 || strcmp(text, "ку", true) == 0)
		{
			foreach(new i: StreamedPlayers[playerid]) {
				if(IsPlayerInRangeOfPlayer(2.0, playerid, i) && playerid != i) {
					strin = "";
					format(strin, 128, "%s пожал(а) руку %s", NamePlayer(playerid) ,NamePlayer(i));
					ProxDetector(10.0, playerid, strin, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					ApplyAnimation(playerid,"GANGS","hndshkfa",4.0,0,0,0,0,0);
					ApplyAnimation(i,"GANGS","hndshkfa",4.0,0,0,0,0,0);
					return 0;
				}
			}
		}
	}
	if(!IsPlayerInAnyVehicle(playerid))
	format(strin, 144, "- %s(%d): %s", NamePlayer(playerid), playerid, text);
	else
	format(strin, 144, "- %s(%d) (в машине): %s", NamePlayer(playerid), playerid, text);
	ProxDetector(40.0, playerid, strin,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
	SetPlayerChatBubble(playerid,text,0x317CDFAA,20.0,10000);
	if(!IsPlayerInAnyVehicle(playerid) && GetPVarInt(playerid,"Miner") != 2 && GetPVarInt(playerid,"GruzYes") != 1 && !GetPVarInt(playerid, "TimeDM") && GetPVarInt(playerid,"Animation") != 1) {
		ApplyAnimation(playerid,"PED","IDLE_CHAT",8.1,0,1,1,1,1);
		SetTimerEx("ClearAnimText", 1400, false, "d", playerid);
	}
	SetPVarInt(playerid,"AntiFlood",gettime() + 2);
	return 0;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	UseEnter[playerid] = true;
	IDVEH[playerid]=vehicleid;
	if(ispassenger == 0) {
		if(vehicleid >= BizzCarsPark[0][tcVehicle] && vehicleid <= BizzCarsPark[TOTALCARSPARK][tcVehicle]) {
			foreach(new i : Player) {
				if(!IsPlayerInVehicle(i,vehicleid)) continue;
				if(GetPlayerState(i) == 2) {
					new Float:ppos[3];
					GetPlayerPos(playerid,ppos[0],ppos[1],ppos[2]);
					return t_SetPlayerPos(playerid,ppos[0]+0.1,ppos[1]+0.1,ppos[2]+0.01);
				}//ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
			}
		}
	}
	if(PI[playerid][pMember] == F_ARMY && LoadCarm[vehicleid] == true) {
		SPD(playerid, 2000, 0,"Погрузка","Вы хотите завершить загрузку патронов?","Да","Нет");
	}
	else if(PI[playerid][pMember] == F_ARMY && UnLoadCarm[vehicleid] == true) {
		SPD(playerid, 2001, 0,"Разгрузка","Вы хотите завершить разгрузку патронов?","Да","Нет");
	}
	if(IsAGang(playerid) && Start[vehicleid] == 1) {
		SPD(playerid, 2005, 0,"Погрузка","Вы хотите завершить загрузку патронов?","Да","Нет");
	}
	GunCheckTime[playerid] = 5;
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
	SpeedM[1][playerid] = 0, SpeedM[2][playerid] = 0;
	SetPVarInt(playerid,"AFK_Time",0);
	ResetCarInfo(playerid);
	GunCheckTime[playerid] = 5;
	if(vehicleid >= ArmyMatCar[0] && vehicleid <= ArmyMatCar[1]) DisablePlayerCheckpoint(playerid);
	if(vehicleid >= LBizz[1][lCars][0] && vehicleid <= LBizz[1][lCars][1]){
		if(GetVehicleModel(vehicleid) == 486) {
			DeletePVar(playerid,"GetLBRudaRand");
			DeletePVar(playerid,"GetLBRuda");
			if(GetPVarInt(playerid,"GetLBTimer") != 0) KillTimer(GetPVarInt(playerid,"GetLBTimer"));
			DeletePVar(playerid,"GetLBTimer");
			DisablePlayerRaceCheckpoint(playerid);
			if(GetPVarInt(playerid,"LBObj1") != 0) {
				DestroyDynamicObject(GetPVarInt(playerid,"LBObj1"));
				DestroyDynamicObject(GetPVarInt(playerid,"LBObj2"));
				DestroyDynamicObject(GetPVarInt(playerid,"LBObj3"));
				DestroyDynamicObject(GetPVarInt(playerid,"LBObj4"));
				DeletePVar(playerid,"LBObj1");
				DeletePVar(playerid,"LBObj2");
				DeletePVar(playerid,"LBObj3");
				DeletePVar(playerid,"LBObj4");
			}
		}
	}
	if(GetPVarInt(playerid, "FuelCarLittle") > 0) {
		PI[playerid][pPayCheck] += GetPVarInt(playerid, "JobLittlePrice");
		SendClientMessageEx(playerid, COLOR_BLUE, "Рабочий день завершен. Вами заработано: %i долларов", GetPVarInt(playerid, "JobLittlePrice"));
		SendClientMessage(playerid, COLOR_WHITE, "Деньги будут перечислены на счет во время зарплаты");
		DeletePVar(playerid, "FuelCarLittle");
		DeletePVar(playerid, "LittleFull");
		DeletePVar(playerid, "JobLittlePrice");
		DisablePlayerRaceCheckpoint(playerid);
	}
	if(Ether[playerid] == true) {
		new CB[16];
		Ether[playerid] = false;
		Convert(GetPVarInt(playerid,"InEther"),CB);
		strin = "";
		if(EtherSms[PI[playerid][pNews]-1] == true)
		format(strin, 90, "[F] %s выключил прием СМС",NamePlayer(playerid)), SendFMes(PI[playerid][pMember], COLOR_LIGHTRED, strin);
		if(EtherCall[PI[playerid][pNews]-1] == true)
		format(strin, 90, "[F] %s выключил прием звонков",NamePlayer(playerid)), SendFMes(PI[playerid][pMember], COLOR_LIGHTRED, strin);
		strin = "";
		format(strin, 90, "[F] %s вышел(а) из прямого эфира (Время в эфире: %s, звонков: %i, СМС: %i)",NamePlayer(playerid), CB, CallNews[PI[playerid][pNews]-1],SmsNews[PI[playerid][pNews]-1]);
		SendFMes(PI[playerid][pMember], COLOR_LIGHTRED, strin);
		EtherSms[PI[playerid][pNews]-1] = false;
		EtherCall[PI[playerid][pNews]-1] = false;
		SmsNews[PI[playerid][pNews]-1] = 0;
		CallNews[PI[playerid][pNews]-1] = 0;
		DeletePVar(playerid, "InEther");
		if(Mobile[playerid] != INVALID_PLAYER_ID) MobileCrash(playerid);
	}
	if(GetPVarInt(playerid, "PriceTaxi") > 0) {
		SendClientMessageEx(playerid, COLOR_PAYCHEC, "Рабочий день завершен. Вами заработано: {5d9f35}%i$", GetPVarInt(playerid, "TaxiMoney"));
		SendClientMessage(playerid, COLOR_PAYCHEC, "Деньги будут перечислены на банковский счет во время зарплаты.");
		DeletePVar(playerid, "PriceTaxi");
		DeletePVar(playerid, "TaxiMoney");
		DestroyDynamic3DTextLabel(TaxiText3D[playerid]);
		DisablePlayerCheckpoint(playerid);
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
	new vehicleid = GetPlayerVehicleID(playerid);
	if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) {
		KillTimer(STimer[playerid]);
		for(new i;i<7;i++) PlayerTextDrawHide(playerid, SpeedDraw[i][playerid]);
		if(vehicleid >= LBizz[1][lCars][0] && vehicleid <= LBizz[1][lCars][1]){
			if(GetVehicleModel(vehicleid) == 486) {
				DeletePVar(playerid,"GetLBRudaRand");
				DeletePVar(playerid,"GetLBRuda");
				if(GetPVarInt(playerid,"GetLBTimer") != 0) KillTimer(GetPVarInt(playerid,"GetLBTimer"));
				DeletePVar(playerid,"GetLBTimer");
				DisablePlayerRaceCheckpoint(playerid);
				if(GetPVarInt(playerid,"LBObj1") != 0) {
					DestroyDynamicObject(GetPVarInt(playerid,"LBObj1"));
					DestroyDynamicObject(GetPVarInt(playerid,"LBObj2"));
					DestroyDynamicObject(GetPVarInt(playerid,"LBObj3"));
					DestroyDynamicObject(GetPVarInt(playerid,"LBObj4"));
					DeletePVar(playerid,"LBObj1");
					DeletePVar(playerid,"LBObj2");
					DeletePVar(playerid,"LBObj3");
					DeletePVar(playerid,"LBObj4");
				}
			}
		}
	}
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER ) {
		if(PlayerLogged[playerid] == true)
		{
			if(GetPlayerSkin(playerid) == 0) NewKick(playerid,"[Античит]: Вы были кикнуты по подозрению в читерстве (#4444)");
			if(IDVEH[playerid] != GetPlayerVehicleID(playerid) || !UseEnter[playerid]) Punish(playerid);
			UseEnter[playerid] = false;
		}
	}
	switch(newstate) {
	case 1: //Игрок пешком (можно писать PLAYER_STATE_ONFOOT)
		{
			StopAudioStreamForPlayer(playerid);
			if(GetPVarInt(playerid, "LicTest") > 0) {
				SendClientMessage(playerid, COLOR_LIGHTRED, "У вас есть 15 секунд, чтобы вернуться");
				DisablePlayerRaceCheckpoint(playerid);
				SetPVarInt(playerid, "LicTime", 16);
			}
			if(GetPVarInt(playerid, "PriceBus") > 0) {
				SendClientMessage(playerid, COLOR_LIGHTRED, "У вас есть 30 секунд, чтобы вернуться в автобус!");
				Delete3DTextLabel(BusText3D[playerid]);
				DisablePlayerRaceCheckpoint(playerid);
				DeletePVar(playerid, "TimeBus");
				SetPVarInt(playerid, "BusTime", 31);
			}
			if(GetPVarInt(playerid, "ProductID") > 0) {
				SendClientMessage(playerid, COLOR_LIGHTRED, "У вас есть 15 секунд, чтобы вернуться");
				DisablePlayerRaceCheckpoint(playerid);
				Delete3DTextLabel(ProductInfo[GetPVarInt(playerid, "ProductID")][pText3D]);
				ProductTime[playerid] = 15;
			}
			if(GetPVarInt(playerid,"Collector_MGetting") != 0) DisablePlayerRaceCheckpoint(playerid),DeletePVar(playerid,"Collector_MGetting");
			if(GetPVarInt(playerid,"Collector_MWatering") != 0) DisablePlayerRaceCheckpoint(playerid),DeletePVar(playerid,"Collector_MWatering");
			if(GetPVarInt(playerid,"Collector_MWO1") != 0) {
				DestroyDynamicObject(GetPVarInt(playerid,"Collector_MWO1"));
				DestroyDynamicObject(GetPVarInt(playerid,"Collector_MWO2"));
				DestroyDynamicObject(GetPVarInt(playerid,"Collector_MWO3"));
				DestroyDynamicObject(GetPVarInt(playerid,"Collector_MWO4"));
				DeletePVar(playerid,"Collector_MWO4");
				DeletePVar(playerid,"Collector_MWO3");
				DeletePVar(playerid,"Collector_MWO2");
				DeletePVar(playerid,"Collector_MWO1");
			}
		}
	case 2: //Игрок в машине, на месте водителя (можно писать PLAYER_STATE_DRIVER)
		{
			if(InShop[playerid] > 0) return 1;
			OLDIDVEH[playerid] = vehicleid;
			SpeedM[1][playerid] = 0, SpeedM[2][playerid] = 0;
			new Float:vhelti;
			GetVehicleHealth(GetPlayerVehicleID(playerid), vhelti);
			AutoHelti[playerid] = vhelti;
			SetPlayerArmedWeapon(playerid,0);

			if(GetVehicleModel(vehicleid) == 481 || GetVehicleModel(vehicleid) == 509 || GetVehicleModel(vehicleid) == 510) {
				GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
				SetVehicleParamsEx(GetPlayerVehicleID(playerid),VEHICLE_PARAMS_ON,VEHICLE_PARAMS_ON,alarm,doors,bonnet,boot,objective);
				Engine[GetPlayerVehicleID(playerid)] = true;
			}
			if(Engine[GetPlayerVehicleID(playerid)] == false) SendClientMessage(playerid, COLOR_WHITE, "Чтобы завести двигатель, нажмите: {9ACD32}'Y'{FFFFFF} или введите: {9ACD32}'/en'");
			if(!IsABoat(vehicleid) && !IsAPlane(vehicleid) && GetVehicleModel(vehicleid) != 509 && GetVehicleModel(vehicleid) != 481 && GetVehicleModel(vehicleid) != 510) {
				STimer[playerid] = SetTimerEx("UpdateSpeedometr", 100, 1, "d", playerid);
				for(new i;i<7;i++) PlayerTextDrawShow(playerid, SpeedDraw[i][playerid]);
				PlayerTextDrawHide(playerid,SpeedDraw[2][playerid]);
				PlayerTextDrawSetPreviewModel(playerid, SpeedDraw[2][playerid], GetVehicleModel(GetPlayerVehicleID(playerid)));
				PlayerTextDrawSetPreviewVehCol(playerid, SpeedDraw[2][playerid],VehInfo[GetPlayerVehicleID(playerid)][vColor1],VehInfo[GetPlayerVehicleID(playerid)][vColor2]);
				PlayerTextDrawShow(playerid,SpeedDraw[2][playerid]);
			}
			if(PI[playerid][pLic][0] != 1) {
				if(GetPVarInt(playerid, "LicTest") > 0) { }
				else {
					if(GetVehicleModel(vehicleid) != 462 && GetVehicleModel(vehicleid) != 481 && GetVehicleModel(vehicleid) != 509 && GetVehicleModel(vehicleid) != 510) {
						SendClientMessage(playerid, COLOR_GREY, "У вас нет водительских прав!");
						RemovePlayerFromVehicleEx(playerid);
						return 1;
					}
				}
			}
			// Автобусы
			if(GetPVarInt(playerid, "PriceBus") > 0 && GetPVarInt(playerid, "BusTime") > 0) {
				for(new b = 21; b <= 56;b++) {
					if(vehicleid == BizzCarsPark[b][tcVehicle]) {
						if(BizzCarsPark[b][tcPID] == 2 && PI[playerid][pJob] == 2)
						{
							DeletePVar(playerid, "BusTime");
							new i = pPressed[playerid], type = GetPVarInt(playerid, "TypeBus");
							if(type == 1) SetPlayerRaceCheckpoint(playerid,0,VLS_001[i][0],VLS_001[i][1],VLS_001[i][2],VLS_001[i][3],VLS_001[i][4],VLS_001[i][5],5.0);//LS_001[i][0],LS_001[i][1],LS_001[i][2],LS_001[i][3],LS_001[i][4],LS_001[i][5],5.0
							if(type == 2) SetPlayerRaceCheckpoint(playerid,0,LS_002[i][0],LS_002[i][1],LS_002[i][2],LS_002[i][3],LS_002[i][4],LS_002[i][5],5.0);
							if(type == 3) SetPlayerRaceCheckpoint(playerid,0,VLS_001[i][0],VLS_001[i][1],VLS_001[i][2],VLS_001[i][3],VLS_001[i][4],VLS_001[i][5],5.0);
							new name[32];
							switch(type)
							{
							case 1: name = "Los Santos - Лесопилка";
							case 2: name = "Los Santos - Fort Carson";
							case 3: name = "Внутригородской Los Santos";
							}
							strin = "";
							format(strin, 90, "%s\n{ffffff}Стоимость проезда: {33AAFF}%i {ffffff}долларов", name, GetPVarInt(playerid, "PriceBus"));
							BusText3D[playerid] = Create3DTextLabel( strin, 0x33AAFFFF, 0.0, 0.0, 0.0, 50.0, 0, 1);
							Attach3DTextLabelToVehicle(BusText3D[playerid], GetPlayerVehicleID(playerid), 0.0, 0.0, 2.25);
							return 1;
						}
					}
				}
			}
			// Античит на езду при выключенном двигателе
			if(Engine[vehicleid] == false && SpeedVehicle(playerid)/2 > 60) {
				strin = "";
				format(strin, 256, "[Античит]: Игрок %s (ID: %i) был кикнут за читерство (Езда при выключенном двигателе)", NamePlayer(playerid), playerid);
				SendAdminMessage(COLOR_LIGHTRED, strin);
				NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (#1166)");
				SetVehicleToRespawn(GetPlayerVehicleID(playerid));
			}
			if(vehicleid >= TraktorVeh[0] && vehicleid <= TraktorVeh[1]) {
				if(JobTraktor[playerid] == 0) {
					SendClientMessage(playerid, -1, "Вы не работаете на этой должности!");
					RemovePlayerFromVehicle(playerid);
					return true;
				}
			}
			if(vehicleid >= CombineVeh[0] && vehicleid <= CombineVeh[1]) {
				if(JobCombine[playerid] == 0) {
					SendClientMessage(playerid, -1, "Вы не работаете на этой должности!");
					RemovePlayerFromVehicle(playerid);
					return true;
				}
			}
			if(vehicleid >= FlyVeh[0] && vehicleid <= FlyVeh[1]) {
				if(JobFly[playerid] == 0) {
					SendClientMessage(playerid, -1, "Вы не работаете на этой должности!");
					RemovePlayerFromVehicle(playerid);
					return true;
				}
			}
			if(vehicleid >= LBizz[1][lCars][0] && vehicleid <= LBizz[1][lCars][1]) {
				if(strcmp(LBizz[1][lOwner],NamePlayer(playerid)) != 0 && strcmp(LBizz[1][lWorker_1],NamePlayer(playerid)) != 0 && strcmp(LBizz[1][lWorker_2],NamePlayer(playerid)) != 0 && strcmp(LBizz[1][lWorker_3],NamePlayer(playerid)) != 0) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт! #1");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
				else {
					if(GetVehicleModel(vehicleid) == 486) {
						SetPlayerRaceCheckpoint(playerid,0,-1383.8345,2109.7976,42.3904,-1330.0692,2101.9507,40.8955,5.0);
						SendClientMessage(playerid,COLOR_GREEN,"Отправляйтесь по красным маркерам для погрузки породы.");
					}
				}
			}
			if(vehicleid >= LBizz[2][lCars][0] && vehicleid <= LBizz[2][lCars][1]+2) {
				if(strcmp(LBizz[2][lOwner],NamePlayer(playerid)) != 0 && strcmp(LBizz[2][lWorker_1],NamePlayer(playerid)) != 0 && strcmp(LBizz[2][lWorker_2],NamePlayer(playerid)) != 0 && strcmp(LBizz[2][lWorker_3],NamePlayer(playerid)) != 0) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт! #2");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
				else {
					if(GetVehicleModel(vehicleid) == 572) {
						new tmptree;
						for(new i;i<76;i++) {
							if(GardenTreesIs[i] <= -1) {
								tmptree++;
							}
						}
						if(tmptree >= 75) return SendClientMessage(playerid,COLOR_GREY,"Сад не нуждается в обслуживании.");
						SendClientMessage(playerid,COLOR_YELLOW,"Возьмите удобрение со склада.");
						SetPlayerRaceCheckpoint(playerid,1,-1071.3224,-1211.4507,128.7986,-1071.3224,-1211.4507,128.7986,2.0);
						SetPVarInt(playerid,"Collector_MWatering",-1);
					}
					else if(vehicleid == GardenWaterTruck) {
						if(GetPVarInt(playerid,"Collector_MTrucking") == 0) {
							if(LBizz[2][lMaterials][1] >= 15000) return SendClientMessage(playerid,COLOR_RED,"Бочки полны");
							SendClientMessage(playerid,COLOR_GREEN,"Для доставки воды отправляйтесь по маркеру.");
							SetPlayerRaceCheckpoint(playerid,1,-919.0276,2020.0289,60.7528,-919.0276,2020.0289,60.7528,5.0);
							SetPVarInt(playerid,"Collector_MTrucking",1);
						}
						else if(GetPVarInt(playerid,"Collector_MTrucking") == 1) {
							SendClientMessage(playerid,COLOR_GREEN,"Для доставки воды отправляйтесь по маркеру.");
							SetPlayerRaceCheckpoint(playerid,1,-919.0276,2020.0289,60.7528,-919.0276,2020.0289,60.7528,5.0);
							SetPVarInt(playerid,"Collector_MTrucking",1);
						}
						else if(GetPVarInt(playerid,"Collector_MTrucking") == 2) {
							SendClientMessage(playerid,COLOR_GREEN,"Перевезите погруженную жидкость на ферму.");
							SetPlayerRaceCheckpoint(playerid,1,-1100.4751,-1177.8204,129.8441,-1100.4751,-1177.8204,129.8441,5.0);
						}
					}
					else {
						if(vehicleid == LBizz[2][lCars][0])
						{
							if(GardenCarsIs[0][0] >= 10)
							{
								SetPlayerRaceCheckpoint(playerid,1,-1084.3141,-1195.7756,128.7987,-1084.3141,-1195.7756,128.7987,2.0);
								return SendClientMessage(playerid,COLOR_RED,"Машина заполнена, разгрузите ее на складе.");
							}
						}
						else if(vehicleid == LBizz[2][lCars][1]) {
							if(GardenCarsIs[1][0] >= 10) {
								SetPlayerRaceCheckpoint(playerid,1,-1084.3141,-1195.7756,128.7987,-1084.3141,-1195.7756,128.7987,2.0);
								return SendClientMessage(playerid,COLOR_RED,"Машина заполнена, разгрузите ее на складе.");
							}
						}
						SendClientMessage(playerid,COLOR_GREEN,"Припаркуйте данный Bobcat в саду, чтобы рабочие его загрузили.");
						SetPVarInt(playerid, "Collector_MGetting", 1);
						switch(GardenCarsIs[vehicleid-LBizz[2][lCars][0]][1]-1) {
						case 0: SetPlayerRaceCheckpoint(playerid,1,-1137.9281,-1197.3164,129.2099,-1137.9281,-1197.3164,129.2099,5.0);
						case 1: SetPlayerRaceCheckpoint(playerid,1,-1181.8412,-1196.9894,129.2065,-1181.8412,-1196.9894,129.2065,5.0);
						case 2: SetPlayerRaceCheckpoint(playerid,1,-1143.7201,-1179.9158,129.2047,-1143.7201,-1179.9158,129.2047,5.0);
						case 3: SetPlayerRaceCheckpoint(playerid,1,-1150.6014,-1213.4669,129.2046,-1150.6014,-1213.4669,129.2046,5.0);
						default: {
								switch(random(3)) {
								case 0: SetPlayerRaceCheckpoint(playerid,1,-1137.9281,-1197.3164,129.2099,-1137.9281,-1197.3164,129.2099,5.0),SetPVarInt(playerid,"Collector_MGetCP",1);
								case 1: SetPlayerRaceCheckpoint(playerid,1,-1181.8412,-1196.9894,129.2065,-1181.8412,-1196.9894,129.2065,5.0),SetPVarInt(playerid,"Collector_MGetCP",2);
								case 2: SetPlayerRaceCheckpoint(playerid,1,-1143.7201,-1179.9158,129.2047,-1143.7201,-1179.9158,129.2047,5.0),SetPVarInt(playerid,"Collector_MGetCP",3);
								case 3: SetPlayerRaceCheckpoint(playerid,1,-1150.6014,-1213.4669,129.2046,-1150.6014,-1213.4669,129.2046,5.0),SetPVarInt(playerid,"Collector_MGetCP",4);
								}
							}
						}
					}
				}
			}
			if(vehicleid >= PDcar[0] && vehicleid <= PDcar[21]) {
				if(PI[playerid][pMember] != 2) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			if(vehicleid >= LVPDcar[0] && vehicleid <= LVPDcar[1]) {
				if(PI[playerid][pMember] != F_LVPD) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			if(vehicleid >= SFPDcar[0] && vehicleid <= SFPDcar[1]) {
				if(PI[playerid][pMember] != F_SFPD) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 432 && GetVehicleModel(GetPlayerVehicleID(playerid)) == 520 && GetVehicleModel(GetPlayerVehicleID(playerid)) == 425) {
				if (PI[playerid][pMember] == F_ARMY && PI[playerid][pRank] >= 7 || PI[playerid][pLeader] == F_VMF && PI[playerid][pMember] == F_VMF && PI[playerid][pRank] >= 7 || PI[playerid][pLeader] == F_VMF && PI[playerid][pAdmLevel] > 1) { }
				else {
					RemovePlayerFromVehicleEx(playerid);
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
				}
			}
			if(vehicleid >= VMFCar[0] && vehicleid <= VMFCar[1]) {
				if(PI[playerid][pMember] != F_VMF) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			if(vehicleid >= ArmyCar[0] && vehicleid <= ArmyCar[1]) {
				if(PI[playerid][pMember] != 13) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			// ambucile
			if(vehicleid >= ambucile[0] && vehicleid <= ambucile[1]) {
				if(PI[playerid][pMember] != 5) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			if(IsABoat(vehicleid)) {
				if(PI[playerid][pLic][1] < 1) {
					SendClientMessage(playerid, COLOR_GREY, "У вас нет прав на водный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
				}
			}
			if(IsAPlane(vehicleid)) {
				if(PI[playerid][pLic][2] < 1) {
					SendClientMessage(playerid, COLOR_GREY, "У вас нет прав на воздушный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
				}
			}
			if(vehicleid >= fuelcar[0] && vehicleid <= fuelcar[1]) {
				if(PI[playerid][pJob] != 5) {
					SendClientMessage(playerid, COLOR_GREY, "Вы не развозчик топлива!");
					RemovePlayerFromVehicle(playerid);
					return 1;
				}
				if(GetPVarInt(playerid, "FuelCar") == GetPlayerVehicleID(playerid)) {
					if(GetVehicleModel(vehicleid) == 583 && GetPVarInt(playerid, "FuelCarLittle") == 0) {
						SetPVarInt(playerid, "FuelCarLittle", 1);
						new full;
						if(full == 0)
						{
							PI[playerid][pPayCheck] += GetPVarInt(playerid, "JobLittlePrice");
							DeletePVar(playerid, "LittleFull");
							DeletePVar(playerid, "JobLittlePrice");
							DeletePVar(playerid, "FuelCarLittle");
							RemovePlayerFromVehicle(playerid);
							return SendClientMessage(playerid, COLOR_GREY, "В скважинах нет топлива, подождите!");
						}
						SendClientMessage(playerid, COLOR_YELLOW, "Следуйте на чекпоинт, чтобы взять груз");
						SetPVarInt(playerid, "LittleFull", full);
						full--;
						if(full == 0) SetPlayerRaceCheckpoint(playerid, 1, 433.7109,1580.9321,11.4922, 0.0, 0.0, 0.0, 5.0);
						if(full == 1) SetPlayerRaceCheckpoint(playerid, 1, 600.3598,1515.3052,7.8325, 0.0, 0.0, 0.0, 5.0);
						if(full == 2) SetPlayerRaceCheckpoint(playerid, 1, 578.3732,1439.7570,11.1406, 0.0, 0.0, 0.0, 5.0);
						if(full == 3) SetPlayerRaceCheckpoint(playerid, 1, 627.6626,1369.1279,11.9845, 0.0, 0.0, 0.0, 5.0);
						if(full == 4) SetPlayerRaceCheckpoint(playerid, 1, 353.2522,1317.3221,12.4766, 0.0, 0.0, 0.0, 5.0);
					}
					if(FuelTime[playerid] > 0) {
						new Float:VPos[3], i = FuelInfo[GetPVarInt(playerid, "FuelID")][pBizzid];
						FuelTime[playerid] = 0;
						GetPlayerPos(playerid, VPos[0], VPos[1], VPos[2]);
						DisablePlayerRaceCheckpoint(playerid);
						SetPlayerRaceCheckpoint(playerid, 1, BizzInfo[i][bEntrx], BizzInfo[i][bEntry], BizzInfo[i][bEntrz], 0.0,0.0,0.0,6);
						strin = "";
						format(strin, 100, "{9ACD32}Топлива: {ffffff}%i / 50000{9ACD32} литров", FuelInfo[GetPVarInt(playerid, "FuelID")][pTill]);
						FuelInfo[GetPVarInt(playerid, "FuelID")][pText3D] = Create3DTextLabel(strin, 0xffffffff, 0.0, 0.0, 0.0, 30.0, 0, 1);
						Attach3DTextLabelToVehicle(FuelInfo[GetPVarInt(playerid, "FuelID")][pText3D], GetPlayerVehicleID(playerid), 0, -1.0, 2.0);
					}
				}
				else SPD(playerid, DIALOG_JOB+124, 0, "{ffffff}Аренда", "{ffffff}Вы хотите арендовать данное тр. средство?\n\nСтоимость: {33CCFF}1000{ffffff} долларов", "Да", "Нет");
			}
			if(vehicleid >= jobproduct[0] && vehicleid <= jobproduct[1]) {
				if(PI[playerid][pJob] != 3) {
					SendClientMessage(playerid, COLOR_GREY, "Вы не развозчик продуктов!");
					RemovePlayerFromVehicleEx(playerid);
					return true;
				}
				if(ProductTime[playerid] > 0) {
					new Float:VPos[3], i = ProductInfo[GetPVarInt(playerid, "ProductID")][pBizzid];
					ProductTime[playerid] = 0;
					GetPlayerPos(playerid, VPos[0], VPos[1], VPos[2]);
					DisablePlayerRaceCheckpoint(playerid);
					SetPlayerRaceCheckpoint(playerid, 1, BizzInfo[i][bEntrx], BizzInfo[i][bEntry], BizzInfo[i][bEntrz], 0.0,0.0,0.0,6);
					strin = "";
					format(strin, 50, "{9ACD32}Продуктов: {ffffff}%i", ProductInfo[GetPVarInt(playerid, "ProductID")][pTill]);
					ProductInfo[GetPVarInt(playerid, "ProductID")][pText3D] = Create3DTextLabel(strin, 0xffffffff, 0.0, 0.0, 0.0, 30.0, 0, 1);
					Attach3DTextLabelToVehicle(ProductInfo[GetPVarInt(playerid, "ProductID")][pText3D], GetPlayerVehicleID(playerid), 0, -1.0, 0.5);
				}
			}
			if(vehicleid >= mercar[0] && vehicleid <= mercar[1]) {
				if(PI[playerid][pMember] != 1) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			if(vehicleid >= sancar[0] && vehicleid <= sancar[1]) {
				if(PI[playerid][pMember] != 3) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			if(vehicleid >= mechanics[0] && vehicleid <= mechanics[9]) {
				if(PI[playerid][pJob] != 4) {
					SendClientMessage(playerid, COLOR_GREY, "Вы не работаете механиком!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			if(vehicleid >= fbicar[0] && vehicleid <= fbicar[1]) {
				if(PI[playerid][pMember] != 11) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			if(vehicleid >= fishcar[0] && vehicleid <= fishcar[1]) {
				if(Fishjob[playerid] < 1) {
					SendClientMessage(playerid, COLOR_GREY, "Вы не работаете рыболовом!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			if(vehicleid >= liccar[0] && vehicleid <= liccar[6]) {
				if(GetPVarInt(playerid, "LicTest") > 0) {
					SendClientMessage(playerid, COLOR_BLUE, "Следуйте по чекпоинтам, соблюдая правила дорожного движения");
					new i = pPressed[playerid];
					SetPlayerRaceCheckpoint(playerid,0,LicTest[i][0],LicTest[i][1],LicTest[i][2],LicTest[i][3],LicTest[i][4],LicTest[i][5],5.0);
					if(GetPVarInt(playerid, "LicTime") > 0) return DeletePVar(playerid, "LicTime");

				}
				else {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			if(vehicleid >= schoolcar[0] && vehicleid <= schoolcar[1]) {
				if(PI[playerid][pMember] != F_LIC) {
					SendClientMessage(playerid, COLOR_GREY, "Данный транспорт пренадлежит сотрудникам автошколы!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			//Ballas
			if(vehicleid >= GangCar[0] && vehicleid <= GangCar[1] || vehicleid == GangAmmoCar[0]) {
				if(PI[playerid][pMember] != 7) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			// Grove
			if(vehicleid >= GangCar[2] && vehicleid <= GangCar[3] || vehicleid == GangAmmoCar[1]) {
				if(PI[playerid][pMember] != 6) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			// Vagos
			if(vehicleid >= GangCar[4] && vehicleid <= GangCar[5] || vehicleid == GangAmmoCar[2]) {
				if(PI[playerid][pMember] != 9) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			// Aztecas
			if(vehicleid >= GangCar[6] && vehicleid <= GangCar[7] || vehicleid == GangAmmoCar[3]) {
				if(PI[playerid][pMember] != 8) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			// Rifa
			if(vehicleid >= GangCar[8] && vehicleid <= GangCar[9] || vehicleid == GangAmmoCar[4]) {
				if(PI[playerid][pMember] != 10) {
					SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
					RemovePlayerFromVehicleEx(playerid);
					return 1;
				}
			}
			for(new i = 1; i <= 20;i++) {
				if(vehicleid == BizzCarsPark[i][tcVehicle]) {

					if(BizzCarsPark[i][tcPID] == 1 && PI[playerid][pJob] == 1) {
						if(!strcmp(BizzPark[1][tOwner],"None",true)) return SendClientMessage(playerid, COLOR_GREY, "Таксопарк не имеет владельца!"), RemovePlayerFromVehicleEx(playerid);
						SPD(playerid, 60, 0, "Такси - Los Santos", "Такси - Los Santos\nВы хотите начать рабочий день?", "Да", "Нет");
						return 1;
					}
					else
					{
						SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
						RemovePlayerFromVehicleEx(playerid);
					}
				}
			}
			for(new i = 21; i <= 30;i++) {
				if(vehicleid == BizzCarsPark[i][tcVehicle]) {
					if(BizzCarsPark[i][tcPID] == 2 && PI[playerid][pJob] == 2) {
						if(!strcmp(BizzPark[2][tOwner],"None",true)) return SendClientMessage(playerid, COLOR_GREY, "Автобусный парк не имеет владельца!"), RemovePlayerFromVehicleEx(playerid);
						if(GetPVarInt(playerid, "RentBus") == vehicleid) return 1;
						SPD(playerid, 64, 0, "Автобусный парк", "Автобусный парк - Los Santos\nВы хотите начать рабочий день?", "Да", "Нет");
					}
					else
					{
						SendClientMessage(playerid, COLOR_GREY, "Вам недоступен данный транспорт!");
						RemovePlayerFromVehicleEx(playerid);
						return 1;
					}
				}
			}

		}
	case 3: //Игрок в машине, на месте пассажира - (можно писать PLAYER_STATE_PASSENGER)
		{
			new Weap[2];
			GetPlayerWeaponData(playerid,4, Weap[0], Weap[1]);
			SetPlayerArmedWeapon(playerid, Weap[0]);

			if(Engine[vehicleid] == false && SpeedVehicle(playerid)/2 > 60) {
				strin = "";
				format(strin, 256, "[Античит]: Игрок %s (ID: %i) был кикнут за читерство (Езда при выключенном двигателе)", NamePlayer(playerid), playerid);
				SendAdminMessage(COLOR_LIGHTRED, strin);
				NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (#1166)");
				SetVehicleToRespawn(vehicleid);
			}
			foreach(new i: Player) {
				if(PlayerLogged[i] == false) continue;
				if(IsPlayerInVehicle(i, vehicleid) && GetPlayerState(i) == 2) {
					if(GetPVarInt(i, "PriceBus") > 0) {
						if(GetMoney(playerid) < GetPVarInt(i, "PriceBus"))
						{
							SendClientMessageEx(playerid, COLOR_GREY, "Недостаточно средств!");
							RemovePlayerFromVehicleEx(playerid);
						}
						else
						{
							GiveMoney(playerid, -GetPVarInt(i, "PriceBus"));
							SendClientMessageEx(playerid, COLOR_BLUE, "Вы заплатили %i$ за проезд водителю %s'у",GetPVarInt(i, "PriceBus"), NamePlayer(i));
							PI[i][pPayCheck] += GetPVarInt(i, "PriceBus")/2;
							BizzPark[2][tBank] += GetPVarInt(i, "PriceBus")/2;
							SendClientMessageEx(i, COLOR_BLUE, "Пассажир %s заплатил %i$ за проезд", NamePlayer(playerid), GetPVarInt(i, "PriceBus"));
							strin = "";
							format(strin, 10, "~r~-%i$",  GetPVarInt(i, "PriceBus"));
							GameTextForPlayer(playerid, strin, 5000, 1);
							strin = "";
							format(strin, 10, "~b~+%i$", GetPVarInt(i, "PriceBus"));
							GameTextForPlayer(i, strin, 5000, 1);
						}
					}
					if(GetPVarInt(i, "PriceTaxi") > 0) {
						if(GetMoney(playerid) < GetPVarInt(i, "PriceTaxi"))
						{
							SendClientMessageEx(playerid, COLOR_GREY, "Недостаточно средств!");
							RemovePlayerFromVehicleEx(playerid);
						}
						else
						{
							GiveMoney(playerid, -GetPVarInt(i, "PriceTaxi"));
							BizzPark[1][tBank] += GetPVarInt(i, "PriceTaxi")/2;
							PI[i][pPayCheck] += GetPVarInt(i, "PriceTaxi")/2;
							SetPVarInt(playerid, "TimeTaxi", 30);
							SetPVarInt(playerid, "TaxiPrice",GetPVarInt(i, "PriceTaxi"));
							SetPVarInt(playerid, "PlayerTaxi", i);
							strin = "";
							format(strin, 10, "~r~-%i$", GetPVarInt(i, "PriceTaxi"));
							GameTextForPlayer(playerid, strin, 5000, 1);
							strin = "";
							format(strin, 10, "~b~+%i$", GetPVarInt(i, "PriceTaxi"));
							GameTextForPlayer(i, strin, 5000, 1);
							SetPVarInt(i, "TaxiMoney", GetPVarInt(i, "TaxiMoney") + GetPVarInt(i, "PriceTaxi")/2);

							SetPVarInt(playerid,"PlayerTaxi",i);
							SendClientMessageEx(playerid, COLOR_GREY, "Вы можете выбрать один из маршрутов либо сказать куда ехать.");
							return SPD(playerid, 4500, 2, "Куда едем", "- Мэрия\n- Банк\n- Биржа труда\n- Лесопилка\n- Шахта\n- Грузчики\n- Автошкола", "Выбрать", "Отмена");
						}
					}
				}
			}
		}
	case 9: //Игрок наблюдает с помощью функции SPECTATING (можно писать PLAYER_STATE_SPECTATING)
		{
			if(PI[playerid][pAdmLevel] < 1) {
				if(GetPVarInt(playerid,"InvizCheat") > 0) NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (#1105)");
			}
		}
	}
	return 1;
}
public OnPlayerEnterCheckpoint(playerid) {
	if(SelectFarmJob[playerid] == 2 || SelectFarmJob[playerid] == 3)
	SetFarmCheck(playerid);

	if(SelectFarmJob[playerid]) {
		if(IsPlayerInRangeOfPoint(playerid,2.0, -83.5173,55.5051,3.1172))
		{
			ApplyAnimation(playerid,"PED","IDLE_chat",4.1,0,0,0,1,5150);
			InPlayerPoint[playerid] = 1;
			if(random(2)) SetPlayerCheckpoint(playerid, -150.8812,-34.2264,3.1172, 2.0);
			else SetPlayerCheckpoint(playerid, -37.3504,-46.2130,3.1172, 2.0);
		}
		if(IsPlayerInRangeOfPoint(playerid,2.0, -69.1939,-36.8022,3.1172))
		{
			ApplyAnimation(playerid,"PED","IDLE_chat",4.1,0,0,0,1,5150);
			SetPlayerAttachedObject(playerid,1, 1458, 1, -1.034844, 1.116571, -0.065124, 76.480148, 75.781570, 280.952545, 0.575599, 0.604554, 0.624122);
			SetPlayerAttachedObject(playerid,2, 2060, 1, -0.275758, 1.305280, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);// Дали камень
			InPlayerPoint[playerid] = 1;
			if(random(2)) SetPlayerCheckpoint(playerid, -124.8055,36.3951,3.1172, 2.0);
			else SetPlayerCheckpoint(playerid, -49.3619,-83.9263,3.1094, 2.0);
		}
		if(IsPlayerInRangeOfPoint(playerid,2.0, 8.5415,55.5826,3.1172))
		{
			SetPlayerSpecialAction(playerid,25);
			SetPlayerAttachedObject(playerid, 1 , 2901, 1,0.11,0.36,0.0,0.0,90.0);
			InPlayerPoint[playerid] = 1;
			SetPlayerCheckpoint(playerid, -64.8744,38.6510,3.1103, 2.0);
		}
		if(IsPlayerInRangeOfPoint(playerid,2.0, -96.3521,122.7176,3.1096))
		{
			SetPlayerSpecialAction(playerid,25);
			SetPlayerAttachedObject(playerid, 1 , 2901, 1,0.11,0.36,0.0,0.0,90.0);
			InPlayerPoint[playerid] = 1;
			SetPlayerCheckpoint(playerid, -64.8744,38.6510,3.1103, 2.0);
		}
		if(IsPlayerInRangeOfPoint(playerid,2.0, -64.8744,38.6510,3.1103))
		{
			ApplyAnimation(playerid, "CARRY", "putdwn", 4.1, 0, 0, 0, 0, 0,1);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 2)) RemovePlayerAttachedObject(playerid, 2);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 3)) RemovePlayerAttachedObject(playerid, 3);
			SetPlayerSpecialAction(playerid,0);
			InPlayerPoint[playerid] = 0;
			OnLevelKol[playerid]++;
			Skill[playerid] += 20;
			strin = "";
			format(strin, sizeof(strin), "Всего сена перенесено: %d",OnLevelKol[playerid]);
			SendClientMessage(playerid, -1, strin);
			strin = "";
			format(strin, sizeof(strin), "Ты получил +20 к скиллу,твой скилл %d",Skill[playerid]);
			SendClientMessage(playerid, -1, strin);
			if(random(2)) SetPlayerCheckpoint(playerid, 8.5415,55.5826,3.1172, 2.0);
			else SetPlayerCheckpoint(playerid, -96.3521,122.7176,3.1096, 2.0);
		}
		if(IsPlayerInRangeOfPoint(playerid,2.0, -124.8055,36.3951,3.1172))
		{
			if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 2)) RemovePlayerAttachedObject(playerid, 2);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 3)) RemovePlayerAttachedObject(playerid, 3);
			InPlayerPoint[playerid] = 0;
			OnLevelKol[playerid]++;
			Skill[playerid] += 20;
			strin = "";
			format(strin, sizeof(strin), "Всего зерна перенесено: %d",OnLevelKol[playerid]);
			SendClientMessage(playerid, -1, strin);
			strin = "";
			format(strin, sizeof(strin), "Ты получил +20 к скиллу,твой скилл %d",Skill[playerid]);
			SendClientMessage(playerid, -1, strin);
			SetPlayerCheckpoint(playerid, -69.1939,-36.8022,3.1172, 2.0);
		}
		if(IsPlayerInRangeOfPoint(playerid,2.0, -49.3619,-83.9263,3.1094))
		{
			if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 2)) RemovePlayerAttachedObject(playerid, 2);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 3)) RemovePlayerAttachedObject(playerid, 3);
			InPlayerPoint[playerid] = 0;
			OnLevelKol[playerid]++;
			Skill[playerid] += 20;
			strin = "";
			format(strin, sizeof(strin), "Всего зерна перенесено: %d",OnLevelKol[playerid]);
			SendClientMessage(playerid, -1, strin);
			strin = "";
			format(strin, sizeof(strin), "Ты получил +20 к скиллу,твой скилл %d",Skill[playerid]);
			SendClientMessage(playerid, -1, strin);
			SetPlayerCheckpoint(playerid, -69.1939,-36.8022,3.1172, 2.0);
		}
		if(IsPlayerInRangeOfPoint(playerid,2.0, -150.8812,-34.2264,3.1172))
		{
			InPlayerPoint[playerid] = 0;
			OnLevelKol[playerid]++;
			Skill[playerid] += 20;
			if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 2)) RemovePlayerAttachedObject(playerid, 2);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 3)) RemovePlayerAttachedObject(playerid, 3);
			strin = "";
			format(strin, sizeof(strin), "Всего ведер воды перенесено: %d",OnLevelKol[playerid]);
			SendClientMessage(playerid, -1, strin);
			strin = "";
			format(strin, sizeof(strin), "Ты получил +20 к скиллу,твой скилл %d",Skill[playerid]);
			SendClientMessage(playerid, -1, strin);
			SetPlayerCheckpoint(playerid, -83.5173,55.5051,3.1172, 2.0);
		}
		if(IsPlayerInRangeOfPoint(playerid,2.0, -37.3504,-46.2130,3.1172))
		{
			InPlayerPoint[playerid] = 0;
			OnLevelKol[playerid]++;
			Skill[playerid] += 20;
			if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 2)) RemovePlayerAttachedObject(playerid, 2);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 3)) RemovePlayerAttachedObject(playerid, 3);
			strin = "";
			format(strin, sizeof(strin), "Всего ведер воды перенесено: %d",OnLevelKol[playerid]);
			SendClientMessage(playerid, -1, strin);
			strin = "";
			format(strin, sizeof(strin), "Ты получил +20 к скиллу,твой скилл %d",Skill[playerid]);
			SendClientMessage(playerid, -1, strin);
			SetPlayerCheckpoint(playerid, -83.5173,55.5051,3.1172, 2.0);
		}
	}
	if(GetPVarInt(playerid,"FishCP") > 0) {
		switch(GetPVarInt(playerid,"FishCP"))
		{
		case CPID_JOBKRUB_TAKECAGE: {
				if(IsPlayerInAnyVehicle(playerid)) return true;
				new numberPirs = GetPVarInt(playerid, "jobkrub_numberPirs");
				SetPlayerCheckpoint(playerid, coordinationPirs[numberPirs][0], coordinationPirs[numberPirs][1], coordinationPirs[numberPirs][2], 2.0);
				SetPVarInt(playerid,"FishCP", CPID_JOBKRUB_PUTCAGE);
				SetPVarInt(playerid, "jobkrub_cage_status", 1);
				SetPVarInt(playerid, "jobkrub_cage_count", GetPVarInt(playerid, "jobkrub_cage_count")+1);
				strin = "";
				format(strin, sizeof strin, "TAKE CAGE: %i/6", GetPVarInt(playerid, "jobkrub_cage_count"));
				GameTextForPlayer(playerid, strin, 2000, 3);
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);

				SetDynamicObjectMaterial(objects_krubjob[playerid][0], 0, 3214, "quarry", "Was_swr_trolleycage", 0xFFFFFFFF);
				SetPlayerAttachedObject(playerid, 0, 964, 6, 0.301999, 0.040999, -0.189999, -118.499984, -18.399999, -99.399986, 0.747000, 0.680000, 0.599999);
				SetPlayerAttachedObject(playerid,1,964,5,0.142999,0.229999,-0.442999,1.799999,16.799995,17.600006,0.612999,0.208000,1.061999);
				return 1;
			}
		case CPID_JOBKRUB_PUTCAGE: {
				if(!GetPVarInt(playerid, "jobkrub_cage_status")) return 1;
				DeletePVar(playerid, "jobkrub_cage_status");
				new count = GetPVarInt(playerid, "jobkrub_cage_count")-1;
				strin = "";
				format(strin, sizeof strin, "PUT CAGE: %i/6", count+1);
				GameTextForPlayer(playerid, strin, 2000, 3);
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
				if(IsPlayerAttachedObjectSlotUsed(playerid, 0)) RemovePlayerAttachedObject(playerid, 0);
				if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);

				objectsOnCar_krubjob[playerid][count] = CreateDynamicObject(964, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 300.0);
				SetDynamicObjectMaterial(objectsOnCar_krubjob[playerid][count], 0, 3214, "quarry", "Was_swr_trolleycage", 0xFFFFFFFF);

				AttachDynamicObjectToVehicle(objectsOnCar_krubjob[playerid][count], krub_car[GetPVarInt(playerid, "jobkrub_numberPirs")], coordinationObjectOnCar[count][0], coordinationObjectOnCar[count][1], coordinationObjectOnCar[count][2], 0.000000, 0.000000, 0.000000);
				if(GetPVarInt(playerid, "jobkrub_cage_count") == 6) {
					SendClientMessage(playerid, -1, "Это была последняя клетка, садитесь за штурвал.");
					new numberPirs = GetPVarInt(playerid, "jobkrub_numberPirs");
					SetPlayerRaceCheckpoint(playerid, 2, coordinationWaterPirs[numberPirs][0], coordinationWaterPirs[numberPirs][1], coordinationWaterPirs[numberPirs][2], coordinationWaterPirs[numberPirs][0], coordinationWaterPirs[numberPirs][1], coordinationWaterPirs[numberPirs][2], 4.0);
					SetPVarInt(playerid,"FishCP",CPID_NOPE);
					DisablePlayerCheckpoint(playerid);
					SetPVarInt(playerid,"FishRCP", RCPID_JOBKRUB_START_MARSHRUT);
					SetPVarInt(playerid, "jobkrub_step", 2);
					DeletePVar(playerid, "jobkrub_cage_count");
					DeletePVar(playerid, "jobkrub_cage_status");
				}
				else {
					SetPVarInt(playerid,"FishCP", CPID_JOBKRUB_TAKECAGE);
					SetPlayerCheckpoint(playerid, -89.8498,-1556.2446,2.6553, 2.0);
				}
				return 1;
			}

		case CPID_JOBKRUB_TAKECAGE2: {
				if(IsPlayerInAnyVehicle(playerid)) return true;
				SetPlayerCheckpoint(playerid, -89.8498,-1556.2446,2.6553, 2.0);
				SetPVarInt(playerid,"FishCP",CPID_JOBKRUB_PUTCAGE2);
				SetPVarInt(playerid, "jobkrub_cage_status", 1);
				DestroyDynamicObject(objectsOnCar_krubjob[playerid][5-GetPVarInt(playerid, "jobkrub_cage_count")]);

				strin = "";
				format(strin, sizeof strin, "TAKE CAGE: %i/6", GetPVarInt(playerid, "jobkrub_cage_count")+1);
				GameTextForPlayer(playerid, strin, 2000, 3);
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
				SetPlayerAttachedObject(playerid, 0, 964, 6, 0.301999, 0.040999, -0.189999, -118.499984, -18.399999, -99.399986, 0.747000, 0.680000, 0.599999);
				SetPlayerAttachedObject(playerid,1,964,5,0.142999,0.229999,-0.442999,1.799999,16.799995,17.600006,0.612999,0.208000,1.061999);
				return 1;
			}
		case CPID_JOBKRUB_PUTCAGE2: {
				if(!GetPVarInt(playerid, "jobkrub_cage_status")) return 1;
				DeletePVar(playerid, "jobkrub_cage_status");
				new count = GetPVarInt(playerid, "jobkrub_cage_count");
				strin = "";
				format(strin, sizeof strin, "PUT CAGE: %i/6", count+1);
				GameTextForPlayer(playerid, strin, 2000, 3);
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
				if(IsPlayerAttachedObjectSlotUsed(playerid, 0)) RemovePlayerAttachedObject(playerid, 0);
				if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);
				SetPVarInt(playerid, "jobkrub_cage_count", GetPVarInt(playerid, "jobkrub_cage_count")+1);
				if(GetPVarInt(playerid, "jobkrub_cage_count") == 6) {
					SendClientMessage(playerid, -1, "Это была последняя клетка. Увольтесь с работы!");
					SetPVarInt(playerid,"FishCP", CPID_NOPE);
					DisablePlayerCheckpoint(playerid);
					SetPVarInt(playerid, "jobkrub_step", 6);
					DeletePVar(playerid, "jobkrub_cage_count");
					DeletePVar(playerid, "jobkrub_cage_status");
				}
				else {
					SetPVarInt(playerid,"FishCP", CPID_JOBKRUB_TAKECAGE2);
					new numberPirs = GetPVarInt(playerid, "jobkrub_numberPirs");
					SetPlayerCheckpoint(playerid, coordinationPirs[numberPirs][0], coordinationPirs[numberPirs][1], coordinationPirs[numberPirs][2], 2.0);
				}
				return 1;
			}
		}

	}
	if(GetPVarInt(playerid,"FishCP") > 0) {
		switch(GetPVarInt(playerid,"FishCP"))
		{
		case CPID_JOBKRUB_TAKECAGE: {
				if(IsPlayerInAnyVehicle(playerid)) return true;
				new numberPirs = GetPVarInt(playerid, "jobkrub_numberPirs");
				SetPlayerCheckpoint(playerid, coordinationPirs[numberPirs][0], coordinationPirs[numberPirs][1], coordinationPirs[numberPirs][2], 2.0);
				SetPVarInt(playerid,"FishCP", CPID_JOBKRUB_PUTCAGE);
				SetPVarInt(playerid, "jobkrub_cage_status", 1);
				SetPVarInt(playerid, "jobkrub_cage_count", GetPVarInt(playerid, "jobkrub_cage_count")+1);
				strin = "";
				format(strin, sizeof strin, "TAKE CAGE: %i/6", GetPVarInt(playerid, "jobkrub_cage_count"));
				GameTextForPlayer(playerid, strin, 2000, 3);
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);

				SetDynamicObjectMaterial(objects_krubjob[playerid][0], 0, 3214, "quarry", "Was_swr_trolleycage", 0xFFFFFFFF);
				SetPlayerAttachedObject(playerid, 0, 964, 6, 0.301999, 0.040999, -0.189999, -118.499984, -18.399999, -99.399986, 0.747000, 0.680000, 0.599999);
				SetPlayerAttachedObject(playerid,1,964,5,0.142999,0.229999,-0.442999,1.799999,16.799995,17.600006,0.612999,0.208000,1.061999);
				return 1;
			}
		case CPID_JOBKRUB_PUTCAGE: {
				if(!GetPVarInt(playerid, "jobkrub_cage_status")) return 1;
				DeletePVar(playerid, "jobkrub_cage_status");
				new count = GetPVarInt(playerid, "jobkrub_cage_count")-1;
				strin = "";
				format(strin, sizeof strin, "PUT CAGE: %i/6", count+1);
				GameTextForPlayer(playerid, strin, 2000, 3);
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
				if(IsPlayerAttachedObjectSlotUsed(playerid, 0)) RemovePlayerAttachedObject(playerid, 0);
				if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);

				objectsOnCar_krubjob[playerid][count] = CreateDynamicObject(964, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 300.0);
				SetDynamicObjectMaterial(objectsOnCar_krubjob[playerid][count], 0, 3214, "quarry", "Was_swr_trolleycage", 0xFFFFFFFF);

				AttachDynamicObjectToVehicle(objectsOnCar_krubjob[playerid][count], krub_car[GetPVarInt(playerid, "jobkrub_numberPirs")], coordinationObjectOnCar[count][0], coordinationObjectOnCar[count][1], coordinationObjectOnCar[count][2], 0.000000, 0.000000, 0.000000);
				if(GetPVarInt(playerid, "jobkrub_cage_count") == 6) {
					SendClientMessage(playerid, -1, "Это была последняя клетка, садитесь за штурвал.");
					new numberPirs = GetPVarInt(playerid, "jobkrub_numberPirs");
					SetPlayerRaceCheckpoint(playerid, 2, coordinationWaterPirs[numberPirs][0], coordinationWaterPirs[numberPirs][1], coordinationWaterPirs[numberPirs][2], coordinationWaterPirs[numberPirs][0], coordinationWaterPirs[numberPirs][1], coordinationWaterPirs[numberPirs][2], 4.0);
					SetPVarInt(playerid,"FishCP",CPID_NOPE);
					DisablePlayerCheckpoint(playerid);
					SetPVarInt(playerid,"FishRCP", RCPID_JOBKRUB_START_MARSHRUT);
					SetPVarInt(playerid, "jobkrub_step", 2);
					DeletePVar(playerid, "jobkrub_cage_count");
					DeletePVar(playerid, "jobkrub_cage_status");
				}
				else {
					SetPVarInt(playerid,"FishCP", CPID_JOBKRUB_TAKECAGE);
					SetPlayerCheckpoint(playerid, -89.8498,-1556.2446,2.6553, 2.0);
				}
				return 1;
			}

		case CPID_JOBKRUB_TAKECAGE2: {
				if(IsPlayerInAnyVehicle(playerid)) return true;
				SetPlayerCheckpoint(playerid, -89.8498,-1556.2446,2.6553, 2.0);
				SetPVarInt(playerid,"FishCP",CPID_JOBKRUB_PUTCAGE2);
				SetPVarInt(playerid, "jobkrub_cage_status", 1);
				DestroyDynamicObject(objectsOnCar_krubjob[playerid][5-GetPVarInt(playerid, "jobkrub_cage_count")]);

				strin = "";
				format(strin, sizeof strin, "TAKE CAGE: %i/6", GetPVarInt(playerid, "jobkrub_cage_count")+1);
				GameTextForPlayer(playerid, strin, 2000, 3);
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
				SetPlayerAttachedObject(playerid, 0, 964, 6, 0.301999, 0.040999, -0.189999, -118.499984, -18.399999, -99.399986, 0.747000, 0.680000, 0.599999);
				SetPlayerAttachedObject(playerid,1,964,5,0.142999,0.229999,-0.442999,1.799999,16.799995,17.600006,0.612999,0.208000,1.061999);
				return 1;
			}
		case CPID_JOBKRUB_PUTCAGE2: {
				if(!GetPVarInt(playerid, "jobkrub_cage_status")) return 1;
				DeletePVar(playerid, "jobkrub_cage_status");
				new count = GetPVarInt(playerid, "jobkrub_cage_count");
				strin = "";
				format(strin, sizeof strin, "PUT CAGE: %i/6", count+1);
				GameTextForPlayer(playerid, strin, 2000, 3);
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
				if(IsPlayerAttachedObjectSlotUsed(playerid, 0)) RemovePlayerAttachedObject(playerid, 0);
				if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);
				SetPVarInt(playerid, "jobkrub_cage_count", GetPVarInt(playerid, "jobkrub_cage_count")+1);
				if(GetPVarInt(playerid, "jobkrub_cage_count") == 6) {
					SendClientMessage(playerid, -1, "Это была последняя клетка. Увольтесь с работы!");
					SetPVarInt(playerid,"FishCP", CPID_NOPE);
					DisablePlayerCheckpoint(playerid);
					SetPVarInt(playerid, "jobkrub_step", 6);
					DeletePVar(playerid, "jobkrub_cage_count");
					DeletePVar(playerid, "jobkrub_cage_status");
				}
				else {
					SetPVarInt(playerid,"FishCP", CPID_JOBKRUB_TAKECAGE2);
					new numberPirs = GetPVarInt(playerid, "jobkrub_numberPirs");
					SetPlayerCheckpoint(playerid, coordinationPirs[numberPirs][0], coordinationPirs[numberPirs][1], coordinationPirs[numberPirs][2], 2.0);
				}
				return 1;
			}
		}
	}
	if(GetPVarInt(playerid,"Work") == 1) {
		RemovePlayerAttachedObject(playerid,2);
		ClearAnimations(playerid);
		ApplyAnimation(playerid,"CAR_CHAT","CAR_Sc4_BL",4.0,1,1,1,0,22000,0);
		SetTimerEx("SeloLoad",20000,false,"i",playerid);
	}
	if(GetPVarInt(playerid,"loadid") == 10 && GetPVarInt(playerid,"Work") == 1) {
		ApplyAnimation(playerid,"CARRY","crry_prtial",4.0,1,1,1,1,1,1);
		SetPlayerAttachedObject(playerid, 2, 2384, 5, 0.01, 0.1, 0.2, 100, 10, 85);
		new cjob = Random(0,5);
		SetPlayerCheckpoint(playerid,gSeloCP[cjob][0],gSeloCP[cjob][1],gSeloCP[cjob][2]-1,1.2);
		SetPVarInt(playerid,"loadid",cjob+1);
	}
	if(GetPVarInt(playerid,"loadid") == 20 && GetPVarInt(playerid,"Work") == 1) {
		cWorkSalary[playerid] += 40;
		strin = "";
		format(strin,sizeof(strin),"Одежда здана. +40$ {ffffff}к вашей зарплате. Всего заработано: %d$",cWorkSalary[playerid]);
		SendClientMessage(playerid,COLOR_PAYCHEC,strin);
		RemovePlayerAttachedObject(playerid,2);
		ClearAnimations(playerid);
		SetPVarInt(playerid,"loadid",10);
		ClearAnimations(playerid,1);
		SetPlayerCheckpoint(playerid,-41.0592,-189.0606,928.7820-1,1.2);
	}
	if(GetPVarInt(playerid, "Garden") == 1) {
		SetTimerEx("GardenEnd",7000,0,"%i",playerid);
		GameTextForPlayer(playerid,"~g~+1",5200,5);
		AmmountWood[playerid] += 1;
		ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,1,1,1,1,0);
		new rand = random(sizeof(TreeSad));
		SetPlayerCheckpoint(playerid,TreeSad[rand][0],TreeSad[rand][1],TreeSad[rand][2],3.0);
		DisablePlayerCheckpoint(playerid);
		return true;
	}
	if(FishStart[playerid] == 1) {
		FishBegin[playerid] = 1;
		SendClientMessage(playerid, COLOR_YELLOW, "Начинайте рыбачить,в этом месте.");
		DisablePlayerCheckpoint(playerid);
	}
	if(OnOneLevelJob[playerid] < 1) {
		if(GetPVarInt(playerid,"YEAH") == 1)
		{
			SendClientMessage(playerid, COLOR_YELLOW, "Вы достигли места назначения!");
			SetPVarInt(playerid,"YEAH",0);
			DisablePlayerCheckpoint(playerid);
			return 1;
		}
		if(GetPVarInt(playerid,"TaxiCheck") == 1)
		{
			SendClientMessage(playerid, COLOR_YELLOW, "Вы достигли места назначения!");
			SetPVarInt(playerid,"TaxiCheck",0);
			DisablePlayerCheckpoint(playerid);
			return 1;
		}
		if(GetPVarInt(playerid,"GPS") == 1)
		{
			SendClientMessage(playerid, COLOR_YELLOW, "Вы достигли места назначения!");
			SetPVarInt(playerid,"GPS",0);
			DisablePlayerCheckpoint(playerid);
			return 1;
		}
		if(GetPVarInt(playerid,"GPSCar") == 1)
		{
			SendClientMessage(playerid, COLOR_YELLOW, "Вы достигли места назначения!");
			DeletePVar(playerid,"GPSCar");
			DisablePlayerCheckpoint(playerid);
			return 1;
		}
	}
	if(GetPVarInt(playerid,"Miner") == 2) {
		RemovePlayerAttachedObject(playerid,4);
		DisablePlayerCheckpoint(playerid);
		TogglePlayerControllable(playerid,1);
		ClearAnimations(playerid);
		ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
		SetPVarInt(playerid,"Miner", 1);
		PI[playerid][pJobAmount][0] += GetPVarInt(playerid, "MinerKG_One");
		SendClientMessageEx(playerid,COLOR_PAYCHEC ,"Вы принесли %i кг железа, всего Вами добыто: %i кг", GetPVarInt(playerid, "MinerKG_One"), PI[playerid][pJobAmount][0]);
		SetPlayerAttachedObject(playerid, 3, 18634, 6, 0.078222, 0.000000, 0.110844, 298.897308, 264.126861, 193.350555, 1.000000, 1.000000, 1.000000);
		rock_a[playerid] = CreateObject(3930,480.5320129,867.7780151,3008.4689941,0.0000000,48.0000000,0.0000000);
		MoveObject(rock_a[playerid],480.5320129,872.7780151,3008.4689941,2.00);
		timer_rock = SetTimerEx("timer_rockp",3100, false, "i", playerid);
		SavePlayer(playerid);
		return 1;
	}
	if(GetPVarInt(playerid, "Gruz") > 0 && GetPVarInt(playerid, "GruzYes") < 1 && IsPlayerInRangeOfPoint(playerid, 1.4, 2042.6589,-1958.3080,14.3957)) {
		if(GetPVarInt(playerid,"FloodGruz") > gettime()) return 1;
		DisablePlayerCheckpoint(playerid);
		ClearAnimations(playerid);
		ApplyAnimation(playerid,"CARRY","crry_prtial",4.1,0,1,1,1,1);
		SetPlayerAttachedObject(playerid, 2, 2060, 5, 0.01, 0.1, 0.2, 100, 10, 85);
		SetPlayerCheckpoint(playerid,2014.7725,-1986.8894,13.5469,1.4);
		TOTALGRUZ -= 1;
		strin = "";
		format(strin, 125, "{ffffff}Мешков: {e2ba00}%d из 500",TOTALGRUZ);
		Update3DTextLabelText(GruzText[0], COLOR_YELLOW, strin);
		SendClientMessageEx(playerid,COLOR_PAYCHEC ,"Вы взяли мешок с продуктами, отнесите его на склад.");
		SetPVarInt(playerid, "GruzYes",1);
		SetPVarInt(playerid,"FloodGruz",gettime() + 15);
		return 1;
	}
	if(GetPVarInt(playerid, "Gruz") > 0 && GetPVarInt(playerid, "GruzYes") > 0 && IsPlayerInRangeOfPoint(playerid, 1.4, 2014.7725,-1986.8894,13.5469)) {
		if(TOTALGRUZ <= 0)
		{
			DisablePlayerCheckpoint(playerid),SendClientMessage(playerid, COLOR_YELLOW, "В вагоне больше нет мешков!");
			ClearAnimations(playerid);
			ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
			RemovePlayerAttachedObject(playerid,2);
			return 1;
		}
		DisablePlayerCheckpoint(playerid);
		RemovePlayerAttachedObject(playerid,2);
		SetPlayerCheckpoint(playerid,2042.6589,-1958.3080,14.3957,1.4);
		SetPVarInt(playerid, "GruzYes",0);
		PI[playerid][pJobAmount][1]++;
		ClearAnimations(playerid);
		ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
		return 1;
	}
	if(GetPVarInt(playerid, "LessPil") > 0 && IsPlayerInRangeOfPoint(playerid, 3.0, -749.0853,-121.2919,66.0043)) {
		DisablePlayerCheckpoint(playerid);
		RemovePlayerAttachedObject(playerid,3);
		new rand = 30 + random(50);
		PI[playerid][pJobAmount][2] += rand;
		strin = "";
		format(strin,30,"+%d",rand);
		ChatBubble(playerid, strin);
		ClearAnimations(playerid); ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
		DeletePVar(playerid, "Derevo");
		SetPVarInt(playerid, "LessProc", 0);
		SetPVarInt(playerid, "LessStatus", 0);
		TextDrawShowForPlayer(playerid, ProcentDraw[playerid]);
		SetPVarInt(playerid, "Derevo", TOTALDEREVO);
		TOTALDEREVO++;
		SetPlayerCheckpoint(playerid,Derevo[GetPVarInt(playerid, "Derevo")][0],Derevo[GetPVarInt(playerid, "Derevo")][1],Derevo[GetPVarInt(playerid, "Derevo")][2], 3.0);
		SavePlayer(playerid);
		return 1;
	}
	if(GetPVarInt(playerid, "GMiner") == 2) {
		SPD(playerid,-1,0,"","","","");
		ApplyAnimation(playerid, "BOMBER","BOM_Plant_Loop",4.0,1,0,0,0,0);
		SetPVarInt(playerid,"Animation",4);
		SelectTextDraw(playerid, 0xE0D012AA);
		SetPVarInt(playerid,"GMinerMode",1);
		ApplyAnimation(playerid, "BOMBER","BOM_Plant_Loop",4.0,1,0,0,0,0);
		TextDrawShowForPlayer(playerid,FULLBOX);
		SetPVarInt(playerid, "GMinerG_One",random(10)+5);
		new PlayerText:tmpvar;
		for(new i;i < GetPVarInt(playerid,"GMinerG_One");i++) {
			strin = "";
			format(strin,16,"GMiner_CTD%i",i);
			switch(random(3)) {
			case 0: tmpvar = CreatePlayerTextDraw(playerid,299.000000+(random(10)*29.1), 189.000000-(random(10)*18.1), "kamen");
			case 1: tmpvar = CreatePlayerTextDraw(playerid,299.000000+(random(10)*29.1), 189.000000+(random(10)*20.1), "kamen");
			case 2: tmpvar = CreatePlayerTextDraw(playerid,299.000000-(random(10)*28.9), 189.000000-(random(10)*18.1), "kamen");
			case 3: tmpvar = CreatePlayerTextDraw(playerid,299.000000-(random(10)*28.9), 189.000000+(random(10)*20.1), "kamen");
			}
			PlayerTextDrawBackgroundColor(playerid,tmpvar, 0);
			PlayerTextDrawFont(playerid,tmpvar, 5);
			PlayerTextDrawLetterSize(playerid,tmpvar, 0.500000, 1.000000);
			PlayerTextDrawColor(playerid,tmpvar, -1);
			PlayerTextDrawSetOutline(playerid,tmpvar, 0);
			PlayerTextDrawSetProportional(playerid,tmpvar, 1);
			PlayerTextDrawSetShadow(playerid,tmpvar, 1);
			PlayerTextDrawUseBox(playerid,tmpvar, 1);
			PlayerTextDrawBoxColor(playerid,tmpvar, 255);
			PlayerTextDrawTextSize(playerid,tmpvar, 47.000000+(random(60)*0.5), 44.000000+(random(60)*0.5));
			PlayerTextDrawSetPreviewModel(playerid, tmpvar, 905);
			PlayerTextDrawSetPreviewRot(playerid, tmpvar, -16.000000, 0.000000, 0.000000, 0.899999);
			PlayerTextDrawSetSelectable(playerid,tmpvar, 1);
			PlayerTextDrawShow(playerid,tmpvar);
			SetPVarInt(playerid,strin,_:tmpvar);
			SPD(playerid,-1,0,"","","","");
		}
	}
	if(ToCallTime[playerid] > 0) return DisablePlayerCheckpoint(playerid);
	if(GetPVarInt(playerid,"Collector_NotGived") >= 30) {
		if(IsPlayerInRangeOfPoint(playerid,5.0,-1082.6498,-1195.5306,129.2188)) {
			LBizz[2][lMaterials][0]+=GetPVarInt(playerid,"Collector_NotGived");
			DisablePlayerCheckpoint(playerid);
			strin = "";
			format(strin,30,"+%i",GetPVarInt(playerid,"Collector_NotGived"));//One"));
			GameTextForPlayer(playerid, strin, 750, 3);
			ChatBubble(playerid, strin);
			SetPlayerSpecialAction(playerid,0);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 4)) RemovePlayerAttachedObject(playerid, 4);
			AmountLBizz[playerid][1] += GetPVarInt(playerid, "Collector_NotGived");
			GiveMoney(playerid,GetPVarInt(playerid, "Collector_NotGived")*2);
			format(spect,32,"AMOUNT: %i",AmountLBizz[playerid][1]);
			TextDrawSetString(MinerDraw[playerid],spect);
			SetPlayerSpecialAction(playerid, 0);
			for(new x;x < 76;x++) if(GardenCheckpoints[x] != 0) TogglePlayerDynamicCP(playerid, GardenCheckpoints[x], 1);
			SPD(playerid,-1,0,"","","","");
			DeletePVar(playerid,"Collector_NotGived");
		}
	}
	return 1;
}
public OnPlayerEnterRaceCheckpoint(playerid) {
	if(GetPlayerVehicleID(playerid) >= LBizz[1][lCars][0] && GetPlayerVehicleID(playerid) <= LBizz[1][lCars][1]) {
		if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 486) {
			if(GetPVarInt(playerid,"GetLBRuda") == 0) {
				SetPlayerRaceCheckpoint(playerid,1,-1330.0692,2101.9507,40.8955,-1361.3854,2107.0049,41.0793,5.0);
				SetPVarInt(playerid,"GetLBRuda",1);
			}
			else if(GetPVarInt(playerid,"GetLBRuda") == 1) {
				SetPVarInt(playerid,"GetLBRuda",2);
				SetPVarInt(playerid,"GetLBRudaMode",1);
				SelectTextDraw(playerid, 0xE0D012AA);
				SetPVarInt(playerid,"GetLBRudaRand",random(10)+10);
				TextDrawShowForPlayer(playerid,FULLBOX);
				new PlayerText:tmpvar;
				for(new i;i < GetPVarInt(playerid,"GetLBRudaRand");i++) {
					strin = "";
					format(strin,16,"GLB_CTD%i",i);
					tmpvar = CreatePlayerTextDraw(playerid,177.0+(random(10)*24.0), 289.0, "kamen_bottom");
					PlayerTextDrawBackgroundColor(playerid,tmpvar, 0);
					PlayerTextDrawFont(playerid,tmpvar, 5);
					PlayerTextDrawLetterSize(playerid,tmpvar, 0.500000, 1.000000);
					PlayerTextDrawColor(playerid,tmpvar, -1);
					PlayerTextDrawSetOutline(playerid,tmpvar, 0);
					PlayerTextDrawSetProportional(playerid,tmpvar, 1);
					PlayerTextDrawSetShadow(playerid,tmpvar, 1);
					PlayerTextDrawUseBox(playerid,tmpvar, 1);
					PlayerTextDrawBoxColor(playerid,tmpvar, 0); //255
					PlayerTextDrawTextSize(playerid,tmpvar, 47.000000+(random(60)*0.5), 44.000000+(random(60)*0.5));
					PlayerTextDrawSetPreviewModel(playerid, tmpvar, 905);
					PlayerTextDrawSetPreviewRot(playerid, tmpvar, -16.000000, 0.000000, 0.000000, 0.899999);
					PlayerTextDrawSetSelectable(playerid,tmpvar, 1);
					PlayerTextDrawShow(playerid,tmpvar);
					SetPVarInt(playerid,strin,_:tmpvar);
				}
				//  				TogglePlayerControllable(playerid, false);
				//  				if(GetPVarInt(playerid,"GetLBTimer") == 0) SetPVarInt(playerid,"GetLBTimer",SetTimerEx("GetLBRudaTimer",1000,1,"i",playerid));
			}
			else if(GetPVarInt(playerid,"GetLBRuda") == 2) {
				DestroyDynamicObject(GetPVarInt(playerid,"LBObj1"));
				DestroyDynamicObject(GetPVarInt(playerid,"LBObj2"));
				DestroyDynamicObject(GetPVarInt(playerid,"LBObj3"));
				DestroyDynamicObject(GetPVarInt(playerid,"LBObj4"));
				DeletePVar(playerid,"LBObj1");
				DeletePVar(playerid,"LBObj2");
				DeletePVar(playerid,"LBObj3");
				DeletePVar(playerid,"LBObj4");
				//   				SetPlayerRaceCheckpoint(playerid,0,-1383.8345,2109.7976,42.3904,-1330.0692,2101.9507,40.8955,5.0);
				SetPlayerRaceCheckpoint(playerid,1,-1330.0692,2101.9507,40.8955,-1361.3854,2107.0049,41.0793,5.0);
				SendClientMessageEx(playerid,COLOR_GREEN,"Вы выгрузили загруженные %i кг породы",GetPVarInt(playerid,"GetLBRudaRand"));
				LBizz[1][lMaterials][0]+=GetPVarInt(playerid,"GetLBRudaRand");
				strin = "";
				format(strin,192,"Породы: %d килограмм",LBizz[1][lMaterials][0]);
				SetDynamicObjectMaterialText(LBizz[1][lObject], 0, strin, 130, "Tahoma", 38, 1, -1, -12303292, 1);
				//				UpdateDynamic3DTextLabelText(LBizz[1][lText][0],0xFFFFFFFF,strin);
				DeletePVar(playerid,"GetLBRudaRand");
				SetPVarInt(playerid,"GetLBRuda",1);
			}
		}
	}
	if(GetPlayerVehicleID(playerid) >= LBizz[2][lCars][0] && GetPlayerVehicleID(playerid) <= LBizz[2][lCars][1]+2) {
		if(GetPlayerVehicleID(playerid) == GardenSmallCar)
		{
			new tmpvar = GetPVarInt(playerid,"Collector_MWatering");
			if(tmpvar == -1) {
				for(new i;i<76;i++) {
					if(GardenTreesIs[i] <= -1) {
						tmpvar = CreateDynamicObject(1575,0.0,0.0,0.0,0.0,0.0,0.0); //object(drug_white) (1)
						AttachDynamicObjectToVehicle(tmpvar,GardenSmallCar,0.0312000,-0.6963000,-0.0304000,0.0000000,0.0000000,0.0000000); //object(drug_white) (1)
						SetPVarInt(playerid,"Collector_MWO1",tmpvar);
						tmpvar = CreateDynamicObject(1575,0.0,0.0,0.0,0.0,0.0,0.0);
						AttachDynamicObjectToVehicle(tmpvar,GardenSmallCar,0.0185000,-0.8962000,-0.0554000,0.0000000,0.0000000,0.0000000); //object(drug_white) (2)
						SetPVarInt(playerid,"Collector_MWO2",tmpvar);
						tmpvar = CreateDynamicObject(1575,0.0,0.0,0.0,0.0,0.0,0.0);
						AttachDynamicObjectToVehicle(tmpvar,GardenSmallCar,0.0186000,-0.8936000,0.0946000,0.0000000,0.0000000,0.0000000); //object(drug_white) (3)
						SetPVarInt(playerid,"Collector_MWO3",tmpvar);
						tmpvar = CreateDynamicObject(1575,0.0,0.0,0.0,0.0,0.0,0.0);
						AttachDynamicObjectToVehicle(tmpvar,GardenSmallCar,-0.0066000,-0.8999000,0.2446000,0.0000000,0.0000000,0.0000000); //object(drug_white) (4)
						SetPVarInt(playerid,"Collector_MWO4",tmpvar);

						SetPlayerRaceCheckpoint(playerid,1,GardenTrees[i][0]+1.0,GardenTrees[i][1]+1.0,129.21875,-1094.9667,-1175.1188,128.7986,2.0);
						SetPVarInt(playerid,"Collector_MWatering",i+1);
						return SendClientMessage(playerid,COLOR_GREEN,"Отправляйтесь по красным маркерам для обработки деревьев.");
					}
				}
				DisablePlayerRaceCheckpoint(playerid);
				DeletePVar(playerid,"Collector_MWatering");
				return SendClientMessage(playerid,COLOR_GREY,"Сад не нуждается в обслуживании.");
			}
			else if(tmpvar >= 1) {
				GardenTreesIs[tmpvar-1] = 0;
				SendClientMessage(playerid,COLOR_GREEN,"Дерево обработано, но нуждается в поливке..");
				SetPlayerRaceCheckpoint(playerid,1,-1071.3224,-1211.4507,128.7986,-1071.3224,-1211.4507,128.7986,2.0);
				SetPVarInt(playerid,"Collector_MWatering",-1);
				DestroyDynamicObject(GetPVarInt(playerid,"Collector_MWO1"));
				DestroyDynamicObject(GetPVarInt(playerid,"Collector_MWO2"));
				DestroyDynamicObject(GetPVarInt(playerid,"Collector_MWO3"));
				DestroyDynamicObject(GetPVarInt(playerid,"Collector_MWO4"));
				DeletePVar(playerid,"Collector_MWO4");
				DeletePVar(playerid,"Collector_MWO3");
				DeletePVar(playerid,"Collector_MWO2");
				DeletePVar(playerid,"Collector_MWO1");
			}
		}
		else if(GetPlayerVehicleID(playerid) == GardenWaterTruck) {
			if(GetPVarInt(playerid,"Collector_MTrucking") == 1) {
				SendClientMessage(playerid,COLOR_GREEN,"Перевезите погруженную жидкость на ферму.");
				SetPlayerRaceCheckpoint(playerid,1,-1100.4751,-1177.8204,129.8441,-1100.4751,-1177.8204,129.8441,5.0);
				SetPVarInt(playerid,"Collector_MTrucking",2);
			}
			else if(GetPVarInt(playerid,"Collector_MTrucking") == 2) {
				SendClientMessage(playerid,COLOR_GREEN,"Жидкость была разгружена на складе.");
				LBizz[2][lMaterials][1] +=2000;

				strin = "";
				format(strin,32,"%i литров",LBizz[2][lMaterials][1]);
				SetDynamicObjectMaterialText(LBizz[2][lObject], 0, strin, 130, "Arial", 37, 1, 0xFF5E6B92, -8092540, 1);
				DisablePlayerRaceCheckpoint(playerid);
				return DeletePVar(playerid,"Collector_MTrucking");
			}
		}
		else {
			if(GetPVarInt(playerid,"Collector_MGetting") == 0) return true;
			if(GetPlayerVehicleID(playerid) == LBizz[2][lCars][0]) {
				if(GardenCarsIs[0][0] >= 10) {
					LBizz[2][lMaterials][0]+=1000;
					GardenCarsIs[0][0] = 0;
					SetPVarInt(playerid, "Collector_MGetting", 1);
					switch(random(3)) {
					case 0: SetPlayerRaceCheckpoint(playerid,1,-1137.9281,-1197.3164,129.2099,-1137.9281,-1197.3164,129.2099,5.0);
					case 1: SetPlayerRaceCheckpoint(playerid,1,-1181.8412,-1196.9894,129.2065,-1181.8412,-1196.9894,129.2065,5.0);
					case 2: SetPlayerRaceCheckpoint(playerid,1,-1143.7201,-1179.9158,129.2047,-1143.7201,-1179.9158,129.2047,5.0);
					case 3: SetPlayerRaceCheckpoint(playerid,1,-1150.6014,-1213.4669,129.2046,-1150.6014,-1213.4669,129.2046,5.0);
					}
					for(new i;i < 34;i++) {
						if(GardenBObjects[0][i] != 0) DestroyDynamicObject(GardenBObjects[0][i]);
					}
					return SendClientMessage(playerid,COLOR_GREEN,"Машина была разгружена на складе!");
				}
			}
			else if(GetPlayerVehicleID(playerid) == LBizz[2][lCars][1]) {
				if(GardenCarsIs[1][0] >= 10) {
					LBizz[2][lMaterials][0]+=1000;
					GardenCarsIs[1][0] = 0;
					SetPVarInt(playerid, "Collector_MGetting", 1);
					switch(random(3)) {
					case 0: SetPlayerRaceCheckpoint(playerid,1,-1137.9281,-1197.3164,129.2099,-1137.9281,-1197.3164,129.2099,5.0);
					case 1: SetPlayerRaceCheckpoint(playerid,1,-1181.8412,-1196.9894,129.2065,-1181.8412,-1196.9894,129.2065,5.0);
					case 2: SetPlayerRaceCheckpoint(playerid,1,-1143.7201,-1179.9158,129.2047,-1143.7201,-1179.9158,129.2047,5.0);
					case 3: SetPlayerRaceCheckpoint(playerid,1,-1150.6014,-1213.4669,129.2046,-1150.6014,-1213.4669,129.2046,5.0);
					}
					for(new i;i < 34;i++) {
						if(GardenBObjects[1][i] != 0) DestroyDynamicObject(GardenBObjects[1][i]);
					}
					return SendClientMessage(playerid,COLOR_GREEN,"Машина была разгружена на складе!");
				}
			}
			new Float:cPX,Float:cPY,Float:cPZ;
			GetVehiclePos(GetPlayerVehicleID(playerid), cPX, cPY, cPZ);
			GetCoordBootVehicle(GetPlayerVehicleID(playerid), cPX, cPY, cPZ);

			if(GetPlayerVehicleID(playerid) == LBizz[2][lCars][0]) {
				if( GardenCPicks[0] != 0 ) DestroyDynamicPickup(GardenCPicks[0]),DestroyDynamic3DTextLabel(GardenCText[0]);
				GardenCPicks[0] = CreateDynamicPickup(916,23,cPX,cPY,cPZ, -1, -1);
				GardenCText[0] = CreateDynamic3DTextLabel("Загрузка яблок\n0 / 1000",0xFFFFFFFF,cPX,cPY,cPZ,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
			}
			else if(GetPlayerVehicleID(playerid) == LBizz[2][lCars][1]) {
				if( GardenCPicks[1] != 0) DestroyDynamicPickup(GardenCPicks[1]),DestroyDynamic3DTextLabel(GardenCText[1]);
				GardenCPicks[1] = CreateDynamicPickup(916,23,cPX,cPY,cPZ, -1, -1);
				GardenCText[1] = CreateDynamic3DTextLabel("Загрузка яблок\n0 / 1000",0xFFFFFFFF,cPX,cPY,cPZ,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
			}
			SetVehicleParamsEx(GetPlayerVehicleID(playerid),VEHICLE_PARAMS_OFF,lights,alarm,doors,bonnet,boot,objective);

			SetVehicleVelocity(GetPlayerVehicleID(playerid),0.0,0.0,0.0);
			GameTextForPlayer(playerid, "PARKED.", 3000, 1);
			GardenCarsIs[GetPlayerVehicleID(playerid)-LBizz[2][lCars][0]][1] = GetPVarInt(playerid,"Collector_MGetCP");
			DeletePVar(playerid,"Collector_MGetCP");
		}
	}
	if(GetPVarInt(playerid,"FishRCP") > 0) {
		switch(GetPVarInt(playerid,"FishRCP"))
		{
		case RCPID_JOBKRUB_MARSHRUT_PUT: {
				if((GetPVarInt(playerid, "jobkrub_step") != 2) || GetPVarInt(playerid, "jobkrub_putcage_status")) return 1;
				SetPVarInt(playerid, "jobkrub_putcage_status", 1);
				SetPVarInt(playerid, "jobkrub_putcage_height", 1);
				new numberPirs = GetPVarInt(playerid, "jobkrub_numberPirs");
				objects_krubjob[playerid][0] = CreateDynamicObject(964, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 300.0);
				AttachDynamicObjectToVehicle(objects_krubjob[playerid][0], krub_car[numberPirs], 0.000000, -6.295096, 1.519998, 0.000000, 0.000000, 0.000000);
				for(new ycoord = 1; ycoord < 11; ycoord++) {
					objects_krubjob[playerid][ycoord] = CreateDynamicObject(19087, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 300.0);
					AttachDynamicObjectToVehicle(objects_krubjob[playerid][ycoord], krub_car[numberPirs], 0.000000, -6.260095, (ycoord == 1) ? (3.475032) : (3.475032-(2.415033*(ycoord-1))), 0.000000, 0.000000, 0.000000);
				}
				DestroyDynamicObject(objectsOnCar_krubjob[playerid][5-GetPVarInt(playerid, "jobkrub_putcage_point_count")]);
				showPlayerPanelCage(playerid, 1, 1);
				new Float: pos[3];
				GetVehiclePos(GetPlayerVehicleID(playerid), pos[0], pos[1], pos[2]), SetVehiclePos(GetPlayerVehicleID(playerid), pos[0], pos[1], pos[2]);
				return 1;
			}
		case RCPID_JOBKRUB_MARSHRUT_TAKE: {
				if((GetPVarInt(playerid, "jobkrub_step") != 3) || GetPVarInt(playerid, "jobkrub_takecage_status")) return 1;

				SetPVarInt(playerid, "jobkrub_takecage_status", 1);
				SetPVarInt(playerid, "jobkrub_takecage_height", 9);

				new numberPirs = GetPVarInt(playerid, "jobkrub_numberPirs");
				objects_krubjob[playerid][0] = CreateDynamicObject(964, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 300.0);
				AttachDynamicObjectToVehicle(objects_krubjob[playerid][0], krub_car[numberPirs], 0.000000, -6.295096, -22.630332, 0.000000, 0.000000, 0.000000);
				for(new ycoord = 1; ycoord < 11; ycoord++) {
					objects_krubjob[playerid][ycoord] = CreateDynamicObject(19087, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, -1, 300.0);
					AttachDynamicObjectToVehicle(objects_krubjob[playerid][ycoord], krub_car[numberPirs], 0.000000, -6.260095, (ycoord == 1) ? (3.475032) : (3.475032-(2.415033*(ycoord-1))), 0.000000, 0.000000, 0.000000);
				}
				showPlayerPanelCage(playerid, 1, 2);
				new Float: pos[3];
				GetVehiclePos(GetPlayerVehicleID(playerid), pos[0], pos[1], pos[2]), SetVehiclePos(GetPlayerVehicleID(playerid), pos[0], pos[1], pos[2]);
				return 1;
			}
		case RCPID_JOBKRUB_RETURN_PIRS: {
				SetPVarInt(playerid,"FishRCP", RCPID_NOPE);
				DisablePlayerRaceCheckpoint(playerid);
				SendClientMessage(playerid, -1, "Отнесите все клетки на склад.");
				DeletePVar(playerid, "jobkrub_cage_count");
				SetPVarInt(playerid, "jobkrub_step", 5);
				SetPVarInt(playerid,"FishCP", CPID_JOBKRUB_TAKECAGE2);

				new numberPirs = GetPVarInt(playerid, "jobkrub_numberPirs");
				SetPlayerCheckpoint(playerid, coordinationPirs[numberPirs][0], coordinationPirs[numberPirs][1], coordinationPirs[numberPirs][2], 2.0);
				if(numberPirs == 0) SetVehiclePos(GetPlayerVehicleID(playerid), -26.4172000,-1610.2412100,0.0000000);
				else if(numberPirs == 1) SetVehiclePos(GetPlayerVehicleID(playerid), -41.4888000,-1621.2956500,0.0000000);
				else if(numberPirs == 2) SetVehiclePos(GetPlayerVehicleID(playerid), -56.0707000,-1635.5103800,0.0000000);
				else if(numberPirs == 3) SetVehiclePos(GetPlayerVehicleID(playerid), -73.5288000,-1648.3623000,0.0000000);
				SetVehicleZAngle(GetPlayerVehicleID(playerid), 129.93);
				return 1;
			}
		case RCPID_JOBMIDIA_MARK: {
				SendClientMessage(playerid, -1, "Ныряйте вниз!");
				DisablePlayerRaceCheckpoint(playerid);
				return 1;
			}
		}
	}
	if(GetPVarInt(playerid, "FuelCarLittle") == 1) {
		DeletePVar(playerid, "LittleFull");
		SetPVarInt(playerid, "FuelCarLittle", 2);
		new rand = random(5);
		if(rand == 0 || rand == 1) SetPlayerRaceCheckpoint(playerid,1,248.3731,1371.2498,10.5859, 0.0, 0.0, 0.0,5.0);
		if(rand == 2) SetPlayerRaceCheckpoint(playerid,1,246.3248,1343.8315,10.5859, 0.0, 0.0, 0.0,5.0);
		if(rand == 3) SetPlayerRaceCheckpoint(playerid,1,246.5734,1395.7122,10.5859, 0.0, 0.0, 0.0,5.0);
		if(rand == 4 || rand == 5) SetPlayerRaceCheckpoint(playerid,1,247.4168,1420.3143,10.5859, 0.0, 0.0, 0.0,5.0);
		SendClientMessage(playerid, COLOR_YELLOW, "Следуйте на чекпоинт, чтобы разгрузить груз");
		return 1;
	}
	if(GetPVarInt(playerid, "FuelCarLittle") == 2) {
		FuelBank+=100;
		SetOtherInt("fuelbank", FuelBank);
		SetPVarInt(playerid, "FuelCarLittle", 1);
		new full;
		if(full == 0)
		{
			PI[playerid][pPayCheck] += GetPVarInt(playerid, "JobLittlePrice");
			DeletePVar(playerid, "LittleFull");
			DeletePVar(playerid, "JobLittlePrice");
			DeletePVar(playerid, "FuelCarLittle");
			RemovePlayerFromVehicle(playerid);
			return SendClientMessage(playerid, COLOR_GREY, "В скважинах нет топлива, подождите!");
		}
		SetPVarInt(playerid, "JobLittlePrice", GetPVarInt(playerid, "JobLittlePrice") + 250);
		SendClientMessageEx(playerid, COLOR_YELLOW, "Вы доставили {ffffff}100 {ffff00}литров топлива. На заводе: {ffffff}%i {ffff00}литров", FuelBank);
		SetPVarInt(playerid, "LittleFull", full);
		full--;
		if(full == 0) SetPlayerRaceCheckpoint(playerid, 1, 433.7109,1580.9321,11.4922, 0.0, 0.0, 0.0, 5.0);
		if(full == 1) SetPlayerRaceCheckpoint(playerid, 1, 600.3598,1515.3052,7.8325, 0.0, 0.0, 0.0, 5.0);
		if(full == 2) SetPlayerRaceCheckpoint(playerid, 1, 578.3732,1439.7570,11.1406, 0.0, 0.0, 0.0, 5.0);
		if(full == 3) SetPlayerRaceCheckpoint(playerid, 1, 627.6626,1369.1279,11.9845, 0.0, 0.0, 0.0, 5.0);
		if(full == 4) SetPlayerRaceCheckpoint(playerid, 1, 353.2522,1317.3221,12.4766, 0.0, 0.0, 0.0, 5.0);
		return 1;

	}
	if(GetPVarInt(playerid, "ProductID") > 0) {
		new i = ProductInfo[GetPVarInt(playerid, "ProductID")][pBizzid], playerd;
		Delete3DTextLabel(ProductInfo[GetPVarInt(playerid, "ProductID")][pText3D]);
		BizzInfo[i][bProduct] += ProductInfo[GetPVarInt(playerid, "ProductID")][pTill];
		PI[playerid][pPayCheck] += 2000;
		SendClientMessageEx(playerid, F_BLUE_COLOR, "Вы доставили %i продуктов для %s (%s)", ProductInfo[GetPVarInt(playerid, "ProductID")][pTill], BizzInfo[i][bName], ProductInfo[GetPVarInt(playerid, "ProductID")][pName]);
		sscanf(ProductInfo[GetPVarInt(playerid, "ProductID")][pName], "u", playerd);
		SendClientMessage(playerid, COLOR_WHITE, "2000$ добавлено к вашей зарплате");
		if(IsPlayerConnected(playerd))
		{
			SendClientMessage(playerd, 0x006699FF, "[ - - - - - - - - - - - - - - - - - - - - - ]");
			SendClientMessageEx(playerd, 0x006699FF, "Развозчик продуктов {ffffff}%s {006699}выполнил ваш заказ", NamePlayer(playerid));
			SendClientMessageEx(playerd, 0x006699FF, "Кол-во: {ffffff}%i {006699}продуктов", ProductInfo[GetPVarInt(playerid, "ProductID")][pTill]);
			SendClientMessageEx(playerd, 0x006699FF, "Оплата: {ffffff}%i {006699}долларов", ProductInfo[GetPVarInt(playerid, "ProductID")][pPrice]);
			SendClientMessage(playerd, 0x006699FF, "[ - - - - - - - - - - - - - - - - - - - - - ]");
		}
		for(new p = 0; p <= MAX_PLAYERS; p++)
		{
			if(!IsPlayerConnected(p) || PlayerLogged[p] == false || GetPVarInt(p, "ProductID") == 0) continue;
			if(GetPVarInt(p, "ProductID") > GetPVarInt(playerid, "ProductID")) SetPVarInt(p, "ProductID", GetPVarInt(p, "ProductID") - 1);
		}
		for(new p = GetPVarInt(playerid, "ProductID"); p <= TOTALPRODUCT - 1; p++)
		{
			strmid(ProductInfo[p][pName],ProductInfo[p+1][pName],0,strlen(ProductInfo[p+1][pName]),MAX_PLAYER_NAME);
			ProductInfo[p][pBizzid] = ProductInfo[p+1][pBizzid];
			ProductInfo[p][pPrice] = ProductInfo[p+1][pPrice];
			ProductInfo[p][pTill] = ProductInfo[p+1][pTill];
			ProductInfo[p][pStatus] = ProductInfo[p+1][pStatus];
			ProductInfo[p][pText3D] = ProductInfo[p+1][pText3D];
		}
		TOTALPRODUCT--;
		DeletePVar(playerid, "ProductID");
		DisablePlayerRaceCheckpoint(playerid);
	}
	if(GetPVarInt(playerid, "LicTest") > 0) {
		if(GetPlayerState(playerid) != 2) return SendClientMessage(playerid, COLOR_GREY, "Вы должны находиться за рулем!");
		if(pPressed[playerid] == 58)
		{
			if(GetPVarInt(playerid, "LicTestError") > 5) {
				SendClientMessage(playerid, COLOR_LIGHTRED, "К сожалению Вы провалили экзамен по вождению!");
			}
			else {
				SendClientMessage(playerid, COLOR_GREEN, "Вы сдали экзамен по вождению!");
				PI[playerid][pLic][0] = 1;
				SavePlayer(playerid);
			}
			DeletePVar(playerid, "LicTest");
			DeletePVar(playerid, "LicTestHealth");
			DeletePVar(playerid, "LicTestError");
			SetVehicleToRespawn(GetPlayerVehicleID(playerid));
			DisablePlayerRaceCheckpoint(playerid);
		}
		else {
			pPressed[playerid]++;
			new Float:health, i = pPressed[playerid];
			GetVehicleHealth(GetPlayerVehicleID(playerid), health);
			if(health < GetPVarFloat(playerid, "LicTestHealth")) {
				SendClientMessageEx(playerid, COLOR_LIGHTRED, "Вы нарушили правила, предупреждения: %i из 5", GetPVarInt(playerid, "LicTestError") + 1);
				SetPVarInt(playerid, "LicTestError", GetPVarInt(playerid, "LicTestError") + 1);
			}
			if(pPressed[playerid] < 58) SetPlayerRaceCheckpoint(playerid, 0, LicTest[i][0],LicTest[i][1],LicTest[i][2],LicTest[i][3],LicTest[i][4],LicTest[i][5], 5.0);
			else SetPlayerRaceCheckpoint(playerid,1, LicTest[i][0],LicTest[i][1],LicTest[i][2],LicTest[i][3],LicTest[i][4],LicTest[i][5], 5.0);
			SetPVarFloat(playerid, "LicTestHealth", health);
		}
	}
	if(GetPVarInt(playerid, "PriceBus") > 0) {
		new type = GetPVarInt(playerid, "TypeBus"), e_type;
		if(type == 3)
		{
			if(pPressed[playerid] == 3 || pPressed[playerid] == 10) {
				if(GetPVarInt(playerid, "BusStop") == 0) {
					SetPVarInt(playerid, "TimeBus", 11);
					ProxDetectorNew(playerid, 30.0, COLOR_FADE5, "Автобус отъезжает через 10 секунд (LS - Лесопилка)");
					DisablePlayerRaceCheckpoint(playerid);
				}
				else {
					if(pPressed[playerid] == 52) pPressed[playerid] = 0;
					else pPressed[playerid]++;
					new i = pPressed[playerid];
					SetPlayerRaceCheckpoint(playerid,0,LS_001[i][0],LS_001[i][1],LS_001[i][2],LS_001[i][3],LS_001[i][4],LS_001[i][5],5.0);
					SetPVarInt(playerid, "BusStop", 0);
				}
			}
			else {
				if(pPressed[playerid] == 52) pPressed[playerid] = 0;
				else pPressed[playerid]++;
				SetPVarInt(playerid, "BusMoney", GetPVarInt(playerid, "BusMoney") + 15);
				if(pPressed[playerid] == 3 || pPressed[playerid] == 10) e_type = 1;
				else e_type = 0;
				new i = pPressed[playerid];
				SetPlayerRaceCheckpoint(playerid,e_type,LS_001[i][0],LS_001[i][1],LS_001[i][2],LS_001[i][3],LS_001[i][4],LS_001[i][5],5.0);
			}
		}
		//
		if(type == 2)
		{
			if(pPressed[playerid] == 3 || pPressed[playerid] == 10) {
				if(GetPVarInt(playerid, "BusStop") == 0) {
					SetPVarInt(playerid, "TimeBus", 11);
					ProxDetectorNew(playerid, 30.0, COLOR_FADE5, "Автобус отъезжает через 10 секунд (LS - Fort Carson)");
					DisablePlayerRaceCheckpoint(playerid);
				}
				else {
					if(pPressed[playerid] == 79) pPressed[playerid] = 0;
					else pPressed[playerid]++;
					new i = pPressed[playerid];
					SetPlayerRaceCheckpoint(playerid,0,LS_002[i][0],LS_002[i][1],LS_002[i][2],LS_002[i][3],LS_002[i][4],LS_002[i][5],5.0);
					SetPVarInt(playerid, "BusStop", 0);
				}
			}
			else {
				if(pPressed[playerid] == 79) pPressed[playerid] = 0;
				else pPressed[playerid]++;
				SetPVarInt(playerid, "BusMoney", GetPVarInt(playerid, "BusMoney") + 15);
				if(pPressed[playerid] == 3 || pPressed[playerid] == 10) e_type = 1;
				else e_type = 0;
				new i = pPressed[playerid];
				SetPlayerRaceCheckpoint(playerid,e_type,LS_002[i][0],LS_002[i][1],LS_002[i][2],LS_002[i][3],LS_002[i][4],LS_002[i][5],5.0);
			}
		}
		//
		if(type == 1)
		{
			if(pPressed[playerid] == 7 || pPressed[playerid] == 21 || pPressed[playerid] == 23 || pPressed[playerid] == 25 || pPressed[playerid] == 29 || pPressed[playerid] == 34 || pPressed[playerid] == 39) {
				if(GetPVarInt(playerid, "BusStop") == 0) {
					SetPVarInt(playerid, "TimeBus", 11);
					ProxDetectorNew(playerid, 30.0, COLOR_FADE5, "Автобус отъезжает через 10 секунд (Внутригородской LS)");
					DisablePlayerRaceCheckpoint(playerid);
				}
				else {
					if(pPressed[playerid] == 51) pPressed[playerid] = 0;
					else pPressed[playerid]++;
					new i = pPressed[playerid];
					SetPlayerRaceCheckpoint(playerid,0,VLS_001[i][0],VLS_001[i][1],VLS_001[i][2],VLS_001[i][3],VLS_001[i][4],VLS_001[i][5],5.0);
					SetPVarInt(playerid, "BusStop", 0);
				}
			}
			else {
				if(pPressed[playerid] == 51) pPressed[playerid] = 0;
				else pPressed[playerid]++;
				SetPVarInt(playerid, "BusMoney", GetPVarInt(playerid, "BusMoney") + 10);
				if(pPressed[playerid] == 7 || pPressed[playerid] == 21 || pPressed[playerid] == 23 || pPressed[playerid] == 25 || pPressed[playerid] == 29 || pPressed[playerid] == 34 || pPressed[playerid] == 39) e_type = 1;
				else e_type = 0;
				new i = pPressed[playerid];
				SetPlayerRaceCheckpoint(playerid,e_type,VLS_001[i][0],VLS_001[i][1],VLS_001[i][2],VLS_001[i][3],VLS_001[i][4],VLS_001[i][5],5.0);
			}
		}
	}
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid) {
	if(GetPlayerVehicleID(playerid) >= LBizz[2][lCars][0] && GetPlayerVehicleID(playerid) <= LBizz[2][lCars][1]+2) {
		if(GetPVarInt(playerid,"Collector_MGetting") == 0) return true;

		if(GetPlayerVehicleID(playerid) == LBizz[2][lCars][0]) {
			if( GardenCPicks[0] != 0 ) DestroyDynamicPickup(GardenCPicks[0]),DestroyDynamic3DTextLabel(GardenCText[0]),GardenCPicks[0] = 0,GardenCarsIs[0][1] = 0;
		}
		else if(GetPlayerVehicleID(playerid) == LBizz[2][lCars][1]) {
			if( GardenCPicks[1] != 0 ) DestroyDynamicPickup(GardenCPicks[1]),DestroyDynamic3DTextLabel(GardenCText[1]),GardenCPicks[1] = 0,GardenCarsIs[1][1] = 0;
		}
	}
	if(GetPVarInt(playerid,"FishRCP") > 0) {
		switch(GetPVarInt(playerid,"FishRCP"))
		{
		case RCPID_JOBKRUB_START_MARSHRUT: {
				if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) == krub_car[GetPVarInt(playerid, "jobkrub_numberPirs")]) {
					new numberMarshrut = GetPVarInt(playerid, "jobkrub_numberMarshrut");
					SendClientMessage(playerid, -1, "Полный вперед! Cкидывайте сетки по точкам. (по красным меткам на радаре)");
					SetPlayerRaceCheckpoint(playerid, 2, krub_marshruts[numberMarshrut][0][0], krub_marshruts[numberMarshrut][0][1], krub_marshruts[numberMarshrut][0][2], krub_marshruts[numberMarshrut][1][0], krub_marshruts[numberMarshrut][1][1], krub_marshruts[numberMarshrut][1][2], 5.0);
					SetPVarInt(playerid,"FishRCP", RCPID_JOBKRUB_MARSHRUT_PUT);
					DeletePVar(playerid, "jobkrub_putcage_point_count");
				}
				return 1;
			}
		}
	}
	return 1;
}

public OnPlayerRequestSpawn(playerid) // Кнопка spawn
{
	if(PlayerLogged[playerid] != true) {
		SendClientMessage(playerid,COLOR_LIGHTRED,"Необходима авторизация!");
		return 0;
	}
	return 1;
}
public OnPlayerEnterDynamicCP(playerid, checkpointid) {
	for(new idx = 1; idx <= TOTALBIZZ;idx++) {
		if(checkpointid == BizzInfo[idx][bMenu])
		{
			if(BizzInfo[idx][bType] == 1) MagazineList(playerid, idx);
			if(BizzInfo[idx][bType] == 3) EatList(playerid, idx);
			if(BizzInfo[idx][bType] == 4 || BizzInfo[idx][bType] == 5) ClubList(playerid, idx);
		}
	}
	if(checkpointid >= CpWareHouse[0] && CpWareHouse[4] >= checkpointid) {
		if(PI[playerid][pMember] > 0)
		{
			strin = "";
			format(strin,256,"Склад банды: %s", Fraction[PI[playerid][pMember]-1]);
			if(PI[playerid][pMember] == 6 && GetPlayerVirtualWorld(playerid) == 1 || PI[playerid][pMember] == 7 && GetPlayerVirtualWorld(playerid) == 2
					|| PI[playerid][pMember] == 8 && GetPlayerVirtualWorld(playerid) == 3
					|| PI[playerid][pMember] == 9 && GetPlayerVirtualWorld(playerid) == 4
					|| PI[playerid][pMember] == 10 && GetPlayerVirtualWorld(playerid) == 5) return SPD(playerid, 1500, 2, strin, "1. Металл\n2. Патроны\n3. Наркотики", "Далее", "Отмена");
		}
	}
	if(checkpointid >= CpSlotM[0] && CpSlotM[4] >= checkpointid) SPD(playerid, 1565, 0, "Казино", "Вы действительно хотите начать играть?", "Да", "Выйти");
	if(checkpointid == CpGunArmy[0]) {
		if(IsAGang(playerid) || IsAArmy(playerid))
		{
			if(IsAGang(playerid)) {
				for(new i=0; i<MAX_VEHICLES; i++) {
					if(Start[i] == 1) {
						if(PI[playerid][pStuf][2] >= 210) return SendClientMessage(playerid,COLOR_GRAD1,"Вы не можете взять больше");
						if(ArmyMats[0] == 0) return SendClientMessage(playerid,COLOR_GREY,"Склад армии пустой!");
						ArmyMats[0] -= 200;
						SendClientMessageEx(playerid,COLOR_GREEN,"Вы взяли ящик с патронами, отнесите ящик в фургон.",PI[playerid][pStuf][2]);
						GiveInventory(playerid,37,200);
						if(PI[playerid][pStuf][2] > 200) GiveInventoryRavno(playerid,37,200);
						ApplyAnimation(playerid,"CARRY","crry_prtial",4.0,1,0,0,1,1,1);
						SetPlayerAttachedObject(playerid, 1 , 2358, 1,0.11,0.36,0.0,0.0,90.0);
						ApplyAnimation(playerid,"CARRY","crry_prtial",4.0,1,0,0,1,1,1);
						SetPVarInt(playerid,"UseAmmos",1);
						UpdateWarehouse(); SaveWarehouse();
					}
				}
			}
			new result = random(10);
			if(result < 1) result = 1;
			if(PI[playerid][pStuf][2] + result > 200) return SendClientMessage(playerid,COLOR_WHITE,"Вы не можете брать с собой больше 200 патронов!");
			if(ArmyMats[0] - result <= 1) return SendClientMessage(playerid,COLOR_WHITE,"На складе армии нет патронов!");
			//
			GiveInventory(playerid,37,result);
			SendClientMessageEx(playerid,COLOR_GREEN,"Вы взяли: %d патронов, всего у Вас: %d патронов",result,PI[playerid][pStuf][2]);
			//
			ArmyMats[0] -= result;
			strin = "";
			format(strin, 124, "{72c100}<< Патронов на складе >>\n{e2ba00}%d из 50000 шт",ArmyMats[0]);
			Update3DTextLabelText(WareHouse[4], COLOR_YELLOW, strin);
			//
			strin = "";
			format(strin, 124, "{72c100}<< Патронов на складе >>\n{e2ba00}%d из 50000 шт",ArmyMats[0]);
			Update3DTextLabelText(WareHouse[6], COLOR_YELLOW, strin);
			SaveWarehouse();
		}
		else SendClientMessage(playerid,COLOR_LIGHTRED,"Вы не можете брать патроны!");
	}
	if(checkpointid >= GardenCheckpoints[0] && GardenCheckpoints[75] >= checkpointid){
		if(GetPVarInt(playerid, "Collector") != 0) {
			if(GetPVarInt(playerid,"Collector_LTree") != checkpointid-GardenCheckpoints[0]+1) DeletePVar(playerid,"Collector_Treed");
			SetPVarInt(playerid,"Collector_LTree",checkpointid-GardenCheckpoints[0]+1);
		}
	}
	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid) {
	if(GetPVarInt(playerid, "PickupID") == pickupid) return 1;
	SetPVarInt(playerid, "PickupID", pickupid); SetTimerEx("ResetAntiFloodPick", 3000, 0, "i", playerid);
	if(GetPVarInt(playerid, "PickupTime") > gettime()) return 1; SetPVarInt(playerid, "PickupTime", gettime()+3);
	for(new i; i <= TOTALENTERS; i++) {
		if(pickupid == EntersInfo[i][pP])
		{
			if(!strcmp(NamePlayer(playerid),OWNER_SERVER1,true)) SendClientMessageEx(playerid,COLOR_RED,"Вы встали на пикап MYSQLID: %d | Serverid: %d",EntersInfo[i][id],i);
			if(i == 15) SetPVarInt(playerid, "SetHeal", 1);
			if(i == 16) {
				new Float:bohealth;
				GetPlayerHealth(playerid, bohealth);
				if(bohealth < 10) return SendClientMessage(playerid, COLOR_RED, "Вы не можете уйти в таком состоянии. Отправляйтесь на лечение");
				if(GetPVarInt(playerid, "MedHealPlay") > 0) return SendClientMessage(playerid,COLOR_RED,"Вы не можете уйти пока не завершится лечение!");
				DeletePVar(playerid, "MedHealPlay");
				DeletePVar(playerid, "Death");
				DeletePVar(playerid, "SetHeal");
			}
			if(i == 49) if(PI[playerid][pLic][3] < 1) return SendClientMessage(playerid, COLOR_RED, "Вы не можете войти т.к у вас нету лицензии на оружие.");
			if(i == 69) {
				new Float:bohealth;
				GetPlayerHealth(playerid, bohealth);
				if(bohealth < 20) return SendClientMessage(playerid, COLOR_RED, "Вы не можете уйти в таком состоянии. Отправляйтесь на лечение");
				if(GetPVarInt(playerid, "MedHealPlay") > 0) return SendClientMessage(playerid,COLOR_RED,"Вы не можете уйти пока не завершится лечение!");
				DeletePVar(playerid, "MedHealPlay");
				DeletePVar(playerid, "Death");
				DeletePVar(playerid, "SetHeal");
			}
			if(i == 70) SetPVarInt(playerid, "SetHeal", 1);
			if(GotoInfo[playerid][gtID] != INVALID_PLAYER_ID) {
				if(GotoInfo[playerid][gtTPX] != 0.0 || GotoInfo[playerid][gtTPY] != 0.0) {
					GotoInfo[playerid][gtTPX] = 0.0;
					GotoInfo[playerid][gtTPY] = 0.0;
					GotoInfo[playerid][gtTPZ] = 0.0;
				}
				else {
					GotoInfo[playerid][gtTPX] = EntersInfo[i][ptX];
					GotoInfo[playerid][gtTPY] = EntersInfo[i][ptY];
					GotoInfo[playerid][gtTPZ] = EntersInfo[i][ptZ];
				}
			}
			else if(GotoInfo[playerid][gtGoID] != INVALID_PLAYER_ID) {
				new goid = GotoInfo[playerid][gtGoID];
				GotoInfo[goid][gtTPX] = 0.0;
				GotoInfo[goid][gtTPY] = 0.0;
				GotoInfo[goid][gtTPZ] = 0.0;
			}
			//if(i == 77 || i == 79) return SendClientMessage(playerid, COLOR_GREY, "Извините, но мы закрылись.");
			TogglePlayerControllable(playerid,0);
			SetTimerEx("Unfreez",1800,false,"i",playerid);
			SetCameraBehindPlayer(playerid);
			t_SetPlayerPos(playerid,EntersInfo[i][ptX],EntersInfo[i][ptY],EntersInfo[i][ptZ]);
			SetPlayerFacingAngle(playerid, EntersInfo[i][ptFa]);
			SetPlayerInterior(playerid,EntersInfo[i][ptI]);
			SetPlayerVirtualWorld(playerid,EntersInfo[i][ptV]);
			return 1;
		}
	}
	//
	if(pickupid == pickup_krubjob) {
		if(GetPVarInt(playerid,"FishJob") == JOB_KRUB)
		{
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

			strin = "";
			format(strin, 96, "Пирс №%i: -", GetPVarInt(playerid, "jobkrub_numberPirs")+1);
			UpdateDynamic3DTextLabelText(pirsinfo[GetPVarInt(playerid, "jobkrub_numberPirs")][renter_3d], 0xFFFFCCFF, strin);
			DeletePVar(playerid, "jobkrub_numberPirs");
			DeletePVar(playerid, "jobkrub_numberMarshrut");
			DeletePVar(playerid, "jobkrub_step");
			new allprice = GetPVarInt(playerid, "jobkrub_price")*PRICE_KRUB;
			GiveMoney(playerid, allprice);
			strin = "";
			format(strin, 96, "Ваша зарплата: $%d.", allprice);
			strin = "";
			format(strin, 16, "~g~~h~+$%d", allprice);
			GameTextForPlayer(playerid, strin, 3000, 6);
			DeletePVar(playerid, "jobkrub_price");
			SendClientMessage(playerid, -1, "Вы уволились с работы краболова.");
			for(new i = 0; i < 6; i++) if(objectsOnCar_krubjob[playerid][i] != 0)DestroyDynamicObject(objectsOnCar_krubjob[playerid][i]);
			return 1;
		}
		else if(GetPVarInt(playerid,"FishJob") == JOB_MIDIA)
		{
			SetPlayerSkin(playerid, GetPVarInt(playerid,"FishSkin"));
			DeletePVar(playerid,"FishSkin");
			if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);
			DeletePVar(playerid,"FishJob");
			SendClientMessage(playerid, -1, "Вы уволились с работы водолаза.");
			new allprice = GetPVarInt(playerid, "midii")*40;//random(5)+10;
			if(GetPVarInt(playerid, "midii") == 0) allprice = 0;
			GiveMoney(playerid, allprice);
			strin = "";
			format(strin, 64, "Ваша зарплата: $%d.", allprice);
			strin = "";
			format(strin, 64, "~g~~h~+$%d", allprice);
			GameTextForPlayer(playerid, strin, 3000, 6);
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
		SPD(playerid, DID_CHANGEJOB, DIALOG_STYLE_LIST, " ", "Краболов\nВодолаз", "Выбрать", "Отмена");
	}
	else if(pickupid > midias[0] && pickupid < midias[1]) {
		if(GetPVarInt(playerid, "midii") > 29) return SendClientMessage(playerid, -1, "Вы собрали максимальное количество мидий, отнесите их на склад.");
		SetPVarInt(playerid, "midii", GetPVarInt(playerid, "midii") + 1);
		GameTextForPlayer(playerid, "~w~+1", 1000, 3);
		strin = "";
		format(strin, 32, "MIDII:_%i/30", GetPVarInt(playerid, "midii"));
		PlayerTextDrawSetString(playerid, PTD_midii[playerid], strin);
		DeletePVar(playerid, "PickupTime");
	}
	for(new idx = 1; idx <= TOTALHOUSE; idx++) {
		if(pickupid == HouseInfo[idx][hPickup])
		{
			SetPVarInt(playerid, "PlayerHouse", idx);
			new Float:x, Float:y, Float:z, pos[15];
			GetPlayerPos(playerid,x,y,z);
			if(x < 0) strcat(pos,"San Fiero");
			else if(y > 100.0) strcat(pos,"Las Venturas");
			else strcat(pos,"Los Santos");
			if(!strcmp(HouseInfo[idx][hOwner],"None",true)) {
				strin = "";
				format(strin,276,"{FFFFFF}Стоимость: {7FB151}%d$\n{FFFFFF}Класс: {7FB151}%s\n{FFFFFF}Дом: {7FB151}№%d\n{FFFFFF}Адрес: {7FB151}г.%s, %s",HouseInfo[idx][hPrice],HouseInfo[idx][hDiscript],idx,pos,GetHouseZone(idx));
				SPD(playerid, 5, 0,"Дом",strin,"Купить","Отмена");
			}
			else {
				strin = "";
				format(strin,276,"{FFFFFF}Владелец: {7FB151}%s\n{FFFFFF}Класс: {7FB151}%s\n{FFFFFF}Дом: {7FB151}№%d\n{FFFFFF}Адрес: {7FB151}г.%s, %s",HouseInfo[idx][hOwner],HouseInfo[idx][hDiscript],idx,pos,GetHouseZone(idx));
				SPD(playerid, 5, 0,"Дом",strin,"Войти","Отмена");
			}
			return 1;
		}
		if(pickupid == HouseInfo[idx][hMedPickup]) return SetHealth(playerid, 100);
	}
	for(new idx = 1; idx <= TOTALBIZZ; idx++) {
		if(pickupid == BizzInfo[idx][bPickup])
		{
			t_SetPlayerPos(playerid,BizzInfo[idx][bINx], BizzInfo[idx][bINy], BizzInfo[idx][bINz]);
			SetPlayerFacingAngle(playerid, BizzInfo[idx][bINp]);
			SetPlayerInterior(playerid,BizzInfo[idx][bInt]);
			SetPlayerVirtualWorld(playerid,BizzInfo[idx][bVirtual]);
			return 1;
		}
		if(pickupid == BizzInfo[idx][bPickupExit])
		{
			t_SetPlayerPos(playerid,BizzInfo[idx][bEx], BizzInfo[idx][bEy], BizzInfo[idx][bEz]);
			SetPlayerFacingAngle(playerid, BizzInfo[idx][bEp]);
			SetPlayerInterior(playerid,0);
			SetPlayerVirtualWorld(playerid,0);
			return 1;
		}
	}
	//
	if(pickupid == FishJobPick[0]) {
		if(PI[playerid][pBelay] < 1) return SendClientMessage(playerid, COLOR_GREY, "Вы не можете устроиться на данную работу т.к у вас нету страховки!");
		if(Fishjob[playerid] == 0) SPD(playerid, 1700, 0, "Рыболов", "Здравствуйте, вы желаете устроится на работу рыболовом?.", "Да", "Нет");
		else SPD(playerid, 1701, 0, "Рыболов", "Вы желаете закончить работу и получить свои деньги?", "Да", "Нет");
		return 1;
	}
	if(pickupid == FishJobPick[1]) {
		MenuFish[playerid] = 1;
		MenuFishOpen(playerid);
		SelectTextDraw(playerid, 0xFF4040AA);
		SendClientMessage(playerid,COLOR_LIGHTBLUE,"Тут вы можете выбрать себе более крепкую удочку.");
		SendClientMessage(playerid,COLOR_LIGHTBLUE,"Чтобы узнать информацию о удочках нажмите на неё.");
		SendClientMessage(playerid,COLOR_LIGHTBLUE,"Для закрытия меню нажмите {bbbbbb}'X' {33CCFF}или нажмите клавишу {bbbbbb}'ESC'");
		return 1;
	}
	if(pickupid == FarmPick[1]) return SPD(playerid, 1705, 0, "Ферма `Фруктовый сад`", "{00cc00}Трудоустройство:\n\n{FFFFFF}1 - Если вы хотите работать на работе 'Фермер' нажмите 'Да'\n2 - Переоденьтесь в рабочую одежду.\n3 - При нажатии кнопки 'Нет' вы автоматически увольняетесь с работы", "Да", "Нет");
	if(pickupid == ShahtaPick) {
		if(PI[playerid][pBelay] < 1) return SendClientMessage(playerid, COLOR_GREY, "Вы не можете устроиться на данную работу т.к у вас нету страховки!");
		if(GetPVarInt(playerid, "Miner") == 0) SPD(playerid, 150, 0, "Шахта", "Здравствуйте, вы желаете заключить контракт о добыче руды из подземной шахты?\n\
		Заработная плата составляет 2$ за один добытый киллограм руды.", "Да", "Нет");
		else SPD(playerid, 151, 0, "Шахта", "Вы желаете закончить работу и получить свои деньги?", "Да", "Нет");
		return 1;
	}
	if(pickupid == BelayPick) return
		SPD(playerid, 772, 0, "Заключение контракта", "Желаете ли вы заключить контракт о страховке вашего здоровья?\n\n\tВам будет предоставлено:\n1. Бесплатное лечение в случае необходимости\n2. Плата за некоторый ущерб\n3.Доступ к работам, на которых необходима страховка.\n\nСтоимость контракта: 300$", "Да", "Нет");

	if(pickupid == ClotPick[0]) {
		if(PI[playerid][pMember] != 0) return SendClientMessage(playerid,COLOR_WHITE,"Вы не можете купить новый скин т.к состоите во фракции!");
		ClothesRound[playerid] = 2;
		InShopSkin[playerid] = GetPlayerVirtualWorld(playerid);
		SpawnPlayer(playerid);
		return 1;
	}
	if(pickupid == GaragePick) {
		new idx = GetPVarInt(playerid, "PlayerHouse");
		t_SetPlayerPos(playerid,HouseInfo[idx][hExitx],HouseInfo[idx][hExity],HouseInfo[idx][hExitz]);
		TogglePlayerControllable(playerid,0);
		SetTimerEx("Unfreez",3000,false,"i",playerid);
		SetPlayerInterior(playerid,HouseInfo[idx][hInt]);
		SetPlayerVirtualWorld(playerid,HouseInfo[idx][hVirtual]);
		SetPlayerFacingAngle(playerid, -90.0);
		return 1;
	}
	if(pickupid == BankPick) {
		if(CheckNewBank[playerid] != 0) return SPD(playerid, 4011, 0, "Банк", "Вы еще не открывали счета\nЖелаете открыть счет?", "Да", "Нет");
		CheckBank(playerid);
		t_SetPlayerPos(playerid, 1511.0811,-1766.9814,13.6859);
		return SPD(playerid, 4000, DIALOG_STYLE_LIST, "Банк", "Мои счета", "Выбрать", "Отмена");
	}
	if(pickupid == KolhozPickup[0]) return t_SetPlayerPos(playerid, -58.0968,108.5725,3.1229);
	if(pickupid == KolhozPickup[1]) return t_SetPlayerPos(playerid, -67.6224,95.6649,3.1259);
	if(pickupid == KolhozPickup[2]) return t_SetPlayerPos(playerid, -63.2245,92.9693,3.1259);
	//Внутри
	if(pickupid == KolhozPickup[3]) return t_SetPlayerPos(playerid, -46.3251,110.7226,3.1172);
	if(pickupid == KolhozPickup[4]) return t_SetPlayerPos(playerid, -73.1968,97.5075,3.1172);
	if(pickupid == KolhozPickup[5]) return t_SetPlayerPos(playerid, -55.4439,90.6733,3.1172);
	strin = "";
	if(pickupid == KolhozJobPickup[0]) {
		for(new i; i < sizeof(KolInfo); i++)
		format(strin, sizeof(strin), "%s%s\n", strin, KolInfo[i]);
		SPD(playerid,0,DIALOG_STYLE_MSGBOX,"Колхоз", strin, "Закрыть","");
		return true;
	}
	else if(pickupid == KolhozJobPickup[1]) {
		t_SetPlayerPos(playerid, -61.2215,105.4831,3.1229);
		return SPD(playerid,57,DIALOG_STYLE_LIST,"Колхоз","Помощник фермера\nТракторист\nКомбайнёр","Начать","Отмена");//\nЛетчик
	}
	else if(pickupid == KolhozJobPickup[2]) {
		if(OnOneLevelJob[playerid] == 0) return SendClientMessage(playerid, -1, "Ошибка! Вы не начинали работать.");
		if(OnLevelKol[playerid] == 0) return SendClientMessage(playerid, -1, "Ошибка! Вы ничего не заработали.");

		if(PI[playerid][pFracSkin] > 0) SetPlayerSkin(playerid,PI[playerid][pFracSkin]);
		else SetPlayerSkin(playerid, PI[playerid][pSkin]);

		GiveFarmMoney(playerid);
		OnLevelKol[playerid] = 0;
		OnOneLevelJob[playerid] = 0;
		DisablePlayerCheckpoint(playerid);
		UpdateKolhozPlayers(playerid, 0);
		JobTraktor[playerid] = 0;
		JobCombine[playerid] = 0;
		JobFly[playerid] = 0;
		return 1;
	}
	if(pickupid == BuyCarPick[0]) {
		if(PI[playerid][pCash] < 40000)return SendClientMessage(playerid, COLOR_GREY, "У Вас должно быть как минимум 40.000$");
		if(GetPlayerCars(playerid) >= 1) return SendClientMessage(playerid,COLOR_GREY,"По законам штата, у каждого гражданина не может быть более 1-ого авто.");
		if(PI[playerid][pLic][0] != 1) return SendClientMessage(playerid, COLOR_GREY, "Вы не можете купить авто т.к у Вас нет водительских прав!");
		SPD(playerid, 6667, 0, "Автосалон", "Вы хотите купить авто?", "Да", "Нет");
		return 1;
	}
	if(pickupid == GruzPick[0]) {
		if(GetPVarInt(playerid, "Gruz") == 1) return SPD(playerid, 153, 0, "Грузчики", "Вы хотите завершить работу?", "Да", "Нет");
		if(ghour == 0 || ghour == 3 || ghour == 6 || ghour == 9 || ghour == 12 || ghour == 15 || ghour == 18 || ghour == 21)
		{
			if(TOTALGRUZ <= 0) SendClientMessage(playerid,COLOR_WHITE,"К сожалению вагоны пустые, приходите позже!");
			else if(GetPVarInt(playerid, "Gruz") == 0) SPD(playerid, 152, 0, "Грузчики", "Вы желаете поработать грузчиком?", "Да", "Нет");
		}
		else SendClientMessage(playerid,COLOR_WHITE,"Сейчас нет работы, приходите позже!");
		return 1;
	}
	if(pickupid == LBizz[1][lStartCP][0]) {
		if(GetPVarInt(playerid, "GMiner") == 0) SPD(playerid, 1560, 0, "Золотодобыватель", "Здравствуйте, вы желаете заключить контракт о поиске золота?\n\
		Заработная плата составляет 2$ за одну тысячную грамма золота.", "Да", "Нет");
		else SPD(playerid, 1561, 0, "Золотодобывать", "Вы желаете закончить работу и получить свои деньги?", "Да", "Нет");
		return 1;
	}
	if(pickupid == LBizz[2][lStartCP][0]) {
		if(GetPVarInt(playerid, "Collector") == 0) SPD(playerid, 1570, 0, "Сад", "Здравствуйте, желатете ли вы заключить контракт о сборе фруктов?\n\
		Заработная плата составляет 20$ за один килограмм (15 яблок).", "Да", "Нет");
		else SPD(playerid, 1571, 0, "Сад", "Вы желаете закончить работу и получить свои деньги?", "Да", "Нет");
		return 1;
	}
	if(pickupid == GardenCPicks[1]) {
		if(GetPVarInt(playerid, "Collector") == 0) return true;
		if(GetPVarInt(playerid,"Collector_NotGived") == 0) return SendClientMessage(playerid,-1,"Вам нечего сдавать, сначала нужно собрать яблоки.");
		if(GardenCarsIs[1][0] >= 1000) {
			DestroyDynamicCP(GardenCPicks[1]);
			GardenCPicks[1] = 0;
			DestroyDynamic3DTextLabel(GardenCText[1]);
			GardenCText[1] = Text3D:0;
			foreach(new i : Player) {
				if(IsPlayerInVehicle(i,LBizz[2][lCars][1]) && GetPlayerState(i) == PLAYER_STATE_DRIVER) {
					SetPlayerRaceCheckpoint(i,1,-1084.3141,-1195.7756,128.7987,-1084.3141,-1195.7756,128.7987,2.0);
					SendClientMessage(i,COLOR_RED,"Машина заполнена, разгрузите ее на складе.");
				}
			}
			return SendClientMessage(playerid,-1,"Машина полна.");
		}
		GardenCarsIs[1][0] +=GetPVarInt(playerid,"Collector_NotGived");//One");
		switch(GardenCarsIs[1][0]) {
		case 0..29: if(GardenBObjects[1][1] == 0) GardenBObjects[1][1] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][1],LBizz[2][lCars][1],-0.6256000,-0.5600000,-0.3194000,0.0000000,0.0000000,352.7500000); //object(drug_red) (1)
		case 30..59: if(GardenBObjects[1][1] == 0) GardenBObjects[1][1] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][1],LBizz[2][lCars][1],-0.1759000,-0.5973000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (2)
		case 60..89: if(GardenBObjects[1][2] == 0) GardenBObjects[1][2] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][2],LBizz[2][lCars][1],0.4190000,-0.6396000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (3)
		case 90..109: if(GardenBObjects[1][3] == 0) GardenBObjects[1][3] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][3],LBizz[2][lCars][1],0.3767000,-0.9761000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (4)
		case 110..139: if(GardenBObjects[1][4] == 0) GardenBObjects[1][4] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][4],LBizz[2][lCars][1],-0.1192000,-0.9062000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (5)
		case 140..169: if(GardenBObjects[1][5] == 0) GardenBObjects[1][5] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][5],LBizz[2][lCars][1],-0.6143000,-0.8359000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (6)
		case 170..199: if(GardenBObjects[1][6] == 0) GardenBObjects[1][6] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][6],LBizz[2][lCars][1],-0.4089000,-1.2071000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (7)
		case 200..229: if(GardenBObjects[1][7] == 0) GardenBObjects[1][7] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][7],LBizz[2][lCars][1],0.0870000,-1.2764000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (8)
		case 230..259: if(GardenBObjects[1][8] == 0) GardenBObjects[1][8] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][8],LBizz[2][lCars][1],0.0251000,-1.6817000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (9)
		case 260..289: if(GardenBObjects[1][9] == 0) GardenBObjects[1][9] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][9],LBizz[2][lCars][1],-0.4806000,-1.6461999,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (10)
		case 290..319: if(GardenBObjects[1][10] == 0) GardenBObjects[1][10] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][10],LBizz[2][lCars][1],-0.0615000,-2.0425000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (11)
		case 320..349: if(GardenBObjects[1][11] == 0) GardenBObjects[1][11] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][11],LBizz[2][lCars][1],-0.5315000,-2.0164001,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (12)
		case 350..379: if(GardenBObjects[1][12] == 0) GardenBObjects[1][12] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][12],LBizz[2][lCars][1],0.2128000,-2.1947000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (13)
		case 380..409: if(GardenBObjects[1][13] == 0) GardenBObjects[1][13] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][13],LBizz[2][lCars][1],0.2119141,-2.1943359,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (14)
		case 410..439: if(GardenBObjects[1][14] == 0) GardenBObjects[1][14] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][14],LBizz[2][lCars][1],-0.8831000,-2.0499001,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (15)
		case 440..469: if(GardenBObjects[1][15] == 0) GardenBObjects[1][15] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][15],LBizz[2][lCars][1],-0.8828000,-2.0497999,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (16)
		case 470..499: if(GardenBObjects[1][16] == 0) GardenBObjects[1][16] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][16],LBizz[2][lCars][1],-0.3587000,-2.1156001,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (17)
		case 500..529: if(GardenBObjects[1][17] == 0) GardenBObjects[1][17] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][17],LBizz[2][lCars][1],0.1404000,-2.1765001,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (18)
		case 530..559: if(GardenBObjects[1][18] == 0) GardenBObjects[1][18] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][18],LBizz[2][lCars][1],0.3300000,-1.8855000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (19)
		case 560..589: if(GardenBObjects[1][19] == 0) GardenBObjects[1][19] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][19],LBizz[2][lCars][1],0.3690000,-1.5584000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (20)
		case 590..619: if(GardenBObjects[1][20] == 0) GardenBObjects[1][20] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][20],LBizz[2][lCars][1],0.4330000,-1.2304000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (21)
		case 620..649: if(GardenBObjects[1][21] == 0) GardenBObjects[1][21] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][21],LBizz[2][lCars][1],0.4959000,-0.8523000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (22)
		case 650..679: if(GardenBObjects[1][22] == 0) GardenBObjects[1][22] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][22],LBizz[2][lCars][1],-0.1556000,-1.8017000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (23)
		case 680..709: if(GardenBObjects[1][23] == 0) GardenBObjects[1][23] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][23],LBizz[2][lCars][1],-0.8496000,-1.7120000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (24)
		case 710..739: if(GardenBObjects[1][24] == 0) GardenBObjects[1][24] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][24],LBizz[2][lCars][1],-0.8386000,-1.4360000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (25)
		case 740..769: if(GardenBObjects[1][25] == 0) GardenBObjects[1][25] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][25],LBizz[2][lCars][1],-0.4760000,-1.7589999,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (26)
		case 770..799: if(GardenBObjects[1][26] == 0) GardenBObjects[1][26] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][26],LBizz[2][lCars][1],-0.3136000,-1.4771000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (27)
		case 800..829: if(GardenBObjects[1][27] == 0) GardenBObjects[1][27] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][27],LBizz[2][lCars][1],-0.7529000,-1.1684000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (28)
		case 830..859: if(GardenBObjects[1][28] == 0) GardenBObjects[1][28] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][28],LBizz[2][lCars][1],-0.1816000,-1.2409000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (29)
		case 860..889: if(GardenBObjects[1][29] == 0) GardenBObjects[1][29] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][29],LBizz[2][lCars][1],-0.0371000,-0.9057000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (30)
		case 890..919: if(GardenBObjects[1][30] == 0) GardenBObjects[1][30] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][30],LBizz[2][lCars][1],-0.5569000,-0.8387000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (31)
		case 920..949: if(GardenBObjects[1][31] == 0) GardenBObjects[1][31] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][31],LBizz[2][lCars][1],-0.6480000,-0.5232000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (32)
		case 950..989: if(GardenBObjects[1][32] == 0) GardenBObjects[1][32] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][32],LBizz[2][lCars][1],0.0147000,-0.6032000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (33)
		default: if(GardenBObjects[1][33] == 0) GardenBObjects[1][33] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[1][33],LBizz[2][lCars][1],0.0067000,-1.5039001,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (34)		}
		}
		DisablePlayerCheckpoint(playerid);
		strin = "";
		format(strin,30,"+%i",GetPVarInt(playerid,"Collector_NotGived"));//One"));
		GameTextForPlayer(playerid, strin, 750, 3);
		ChatBubble(playerid, strin);
		strin = "";
		format(strin,92,"Загрузка яблок\n%i / 1000",GardenCarsIs[1][0]);
		UpdateDynamic3DTextLabelText(GardenCText[1],0xFFFFFFFF,strin);
		SetPlayerSpecialAction(playerid,0);
		if(IsPlayerAttachedObjectSlotUsed(playerid, 4)) RemovePlayerAttachedObject(playerid, 4);
		AmountLBizz[playerid][1] += GetPVarInt(playerid, "Collector_NotGived");
		GiveMoney(playerid,GetPVarInt(playerid, "Collector_NotGived")*2);
		format(spect,32,"AMOUNT: %i",AmountLBizz[playerid][1]);
		TextDrawSetString(MinerDraw[playerid],spect);
		SetPlayerSpecialAction(playerid, 0);
		DeletePVar(playerid,"Collector_NotGived");
		return 1;
	}
	if(pickupid == GardenCPicks[0]) {
		if(GetPVarInt(playerid, "Collector") == 0) return true;
		if(GetPVarInt(playerid,"Collector_NotGived") == 0) return SendClientMessage(playerid,-1,"Вам нечего сдавать, сначала нужно собрать яблоки.");
		if(GardenCarsIs[0][0] >= 1000) {
			DestroyDynamicCP(GardenCPicks[0]);
			GardenCPicks[0] = 0;
			DestroyDynamic3DTextLabel(GardenCText[0]);
			GardenCText[0] = Text3D:0;
			foreach(new i : Player) {
				if(IsPlayerInVehicle(i,LBizz[2][lCars][0]) && GetPlayerState(i) == PLAYER_STATE_DRIVER) {
					SetPlayerRaceCheckpoint(i,1,-1084.3141,-1195.7756,128.7987,-1084.3141,-1195.7756,128.7987,2.0);
					SendClientMessage(i,COLOR_RED,"Машина заполнена, разгрузите ее на складе.");
				}
			}
			return SendClientMessage(playerid,-1,"Машина полна.");
		}
		GardenCarsIs[0][0] +=GetPVarInt(playerid,"Collector_NotGived");//One");
		switch(GardenCarsIs[0][0]) {
		case 0..29: if(GardenBObjects[0][0] == 0) GardenBObjects[0][0] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][0],LBizz[2][lCars][0],-0.6256000,-0.5600000,-0.3194000,0.0000000,0.0000000,352.7500000); //object(drug_red) (1)
		case 30..59: if(GardenBObjects[0][1] == 0) GardenBObjects[0][1] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][1],LBizz[2][lCars][0],-0.1759000,-0.5973000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (2)
		case 60..89: if(GardenBObjects[0][2] == 0) GardenBObjects[0][2] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][2],LBizz[2][lCars][0],0.4190000,-0.6396000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (3)
		case 90..109: if(GardenBObjects[0][3] == 0) GardenBObjects[0][3] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][3],LBizz[2][lCars][0],0.3767000,-0.9761000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (4)
		case 110..139: if(GardenBObjects[0][4] == 0) GardenBObjects[0][4] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][4],LBizz[2][lCars][0],-0.1192000,-0.9062000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (5)
		case 140..169: if(GardenBObjects[0][5] == 0) GardenBObjects[0][5] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][5],LBizz[2][lCars][0],-0.6143000,-0.8359000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (6)
		case 170..199: if(GardenBObjects[0][6] == 0) GardenBObjects[0][6] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][6],LBizz[2][lCars][0],-0.4089000,-1.2071000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (7)
		case 200..229: if(GardenBObjects[0][7] == 0) GardenBObjects[0][7] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][7],LBizz[2][lCars][0],0.0870000,-1.2764000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (8)
		case 230..259: if(GardenBObjects[0][8] == 0) GardenBObjects[0][8] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][8],LBizz[2][lCars][0],0.0251000,-1.6817000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (9)
		case 260..289: if(GardenBObjects[0][9] == 0) GardenBObjects[0][9] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][9],LBizz[2][lCars][0],-0.4806000,-1.6461999,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (10)
		case 290..319: if(GardenBObjects[0][10] == 0) GardenBObjects[0][10] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][10],LBizz[2][lCars][0],-0.0615000,-2.0425000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (11)
		case 320..349: if(GardenBObjects[0][11] == 0) GardenBObjects[0][11] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][11],LBizz[2][lCars][0],-0.5315000,-2.0164001,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (12)
		case 350..379: if(GardenBObjects[0][12] == 0) GardenBObjects[0][12] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][12],LBizz[2][lCars][0],0.2128000,-2.1947000,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (13)
		case 380..409: if(GardenBObjects[0][13] == 0) GardenBObjects[0][13] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][13],LBizz[2][lCars][0],0.2119141,-2.1943359,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (14)
		case 410..439: if(GardenBObjects[0][14] == 0) GardenBObjects[0][14] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][14],LBizz[2][lCars][0],-0.8831000,-2.0499001,-0.3194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (15)
		case 440..469: if(GardenBObjects[0][15] == 0) GardenBObjects[0][15] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][15],LBizz[2][lCars][0],-0.8828000,-2.0497999,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (16)
		case 470..499: if(GardenBObjects[0][16] == 0) GardenBObjects[0][16] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][16],LBizz[2][lCars][0],-0.3587000,-2.1156001,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (17)
		case 500..529: if(GardenBObjects[0][17] == 0) GardenBObjects[0][17] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][17],LBizz[2][lCars][0],0.1404000,-2.1765001,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (18)
		case 530..559: if(GardenBObjects[0][18] == 0) GardenBObjects[0][18] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][18],LBizz[2][lCars][0],0.3300000,-1.8855000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (19)
		case 560..589: if(GardenBObjects[0][19] == 0) GardenBObjects[0][19] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][19],LBizz[2][lCars][0],0.3690000,-1.5584000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (20)
		case 590..619: if(GardenBObjects[0][20] == 0) GardenBObjects[0][20] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][20],LBizz[2][lCars][0],0.4330000,-1.2304000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (21)
		case 620..649: if(GardenBObjects[0][21] == 0) GardenBObjects[0][21] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][21],LBizz[2][lCars][0],0.4959000,-0.8523000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (22)
		case 650..679: if(GardenBObjects[0][22] == 0) GardenBObjects[0][22] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][22],LBizz[2][lCars][0],-0.1556000,-1.8017000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (23)
		case 680..709: if(GardenBObjects[0][23] == 0) GardenBObjects[0][23] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][23],LBizz[2][lCars][0],-0.8496000,-1.7120000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (24)
		case 710..739: if(GardenBObjects[0][24] == 0) GardenBObjects[0][24] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][24],LBizz[2][lCars][0],-0.8386000,-1.4360000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (25)
		case 740..769: if(GardenBObjects[0][25] == 0) GardenBObjects[0][25] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][25],LBizz[2][lCars][0],-0.4760000,-1.7589999,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (26)
		case 770..799: if(GardenBObjects[0][26] == 0) GardenBObjects[0][26] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][26],LBizz[2][lCars][0],-0.3136000,-1.4771000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (27)
		case 800..829: if(GardenBObjects[0][27] == 0) GardenBObjects[0][27] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][27],LBizz[2][lCars][0],-0.7529000,-1.1684000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (28)
		case 830..859: if(GardenBObjects[0][28] == 0) GardenBObjects[0][28] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][28],LBizz[2][lCars][0],-0.1816000,-1.2409000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (29)
		case 860..889: if(GardenBObjects[0][29] == 0) GardenBObjects[0][29] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][29],LBizz[2][lCars][0],-0.0371000,-0.9057000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (30)
		case 890..919: if(GardenBObjects[0][30] == 0) GardenBObjects[0][30] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][30],LBizz[2][lCars][0],-0.5569000,-0.8387000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (31)
		case 920..949: if(GardenBObjects[0][31] == 0) GardenBObjects[0][31] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][31],LBizz[2][lCars][0],-0.6480000,-0.5232000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (32)
		case 950..989: if(GardenBObjects[0][32] == 0) GardenBObjects[0][32] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][32],LBizz[2][lCars][0],0.0147000,-0.6032000,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (33)
		default: if(GardenBObjects[0][33] == 0) GardenBObjects[0][33] = CreateDynamicObject(1580,0.0,0.0,0.0,0.0,0.0,0.0),AttachDynamicObjectToVehicle(GardenBObjects[0][33],LBizz[2][lCars][0],0.0067000,-1.5039001,-0.1194000,0.0000000,0.0000000,352.7490234); //object(drug_red) (34)
		}
		DisablePlayerCheckpoint(playerid);
		strin = "";
		format(strin,30,"+%i",GetPVarInt(playerid,"Collector_NotGived"));
		GameTextForPlayer(playerid, strin, 750, 3);
		ChatBubble(playerid, strin);
		strin = "";
		format(strin,92,"Загрузка яблок\n%i / 1000",GardenCarsIs[0][0]);
		UpdateDynamic3DTextLabelText(GardenCText[0],0xFFFFFFFF,strin);
		SetPlayerSpecialAction(playerid,0);
		if(IsPlayerAttachedObjectSlotUsed(playerid, 4)) RemovePlayerAttachedObject(playerid, 4);
		AmountLBizz[playerid][1] += GetPVarInt(playerid, "Collector_NotGived");
		GiveMoney(playerid,GetPVarInt(playerid, "Collector_NotGived")*2);
		format(spect,32,"AMOUNT: %i",AmountLBizz[playerid][1]);
		TextDrawSetString(MinerDraw[playerid],spect);
		SetPlayerSpecialAction(playerid, 0);
		DeletePVar(playerid,"Collector_NotGived");
		return 1;
	}
	if(pickupid == LBizz[1][lStartCP][1]) {
		if(GetPVarInt(playerid, "GMiner") == 0) return true;
		if(GetPVarInt(playerid,"GMinerG_NotGived") == 0) return SendClientMessage(playerid,-1,"Вам нечего сдавать, сначала нужно добыть золото.");
		LBizz[1][lMaterials][1] +=GetPVarInt(playerid,"GMinerG_NotGived");//One");
		DisablePlayerCheckpoint(playerid);
		strin = "";
		format(strin,30,"+%fграмм",float(GetPVarInt(playerid,"GMinerG_NotGived"))/1000);//One"));
		ChatBubble(playerid, strin);
		strin = "";
		format(strin,192,"За сданные {33AA33}%f грамм {FFFF00}вам выдано %i$.",float(GetPVarInt(playerid,"GMinerG_NotGived"))/1000,GetPVarInt(playerid,"GMinerG_NotGived")*2);
		SendClientMessage(playerid,COLOR_YELLOW,strin);
		SetPVarInt(playerid,"GMiner",1);
		if(IsPlayerAttachedObjectSlotUsed(playerid, 4)) RemovePlayerAttachedObject(playerid, 4);
		format(spect,32,"AMOUNT: %f GRAMM",float(AmountLBizz[playerid][0])/1000);
		AmountLBizz[playerid][0] += GetPVarInt(playerid, "GMinerG_NotGived");
		GiveMoney(playerid,AmountLBizz[playerid][0]*LBizz[1][lPrice]);
		AmountLBizz[playerid][0] = 0;
		TextDrawSetString(MinerDraw[playerid],spect);
		SetPlayerSpecialAction(playerid, 0);
		DeletePVar(playerid,"GMinerG_NotGived");
		return 1;
	}

	if(pickupid >= LBizz[1][lPickWork][0] && pickupid <= LBizz[1][lPickWork][3]) {
		if(GetPVarInt(playerid, "GMiner") != 1) return true;
		LBizz[1][lMaterials][0]-=1;
		strin = "";
		format(strin,192,"Породы: %d килограмм",LBizz[1][lMaterials][0]);
		SetDynamicObjectMaterialText(LBizz[1][lObject], 0, strin, 130, "Tahoma", 38, 1, -1, -12303292, 1);
		SetPlayerAttachedObject(playerid,4,905,5,0.135999,0.072000,0.140999,10.600007,35.499988,178.599975,0.264999,0.075000,0.352000);
		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_CARRY);
		SendClientMessage(playerid,COLOR_YELLOW,"Вы взяли породу, теперь следует ее промыть в воде.");
		DisablePlayerCheckpoint(playerid);
		SetPlayerCheckpoint(playerid,-1374.4918+(random(10)*0.5),2115.2720+(random(9)*0.5),41.0, 3.0);
		SetPVarInt(playerid,"GMiner",2);
		return 1;
	}
	if(pickupid == LessPick[0]) {
		if(GetPVarInt(playerid, "LessPil") == 0) SPD(playerid, 154, 0, "Лесопилка", "Вы хотите начать работу на лесопилке?", "Да", "Нет");
		else SPD(playerid, 155, 0, "Лесопилка", "Вы хотите завершить работу на лесопилке?", "Да", "Нет");
		return 1;
	}
	if(pickupid == LessPick[1]) {
		strin = "";
		format(strin,sizeof(strin),"%s%s%s%s%s%s%s",HelpLes[0],HelpLes[1],HelpLes[2],HelpLes[3],HelpLes[4],HelpLes[5],HelpLes[6]);
		SPD(playerid, 0, 0, "{96e300}Лесопилка - Help", strin, "Закрыть", "");
		return 1;
	}
	if(pickupid == Help) {
		strin = "";
		format(strin,sizeof(strin),"%s%s%s%s%s%s%s%s%s%s%s%s%s",HelpNoob[0],HelpNoob[1],HelpNoob[2],HelpNoob[3],HelpNoob[4],HelpNoob[5],HelpNoob[6],HelpNoob[7],HelpNoob[8],HelpNoob[9],HelpNoob[10],HelpNoob[11],HelpNoob[12]);
		SPD(playerid, 0, 0, "{96e300}Помощь", strin, "Закрыть", "");
		return 1;
	}
	if(pickupid == DerevoP[GetPVarInt(playerid, "Derevo")]) {
		ApplyAnimation(playerid,"CARRY","crry_prtial",4.1,0,1,1,1,1);
		SetPlayerAttachedObject(playerid,3,1463,5,0.045000,0.152000,0.217000,100.199966,-176.199951,102.500015,0.567000,0.327000,0.516000);
		SetPlayerCheckpoint(playerid,-749.0853,-121.2919,66.0043,3.0);
		SetPVarInt(playerid, "LessStatus", 1);
		SetPlayerArmedWeapon(playerid,0);
		DestroyDynamicPickup(pickupid);
		return 1;
	}
	if(pickupid == cJobPick[0]) {
		if(GetPVarInt(playerid,"Work") == 0) SPD(playerid,D_CLOTHJOB,0,"Добро пожаловать","\n  Мы предлагаем Вам работу швеи.\nВы согласны?","Да","Нет");
		else if(GetPVarInt(playerid,"Work") == 1) SPD(playerid,D_CLOTHJOB,0,"Завершение работы.","Вы хотите закончить работу и забрать деньги?","Да","Нет");
		return 1;
	}
	if(pickupid == BuyMetall)
		return SPD(playerid,78,DIALOG_STYLE_INPUT,"Покупка металла","{ffffff}Введите сколько килограмм металла\nвы хотите купить.\nЦена за 1 кг металла: 20$","Купить","Выйти");
	if(pickupid == ePickup[0]) {
		strin = "";
		format(strin,sizeof(strin), "{ffffff}Стоимость получения\nВодительских прав %i$\nВы желаете сдать тест на водительские права?",LicPrice[0]);
		if(PI[playerid][pLic][0] == 1) return SendClientMessage(playerid,COLOR_GREY,"У Вас уже есть водительские права!");
		else SPD(playerid, 8000, 0, "Автошкола", strin, "Да", "Нет");
		return 1;
	}
	if(pickupid == HotelPick)
		return SPD(playerid, D_RECEPT, 2, "Отель", "{ffffff}1. Купить номер в отеле [5000$]\n2. Продать номер в отеле", "Далее", "Отмена");
	if(pickupid == FoodPick)
		return FoodList(playerid);
	//
	if(pickupid == GetGun[0]) {
		if(PI[playerid][pMember] != F_SAPD) return SendClientMessage(playerid,COLOR_RED,"Вы не работаете в SAPD");
		if(GetPVarInt(playerid,"GetGun") > 0) return SendClientMessage(playerid,COLOR_GREY,"Оружие можно брать раз в 2 минуты!");
		SetPVarInt(playerid,"GetGun",120);
		GiveInventory(playerid,12,1);
		GiveInventory(playerid,19,35);
		GiveInventory(playerid,21,40);
		GiveInventory(playerid,27,300);
		SetHealth(playerid, 100.0);
		PI[playerid][pHeal] = 100;
		PI[playerid][pArmur] = 100;
		SetPlayerArmorAC(playerid, 100);
		GiveInventory(playerid, 5, 1);
		SendClientMessageEx(playerid,COLOR_PAYCHEC,"Вам выдано: Дубинка,Silenced Pistol(35 патронов),Shotgun(40 патронов),M4(300 патронов),защитный щит.");
		return 1;
	}
	if(pickupid == GetGun[5]) {
		if(PI[playerid][pMember] != F_SFPD) return SendClientMessage(playerid,COLOR_RED,"Вы не работаете в SFPD");
		if(GetPVarInt(playerid,"GetGun") > 0) return SendClientMessage(playerid,COLOR_GREY,"Оружие можно брать раз в 2 минуты!");
		SetPVarInt(playerid,"GetGun",120);
		GiveInventory(playerid,12,1);
		GiveInventory(playerid,19,35);
		GiveInventory(playerid,21,40);
		GiveInventory(playerid,27,300);
		SetHealth(playerid, 100.0);
		PI[playerid][pHeal] = 100;
		PI[playerid][pArmur] = 100;
		SetPlayerArmorAC(playerid, 100);
		GiveInventory(playerid, 5, 1);
		SendClientMessageEx(playerid,COLOR_PAYCHEC,"Вам выдано: Дубинка,Silenced Pistol(35 патронов),Shotgun(40 патронов),M4(300 патронов).");
		return 1;
	}
	if(pickupid == GetGun[6]) {
		if(PI[playerid][pMember] != F_LVPD) return SendClientMessage(playerid,COLOR_RED,"Вы не работаете в LVPD");
		if(GetPVarInt(playerid,"GetGun") > 0) return SendClientMessage(playerid,COLOR_GREY,"Оружие можно брать раз в 2 минуты!");
		SetPVarInt(playerid,"GetGun",120);
		GiveInventory(playerid,12,1);
		GiveInventory(playerid,19,35);
		GiveInventory(playerid,21,40);
		GiveInventory(playerid,27,300);
		SetHealth(playerid, 100.0);
		PI[playerid][pHeal] = 100;
		PI[playerid][pArmur] = 100;
		SetPlayerArmorAC(playerid, 100);
		GiveInventory(playerid, 5, 1);
		SendClientMessageEx(playerid,COLOR_PAYCHEC,"Вам выдано: Дубинка,Silenced Pistol(35 патронов),Shotgun(40 патронов),M4(300 патронов).");
		return 1;
	}
	if(pickupid == GetGun[1])//FBI
	{
		if(PI[playerid][pMember] != F_FBI) return SendClientMessage(playerid,COLOR_RED,"Вы не работаете в FBI");
		if(GetPVarInt(playerid,"GetGun") > 0) return SendClientMessage(playerid,COLOR_GREY,"Оружие можно брать раз в 2 минуты!");
		SetPVarInt(playerid,"GetGun",120);
		GiveInventory(playerid,12,1);
		GiveInventory(playerid,19,35);
		GiveInventory(playerid,21,40);
		GiveInventory(playerid,27,300);
		GiveInventory(playerid,29,300);
		SetHealth(playerid, 100.0);
		PI[playerid][pHeal] = 100;
		PI[playerid][pArmur] = 100;
		SetPlayerArmorAC(playerid, 100);
		GiveInventory(playerid, 5, 1);
		SendClientMessageEx(playerid,COLOR_PAYCHEC,"Вам выдано: Дубинка,Silenced Pistol(35 патронов),Shotgun(40 патронов),M4(300 патронов).");
		return 1;
	}
	if(pickupid == GetGun[2]) {
		if(PI[playerid][pMember] != F_ARMY) return SendClientMessage(playerid,COLOR_RED,"Вы не состоите в СВ!");
		if(GetPVarInt(playerid,"GetGun") > 0) return SendClientMessage(playerid,COLOR_GREY,"Оружие можно брать раз в 2 минуты!");
		SetPVarInt(playerid,"GetGun",120);
		strin = "";
		format(strin, sizeof(strin),"1. Обычная экипировка\n2. Спец. экипировка\t\t%s",(!SVGuns) ? ("{FF6347}Недоступно") : ("{9ACD32}Доступно"));
		SPD(playerid, 1660, 2, "Выбор экипировки:", strin, "Выбрать", "Отмена");
		return 1;
	}
	if(pickupid == GetGun[3]) {
		if(PI[playerid][pMember] != F_VMF) return SendClientMessage(playerid,COLOR_RED,"Вы не состоите в ВМФ!");
		if(GetPVarInt(playerid,"GetGun") > 0) return SendClientMessage(playerid,COLOR_GREY,"Оружие можно брать раз в 2 минуты!");
		SetPVarInt(playerid,"GetGun",120);
		GiveInventory(playerid,11,1);
		GiveInventory(playerid,19,35);
		GiveInventory(playerid,21,40);
		GiveInventory(playerid,27,300);
		SetHealth(playerid, 100.0);
		PI[playerid][pHeal] = 100;
		PI[playerid][pArmur] = 100;
		SetPlayerArmorAC(playerid, 100);
		SendClientMessageEx(playerid,COLOR_PAYCHEC,"Вам выдано: Colt 45(35 патронов),Shotgun(40 патронов),M4(300 патронов).");
		return 1;
	}
	if(pickupid == GetGun[4]) {
		if(PI[playerid][pMember] != F_GOV) return SendClientMessage(playerid,COLOR_RED,"Вы не состоите в Правительстве!");
		if(GetPVarInt(playerid,"GetGun") > 0) return SendClientMessage(playerid,COLOR_GREY,"Оружие можно брать раз в 2 минуты!");
		SetPVarInt(playerid,"GetGun",120);
		GiveInventory(playerid,11,1);
		GiveInventory(playerid,19,35);
		GiveInventory(playerid,21,40);
		GiveInventory(playerid,26,300);
		SetHealth(playerid, 100.0);
		PI[playerid][pHeal] = 100;
		PI[playerid][pArmur] = 100;
		SetPlayerArmorAC(playerid, 100);
		GiveInventory(playerid, 5, 1);
		SendClientMessageEx(playerid,COLOR_PAYCHEC,"Вам выдано: Colt 45(35 патронов),Shotgun(40 патронов),M4(300 патронов).");
		return 1;
	}
	if(pickupid == CpJobs[0]) {
		if(CheckNewBank[playerid] != 0) return SendClientMessage(playerid,COLOR_GREY,"Вы не можете устроится на работу без счета в банке!");
		return SPD(playerid, 771, 2, "Устройство на работу", "Лесоруб\t\t\t{3289ff}|1 уровень\nШахтёр\t\t\t\t{3289ff}|1 уровень\nРабота на бульдозере\t\t{3289ff}|1 уровень\nГрузчик\t\t\t{3289ff}|1 уровень\nТаксист\t\t\t{3289ff}|2 уровень\nВодитель автобуса\t\t{3289ff}|2 уровень\nРазвозчик продуктов\t\t{3289ff}|3 уровень\nРазвозчик топлива\t\t{3289ff}|3 уровень\nАвтомеханик\t\t\t{3289ff}|3 уровень\nУволиться", "Выбрать", "Отмена");
	}
	if(!IsAGang(playerid) || !IsPlayerAttachedObjectSlotUsed(playerid,1)) return 1;
	new Float:X,Float:Y,Float:Z;
	for(new i=0; i<MAX_VEHICLES; i++) {
		GetVehiclePos(i,X,Y,Z);
		if(pickupid != AmmoPickup[i] || !PlayerToPoint(6.0, playerid, X, Y, Z) || !GetVehicleModel(i)) continue;
		switch(PI[playerid][pMember])
		{
		case F_BALLAS: {
				if(LoadAmmoInfo[i-GangAmmoCar[0]][gBallas] >= 2000) return FullFura(playerid,i);
				if(PI[playerid][pStuf][2] < 200) return SendClientMessageEx(playerid, COLOR_PAYCHEC, "Патроны %d/2000", LoadAmmoInfo[i-GangAmmoCar[0]][gBallas]);
				LoadAmmoInfo[i-GangAmmoCar[0]][gBallas] += 200;//
				SendClientMessageEx(playerid, COLOR_PAYCHEC, "Патроны %d/2000", LoadAmmoInfo[i-GangAmmoCar[0]][gBallas]);
				strin = "";
				format(strin, sizeof(strin), "%d/2000",LoadAmmoInfo[i-GangAmmoCar[0]][gBallas]);
				Update3DTextLabelText(AmmoText[i], COLOR_YELLOW, strin);
			}
		case F_VAGOS: {
				if(LoadAmmoInfo[i-GangAmmoCar[2]][gVagos] >= 2000) return FullFura(playerid,i);
				if(PI[playerid][pStuf][2] < 200) return SendClientMessageEx(playerid, COLOR_PAYCHEC, "Патроны %d/2000", LoadAmmoInfo[i-GangAmmoCar[2]][gVagos]);
				LoadAmmoInfo[i-GangAmmoCar[2]][gVagos] += 200;//
				SendClientMessageEx(playerid, COLOR_PAYCHEC, "Патроны %d/2000", LoadAmmoInfo[i-GangAmmoCar[2]][gVagos]);
				strin = "";
				format(strin, sizeof(strin), "%d/2000",LoadAmmoInfo[i-GangAmmoCar[2]][gVagos]);
				Update3DTextLabelText(AmmoText[i], COLOR_YELLOW, strin);
			}
		case F_GROVE: {
				if(LoadAmmoInfo[i-GangAmmoCar[1]][gGrove]  >= 2000) return FullFura(playerid,i);
				if(PI[playerid][pStuf][2] < 200) return SendClientMessageEx(playerid, COLOR_PAYCHEC, "Патроны %d/2000", LoadAmmoInfo[i-GangAmmoCar[1]][gGrove]);
				LoadAmmoInfo[i-GangAmmoCar[1]][gGrove] += 200;//
				SendClientMessageEx(playerid, COLOR_PAYCHEC, "Патроны %d/2000", LoadAmmoInfo[i-GangAmmoCar[1]][gGrove]);
				strin = "";
				format(strin, sizeof(strin), "%d/2000",LoadAmmoInfo[i-GangAmmoCar[1]][gGrove]);
				Update3DTextLabelText(AmmoText[i], COLOR_YELLOW, strin);
			}
		case F_AZTEC: {
				if(LoadAmmoInfo[i-GangAmmoCar[3]][gAztek]  >= 2000) return FullFura(playerid,i);
				if(PI[playerid][pStuf][2] < 200) return SendClientMessageEx(playerid, COLOR_PAYCHEC, "Патроны %d/2000", LoadAmmoInfo[i-GangAmmoCar[3]][gAztek]);
				LoadAmmoInfo[i-GangAmmoCar[3]][gAztek] += 200;//
				SendClientMessageEx(playerid, COLOR_PAYCHEC, "Патроны %d/2000", LoadAmmoInfo[i-GangAmmoCar[3]][gAztek]);
				strin = "";
				format(strin, sizeof(strin), "%d/2000",LoadAmmoInfo[i-GangAmmoCar[3]][gAztek]);
				Update3DTextLabelText(AmmoText[i], COLOR_YELLOW, strin);
			}
		case F_RIFA: {
				if(LoadAmmoInfo[i-GangAmmoCar[4]][gRifa]   >= 2000) return FullFura(playerid,i);
				if(PI[playerid][pStuf][2] < 200) return SendClientMessageEx(playerid, COLOR_PAYCHEC, "Патроны %d/2000", LoadAmmoInfo[i-GangAmmoCar[4]][gRifa]);
				LoadAmmoInfo[i-GangAmmoCar[4]][gRifa] += 200;//
				SendClientMessageEx(playerid, COLOR_PAYCHEC, "Патроны %d/2000", LoadAmmoInfo[i-GangAmmoCar[4]][gRifa]);
				strin = "";
				format(strin, sizeof(strin), "%d/2000",LoadAmmoInfo[i-GangAmmoCar[4]][gRifa]);
				Update3DTextLabelText(AmmoText[i], COLOR_YELLOW, strin);
			}
		}
		SendClientMessage(playerid, COLOR_WHITE, "Вы отнесли в фургон ящик с патронами (200 патронов)");
		GiveInventory(playerid,37,-200);
		SetPVarInt(playerid,"UseAmmos",0);
		RemovePlayerAttachedObject(playerid, 1);
		ApplyAnimation(playerid,"CARRY","crry_prtial",4.0,0,0,0,0,1,0);
		return 1;
	}
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid) {
	new slotid = GetVehicleComponentType(componentid);
	if(GetPlayerInterior(playerid) == 0 && AC_PI[playerid][pMod][14] != vehicleid && (AC_PI[playerid][pMod][slotid] != 2 && AC_PI[playerid][pMod] != -1))
	if(PI[playerid][pAdmLevel] < 1) NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (Vehicle Tuning)");
}

public OnPlayerSelectedMenuRow(playerid, row) {
	new Menu:Current = GetPlayerMenu(playerid);
	if(Current == SkinMenu) {
		switch(row)
		{
		case 0: {
				if(PI[playerid][pSex] == 0) {
					if(SelectCharPlace[playerid] == sizeof(JoinRegF)-1) SelectCharPlace[playerid] = 0;
					else SelectCharPlace[playerid]++;
					SetPlayerSkin(playerid, JoinRegF[SelectCharPlace[playerid]][0]);
				}
				else {
					if(SelectCharPlace[playerid] == sizeof(JoinRegM)-1) SelectCharPlace[playerid] = 0;
					else SelectCharPlace[playerid]++;
					SetPlayerSkin(playerid, JoinRegM[SelectCharPlace[playerid]][0]);
				}
				ShowMenuForPlayer(SkinMenu,playerid);
			}
		case 1: {
				if(PI[playerid][pSex] == 0) {
					if(SelectCharPlace[playerid] == 0) SelectCharPlace[playerid] = sizeof(JoinRegF)-1;
					else SelectCharPlace[playerid]--;
					SetPlayerSkin(playerid, JoinRegF[SelectCharPlace[playerid]][0]);
				}
				else {
					if(SelectCharPlace[playerid] == 0) SelectCharPlace[playerid] = sizeof(JoinRegM)-1;
					else SelectCharPlace[playerid]--;
					SetPlayerSkin(playerid, JoinRegM[SelectCharPlace[playerid]][0]);
				}
				ShowMenuForPlayer(SkinMenu,playerid);
			}
		case 2: {
				if(PI[playerid][pSex] == 0) PI[playerid][pSkin] = JoinRegF[SelectCharPlace[playerid]][0];
				else PI[playerid][pSkin] = JoinRegM[SelectCharPlace[playerid]][0];
				SetPlayerSkin(playerid,PI[playerid][pSkin]);
				TogglePlayerControllable(playerid, 0);
				ClothesRound[playerid] = 0;
				CreatePlayer(playerid, PI[playerid][pPassword]);
				SpawnPlayer(playerid);
				SavePlayer(playerid);
				KillTimer(EnterTimer[playerid]);
			}
		}
	}
	//
	if(Current == ShopMenu) {
		switch(row)
		{
		case 0: {
				if(PI[playerid][pSex] == 0) {
					if(SelectCharPlace[playerid] == sizeof(JoinShopF)-1) SelectCharPlace[playerid] = 0;
					else SelectCharPlace[playerid]++;
					SetPlayerSkin(playerid, JoinShopF[SelectCharPlace[playerid]][0]);
					// Цена
					strin = "";
					format(strin,sizeof(strin),"~g~$%d",JoinShopF[SelectCharPlace[playerid]][1]);
					TextDrawSetString(SkinCost[playerid],strin);
				}
				else {
					if(SelectCharPlace[playerid] == sizeof(JoinShopM)-1) SelectCharPlace[playerid] = 0;
					else SelectCharPlace[playerid]++;
					SetPlayerSkin(playerid, JoinShopM[SelectCharPlace[playerid]][0]);
					// Цена
					strin = "";
					format(strin,sizeof(strin),"~g~$%d",JoinShopM[SelectCharPlace[playerid]][1]);
					TextDrawSetString(SkinCost[playerid],strin);
				}
				ShowMenuForPlayer(ShopMenu,playerid);
			}
		case 1: {
				if(PI[playerid][pSex] == 0) {
					if(SelectCharPlace[playerid] == 0) SelectCharPlace[playerid] = sizeof(JoinShopF)-1;
					else SelectCharPlace[playerid]--;
					SetPlayerSkin(playerid, JoinShopF[SelectCharPlace[playerid]][0]);
					// Цена
					strin = "";
					format(strin,sizeof(strin),"~g~$%d",JoinShopF[SelectCharPlace[playerid]][1]);
					TextDrawSetString(SkinCost[playerid],strin);
				}
				else {
					if(SelectCharPlace[playerid] == 0) SelectCharPlace[playerid] = sizeof(JoinShopM)-1;
					else SelectCharPlace[playerid]--;
					SetPlayerSkin(playerid, JoinShopM[SelectCharPlace[playerid]][0]);
					// Цена
					strin = "";
					format(strin,sizeof(strin),"~g~$%d",JoinShopM[SelectCharPlace[playerid]][1]);
					TextDrawSetString(SkinCost[playerid],strin);
				}
				ShowMenuForPlayer(ShopMenu,playerid);
			}
		case 2: {
				if(PI[playerid][pSex] == 0) {
					if(GetMoney(playerid) < JoinShopF[SelectCharPlace[playerid]][1]) {
						SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
						return ShowMenuForPlayer(ShopMenu,playerid);
					}
					PI[playerid][pSkin] = JoinShopF[SelectCharPlace[playerid]][0];
					GiveMoney(playerid, -JoinShopF[SelectCharPlace[playerid]][1]);
				}
				else {
					if(GetMoney(playerid) < JoinShopM[SelectCharPlace[playerid]][1]) {
						SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
						return ShowMenuForPlayer(ShopMenu,playerid);
					}
					PI[playerid][pSkin] = JoinShopM[SelectCharPlace[playerid]][0];
					GiveMoney(playerid, -JoinShopM[SelectCharPlace[playerid]][1]);
				}
				TogglePlayerControllable(playerid,true);
				t_SetPlayerPos(playerid, 204.2966,-162.2770,1000.5234);
				SetPlayerFacingAngle(playerid, 182.1083);
				SetPlayerVirtualWorld(playerid, InShopSkin[playerid]);
				SetPlayerInterior(playerid, 14);
				InShopSkin[playerid] = 0;
				SelectCharPlace[playerid] = 0;
				ClothesRound[playerid] = 0;
				SetCameraBehindPlayer(playerid);
				SetPlayerSkin(playerid, PI[playerid][pSkin]);
				SendClientMessage(playerid, COLOR_GREY, "Вы купили новую одежду!");
				TextDrawHideForPlayer(playerid,SkinCost[playerid]);
				SavePlayer(playerid);
			}
		case 3: {
				TogglePlayerControllable(playerid,true);
				t_SetPlayerPos(playerid, 204.2966,-162.2770,1000.5234);
				SetPlayerFacingAngle(playerid, 182.1083);
				SetPlayerVirtualWorld(playerid, InShopSkin[playerid]);
				SetPlayerInterior(playerid, 14);
				InShopSkin[playerid] = 0;
				SelectCharPlace[playerid] = 0;
				ClothesRound[playerid] = 0;
				SetCameraBehindPlayer(playerid);
				SetPlayerSkin(playerid, PI[playerid][pSkin]);
				TextDrawHideForPlayer(playerid,SkinCost[playerid]);
			}
		}
	}
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
		if(isPlayingBasketBall(playerid)) {
			if(newkeys & KEY_JUMP) return tryScoreBBall(playerid);
			if(newkeys & KEY_SPRINT) return tryMarkOpponent(playerid);
			if(newkeys & KEY_HANDBRAKE) return tryPassBall(playerid);
			if(newkeys & KEY_WALK) return loadBBallAnims(BASKETBALL_DEFENSE);
		}
	}
	// - Y -- N-
	if(newkeys == 65536) {
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return StartEngine(playerid);
		if(IsPlayerInRangeOfPoint(playerid, 2.0, 1384.5718,-25.8539,1000.9229)) return SPD(playerid,D_GRAIN,0,"Создание наркотика","\n\t1 грамм = 10 зерен.\n\n\tПродолжить?","Да","Нет");
		if(KostiName[playerid] < 999)
		{
			new dice = random(12)+1;
			new dice1 = random(12)+1;

			new str1[13];
			strin = "";
			format(strin, sizeof(strin), "%s и %s бросили кости. Результат: {CC9900}%i:%i",NamePlayer(KostiName[playerid]),NamePlayer(playerid),dice,dice1);
			ProxDetectorNew(playerid,30.0,COLOR_PURPLE,strin);
			if(dice > dice1) {
				GiveMoney(KostiName[playerid],KostiMoney[playerid]);
				GiveMoney(playerid,-KostiMoney[playerid]);
				SendClientMessage(KostiName[playerid], COLOR_YELLOW, "Поздравляем, Вы выйграли!");
				SendClientMessage(playerid, COLOR_ORANGE, "К сожалению, Вы проиграли!");
				format(str1, sizeof(str1), "~g~+%d$", KostiMoney[playerid]);
				GameTextForPlayer(KostiName[playerid], str1, 3000, 1);
				format(str1, sizeof(str1), "~r~-%d$", KostiMoney[playerid]);
				GameTextForPlayer(playerid, str1, 3000, 1);
				strin = "";
				format(strin,sizeof(strin), "Выпало: %i",dice1);
				SetPlayerChatBubble(playerid,strin,COLOR_PURPLE,30.0,10000);
				strin = "";
				format(strin,sizeof(strin), "Выпало: %i",dice);
				SetPlayerChatBubble(KostiName[playerid],strin,COLOR_PURPLE,30.0,10000);
				ZapretDice[playerid] = 0;
				ZapretDice[KostiName[playerid]] = 0;
				KostiMoney[playerid] = 0;
				KostiName[playerid] = 999;
			}
			if(dice < dice1) {
				GiveMoney(KostiName[playerid],-KostiMoney[playerid]);
				GiveMoney(playerid,KostiMoney[playerid]);
				SendClientMessage(playerid, COLOR_YELLOW, "Поздравляем, Вы выйграли!");
				SendClientMessage(KostiName[playerid], COLOR_ORANGE, "К сожелению, вы проиграли!");
				format(str1, sizeof(str1), "~g~+%d$", KostiMoney[playerid]);
				GameTextForPlayer(playerid, str1, 3000, 1);
				format(str1, sizeof(str1), "~r~-%d$", KostiMoney[playerid]);
				GameTextForPlayer(KostiName[playerid], str1, 3000, 1);
				strin = "";
				format(strin,sizeof(strin), "Выпало: %i",dice1);
				SetPlayerChatBubble(playerid,strin,COLOR_PURPLE,30.0,10000);
				strin = "";
				format(strin,sizeof(strin), "Выпало: %i",dice);
				SetPlayerChatBubble(KostiName[playerid],strin,COLOR_PURPLE,30.0,10000);
				ZapretDice[playerid] = 0;
				ZapretDice[KostiName[playerid]] = 0;
				KostiMoney[playerid] = 0;
				KostiName[playerid] = 999;
			}
			if(dice == dice1) {
				SendClientMessage(playerid, COLOR_ORANGE, "Игра закончилась в нечью!");
				SendClientMessage(KostiName[playerid], COLOR_ORANGE, "Игра закончилась в нечью!");
				strin = "";
				format(strin,sizeof(strin), "Выпало: %i",dice1);
				SetPlayerChatBubble(playerid,strin,COLOR_PURPLE,30.0,10000);
				strin = "";
				format(strin,sizeof(strin), "Выпало: %i",dice);
				SetPlayerChatBubble(KostiName[playerid],strin,COLOR_PURPLE,30.0,10000);
				ZapretDice[playerid] = 0;
				ZapretDice[KostiName[playerid]] = 0;
				KostiMoney[playerid] = 0;
				KostiName[playerid] = 999;
			}
			return 1;
		}
		if(GetPVarInt(playerid, "KeyHeal") == 1)
		{
			new p = GetPVarInt(playerid, "PlayerHeal");
			SetHealth(playerid, 100);
			if(GetPlayerDrunkLevel(playerid) > 0) SetPlayerDrunkLevel(playerid, 0);
			SendClientMessageEx(playerid, 0x6495EDFF, "%s вылечил вас", NamePlayer(p));
			SendClientMessageEx(p, 0x6495EDFF, "Вы вылечили %s", NamePlayer(playerid));
			DeletePVar(playerid, "PlayerHeal");
			DeletePVar(playerid, "KeyHeal");
			return 1;
		}
		else if(GetPVarInt(playerid, "cKeyHeal") == 1)
		{
			new p = GetPVarInt(playerid, "cPlayerHeal"),price = GetPVarInt(playerid, "cPriceHeal");
			if(GetMoney(playerid) < price) {
				SendClientMessageEx(p,0x6495EDFF, "У игрока %s недостаточно средств", NamePlayer(playerid));
				DeletePVar(playerid, "cPlayerHeal");
				DeletePVar(playerid, "cPriceHeal");
				DeletePVar(playerid, "cKeyHeal");
				return SendClientMessage(playerid, COLOR_GREY, "У Вас недостаточно средств!");
			}
			if(!IsPlayerInVehicle(playerid, GetPlayerVehicleID(p))) return SendClientMessage(playerid, COLOR_GREY, "Вы должны находится в машине медика!");
			GiveMoney(p, price);
			GiveMoney(playerid, -price);
			SetHealth(playerid, 100);
			if(GetPlayerDrunkLevel(playerid) > 0) SetPlayerDrunkLevel(playerid, 0);
			SendClientMessageEx(playerid, 0x6495EDFF, "%s вылечил Вас за %i$", NamePlayer(p), price);
			SendClientMessageEx(p, 0x6495EDFF, "Вы вылечили %s за %i$", NamePlayer(playerid), price);
			DeletePVar(playerid, "cPlayerHeal");
			DeletePVar(playerid, "cPriceHeal");
			DeletePVar(playerid, "cKeyHeal");
			return 1;
		}
		if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) return cmd::inv(playerid, "");
	}
	if(newkeys == 131072) {
		if(KostiName[playerid] < 999)
		{
			KostiName[playerid] = 999;
			KostiMoney[playerid] = 0;
			ZapretDice[playerid] = 0;
			ZapretDice[KostiName[playerid]] = 0;
			SendClientMessage(KostiName[playerid], COLOR_GREEN, "Игрок отказался от ставки!");
			SendClientMessage(playerid, COLOR_ORANGE, "Вы отказались играть!");
		}
		if(GetPVarInt(playerid, "KeyHeal") == 1)
		{
			new p = GetPVarInt(playerid, "PlayerHeal");
			SendClientMessageEx(p,0x6495EDFF,"%s отклонил предложение вылечиться",NamePlayer(playerid));
			DeletePVar(playerid, "PlayerHeal");
			DeletePVar(playerid, "KeyHeal");
			return 1;
		}
		else if(GetPVarInt(playerid, "cKeyHeal") == 1)
		{
			new p = GetPVarInt(playerid, "cPlayerHeal");
			SendClientMessageEx(p,0x6495EDFF,"%s отклонил предложение вылечиться",NamePlayer(playerid));
			DeletePVar(playerid, "cPlayerHeal");
			DeletePVar(playerid, "cPriceHeal");
			DeletePVar(playerid, "cKeyHeal");
			return 1;
		}
	}
	// Сад
	if (GetPVarInt(playerid,"Collector_LTree") != 0 && PRESSED(KEY_HANDBRAKE)) {
		if(GetPVarInt(playerid,"Collector_Getting") == 1)return true;
		if(!IsPlayerInDynamicCP(playerid,GardenCheckpoints[GetPVarInt(playerid,"Collector_LTree")-1])) return true;
		if(GetPVarInt(playerid,"Collector_NotGived") >= 30) return SendClientMessage(playerid,COLOR_RED,"Корзина полна, сдайте ее на склад.");
		if(GetPVarInt(playerid,"Collector_Treed") >= 15) return SendClientMessage(playerid,COLOR_RED,"Собирайте яблоки у другого дерева.");

		SetPVarInt(playerid,"Animation",4);
		ApplyAnimation(playerid, "CAMERA","picstnd_in",4.0,1,0,0,0,0);
		SetPVarInt(playerid,"Collector_Getting",1);
		SetTimerEx("CollectorGet",1250,false,"i",playerid);
	}
	// Лесопилка
	if(GetPVarInt(playerid, "LessPil") == 1 && PRESSED(KEY_FIRE)) {
		if(IsPlayerInRangeOfPoint(playerid, 2.5,Derevo[GetPVarInt(playerid, "Derevo")][0],Derevo[GetPVarInt(playerid, "Derevo")][1],Derevo[GetPVarInt(playerid, "Derevo")][2]))
		{
			if(!strcmp(animlib[playerid], "CHAINSAW", true) && !strcmp(animname[playerid], "CSAW_1", true) || !strcmp(animlib[playerid], "CHAINSAW", true) && !strcmp(animname[playerid], "CSAW_2", true)) {
				SetPVarInt(playerid, "LessProc", GetPVarInt(playerid, "LessProc") + 4);
				if(GetPVarInt(playerid,"LessProc") > 95) SetPVarInt(playerid, "LessProc", 100);
				return 1;
			}
		}
	}
	// Клавиша F
	if(newkeys == 16) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0,2317.0669,-1527.6624,25.3438)) joiningOrLeavingBBall(playerid); //basketball
		if(GetPVarInt(playerid, "HealDeath") == 1 || GetPVarInt(playerid, "SetHeal") == 1)
		{
			if(PI[playerid][pHeal] < 80) {
				new fullk;
				if(GetPVarInt(playerid, "MedHealPlace") > 0) {
					fullk++;
					SendClientMessage(playerid, COLOR_GREY, "У Вас уже есть койка!");
				}
				else {
					for(new i = 0; i < 15; i++) {
						if(IsPlayerInRangeOfPoint(playerid, 1.3,InMedHeal[i][0], InMedHeal[i][1], InMedHeal[i][2]))
						{
							if(GetPVarInt(playerid, "SetHeal") == 1)
							SPD(playerid,10001,0,"Больница","{ffffff}Для Вас лечение платное!\nСтоимость лечения: 300$\nВы хотите занять койку?", "Да", "Нет");
							else {
								if(StatusMedHeal[i] == true) return SendClientMessage(playerid, COLOR_GREY, "Данное место занято!");
								StatusMedHeal[i] = true;
								SetPVarInt(playerid, "MedHealPlace", i+1);
								fullk++;
								strin = "";
								SendClientMessageEx(playerid, COLOR_YELLOW, "Вы заняли эту койку!");
								strin = "";
								format(strin, 64, "Койка: %s", NamePlayer(playerid));
								UpdateDynamic3DTextLabelText(MedHealText3D[i],0x7CB523FF,strin);
								SetPVarInt(playerid, "MedHealPlay", 1);
								SetPVarInt(playerid, "MedHealTime", 1);
								DeletePVar(playerid, "HealDeath");
							}
						}
					}
				}
				if(fullk == 0) SendClientMessage(playerid, COLOR_GREY, "Вы должны находится возле койки!");
			}
		}
		if(ClothesRound[playerid] == 1)
		{
			SetPlayerVirtualWorld(playerid, playerid);
			SetPlayerInterior(playerid,18);
			PI[playerid][pRank] = 0;PI[playerid][pMember] = 0;PI[playerid][pAdmLevel] = 0;
			SetPlayerInterior(playerid,14);
			t_SetPlayerPos(playerid,1480.0984,-1369.8914,121.9811);
			SetPlayerFacingAngle(playerid, 2.5123);
			SetPlayerCameraPos(playerid,1480.0277,-1364.4063,122.7142);
			SetPlayerCameraLookAt(playerid,1480.0984,-1369.8914,121.9811);
			TogglePlayerControllable(playerid, 0);
			ShowMenuForPlayer(SkinMenu,playerid);
		}
		else if(ClothesRound[playerid] == 2)
		{
			SetPlayerVirtualWorld(playerid, playerid);
			SetPlayerInterior(playerid,14);
			t_SetPlayerPos(playerid, 215.0519,-155.5064,1000.5234);
			SetPlayerFacingAngle(playerid, 91.8908);
			SetPlayerCameraPos(playerid,212.2030,-155.6162,1000.5306);
			SetPlayerCameraLookAt(playerid,213.7042,-155.6230,1000.5234);
			TogglePlayerControllable(playerid, 0);
			ShowMenuForPlayer(ShopMenu,playerid);
		}
		for(new i; i <= sizeof(ATMInfo);i++)
		{
			if(IsPlayerInRangeOfPoint(playerid,1.5,ATMInfo[i][0],ATMInfo[i][1],ATMInfo[i][2])) {
				if(CheckNewBank[playerid] == 1) return SendClientMessage(playerid, COLOR_GREY, "У Вас нет счета в банке!");
				query = "";
				format(query, sizeof(query), "SELECT * FROM `bank` WHERE `playerid` = '%d'", PI[playerid][pID]);
				mysql_function_query(cHandle, query, true, "LoadAccountBank", "d", playerid);
				break;
			}
		}
	}
	//
	// Шахтер
	if(GetPVarInt(playerid, "Miner") == 1 && PRESSED(KEY_FIRE)) {
		if((GetTickCount() - PlayerLastTick[playerid]) < 1000 ) return 1;
		if(IsPlayerInRangeOfPoint(playerid, 4.0, 416.7321,863.8525,3011.4116) || IsPlayerInRangeOfPoint(playerid, 4.0, 418.9579,878.6878,3011.7649) || IsPlayerInRangeOfPoint(playerid, 4.0, 430.3567,885.1015,3013.3110)
				|| IsPlayerInRangeOfPoint(playerid, 4.0, 438.8086,885.2208,3013.8123) || IsPlayerInRangeOfPoint(playerid, 4.0, 438.8394,860.0536,3011.7625) || IsPlayerInRangeOfPoint(playerid, 4.0, 432.6754,860.3979,3012.6011) || IsPlayerInRangeOfPoint(playerid, 4.0, 423.9833,855.9692,3010.6992))
		{
			SetPVarInt(playerid,"MinerCount",GetPVarInt(playerid,"MinerCount")+1);
			if(GetPVarInt(playerid,"MinerCount") >= 10) {
				ClearAnimations(playerid);
				TogglePlayerControllable(playerid,1);
				ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
				ApplyAnimation(playerid,"CARRY","crry_prtial",4.1,0,1,1,1,1);
				if(IsPlayerAttachedObjectSlotUsed(playerid, 3)) RemovePlayerAttachedObject(playerid, 3);
				SetPlayerAttachedObject(playerid, 4, 3930, 1, 0.242263, 0.535462, -0.046915, 353.850921, 306.869110, 242.540740, 1.000000, 1.000000, 1.000000 );
				SetPlayerCheckpoint(playerid, 479.4036,867.0117,3008.5830-1,2.0);
				SetPVarInt(playerid,"Miner",2);
				new rand = 0;
				if(IsPlayerInRangeOfPoint(playerid, 2.0,479.4036,867.0117,3008.5830)) rand = 30 + random(29);
				else rand = 20 + random(29);
				SetPVarInt(playerid, "MinerKG_One", rand);
				DeletePVar(playerid, "MinerCount");
				return 1;
			}
			ApplyAnimation( playerid, "BASEBALL", "Bat_4", 4.1, 0, 1, 1, 1, 0 );
			PlayerLastTick[playerid] = GetTickCount();
		}
	}
	if(PRESSED(KEY_SPRINT)) {
		if(GetPVarInt(playerid,"Animation") > 0)
		{
			ClearAnimations(playerid);
			ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
			SetPVarInt(playerid,"Animation", 0);
			TextDrawHideForPlayer(playerid, AnimDraw[playerid]);
			return 1;
		}
		new Float:Velocity[3];
		GetPlayerVelocity(playerid, Velocity[0], Velocity[1], Velocity[2]);
		if(Velocity[0] != 0 || Velocity[1] != 0 || Velocity[2] != 0) TimeActive[playerid] = gettime();
	}
	//
	if(newkeys & KEY_SPRINT && newkeys & KEY_JUMP) {
		GetAnimationName(GetPlayerAnimationIndex(playerid),animlib[playerid], 32, animname[playerid], 32);
		if(strcmp(animname[playerid], "RUN_CIVI", true) == 0) BunnyUse[playerid] = true;
	}
	if(newkeys & KEY_JUMP && !BunnyUse[playerid]) {
		if(TimeActive[playerid] != 0 && gettime() - TimeActive[playerid] < 2) BunnyUse[playerid] = true;
	}
	// Проверки
	if(PRESSED(KEY_FIRE) || PRESSED(KEY_HANDBRAKE) || PRESSED(KEY_CROUCH) || PRESSED(KEY_ACTION)) {
		if(GetPVarInt(playerid,"Miner") == 2 && IsPlayerAttachedObjectSlotUsed(playerid, 4) || GetPVarInt(playerid,"LessStatus") == 1 && IsPlayerAttachedObjectSlotUsed(playerid, 3))
		{
			ClearAnimations(playerid);
			ApplyAnimation(playerid,"CARRY","crry_prtial",4.1,0,1,1,1,1);
			return 1;
		}
		else if(GetPVarInt(playerid,"Gruz") > 0 && GetPVarInt(playerid,"GruzYes") > 0 && IsPlayerAttachedObjectSlotUsed(playerid, 2))
		{
			ClearAnimations(playerid);
			ApplyAnimation(playerid,"CARRY","crry_prtial",4.1,0,1,1,1,1);
		}
	}
	else if(newkeys & KEY_JUMP && !(oldkeys & KEY_JUMP) && GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED) ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff",4.1,0,1,1,0,0);
	else if(PRESSED(KEY_SECONDARY_ATTACK) || PRESSED(KEY_JUMP) || PRESSED(KEY_SPRINT)) {
		if(GetPVarInt(playerid,"UseAmmos") == 1)
		{
			SendClientMessageEx(playerid, COLOR_RED, "Вы уронили ящик с патронами, попробуйте еще раз!");
			GiveInventory(playerid,37,-200);
			SetPVarInt(playerid,"UseAmmos",0);
			RemovePlayerAttachedObject(playerid, 1);
			ApplyAnimation(playerid,"CARRY","crry_prtial",4.0,0,0,0,0,1,0);
		}
		if(GetPVarInt(playerid,"Miner") == 2 && IsPlayerAttachedObjectSlotUsed(playerid, 4))
		{
			SendClientMessageEx(playerid, COLOR_RED, "Вы уронили железо, попробуйте еще раз!");
			RemovePlayerAttachedObject(playerid,4);
			DisablePlayerCheckpoint(playerid);
			TogglePlayerControllable(playerid,1);
			SetPVarInt(playerid,"Miner", 1);
			ClearAnimations(playerid);
			ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
			SetPlayerAttachedObject(playerid, 3, 18634, 6, 0.078222, 0.000000, 0.110844, 298.897308, 264.126861, 193.350555, 1.000000, 1.000000, 1.000000);
		}
		else if(GetPVarInt(playerid,"Gruz") > 0 && GetPVarInt(playerid,"GruzYes") > 0 && IsPlayerAttachedObjectSlotUsed(playerid, 2))
		{
			SendClientMessageEx(playerid, COLOR_RED, "Вы уронили мешок, попробуйте еще раз!");
			if(TOTALGRUZ <= 0) {
				DisablePlayerCheckpoint(playerid);
				RemovePlayerAttachedObject(playerid,2);
				ClearAnimations(playerid);
				ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
				SendClientMessage(playerid, COLOR_GREY, "В вагонах больше нет мешков!");
				return 1;
			}
			DisablePlayerCheckpoint(playerid);
			RemovePlayerAttachedObject(playerid,2);
			SetPlayerCheckpoint(playerid,2042.6589,-1958.3080,14.3957,1.4);
			SetPVarInt(playerid, "GruzYes",0);
			ClearAnimations(playerid);
			ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
		}
	}
	if(newkeys & KEY_CROUCH) {
		if(GetPlayerState(playerid) != 2) return 1;
		// Автобусный парк
		if(IsPlayerInRangeOfPoint(playerid, 15.0, 2222.4169922, -2530.7871094, 2052.1999512)) {
			for(new i; i < 11; i++) PlayerTextDrawHide(playerid,TuningTD[i][playerid]);
			TogglePlayerControllable(playerid,0),
			SetTimerEx("Unfreez",1800,false,"i",playerid);
			SetVehiclePosEx(GetPlayerVehicleID(playerid), 691.3149,-1568.6337,14.5905);
			SetVehicleZAngle(GetPlayerVehicleID(playerid),0);
			SetPVarInt(playerid,"TuningCar",0);
			InTuning[playerid] = 0;
			NullComponents(playerid),TuningCamera(playerid),SetCameraBehindPlayer(playerid);
		}
		if(IsPlayerInRangeOfPoint(playerid, 5.0, 869.6716,719.5503,1039.8295))
		{
			if(GetPlayerHouse(playerid) == 0) return SendClientMessage(playerid, COLOR_GREY, "У Вас нет дома!");
			new i = GetPVarInt(playerid, "PlayerHouse");
			if(HouseInfo[i][hLocker] == 0) return SendClientMessage(playerid,COLOR_GREY,"В вашем доме не установлен гараж!");
			if(PI[playerid][pCars][selectcar[playerid]-1] == 0) return true;
			new c = PI[playerid][pCars][selectcar[playerid]-1];
			caringarage[playerid] = 0;
			Delete3DTextLabel(CarInfo[c][cText]);
			strin = "";
			format(strin, sizeof(strin), "{ff4f00}Владелец: {ffffff}%s\n{ff4f00}ID: {ffffff}%d", CarInfo[c][cOwner], CarInfo[c][cID]);
			CarInfo[c][cText] = Create3DTextLabel(strin, 0x33AAFFFF, 0.0, 0.0, 0.0, 50.0, 0, 1);
			Attach3DTextLabelToVehicle(CarInfo[c][cText], CarInfo[c][cID], 0.0, 0.0, 1.25);
			DestroyVehicle(CarInfo[c][cID]);
			CarInfo[c][cID] = CreateVehicle(CarInfo[c][cModel], HouseInfo[i][hCarx],HouseInfo[i][hCary],HouseInfo[i][hCarz], HouseInfo[i][hCarfa], CarInfo[c][cColor][0], CarInfo[c][cColor][1], 90000);
			LinkVehicleToInterior(CarInfo[c][cID],7);
			SetPlayerInterior(playerid,7);
			SetVehicleVirtualWorld(CarInfo[c][cID], playerid);
			SetPlayerVirtualWorld(playerid,playerid);
			CarInfo[c][cFuel] = 150;
			LinkVehicleToInterior(CarInfo[c][cID],0);
			SetPlayerInterior(playerid,0);
			SetVehicleVirtualWorld(CarInfo[c][cID], 0);
			SetPlayerVirtualWorld(playerid,0);
			LoadMyCar(playerid,selectcar[playerid]-1);
			PutPlayerInVehicleEx(playerid, CarInfo[c][cID], 0);
			selectcar[playerid] = 0;
		}
		if(IsPlayerInRangeOfPoint(playerid, 10.0,1217.2049561,-1842.4620361,13.1660004))
		{
			if(GetPlayerState(playerid) != 2) return 1;
			if(GateOpened[0]) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ворота уже открыты!");
			new Float:RotX, Float:RotY, Float:RotZ;
			GetObjectRot(Object[1], RotX, RotY, RotZ);
			if(RotY != 269) return 1;
			MoveObject(Object[1], 1217.2049561,-1842.4620361,13.1660004+0.004,0.004, 0.00000000,0.00000000,0.00000000);
			SetTimer("GateBus", 7000, 0);
			GateOpened[0] = 1;
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Шлагбаум открыт, у Вас есть 7 секунд что бы проехать.");
		}
		if(IsPlayerInRangeOfPoint(playerid, 10.0,1273.5322266,-1842.4619141,13.1660004))
		{
			if(GetPlayerState(playerid) != 2) return 1;
			if(GateOpened[1]) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ворота уже открыты!");
			new Float:RotX, Float:RotY, Float:RotZ;
			GetObjectRot(Object[2], RotX, RotY, RotZ);
			if(RotY != 269) return 1;
			MoveObject(Object[2], 1273.5322266,-1842.4619141,13.1660004+0.004,0.004, 0.00000000,0.00000000,0.00000000);
			SetTimer("GateBusTy", 7000, 0);
			GateOpened[1] = 1;
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Шлагбаум открыт, у Вас есть 7 секунд что бы проехать.");
		}
		// Таксопарк
		if(IsPlayerInRangeOfPoint(playerid, 7.0,1101.8370361,-1736.0090332,13.2410002))
		{
			if(GetPlayerState(playerid) != 2) return 1;
			if(GateOpened[2]) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ворота уже открыты!");
			new Float:RotX, Float:RotY, Float:RotZ;
			GetObjectRot(Object[3], RotX, RotY, RotZ);
			if(RotY != 269) return 1;
			MoveObject(Object[3], 1101.8370361,-1736.0090332,13.2410002+0.004,0.004, 0.00000000,0.00000000,90.00000000);
			SetTimer("GateTaxi", 7000, 0);
			GateOpened[2] = 1;
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Шлагбаум открыт, у Вас есть 7 секунд что бы проехать.");
		}
		// Сухопутные Войска
		if(IsPlayerInRangeOfPoint(playerid, 7.0,285.793, 1821.920, 19.887))
		{
			if(PI[playerid][pMember] != F_ARMY) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "У вас нет доступа!");
			if(GateOpened[3]) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ворота уже открыты!");
			MoveObject(Object[4], 285.772, 1833.950, 19.887, 5.0);
			SetTimer("Gate51", 7000, 0);
			GateOpened[3] = 1;
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Ворота открыты, у Вас есть 7 секунд что бы проехать.");
		}
		if(IsPlayerInRangeOfPoint(playerid, 7.0,135.614, 1941.291, 21.577))
		{
			if(PI[playerid][pMember] != F_ARMY) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "У вас нет доступа!");
			if(GateOpened[4]) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ворота уже открыты!");
			MoveObject(Object[5], 148.434, 1941.291, 21.577, 5.0);
			SetTimer("Gate51a", 7000, 0);
			GateOpened[4] = 1;
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Ворота открыты, у Вас есть 7 секунд что бы проехать.");
		}
		if(IsPlayerInRangeOfPoint(playerid, 10.0,348.9490051,1800.5999756,18.1000004))
		{
			if(PI[playerid][pMember] != F_ARMY) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "У вас нет доступа!");
			if(GateOpened[5]) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ворота уже открыты!");
			new Float:RotX, Float:RotY, Float:RotZ;
			GetObjectRot(Object[7], RotX, RotY, RotZ);
			if(RotY != 269) return 1;
			MoveObject(Object[7], 348.9490051, 1800.5999756, 18.1000004, 5.0);
			SetTimer("GateA51", 7000, 0);
			GateOpened[5] = 1;
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Шлагбаум открыт, у Вас есть 7 секунд что бы проехать.");
		}
		if(IsPlayerInRangeOfPoint(playerid, 8.0,214.677, 1875.406, 13.891))
		{
			if(PI[playerid][pMember] != F_ARMY) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "У вас нет доступа!");
			if(GateOpened[6]) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ворота уже открыты!");
			MoveObject(Object[8], 222.687 ,1875.364, 13.891, 5.0);
			SetTimer("GateBunker51", 7000, 0);
			GateOpened[6] = 1;
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Ворота открыты, у Вас есть 7 секунд что бы проехать.");
		}
		// SAPD
		if(IsPlayerInRangeOfPoint(playerid, 7.0,1544.682495,-1630.980000,13.215000))
		{
			if(GetPlayerState(playerid) != 2) return 1;
			if(PI[playerid][pMember] != F_SAPD) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "У вас нет доступа!");
			if(GateOpened[7]) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ворота уже открыты!");
			new Float:RotX, Float:RotY, Float:RotZ;
			GetObjectRot(Object[6], RotX, RotY, RotZ);
			if(RotY != 90) return 1;
			MoveObject(Object[6], 1544.682495, -1630.980000, 13.215000+0.004,0.004, 0.00000000,0.00000000,90.00000000);
			SetTimer("GateLspd", 7000, 0);
			GateOpened[7] = 1;
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Шлагбаум открыт, у Вас есть 7 секунд что бы проехать.");
		}
		return 1;
	}
	// Выход из дома на alt
	if(newkeys == 1024) {
		if(PlayerLogged[playerid] != true) return 1;
		for(new i = 0; i < sizeof(ObjectInv); i++)
		{
			if (IsPlayerInRangeOfPoint(playerid, 2.0,ObjectInv[i][obiDropPos][0],ObjectInv[i][obiDropPos][1],ObjectInv[i][obiDropPos][2])) {
				DestroyObject(ObjectInv[i][obiObject]);
				GiveInventory(playerid, ObjectInv[i][obiDrop][0], ObjectInv[i][obiDrop][1]);
				ObjectInv[i][obiDrop][0] = 0;
				ObjectInv[i][obiDrop][1] = 0;
				ObjectInv[i][obiDropPos][0] = 0.0;
				ObjectInv[i][obiDropPos][1] = 0.0;
				ObjectInv[i][obiDropPos][2] = 0.0;
				ApplyAnimation(playerid,"BSKTBALL","BBALL_pickup",4.0,0,0,0,0,0);
				strin = "";
				format(strin, sizeof(strin), "%s поднимает предмет с земли", NamePlayer(playerid));
				ProxDetector(10.0, playerid, strin, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				return 1;
			}
		}
		for(new idx = 1; idx <= TOTALHOUSE; idx++)
		{
			if(HouseInfo[idx][hOutput] == 1) {
				if(IsPlayerInRangeOfPoint(playerid, 1.5,HouseInfo[idx][hExitx],HouseInfo[idx][hExity],HouseInfo[idx][hExitz]) && GetPlayerInterior(playerid) == HouseInfo[idx][hInt] && GetPlayerVirtualWorld(playerid) == idx) {
					t_SetPlayerPos(playerid,HouseInfo[idx][hEx],HouseInfo[idx][hEy],HouseInfo[idx][hEz]);
					SetPlayerFacingAngle(playerid, HouseInfo[idx][hEp]);
					SetPlayerInterior(playerid,0);
					SetPlayerVirtualWorld(playerid,0);
				}
			}
		}
		if(IsPlayerInRangeOfPoint(playerid,0.3,293.6721,-38.5141,1001.5156))
		{
			if(PI[playerid][pLic][3] < 1) return SendClientMessage(playerid, COLOR_RED, "Вы не можете купить оружие т.к у вас нету лицензии на оружие.");
			SetPlayerCameraPos(playerid, 293.5550, -38.6622, 1002.9490);
			SetPlayerCameraLookAt(playerid, 293.5551, -39.6610, 1000.8944);
			strin = "";
			format(strin,256,"{FFFFFF}Пистолет:\t\t{C13E1D}Desert Eagle\n{FFFFFF}Патроны:\t\t{C13E1D}40 шт.\n\n{FFFFFF}Стоимость: {0FC531}4000$");
			SPD(playerid,3005,DIALOG_STYLE_MSGBOX,"Пистолет - Desert Eagle",strin,"Купить","Выход");
		}
		if(IsPlayerInRangeOfPoint(playerid,0.3,294.3938,-38.5145,1001.5156))
		{
			if(PI[playerid][pLic][3] < 1) return SendClientMessage(playerid, COLOR_RED, "Вы не можете купить оружие т.к у вас нету лицензии на оружие.");
			SetPlayerCameraPos(playerid, 294.4572, -38.6204, 1002.8725);
			SetPlayerCameraLookAt(playerid, 294.4612, -39.6191, 1001.0381);
			strin = "";
			format(strin,256,"{FFFFFF}Пистолет:\t\t{C13E1D}SdPistol\n{FFFFFF}Патроны:\t\t{C13E1D}40 шт.\n\n{FFFFFF}Стоимость: {0FC531}4000$");
			SPD(playerid,3006,DIALOG_STYLE_MSGBOX,"Пистолет - SdPistol",strin,"Купить","Выход");
		}
		if(IsPlayerInRangeOfPoint(playerid,0.3,295.2726,-38.5150,1001.5156))
		{
			if(PI[playerid][pLic][3] < 1) return SendClientMessage(playerid, COLOR_RED, "Вы не можете купить оружие т.к у вас нету лицензии на оружие.");
			SetPlayerCameraPos(playerid, 295.4286, -38.6667, 1003.0334);
			SetPlayerCameraLookAt(playerid, 295.4344, -39.6655, 1000.9838);
			strin = "";
			format(strin,256,"{FFFFFF}Дробовик:\t\t{C13E1D}Shot Gun\n{FFFFFF}Патроны:\t\t{C13E1D}80 шт.\n\n{FFFFFF}Стоимость: {0FC531}6000$");
			SPD(playerid,3007,DIALOG_STYLE_MSGBOX,"Дробовик - Shot Gun",strin,"Купить","Выход");
		}
		if(IsPlayerInRangeOfPoint(playerid,0.3,296.5346,-38.5150,1001.5156))
		{
			if(PI[playerid][pLic][3] < 1) return SendClientMessage(playerid, COLOR_RED, "Вы не можете купить оружие т.к у вас нету лицензии на оружие.");
			SetPlayerCameraPos(playerid, 296.4631, -38.6067, 1002.9152);
			SetPlayerCameraLookAt(playerid, 296.4595, -39.6049, 1000.9538);
			strin = "";
			format(strin,256,"{FFFFFF}Пол-автомат:\t\t{C13E1D}MP5\n{FFFFFF}Патроны:\t\t{C13E1D}120 шт.\n\n{FFFFFF}Стоимость: {0FC531}10000$");
			SPD(playerid,3008,DIALOG_STYLE_MSGBOX,"Пол-автомат - MP5",strin,"Купить","Выход");
		}
		if(IsPlayerInRangeOfPoint(playerid,0.3,297.0396,-38.3967,1001.5156))
		{
			if(PI[playerid][pLic][3] < 1) return SendClientMessage(playerid, COLOR_RED, "Вы не можете купить оружие т.к у вас нету лицензии на оружие.");
			SetPlayerCameraPos(playerid, 297.3016, -38.4249, 1002.6393);
			SetPlayerCameraLookAt(playerid, 298.3000, -38.4255, 1000.3725);
			strin = "";
			format(strin,256,"{FFFFFF}Автомат:\t\t{C13E1D}АК-47\n{FFFFFF}Патроны:\t\t{C13E1D}160 шт.\n\n{FFFFFF}Стоимость: {0FC531}10000$");
			SPD(playerid,3009,DIALOG_STYLE_MSGBOX,"Автомат - АК-47",strin,"Купить","Выход");
		}
		if(IsPlayerInRangeOfPoint(playerid,0.3,299.2400,-38.4304,1001.5156))
		{
			if(PI[playerid][pLic][3] < 1) return SendClientMessage(playerid, COLOR_RED, "Вы не можете купить оружие т.к у вас нету лицензии на оружие.");
			SetPlayerCameraPos(playerid, 298.8741, -38.5262, 1002.6832);
			SetPlayerCameraLookAt(playerid, 297.8757, -38.5313, 999.8607);
			strin = "";
			format(strin,256,"{FFFFFF}Автомат:\t\t{C13E1D}M4\n{FFFFFF}Патроны:\t\t{C13E1D}120 шт.\n\n{FFFFFF}Стоимость: {0FC531}10000$");
			SPD(playerid,3010,DIALOG_STYLE_MSGBOX,"Автомат - M4",strin,"Купить","Выход");
		}
		if(IsPlayerInRangeOfPoint(playerid,0.3,299.2404,-39.5468,1001.5156))
		{
			if(PI[playerid][pLic][3] < 1) return SendClientMessage(playerid, COLOR_RED, "Вы не можете купить оружие т.к у вас нету лицензии на оружие.");
			SetPlayerCameraPos(playerid, 298.9263, -39.4920, 1002.7551);
			SetPlayerCameraLookAt(playerid, 297.9278, -39.4851, 1000.3481);
			strin = "";
			format(strin,256,"{FFFFFF}Защита:\t\t{C13E1D}Бронижилет\n\n{FFFFFF}Стоимость: {0FC531}15000$");
			SPD(playerid,3011,DIALOG_STYLE_MSGBOX,"Бронижилет",strin,"Купить","Выход");
		}
		if(GetPlayerVirtualWorld(playerid) == 1 || GetPlayerVirtualWorld(playerid) == 2 || GetPlayerVirtualWorld(playerid) == 3)
		{
			if(PlayerToPoint(2.0,playerid,1708.7024,-1670.2324,23.7057)) {
				if(PI[playerid][pHotelNumber] != 1) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №1");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1708.7043,-1665.0304,23.7044)) {
				if(PI[playerid][pHotelNumber] != 2) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №2");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1708.7029,-1659.8270,23.7031)) {
				if(PI[playerid][pHotelNumber] != 3) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №3");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1708.7021,-1654.5770,23.7018)) {
				if(PI[playerid][pHotelNumber] != 4) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №4");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1708.7019,-1649.3079,23.6953)) {
				if(PI[playerid][pHotelNumber] != 5) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №5");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1735.0483,-1642.2540,23.7578)) {
				if(PI[playerid][pHotelNumber] != 6) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №6");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1735.0646,-1648.1945,23.7448)) {
				if(PI[playerid][pHotelNumber] != 7) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №7");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1735.0820,-1654.0867,23.7318)) {
				if(PI[playerid][pHotelNumber] != 8) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №8");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1735.0988,-1660.0123,23.7188)) {
				if(PI[playerid][pHotelNumber] != 9) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №9");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1708.7017,-1670.2111,27.1953)) {
				if(PI[playerid][pHotelNumber] != 10) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №10");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1708.7028,-1665.0184,27.1953)) {
				if(PI[playerid][pHotelNumber] != 11) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №11");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1708.7098,-1659.7622,27.1953)) {
				if(PI[playerid][pHotelNumber] != 12) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №12");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1708.7083,-1654.5234,27.1953)) {
				if(PI[playerid][pHotelNumber] != 13) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №13");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1708.7184,-1649.2904,27.1953)) {
				if(PI[playerid][pHotelNumber] != 14) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №14");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1735.0482,-1642.3508,27.2392)) {
				if(PI[playerid][pHotelNumber] != 15) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №15");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1735.0631,-1648.2434,27.2304)) {
				if(PI[playerid][pHotelNumber] != 16) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №16");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1735.0767,-1654.1727,27.2216)) {
				if(PI[playerid][pHotelNumber] != 17) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №17");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
			if(PlayerToPoint(2.0,playerid,1735.0927,-1660.0815,27.2128)) {
				if(PI[playerid][pHotelNumber] != 18) return SendClientMessage(playerid,COLOR_GREY,"Вы не владелец гостиничного номера №18");
				if(GetPlayerVirtualWorld(playerid) != PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"Вы не проживаете в этом отеле!");
				t_SetPlayerPos(playerid,-2168.4741,642.1261,1057.5938);
				SetPlayerInterior(playerid, 1);
				SetPlayerVirtualWorld(playerid,playerid);
			}
		}
	}
	if(!IsPlayerInAnyVehicle(playerid)) //АнтиДМ
	{
		if(newkeys & KEY_FIRE || (newkeys & KEY_SPRINT && newkeys & KEY_SECONDARY_ATTACK) || (newkeys & 128  && newkeys & 16) || (newkeys & KEY_SPRINT && newkeys & KEY_FIRE ) || !strcmp(animlib[playerid], "PED", true) && !strcmp(animname[playerid], "FIGHTA_1", true) || !strcmp(animlib[playerid], "PED", true) && !strcmp(animname[playerid], "FIGHTA_2", true))
		{
			if(IsPlayerInRangeOfPoint(playerid, 40.0,1109.3701,-1796.3728,16.5938)) {
				ApplyAnimation(playerid,"FAT","IDLE_tired",4.0,1,0,0,0,0,0);
				SetPVarInt(playerid, "TimeDM", 6);
			}
		}
		if(newkeys & KEY_FIRE || (newkeys & KEY_SPRINT && newkeys & KEY_SECONDARY_ATTACK) || (newkeys & 128  && newkeys & 16) || (newkeys & KEY_SPRINT && newkeys & KEY_FIRE ) || !strcmp(animlib[playerid], "PED", true) && !strcmp(animname[playerid], "FIGHTA_1", true) || !strcmp(animlib[playerid], "PED", true) && !strcmp(animname[playerid], "FIGHTA_2", true))
		{
			if(IsPlayerInRangeOfPoint(playerid, 40.0,331.5340,179.3468,942.9400) && GetPlayerVirtualWorld(playerid) == 1) {
				ApplyAnimation(playerid,"FAT","IDLE_tired",4.0,1,0,0,0,0,0);
				SetPVarInt(playerid, "TimeDM", 6);
			}
		}
	}
	// Авто
	new carid = GetPlayerVehicleID(playerid);
	if(newkeys == 8192)//Num 4
	{
		if(InShop[playerid] > 0) return 1;
		if(Boots[carid] == false)
		{
			if(GetVehicleModel(carid) == 411) return 1;
			GetVehicleParamsEx(carid,engine,lights,alarm,doors,bonnet,boot,objective);
			SetVehicleParamsEx(carid,engine,lights,alarm,doors,bonnet,true,objective);
			Boots[carid] = true;
		}else{
			GetVehicleParamsEx(carid,engine,lights,alarm,doors,bonnet,boot,objective);
			SetVehicleParamsEx(carid,engine,lights,alarm,doors,bonnet,false,objective);
			Boots[carid] = false;
		}
	}
	if(newkeys == 1) //Фары
	{
		if(InShop[playerid] > 0) return 1;
		if(Light[carid] == false)
		{
			GetVehicleParamsEx(carid,engine,lights,alarm,doors,bonnet,boot,objective);
			SetVehicleParamsEx(carid,engine,true,alarm,doors,bonnet,boot,objective);
			Light[carid] = true;
		}else{
			GetVehicleParamsEx(carid,engine,lights,alarm,doors,bonnet,boot,objective);
			SetVehicleParamsEx(carid,engine,false,alarm,doors,bonnet,boot,objective);
			Light[carid] = false;
		}
	}
	return 1;
}
public OnRconLoginAttempt(ip[], password[], success) {
	if(success) {
		static ips[16];
		foreach(new i: Player)
		{
			if(!strcmp(NamePlayer(i),OWNER_SERVER1,true) || !strcmp(NamePlayer(i),OWNER_SERVER2,true)) return true;
			GetPlayerIp(i,ips,16);
			if(!strcmp(ips, ip)) {
				Ban(i);
				strin = "";
				format(strin,92,"Hacker!, IP: %s :: %s [%d]",ip, NamePlayer(i), i);
				SendAdminMessage(COLOR_LIGHTRED,strin);
				break;
			}
		}
	}
	return 1;
}
public OnPlayerCommandText(playerid, cmdtext[]) {
	return true;
}
public OnPlayerCommandReceived(playerid, cmdtext[]) {
	if(!IsPlayerConnected(playerid) || !PlayerLogged[playerid]) return true;
	return true;
}
public OnPlayerCommandPerformed(playerid, cmdtext[], success) {
	if(success == -1) return SendClientMessage(playerid, COLOR_GREY, "Данная команда не найдена, используйте /help.");
	return true;
}

public OnPlayerUpdate(playerid) {
	GetAnimationName(GetPlayerAnimationIndex(playerid), animlib[playerid], sizeof(animlib), animname[playerid], sizeof(animname));
	if(SpeedVehicle(playerid) > 60 && strcmp(animlib[playerid], "SWIM", true) == 0 && strcmp(animname[playerid], "SWIM_crawl", true) == 0) {
		if(PI[playerid][pAdmLevel] == 0 && AdminLogged[playerid] == false) NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (#1106)");
	}
	if(IsAGreenZone(playerid) && !(GetPlayerWeapon(playerid) >= 0 && GetPlayerWeapon(playerid) <= 9) && !IsACop(playerid)) SetPlayerArmedWeapon(playerid,0);
	if(GetPlayerWeapon(playerid) == 0 && PlayerLogged[playerid] == true && !IsPlayerInAnyVehicle(playerid))
	if(isPlayingBasketBall(playerid)) SetPlayerArmedWeapon(playerid,0);
	if(BunnyUse[playerid] && !IsPlayerInAnyVehicle(playerid)) {
		if(strcmp(animname[playerid], "JUMP_LAND", true) == 0)
		{
			BunnyUse[playerid] = false;
			TogglePlayerControllable(playerid, 0);
			TogglePlayerControllable(playerid, 1);
			ApplyAnimation(playerid,"PED","getup_front", 7.0, 0, 0, 0, 0, 0);
		}
	}
	for(new d; d < sizeof(Derevo); d++) {
		new Float:DerevoPos[3];
		GetDynamicObjectPos(gDerevo[d], DerevoPos[0], DerevoPos[1], DerevoPos[2]);
		if(GetPVarInt(playerid, "LessPil") != 0 && IsPlayerInRangeOfPoint(playerid, 1.5, DerevoPos[0], DerevoPos[1], DerevoPos[2])) {
			if(GetPVarInt(playerid,"_idDerevoPos") != d)
			SetPVarInt(playerid,"_idDerevoPos",d), SendClientMessage(playerid, COLOR_GREY, "(( Чтобы срубить дерево нажимайте на ЛКМ ))");
		}
	}
	new anim = GetPlayerAnimationIndex(playerid);
	if(anim != 0) {
		if(UsingShield[playerid])
		{
			if(anim != 1274 && anim != 28 && !ResetShield[playerid]) {
				SetPlayerAttachedObject(playerid, 6, 18637, 1, 0.15, -0.05, 0.18, 90, 0, 270);
				UsingShield[playerid] = false;
				ClearAnimations(playerid);
				HideSHBarForPlayer(playerid);
			}
			if(ResetShield[playerid] > 0) ResetShield[playerid] --;
		}
	}
	if(GotoInfo[playerid][gtID] != INVALID_PLAYER_ID) {
		new cuffed = GotoInfo[playerid][gtID];
		if(!IsPlayerConnected(cuffed) || !PlayerLogged[cuffed])
		{
			GotoInfo[playerid][gtID] = INVALID_PLAYER_ID;
			GotoInfo[playerid][gtTPX] = 0.0;
			GotoInfo[playerid][gtTPY] = 0.0;
			GotoInfo[playerid][gtTPZ] = 0.0;
			GotoInfo[cuffed][gtState] = 0;
			GotoInfo[cuffed][gtStayed] = 0;
			GotoInfo[cuffed][gtGoID] = INVALID_PLAYER_ID;
			GotoInfo[cuffed][gtX] = 0.0;
			GotoInfo[cuffed][gtY] = 0.0;
			GotoInfo[cuffed][gtZ] = 0.0;
		}
	}
	else if(GotoInfo[playerid][gtGoID] != INVALID_PLAYER_ID) {
		new goid = GotoInfo[playerid][gtGoID];
		if(IsPlayerConnected(goid) && PlayerLogged[goid])
		{
			new Float:xX, Float:xY, Float:xZ;
			GetPlayerPos(goid, xX, xY, xZ);
			new PLAYER_STATE = GetPlayerState(goid);
			if(PLAYER_STATE != GotoInfo[playerid][gtState]) {
				switch(PLAYER_STATE) {
				case PLAYER_STATE_ONFOOT: {
						RemovePlayerFromVehicle(playerid);
						GotoInfo[playerid][gtState] = PLAYER_STATE_ONFOOT;
					}
				case PLAYER_STATE_DRIVER: {
						new vehid = GetPlayerVehicleID(goid);
						if(PlayerSeatedToVehicle(playerid, vehid))
						{
							GotoInfo[playerid][gtState] = PLAYER_STATE_DRIVER;
						}
					}
				case PLAYER_STATE_PASSENGER: {
						new vehid = GetPlayerVehicleID(goid);
						if(PlayerSeatedToVehicle(playerid, vehid))
						{
							GotoInfo[playerid][gtState] = PLAYER_STATE_PASSENGER;
						}
					}
				default: {
						GotoInfo[playerid][gtGoID] = INVALID_PLAYER_ID;
						GotoInfo[playerid][gtX] = 0.0;
						GotoInfo[playerid][gtY] = 0.0;
						GotoInfo[playerid][gtZ] = 0.0;
					}
				}
			}
			else {
				new ANIMATION;
				if(GotoInfo[goid][gtTPX] != 0.0 || GotoInfo[goid][gtTPY] != 0.0) {
					SetPlayerFaceToPoint(playerid, GotoInfo[goid][gtTPX], GotoInfo[goid][gtTPY]);
					ANIMATION = GoPlayerAnimation(playerid, GotoInfo[goid][gtTPX], GotoInfo[goid][gtTPY], GotoInfo[goid][gtTPZ]);
				}
				else {
					TurnPlayerFaceToPlayer(playerid, goid);
					ANIMATION = GoPlayerAnimation(playerid, xX, xY, xZ);
				}
				if(ANIMATION != 1) {
					if(IsPlayerInRangeOfPoint(playerid, 0.05, GotoInfo[playerid][gtX], GotoInfo[playerid][gtY], GotoInfo[playerid][gtZ])) {
						GotoInfo[playerid][gtStayed] ++;
						if(GotoInfo[playerid][gtStayed] >= 10)
						{
							new Float:xA;
							GetPlayerPos(playerid, xX, xY, xZ);
							GetPlayerFacingAngle(playerid, xA);
							ShiftCords(0, xX, xY, xZ, xA, 1.5);
							t_SetPlayerPos(playerid, xX, xY, xZ);
							GotoInfo[playerid][gtStayed] = 0;
						}
					}
					else GotoInfo[playerid][gtStayed] = 0;
					GetPlayerPos(playerid, GotoInfo[playerid][gtX], GotoInfo[playerid][gtY], GotoInfo[playerid][gtZ]);
				}
			}
		}
		else {
			GotoInfo[playerid][gtGoID] = INVALID_PLAYER_ID;
			GotoInfo[playerid][gtX] = 0.0;
			GotoInfo[playerid][gtY] = 0.0;
			GotoInfo[playerid][gtZ] = 0.0;
		}
	}
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
		new Keys,ud,lr;
		GetPlayerKeys(playerid,Keys,ud,lr);
		if(HOLDING(KEY_CTRL_BACK | KEY_HANDBRAKE))// ПКМ and H
		{
			new target = GetPlayerTargetPlayer(playerid);
			SetPVarInt(playerid, "TargetID", target);
			if(target != INVALID_PLAYER_ID) {
				strin = "";
				format(strin,56,"Действия с %s:",NamePlayer(target));
				SPD(playerid, 1850, 2, strin, "Передать деньги\nПоказать пасспорт\nПоказать лицензии\nПоказать умения оружий", "Выбрать", "Отмена");
			}
		}
	}
	if (GetPVarInt(playerid, "laser")) {
		RemovePlayerAttachedObject(playerid, 0);
		if ((IsPlayerInAnyVehicle(playerid)) || (IsPlayerInWater(playerid))) return 1;
		switch (GetPlayerWeapon(playerid)) {
		case 23: {
				if (IsPlayerAiming(playerid)) {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
						SetPlayerAttachedObject(playerid, 0, 18643, 6,
						0.108249, 0.030232, 0.118051, 1.468254, 350.512573, 364.284240);
					}
					else {
						SetPlayerAttachedObject(playerid, 0, 18643, 6,
						0.108249, 0.030232, 0.118051, 1.468254, 349.862579, 364.784240);
					}
				}
				else {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
						SetPlayerAttachedObject(playerid, 0, 18643, 6,
						0.078248, 0.027239, 0.113051, -11.131746, 350.602722, 362.384216);
					}
					else {
						SetPlayerAttachedObject(playerid, 0, 18643, 6,
						0.078248, 0.027239, 0.113051, -11.131746, 350.602722, 362.384216);
					}
				}
			}
		}
	}
	if(GetPlayerMoney(playerid) > PI[playerid][pCash]) SetMoney(playerid,PI[playerid][pCash]);
	SetPVarInt(playerid, "NewPlayerAmmo", GetPlayerAmmo(playerid));
	if(GetPVarInt(playerid, "NewPlayerAmmo") != GetPVarInt(playerid, "PlayerAmmo")) {
		if(GetPVarInt(playerid, "NewPlayerAmmo") >= 0 && GetPVarInt(playerid, "NewPlayerAmmo") <= 1) SetPVarInt(playerid, "GunCheck", gettime() + 2);
		OnPlayerAmmoChange(playerid, GetPVarInt(playerid, "NewPlayerAmmo"), GetPVarInt(playerid, "PlayerAmmo"));
		SetPVarInt(playerid, "PlayerAmmo", GetPVarInt(playerid, "NewPlayerAmmo"));
	}
	SetPVarInt(playerid,"AFK_Tick", GetPVarInt(playerid,"AFK_Tick") + 1);
	//
	if(GetPVarInt(playerid, "HealDeath") > 0)
	if(!PlayerToKvadrat(playerid,-2601.8850,-1630.6324,-2632.4309,-1658.8185) && GetPlayerVirtualWorld(playerid) != 1) SetPVarInt(playerid, "HealDeath", 0);

	//
	if(GetPVarInt(playerid, "MedHealPlay") > 0) {
		if(!PlayerToKvadrat(playerid,-2601.8850,-1630.6324,-2632.4309,-1658.8185) && GetPlayerVirtualWorld(playerid) != 1)
		{
			if(GetPVarInt(playerid, "MedHealPlay") > 0) {
				SendClientMessage(playerid, COLOR_GREY, "Вы были выписаны.");
				new i = GetPVarInt(playerid, "MedHealPlace")-1;
				StatusMedHeal[i] = false;
				UpdateDynamic3DTextLabelText(MedHealText3D[i],0xD1B221FF,"<< Койка свободена! >>\nНажмите \"F\" что бы занять");
				DeletePVar(playerid, "MedHealPlay"),DeletePVar(playerid, "MedHealTime"),DeletePVar(playerid, "MedHealPlace");
			}
		}
		SetPVarInt(playerid, "MedHealTime", GetPVarInt(playerid, "MedHealTime")+1);
		if(GetPVarInt(playerid, "MedHealTime") > 30)
		{
			ChatBubbleMe(playerid, "+2");
			strin = "";
			format(strin,30,"~g~+2");
			GameTextForPlayer(playerid,strin,2000,6);
			new Float:shealth;
			GetPlayerHealth(playerid, shealth);
			if(shealth >= 100) {
				SendClientMessage(playerid, COLOR_GREY, "Вы были выписаны.");
				new i = GetPVarInt(playerid, "MedHealPlace")-1;
				StatusMedHeal[i] = false;
				UpdateDynamic3DTextLabelText(MedHealText3D[i],0xD1B221FF,"<< Койка свободена! >>\nНажмите \"F\" что бы занять");
				DeletePVar(playerid, "MedHealPlay"),DeletePVar(playerid, "MedHealTime"),DeletePVar(playerid, "MedHealPlace");
			}
			SetHealth(playerid, shealth+2);
			GetPlayerHealth(playerid, shealth);
			SetPVarInt(playerid, "MedHealTime", GetPVarInt(playerid, "MedHealTime")-29);
			if(shealth > 100) {
				SetHealth(playerid, 100);
				SendClientMessage(playerid, COLOR_GREY, "Вы были выписаны.");
				new i = GetPVarInt(playerid, "MedHealPlace")-1;
				StatusMedHeal[i] = false;
				UpdateDynamic3DTextLabelText(MedHealText3D[i],0xD1B221FF,"<< Койка свободена! >>\nНажмите \"F\" что бы занять");
				DeletePVar(playerid, "MedHealPlay"),DeletePVar(playerid, "MedHealTime"),DeletePVar(playerid, "MedHealPlace");
			}
		}
	}
	if(Fishjob[playerid] > 0) {
		spect = "";
		format(spect,24,"FISH: %dKG",PlayerFish[playerid]);
		TextDrawSetString(FishDraw[playerid],spect);
	}
	else TextDrawHideForPlayer(playerid, FishDraw[playerid]);
	// Ферма №2
	if(GetPVarInt(playerid,"Garden") > 0) {
		spect = "";
		format(spect,32,"AMOUNT: %d KG",AmmountWood[playerid]);
		TextDrawSetString(GardenDraw[playerid],spect);
	}
	else TextDrawHideForPlayer(playerid, GardenDraw[playerid]);
	if(Fishjob[playerid] > 0) {
		spect = "";
		format(spect,24,"FISH: %dKG",PlayerFish[playerid]);
		TextDrawSetString(FishDraw[playerid],spect);
	}
	else TextDrawHideForPlayer(playerid, FishDraw[playerid]);
	// Грузчики
	if(GetPVarInt(playerid,"Gruz") > 0) {
		spect = "";
		format(spect,24,"AMOUNT: %d",PI[playerid][pJobAmount][1]);
		TextDrawSetString(AmountDraw[playerid],spect);
		if(!strcmp(animlib[playerid], "PED", true) && !strcmp(animname[playerid], "FALL_GLIDE", true) && GetPVarInt(playerid,"GruzYes") == 1)
		{
			SendClientMessageEx(playerid, COLOR_RED, "Вы уронили мешок, попробуйте еще раз!");
			if(TOTALGRUZ <= 0) {
				DisablePlayerCheckpoint(playerid);
				RemovePlayerAttachedObject(playerid,2);
				ClearAnimations(playerid);
				ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
				SendClientMessage(playerid, COLOR_GREY, "В вагонах больше нет мешков!");
				return 1;
			}
			DisablePlayerCheckpoint(playerid);
			RemovePlayerAttachedObject(playerid,2);
			SetPlayerCheckpoint(playerid,2042.6589,-1958.3080,14.3957,1.4);
			SetPVarInt(playerid, "GruzYes",0);
			ClearAnimations(playerid);
			ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
		}
	}
	else TextDrawHideForPlayer(playerid, AmountDraw[playerid]);
	// Шахта
	if(GetPVarInt(playerid,"Miner") > 0) {
		spect = "";
		format(spect,32,"AMOUNT: %d KG",PI[playerid][pJobAmount][0]);
		TextDrawSetString(MinerDraw[playerid],spect);
	}
	else TextDrawHideForPlayer(playerid, MinerDraw[playerid]);
	// Лесопилка
	if(GetPVarInt(playerid,"LessPil") > 0) {
		if(GetPVarInt(playerid,"LessProc") > 100) return 1;
		spect = "";
		format(spect,24,"PROCENT: %d%",GetPVarInt(playerid,"LessProc"));
		TextDrawSetString(ProcentDraw[playerid],spect);

		spect = "";
		format(spect,24,"AMOUNT: %d KG",PI[playerid][pJobAmount][2]);
		TextDrawSetString(AmountLDraw[playerid],spect);
	}
	else {
		TextDrawHideForPlayer(playerid, ProcentDraw[playerid]);
		TextDrawHideForPlayer(playerid, AmountLDraw[playerid]);
	}
	if(GetPVarInt(playerid,"LessProc") >= 100) {
		MoveObject(gDerevo[GetPVarInt(playerid,"Derevo")],Derevo[GetPVarInt(playerid, "Derevo")][0],Derevo[GetPVarInt(playerid, "Derevo")][1],Derevo[GetPVarInt(playerid, "Derevo")][2]+0.004,0.004, 0.00000000,90.00000000,0.00000000);
		SetPVarInt(playerid, "LessProc", 0);
		TextDrawHideForPlayer(playerid, ProcentDraw[playerid]);
		DerevoTimer[playerid] = SetTimerEx("GatDerevo",2000,false,"i",playerid);
	}
	if(GetPVarInt(playerid,"Animation") > 0) TextDrawSetString(AnimDraw[playerid],"Stop Animation - SPACE");
	else TextDrawHideForPlayer(playerid, AnimDraw[playerid]);
	return 1;
}
public OnPlayerStreamIn(playerid, forplayerid) {
	Iter_Add(StreamedPlayers[forplayerid],playerid);
	return true;
}

public OnPlayerStreamOut(playerid, forplayerid) {
	Iter_Remove(StreamedPlayers[forplayerid],playerid);
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	if(GetPVarInt(playerid,"DialogID") != dialogid) return NewKick(playerid,"[Античит]: Вы кикнуты по подозрению в читерстве (#1115)");
	new params[64];
	if(strfind(inputtext,"%",true)!=-1)
	strdel(inputtext,strfind(inputtext,"%",true),strfind(inputtext,"%",true)+2);
	switch(dialogid) {
	case 1: {
			if(response) {
				if(strfind(inputtext,"|") != -1) return SPD(playerid, 1, DIALOG_STYLE_PASSWORD, "{96e300}Пароль", "{ffffff}Введите пароль:", "Готово", "Закрыть");
				if(IsTextRussian(inputtext)) return SPD(playerid, 1, DIALOG_STYLE_PASSWORD, "{96e300}Пароль", "{ffffff}Введите пароль:", "Готово", "Закрыть");
				if(strlen(inputtext) < 6 || strlen(inputtext) > 16) return SPD(playerid, 1, DIALOG_STYLE_PASSWORD, "{96e300}Пароль", "{ffffff}Введите пароль:", "Готово", "Закрыть");
				KillTimer(EnterTimer[playerid]);
				SetPVarString(playerid,"RegPass",inputtext);
				PlayerRegister[0][playerid] = 1;
				PlayerTextDrawSetString(playerid,RegDraws[5][playerid],inputtext);
				return 1;
			}
		}
	case 2: {
			if(strfind(inputtext,"|") != -1) return SPD(playerid, 2, DIALOG_STYLE_PASSWORD, "{96e300}Пароль", "{ffffff}Введите пароль:", "Готово", "");
			if(IsTextRussian(inputtext)) return SPD(playerid, 2, DIALOG_STYLE_PASSWORD, "{96e300}Пароль", "{ffffff}Введите пароль:", "Готово", "");
			if(strlen(inputtext) < 6 || strlen(inputtext) > 16) return SPD(playerid, 2, DIALOG_STYLE_PASSWORD, "{96e300}Пароль", "{ffffff}Введите пароль:", "Готово", "");
			PlayerTextDrawSetSelectable(playerid, RegDraws[5][playerid], false);
			if(strlen(inputtext) == 6) PlayerTextDrawSetString(playerid,RegDraws[5][playerid],"------");
			if(strlen(inputtext) == 7) PlayerTextDrawSetString(playerid,RegDraws[5][playerid],"-------");
			if(strlen(inputtext) == 8) PlayerTextDrawSetString(playerid,RegDraws[5][playerid],"--------");
			if(strlen(inputtext) == 9) PlayerTextDrawSetString(playerid,RegDraws[5][playerid],"---------");
			if(strlen(inputtext) == 10) PlayerTextDrawSetString(playerid,RegDraws[5][playerid],"---------");
			if(strlen(inputtext) == 11) PlayerTextDrawSetString(playerid,RegDraws[5][playerid],"----------");
			if(strlen(inputtext) == 12) PlayerTextDrawSetString(playerid,RegDraws[5][playerid],"-----------");
			if(strlen(inputtext) == 13) PlayerTextDrawSetString(playerid,RegDraws[5][playerid],"------------");
			if(strlen(inputtext) == 14) PlayerTextDrawSetString(playerid,RegDraws[5][playerid],"-------------");
			if(strlen(inputtext) == 15) PlayerTextDrawSetString(playerid,RegDraws[5][playerid],"--------------");
			if(strlen(inputtext) == 16) PlayerTextDrawSetString(playerid,RegDraws[5][playerid],"---------------");
			KillTimer(EnterTimer[playerid]);
			OnPlayerLoginServer(playerid,inputtext);
			PlayerLogins[0][playerid] = 1;
			PlayerLogins[1][playerid] = 1;
			return 1;
		}
	case 3: {
			if(response) {
				if(strfind(inputtext, "@", true) == -1 || strfind(inputtext, ".", true) == -1 || strlen(inputtext) < 5)
				return SPD(playerid,3,DIALOG_STYLE_INPUT,"{96e300}Почта - Email","{ffffff}Введите Ваш E-Mail адрес:", "Готово", "Закрыть");
				KillTimer(EnterTimer[playerid]);
				EnterTimer[playerid] = SetTimerEx("PlayerKick",240000,false,"d",playerid);
				SetPVarString(playerid,"RegMail",inputtext);
				PlayerRegister[1][playerid] = 1;
				PlayerTextDrawSetString(playerid,RegDraws[6][playerid],inputtext);
			}
		}
	case 4: {
			if(!response) return 1;
			switch(listitem) {
			case 0: {
					PI[playerid][pSex] = 0; //Мужской
					SendClientMessage(playerid,COLOR_GREEN,"Выбран мужской пол.");
					PlayerTextDrawSetString(playerid,RegDraws[7][playerid],"MAN");
				}
			case 1: {
					PI[playerid][pSex] = 1; //Женский
					SendClientMessage(playerid,COLOR_GREEN,"Выбран женский пол.");
					PlayerTextDrawSetString(playerid,RegDraws[7][playerid],"WOMAN");
				}
			}
			KillTimer(EnterTimer[playerid]);
			EnterTimer[playerid] = SetTimerEx("PlayerKick",240000,false,"d",playerid);
			PlayerRegister[2][playerid] = 1;
		}
		//Колхоз
	case 57: {
			if(response) {
				SelectFarmJob[playerid] = listitem + 1;
				FarmData[playerid][0] = 0;
				FarmData[playerid][1] = 0;
				if(listitem == 0) {
					if(Level[playerid] < 1) return SendClientMessage(playerid, -1, "Ваш навык работы на ферме слишком мал (/fskill)");
					//SPD(playerid,58,DIALOG_STYLE_LIST,"Кем работать", "Носить воду\nНосить зерно\nНосить сено","Далее","");
					SPD(playerid,58,DIALOG_STYLE_LIST,"Кем работать", "Носить зерно\nНосить сено","Далее","");
				}
				if(listitem == 1) {
					if(Level[playerid] < 2) return SendClientMessage(playerid, -1, "Ваш навык работы на ферме слишком мал (/fskill)");
					if(OnOneLevelJob[playerid] == 1) return SendClientMessage(playerid, -1, "Вы уже работаете!");
					NullFishJob(playerid);
					DisablePlayerCheckpoint(playerid);
					SetPVarInt(playerid,"TaxiCheck",0);
					SetPVarInt(playerid,"GPS",0);
					SetPVarInt(playerid,"GPSCar",1);
					SetPVarInt(playerid,"YEAH",0);
					SetPVarInt(playerid, "Garden", 0);
					JobTraktor[playerid] = 1;
					OnOneLevelJob[playerid] = 1;
					SetPlayerSkin(playerid, 158);
					SetFarmCheck(playerid);
				}
				if(listitem == 2) {
					if(Level[playerid] < 3) return SendClientMessage(playerid, -1, "Ваш навык работы на ферме слишком мал (/fskill)");
					if(OnOneLevelJob[playerid] == 1) return SendClientMessage(playerid, -1, "Вы уже работаете!");
					NullFishJob(playerid);
					DisablePlayerCheckpoint(playerid);
					SetPVarInt(playerid,"TaxiCheck",0);
					SetPVarInt(playerid,"GPS",0);
					SetPVarInt(playerid,"GPSCar",1);
					SetPVarInt(playerid,"YEAH",0);
					SetPVarInt(playerid, "Garden", 0);
					JobCombine[playerid] = 1;
					OnOneLevelJob[playerid] = 1;
					SetPlayerSkin(playerid, 161);
					SetFarmCheck(playerid);
				}
				if(listitem == 3) {
					if(Level[playerid] < 4) return SendClientMessage(playerid, -1, "Ваш навык работы на ферме слишком мал (/fskill)");
					if(OnOneLevelJob[playerid] == 1) return SendClientMessage(playerid, -1, "Вы уже работаете!");
					NullFishJob(playerid);
					DisablePlayerCheckpoint(playerid);
					SetPVarInt(playerid,"TaxiCheck",0);
					SetPVarInt(playerid,"GPS",0);
					SetPVarInt(playerid,"GPSCar",1);
					SetPVarInt(playerid,"YEAH",0);
					SetPVarInt(playerid, "Garden", 0);
					JobFly[playerid] = 1;
					OnOneLevelJob[playerid] = 1;
					SetPlayerSkin(playerid, 34);
					SetPlayerCheckpoint(playerid, 8.7958,15.6403,3.1172, 2.0);
				}

			}
		}
	case 58: {
			if(response) {
				if(OnOneLevelJob[playerid] == 1) return SendClientMessage(playerid, -1, "Вы уже работаете!");
				UpdateKolhozPlayers(playerid, 1);
				OnOneLevelJob[playerid] = 1;
				NullFishJob(playerid);
				DisablePlayerCheckpoint(playerid);

				if(listitem == 0) {
					SetPVarInt(playerid,"TaxiCheck",0);
					SetPVarInt(playerid,"GPS",0);
					SetPVarInt(playerid,"GPSCar",1);
					SetPVarInt(playerid,"YEAH",0);
					SetPVarInt(playerid, "Garden", 0);
					SetPlayerSkin(playerid, 206);
					SetPlayerCheckpoint(playerid, -69.1939,-36.8022,3.1172, 2.0);
				}
				if(listitem == 1) {
					SetPVarInt(playerid,"TaxiCheck",0);
					SetPVarInt(playerid,"GPS",0);
					SetPVarInt(playerid,"GPSCar",1);
					SetPVarInt(playerid,"YEAH",0);
					SetPVarInt(playerid, "Garden", 0);
					SetPlayerSkin(playerid, 159);
					if(random(2)) SetPlayerCheckpoint(playerid, 8.5415,55.5826,3.1172, 2.0);
					else SetPlayerCheckpoint(playerid, -96.3521,122.7176,3.1096, 2.0);
				}

			}
		}
		//Дом
	case 5: {
			if(response) {
				new idx = GetPVarInt(playerid, "PlayerHouse");
				if(!strcmp(HouseInfo[idx][hOwner],"None",true)) {
					if(CheckNewBank[playerid] != 0) return SendClientMessage(playerid,COLOR_WHITE,"У Вас нет банковского счета!");
					if(PI[playerid][pBank] < HouseInfo[idx][hPrice]) return SendClientMessage(playerid, COLOR_GREY, "На Вашем банковском счету недостаточно средств!");
					else
					{
						new house = 0;
						for(new i = 1; i <= TOTALHOUSE;i++)
						{
							if(!strcmp(HouseInfo[i][hOwner],NamePlayer(playerid),true)) house++;
						}
						if(house != 0) return SendClientMessage(playerid, COLOR_GREY, "У Вас уже есть дом!");
						MinusBankMoney(playerid, HouseInfo[idx][hPrice]);
						MinusBankMoney(playerid, HouseInfo[idx][hPrice]);
						CheckBank(playerid);
						PI[playerid][pHouseMoney] = 0;
						PI[playerid][pHouseDrugs] = 0;
						HouseInfo[idx][hBuyPrice] = HouseInfo[idx][hPrice];
						SendClientMessageEx(playerid, COLOR_WHITE, "Вы купили дом за %i$",HouseInfo[idx][hPrice]);
						SendClientMessageEx(playerid, COLOR_LIGHTRED, "Внимание! Не забывайте пополнять домашний счет");
						strmid(HouseInfo[idx][hOwner],NamePlayer(playerid), 0, strlen(NamePlayer(playerid)), MAX_PLAYER_NAME);
						HouseInfo[idx][hOplata] = 200;
						qurey = "";
						format(qurey, sizeof(qurey), "UPDATE "TABLE_HOUSE" SET hOwner = '%s', buyprice = %i WHERE id = '%d' LIMIT 1", HouseInfo[idx][hOwner], HouseInfo[idx][hBuyPrice], idx);
						mysql_function_query(cHandle, qurey, false, "", "");
						SetHouseInt(idx, "hOplata", HouseInfo[idx][hOplata]);
						t_SetPlayerPos(playerid,HouseInfo[idx][hExitx],HouseInfo[idx][hExity],HouseInfo[idx][hExitz]);
						SetPlayerInterior(playerid,HouseInfo[idx][hInt]);
						SetPlayerVirtualWorld(playerid,HouseInfo[idx][hVirtual]);
						SetPlayerFacingAngle(playerid, -90.0);
						UpdateHouse(idx);
						return true;
					}
				}
				else {
					if(HouseInfo[idx][hLock] == 1) {
						if(strcmp(NamePlayer(playerid), HouseInfo[idx][hOwner], true) == 0) SPD(playerid, 6, 0, "Дом", "Ваш дом закрыт\n\nВы хотите его открыть?", "Да", "Нет");
						GameTextForPlayer(playerid, "~r~Locked", 5000, 1);
					}
					else
					{
						t_SetPlayerPos(playerid,HouseInfo[idx][hExitx],HouseInfo[idx][hExity],HouseInfo[idx][hExitz]);
						SetPlayerInterior(playerid,HouseInfo[idx][hInt]);
						SetPlayerVirtualWorld(playerid,HouseInfo[idx][hVirtual]);
						SetPlayerFacingAngle(playerid, -90.0);
					}
				}
			}
		}
	case 6: {
			if(!response) return 1;
			new i = GetPVarInt(playerid, "PlayerHouse");
			HouseInfo[i][hLock] = 0;
			strin = "";
			format(strin, 16, "~g~unlock");
			PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
			GameTextForPlayer(playerid, strin, 5000, 5);
			strin = "";
			format(strin, 90, "%s открывает замок дома", NamePlayer(playerid));
			ProxDetectorNew(playerid,20.0,COLOR_PURPLE,strin);
			SetHouseInt(i, "hLock", HouseInfo[i][hLock]);
			return 1;
		}
	case DIALOG_HOUSE: {
			if(!response) return 1;
			new h = GetPVarInt(playerid, "PlayerHouse");
			switch(listitem) {
			case 0: {
					if(HouseInfo[h][hLock] == 1) {
						HouseInfo[h][hLock] = 0;
						strin = "";
						strin = "";
						format(strin, 16, "~g~unlock");
						PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
						GameTextForPlayer(playerid, strin, 5000, 5);
						strin = "";
						format(strin, 90, "%s открывает замок дома", NamePlayer(playerid));
						ProxDetectorNew(playerid,20.0,COLOR_PURPLE,strin);
						SetHouseInt(h, "hLock", HouseInfo[h][hLock]);
					}
					else {
						if(HouseInfo[h][hLock] == 1) return SendClientMessage(playerid, COLOR_GREY, "Ваш дом уже закрыт!");
						HouseInfo[h][hLock] = 1;
						strin = "";
						strin = "";
						format(strin, 16, "~r~lock");
						PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
						GameTextForPlayer(playerid, strin, 5000, 5);
						strin = "";
						format(strin, 90, "%s закрывает замок дома", NamePlayer(playerid));
						ProxDetectorNew(playerid,20.0,COLOR_PURPLE,strin);
						SetHouseInt(h, "hLock", HouseInfo[h][hLock]);
					}
				}
			case 1: SPD(playerid, DIALOG_HOUSE+2, 2, "Улучшения дома", "1. Автоматическийх выход\n2. Субсидии(-50% кварплаты)\n3. Аптечка в доме\n4. Сейф\n5. Гараж", "Далее", "Отмена");//\n5. Шкаф
			case 2: {
					new htax;
					if(!HouseInfo[h][hGrant]) {
						if(!strcmp("E",HouseInfo[h][hDiscript],true)) htax = 100;
						if(!strcmp("C",HouseInfo[h][hDiscript],true)) htax = 150;
						if(!strcmp("B",HouseInfo[h][hDiscript],true)) htax = 250;
						if(!strcmp("A",HouseInfo[h][hDiscript],true)) htax = 300;
						if(!strcmp("S",HouseInfo[h][hDiscript],true)) htax = 700;
					}
					else {
						if(!strcmp("E",HouseInfo[h][hDiscript],true)) htax = 100/2;
						if(!strcmp("C",HouseInfo[h][hDiscript],true)) htax = 150/2;
						if(!strcmp("B",HouseInfo[h][hDiscript],true)) htax = 250/2;
						if(!strcmp("A",HouseInfo[h][hDiscript],true)) htax = 300/2;
						if(!strcmp("S",HouseInfo[h][hDiscript],true)) htax = 700/2;
					}
					strin = "";
					format(strin,sizeof(strin),"{ffffff}На счету дома\t\t\t{8ce304}%d${ffffff}\nОплата в час\t\t\t{8ce304}%d${ffffff}\nГос.Цена\t\t\t{8ce304}%d${ffffff}\n\nВыход на ALT\t\t\t%s{ffffff}\nСубсидии\t\t\t%s{ffffff}\nАптечка\t\t\t%s\nСейф\t\t\t%s",
					HouseInfo[h][hOplata],htax,HouseInfo[h][hBuyPrice],(!HouseInfo[h][hOutput]) ? ("{FF6347}Нет"):("{9ACD32}Да"),(!HouseInfo[h][hGrant]) ? ("{FF6347}Нет"):("{9ACD32}Да"),(!HouseInfo[h][hMedicine]) ? ("{FF6347}Нет"):("{9ACD32}Да"),(!HouseInfo[h][hSafe]) ? ("{FF6347}Нет"):("{9ACD32}Да"));
					SPD(playerid, 0, 0, "Информация", strin, "Закрыть", "");
				}
			case 3: {
					new i = GetPVarInt(playerid, "PlayerHouse");
					if(GetPlayerHouse(playerid) == 0) return SendClientMessage(playerid, COLOR_GREY, "У Вас нет дома!");
					if(GetPlayerVirtualWorld(playerid) != HouseInfo[i][hVirtual]) return SendClientMessage(playerid, COLOR_GREY, "Вы должны находится у себя в доме!");
					new drugs = PI[playerid][pHouseDrugs];
					new money = PI[playerid][pHouseMoney];
					if(HouseInfo[i][hSafe] == 0) return SendClientMessage(playerid,COLOR_GREY,"В вашем доме не установлен сейф!");
					if(strcmp(NamePlayer(playerid),HouseInfo[i][hOwner],true) == 0) {
						if(IsPlayerInRangeOfPoint(playerid, 15.0, HouseInfo[i][hExitx], HouseInfo[i][hExity], HouseInfo[i][hExitz]))
						{
							strin = "";
							format(strin, 200, "{FFFFFF}Деньги: {6495ED}\t\t%d из 2.000.000$\n{FFFFFF}Наркотики: {6495ED}\t\t%d из 2.000 грамм", money, drugs);
							SPD(playerid, 81, 0,"{FFFFFF}Сейф",strin,"Далее","Закрыть");
						}
						else SendClientMessage(playerid, COLOR_GREY, "Вы должны находится у себя в доме!");
					}
				}
			case 4: {
					if(GetPlayerHouse(playerid) == 0) return SendClientMessage(playerid, COLOR_GREY, "У Вас нет дома!");
					new i = GetPVarInt(playerid, "PlayerHouse");
					if(GetPlayerVirtualWorld(playerid) != HouseInfo[i][hVirtual]) return SendClientMessage(playerid, COLOR_GREY, "Вы должны находится у себя в доме!");
					if(HouseInfo[i][hLocker] == 0) return SendClientMessage(playerid,COLOR_GREY,"В вашем доме не установлен гараж!");
					if(strcmp(NamePlayer(playerid),HouseInfo[i][hOwner],true) == 0) {
						if(IsPlayerInRangeOfPoint(playerid, 15.0, HouseInfo[i][hExitx], HouseInfo[i][hExity], HouseInfo[i][hExitz]))
						{
							TogglePlayerControllable(playerid, 0);
							SetTimerEx("Unfreez",3500,false,"i",playerid);
							SendClientMessage(playerid, COLOR_PAYCHEC, "ПОДСКАЗКА: Чтобы открыть меню гаража (( Введите /gpanel ))");
							t_SetPlayerPos(playerid, 870.8230,709.0129,1039.8203);
							SetPlayerFacingAngle(playerid, 23.3237);
							SetPlayerInterior(playerid, 7);
							SetPlayerVirtualWorld(playerid, playerid);
						}
						else SendClientMessage(playerid, COLOR_GREY, "Вы должны находится у себя в доме!");
					}
				}
			case 5: SPD(playerid, DIALOG_HOUSE+1, 0, "Продать дом", "Вы действительно хотите продать свой дом?", "Да", "Нет");
			}
		}
	case DIALOG_HOUSE+1: {
			if(response) {
				new h = GetPVarInt(playerid, "PlayerHouse");
				strmid(HouseInfo[h][hOwner], "None", 0, strlen("None"), MAX_PLAYER_NAME);
				HouseInfo[h][hLock] = 0;
				SetHouseStr(h, "hOwner", "None");
				HouseInfo[h][hOplata] = 0;
				HouseInfo[h][hOutput] = 0;
				HouseInfo[h][hGrant] = 0;
				HouseInfo[h][hMedicine] = 0;
				SendClientMessage(playerid, COLOR_LIGHTRED, "Вы продали свой дом!");
				UpdateHouse(h);
				PlusBankMoney(playerid, HouseInfo[h][hBuyPrice]), CheckBank(playerid);
				query = "";
				format(query, 300, "UPDATE "TABLE_HOUSE" SET  hOwner = '%s', hLock = %d, hOplata = %d, hOutput = '0', hGrant = '0', hMedicine = '0' WHERE id = %d LIMIT 1", HouseInfo[h][hOwner], HouseInfo[h][hLock], HouseInfo[h][hOplata],h);
				mysql_function_query(cHandle, query, false, "", "");
				//DestroyVehicleEx(GetPVarInt(playerid,"MyCarID"));//,DestroyDynamicObject(NeonObject[0][playerid]),DestroyDynamicObject(NeonObject[1][playerid]);
			}
		}
	case DIALOG_HOUSE+2: {
			if(!response) return 1;
			switch(listitem) {
			case 0: SPD(playerid, DIALOG_HOUSE+3, 0, "Автоматическийх выход", "{ffffff}При покупки данного улучшения\nвыходить из дома можно используя клавишу {ff0000}ALT{ffffff}\nЦена: 10000$", "Купить", "Отмена");
			case 1: SPD(playerid, DIALOG_HOUSE+4, 0, "Субсидии", "{ffffff}При покупки данного улучшения\nВаша квартплата уменшится на 50%\nЦена: 30000$", "Купить", "Отмена");
			case 2: SPD(playerid, DIALOG_HOUSE+5, 0, "Аптечка в доме", "{ffffff}При покупки данного улучшения\nу Вас в доме появится аптечка (сердечко).\nЦена: 15000$", "Купить", "Отмена");
			case 3: SPD(playerid, DIALOG_HOUSE+6, 0, "Сейф", "{ffffff}При покупки данного улучшения\nв Вашем доме появится сейф, в который\nВы сможете ложить оружие, наркотики, деньги.\nЦена: 20000$", "Купить", "Отмена");
			case 4: SPD(playerid, DIALOG_HOUSE+7, 0, "Гараж", "{ffffff}При покупки данного улучшения\nу Вас появится гараж!\n\nЦена: 30000$", "Купить", "Отмена");
			}
		}
	case DIALOG_HOUSE+3: {
			if(!response) return 1;
			new h = GetPVarInt(playerid, "PlayerHouse");
			if(HouseInfo[h][hOutput] > 0) return SendClientMessage(playerid, COLOR_GREY, "У вас уже есть данное улучшение.");
			if(GetMoney(playerid) < 10000) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
			SendClientMessage(playerid, COLOR_LIGHTRED, "Вы улучшили свой дом, теперь у Вас есть автоматический выход!");
			HouseInfo[h][hOutput] = 1;
			SetHouseInt(h, "hOutput", HouseInfo[h][hOutput]);
			GiveMoney(playerid, -10000);
			UpdateHouse(h);
		}
		//
	case DIALOG_HOUSE+4: {
			if(!response) return 1;
			new h = GetPVarInt(playerid, "PlayerHouse");
			if(HouseInfo[h][hGrant] > 0) return SendClientMessage(playerid, COLOR_GREY, "У вас уже есть данное улучшение.");
			if(GetMoney(playerid) < 30000) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
			SendClientMessage(playerid, COLOR_LIGHTRED, "Вы улучшили свой дом, теперь у Вас есть субсидии.");
			HouseInfo[h][hGrant] = 1;
			SetHouseInt(h, "hGrant", HouseInfo[h][hGrant]);
			GiveMoney(playerid, -30000);
			UpdateHouse(h);
		}
		// Аптечка в дом
	case DIALOG_HOUSE+5: {
			if(!response) return 1;
			new h = GetPVarInt(playerid, "PlayerHouse");
			if(HouseInfo[h][hMedicine] > 0) return SendClientMessage(playerid, COLOR_GREY, "У вас уже есть данное улучшение.");
			if(GetMoney(playerid) < 15000) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
			SendClientMessage(playerid, COLOR_LIGHTRED, "Вы улучшили свой дом, теперь у Вас есть аптечка!");
			HouseInfo[h][hMedicine] = 1;
			SetHouseInt(h, "hMedicine", HouseInfo[h][hMedicine]);
			GiveMoney(playerid, -15000);
			UpdateHouse(h);
		}
	case DIALOG_HOUSE+6: {
			if(!response) return 1;
			new h = GetPVarInt(playerid, "PlayerHouse");
			if(HouseInfo[h][hSafe] > 0) return SendClientMessage(playerid, COLOR_GREY, "У вас уже есть данное улучшение.");
			if(GetMoney(playerid) < 20000) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
			SendClientMessage(playerid, COLOR_LIGHTRED, "Вы улучшили свой дом, теперь у Вас есть сейф!");
			HouseInfo[h][hSafe] = 1;
			SetHouseInt(h, "hSafe", HouseInfo[h][hSafe]);
			GiveMoney(playerid, -20000);
			UpdateHouse(h);
		}
	case DIALOG_HOUSE+7: {
			if(!response) return 1;
			if(GetMoney(playerid) < 30000) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
			new h = GetPVarInt(playerid, "PlayerHouse");
			SendClientMessage(playerid, COLOR_LIGHTRED, "Вы улучшили свой дом, теперь у Вас есть гараж!");
			HouseInfo[h][hLocker] = 1;
			SetHouseInt(h, "hLocker", HouseInfo[h][hLocker]);
			GiveMoney(playerid, -30000);
			UpdateHouse(h);
		}
	case 10: {
			if(!response) return 1;
			if(!strlen(inputtext)) return SPD(playerid, 10, 1, "Авторизация", "Введите пароль администратора:", "Принять", "Отмена");
			if(strlen(inputtext) < 1 || strlen(inputtext) > 32) return SPD(playerid, 10, 1, "Авторизация", "Введите пароль администратора:", "Принять", "Отмена");
			if(strcmp(inputtext, PI[playerid][pAdmKey], true)) SendClientMessage(playerid, COLOR_LIGHTRED, "Не верно введен пароль администратора!"), Kick(playerid);
			else {
				strin = "";
				format(strin, 90, "[A] %s (ID: %i) авторизовался(ась) как администратор", NamePlayer(playerid), playerid);
				SendAdminMessage(COLOR_LIGHTRED, strin);
				AdminLogged[playerid] = true;
			}

		}
		// Команда /add
	case 11: {
			if(response) {
				switch(listitem) {
				case 0: {
						GetPlayerPos(playerid, PI[playerid][pPos][0],PI[playerid][pPos][1],PI[playerid][pPos][2]);
						VehTest[playerid] = CreateVehicleEx(426, PI[playerid][pPos][0],PI[playerid][pPos][1],PI[playerid][pPos][2], 0.0, random(10), 0, 10000);
						Fuel[VehTest[playerid]] = 200;
						PutPlayerInVehicleEx(playerid, VehTest[playerid], 0);
						SendClientMessageEx(playerid, COLOR_LIGHTRED, "Тест транспорт создан. Установить координаты: /tpc");
						SetPVarInt(playerid,"addhome",1);
					}
				case 1: SPD(playerid, 14, 2, "Добавить бизнес", "Магазин 24/7\nЗаправка\nПиццерия\nЗакусочная (Burger Shot)\nЗакусочная (Cluckin Bell)\nКлуб (Alhambra)\nКлуб (Jizzy)\nКлуб (Pig Pen)\nБар (Misty)", "Принять", "Отмена");
				case 2: SPD(playerid, 15, 1, "Добавить пикап", "Модель , Тип , Имя\nПример: 1318 , 1, SAPD","Принять", "Отмена");
				}
			}
			return 1;
		}
	case 12: {
			if(response) {
				new price,type;
				if(sscanf(inputtext,"p<,>ii",price,type)) {
					strin = "";
					strcat(strin,"ВАЖНО: Цена , Тип интерьера\n\nПример: 100000,1\n\n");
					strcat(strin,"1. Класс: A\t12. Класс: C\n");
					strcat(strin,"2. Класс: A\t13. Класс: C\n");
					strcat(strin,"3. Класс: A\t14. Класс: C\n");
					strcat(strin,"4. Класс: A\t15. Класс: C\n");
					strcat(strin,"5. Класс: A\t16. Класс: C\n");
					strcat(strin,"6. Класс: A\t17. Класс: C\n");
					strcat(strin,"7. Класс: B\t18. Класс: E\n");
					strcat(strin,"8. Класс: B\t19. Класс: E\n");
					strcat(strin,"9. Класс: B\t20. Класс: E\n");
					strcat(strin,"10. Класс: C\t21. Класс: E\n");
					strcat(strin,"11. Класс: C\n");
					return SPD(playerid,12,1,"Добавить дом",strin,"Выбрать","Закрыть");
				}
				TOTALHOUSE++;
				GetPlayerPos(playerid,PI[playerid][pPos][0],PI[playerid][pPos][1],PI[playerid][pPos][2]);
				HouseInfo[TOTALHOUSE][hEntrx] = PI[playerid][pPos][0];
				HouseInfo[TOTALHOUSE][hEntry] = PI[playerid][pPos][1];
				HouseInfo[TOTALHOUSE][hEntrz] = PI[playerid][pPos][2];
				strin = "";
				switch(type) {
				case 1:
					format(strin,90,"140.2660,1366.1091,1083.8594,A,5,1");	// A
				case 2:
					format(strin,90,"234.1541,1063.7206,1084.2123,A,6,2");	// A
				case 3:
					format(strin,90,"2317.7983,-1026.7651,1050.2178,A,9,3");	// A
				case 4:
					format(strin,90,"235.2748,1186.6809,1080.2578,A,3,4");	// A
				case 5:
					format(strin,90,"226.2956,1114.1615,1080.9929,A,5,5");	// A
				case 6:
					format(strin,90,"2324.3977,-1149.0601,1050.7101,A,12,6");	// A
				case 7:
					format(strin,90,"2237.5413,-1081.1516,1049.04,B,2,7");	// B
				case 8:
					format(strin,90,"2196.8469,-1204.3524,1049.0234,B,6,8");	// B
				case 9:
					format(strin,90,"2365.3345,-1135.5907,1050.8826,B,8,9");	// B
				case 10:
					format(strin,90,"260.8800,1237.2365,1084.2578,C,9,10");	// C
				case 11:
					format(strin,90,"327.9864,1477.7328,1084.4375,C,15,11");	// C
				case 12:
					format(strin,90,"2282.8831,-1140.0713,1050.8984,C,11,12");	// C
				case 13:
					format(strin,90,"2218.3875,-1076.1580,1050.4844,C,1,13");	// C
				case 14:
					format(strin,90,"226.4436,1239.9277,1082.1406,C,2,14");	// C
				case 15:
					format(strin,90,"261.1874,1284.2982,1080.2578,C,4,15");	// C
				case 16:
					format(strin,90,"2807.6919,-1174.2933,1025.5703,C,8,16");	// C
				case 17:
					format(strin,90,"2233.6965,-1115.1270,1050.8828,C,5,17");	// C
				case 18:
					format(strin,90,"2259.5068,-1135.9337,1050.6328,E,10,18");	// E
				case 19:
					format(strin,90,"244.0883,305.0291,999.1484,E,1,19");	// E
				case 20:
					format(strin,90,"2468.2080,-1698.2988,1013.5078,E,2,20");	// E
				case 21:
					format(strin,90,"266.9498,304.9866,999.1484,E,2,21");	// E
				}
				sscanf(coordh,"p<,>ffff",
				HouseInfo[TOTALHOUSE][hCarx],HouseInfo[TOTALHOUSE][hCary],HouseInfo[TOTALHOUSE][hCarz],HouseInfo[TOTALHOUSE][hCarfa]);

				sscanf(coordexx,"p<,>ffff",
				HouseInfo[TOTALHOUSE][hEx],HouseInfo[TOTALHOUSE][hEy],HouseInfo[TOTALHOUSE][hEz],HouseInfo[TOTALHOUSE][hEp]);

				sscanf(strin,"p<,>fffsii",
				HouseInfo[TOTALHOUSE][hExitx],HouseInfo[TOTALHOUSE][hExity],HouseInfo[TOTALHOUSE][hExitz],
				HouseInfo[TOTALHOUSE][hDiscript],HouseInfo[TOTALHOUSE][hInt],HouseInfo[TOTALHOUSE][hType]);
				HouseInfo[TOTALHOUSE][hVirtual] = TOTALHOUSE;
				HouseInfo[TOTALHOUSE][hPrice] = price;

				strmid(HouseInfo[TOTALHOUSE][hOwner], "None", 0, strlen("None"), MAX_PLAYER_NAME);
				HouseInfo[TOTALHOUSE][hMIcon] = CreateDynamicMapIcon(HouseInfo[TOTALHOUSE][hEntrx], HouseInfo[TOTALHOUSE][hEntry], HouseInfo[TOTALHOUSE][hEntrz], 31, 0,-1,-1,-1,160.0);
				HouseInfo[TOTALHOUSE][hPickup] = CreateDynamicPickup(1273,1, HouseInfo[TOTALHOUSE][hEntrx], HouseInfo[TOTALHOUSE][hEntry], HouseInfo[TOTALHOUSE][hEntrz]);
				strin = "";
				format(strin,1024,"INSERT INTO "TABLE_HOUSE" (id,hEntrx,hEntry,hEntrz,hExitx,hExity,hExitz,hEx,hEy,hEz,hEp,carx,cary,carz,carfa,hDiscript,hPrice,hInt,hType,hVirtual)\
				VALUES (%d,'%f','%f','%f','%f','%f','%f','%f','%f','%f','%f','%f','%f','%f','%f','%s',%d,%d,%d,%d)",
				TOTALHOUSE,
				HouseInfo[TOTALHOUSE][hEntrx],HouseInfo[TOTALHOUSE][hEntry],HouseInfo[TOTALHOUSE][hEntrz],
				HouseInfo[TOTALHOUSE][hExitx],HouseInfo[TOTALHOUSE][hExity],HouseInfo[TOTALHOUSE][hExitz],
				HouseInfo[TOTALHOUSE][hEx],HouseInfo[TOTALHOUSE][hEy],HouseInfo[TOTALHOUSE][hEz],HouseInfo[TOTALHOUSE][hEp],
				HouseInfo[TOTALHOUSE][hCarx],HouseInfo[TOTALHOUSE][hCary],HouseInfo[TOTALHOUSE][hCarz],HouseInfo[TOTALHOUSE][hCarfa],
				HouseInfo[TOTALHOUSE][hDiscript],HouseInfo[TOTALHOUSE][hPrice],HouseInfo[TOTALHOUSE][hInt],HouseInfo[TOTALHOUSE][hType],HouseInfo[TOTALHOUSE][hVirtual]);
				mysql_function_query(cHandle, strin, false, "", "");
				return SendClientMessageEx(playerid,COLOR_ORANGE,"Дом номер %d создан",TOTALHOUSE);
			}
			DeletePVar(playerid, "addhome");
		}
		// Пикапы
	case 15: {
			if(!response) return 1;
			new type, model, name[32];
			if(sscanf(inputtext,"p<,>iis[32]",type,model,name)) return SPD(playerid, 15, 1, "Добавить пикап", "Модель , Тип , Имя\nПример: 1318 , 1, SAPD","Принять", "Отмена");
			GetPlayerPos(playerid, PI[playerid][pPos][0],PI[playerid][pPos][1],PI[playerid][pPos][2]);
			coordc = "";
			format(coordc, sizeof(coordc), "%f, %f, %f, %d, %d, %d, %d, %s", PI[playerid][pPos][0],PI[playerid][pPos][1],PI[playerid][pPos][2], model, type, GetPlayerInterior(playerid),GetPlayerVirtualWorld(playerid), name);
			SendClientMessage(playerid, COLOR_LIGHTRED, "Координаты созданы. Установите выходные координаты: /ppc");
			PPC[playerid] = true;
		}
		// Биз
	case 13: {
			if(!response) return 1;
			new price,name[32];
			if(sscanf(inputtext,"p<,>is[32]",price,name)) return SPD(playerid, 13, 1, "Бизнес", "ВАЖНО: Цена , Название\n\nПРИМЕР: 100000 , Idlewood Gas", "Принять", "Отмена");
			if(price < 1) return SPD(playerid, 13, 1, "Бизнес", "ВАЖНО: Цена , Название\n\nПРИМЕР: 100000 , Idlewood Gas", "Принять", "Отмена");
			TOTALBIZZ++;
			sscanf(coordexxb,"p<,>ffff",
			BizzInfo[TOTALBIZZ][bEx],BizzInfo[TOTALBIZZ][bEy],BizzInfo[TOTALBIZZ][bEz],BizzInfo[TOTALBIZZ][bEp]);
			sscanf(boordh,"p<,>ffffffiiiffff",
			BizzInfo[TOTALBIZZ][bExitx],BizzInfo[TOTALBIZZ][bExity],BizzInfo[TOTALBIZZ][bExitz],
			BizzInfo[TOTALBIZZ][bMenux],BizzInfo[TOTALBIZZ][bMenuy],BizzInfo[TOTALBIZZ][bMenuz],
			BizzInfo[TOTALBIZZ][bInt],BizzInfo[TOTALBIZZ][bMIcon],BizzInfo[TOTALBIZZ][bType],
			BizzInfo[TOTALBIZZ][bINx],BizzInfo[TOTALBIZZ][bINy],BizzInfo[TOTALBIZZ][bINz],BizzInfo[TOTALBIZZ][bINp]);

			GetPlayerPos(playerid,BizzInfo[TOTALBIZZ][bEntrx],BizzInfo[TOTALBIZZ][bEntry],BizzInfo[TOTALBIZZ][bEntrz]);
			strmid(BizzInfo[TOTALBIZZ][bOwner], "None", 0, strlen("None"), MAX_PLAYER_NAME);
			strmid(BizzInfo[TOTALBIZZ][bName], name, 0, strlen(name), MAX_PLAYER_NAME);
			BizzInfo[TOTALBIZZ][bVirtual] = TOTALBIZZ;
			BizzInfo[TOTALBIZZ][bPrice] = price;
			BizzInfo[TOTALBIZZ][bEnter] = 100;
			BizzInfo[TOTALBIZZ][bTill] = 50;
			BizzInfo[TOTALBIZZ][bProduct] = 10000000;
			if(BizzInfo[TOTALBIZZ][bType] > 2) BizzInfo[TOTALBIZZ][bIcon] = CreateDynamicMapIcon(BizzInfo[TOTALBIZZ][bEntrx],BizzInfo[TOTALBIZZ][bEntry],BizzInfo[TOTALBIZZ][bEntrz], BizzInfo[TOTALBIZZ][bMIcon], 0,-1,-1,-1,160.0);
			strin = "";
			if(BizzInfo[TOTALBIZZ][bType] != 2) {
				strin = "";
				format(strin, 90, "<< Бизнес продается >>\nНазвание: %s", BizzInfo[TOTALBIZZ][bName]);
				LABELBIZZ[TOTALBIZZ] = CreateDynamic3DTextLabel(strin,COLOR_YELLOW,BizzInfo[TOTALBIZZ][bEntrx],BizzInfo[TOTALBIZZ][bEntry],BizzInfo[TOTALBIZZ][bEntrz],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
				BizzInfo[TOTALBIZZ][bPickup] = CreatePickup(19132,1, BizzInfo[TOTALBIZZ][bEntrx],BizzInfo[TOTALBIZZ][bEntry],BizzInfo[TOTALBIZZ][bEntrz]);
				BizzInfo[TOTALBIZZ][bPickupExit] = CreatePickup(19134, 1, BizzInfo[TOTALBIZZ][bExitx],BizzInfo[TOTALBIZZ][bExity],BizzInfo[TOTALBIZZ][bExitz], BizzInfo[TOTALBIZZ][bVirtual]);
				BizzInfo[TOTALBIZZ][bMenu] = CreateDynamicCP(BizzInfo[TOTALBIZZ][bMenux],BizzInfo[TOTALBIZZ][bMenuy],BizzInfo[TOTALBIZZ][bMenuz], 1.0,BizzInfo[TOTALBIZZ][bVirtual],BizzInfo[TOTALBIZZ][bInt]);
			}
			else {
				strin = "";
				format(strin, 90, "<< Бизнес продается >>\nНазвание: %s\nЦена за 1 литр - %i долларов", BizzInfo[TOTALBIZZ][bName],BizzInfo[TOTALBIZZ][bTill] / 3);
				LABELBIZZ[TOTALBIZZ] = CreateDynamic3DTextLabel(strin,COLOR_YELLOW,BizzInfo[TOTALBIZZ][bEntrx],BizzInfo[TOTALBIZZ][bEntry],BizzInfo[TOTALBIZZ][bEntrz],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,-1, -1, -1);
			}
			strin = "";
			format(strin, 1024, "INSERT INTO "TABLE_BIZZ" (id, x, y, z, xt, yt, zt,menux,menuy,menuz, vint, virt, owner, name, price, type, icon, INx, INy, INz, INp, Ex, Ey, Ez, Ep) VALUES (%i, '%f', '%f', '%f', '%f', '%f', '%f','%f', '%f', '%f',%i, %i, '%s', '%s', %i, %i, %i, '%f','%f','%f','%f','%f','%f','%f','%f')",
			TOTALBIZZ,BizzInfo[TOTALBIZZ][bEntrx],BizzInfo[TOTALBIZZ][bEntry],BizzInfo[TOTALBIZZ][bEntrz],BizzInfo[TOTALBIZZ][bExitx],BizzInfo[TOTALBIZZ][bExity],BizzInfo[TOTALBIZZ][bExitz], BizzInfo[TOTALBIZZ][bMenux],BizzInfo[TOTALBIZZ][bMenuy],BizzInfo[TOTALBIZZ][bMenuz]
			,BizzInfo[TOTALBIZZ][bInt],BizzInfo[TOTALBIZZ][bVirtual],BizzInfo[TOTALBIZZ][bOwner],BizzInfo[TOTALBIZZ][bName], BizzInfo[TOTALBIZZ][bPrice], BizzInfo[TOTALBIZZ][bType],BizzInfo[TOTALBIZZ][bMIcon],BizzInfo[TOTALBIZZ][bINx],BizzInfo[TOTALBIZZ][bINy],BizzInfo[TOTALBIZZ][bINz],BizzInfo[TOTALBIZZ][bINp]
			,BizzInfo[TOTALBIZZ][bEx],BizzInfo[TOTALBIZZ][bEy],BizzInfo[TOTALBIZZ][bEz],BizzInfo[TOTALBIZZ][bEp]);
			mysql_function_query(cHandle, strin, true, "", "");
			DeletePVar(playerid, "addbizz");
			return SendClientMessageEx(playerid,COLOR_ORANGE,"Бизнес номер %d создан",TOTALBIZZ);
		}
	case 14: {
			if(!response) return 1;
			boordh = "";
			switch(listitem) {
			case 0: format(boordh,sizeof(boordh),"-2240.7820,137.2150,1035.4141,-2237.0664,130.2340,1035.4141,6,0,1,-2238.6067,137.1369,1035.4141,270.5260");
			case 1: format(boordh,sizeof(boordh),"0.0,0.0,0.0,0.0,0.0,0.0,0,0,2,0.0,0.0,0.0,0.0");
			case 2: format(boordh,sizeof(boordh),"372.3061,-133.5236,1001.4922,374.7469,-119.3624,1001.4995,5,29,3,372.3968,-131.5217,1001.4922,356.7069");
			case 3: format(boordh,sizeof(boordh),"362.8425,-75.1392,1001.5078,377.3217,-67.8903,1001.5151,10,10,3,364.4198,-73.8987,1001.5078,313.1765");
			case 4: format(boordh,sizeof(boordh),"364.9063,-11.7721,1001.8516,369.6516,-6.3217,1001.8589,9,14,3,364.8733,-9.5414,1001.8516,359.8869");
			case 5: format(boordh,sizeof(boordh),"493.3561,-24.8449,1000.6797,499.2758,-20.7244,1000.6797,17,48,4,493.4050,-22.1312,1000.6797,356.7769");
			case 6: format(boordh,sizeof(boordh),"-2636.6792,1402.4634,906.4609,-2659.1587,1416.9315,906.2734,3,48,4,-2636.8164,1404.7628,906.4609,353.6436");
			case 7: format(boordh,sizeof(boordh),"1204.7395,-13.8515,1000.9219,1214.1865,-12.9937,1000.9219,2,48,4,1204.8483,-11.4207,1000.9219,3.4271");
			case 8: format(boordh,sizeof(boordh),"501.9752,-67.5652,998.7578,496.4381,-75.5758,998.7578,11,49,5,501.8818,-69.5520,998.7578,182.9454");

			}
			SetPVarInt(playerid,"addbizz",1);
			SendClientMessage(playerid, COLOR_LIGHTRED, "Тип бизнеса выбран. Установите Координаты выхода из бизнеса: /tpb");
		}
		// Команда /menu
	case 19: {
			if(!response) return 1;
			strin = "";
			format(strin,100,"{96e300}Главное меню {4751ff}%s",NamePlayer(playerid));
			SPD(playerid, 20, 2, strin, "1. Инвентарь\n2. Статистика персонажа\n3. Настройки персонажа\n4. Команды сервера\n5. Связь с администрацией\n6. Донат", "Далее", "Отмена");
		}
	case 20://menu
		{
			if(!response) return 1;
			switch(listitem) {
			case 0: cmd::inv(playerid, "");
			case 1: Stats(playerid, playerid);
			case 2: {
					strin = "";
					format(strin, 126, "Чат фракции\t\t%s\nОчистить чат\nСмена пола\nСмена ника",(!SendFamily[playerid]) ? ("{9ACD32}Включить") : ("{FF6347}Выключить"));
					SPD(playerid, 22, 2, "Настройки персонажа", strin, "Принять", "Отмена");
				}
			case 3: SPD(playerid, 21, DIALOG_STYLE_LIST, "Команды сервера", "Получить описание\nОбщие команды\nКоманды администрации\nКоманды хелперов\nКоманды работы\nКоманды правительства\nКоманды Полиции и ФБР\nКоманды бандитов\nКоманды репортеров\nКоманды лицензеров\nЛидерские команды\nКоманды личного авто", "Далее", "Отмена");
			case 4: SPD(playerid, 24 , DIALOG_STYLE_LIST, "Связь с администрацией", "Репорт\nВопрос", "Далее", "Отмена");
			case 5: {
					static str_title[64]; format(str_title,sizeof(str_title),"{96e300}Донат {4751ff}| {96e300}[У вас: %d монет]",PI[playerid][pDonateCash]);
					SPD(playerid, 5124, DIALOG_STYLE_LIST, str_title, "{ffffff}Активировать донат-код\nГде купить монеты?\n \n{96e300}Потратить монеты", "Выбрать", "Отмена");
				}
			}
		}
	case 5124: {
			if(!response) return 1;
			static str_title[64]; format(str_title,sizeof(str_title),"{96e300}Донат {4751ff}| {96e300}[У вас: %d монет]",PI[playerid][pDonateCash]);
			switch(listitem) {
			case 0: cmd::donate(playerid,"");
			case 1: SPD(playerid, 5126, DIALOG_STYLE_MSGBOX, str_title, "{ffffff}Приобрести донат-код Вы можете на нашем сайте - {96e300}"NameSite"\n{ffffff}\t1 рубль = 1 монета", "Назад", "");
			case 3: SPD(playerid, 5125, DIALOG_STYLE_LIST, str_title, "{ffffff}Перевести монеты в игровые\nСнять все предупреждения\t\t{96e300}|{ffffff} 50 монет\nСкиллы оружия на 100%\t\t{96e300}|{ffffff} 70 монет\nКомплект лицензий\t\t\t{96e300}|{ffffff} 100 монет\nПовысить уровень\t\t\t{96e300}|{ffffff} 50 монет", "Выбрать", "Назад");
			}
		}
	case 5125: {
			if(!response) return 1;
			switch(listitem) {
			case 0: {
					if(PI[playerid][pDonateCash] < 1) return SendClientMessage(playerid,-1,"У Вас нет монет!");
					static str_title[64]; format(str_title,sizeof(str_title),"{96e300}Донат {4751ff}| {96e300}[У вас: %d монет]",PI[playerid][pDonateCash]);
					SPD(playerid, 5127, DIALOG_STYLE_INPUT, str_title, "{ffffff}Введите кол-во монет, которое хотите потратить\n\n{ffffff}\t1 монета = 700$", "Обменять", "");
				} // Donate > $
			case 1:{
					if(PI[playerid][pDonateCash] < 100) return SendClientMessage(playerid,-1,"У Вас недостаточно монет!");
					PI[playerid][pDonateCash] -= 100;
					PI[playerid][pWarn] = 0;
					SendClientMessage(playerid,COLOR_PAYCHEC,"Вы успешно сняли все предупреждения за 100 монет!");
					SavePlayer(playerid);
				}
			case 2: {
					if(PI[playerid][pDonateCash] < 70) return SendClientMessage(playerid,-1,"У Вас недостаточно монет!");
					for(new i; i < 6;i++) PI[playerid][pGunSkill][i] = 100;   // skills
					PI[playerid][pDonateCash] -= 70;
					SendClientMessage(playerid,COLOR_PAYCHEC,"Вы успешно улучшили свои скиллы за 70 монет!");
					SavePlayer(playerid);
				}
			case 3: {
					if(PI[playerid][pDonateCash] < 100) return SendClientMessage(playerid,-1,"У Вас недостаточно монет!");
					for(new i; i < 5;i++) PI[playerid][pLic][i] = 1;
					PI[playerid][pDonateCash] -= 100;
					SendClientMessage(playerid,COLOR_PAYCHEC,"Вы успешно купили все лицензии за 100 монет!");
					SavePlayer(playerid);
				}
			case 4: {
					if(PI[playerid][pDonateCash] < 50) return SendClientMessage(playerid,-1,"У Вас недостаточно монет!");
					PI[playerid][pLevel]++;
					SetPlayerScore(playerid,PI[playerid][pLevel]);
					SendClientMessage(playerid,COLOR_PAYCHEC,"Вы успешно повысили уровень за 50 монет!");
					SavePlayer(playerid);
				}   // lvlup
			}
			SavePlayer(playerid);
		}
	case 5127: {
			if(!response) return 1;
			if(!strlen(inputtext) || (!IsNumeric(inputtext))) return SPD(playerid, 5127, DIALOG_STYLE_INPUT, "{96e300}Донат {4751ff}| {96e300}[У вас: 0 монет]", "{ffffff}Введите кол-во монет, которое хотите потратить\n\n{ffffff}\t1 монета = 700$", "Обменять", "");
			if(PI[playerid][pDonateCash] < strval(inputtext)) return SendClientMessage(playerid, -1, "У вас недостаточно монет.");
			PI[playerid][pDonateCash] -= strval(inputtext);
			new DonateMoneyToCash = strval(inputtext)*700;
			GiveMoney(playerid,DonateMoneyToCash);
			static str_donate[128];
			format(str_donate,sizeof(str_donate),"Вы успешно обменяли %d монет на %d$",strval(inputtext),DonateMoneyToCash);
			SendClientMessage(playerid,COLOR_PAYCHEC,str_donate);
			SavePlayer(playerid);
		}
	case 5126: {
			static str_title[64]; format(str_title,sizeof(str_title),"{96e300}Донат {4751ff}| {96e300}[У вас: %d монет]",PI[playerid][pDonateCash]);
			SPD(playerid, 5124, DIALOG_STYLE_LIST, str_title, "{ffffff}Активировать донат-код\nГде купить монеты?\n \n{96e300}Потратить монеты", "Выбрать", "Отмена");
		}
	case 21: {
			if(!response) return 1;
			switch(listitem) {
			case 0: return SPD(playerid,1012,1,"{adff2f}Описание Команды","{FFFFFF}Введите интересующую Вас Команду\nдля получения её описания:\nПример: /sms","Описание","Назад");
			case 1: {
					SendClientMessage(playerid, -1, "Общие команды:");
					SendClientMessage(playerid, -1, "<> {9ACD32}/menu /gps /leaders /admins /inv /pay /givpat /givemet /givegrain /(lic)enses /anim /setspawn /eject /pass /id /ad");
					SendClientMessage(playerid, -1, "<> {9ACD32}/call /sms /p /h /f /r /me /do /try /s /w /n /number");
				}
			case 2: {
					if(PI[playerid][pAdmLevel] < 1) return SendClientMessage(playerid, COLOR_GREY, T_CMD);
					SendClientMessage(playerid, -1, "Команды администратора:");
					if(PI[playerid][pAdmLevel] >= 1) SendClientMessage(playerid, -1, "<> {9ACD32}(/a)dmin /mute /unmute /spec /specoff /stats /ans /admins");
					if(PI[playerid][pAdmLevel] >= 2) SendClientMessage(playerid, -1, "<> {9ACD32}/kick /goto /slap /jail /unjail /setskin ");
					if(PI[playerid][pAdmLevel] >= 3) SendClientMessage(playerid, -1, "<> {9ACD32}/fly /warn /unwarn /ban /spawncars /spcarid /delcarid /atake /setweather /settime");
					if(PI[playerid][pAdmLevel] >= 4) SendClientMessage(playerid, -1, "<> {9ACD32}/skick /givemoney /gethere /respawncars /unban /veh /msg /delcar /afill /hp /showall /agivelic");
					if(PI[playerid][pAdmLevel] >= 5) SendClientMessage(playerid, -1, "<> {9ACD32}/setstats /banip /unbanip /sban /makeleader /sethp /dellac /givegun /giveinventory /givefskill /mp /scene (add/del) /derby (add/del)");
				}
			case 3: {
					if(PI[playerid][pHelpLevel] < 1) return SendClientMessage(playerid, COLOR_GREY, T_CMD);
					SendClientMessage(playerid, -1, "Команды хелпера:");
					if(PI[playerid][pHelpLevel] >= 1) SendClientMessage(playerid, -1, "<> {9ACD32}/hc (Чат помощников) /hooc (Общий чат) /hans(ответить) /hgoto (Телепортироваться) /helpers");
				}
			case 4: {
					if(PI[playerid][pJob] < 1) return SendClientMessage(playerid, COLOR_GREY, "У вас нет работы!");
					if(PI[playerid][pJob] >= 1)	SendClientMessage(playerid, -1, "<> Нет доступных команд.");
					if(PI[playerid][pJob] >= 2)	SendClientMessage(playerid, -1, "<> Нет доступных команд.");
					if(PI[playerid][pJob] >= 3) {
						strin = "";
						format(strin,sizeof(strin),"Развозчик продуктов:");
						SendClientMessage(params[0], -1, strin);
						SendClientMessage(playerid, -1, "<> /plist - список заказов");
					}
					if(PI[playerid][pJob] >= 4) {
						strin = "";
						format(strin,sizeof(strin),"Автомеханик:");
						SendClientMessage(params[0], -1, strin);
						SendClientMessage(playerid, -1, "<> /refill - заправить авто");
						SendClientMessage(playerid, -1, "<> /repair - починить авто");
						SendClientMessage(playerid, -1, "<> /towcar - прицепить авто");
					}
				}
			case 5: {
					SendClientMessage(playerid, -1, "Команды правительства:");
					SendClientMessage(playerid, -1, "<> {9ACD32}/r /d /g(ov) /muninvite /minfo /salary /tbudget /budget");
				}
			case 6: {
					SendClientMessage(playerid, -1, "Команды Полиции и ФБР:");
					SendClientMessage(playerid, -1, "<> {9ACD32}/f /r /d /g(ov) /wanted /find /cfind /arrest /su /cuff /uncuff /clear /cput /m");
					SendClientMessage(playerid, -1, "<> {9ACD32} /tazer /take /ticket");
				}
			case 7: {
					SendClientMessage(playerid, -1, "Команды Бандитов:");
					SendClientMessage(playerid, -1, "<> {9ACD32}/f /makegun /sellgun /selldrugs /capture /drugs /buydrugs /loadammo /unloadammo");
				}
			case 8: {
					SendClientMessage(playerid, -1, "Команды репортеров:");
					SendClientMessage(playerid, -1, "<> {9ACD32}(/f)amily /news /ad");
				}
			case 9: {
					SendClientMessage(playerid, -1, "Команды лицензеров:");
					SendClientMessage(playerid, -1, "<> {9ACD32}/r /givelicense /licprice");
				}
			case 10: {
					SendClientMessage(playerid, -1, "Лидерские лидеров:");
					SendClientMessage(playerid, -1, "<> {9ACD32}/invite /uninvite /rank /changeskin /offuninvite");
				}
			case 11: {
					SendClientMessage(playerid, -1, "Личное авто:");
					SendClientMessage(playerid, -1, "<> {9ACD32}/en /lock [1-2] /park [1-2] /fixcar [1-2] /gpscar [1-2]");
				}
			}
		}
	case 1012: {
			if(!response) return SPD(playerid, 21, DIALOG_STYLE_LIST, "Команды сервера", "Получить описание\nОбщие команды\nКоманды администрации\nКоманды хелперов\nКоманды работы\nКоманды правительства\nКоманды Полиции и ФБР\nКоманды бандитов\nКоманды репортеров\nКоманды лицензеров\nЛидерские команды\nКоманды личного авто", "Далее", "Отмена");
			if(!strcmp(inputtext,"/mn",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/mn - Главное меню игрока");
			else if(!strcmp(inputtext,"/home",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/hmenu - Общее меню дома");
			else if(!strcmp(inputtext,"/sellcar",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/sellcar - продать личный автомобиль");
			else if(!strcmp(inputtext,"/business",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/business - меню бизнеса");
			else if(!strcmp(inputtext,"/business",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/bpanel - меню бизнеса");
			else if(!strcmp(inputtext,"/buybiz",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/buybiz - купить бизнес");
			else if(!strcmp(inputtext,"/lock",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/lock - открыть/закрыть личный автомобиль");
			else if(!strcmp(inputtext,"/sell",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/sell - продать товар игроку");
			else if(!strcmp(inputtext,"/s",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/s - крикнуть");
			else if(!strcmp(inputtext,"/w",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/w - сказать шёпотом");
			else if(!strcmp(inputtext,"/b",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/n - OOC сообщение)");
			else if(!strcmp(inputtext,"/sms",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/sms - отправить смс игроку");
			else if(!strcmp(inputtext,"/c",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/c - сделать звонок");
			else if(!strcmp(inputtext,"/ad",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/ad - подать объявление на проверку");
			else if(!strcmp(inputtext,"/me",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/me - выполнить действие");
			else if(!strcmp(inputtext,"/try",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/try - попытаться выполнить действие");
			else if(!strcmp(inputtext,"/do",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/do - выполнить действие от 1-го лица");
			else if(!strcmp(inputtext,"/capture",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/capture - начать захват территории");
			else if(!strcmp(inputtext,"/makegun",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/makegun - собрать оружие");
			else if(!strcmp(inputtext,"/f",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/f - чат семьи");
			else if(!strcmp(inputtext,"/r",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/r - рация");
			else if(!strcmp(inputtext,"/d",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/d - депортамент");
			else if(!strcmp(inputtext,"/givelicense",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/givelicense - продать лицензии");
			else if(!strcmp(inputtext,"/ticket",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/ticket - выписать штраф");
			else if(!strcmp(inputtext,"/flash",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/flash - установить сирену");
			else if(!strcmp(inputtext,"/pay",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/pay - передать деньги");
			else if(!strcmp(inputtext,"/anim",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/anim - список анимаций");
			else if(!strcmp(inputtext,"/pay",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/pay - передать деньги");
			else if(!strcmp(inputtext,"/cuff",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/cuff - надеть наручники");
			else if(!strcmp(inputtext,"/uncuff",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/uncuff - снять наручники");
			else if(!strcmp(inputtext,"/tazer",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/tazer - ударить электрошокером");
			else if(!strcmp(inputtext,"/arrest",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/arrest - посадить игрока в КПЗ");
			else if(!strcmp(inputtext,"/cfind",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/cfind - узнать примерное месторасположение игрока");
			else if(!strcmp(inputtext,"/heal",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/heal - вылечить игрока");
			else if(!strcmp(inputtext,"/givemc",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/givemc - выдать мед.карту");
			else if(!strcmp(inputtext,"/number",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/number - узнать номер телефона");
			else if(!strcmp(inputtext,"/givpat",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/givpatr - передать патроны");
			else if(!strcmp(inputtext,"/drugs",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/drugs - употребить наркотики ");
			else if(!strcmp(inputtext,"/call",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/call - позвонить");
			else if(!strcmp(inputtext,"/sms",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/sms - отправить SMS");
			else if(!strcmp(inputtext,"/news",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/news - меня репортеров");
			else if(!strcmp(inputtext,"/leaders",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/leaders - лидеры в сети");
			else if(!strcmp(inputtext,"/helpers",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/helpers - помощники в сети");
			else if(!strcmp(inputtext,"/admins",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/admins - админы в сети");
			else if(!strcmp(inputtext,"/suspect",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/(su)spect - выдать розыск");
			else if(!strcmp(inputtext,"/frisk",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/frisk - обыскать игрока");
			else if(!strcmp(inputtext,"/wanted",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/wanted - преступники");
			else if(!strcmp(inputtext,"/cput",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/cput - затащить в авто");
			else if(!strcmp(inputtext,"/clear",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/clear - очистить уровень розыска");
			else if(!strcmp(inputtext,"/setspawn",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/setspawn - изменить место появления(спавн)");
			else if(!strcmp(inputtext,"/exit",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/exit - выйти из дома");
			else if(!strcmp(inputtext,"/park",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/park - припарковать личное авто");
			else if(!strcmp(inputtext,"/lock",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/lock - открыть/закрыть личное авто");
			else if(!strcmp(inputtext,"/licenses",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/licenses - ваши лицензии");
			else if(!strcmp(inputtext,"/find",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/find - члены организации в сети");
			else if(!strcmp(inputtext,"/givemet",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/givemet - передать метал");
			else if(!strcmp(inputtext,"/tie",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/tie - связать человека");
			else if(!strcmp(inputtext,"/untie",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/untie - развязать человека");
			else if(!strcmp(inputtext,"/pass",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/pass - показать документы");
			else if(!strcmp(inputtext,"/take",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/take - отобрать лицензии/оружие/патроны");
			else if(!strcmp(inputtext,"/clist",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/clist - сменить цвет ника");
			else if(!strcmp(inputtext,"/eject",true)) return SendClientMessage(playerid, COLOR_YELLOW2,"/eject - выкинуть из авто");
			return true;
		}
	case 22: {
			if(!response) return 1;
			switch(listitem) {
			case 0: {
					if(SendFamily[playerid] == 1) {
						SendClientMessage(playerid, COLOR_LIGHTRED, "Вы отключили рацию");
						SendFamily[playerid] = 0;
					}
					else
					{
						SendClientMessage(playerid, COLOR_LIGHTGREEN, "Вы включили рацию");
						SendFamily[playerid] = 1;
					}
				}
			case 1: {
					new a;
					while(a++ < 100) SendClientMessage(playerid, COLOR_LIGHTRED, "");
					SendClientMessage(playerid, COLOR_LIGHTRED, "Вы очистили чат");
				}
			case 2: {
					if(PI[playerid][pSex] == 0) {
						PI[playerid][pSex] = 1;
						SendClientMessage(playerid, COLOR_LIGHTRED, "Вы сменили пол на: женский");
					}
					else
					{
						SendClientMessage(playerid, COLOR_LIGHTRED, "Вы сменили пол на: мужской");
						PI[playerid][pSex] = 0;
					}
				}
			case 3: SPD(playerid, CHANGE_NICK_1, 1, "Введите пароль", "Введите пароль вашего аккаунта", "Далее", "Выход");
			}
		}
		// Репорт
	case 23: {
			if(!response) return 1;
			if(!strlen(inputtext)) return SPD(playerid, 23, 1, "{FF9900}Репорт", "Обращаясь в репорт четко и ясно выражайте суть своей жалобы.\nЗапрещен оффтоп, флуд, мат.\nВаш сообщение:", "Отправить", "Отмена");
			if(strlen(inputtext) < 1 || strlen(inputtext) > 100) return SPD(playerid, 23, 1, "{FF9900}Репорт", "Обращаясь в репорт четко и ясно выражайте суть своей жалобы.\nЗапрещен оффтоп, флуд, мат.\nВаш сообщение:", "Отправить", "Отмена");
			if(GetPVarInt(playerid,"AntiFloodRep") > gettime()) return SendClientMessage(playerid, COLOR_GREY, "Писать в репорт можно раз в 30 секунд!");
			strin = "";
			format(strin, 128, "Жалоба от %s (ID: %d): %s",NamePlayer(playerid),playerid,inputtext);
			SendAdminMessage(0x006bcfAA, strin);
			SendClientMessage(playerid, COLOR_LIGHTRED, "Ваш запрос был отправлен администрации");
			SetPVarInt(playerid,"AntiFloodRep",gettime() + 30);
		}
	case 26: {
			if(!response) return 1;
			if(!strlen(inputtext)) return SPD(playerid, 23, 1, "{FF9900}Вопрос", "Обращаясь к помощникам четко и ясно выражайте суть своего вопроса.\nЗапрещен оффтоп, флуд, мат.\nВаш сообщение:", "Отправить", "Отмена");
			if(strlen(inputtext) < 1 || strlen(inputtext) > 100) return SPD(playerid, 23, 1, "{FF9900}Вопрос", "Обращаясь к помощникам четко и ясно выражайте суть своего вопроса.\nЗапрещен оффтоп, флуд, мат.\nВаш сообщение:", "Отправить", "Отмена");
			if(GetPVarInt(playerid,"AntiFloodRep") > gettime()) return SendClientMessage(playerid, COLOR_GREY, "Писать в вопрос можно раз в 30 секунд!");
			strin = "";
			format(strin, 128, "Вопрос от %s (ID: %d): %s",NamePlayer(playerid),playerid,inputtext);
			SendHelperMessage(0x006bcfAA, strin);
			SendClientMessage(playerid, COLOR_LIGHTRED, "Ваш вопрос был отправлен помощникам");
			SetPVarInt(playerid,"AntiFloodRep",gettime() + 30);
		}
	case 24://ADMIN
		{
			if(!response) return 1;
			switch(listitem) {
			case 0: {
					strin = "";
					strcat(strin, "Вы собираетесь написать сообщение Администрации\n");
					strcat(strin, "Перед тем как отправить сообщение убедитесь\n");
					strcat(strin, "что не один из пунктов помощи не дал вам ответа на ваш вопрос.\n\n");
					strcat(strin, "{FF0000}Запрещено:\n");
					strcat(strin, "1.Флуд,оскорбления,оффтоп.\n");
					strcat(strin, "2.Просьбы(Дайте денег,дайте лидерку,дайте дайте...)\n");
					strcat(strin, "3.Ложные сообщения\n\n");
					strcat(strin, "{B22222}За нарушение правил администрация может:\n");
					strcat(strin, "1.Предупредить(Warn)\n");
					strcat(strin, "2.Выкинуть с сервера(Kick)\n");
					strcat(strin, "3.Заблокировать аккаунт(Ban)\n");
					strcat(strin, "4.Удалить аккаунт(Dell)\n\n");
					strcat(strin, "{ADFF2F}Помните!\n");
					strcat(strin, "Мы всегда готовы помоч если вы соблюдайте правила.\n");
					strcat(strin, "Данные правила установлены для всех игроков "NameServer".\n\n");
					strcat(strin, "{FFFFFF}Если вам долго не отвечают,подождите пару минут\n");
					strcat(strin, "Вы не один на сервере\n");
					strcat(strin, "Спасибо за понимание,с уважением Администрация "NameServer".\n\n");
					SPD(playerid,23,1,"Репорт",strin,"Отправить", "Закрыть");
				}
			case 1: SPD(playerid,26,1,"Вопрос","Если у вас возник вопрос,задайте вопрос помощникам.","Отправить", "Закрыть");
			}
		}
	case 30: {
			if(!response) return 1;
			new i = GetPVarInt(playerid, "PlayerBizzz"),till = BizzInfo[i][bTill];
			switch(listitem) {
			case 0: {
					if(PI[playerid][pPhone][0] == 1) return SendClientMessage(playerid, COLOR_GREY, "У вас есть мобильный телефон!");
					if(GetMoney(playerid) < till*14) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*14);
					BizzInfo[i][bMoney] += till*14;
					BizzPay[i] += till*14;
					BizzInfo[i][bProduct] -= 50;
					new randphone = 10000 + random(999999);
					PI[playerid][pPhone][1] = randphone;
					GiveInventory(playerid,9,1);
					SendClientMessageEx(playerid, COLOR_BLUE, "Вы купили мобильный телефон, вам подарили номер: %i", randphone);
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					MagazineList(playerid, i);
				}
			case 1: {
					if(GetMoney(playerid) < till*3) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*3);
					BizzInfo[i][bMoney] += till*3;
					BizzPay[i] += till*3;
					BizzInfo[i][bProduct] -= 10;
					new randphone = 10000 + random(999999);
					PI[playerid][pPhone][1] = randphone;
					SendClientMessageEx(playerid, COLOR_BLUE, "Ваш новый номер: %i", randphone);
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					MagazineList(playerid, i);
				}
			case 2: {
					if(GetMoney(playerid) < till*5) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*5);
					BizzInfo[i][bMoney] += till*5;
					BizzPay[i] += till*5;
					BizzInfo[i][bProduct] -= 15;
					PI[playerid][pPhone][2] = 1;
					SendClientMessageEx(playerid, COLOR_BLUE, "Вы купили телефонную книгу. Новые доступные команды: /number");
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					MagazineList(playerid, i);
				}
			case 3: {
					if(GetMoney(playerid) < till*4) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*4);
					BizzInfo[i][bMoney] += till*4;
					BizzPay[i] += till*4;
					BizzInfo[i][bProduct] -= 10;
					GambK[playerid]= 1;
					SendClientMessageEx(playerid, COLOR_BLUE, "Вы купили веревку.");
					SendClientMessageEx(playerid, COLOR_BLUE, "Доступные команды: /(un)tie - чтобы развязать/связать игрока");
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					MagazineList(playerid, i);
				}
			case 4: {
					if(GetMoney(playerid) < till*3) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*3);
					BizzInfo[i][bMoney] += till*3;
					BizzPay[i] += till*3;
					BizzInfo[i][bProduct] -= 10;
					SendClientMessageEx(playerid, COLOR_BLUE, "Вы купили маску.");
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					MagazineList(playerid, i);
				}
			case 5: {
					if(GetMoney(playerid) < till*7) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*7);
					BizzInfo[i][bMoney] += till*7;
					BizzPay[i] += till*7;
					BizzInfo[i][bProduct] -= 10;
					GiveInventory(playerid,30,1);
					SendClientMessage(playerid, COLOR_BLUE, "Вы купили парашют.");
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					MagazineList(playerid, i);
				}
			case 6: {
					if(GetMoney(playerid) < till*10) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*10);
					BizzInfo[i][bMoney] += till*10;
					BizzPay[i] += till*10;
					BizzInfo[i][bProduct] -= 10;
					GiveInventory(playerid,33,10);
					SendClientMessage(playerid, COLOR_BLUE, "Вы купили Фотоаппарат (10шт)");
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					MagazineList(playerid, i);
				}
			case 7: {
					if(GetMoney(playerid) < till*4) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*4);
					BizzInfo[i][bMoney] += till*4;
					BizzPay[i] += till*4;
					BizzInfo[i][bProduct] -= 10;
					GiveInventory(playerid,17,1);
					SendClientMessage(playerid, COLOR_BLUE, "Вы купили цветы.");
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					MagazineList(playerid, i);
				}
			case 8: {
					if(GetMoney(playerid) < till*4) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*4);
					BizzInfo[i][bMoney] += till*4;
					BizzPay[i] += till*4;
					BizzInfo[i][bProduct] -= 10;
					GiveInventory(playerid,1,1);
					SendClientMessage(playerid, COLOR_BLUE, "Вы купили 1 аптечку.");
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					MagazineList(playerid, i);
				}
			case 9: {
					if(GetMoney(playerid) < till*2) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*2);
					BizzInfo[i][bMoney] += till*2;
					BizzPay[i] += till*2;
					BizzInfo[i][bProduct] -= 10;
					lotto_var[playerid]= 1;
					SendClientMessage(playerid, COLOR_BLUE, "Вы купили лотерейный билет.");
					SendClientMessage(playerid, COLOR_BLUE, "Доступные команды: /startlotto [число]");
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					MagazineList(playerid, i);
				}
			case 10: {
					if(GetMoney(playerid) < till*6) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*6);
					BizzInfo[i][bMoney] += till*6;
					BizzPay[i] += till*6;
					BizzInfo[i][bProduct] -= 5;
					PI[playerid][pSmoke] = 15;
					SendClientMessage(playerid, COLOR_BLUE, "Вы купили пачку сигарет.");
					SendClientMessage(playerid, COLOR_BLUE, "Доступные команды: /smoke");
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					MagazineList(playerid, i);
				}
			}
		}
	case 31: {
			if(!response) return 1;
			new i = GetPVarInt(playerid, "PlayerBizzz"),till = BizzInfo[i][bTill], inter = GetPlayerInterior(playerid),Float:health;
			GetPlayerHealth(playerid,health);
			switch(listitem) {
			case 0: {
					if(GetMoney(playerid) < till*4) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*4);
					BizzInfo[i][bMoney] += till*4;
					BizzInfo[i][bProduct] -= 50;
					BizzPay[i] += till*4;
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					if(health < 100) SetHealth(playerid, health+20.0);
					PI[playerid][pHunger] += 20;
					strin = "";
					if(inter == 5)
					format(strin, 90, "%s съел(а) маленькую пиццу",NamePlayer(playerid));
					if(inter == 10)
					format(strin, 90, "%s съел(а) бургер",NamePlayer(playerid));
					if(inter == 9)
					format(strin, 90, "%s съел(а) кусочки пиццы",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.0, 0, 0, 0, 0, 0,1);
					EatList(playerid, i);
				}
			case 1: {
					if(GetMoney(playerid) < till*7) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*7);
					BizzInfo[i][bMoney] += till*7;
					BizzInfo[i][bProduct] -= 50;
					BizzPay[i] += till*7;
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					if(health < 100) SetHealth(playerid, health+60.0);
					PI[playerid][pHunger] += 60;
					strin = "";
					if(inter == 5)
					format(strin, 90, "%s съел(а) среднюю пиццу",NamePlayer(playerid));
					if(inter == 10)
					format(strin, 90, "%s съел(а) большой бургер",NamePlayer(playerid));
					if(inter == 9)
					format(strin, 90, "%s съел(а) кусок куринной ножки",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.0, 0, 0, 0, 0, 0,1);
					EatList(playerid, i);
				}
			case 2: {
					if(GetMoney(playerid) < till*10) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*10);
					BizzInfo[i][bMoney] += till*10;
					BizzInfo[i][bProduct] -= 50;
					BizzPay[i] += till*10;
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					if(health < 100) SetHealth(playerid, health+80.0);
					PI[playerid][pHunger] += 80;
					strin = "";
					if(inter == 5)
					format(strin, 90, "%s съел(а) большую пиццу",NamePlayer(playerid));
					if(inter == 10)
					format(strin, 90, "%s съел(а) гамбургер",NamePlayer(playerid));
					if(inter == 9)
					format(strin, 90, "%s съел(а) куриную ножку",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.0, 0, 0, 0, 0, 0,1);
					EatList(playerid, i);
				}
			}
			if(PI[playerid][pHunger] > 100) PI[playerid][pHunger] = 100;
			if(PI[playerid][pHeal] > 100) SetHealth(playerid, 100);
		}
	case 32: {
			if(!response) return 1;
			new i = GetPVarInt(playerid, "PlayerBizzz"),till = BizzInfo[i][bTill],Float:health;
			GetPlayerHealth(playerid,health);
			switch(listitem) {
			case 0: {
					if(GetMoney(playerid) < till*4) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*4);
					BizzInfo[i][bMoney] += till*4;
					BizzPay[i] += till*4;
					BizzInfo[i][bProduct] -= 50;
					PI[playerid][pHunger] += 10;
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					strin = "";
					format(strin, 90, "%s выпил(а) воды",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					SetHealth(playerid, health+10.0);
					ApplyAnimation(playerid,"BAR","dnk_stndF_loop",4.1,0,0,0,0,0,1);
					ClubList(playerid, i);
				}
			case 1: {
					if(GetMoney(playerid) < till*7) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*7);
					BizzInfo[i][bMoney] += till*7;
					BizzInfo[i][bProduct] -= 50;
					BizzPay[i] += till*7;
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					SetHealth(playerid, health+10.0);
					PI[playerid][pHunger] += 10;
					strin = "";
					format(strin, 90, "%s выпил(а) соды",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					ApplyAnimation(playerid,"BAR","dnk_stndF_loop",4.1,0,0,0,0,0,1);
					ClubList(playerid, i);
				}
			case 2: {
					if(GetMoney(playerid) < till*10) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*10);
					BizzInfo[i][bMoney] += till*10;
					BizzInfo[i][bProduct] -= 50;
					BizzPay[i] += till*10;
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					SetHealth(playerid, health+10.0);
					PI[playerid][pHunger] += 10;
					strin = "";
					format(strin, 90, "%s выпил(а) кока-колы",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					ApplyAnimation(playerid,"BAR","dnk_stndF_loop",4.1,0,0,0,0,0,1);
					ClubList(playerid, i);
				}
			case 3: {
					if(GetMoney(playerid) < till*15) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*15);
					BizzInfo[i][bMoney] += till*15;
					BizzInfo[i][bProduct] -= 50;
					BizzPay[i] += till*15;
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					SetHealth(playerid, health+20.0);
					PI[playerid][pHunger] += 20;
					strin = "";
					format(strin, 90, "%s выпил(а) пиво",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					if(GetPlayerDrunkLevel(playerid) < 20000) SetPlayerDrunkLevel(playerid,GetPlayerDrunkLevel(playerid)+2000);
					ApplyAnimation(playerid,"BAR","dnk_stndF_loop",4.1,0,0,0,0,0,1);
					ClubList(playerid, i);
				}
			case 4: {
					if(GetMoney(playerid) < till*20) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*20);
					BizzInfo[i][bMoney] += till*20;
					BizzInfo[i][bProduct] -= 50;
					BizzPay[i] += till*20;
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					SetHealth(playerid, health+30.0);
					PI[playerid][pHunger] += 30;
					strin = "";
					format(strin, 90, "%s выпил(а) водки",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					if(GetPlayerDrunkLevel(playerid) < 20000) SetPlayerDrunkLevel(playerid,GetPlayerDrunkLevel(playerid)+5000);
					ApplyAnimation(playerid,"BAR","dnk_stndF_loop",4.1,0,0,0,0,0,1);
					ClubList(playerid, i);
				}
			case 5: {
					if(GetMoney(playerid) < till*25) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*25);
					BizzInfo[i][bMoney] += till*25;
					BizzPay[i] += till*25;
					BizzInfo[i][bProduct] -= 50;
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					SetHealth(playerid, health+30.0);
					PI[playerid][pHunger] += 30;
					strin = "";
					format(strin, 90, "%s выпил(а) коньяк",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					if(GetPlayerDrunkLevel(playerid) < 20000) SetPlayerDrunkLevel(playerid,GetPlayerDrunkLevel(playerid)+5000);
					ApplyAnimation(playerid,"BAR","dnk_stndF_loop",4.1,0,0,0,0,0,1);
					ClubList(playerid, i);
				}
			case 6: {
					if(GetMoney(playerid) < till*30) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -till*30);
					BizzInfo[i][bMoney] += till*30;
					BizzPay[i] += till*30;
					BizzInfo[i][bProduct] -= 50;
					SetBizzInt(i, "money", BizzInfo[i][bMoney]);
					SetBizzInt(i, "product", BizzInfo[i][bProduct]);
					SetHealth(playerid, health+30.0);
					PI[playerid][pHunger] += 30;
					if(GetPlayerDrunkLevel(playerid) < 20000) SetPlayerDrunkLevel(playerid,GetPlayerDrunkLevel(playerid)+5000);
					strin = "";
					format(strin, 90, "%s выпил(а) абсент",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					ApplyAnimation(playerid,"BAR","dnk_stndF_loop",4.1,0,0,0,0,0,1);
					ClubList(playerid, i);
				}
			}
			if(PI[playerid][pHunger] > 100) PI[playerid][pHunger] = 100;
			if(PI[playerid][pHeal] > 100) SetHealth(playerid, 100);
			if(GetPlayerDrunkLevel(playerid) > 20000) SetPlayerDrunkLevel(playerid,20000);
		}
	case 34: {
			if(!response) return 1;
			new Float:health;
			GetPlayerHealth(playerid,health);
			switch(listitem) {
			case 0: {
					if(GetMoney(playerid) < 5) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -5);
					PI[playerid][pHunger] += 5;
					strin = "";
					format(strin, 90, "%s выпил(а) соду",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					SetHealth(playerid, health+5.0);
					ApplyAnimation(playerid,"BAR","dnk_stndF_loop",4.1,0,0,0,0,0,1);
					FoodList(playerid);
				}
			case 1: {
					if(GetMoney(playerid) < 15) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -15);
					PI[playerid][pHunger] += 10;
					strin = "";
					format(strin, 90, "%s выпил(а) квас",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					SetHealth(playerid, health+10.0);
					ApplyAnimation(playerid,"BAR","dnk_stndF_loop",4.1,0,0,0,0,0,1);
					FoodList(playerid);
				}
			case 2: {
					if(GetMoney(playerid) < 20) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -20);
					PI[playerid][pHunger] += 10;
					strin = "";
					format(strin, 90, "%s выпил(а) сок",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					SetHealth(playerid, health+10.0);
					ApplyAnimation(playerid,"BAR","dnk_stndF_loop",4.1,0,0,0,0,0,1);
					FoodList(playerid);
				}
			case 3: {
					if(GetMoney(playerid) < 30) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -30);
					PI[playerid][pHunger] += 15;
					strin = "";
					format(strin, 90, "%s выпил(а) лимонад",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					SetHealth(playerid, health+15.0);
					ApplyAnimation(playerid,"BAR","dnk_stndF_loop",4.1,0,0,0,0,0,1);
					FoodList(playerid);
				}
			case 4: {
					if(GetMoney(playerid) < 35) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -35);
					PI[playerid][pHunger] += 20;
					strin = "";
					format(strin, 90, "%s съел(а) гамбургер",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					SetHealth(playerid, health+20.0);
					ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.0, 0, 0, 0, 0, 0,1);
					FoodList(playerid);
				}
			case 5: {
					if(GetMoney(playerid) < 40) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -40);
					PI[playerid][pHunger] += 30;
					strin = "";
					format(strin, 90, "%s съел(а) пиццу",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					SetHealth(playerid, health+30.0);
					ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.0, 0, 0, 0, 0, 0,1);
					FoodList(playerid);
				}
			case 6: {
					if(GetMoney(playerid) < 70) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
					GiveMoney(playerid, -70);
					PI[playerid][pHunger] += 50;
					strin = "";
					format(strin, 90, "%s съел(а) пиццу",NamePlayer(playerid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
					SetHealth(playerid, health+50.0);
					ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.0, 0, 0, 0, 0, 0,1);
					FoodList(playerid);
				}
			}
			if(PI[playerid][pHunger] > 100) PI[playerid][pHunger] = 100;
			if(PI[playerid][pHeal] > 100) SetHealth(playerid, 100);
		}
		//
	case 40: {
			if(!response) {DeletePVar(playerid, "PlayerLic");return 1;}
			new p = GetPVarInt(playerid, "PlayerLic");
			switch(listitem) {
				// Права
			case 0: {
					strin = "";
					format(strin,sizeof(strin),"{ffffff}Лицензер %s\nпредлагает Вам водительские права за %d$",NamePlayer(playerid),LicPrice[0]);
					SPD(p,41,0,"Лицензия | Права", strin, "Принять", "Отмена");
				}
				// Водный
			case 1: {
					strin = "";
					format(strin,sizeof(strin),"{ffffff}Лицензер %s\nпредлагает Вам лицензию на\nводный транспорт за %d$",NamePlayer(playerid),LicPrice[1]);
					SPD(p,42,0,"Лицензия | Водные ТС", strin, "Принять", "Отмена");
				}
				// Воздушный
			case 2: {
					strin = "";
					format(strin,sizeof(strin),"{ffffff}Лицензер %s\nпредлагает Вам лицензию на\nвоздушный транспорт за %d$",NamePlayer(playerid),LicPrice[2]);
					SPD(p,43,0,"Лицензия | Воздушные ТС", strin, "Принять", "Отмена");
				}
				// Оружие
			case 3: {
					strin = "";
					format(strin,sizeof(strin),"{ffffff}Лицензер %s\nпредлагает Вам разрешение\nна ношение оружия за %d$",NamePlayer(playerid),LicPrice[3]);
					SPD(p,44,0,"Лицензия | Оружие", strin, "Принять", "Отмена");
				}
				// Бизнес
			case 4: {
					if(GetPlayerBizz(p) == 0) return SendClientMessage(playerid, COLOR_GREY, "Игрок не владеет бизнесом!");
					strin = "";
					format(strin,sizeof(strin),"{ffffff}Лицензер %s\nпредлагает Вам лицензию на бизнес за %d$",NamePlayer(playerid),LicPrice[4]);
					SPD(p,45,0,"Лицензия | Бизнес", strin, "Принять", "Отмена");
				}
			}
			SetPVarInt(p, "LicPlayer", playerid);
			DeletePVar(playerid, "PlayerLic");
		}
	case 41: {
			if(!response) {DeletePVar(playerid, "LicPlayer");return 1;}
			new p = GetPVarInt(playerid, "LicPlayer");
			if(GetMoney(playerid) < LicPrice[0]) {
				SendClientMessage(playerid, COLOR_GREEN,"У Вас недостаточно средств!");
				SendClientMessage(p, COLOR_GREEN,"У игрока недостаточно средств!");
				DeletePVar(playerid, "LicPlayer");
				return 1;
			}
			GiveMoney(playerid, -LicPrice[0]);
			SAMoney += LicPrice[0];
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы купили водительские права у %s за %d$", NamePlayer(p),LicPrice[0]);
			SendClientMessageEx(p, COLOR_PAYCHEC, "%s купили у Вас водительские права за %d$", NamePlayer(playerid),LicPrice[0]);
			PI[playerid][pLic][0] = 1;
			DeletePVar(playerid, "LicPlayer");
		}
	case 42: {
			if(!response) {DeletePVar(playerid, "LicPlayer");return 1;}
			new p = GetPVarInt(playerid, "LicPlayer");
			if(GetMoney(playerid) < LicPrice[1]) {
				SendClientMessage(playerid, COLOR_GREEN,"У Вас недостаточно средств!");
				SendClientMessage(p, COLOR_GREEN,"У игрока недостаточно средств!");
				DeletePVar(playerid, "LicPlayer");
				return 1;
			}
			GiveMoney(playerid, -LicPrice[1]);
			SAMoney += LicPrice[1];
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы купили лицензию на водный транспорт у %s за %d$", NamePlayer(p),LicPrice[1]);
			SendClientMessageEx(p, COLOR_PAYCHEC, "%s купили у Вас лицензию на водный транспорт за %d$", NamePlayer(playerid),LicPrice[1]);
			PI[playerid][pLic][1] = 1;
			DeletePVar(playerid, "LicPlayer");
		}
	case 43: {
			if(!response) {DeletePVar(playerid, "LicPlayer");return 1;}
			new p = GetPVarInt(playerid, "LicPlayer");
			if(GetMoney(playerid) < LicPrice[2]) {
				SendClientMessage(playerid, COLOR_GREEN,"У Вас недостаточно средств!");
				SendClientMessage(p, COLOR_GREEN,"У игрока недостаточно средств!");
				DeletePVar(playerid, "LicPlayer");
				return 1;
			}
			GiveMoney(playerid, -LicPrice[2]);
			SAMoney += LicPrice[2];
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы купили лицензию на воздушный транспорт у %s за %d$", NamePlayer(p),LicPrice[2]);
			SendClientMessageEx(p, COLOR_PAYCHEC, "%s купили у Вас лицензию на воздушный транспорт за %d$", NamePlayer(playerid),LicPrice[2]);
			PI[playerid][pLic][2] = 1;
			DeletePVar(playerid, "LicPlayer");
		}
	case 44: {
			if(!response) {DeletePVar(playerid, "LicPlayer");return 1;}
			new p = GetPVarInt(playerid, "LicPlayer");
			if(GetMoney(playerid) < LicPrice[3]) {
				SendClientMessage(playerid, COLOR_GREEN,"У Вас недостаточно средств!");
				SendClientMessage(p, COLOR_GREEN,"У игрока недостаточно средств!");
				DeletePVar(playerid, "LicPlayer");
				return 1;
			}
			GiveMoney(playerid, -LicPrice[3]);
			SAMoney += LicPrice[3];
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы купили разрешение на ношение оружия у %s за %d$", NamePlayer(p),LicPrice[3]);
			SendClientMessageEx(p, COLOR_PAYCHEC, "%s купили у Вас разрешение на ношение оружия за %d$", NamePlayer(playerid),LicPrice[3]);
			PI[playerid][pLic][3] = 1;
			DeletePVar(playerid, "LicPlayer");
		}
	case 45: {
			if(!response) {DeletePVar(playerid, "LicPlayer");return 1;}
			new p = GetPVarInt(playerid, "LicPlayer");
			if(GetMoney(playerid) < LicPrice[4]) {
				SendClientMessage(playerid, COLOR_GREEN,"У Вас недостаточно средств!");
				SendClientMessage(p, COLOR_GREEN,"У игрока недостаточно средств!");
				DeletePVar(playerid, "LicPlayer");
				return 1;
			}
			SAMoney += LicPrice[4];

			new i = GetPVarInt(p, "PlayerBizz");
			BizzInfo[i][bLic] = 1;
			SetBizzInt(i, "lic", BizzInfo[i][bLic]);

			GiveMoney(playerid, -LicPrice[4]);
			SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы купили лицензию на бизнес у %s за %d$", NamePlayer(p),LicPrice[4]);
			SendClientMessageEx(p, COLOR_PAYCHEC, "%s купили у Вас лицензию на бизнес за %d$", NamePlayer(playerid),LicPrice[4]);
			PI[playerid][pLic][4] = 1;
			DeletePVar(playerid, "LicPlayer");
		}
		////////
	case 60: {
			if(!response) return RemovePlayerFromVehicleEx(playerid);
			SetPVarInt(playerid, "PriceTaxi", BizzPark[1][tTarif]);
			strin = "";
			format(strin, 90, "{a4a4a4}%s\nТариф: {5d9f35}%i {a4a4a4}долларов", BizzPark[1][tName], BizzPark[1][tTarif]);
			TaxiText3D[playerid] = CreateDynamic3DTextLabel(strin,COLOR_YELLOW,0.0,-0.4,1.5,5.0,INVALID_PLAYER_ID,GetPlayerVehicleID(playerid),-1, -1, -1);
		}
	case 61: {
			if(!response) return 1;
			new i = GetPVarInt(playerid, "BizzPark");
			switch(listitem) {
			case 0: ParkStats(playerid, i);
			case 1: {
					GiveMoney(playerid,BizzPark[i][tBank]);
					BizzPark[i][tBank] = 0;
					SendClientMessage(playerid, COLOR_LIGHTRED, "Вы сняли все деньги с бизнеса.");
				}
			case 2: SPD(playerid, 62, 1, "Цена проезда", "{ffffff}Введите цену за проезд:", "Принять", "Отмена");
			case 3: SPD(playerid, 63, 0, "Продать бизнес", "{ffffff}Вы хотите продать свой бизнес?\n\n{FF6347}Внимание! Вам вернут только половину стоимости бизнеса!", "Да", "Нет");
			}
		}
	case 62: {
			if(!response) return 1;
			new price, i = GetPVarInt(playerid, "BizzPark");
			if(sscanf(inputtext, "i",price)) SPD(playerid, 62, 1, "Цена проезда", "{ffffff}Введите цену за проезд:", "Принять", "Отмена");
			if(price < 1 || price > 1000) return SPD(playerid, 62, 1, "Цена проезда", "{ffffff}Введите цену за проезд:", "Принять", "Отмена");
			BizzPark[i][tTarif] = price;
			SetParkInt(i, "tarif", price);
			SendClientMessageEx(playerid, COLOR_BLUE, "Вы установили цену за проезд: %i$", price);
			UpdatePark(i);
			return 1;
		}
	case 63: {
			if(!response) return 1;
			new i = GetPVarInt(playerid, "BizzPark");
			strmid(BizzPark[i][tOwner], "None", 0, strlen("None"), MAX_PLAYER_NAME);
			BizzPark[i][tBank] = 0;
			BizzPark[i][tTarif] = 10;
			SendClientMessage(playerid, COLOR_LIGHTRED, "Вы продали свой бизнес. Деньги с бизнеса переведены на ваш банковский счет");
			new money = BizzPark[i][tBank] + BizzPark[i][tCost];
			PlusBankMoney(playerid, money), CheckBank(playerid);
			query = "";
			format(query, 512, "UPDATE "TABLE_PARK" SET name='%s', owner='%s', bank=%d, tarif=%d WHERE id = %d LIMIT 1",
			BizzPark[i][tName], BizzPark[i][tOwner], BizzPark[i][tBank], BizzPark[i][tTarif],i);
			mysql_function_query(cHandle, query, false, "", "");
			UpdatePark(i);
			GameTextForPlayer(playerid, "The busines sold", 3000, 5);
		}
		// Автобусы
	case 64: {
			if(!response) return RemovePlayerFromVehicleEx(playerid);
			SetPVarInt(playerid, "PriceBus", BizzPark[2][tTarif]);
			SetPVarInt(playerid, "RentBus", GetPlayerVehicleID(playerid));
			SPD(playerid, 65, 2, "Маршрут автобуса", "Внутригородской LS", "Принять", "Отмена");//LS - Лесопилка(Разработка)\nLS - Fort Carson(Разработка)\n
		}
	case 65: {
			if(!response) return 1;
			new name[32];
			switch(listitem) {
				//case 0: name = "Los Santos - Лесопилка";
				//case 1: name = "Los Santos - Fort Carson";
			case 0: name = "Внутригородской Los Santos";
			}
			SetPVarInt(playerid, "TypeBus", listitem+1);
			SendClientMessage(playerid, COLOR_BLUE, "Вы начали работу водителя автобуса");
			strin = "";
			format(strin, 128, "Автобус отъезжает через несколько секунд (%s)",name);
			ProxDetectorNew(playerid, 30.0, COLOR_FADE5, strin);
			strin = "";
			format(strin, 90, "%s\n{ffffff}Стоимость проезда: {33AAFF}%i {ffffff}долларов", name, GetPVarInt(playerid, "PriceBus"));
			BusText3D[playerid] = Create3DTextLabel( strin, 0x33AAFFFF, 0.0, 0.0, 0.0, 50.0, 0, 1);
			Attach3DTextLabelToVehicle(BusText3D[playerid], GetPlayerVehicleID(playerid), 0.0, 0.0, 2.25);
			pPressed[playerid] = 0;
			new i = pPressed[playerid], type = GetPVarInt(playerid, "TypeBus");
			if(type == 1) SetPlayerRaceCheckpoint(playerid,0,VLS_001[i][0],VLS_001[i][1],VLS_001[i][2],VLS_001[i][3],VLS_001[i][4],VLS_001[i][5],5.0);//LS_001[i][0],LS_001[i][1],LS_001[i][2],LS_001[i][3],LS_001[i][4],LS_001[i][5],5.0
			if(type == 2) SetPlayerRaceCheckpoint(playerid,0,LS_002[i][0],LS_002[i][1],LS_002[i][2],LS_002[i][3],LS_002[i][4],LS_002[i][5],5.0);
			if(type == 3) SetPlayerRaceCheckpoint(playerid,0,VLS_001[i][0],VLS_001[i][1],VLS_001[i][2],VLS_001[i][3],VLS_001[i][4],VLS_001[i][5],5.0);
			return 1;
		}
		// Анимации
	case 72: {
			if(!response) return 1;
			switch(listitem) {
			case 0: SetPlayerSpecialAction (playerid, SPECIAL_ACTION_DANCE1);
			case 1: SetPlayerSpecialAction (playerid, SPECIAL_ACTION_DANCE2);
			case 2: SetPlayerSpecialAction (playerid, SPECIAL_ACTION_DANCE3);
			case 3: SetPlayerSpecialAction (playerid, SPECIAL_ACTION_DANCE4);
			case 4: GoAnim(playerid,"DEALER","Dealer_idle",4.1,1,0,0,0,0,0);
			case 5: ApplyAnimation(playerid,"DEALER","Dealer_Deal",4.1,0,0,0,0,0,1);
			case 6: ApplyAnimation(playerid,"FOOD","Eat_Burger",4.1,0,0,0,0,0,1);
			case 7: ApplyAnimation(playerid,"PAULNMAC","Piss_in",4.1,0,0,0,0,0,1);
			case 8: GoAnim(playerid,"PARK","Tai_Chi_Loop",4.1,1,0,0,0,0,0);
			case 9: GoAnim(playerid,"CRACK","Crckidle1",4.1,1,0,0,0,0,0);
			case 10: GoAnim(playerid,"CRACK","Crckidle2",4.1,1,0,0,0,0,0);
			case 11: GoAnim(playerid,"CRACK","Crckidle4",4.1,1,0,0,0,0,0);
			case 12: ApplyAnimation(playerid,"SWEET","sweet_ass_slap",4.1,0,0,0,0,0,1);
			case 13: GoAnim(playerid,"SPRAYCAN","spraycan_full",4.1,1,0,0,0,0,0);
			case 14: GoAnim(playerid,"GRAFFITI","spraycan_fire",4.1,1,0,0,0,0,0);
			case 15: GoAnim(playerid,"SMOKING","M_smkstnd_loop",4.1,1,0,0,0,0,0);
			case 16: GoAnim(playerid,"SHOP","ROB_Loop_Threat",4.1,1,0,0,0,0,0);
			case 17: ApplyAnimation(playerid,"SHOP","ROB_shifty",4.1,0,0,0,0,0,1);
			case 18: GoAnim(playerid,"SHOP","SHP_Rob_HandsUP",4.1,1,0,0,0,0,0);
			case 19: GoAnim(playerid,"RYDER","Ryd_Beckon_02",4.1,1,0,0,0,0,0);
			case 20: ApplyAnimation(playerid,"RIOT","Riot_Angry",4.1,0,0,0,0,0,0);
			case 21: GoAnim(playerid,"RIOT","Riot_Angry_B",4.1,1,0,0,0,0,0);
			case 22: GoAnim(playerid,"RIOT","Riot_Chant",4.1,1,1,0,0,0,0);
			case 23: GoAnim(playerid,"RIOT","Riot_Punches",4.1,1,0,0,0,0,0);
			case 24: ApplyAnimation(playerid,"PED","fucku",4.1,0,0,0,0,0,1);
			case 25: ApplyAnimation(playerid,"BAR","dnK_StndM_loop",4.1,0,0,0,0,0,1);
			case 26: GoAnim(playerid,"BD_FIRE","BD_Panic_03",4.1,1,0,0,0,0,0);
			case 27: GoAnim(playerid,"BD_FIRE","M_smklean_loop",4.1,1,0,0,0,0,0);
			case 28: GoAnim(playerid,"BEACH","bather",4.1,1,0,0,0,0,0);
			case 29: GoAnim(playerid,"BEACH","Lay_Bac_loop",4.1,1,0,0,0,0,0);
			case 30: GoAnim(playerid,"BEACH","Parksit_w_loop",4.1,1,0,0,0,0,0);
			case 31: GoAnim(playerid,"BEACH","Sitnwait_Loop_W",4.1,1,0,0,0,0,0);
			case 32: GoAnim(playerid,"BEACH","Parksit_M_loop",4.1,1,0,0,0,0,0);
			case 33: GoAnim(playerid,"benchpress","gym_bp_celebrate",4.1,1,0,0,0,0,0);
			case 34: GoAnim(playerid,"LOWRIDER","Rap_C_loop",4.1,1,0,0,0,0,0);
			case 35: GoAnim(playerid,"LOWRIDER","Rap_B_loop",4.1,1,0,0,0,0,0);
			case 36: GoAnim(playerid,"LOWRIDER","Rap_A_loop",4.1,1,0,0,0,0,0);
			case 37: GoAnim(playerid,"BSKTBALL","BBALL_idleloop",4.1,1,0,0,0,0,0);
			case 38: ApplyAnimation(playerid,"BSKTBALL","BBALL_Jump_Shot",4.1,0,0,0,0,0,1);
			case 39: ApplyAnimation(playerid,"BSKTBALL","BBALL_pickup",4.1,0,0,0,0,0,1);
			case 40: ApplyAnimation(playerid,"CAMERA","camstnd_cmon",4.1,0,0,0,0,0,1);
			case 41: GoAnim(playerid,"CAR","fixn_car_loop",4.1,1,0,0,0,0,0);
			case 42: GoAnim(playerid,"CAR_CHAT","car_talkm_loop",4.1,1,0,0,0,0,0);
			case 43: GoAnim(playerid,"COP_AMBIENT","coplook_loop",4.1,1,0,0,0,0,0);
			case 44: GoAnim(playerid,"CRACK","Bbalbat_Idle_01",4.1,1,0,0,0,0,0);
			case 45: GoAnim(playerid,"CRACK","Bbalbat_Idle_02",4.1,1,0,0,0,0,0);
			case 46: ApplyAnimation(playerid,"GHANDS","gsign1",4.1,0,0,0,0,0,1);
			case 47: ApplyAnimation(playerid,"GHANDS","gsign2",4.1,0,0,0,0,0,1);
			case 48: ApplyAnimation(playerid,"GHANDS","gsign3",4.1,0,0,0,0,0,1);
			case 49: ApplyAnimation(playerid,"GHANDS","gsign4",4.1,0,0,0,0,0,1);
			case 50: ApplyAnimation(playerid,"GHANDS","gsign5",4.1,0,0,0,0,0,1);
			case 51: ApplyAnimation(playerid,"GHANDS","gsign1LH",4.1,0,0,0,0,0,1);
			case 52: ApplyAnimation(playerid,"GHANDS","gsign2LH",4.1,0,0,0,0,0,1);
			case 53: ApplyAnimation(playerid,"GHANDS","gsign4LH",4.1,0,0,0,0,0,1);
			case 54: GoAnim(playerid,"GRAVEYARD","mrnF_loop",4.1,1,0,0,0,0,0);
			case 55: GoAnim(playerid,"MISC","seat_LR",4.1,1,0,0,0,0,0);
			case 56: GoAnim(playerid,"INT_HOUSE","Lou_in",4.1,0,1,1,1,1,0);
			case 57: GoAnim(playerid,"INT_OFFICE","OFF_sit_Bored_loop",4.1,1,0,0,0,0,0);
			case 58: GoAnim(playerid,"LOWRIDER","F_smklean_loop",4.1,1,0,0,0,0,0);
			case 59: ApplyAnimation(playerid,"MEDIC","CPR",4.1,0,0,0,0,0,1);
			case 60: GoAnim(playerid,"GANGS","LeanIn",4.1,0,1,1,1,1,0);
			case 61: GoAnim(playerid,"MISC","plyrlean_loop",4.1,1,0,0,0,0,0);
			case 62: ApplyAnimation(playerid,"MISC","plyr_shkhead",4.1,0,0,0,0,0,1);
			case 63: GoAnim(playerid,"MISC","scratchballs_01",4.1,1,0,0,0,0,0);
			}
			return 1;
		}
		// Шахта
	case 150: {
			if(!response) return 1;
			SetPVarInt(playerid, "OldMinerSkin",GetPlayerSkin(playerid));
			NullFishJob(playerid);
			SetPlayerSkin(playerid, 16);
			ChatBubbleMe(playerid, "Переоделся(ась)");
			SetPVarInt(playerid, "Miner", 1);
			TextDrawShowForPlayer(playerid, MinerDraw[playerid]);
			SetPlayerAttachedObject( playerid, 3, 18634, 6, 0.078222, 0.000000, 0.110844, 298.897308, 264.126861, 193.350555, 1.000000, 1.000000, 1.000000 );
			SendClientMessage(playerid, COLOR_PAYCHEC, "Вы начали работу на шахте, ищите месторождение руды.");
			SendClientMessage(playerid, COLOR_PAYCHEC, "Чтобы начать добычу на найденом месте (( Нажимайте ЛКМ - Огонь )).");
			return 1;
		}
	case 151: {
			if(!response) return 1;
			SetPlayerSkin(playerid, GetPVarInt(playerid, "OldMinerSkin"));
			ChatBubbleMe(playerid, "Переоделся(ась)");
			SendClientMessageEx(playerid,COLOR_PAYCHEC, "Вы закончили работу, Ваш заработок: %i$",PI[playerid][pJobAmount][0]*2);
			GiveMoney(playerid,PI[playerid][pJobAmount][0]*2);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 3)) RemovePlayerAttachedObject(playerid, 3);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 4)) RemovePlayerAttachedObject(playerid, 4);
			TextDrawHideForPlayer(playerid, MinerDraw[playerid]);
			DeletePVar(playerid, "OldMinerSkin");
			PI[playerid][pJobAmount][0] = 0;
			DeletePVar(playerid, "Miner");
			DeletePVar(playerid, "MinerCount");
			DeletePVar(playerid, "MinerKG_One");
			SavePlayer(playerid);
			return 1;
		}
	case 1560: {
			if(!response) return 1;
			SetPVarInt(playerid, "OldGMinerSkin",GetPlayerSkin(playerid));
			if(strcmp(NamePlayer(playerid),LBizz[1][lOwner]) == 0) SetPlayerSkin(playerid, 234);
			else if(strcmp(NamePlayer(playerid),LBizz[1][lWorker_1]) == 0 || strcmp(NamePlayer(playerid),LBizz[1][lWorker_2]) == 0 || strcmp(NamePlayer(playerid),LBizz[1][lWorker_2]) == 0) SetPlayerSkin(playerid, 202);
			else if(!PI[playerid][pSex]) SetPlayerSkin(playerid, 15+(random(1)*17));
			else if(PI[playerid][pSex]) SetPlayerSkin(playerid, 53);
			ChatBubbleMe(playerid, "Переоделся(ась)");
			SetPVarInt(playerid, "GMiner", 1);
			TextDrawShowForPlayer(playerid, MinerDraw[playerid]);

			//format(spect,32,"AMOUNT: %d GRAMM",AmountLBizz[playerid][0]);
			format(spect,32,"AMOUNT: %f GRAMM",float(GetPVarInt(playerid,"GMinerG_NotGived"))/1000);
			TextDrawSetString(MinerDraw[playerid],spect);
			SetPlayerAttachedObject(playerid,3,18946,5,0.115000,0.023000,0.099999,-1.299997,116.399940,-73.499984,0.365000,1.780999,1.672999);
			//			SetPlayerAttachedObject( playerid, 3, 18634, 6, 0.078222, 0.000000, 0.110844, 298.897308, 264.126861, 193.350555, 1.000000, 1.000000, 1.000000 );
			SendClientMessage(playerid, COLOR_PAYCHEC, "Вы начали работу, сначала необходимо наполнить тарелку породой.");
			SendClientMessage(playerid, COLOR_PAYCHEC, "Далее ее нужно промыть, а также сыскать в ней золото.");
			DisablePlayerCheckpoint(playerid);
			TextDrawShowForPlayer(playerid, MinerDraw[playerid]);
			//			new tmp;
			//			SetPlayerCheckpoint(playerid, -1360.9905+(tmp*1.18),2101.8550+(tmp*1.06),44.8636, 1.0);
			return 1;
		}
	case 1561: {
			if(!response) return 1;
			if(GetPVarInt(playerid, "GMinerG_NotGived") != 0) return SendClientMessage(playerid,COLOR_GREY,"Сначала вам нужно сдать то, что у вас на руках. (соседний стол)");
			SetPlayerSkin(playerid, GetPVarInt(playerid, "OldGMinerSkin"));
			ChatBubbleMe(playerid, "Переоделся(ась)");
			SendClientMessageEx(playerid,COLOR_PAYCHEC, "Вы закончили работу");//, Ваш заработок: %i$",AmountLBizz[playerid][0]*LBizz[1][lPrice]);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 3)) RemovePlayerAttachedObject(playerid, 3);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 4)) RemovePlayerAttachedObject(playerid, 4);
			TextDrawHideForPlayer(playerid, MinerDraw[playerid]);
			DeletePVar(playerid, "OldGMinerSkin");
			DeletePVar(playerid, "GMiner");
			DeletePVar(playerid, "GMinerCount");
			DeletePVar(playerid, "GMinerG_One");
			DeletePVar(playerid, "GMinerG_NotGived");
			SetPlayerSpecialAction(playerid,0);
			DisablePlayerCheckpoint(playerid);
			SavePlayer(playerid);
			return 1;
		}
	case 1570: {
			if(!response) return 1;
			SetPVarInt(playerid, "OldCollectorSkin",GetPlayerSkin(playerid));
			if(!PI[playerid][pSex]) SetPlayerSkin(playerid, 35+random(2));
			else if(PI[playerid][pSex]) SetPlayerSkin(playerid, 53);
			ChatBubbleMe(playerid, "Переоделся(ась)");
			SetPVarInt(playerid, "Collector", 1);
			TextDrawShowForPlayer(playerid,MinerDraw[playerid]);
			format(spect,32,"AMOUNT: %i",AmountLBizz[playerid][1]);
			TextDrawSetString(MinerDraw[playerid],spect);
			SetPlayerAttachedObject(playerid,3,916,5,0.068999,0.100000,0.100999,-78.999992,-7.300001,-71.400024,1.000000,1.000000,1.000000);
			SendClientMessage(playerid, COLOR_PAYCHEC, "Вы начали работу, идите в сад срывать фрукты (клавишей ПКМ)");
			SendClientMessage(playerid, COLOR_PAYCHEC, "После сбора вам нужно отнести их в машину фермера.");

			for(new x;x < 76;x++) {
				if(GardenCheckpoints[x] != 0) TogglePlayerDynamicCP(playerid, GardenCheckpoints[x], 1);
			}
			return 1;
		}
	case 1571: {
			if(!response) return 1;
			if(GetPVarInt(playerid, "Collector_NotGived") != 0) return SendClientMessage(playerid,COLOR_GREY,"Сначала вам нужно сдать то, что вы уже собрали на склад.");
			SetPlayerSkin(playerid, GetPVarInt(playerid, "OldCollectorSkin"));
			ChatBubbleMe(playerid, "Переоделся(ась)");
			SendClientMessageEx(playerid,COLOR_PAYCHEC, "Вы закончили работу, ваш заработок за %i кг яблок составил: $%i",AmountLBizz[playerid][1]/15,AmountLBizz[playerid][1]/15*LBizz[2][lPrice]);//, Ваш заработок: %i$",AmountLBizz[playerid][0]*LBizz[1][lPrice]);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 3)) RemovePlayerAttachedObject(playerid, 3);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 4)) RemovePlayerAttachedObject(playerid, 4);
			GiveMoney(playerid,AmountLBizz[playerid][1]/15*LBizz[2][lPrice]);
			AmountLBizz[playerid][1] = 0;
			TextDrawHideForPlayer(playerid, MinerDraw[playerid]);
			DeletePVar(playerid, "OldCollectorSkin");
			DeletePVar(playerid, "Collector");
			DeletePVar(playerid, "CollectorCount");
			DeletePVar(playerid, "Collector_One");
			DeletePVar(playerid, "Collector_NotGived");
			SetPlayerSpecialAction(playerid,0);
			DisablePlayerCheckpoint(playerid);
			SavePlayer(playerid);
			for(new x;x < 76;x++) {
				if(GardenCheckpoints[x] != 0) TogglePlayerDynamicCP(playerid, GardenCheckpoints[x], 0);
			}
			return 1;
		}
	case 9294: {
			if(!response) return DeletePVar(playerid,"LBMenu_Selected");
			if(listitem == 0) {
				strin = "";
				format(strin,192,"\t\tРаботники:\n1 - %s\n2 - %s\n3 - %s",LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lWorker_1],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lWorker_2],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lWorker_3]);
				SPD(playerid,9295,DIALOG_STYLE_LIST,"Управление работниками",strin,"Выбрать","Закрыть");
			}
			else if(listitem == 1) {
				if(GetPVarInt(playerid,"LBMenu_Selected") == 1)
				format(
				strin,
				512,
				"\t\tСтатистика бизнеса:\t\t\nВладелец: %s.\nРаботники: %s, %s, %s.\nСобрано руды: %i кг\n\nНайдено золота: %i грамм\nЦена за грамм: %i",
				LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lOwner],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lWorker_1],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lWorker_2],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lWorker_3],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lMaterials][0],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lMaterials][1],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lPrice]
				);
				else
				format(
				strin,
				512,
				"\t\tСтатистика бизнеса:\t\t\nВладелец: %s.\nРаботники: %s, %s, %s.\nСобрано яблок %i кг\n\nВоды: %i грамм\nЦена за яблоко: %i",
				LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lOwner],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lWorker_1],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lWorker_2],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lWorker_3],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lMaterials][0],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lMaterials][1],LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lPrice]
				);
				SPD(playerid,9999,DIALOG_STYLE_MSGBOX,"Статистика",strin,"Закрыть","");
				DeletePVar(playerid,"LBMenu_Selected");
			}
			else if(listitem == 2) {
				//PlusBankMoney(playerid, LBizz[1][lCost]);
				PlusBankMoney(playerid, LBizz[1][lCost]);
				SendClientMessage(playerid,COLOR_YELLOW,"Вы продали предприятие!");
				format(LBizz[1][lOwner],MAX_PLAYER_NAME,"None");
				format(query, sizeof(query), "UPDATE "TABLE_LBIZZ" SET `owner`='None' WHERE `id` = '%i'", 1);

				mysql_function_query(cHandle, query, false, "", "");
				DeletePVar(playerid,"LBMenu_Selected");
			}
			return true;
		}
	case 9295: {
			if(!response || listitem == 0) return DeletePVar(playerid,"LBMenu_Selected");
			if(strcmp(LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lOwner],NamePlayer(playerid)) != 0) return true;
			SetPVarInt(playerid,"GetWorker",listitem);
			switch(listitem) {
				case 1: {
					if(!strcmp(LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lWorker_1],"None"))
						SPD(playerid,9297,DIALOG_STYLE_INPUT,"Устройство работника","Введите ID или имя работника, которого хотите устроить на данный пост","Выбрать","Отмена");
					else
						SPD(playerid,9296,DIALOG_STYLE_MSGBOX,"Управление работником","Желаете ли вы уволить данного сотрудика?","Уволить","Отмена");
				}
				case 2: {
					if(!strcmp(LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lWorker_2],"None"))
						SPD(playerid,9297,DIALOG_STYLE_INPUT,"Устройство работника","Введите ID или имя работника, которого хотите устроить на данный пост","Выбрать","Отмена");
					else
						SPD(playerid,9296,DIALOG_STYLE_MSGBOX,"Управление работником","Желаете ли вы уволить данного сотрудика?","Уволить","Отмена");
				}
				case 3: {
					if(!strcmp(LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lWorker_3],"None"))
						SPD(playerid,9297,DIALOG_STYLE_INPUT,"Устройство работника","Введите ID или имя работника, которого хотите устроить на данный пост","Выбрать","Отмена");
					else
						SPD(playerid,9296,DIALOG_STYLE_MSGBOX,"Управление работником","Желаете ли вы уволить данного сотрудика?","Уволить","Отмена");
				}
			}
			return true;
		}
	case 9296: {
			if(!response || listitem == 0) return DeletePVar(playerid,"LBMenu_Selected");
			if(GetPVarInt(playerid,"GetWorker") == 1) SendClientMessageEx(playerid,COLOR_YELLOW,"Вы успешно уволили %s.",LBizz[1][lWorker_1]), format(LBizz[1][lWorker_1],MAX_PLAYER_NAME,"None");
			else if(GetPVarInt(playerid,"GetWorker") == 2) SendClientMessageEx(playerid,COLOR_YELLOW,"Вы успешно уволили %s.",LBizz[1][lWorker_2]), format(LBizz[1][lWorker_2],MAX_PLAYER_NAME,"None");
			else if(GetPVarInt(playerid,"GetWorker") == 3) SendClientMessageEx(playerid,COLOR_YELLOW,"Вы успешно уволили %s.",LBizz[1][lWorker_3]), format(LBizz[1][lWorker_3],MAX_PLAYER_NAME,"None");
			format(query, sizeof(query), "UPDATE "TABLE_LBIZZ" SET `worker%i`='None' WHERE `id` = '%i'", GetPVarInt(playerid,"GetWorker"),GetPVarInt(playerid,"LBMenu_Selected"));

			mysql_function_query(cHandle, query, false, "", "");
			DeletePVar(playerid,"LBMenu_Selected");
			return DeletePVar(playerid,"GetWorker");
		}
	case 9297: {
			if(!response) return DeletePVar(playerid,"LBMenu_Selected");
			if(sscanf(inputtext,"u",inputtext[0])) return SendClientMessage(playerid,COLOR_GREY,"Вы ввели неверный ID или имя."),DeletePVar(playerid,"GetWorker");
			if(!strcmp(LBizz[1][lWorker_1],NamePlayer(inputtext[0])) || !strcmp(LBizz[1][lWorker_2],NamePlayer(inputtext[0])) || !strcmp(LBizz[1][lWorker_3],NamePlayer(inputtext[0]))) return SendClientMessage(playerid,COLOR_GREY,"Данный человек уже работает на вас."),DeletePVar(playerid,"GetWorker");
			if(inputtext[0] == GetPVarInt(playerid,"AcceptLBid")) return SendClientMessage(playerid,COLOR_GREY,"Вы уже отправили приглашение данному игроку."),DeletePVar(playerid,"GetWorker");
			new Float:PPos[3];
			GetPlayerPos(playerid,PPos[0],PPos[1],PPos[2]);
			if(!IsPlayerInRangeOfPoint(inputtext[0],20.0,PPos[0],PPos[1],PPos[2])) return SendClientMessage(playerid,COLOR_GREY,"Игрок должен быть неподалеку от вас."),DeletePVar(playerid,"GetWorker");
			SetPVarInt(playerid,"AcceptLBid",inputtext[0]);
			SetPVarInt(inputtext[0],"AcceptedLBid",playerid);
			SetPVarInt(inputtext[0],"AcceptedtLB",GetPVarInt(playerid,"LBMenu_Selected"));
			DeletePVar(playerid,"LBMenu_Selected");
			strin = "";
			format(strin,192,"%s пригласил вас на работу помощником в '%s', принимаете ли вы приглашение?",NamePlayer(playerid),LBizz[GetPVarInt(playerid,"LBMenu_Selected")][lName]);
			SPD(inputtext[0],9298,DIALOG_STYLE_MSGBOX,"Приглашение",strin,"Да","Отказ");
			return SendClientMessage(playerid,COLOR_YELLOW,"Приглашение было отправлено.");
		}
	case 9298: {
			new playerd = GetPVarInt(playerid,"AcceptedLBid");
			if(!response) { SendClientMessageEx(playerd,COLOR_GREY,"%s отказался от вашего предложения.",NamePlayer(playerid)); DeletePVar(GetPVarInt(playerid,"AcceptedLBid"),"AcceptLBid"); DeletePVar(playerd,"GetWorker"); DeletePVar(playerid,"AcceptedLBid"); DeletePVar(playerid,"AcceptedtLB");}
			SendClientMessage(playerid,COLOR_YELLOW,"Вы приняли предложение!");
			if(GetPVarInt(playerd,"GetWorker") == 1) format(LBizz[GetPVarInt(playerid,"AcceptedtLB")][lWorker_1],MAX_PLAYER_NAME,"%s",NamePlayer(playerid)), SendClientMessageEx(playerd,COLOR_YELLOW,"Вы успешно назначили %s.",LBizz[GetPVarInt(playerid,"AcceptedtLB")][lWorker_1]);
			else if(GetPVarInt(playerd,"GetWorker") == 2) format(LBizz[GetPVarInt(playerid,"AcceptedtLB")][lWorker_2],MAX_PLAYER_NAME,"%s",NamePlayer(playerid)), SendClientMessageEx(playerd,COLOR_YELLOW,"Вы успешно назначили %s.",LBizz[GetPVarInt(playerid,"AcceptedtLB")][lWorker_2]);
			else if(GetPVarInt(playerd,"GetWorker") == 3) format(LBizz[GetPVarInt(playerid,"AcceptedtLB")][lWorker_3],MAX_PLAYER_NAME,"%s",NamePlayer(playerid)), SendClientMessageEx(playerd,COLOR_YELLOW,"Вы успешно назначили %s.",LBizz[GetPVarInt(playerid,"AcceptedtLB")][lWorker_3]);
			format(query, sizeof(query), "UPDATE "TABLE_LBIZZ" SET `worker%i`='%s' WHERE `id` = '%i'", GetPVarInt(playerd,"GetWorker"),NamePlayer(playerid),GetPVarInt(playerid,"AcceptedtLB"));

			mysql_function_query(cHandle, query, false, "", "");
			return DeletePVar(GetPVarInt(playerid,"AcceptedLBid"),"AcceptLBid"),DeletePVar(playerid,"AcceptedtLB"),DeletePVar(playerd,"GetWorker"), DeletePVar(playerid,"AcceptedLBid");
		}
	case 9299: {
			if(!response)return DeletePVar(playerid,"LBMenu_Selected");
			//if(PI[playerid][pPin] == 0) return SendClientMessage(playerid,COLOR_WHITE,"Вы не можете купить эту работу без счета в банке!");
			if(PI[playerid][pBank] <= LBizz[1][lCost]) return SendClientMessage(playerid,COLOR_WHITE,"У вас недостаточно денег на вашем банковском счету.");
			//MinusBankMoney(playerid, LBizz[1][lCost]);
			MinusBankMoney(playerid, LBizz[1][lCost]);
			SendClientMessage(playerid,COLOR_YELLOW,"Вы купили предприятие! Деньги списаны с банковского счета.");
			format(LBizz[1][lOwner],MAX_PLAYER_NAME,"%s",NamePlayer(playerid));
			format(query, sizeof(query), "UPDATE "TABLE_LBIZZ" SET `owner`='%s' WHERE `id` = '%i'", NamePlayer(playerid),GetPVarInt(playerid,"LBMenu_Selected"));

			mysql_function_query(cHandle, query, false, "", "");
			DeletePVar(playerid,"LBMenu_Selected");
			return 1;
		}
	case 1660: {
			if(!response) return 1;
			switch(listitem) {
			case 0: {
					GiveInventory(playerid,19,35);
					GiveInventory(playerid,21,40);
					GiveInventory(playerid,26,300);
					SetHealth(playerid, 100.0);
					PI[playerid][pHeal] = 100;
					PI[playerid][pArmur] = 100;
					SetPlayerArmorAC(playerid, 100);
					SendClientMessageEx(playerid,COLOR_PAYCHEC,"Вы взяли обычную экипировку. Вам выдано: Desert Eagle(35 патронов),Shotgun(40 патронов),AK-47(300 патронов).");
				}
			case 1: {
					GiveInventory(playerid,19,35);
					GiveInventory(playerid,21,40);
					GiveInventory(playerid,26,300);
					GiveInventory(playerid,29,25);
					SetHealth(playerid, 100.0);
					PI[playerid][pHeal] = 100;
					PI[playerid][pArmur] = 100;
					SetPlayerArmorAC(playerid, 100);
					SendClientMessageEx(playerid,COLOR_PAYCHEC,"Вы взяли спец.экипировку. Вам выдано: Desert Eagle(35 патронов),Shotgun(40 патронов),AK-47(300 патронов),Sniper Rifle(25 патронов).");
				}
			}
			return 1;
		}
		//Рыболов
	case 1700: {
			if(!response) return 1;
			Fishjob[playerid] = 1;
			FishMojno[playerid] = 1;
			NullFishJob(playerid);
			TextDrawShowForPlayer(playerid, FishDraw[playerid]);
			SendClientMessage(playerid, COLOR_PAYCHEC, "Вы начали работу рыболова, ловите рыбу.");
			SendClientMessage(playerid, COLOR_PAYCHEC, "Плывите на рыбадской лодке на красный чекпоинт.");
			SendClientMessage(playerid, COLOR_PAYCHEC, "Чтобы начать рыбачить (( Введите /fish )).");
			SetPlayerAttachedObject(playerid, 0, 18632, 6, 0.067000, 0.016999, 0.072999, -168.800018, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000, 0, 0);
			FishStart[playerid] = 1;
			switch(random(4)) {
			case 0: return SetPlayerCheckpoint(playerid,255.7908,-2032.7637,-0.0821,4.0);
			case 1: return SetPlayerCheckpoint(playerid,128.5787,-2017.2180,-0.2506,4.0);
			case 2: return SetPlayerCheckpoint(playerid,188.4454,-2078.6584,-0.3262,4.0);
			case 3: return SetPlayerCheckpoint(playerid,307.8037,-2110.8701,-0.6546,4.0);
			}
			return 1;
		}
	case 1701: {
			if(!response) return 1;
			new zp = PlayerFish[playerid];
			TextDrawHideForPlayer(playerid, FishDraw[playerid]);
			SendClientMessageEx(playerid,COLOR_PAYCHEC, "Вы закончили работу, Ваш заработок: %i$",zp);
			GiveMoney(playerid,zp);
			RemovePlayerAttachedObject(playerid, 0);
			DisablePlayerCheckpoint(playerid);
			PlayerFish[playerid] = 0;
			Fishjob[playerid] = 0;
			FishStart[playerid] = 0;
			FishMojno[playerid] = 0;
			SavePlayer(playerid);
			return 1;
		}
	case 1705: {
			if(response) {
				if(StartGarden[playerid] != 0) return SendClientMessage(playerid,COLOR_GREY,"Ошибка: Вы уже работаете садовода!");
				{
					NullFishJob(playerid);
					SendClientMessage(playerid, COLOR_PAYCHEC, "Вы успешно устроились на работу садовода!");
					StartGarden[playerid] = 1;

					SetPVarInt(playerid,"TaxiCheck",0);
					SetPVarInt(playerid,"GPS",0);
					SetPVarInt(playerid,"GPSCar",1);
					SetPVarInt(playerid,"YEAH",0);
					TextDrawShowForPlayer(playerid,GardenDraw[playerid]);
					SetPVarInt(playerid, "Garden", 1);
					AmmountWood[playerid] = 0;
					new rand = random(sizeof(TreeSad));
					SetPlayerCheckpoint(playerid,TreeSad[rand][0],TreeSad[rand][1],TreeSad[rand][2],3.0);
					return true;
				}
			}
			else {
				SendClientMessage(playerid, COLOR_PAYCHEC, "Вы успешно уволились с работы садовода!");
				new money = AmmountWood[playerid];
				StartGarden[playerid] = 0;
				GiveMoney(playerid,money);
				TextDrawHideForPlayer(playerid,GardenDraw[playerid]);
				strin = "";
				format(strin, sizeof(strin), "~g~+%d$",money);
				GameTextForPlayer(playerid,strin,5000,1);
				RemovePlayerAttachedObject(playerid, 4);
				DisablePlayerCheckpoint(playerid);
				AmmountWood[playerid] = 0;
				DeletePVar(playerid, "Garden");
				SavePlayer(playerid);
			}
			return true;
		}
	case 1850: {
			new targetid = GetPVarInt(playerid, "TargetID");
			switch(listitem) {
			case 0: SPD(playerid,1851,DIALOG_STYLE_INPUT,"Передать деньги","Введите кол-во денег:","Далее","Отмена");
			case 1: ShowPassForPlayer(playerid, targetid);
			case 2: {

					strin = "";
					format(strin,sizeof(strin),"{ffffff}Водительские права:\t\t\t%s\n{ffffff}Водный транспорт:\t\t\t%s\n{ffffff}Воздушный транспорт:\t\t%s\n{ffffff}Лицензия на оружие:\t\t\t%s\n{ffffff}Лицензия на бизнес:\t\t\t%s",(!PI[playerid][pLic][0]) ? ("{FF6347}Нет"):("{9ACD32}Да"),(!PI[playerid][pLic][1]) ? ("{FF6347}Нет"):("{9ACD32}Да"),(!PI[playerid][pLic][2]) ? ("{FF6347}Нет"):("{9ACD32}Да"),(!PI[playerid][pLic][3]) ? ("{FF6347}Нет"):("{9ACD32}Да"),(!PI[playerid][pLic][4]) ? ("{FF6347}Нет"):("{9ACD32}Да"));
					SPD(targetid,0,0,"{96e300}Лицензии игрока",strin,"Закрыть","");
					strin = "";
					format(strin, 90, "%s показывает свои лицензии %s",NamePlayer(playerid),NamePlayer(targetid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
				}
			case 3: {
					strin = "";
					format(strin,sizeof(strin), "Навыки игрока %s:\n\nSDPistol:\t%i%%\t%s\nDeagle:\t%i%%\t%s\nShotGun:\t%i%%\t%s\nMP5\t\t%i%%\t%s\nAK47:\t\t%i%%\t%s\nM4A1:\t\t%i%%\t%s",
					NamePlayer(playerid),PI[playerid][pGunSkill][0],ToDevelopSkills(PI[playerid][pGunSkill][0]),
					PI[playerid][pGunSkill][1],ToDevelopSkills(PI[playerid][pGunSkill][1]),
					PI[playerid][pGunSkill][2],ToDevelopSkills(PI[playerid][pGunSkill][2]),
					PI[playerid][pGunSkill][3],ToDevelopSkills(PI[playerid][pGunSkill][3]),
					PI[playerid][pGunSkill][4],ToDevelopSkills(PI[playerid][pGunSkill][4]),
					PI[playerid][pGunSkill][5],ToDevelopSkills(PI[playerid][pGunSkill][5]));
					if(!ProxDetectorS(5.0, playerid, targetid)) return SendClientMessage(playerid,COLOR_GREY,"Игрок не рядом с вами");
					SPD(targetid,0,DIALOG_STYLE_MSGBOX, "Навыки владения оружием",strin, "Закрыть", "");
					strin = "";
					format(strin, 90, "%s показывает свои навыки владения оружием %s",NamePlayer(playerid),NamePlayer(targetid));
					ProxDetectorNew(playerid, 30.0, COLOR_PURPLE, strin);
				}

			}
		}
	case 1851: {
			if(!response) return 1;
			new text[16];
			if(sscanf(inputtext, "d", params[0]) || params[0] < 1 || params[0] > 100000) return SendClientMessage(playerid, COLOR_GREY, "Кол-во долларов от 1 до 100000");
			format(text, 16, "%d %d", GetPVarInt(playerid, "TargetID"), params[0]), cmd::pay(playerid,text);
			return 1;
		}
		// Грузчики
	case 152: {
			if(!response) return 1;
			NullFishJob(playerid);
			SetPVarInt(playerid, "OldGruzSkin",GetPlayerSkin(playerid));
			SetPlayerSkin(playerid, 260);
			SetPVarInt(playerid, "Gruz", 1);
			SetPlayerCheckpoint(playerid,2042.6589,-1958.3080,14.3957,1.4);
			TextDrawShowForPlayer(playerid, AmountDraw[playerid]);
			SendClientMessage(playerid, COLOR_PAYCHEC, "Вы устроились грузчиком!");
			return 1;
		}
	case 153: {
			if(!response) return 1;
			SetPlayerSkin(playerid, GetPVarInt(playerid, "OldGruzSkin"));
			SendClientMessageEx(playerid,COLOR_PAYCHEC, "Вы закончили рабочий день, Ваш заработок: %i$",PI[playerid][pJobAmount][1]*250);
			GiveMoney(playerid,PI[playerid][pJobAmount][1]*250);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 3)) RemovePlayerAttachedObject(playerid, 3);
			PI[playerid][pJobAmount][1] = 0;
			DeletePVar(playerid, "OldGruzSkin"); DeletePVar(playerid, "Gruz");
			TextDrawHideForPlayer(playerid, AmountDraw[playerid]);
			DisablePlayerCheckpoint(playerid);
			SavePlayer(playerid);
			return 1;
		}
		// Лесопилка
	case 154: {
			if(!response) return 1;
			SetPVarInt(playerid, "OldLessSkin",GetPlayerSkin(playerid));
			SetPlayerSkin(playerid, 260);
			SetPVarInt(playerid, "LessPil", 1);
			TextDrawShowForPlayer(playerid, ProcentDraw[playerid]);
			TextDrawShowForPlayer(playerid, AmountLDraw[playerid]);
			SetPVarInt(playerid, "Derevo", TOTALDEREVO);
			TOTALDEREVO++;
			SetPlayerCheckpoint(playerid, Derevo[GetPVarInt(playerid, "Derevo")][0],Derevo[GetPVarInt(playerid, "Derevo")][1],Derevo[GetPVarInt(playerid, "Derevo")][2], 3.0);
			GiveWeapon(playerid, 9, 1);
			SendClientMessage(playerid, COLOR_PAYCHEC, "Вы начали работу на лесопилке, спилите дерево.");
			return 1;
		}
	case 155: {
			if(!response) return 1;
			SetPlayerSkin(playerid, GetPVarInt(playerid, "OldLessSkin"));
			SendClientMessageEx(playerid,COLOR_PAYCHEC, "Вы закончили рабочий день, Ваш заработок: %i$",PI[playerid][pJobAmount][2]*2);
			GiveMoney(playerid,PI[playerid][pJobAmount][2]*2);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 3)) RemovePlayerAttachedObject(playerid, 3);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 4)) RemovePlayerAttachedObject(playerid, 4);
			PI[playerid][pJobAmount][2] = 0;
			DeletePVar(playerid, "OldLessSkin");
			DeletePVar(playerid, "LessPil");
			DeletePVar(playerid, "Derevo");
			TextDrawHideForPlayer(playerid, ProcentDraw[playerid]);
			TextDrawHideForPlayer(playerid, AmountLDraw[playerid]);
			DisablePlayerCheckpoint(playerid);
			ResetWeapon(playerid);
			SavePlayer(playerid);
			return 1;
		}
		//
	case 6666: {
			if(!response) return 1;
			if(GetPlayerCars(playerid) < 2) {
				new i = GetPVarInt(playerid, "PlayerCars");
				BuyCar(playerid,i);
			}
			return 1;
		}
	case 6669: {
			if(response) {
			    new c = PI[playerid][pCars][GetPVarInt(playerid,"_selectedMyCar") - 1];
				new i = CarInfo[c][cID];

				query = "";
				format(query, sizeof(query), "DELETE FROM "TABLE_CARS" WHERE `owner` = '%s' and `model` = '%d' LIMIT 1",NamePlayer(playerid),GetVehicleModel(CarInfo[c][cID]));
				mysql_function_query(cHandle, query, false, "", "");

			    DestroyVehicle(i);
			    Delete3DTextLabel(CarInfo[c][cText]);

				CarInfo[c][cColor][0] = 0;
				CarInfo[c][cColor][1] = 0;
				CarInfo[c][cModel] = 0;
				CarInfo[c][cFuel] = 0;
				CarInfo[c][cLock] = 0;
				CarInfo[c][cX] = 0.0;
				CarInfo[c][cY] = 0.0;
				CarInfo[c][cZ] = 0.0;
				CarInfo[c][cFa] = 0.0;

				TOTALCARS--;

			    PI[playerid][pCars][GetPVarInt(playerid,"_selectedMyCar")-1] = 0;
				GiveMoney(playerid,GetPVarInt(playerid,"_priceCar"));
				SendClientMessageEx(playerid,COLOR_PAYCHEC,"Поздравляем! Вы успешно продали свой автомобиль за %d$!",VehicleNameS[CarInfo[PI[playerid][pCars][0]][cModel]-400],GetPVarInt(playerid,"_priceCar"));

				strmid(CarInfo[c][cOwner],"None",0,strlen("None"),MAX_PLAYER_NAME);
			}
			return 1;
		}
	case 6667: {
			if(!response) return 1;
			SetPVarInt(playerid, "AntiBreik", 3);
			for(new i; i < 10; i++) PlayerTextDrawShow(playerid, AutoSalonTD[i][playerid]);
			SelectTextDraw(playerid,0xA3B4C5FF);
			SetPlayerVirtualWorld(playerid,0);
			TogglePlayerControllable(playerid,0);
			InShop[playerid] = 1;
			worldcar[playerid] = 1 + playerid;
			BuyVeh[playerid] = CreateVehicle(Cars_C[pPressed[playerid]][0],536.2600,-1301.2469,16.2431,327.7638,ColorVeh[playerid][0]=random(10),ColorVeh[playerid][1]=random(10),10000);
			LinkVehicleToInterior(BuyVeh[playerid],0);
			SetPlayerInterior(playerid,0);
			SetVehicleVirtualWorld(BuyVeh[playerid], worldcar[playerid]);
			SetPlayerVirtualWorld(playerid,worldcar[playerid]);
			PutPlayerInVehicleEx(playerid,BuyVeh[playerid],0);
			SetPlayerCameraPos(playerid,528.9800,-1299.3888,18.5611);
			SetPlayerCameraLookAt(playerid,536.2600,-1301.2469,16.2431);
			strin = "";
			format(strin,64,"~w~%s",VehicleNameS[Cars_C[pPressed[playerid]][0]-400]);
			PlayerTextDrawSetString(playerid,AutoSalonTD[4][playerid],strin);
			strin = "";
			format(strin,64,"~g~$%d",Cars_C[pPressed[playerid]][1]);
			PlayerTextDrawSetString(playerid,AutoSalonTD[5][playerid],strin);
			PlayerTextDrawSetString(playerid,AutoSalonTD[6][playerid],"~w~Fuel:~r~150");
			SendClientMessage(playerid, COLOR_GREEN, "Используйте кнопки 'Buy' - чтобы купить, 'ESC' - чтобы выйти.");
			SendClientMessage(playerid, COLOR_GREEN, "Используйте стрелки - чтобы купить следующие авто.");
			return 1;
		}
	case 6671: {
			if(!response) return 1;
			SetPVarInt(playerid, "AntiBreik", 3);
			for(new i; i < 10; i++) PlayerTextDrawHide(playerid, AutoSalonTD[i][playerid]);
			DestroyVehicle(BuyVeh[playerid]);
			t_SetPlayerPos(playerid,757.4183,-1641.0552,991.0859);
			TogglePlayerControllable(playerid,0);
			SetTimerEx("Unfreez",2500,false,"i",playerid);
			SetPlayerFacingAngle(playerid, 88.9844);
			SetPlayerInterior(playerid,0);
			SetPlayerVirtualWorld(playerid,0);
			CancelSelectTextDraw(playerid);
			SetCameraBehindPlayer(playerid);
			return 1;

		}
	case 6675: {
			if(!response) return 1;
			if(GetPlayerCars(playerid)) {
				if(GetPVarInt(playerid,"Wheels") > 1) {
					if(GetPVarInt(playerid,"Wheels") == 0) PI[playerid][pWheels] = 0;
					else if(GetPVarInt(playerid,"Wheels") == 1) PI[playerid][pWheels] = 0;
					else if(GetPVarInt(playerid,"Wheels") == 2) PI[playerid][pWheels] = 1074;
					else if(GetPVarInt(playerid,"Wheels") == 3) PI[playerid][pWheels] = 1076;
					else if(GetPVarInt(playerid,"Wheels") == 4) PI[playerid][pWheels] = 1077;
					else if(GetPVarInt(playerid,"Wheels") == 5) PI[playerid][pWheels] = 1078;
					else if(GetPVarInt(playerid,"Wheels") == 6) PI[playerid][pWheels] = 1081;
					else if(GetPVarInt(playerid,"Wheels") == 7) PI[playerid][pWheels] = 1085;
					else if(GetPVarInt(playerid,"Wheels") == 8) PI[playerid][pWheels] = 1083;
					else if(GetPVarInt(playerid,"Wheels") == 9) PI[playerid][pWheels] = 1073;
					AC_AddVehicleComponent(GetPlayerVehicleID(playerid),PI[playerid][pWheels]);
					SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы установили новые колеса.");
				}
				if(GetPVarInt(playerid,"Hydraulics") == 1) {
					PI[playerid][pHydraulics] = 1087;
					AC_AddVehicleComponent(GetPlayerVehicleID(playerid),PI[playerid][pHydraulics]);
					SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы установили гидравлику.");
				}
				if(GetPVarInt(playerid,"Nitro") > 1) {
					if(GetPVarInt(playerid,"Nitro") == 0) PI[playerid][pNitro] = 0;
					else if(GetPVarInt(playerid,"Nitro") == 1) PI[playerid][pNitro] = 0;
					else if(GetPVarInt(playerid,"Nitro") == 2) PI[playerid][pNitro] = 1009;
					else if(GetPVarInt(playerid,"Nitro") == 3) PI[playerid][pNitro] = 1010;
					else if(GetPVarInt(playerid,"Nitro") == 4) PI[playerid][pNitro] = 1010;
					AC_AddVehicleComponent(GetPlayerVehicleID(playerid),PI[playerid][pNitro]);
					SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы установили нитро ускорение.");
				}
				if(GetPVarInt(playerid,"Spoilers") > 1) {
					new TuneID[2], c = GetPlayerVehicleID(playerid);
					if(GetVehicleModel(c) == 562) TuneID[0] = 1146, TuneID[1] = 1147;
					else if(GetVehicleModel(c) == 560) TuneID[0] = 1138, TuneID[1] = 1139;
					else if(GetVehicleModel(c) == 565) TuneID[0] = 1049, TuneID[1] = 1050;
					else if(GetVehicleModel(c) == 561) TuneID[0] = 1058, TuneID[1] = 1060;
					else if(GetVehicleModel(c) == 559) TuneID[0] = 1158, TuneID[1] = 1162;
					else if(GetVehicleModel(c) == 558) TuneID[0] = 1063, TuneID[1] = 1064;
					if(GetPVarInt(playerid,"Spoilers") == 1) PI[playerid][pSpoilers] = 0;
					else if(GetPVarInt(playerid,"Spoilers") == 2) PI[playerid][pSpoilers] = TuneID[0];
					else if(GetPVarInt(playerid,"Spoilers") == 3) PI[playerid][pSpoilers] = TuneID[1];
					AC_AddVehicleComponent(GetPlayerVehicleID(playerid),PI[playerid][pSpoilers]);
					SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы установили новый спойлер.");
				}
				if(GetPVarInt(playerid,"HBumper") > 1) {
					new TuneID[2], c = GetPlayerVehicleID(playerid);
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
					else if(GetPVarInt(playerid,"HBumper") == 2) PI[playerid][pHBumper] = TuneID[0];
					else if(GetPVarInt(playerid,"HBumper") == 3) PI[playerid][pHBumper] = TuneID[1];
					AC_AddVehicleComponent(GetPlayerVehicleID(playerid),PI[playerid][pHBumper]);
					SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы установили новый передний бампер.");
				}
				if(GetPVarInt(playerid,"BBumper") > 1) {
					new TuneID[2], c = GetPlayerVehicleID(playerid);
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
					else if(GetPVarInt(playerid,"BBumper") == 2) PI[playerid][pBBumper] = TuneID[0];
					else if(GetPVarInt(playerid,"BBumper") == 3) PI[playerid][pBBumper] = TuneID[1];
					AC_AddVehicleComponent(GetPlayerVehicleID(playerid),PI[playerid][pBBumper]);
					SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы установили новый задний бампер.");
				}
				if(GetPVarInt(playerid,"Neons") > 1) {
					if(GetPVarInt(playerid,"Neons") == 1) PI[playerid][pNeons] = 0;
					else if(GetPVarInt(playerid,"Neons") == 2) PI[playerid][pNeons] = 18652;
					else if(GetPVarInt(playerid,"Neons") == 3) PI[playerid][pNeons] = 18647;
					else if(GetPVarInt(playerid,"Neons") == 4) PI[playerid][pNeons] = 18649;
					else if(GetPVarInt(playerid,"Neons") == 5) PI[playerid][pNeons] = 18648;
					else if(GetPVarInt(playerid,"Neons") == 6) PI[playerid][pNeons] = 18650;
					if(PI[playerid][pNeons] > 0) {
						NeonObject[playerid][0] = CreateDynamicObject(PI[playerid][pNeons],0,0,0,0,0,0,-1,-1,-1,150.0);
						AttachDynamicObjectToVehicle(NeonObject[playerid][0], GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
						NeonObject[playerid][1] = CreateDynamicObject(PI[playerid][pNeons],0,0,0,0,0,0,-1,-1,-1,150.0);
						AttachDynamicObjectToVehicle(NeonObject[playerid][1], GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
					}
					SendClientMessageEx(playerid, COLOR_PAYCHEC, "Вы установили подцветку.");
				}
				NullComponents(playerid);
			}
			return 1;
		}
	case 6676: {
			if(!response) return 1;
			ExitTuning(playerid),CancelSelectTextDraw(playerid);
			NullComponentid(playerid);
			return 1;
		}
	case 6686: {
			if(!strlen(inputtext) || (!IsNumeric(inputtext))) SPD(playerid, 6686, DIALOG_STYLE_INPUT, "Баланс", "Введите кол-во:", "Готово", "Отмена");
			if(PI[playerid][pCash] < strval(inputtext)) return SendClientMessageEx(playerid, COLOR_GREY, "У вас не достаточно средств.");
			GiveMoney(playerid,-strval(inputtext));
			SetPVarInt(playerid,"BALANCE",GetPVarInt(playerid,"BALANCE")+strval(inputtext));
			strin = "";
			format(strin,64,"~g~BALANCE: %d$~n~CTABKA: %d$",GetPVarInt(playerid,"BALANCE"),GetPVarInt(playerid,"BET"));
			PlayerTextDrawSetString(playerid, CasinoDraw[10][playerid], strin);
			return 1;
		}
	case 760: {
			if(!response) return 1;
			SetPlayerCheckpoint(playerid,-773.7891,-110.1276,65.2365,1.4);
			SendClientMessage(playerid, COLOR_WHITE, "Вы поставили метку на карте.");
			return 1;
		}
	case 760+1: {
			if(!response) return 1;
			SetPlayerCheckpoint(playerid,639.3174,848.0027,-42.9609,1.4);
			SendClientMessage(playerid, COLOR_WHITE, "Вы поставили метку на карте.");
			return 1;
		}
	case 760+2: {
			if(!response) return 1;
			SetPlayerCheckpoint(playerid,642.4855,880.2863,-42.8070,1.4);
			SendClientMessage(playerid, COLOR_WHITE, "Вы поставили метку на карте.");
			return 1;
		}
	case 760+3: {
			if(!response) return 1;
			SetPlayerCheckpoint(playerid,2179.9456,-2256.3616,14.7734,1.4);
			SendClientMessage(playerid, COLOR_WHITE, "Вы поставили метку на карте.");
			return 1;
		}
	case 771: {
			if(!response) return 1;
			switch(listitem) {
			case 0://Лесоруб
				{
					SPD(playerid, 760, 0, "Устройство на работу", "Устройство на данную работу происходит непосредственно на месте.\nХотите отметить на карте место работы?", "Да", "Нет");
				}
			case 1://Шахтёр
				{
					if(PI[playerid][pBelay] < 1) return SendClientMessage(playerid, COLOR_GREY, "Вы не можете устроиться на данную работу т.к у вас нету страховки!");
					SPD(playerid, 760+1, 0, "Устройство на работу", "Устройство на данную работу происходит непосредственно на месте.\nХотите отметить на карте место работы?", "Да", "Нет");
				}
			case 2://Работа на бульдозере
				{
					if(PI[playerid][pBelay] < 1) return SendClientMessage(playerid, COLOR_GREY, "Вы не можете устроиться на данную работу т.к у вас нету страховки!");
					SPD(playerid, 760+2, 0, "Устройство на работу", "Устройство на данную работу происходит непосредственно на месте.\nХотите отметить на карте место работы?", "Да", "Нет");
				}
			case 3://Грузчик
				{
					SPD(playerid, 760+3, 0, "Устройство на работу", "Устройство на данную работу происходит непосредственно на месте.\nХотите отметить на карте место работы?", "Да", "Нет");
				}
			case 4: {
					if(PI[playerid][pLevel] < 2) return SendClientMessage(playerid,COLOR_WHITE,"Для данной работы требуется 2 уровень!");
					SendClientMessage(playerid, COLOR_PAYCHEC, "Вы устроились на работу таксиста.");
					PI[playerid][pJob] = 1;
				}
			case 5: {
					if(PI[playerid][pLevel] < 2) return SendClientMessage(playerid,COLOR_WHITE,"Для данной работы требуется 2 уровень!");
					SendClientMessage(playerid, COLOR_PAYCHEC, "Вы устроились на работу водителем автобуса.");
					PI[playerid][pJob] = 2;
				}
			case 6: {
					if(PI[playerid][pLevel] < 3) return SendClientMessage(playerid,COLOR_WHITE,"Для данной работы требуется 3 уровень!");
					SendClientMessage(playerid, COLOR_PAYCHEC, "Вы устроились на работу развозчика продуктов.");
					PI[playerid][pJob] = 3;
				}
			case 7: {
					if(PI[playerid][pLevel] < 3) return SendClientMessage(playerid,COLOR_WHITE,"Для данной работы требуется 3 уровень!");
					SendClientMessage(playerid, COLOR_PAYCHEC, "Вы устроились на работу развозчика топлива.");
					PI[playerid][pJob] = 5;
				}
			case 8: {
					if(PI[playerid][pLevel] < 2) return SendClientMessage(playerid,COLOR_WHITE,"Для данной работы требуется 3 уровень!");
					SendClientMessage(playerid, COLOR_PAYCHEC, "Вы устроились на работу автомеханика.");
					PI[playerid][pJob] = 4;
				}
			case 9: {
					SendClientMessage(playerid, COLOR_PAYCHEC, "Вы уволились с работы.");
					PI[playerid][pJob] = 0;
				}
			}
			return 1;
		}
	case 772: {
			if(!response) return 1;
			if(PI[playerid][pBelay] > 0) {
				PI[playerid][pBelay] += 60;
				SendClientMessage(playerid, COLOR_GREEN, "Вы успешно продлили страховку сроком на 2 месяца (( 60 зарплат ))");
			}
			if(PI[playerid][pBelay] < 1) {
				PI[playerid][pBelay] = 60;
				SendClientMessage(playerid, COLOR_GREEN, "На вас успешно была оформлена страховка сроком на 2 месяца (( 60 зарплат ))");
			}
			GiveMoney(playerid,-300);
			return 1;
		}
	case 7724: {
			if(response) {
				if(listitem == 0) {
					SetPlayerFacingAngle(playerid, 181.6046);
					SetPlayerCameraPos(playerid,338.6618,1573.9758,29.3534);
					SetPlayerCameraLookAt(playerid,338.6618,1573.9758,29.3534);
					TogglePlayerControllable(playerid, 0);
					return true;
				}
				else if(listitem == 1) {
					SetPlayerFacingAngle(playerid, 170.0947);
					SetPlayerCameraPos(playerid,-61.5420,1612.7935,24.2544);
					SetPlayerCameraLookAt(playerid,-61.5420,1612.7935,24.2544);
					TogglePlayerControllable(playerid, 0);
					return true;
				}
				else if(listitem == 2) {
					SetPlayerFacingAngle(playerid, 115.7203);
					SetPlayerCameraPos(playerid,121.2786,1942.5219,29.0367);
					SetPlayerCameraLookAt(playerid,121.2786,1942.5219,29.0367);
					TogglePlayerControllable(playerid, 0);
					return true;
				}
				else if(listitem == 3) {
					SetPlayerFacingAngle(playerid, 319.3263);
					SetPlayerCameraPos(playerid,277.4582,2024.3215,26.3999);
					SetPlayerCameraLookAt(playerid,277.4582,2024.3215,26.3999);
					TogglePlayerControllable(playerid, 0);
					return true;
				}
				SendClientMessage(playerid, COLOR_LIGHTRED, "/cameraoff - отключить камеру.");
				SetPlayerVirtualWorld(playerid, 0);
			}
			else {
				return true;
			}
		}
	case 3005: {
			if(response) {
				if(PI[playerid][pCash] < 4000) return SendClientMessage(playerid, COLOR_GREY,"У вас недостаточно денег!"),SetCameraBehindPlayer(playerid);
				GiveInventory(playerid, 20, 40), SendClientMessage(playerid, COLOR_PAYCHEC,"Вы купили Desert Eagle за 4000$");
				PI[playerid][pCash] -= 4000;
				SetCameraBehindPlayer(playerid);
			}
			else
			SetCameraBehindPlayer(playerid);
		}
	case 3006: {
			if(response) {
				if(PI[playerid][pCash] < 4000) return SendClientMessage(playerid, COLOR_GREY,"У вас недостаточно денег!"),SetCameraBehindPlayer(playerid);
				GiveInventory(playerid, 19, 40), SendClientMessage(playerid, COLOR_PAYCHEC,"Вы купили SDPistol за 4000$");
				PI[playerid][pCash] -= 4000;
				SetCameraBehindPlayer(playerid);
			}
			else {
				SetCameraBehindPlayer(playerid);
			}
		}
	case 3007: {
			if(response) {
				if(PI[playerid][pCash] < 6000) return SendClientMessage(playerid, COLOR_GREY,"У вас недостаточно денег!"),SetCameraBehindPlayer(playerid);
				GiveInventory(playerid, 21, 80), SendClientMessage(playerid, COLOR_PAYCHEC,"Вы купили дробовик ShotGun за 6000$");
				PI[playerid][pCash] -= 6000;
				SetCameraBehindPlayer(playerid);
			}
			else
			SetCameraBehindPlayer(playerid);

		}
	case 3008: {
			if(response) {
				if(PI[playerid][pCash] < 10000) return SendClientMessage(playerid, COLOR_GREY,"У вас недостаточно денег!"),SetCameraBehindPlayer(playerid);
				GiveInventory(playerid, 24, 120), SendClientMessage(playerid, COLOR_PAYCHEC,"Вы купили пол-автомат MP5 за 10000$");
				PI[playerid][pCash] -= 10000;
				SetCameraBehindPlayer(playerid);
			}
			else
			SetCameraBehindPlayer(playerid);

		}
	case 3009: {
			if(response) {
				if(PI[playerid][pCash] < 10000) return SendClientMessage(playerid, COLOR_GREY,"У вас недостаточно денег!"),SetCameraBehindPlayer(playerid);
				GiveInventory(playerid, 26, 160), SendClientMessage(playerid, COLOR_PAYCHEC,"Вы купили автомат AK-47 за 10000$");
				PI[playerid][pCash] -= 10000;
				SetCameraBehindPlayer(playerid);
			}
			else
			SetCameraBehindPlayer(playerid);

		}
	case 3010: {
			if(response) {
				if(PI[playerid][pCash] < 10000) return SendClientMessage(playerid, COLOR_GREY,"У вас недостаточно денег!"),SetCameraBehindPlayer(playerid);
				GiveInventory(playerid, 27, 160), SendClientMessage(playerid, COLOR_PAYCHEC,"Вы купили автомат M4 за 10000$");
				PI[playerid][pCash] -= 10000;
				SetCameraBehindPlayer(playerid);
			}
			else SetCameraBehindPlayer(playerid);

		}
	case 3011: {
			if(response) {
				if(PI[playerid][pCash] < 15000) return SendClientMessage(playerid, COLOR_GREY,"У вас недостаточно денег!"),SetCameraBehindPlayer(playerid);
				GiveInventory(playerid, 34, 1), SendClientMessage(playerid, COLOR_PAYCHEC,"Вы купили бронежилет за 15000$");
				PI[playerid][pCash] -= 15000;
				SetCameraBehindPlayer(playerid);
			}
			else SetCameraBehindPlayer(playerid);

		}
		// ТП ЛИСТ
	case 300: {
			new Float:X, Float:Y, Float:Z;
			if(!response) return 1;
			switch(listitem) {
			case 0: X=1460.6951, Y=-1363.889, Z=13.2324;//мэрия
			case 1: X=-761.8846, Y=-142.5731, Z=65.6930;
			case 2: X=2196.6277, Y=-2257.3381, Z=13.5469;
			case 3: X=641.4872, Y=846.4285, Z=-42.9609;
			case 4: X=-1585.9127, Y=715.8604, Z=-5.2422;
			case 5: X=2289.5046, Y=2452.4695, Z=10.8203;//
			case 6: X=2495.5559, Y=-1666.6296, Z=13.0708;// Банды
			case 7: X=2023.9126, Y=-1132.1450, Z=24.3797;
			case 8: X=2743.6360, Y=-1398.1372, Z=35.9393;
			case 9: X=1871.2664, Y=-1926.1224, Z=13.2740;
			case 10: X=2138.2339, Y=-1616.7936, Z=13.2920;
			case 11: X=-1521.9741, Y=480.8362, Z=7.1875;
			case 12: X=1560.9878, Y=-1237.1444, Z=292.0180;
			case 13: X=1482.0594, Y=-1743.3651, Z=13.2740;//bank
			}
			if (GetPlayerState(playerid) == 2) SetVehiclePosEx(GetPlayerVehicleID(playerid), X, Y, Z);
			else t_SetPlayerPos(playerid, X, Y, Z);
			SetPlayerInterior(playerid,0);
			SetPlayerVirtualWorld(playerid,0);
			PI[playerid][pPos][0] = X;
			PI[playerid][pPos][1] = Y;
			PI[playerid][pPos][2] = Z;
			SetPVarInt(playerid, "AntiBreik", 3);
		}
	case DIALOG_JOB+124: {
			if(!response) return RemovePlayerFromVehicle(playerid);
			if(GetMoney(playerid) < 500) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!"),RemovePlayerFromVehicle(playerid);
			SendClientMessage(playerid, COLOR_BLUE, "Вы арендовали транспорт за 1000 долларов");
			SetPVarInt(playerid, "FuelCar", GetPlayerVehicleID(playerid));
			GiveMoney(playerid, -1000);
			if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 583) {
				SetPVarInt(playerid, "FuelCarLittle", 1);
				new full;
				if(full == 0) {
					PI[playerid][pPayCheck] += GetPVarInt(playerid, "JobLittlePrice");
					DeletePVar(playerid, "LittleFull");
					DeletePVar(playerid, "JobLittlePrice");
					DeletePVar(playerid, "FuelCarLittle");
					RemovePlayerFromVehicle(playerid);
					return SendClientMessage(playerid, COLOR_GREY, "В скважинах нет топлива, подождите!");
				}
				SendClientMessage(playerid, COLOR_YELLOW, "Следуйте на чекпоинт, чтобы взять груз");
				SetPVarInt(playerid, "LittleFull", full);
				full--;
				if(full == 0) SetPlayerRaceCheckpoint(playerid, 1, 433.7109,1580.9321,11.4922, 0.0, 0.0, 0.0, 5.0);
				if(full == 1) SetPlayerRaceCheckpoint(playerid, 1, 600.3598,1515.3052,7.8325, 0.0, 0.0, 0.0, 5.0);
				if(full == 2) SetPlayerRaceCheckpoint(playerid, 1, 578.3732,1439.7570,11.1406, 0.0, 0.0, 0.0, 5.0);
				if(full == 3) SetPlayerRaceCheckpoint(playerid, 1, 627.6626,1369.1279,11.9845, 0.0, 0.0, 0.0, 5.0);
				if(full == 4) SetPlayerRaceCheckpoint(playerid, 1, 353.2522,1317.3221,12.4766, 0.0, 0.0, 0.0, 5.0);
			}
			return 1;
		}
	case DIALOG_JOB+125: {
			if(!response) return 1;
			new price, till, i = GetPVarInt(playerid, "PlayerBizz");
			if(sscanf(inputtext, "p<,>ii",till,price)) return SPD(playerid, DIALOG_JOB+125, 1, "Топливо", "{ffffff}Введите кол-во литров топлива и оплату (через запятую):\n\nНа {8d8dff}1{ffffff} литр топлива приходится {8d8dff}1{ffffff} доллара\n\n", "Принять", "Отмена");
			if(till < 50 || till > 50000-BizzInfo[i][bProduct]) {
				SendClientMessage(playerid, COLOR_GREY, "Кол-во топлива от 50 до 50000!");
				return SPD(playerid, DIALOG_JOB+125, 1, "Топливо", "{ffffff}Введите кол-во литров топлива и оплату (через запятую):\n\nНа {8d8dff}1{ffffff} литр топлива приходится {8d8dff}1{ffffff} доллара\n\n", "Принять", "Отмена");
			}
			if(price < 5000 || price > 100000) {
				SendClientMessage(playerid, COLOR_GREY, "Цена за работу от 5000 до 100000!");
				return SPD(playerid, DIALOG_JOB+125, 1, "Топливо", "{ffffff}Введите кол-во литров топлива и оплату (через запятую):\n\nНа {8d8dff}1{ffffff} литр топлива приходится {8d8dff}1{ffffff} доллара\n\n", "Принять", "Отмена");
			}
			if(PI[playerid][pBank] < price+till) {
				SPD(playerid, DIALOG_JOB+125, 1, "Топливо", "{ffffff}Введите кол-во литров топлива и оплату (через запятую):\n\nНа {8d8dff}1{ffffff} литр топлива приходится {8d8dff}1{ffffff} доллара\n\n", "Принять", "Отмена");
				return SendClientMessage(playerid, COLOR_GREY, "На вашем счету не достаточно денег!");
			}
			TOTALFUEL++;
			strmid(FuelInfo[TOTALFUEL][pName],NamePlayer(playerid),0,strlen(NamePlayer(playerid)),MAX_PLAYER_NAME);
			FuelInfo[TOTALFUEL][pPrice] = price;
			FuelInfo[TOTALFUEL][pTill] = till;
			FuelInfo[TOTALFUEL][pBizzid] = i;
			FuelInfo[TOTALFUEL][pStatus] = false;
			MinusBankMoney(playerid, price);
			SendClientMessageEx(playerid, F_BLUE_COLOR, "Вы заказали %i литро топлива, оплата %i долларов. Остаток на счете: %i долларов", till, price, PI[playerid][pBank]);
			for(new p = 0; p < GetMaxPlayers(); p++) {
				if(!IsPlayerConnected(p) || PlayerLogged[p] == false || PI[p][pJob] != 5) continue;
				SendClientMessageEx(p,  COLOR_ALLDEPT, "Поступил новый заказ от %s. Используйте: /flist", NamePlayer(playerid));
			}
		}
	case DIALOG_JOB+126: {
			if(!response) return 1;
			SetPVarInt(playerid, "FuelID", listitem+1);
			strin = "";
			format(strin, 256, "{ffffff}Номер заказа {8D8DFF}\t\t№%i %s\n\n{ffffff}Заказал:\t\t{8D8DFF}%s\n{ffffff}Куда:\t\t\t{8D8DFF}%s\n{ffffff}Количество:\t\t{8D8DFF}%i {ffffff}литров топлива\n{ffffff}Оплата:\t\t{8D8DFF}%i{ffffff} долларов",
			listitem+1, (!FuelInfo[listitem+1][pStatus]) ? ("{8D8DFF}(Доступен)") : ("{FF6347}(Выполняется)"), FuelInfo[listitem+1][pName], BizzInfo[FuelInfo[listitem+1][pBizzid]][bName],FuelInfo[listitem+1][pTill], FuelInfo[listitem+1][pPrice]);
			SPD(playerid, DIALOG_JOB+127, 0, "Заказ", strin, "Принять", "Назад");
		}
	case DIALOG_JOB+127: {
			if(!response) return FuelList(playerid),DeletePVar(playerid, "FuelID");
			if(strcmp(FuelInfo[GetPVarInt(playerid, "FuelID")][pName], NamePlayer(playerid), true) == 0) { DeletePVar(playerid, "FuelID"); FuelList(playerid); return SendClientMessage(playerid, COLOR_GREY, "Ты не можешь выполнить свой заказ!"); }
			if(FuelInfo[GetPVarInt(playerid, "FuelID")][pStatus] == true) { SendClientMessage(playerid, COLOR_GREY, "Заказ уже выполняется кем-либо!"); DeletePVar(playerid, "FuelID"); return FuelList(playerid); }
			if(FuelInfo[GetPVarInt(playerid, "FuelID")][pTill] > FuelBank) { SendClientMessage(playerid, COLOR_GREY, "На заводе недостаточно топлива!"); DeletePVar(playerid, "FuelID"); return FuelList(playerid); }
			new Float:VPos[3], i = FuelInfo[GetPVarInt(playerid, "FuelID")][pBizzid];
			FuelBank-=FuelInfo[GetPVarInt(playerid, "FuelID")][pTill];
			SetOtherInt("fuelbank", FuelBank);
			SendClientMessageEx(playerid, F_BLUE_COLOR, "Вы приняли заказ от %s. Чтобы отменить, введите: /cancel", FuelInfo[GetPVarInt(playerid, "FuelID")][pName]);
			GetPlayerPos(playerid, VPos[0], VPos[1], VPos[2]);
			DisablePlayerRaceCheckpoint(playerid);
			FuelInfo[GetPVarInt(playerid, "FuelID")][pStatus] = true;
			SetPlayerRaceCheckpoint(playerid, 1, BizzInfo[i][bEntrx], BizzInfo[i][bEntry], BizzInfo[i][bEntrz], 0.0,0.0,0.0,6);
			SendClientMessageEx(playerid, COLOR_YELLOW, "На карте отмечен: %s. Расстояние: %.1f метров",BizzInfo[i][bName],GetDistanceBetweenPoints(VPos[0], VPos[1], VPos[2], BizzInfo[i][bEntrx], BizzInfo[i][bEntry], BizzInfo[i][bEntrz]));
			strin = "";
			format(strin, 100, "{9ACD32}Топлива: {ffffff}%i / 50000{9acd32} литров", FuelInfo[GetPVarInt(playerid, "FuelID")][pTill]);
			FuelInfo[GetPVarInt(playerid, "FuelID")][pText3D] = Create3DTextLabel(strin, 0xffffffff, 0.0, 0.0, 0.0, 30.0, 0, 1);
			Attach3DTextLabelToVehicle(FuelInfo[GetPVarInt(playerid, "FuelID")][pText3D], GetPlayerVehicleID(playerid), 0, -1.0, 2.0);

		}
	case DIALOG_JOB+128: {
			if(!response) return 1;
			new fuel;
			new bizz = BizzInfo[GetPVarInt(playerid, "FuelBizzID")][bTill] / 3;
			if(sscanf(inputtext, "i",fuel)) return SPD(playerid, DIALOG_JOB+128, 1,"Топливо", "Введите кол-во литров топлива:", "Принять", "Отмена");
			if(fuel < 1 || fuel > 200) {
				SendClientMessage(playerid, COLOR_GREY, "Топлива от 1 до 200 литров!");
				return SPD(playerid, DIALOG_JOB+128, 1,"Топливо", "Введите кол-во литров топлива:", "Принять", "Отмена");
			}
			if(fuel+Fuel[GetPlayerVehicleID(playerid)] > 200) {
				SendClientMessageEx(playerid, COLOR_GREY, "Слишком много топлива. Рекомендуем: %i литров", 200-Fuel[GetPlayerVehicleID(playerid)]);
				return SPD(playerid, DIALOG_JOB+128, 1,"Топливо", "Введите кол-во литров топлива:", "Принять", "Отмена");
			}
			if(fuel*bizz > GetMoney(playerid)) {
				SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
				return SPD(playerid, DIALOG_JOB+128, 1, "Топливо", "Введите кол-во литров топлива:", "Принять", "Отмена");
			}
			if(fuel > BizzInfo[GetPVarInt(playerid, "FuelBizzID")][bProduct]) {
				SendClientMessage(playerid, COLOR_GREY, "Недостаточно топлива в бизнесе!");
				return SPD(playerid, DIALOG_JOB+128, 1, "Топливо", "Введите кол-во литров топлива:", "Принять", "Отмена");
			}
			new price = fuel*bizz;
			GiveMoney(playerid, -price);
			BizzPay[GetPVarInt(playerid, "FuelBizzID")] += price;
			BizzInfo[GetPVarInt(playerid, "FuelBizzID")][bMoney] += price;
			BizzInfo[GetPVarInt(playerid, "FuelBizzID")][bProduct] -= fuel;
			SetBizzInt(BizzInfo[GetPVarInt(playerid, "FuelBizzID")][id], "product", BizzInfo[GetPVarInt(playerid, "FuelBizzID")][bProduct]);
			DeletePVar(playerid, "FuelBizzID");
			SendClientMessage(playerid, COLOR_BLUE, "Транспорт заправляется, ожидайте");
			SetPVarInt(playerid, "Refueling", fuel);
			TogglePlayerControllable(playerid, false);
			ReFuelTimer[playerid] = SetTimerEx("ReFill", 500, true, "i", playerid);
			return 1;
		}
	case DIALOG_GARAGE: {
			if(!response) return true;
			//if(!GetPlayerCars(playerid) || (!GetPlayerHouse(playerid))) return SendClientMessage(playerid,COLOR_GREY,"У Вас нету личного транспорта!");
			switch(listitem) {
			case 0: {
					if(PlayerToPoint(90.5,playerid,869.7452,713.9611,1039.8246)) SPD(playerid,DIALOG_GARAGE+1,2,"Гараж","1. Загнать первую машину\n2. Загнать вторую машину","Далее","Отмена");
				}
			}
		}
	case DIALOG_GARAGE+1: {
			if(!response) return true;
			//if(!GetPlayerCars(playerid) || (!GetPlayerHouse(playerid))) return SendClientMessage(playerid,COLOR_GREY,"У Вас нету личного транспорта!");
			switch(listitem) {
			case 0: {
					selectcar[playerid] = 1;
					if(PI[playerid][pCars][selectcar[playerid]-1] == 0) return true;
					if(caringarage[playerid] > 0) return SendClientMessage(playerid, COLOR_GREY, "В вашем гараже не достаточно места для 2-ого авто!");
					new c = PI[playerid][pCars][selectcar[playerid]-1];
					if(GetMoney(playerid) < ((GetVehicleModel(CarInfo[c][cID]) == CarInfo[c][cModel]) ? 500 : 50)) return SendClientMessage(playerid, COLOR_GREY, "У Вас недостаточно средств для починки/доставки транспорта в гараж!");
					new full=0;
					foreach(new i: Player) {
						if(PlayerLogged[i] == false) continue;
						if(IsPlayerInVehicle(i, CarInfo[c][cID])) return SendClientMessage(playerid, COLOR_GREY, "Ваш транспорт используется!");
					}
					if(full != 0) return SendClientMessage(playerid, COLOR_GREY, "Ваш транспорт используется!");
					caringarage[playerid] = 1;
					Delete3DTextLabel(CarInfo[c][cText]);
					strin = "";
					format(strin, sizeof(strin), "{ff4f00}Владелец: {ffffff}%s\n{ff4f00}ID: {ffffff}%d", CarInfo[c][cOwner], CarInfo[c][cID]);
					CarInfo[c][cText] = Create3DTextLabel(strin, 0x33AAFFFF, 0.0, 0.0, 0.0, 50.0, 0, 1);
					Attach3DTextLabelToVehicle(CarInfo[c][cText], CarInfo[c][cID], 0.0, 0.0, 1.25);
					DestroyVehicle(CarInfo[c][cID]);
					SendClientMessage(playerid, COLOR_YELLOW, "Ваш транспорт доставлен в гараж");
					GameTextForPlayer(playerid, "fixcar", 5000, 1);
					GiveMoney(playerid, -(CarInfo[c][cModel] == GetVehicleModel(CarInfo[c][cID])) ? -500 : -50);
					CarInfo[c][cID] = CreateVehicle(CarInfo[c][cModel], 869.5263,715.2844,1039.5702, 180, CarInfo[c][cColor][0], CarInfo[c][cColor][1], 90000);
					LinkVehicleToInterior(CarInfo[c][cID],7);
					SetPlayerInterior(playerid,7);
					SetVehicleVirtualWorld(CarInfo[c][cID], playerid);
					SetPlayerVirtualWorld(playerid,playerid);
					GameTextForPlayer(playerid, "fixcar 1", 5000, 1);
					CarInfo[c][cFuel] = 150;
					LoadMyCar(playerid,selectcar[playerid]-1);
				}
			case 1: {
					selectcar[playerid] = 2;
					if(PI[playerid][pCars][selectcar[playerid]-1] == 0) return true;
					if(caringarage[playerid] > 0) return SendClientMessage(playerid, COLOR_GREY, "В вашем гараже не достаточно места для 2-ого авто!");
					new c = PI[playerid][pCars][selectcar[playerid]-1];
					if(GetMoney(playerid) < ((GetVehicleModel(CarInfo[c][cID]) == CarInfo[c][cModel]) ? 500 : 50)) return SendClientMessage(playerid, COLOR_GREY, "У Вас недостаточно средств для починки/доставки транспорта в гараж!");
					new full=0;
					foreach(new i: Player) {
						if(PlayerLogged[i] == false) continue;
						if(IsPlayerInVehicle(i, CarInfo[c][cID])) return SendClientMessage(playerid, COLOR_GREY, "Ваш транспорт используется!");
					}
					if(full != 0) return SendClientMessage(playerid, COLOR_GREY, "Ваш транспорт используется!");
					caringarage[playerid] = 2;
					Delete3DTextLabel(CarInfo[c][cText]);
					strin = "";
					format(strin, sizeof(strin), "{ff4f00}Владелец: {ffffff}%s\n{ff4f00}ID: {ffffff}%d", CarInfo[c][cOwner], CarInfo[c][cID]);
					CarInfo[c][cText] = Create3DTextLabel(strin, 0x33AAFFFF, 0.0, 0.0, 0.0, 50.0, 0, 1);
					Attach3DTextLabelToVehicle(CarInfo[c][cText], CarInfo[c][cID], 0.0, 0.0, 1.25);
					DestroyVehicle(CarInfo[c][cID]);
					SendClientMessage(playerid, COLOR_YELLOW, "Ваш транспорт доставлен в гараж");
					GameTextForPlayer(playerid, "fixcar", 5000, 1);
					GiveMoney(playerid, -(CarInfo[c][cModel] == GetVehicleModel(CarInfo[c][cID])) ? -500 : -50);
					CarInfo[c][cID] = CreateVehicle(CarInfo[c][cModel], 869.5263,715.2844,1039.5702, 180, CarInfo[c][cColor][0], CarInfo[c][cColor][1], 90000);
					LinkVehicleToInterior(CarInfo[c][cID],7);
					SetPlayerInterior(playerid,7);
					SetVehicleVirtualWorld(CarInfo[c][cID], playerid);
					SetPlayerVirtualWorld(playerid,playerid);
					GameTextForPlayer(playerid, "fixcar 2", 5000, 1);
					CarInfo[c][cFuel] = 150;
					LoadMyCar(playerid,selectcar[playerid]-1);
				}
			}
		}
	case D_CLOTHJOB: {
			if(!response) return true;
			if(GetPVarInt(playerid,"Work") == 0) {
				SetPVarInt(playerid,"Work",1);
				SendClientMessage(playerid,COLOR_PAYCHEC,"Поздравляем! Теперь идите на чекпоинт, чтобы взять готовую ткань.");
				SetPlayerCheckpoint(playerid,-41.0592,-189.0606,928.7820,1.2);
				SetPVarInt(playerid,"loadid",10);
				SetPVarInt(playerid,"skinrabota",GetPlayerSkin(playerid));
				if(PI[playerid][pSex] == 1) SetPlayerSkin(playerid,157);
				else SetPlayerSkin(playerid,8);
			}
			else if(GetPVarInt(playerid,"Work") == 1) {
				SetPVarInt(playerid,"Work",0);
				DeletePVar(playerid,"coalamount");
				DeletePVar(playerid,"loadid");
				RemovePlayerAttachedObject(playerid,2);
				DisablePlayerCheckpoint(playerid);
				strin = "";
				format(strin,sizeof(strin),"Вы заработали %d$. Спасибо, приходите еще",cWorkSalary[playerid]);
				SendClientMessage(playerid,COLOR_PAYCHEC,strin);
				GiveMoney(playerid,cWorkSalary[playerid]);
				cWorkSalary[playerid] = 0;
				SetPlayerSkin(playerid,GetPVarInt(playerid,"skinrabota"));
			}
		}
	case D_GRAIN: {
			if(!response) return true;
			if(PI[playerid][pGrains] < 10) return SendClientMessage(playerid,COLOR_GREY, "Для создания наркотика, вам необходимо минимум 10 зерен!");
			SPD(playerid,D_GRAIN+1,DIALOG_STYLE_INPUT,"Создание наркотика","Введите кол-во наркотиков","Далее","Закрыть");
		}
	case D_GRAIN+1: {
			if(!response) return true;
			if(!strlen(inputtext)) return SPD(playerid,D_GRAIN+1,DIALOG_STYLE_INPUT,"Создание наркотика","Введите кол-во наркотиков","Далее","Закрыть");
			new drug = strval(inputtext);
			if(PI[playerid][pGrains] < 10) return SendClientMessage(playerid,COLOR_GREY, "Для сборки наркотика, вам необходимо минимум 10 зерен!");
			if(drug < 1 || drug > 100) return SendClientMessage(playerid,COLOR_GREY,"Минимум - 1, Максимум - 100!");
			if(PI[playerid][pGrains] < drug*10) return SendClientMessage(playerid,COLOR_GREY, "У вас недостаточно зерен!");
			PI[playerid][pGrains] -= drug*10;
			SetPVarInt(playerid,"grains",drug);
			ClearAnimations(playerid);
			GameTextForPlayer(playerid, "~g~Wait 60 sec~n~~p~process goes.", 55000, 1);
			ApplyAnimation(playerid,"GRAFFITI","spraycan_fire",4.0,1,1,1,0,60000,0);
			SetTimerEx("GrainSTART",60000,false,"i",playerid);
		}
	case D_SPAWN: {
			if(!response) return true;
			strin = "";
			switch(listitem) {
			case 0: {
					if(!GetPlayerHouse(playerid)) return SendClientMessage(playerid,COLOR_GREY,"У Вас нет дома!");
					strin = "";
					format(strin, sizeof(strin), "Теперь Вы будете появляться дома.");
				}
			case 1:
				format(strin, sizeof(strin), "Теперь Вы будете появляться на базе организации/аэропорту.");
			case 2: {
					if(!PI[playerid][pHotel]) return SendClientMessage(playerid,COLOR_GREY,"У Вас нет гостиничного номера!");
					strin = "";
					format(strin, sizeof(strin), "Теперь Вы будете появляться в гостиничном номере.");
				}
			}
			PI[playerid][pSpawn] = listitem+1;
			SendClientMessage(playerid,COLOR_GREY,strin);
		}
	case DIALOG_HOTEL: {
			if(!response) return true;
			switch(listitem) {
			case 0: SPD(playerid, DIALOG_HOTEL+1, DIALOG_STYLE_LIST, "Гардероб", "1. Фракционная Одежда\n2. Обычная Одежда", "Выбрать", "Закрыть");
			}
		}
	case DIALOG_HOTEL+1: {
			if(!response) return true;
			switch(listitem) {
			case 0: {
					if(PI[playerid][pMember]) SetPlayerSkin(playerid,PI[playerid][pFracSkin]), SetPlayerTeamColor(playerid);
					else SendClientMessage(playerid,COLOR_GREY,"Вы не состоите в организации.");
				}
			case 1: SetPlayerSkin(playerid,PI[playerid][pSkin]), SetPlayerColor(playerid,0xFFFFFF11);
			}
		}
	case D_RECEPT: {
			if(!response) return true;
			switch(listitem) {
			case 0: {
					if(PI[playerid][pHotel] > 0) return SendClientMessage(playerid,COLOR_GREY,"У вас уже есть комната");
					SPD(playerid, D_RECEPT+1, DIALOG_STYLE_LIST, "Покупка комнаты", "1. Комната №1\n2. Комната №2\n3. Комната №3\n4. Комната №4\n5. Комната №5\n6. Комната №6\n7. Комната №7\n8. Комната №8\n9. Комната №9\n10. Комната №10\n11. Комната №11\n12. Комната №12\n13. Комната №13\n14. Комната №14\n15. Комната №15\n16. Комната №16\n17. Комната №17\n18. Комната №18", "Выбрать", "Закрыть");
				}
			case 1: {
					if(PI[playerid][pHotel] < 1) return SendClientMessage(playerid,COLOR_GREY,"У вас нету комнаты");
					PI[playerid][pHotel] = 0;
					PI[playerid][pHotelNumber] = 0;
					PI[playerid][pCash] += 2500;
					SendClientMessage(playerid,COLOR_GREY,"Вы продали комнату в отеле. Вам возвращена половина суммы. (2500$)");
				}
			}
		}
	case D_RECEPT+1: {
			if(!response) return true;
			if(PI[playerid][pCash] < 5000) return SendClientMessage(playerid,COLOR_GREY,"У вас недостаточно средств. (5000$)");
			PI[playerid][pCash] -= 2000;
			new Text[5];
			if(GetPlayerVirtualWorld(playerid) == 1) strcat(Text,"Jefferson"), PI[playerid][pHotel] = 1;
			else if(GetPlayerVirtualWorld(playerid) == 2) strcat(Text,"SF"), PI[playerid][pHotel] = 2;
			else if(GetPlayerVirtualWorld(playerid) == 3) strcat(Text,"LV"), PI[playerid][pHotel] = 3;
			PI[playerid][pHotelNumber] = listitem+1;
			strin = "";
			format(strin,sizeof(strin),"Поздравляем, Вы купили комнату №%d в отеле '%s' за 5000$.",listitem+1,Text);
			SendClientMessage(playerid,COLOR_PAYCHEC,strin);
			PlayerPlaySound(playerid,1185,0.0,0.0,0.0);
			SetTimerEx("PlayerPlaySoundDelay",6900,false,"ii",playerid,1186);
		}
		// Фракции
	case DIALOG_FRACTION: {
			if(!response) return DeletePVar(playerid, "PlayerLeader");
			SetPVarInt(playerid, "Fraction", listitem);
			new mes[252];
			for(new i;i<12;i++) {
				new skinid = FractionSkin[listitem][i];
				if(!skinid) break;
				if(!i) format(mes,sizeof(mes),"Скин %d [%d]",i+1,skinid);
				else format(mes,sizeof(mes),"%s\nСкин %d [%d]",mes,i+1,skinid);
			}
			new playerd = GetPVarInt(playerid, "PlayerLeader");
			SPD(playerid,DIALOG_FRACTION+1,2,NamePlayer(playerd),mes,"OK","Отмена");
			return 1;
		}
	case DIALOG_FRACTION+1: {
			new playerd = GetPVarInt(playerid, "PlayerLeader"), frac = GetPVarInt(playerid, "Fraction");
			new skinid = FractionSkin[frac][listitem];
			if(!response) return DeletePVar(playerid, "PlayerLeader");
			if(playerd == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_GREY, "Игрок оффлайн!");
			if(PlayerLogged[playerd] == false) return SendClientMessage(playerid, COLOR_GREY, "Игрок не авторизирован!");

			PI[playerd][pLeader] = frac+1;
			PI[playerd][pMember] = frac+1;
			PI[playerd][pJob] = 0;
			PI[playerd][pRank] = CountRank[frac];
			PI[playerd][pFracSkin] = skinid;
			SetPlayerSkin(playerd,skinid);
			SetPlayerTeamColor(playerd);

			SendClientMessageEx(playerid, COLOR_ORANGE, "Вы назначили %s руководить организацией: %s",NamePlayer(playerd), Fraction[frac]);
			SendClientMessageEx(playerd, COLOR_BLUE, "Администратор %s назначил вас руководить организацией: %s", NamePlayer(playerid), Fraction[frac]);
			SavePlayer(playerd);
			DeletePVar(playerid, "PlayerLeader");
			return 1;
		}
	case DIALOG_FRACTION+3: {
			new playerd = GetPVarInt(playerid, "PlayerSkin");
			new skinid = FractionSkin[PI[playerid][pMember]-1][listitem];
			if(!response) return DeletePVar(playerid, "PlayerSkin");
			if(playerd == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_GREY, "Игрок оффлайн!");
			if(PlayerLogged[playerd] == false) return SendClientMessage(playerid, COLOR_GREY, "Игрок не авторизирован!");
			PI[playerd][pFracSkin] = skinid;
			SetPlayerSkin(playerd,skinid);
			SendClientMessageEx(playerid, COLOR_ORANGE, "Вы изменили скин игрока: %s на ID: %d",NamePlayer(playerd), skinid);
			SendClientMessageEx(playerd, COLOR_BLUE, "%s изменил Ваш скин на ID: %d", NamePlayer(playerid), skinid);
			SavePlayer(playerd);
			DeletePVar(playerid, "PlayerSkin");
			return 1;
		}
		///
	case 1520: {
			if(!response) return 1;
			switch(listitem) {
			case 0: SPD(playerid,1521,DIALOG_STYLE_INPUT,"Взять деньги","Введите кол-во:","Далее","Отмена");
			case 1: SPD(playerid,1522,DIALOG_STYLE_INPUT,"Положить деньги","Введите кол-во:","Далее","Отмена");
			}
		}
	case 1521: {
			if(!response) return 1;
			new counte;
			if(sscanf(inputtext,"i",counte)) return SPD(playerid,1521,DIALOG_STYLE_INPUT,"Взять деньги","Введите кол-во:","Далее","Отмена");
			if(PI[playerid][pLeader] > 1 || PI[playerid][pRank] >= 7) return SendClientMessage(playerid,COLOR_WHITE,"Доступно с 7 ранга!");
			if(counte < 1 || counte > 100) return SPD(playerid,1521,DIALOG_STYLE_INPUT,"Взять деньги","Введите кол-во:","Далее","Отмена");
			if(PI[playerid][pCash] + counte > 10000) return SendClientMessage(playerid,COLOR_WHITE,"Вы не можете брать больше 10000 вирт!");
			if(Metal[PI[playerid][pMember]] >= counte) {
				MBank[PI[playerid][pMember]] -= counte;
				PI[playerid][pCash] += counte;
				SendClientMessageEx(playerid,COLOR_BLUE,"Вы взяли со склада банды %d вирт.",counte);
				UpdateWarehouse(); SaveWarehouse();
				SavePlayer(playerid);
			}
			else SendClientMessage(playerid,COLOR_GREY,"На складе банды нет денег!");
		}
	case 1500: {
			if(!response) return 1;
			switch(listitem) {
			case 0: SPD(playerid,1502,2,"Металл","1. Взять\n2. Положить","Далее","Отмена");
			case 1: SPD(playerid,1505,2,"Патроны","1. Взять\n2. Положить","Далее","Отмена");
			case 2: SPD(playerid,1508,2,"Наркотики","1. Взять\n2. Положить","Далее","Отмена");
			}
		}
	case 1502: {
			if(!response) return 1;
			switch(listitem) {
			case 0: SPD(playerid,1503,DIALOG_STYLE_INPUT,"Взять металл","Введите кол-во:","Далее","Отмена");
			case 1: SPD(playerid,1504,DIALOG_STYLE_INPUT,"Положить металл","Введите кол-во:","Далее","Отмена");
			}
		}
	case 1503: {
			if(!response) return 1;
			new counte;
			if(sscanf(inputtext,"i",counte)) return SPD(playerid,1503,DIALOG_STYLE_INPUT,"Взять металл","Введите кол-во:","Далее","Отмена");
			if(counte < 1 || counte > 100) return SPD(playerid,1503,DIALOG_STYLE_INPUT,"Взять металл","Введите кол-во:","Далее","Отмена");
			if(PI[playerid][pStuf][1] + counte > 200) return SendClientMessage(playerid,COLOR_WHITE,"Вы не можете брать с собой больше 200кг металла!");
			if(Metal[PI[playerid][pMember]] >= counte) {
				Metal[PI[playerid][pMember]] -= counte;
				GiveInventory(playerid,36,counte);
				SendClientMessageEx(playerid,COLOR_BLUE,"Вы взяли со склада банды %d кг металла.",counte);
				UpdateWarehouse(); SaveWarehouse();
				SavePlayer(playerid);
			}
			else SendClientMessage(playerid,COLOR_GREY,"На складе банды нет столько металла!");
		}
		// Положить металл
	case 1504: {
			if(!response) return 1;
			new counte;
			if(sscanf(inputtext,"i",counte)) return SPD(playerid,1504,DIALOG_STYLE_INPUT,"Положить металл","Введите кол-во:","Далее","Отмена");
			if(counte < 1 || counte > 100) return SPD(playerid,1504,DIALOG_STYLE_INPUT,"Положить металл","Введите кол-во:","Далее","Отмена");
			if(PI[playerid][pStuf][1] >= counte) {
				GiveInventory(playerid,36,-counte);
				Metal[PI[playerid][pMember]] += counte;
				UpdateWarehouse(); SaveWarehouse();
				SendClientMessageEx(playerid,COLOR_BLUE,"Вы положили на склад банды %d кг металла.",counte);
			}
			else SendClientMessage(playerid,COLOR_GREY,"У Вас нет столько металла!");
		}
		// Патроны
	case 1505: {
			if(!response) return 1;
			switch(listitem) {
			case 0: SPD(playerid,1506,DIALOG_STYLE_INPUT,"Взять Патроны","Введите кол-во:","Далее","Отмена");
			case 1: SPD(playerid,1507,DIALOG_STYLE_INPUT,"Положить патроны","Введите кол-во:","Далее","Отмена");
			}
		}
	case 1506: {
			if(!response) return 1;
			new counte;
			if(sscanf(inputtext,"i",counte)) return SPD(playerid,1506,DIALOG_STYLE_INPUT,"Взять патроны","Введите кол-во:","Далее","Отмена");
			if(counte < 1 || counte > 100) return SPD(playerid,1506,DIALOG_STYLE_INPUT,"Взять патроны","Введите кол-во:","Далее","Отмена");
			if(PI[playerid][pStuf][2] + counte > 200) return SendClientMessage(playerid,COLOR_WHITE,"Вы не можете брать с собой больше 200 патронов!");
			if(Mats[PI[playerid][pMember]] >= counte) {
				Mats[PI[playerid][pMember]] -= counte;
				GiveInventory(playerid,37,counte);
				UpdateWarehouse(); SaveWarehouse();
				SendClientMessageEx(playerid,COLOR_BLUE,"Вы взяли со склада банды %d патронов.",counte);
				SavePlayer(playerid);
			}
			else SendClientMessage(playerid,COLOR_GREY,"На складе банды нет столько патронов!");
		}
		// Положить
	case 1507: {
			if(!response) return 1;
			new counte;
			if(sscanf(inputtext,"i",counte)) return SPD(playerid,1507,DIALOG_STYLE_INPUT,"Положить патроны","Введите кол-во:","Далее","Отмена");
			if(counte < 1 || counte > 100) return SPD(playerid,1507,DIALOG_STYLE_INPUT,"Положить патроны","Введите кол-во:","Далее","Отмена");
			if(PI[playerid][pStuf][2] >= counte) {
				GiveInventory(playerid,37,-counte);
				Mats[PI[playerid][pMember]] += counte;
				UpdateWarehouse(); SaveWarehouse();
				SendClientMessageEx(playerid,COLOR_BLUE,"Вы положили на склад банды %d патронов.",counte);
			}
			else SendClientMessage(playerid,COLOR_GREY,"У Вас нет столько патронов!");
		}
		// Наркота
	case 1508: {
			if(!response) return 1;
			switch(listitem) {
			case 0: SPD(playerid,1509,DIALOG_STYLE_INPUT,"Взять наркотики","Введите кол-во:","Далее","Отмена");
			case 1: SPD(playerid,1510,DIALOG_STYLE_INPUT,"Положить наркотики","Введите кол-во:","Далее","Отмена");
			}
		}
		//
	case 1509: {
			if(!response) return 1;
			new counte;
			if(sscanf(inputtext,"i",counte)) return SPD(playerid,1509,DIALOG_STYLE_INPUT,"Взять наркотики","Введите кол-во:","Далее","Отмена");
			if(counte < 1 || counte > 100) return SPD(playerid,1509,DIALOG_STYLE_INPUT,"Взять наркотики","Введите кол-во:","Далее","Отмена");
			if(PI[playerid][pStuf][0] + counte > 200) return SendClientMessage(playerid,COLOR_WHITE,"Вы не можете брать с собой больше 100грамм наркотиков!");
			if(Drugs[PI[playerid][pMember]] >= counte) {
				Drugs[PI[playerid][pMember]] -= counte;
				GiveInventory(playerid,35,counte);
				UpdateWarehouse(); SaveWarehouse();
				SendClientMessageEx(playerid,COLOR_BLUE,"Вы взяли со склада банды %d грамм наркотиков.",counte);
				SavePlayer(playerid);
			}
			else SendClientMessage(playerid,COLOR_GREY,"На складе банды нет столько наркотиков!");
		}
		// Положить
	case 1510: {
			if(!response) return 1;
			new counte;
			if(sscanf(inputtext,"i",counte)) return SPD(playerid,1510,DIALOG_STYLE_INPUT,"Положить наркотики","Введите кол-во:","Далее","Отмена");
			if(counte < 1 || counte > 100) return SPD(playerid,1510,DIALOG_STYLE_INPUT,"Положить наркотики","Введите кол-во:","Далее","Отмена");
			if(PI[playerid][pStuf][0] >= counte) {
				GiveInventory(playerid,35,-counte);
				Drugs[PI[playerid][pMember]] += counte;
				UpdateWarehouse(); SaveWarehouse();
				SendClientMessageEx(playerid,COLOR_BLUE,"Вы положили на склад банды %d грамм наркотиков.",counte);
			}
			else SendClientMessage(playerid,COLOR_GREY,"У Вас нет столько наркотиков!");
		}
	case 1565: {
			if(!response) return true;
			if(PI[playerid][pCash] < 2000) return SendClientMessage(playerid, COLOR_GREY, "У вас должно быть как минимум 2000$ с собой!");
			if(GetPVarInt(playerid,"UseCasino")) return SendClientMessage(playerid, COLOR_GREY, "Вы уже играете в казино!");
			SetPVarInt(playerid,"UseCasino",1);
			Slots[playerid][0] = random(2);
			Slots[playerid][1] = random(2);
			Slots[playerid][2] = random(2);
			ShowPlayerSlots(playerid,Slots[playerid][0],Slots[playerid][1],Slots[playerid][2]);
			for(new i; i < 15; i++) PlayerTextDrawShow(playerid,CasinoDraw[i][playerid]);

			GiveMoney(playerid,-2000);
			SetPVarInt(playerid,"BET",2000);
			SetPVarInt(playerid,"BALANCE",2000);
			strin = "";
			format(strin,64,"~g~BALANCE: %d$~n~CTABKA: %d$",GetPVarInt(playerid,"BALANCE"),GetPVarInt(playerid,"BET"));
			PlayerTextDrawSetString(playerid, CasinoDraw[10][playerid], strin);

			return SelectTextDraw(playerid, COLOR_RED);
		}
		// Патроны
	case 2005: {
			if(!response) return 1;
			new veh = GetPlayerVehicleID(playerid);
			DestroyDynamicPickup(AmmoPickup[veh]);
			Delete3DTextLabel(AmmoText[veh]);
			Start[veh] = 0;
			SetVehicleParamsEx(veh,false,false, false,false,false,false,false);
			SendClientMessage(playerid,COLOR_GREY,"Вы завершили загрузку патронов!");
			return 1;
		}
	case 4000: {
			if(!response) return 1;
			switch(listitem) {
			case 0: {
					query = "";
					format(query, sizeof(query), "SELECT * FROM `bank` WHERE `playerid` = '%d'", PI[playerid][pID]);
					mysql_function_query(cHandle, query, true, "LoadAccountBank", "d", playerid);
				}
			}
		}
	case 4001: {
			if(!response) return 1;
			new text_1[64],account,text_2[64];
			if(sscanf(inputtext,"p<№>s[128]s[24]", text_1, text_2)) return 1;
			sscanf(text_2,"d",account); SetPVarInt(playerid, "AccountBank", account); SetPVarString(playerid,"AccountName",text_1);
			strin = "";
			format(strin, sizeof(strin), "{ffffff}Счет {81cb00}№%d{ffffff}\nНазначение: {81cb00}%s{ffffff}\nВведите PIN-Код счета:", account, text_1);
			SPD(playerid,4003,DIALOG_STYLE_INPUT, "Банковский счет", strin, "Далее", "Отмена");
		}
	case 4002: {
			if(!response) return 1;
			new name[16];
			if(sscanf(inputtext,"s[16]",name)) return SPD(playerid,4002,DIALOG_STYLE_INPUT, strin, "Введите название счета:", "Далее", "Отмена");
			if(strlen(name) < 3 || strlen(name) > 16) return SPD(playerid,4002,DIALOG_STYLE_INPUT, strin, "Введите название счета:", "Далее", "Отмена");
			SPD(playerid, 0,0, "Счет создан", "{ffffff}Вы создали новый счет в банке.\n\n\
			Для доступа к нему используйте PIN-код: {ff0000}0000{ffffff}. После входа\n\
			Настоятельно рекомендуем сменить его на более сложный.\n\
			Это поможет защитить счет от нежелательных переводов.", "Готово", "");
			strin = "";
			format(strin,128,"INSERT INTO `bank` (playerid,name) VALUES ('%i','%s')", PI[playerid][pID],name);
			mysql_function_query(cHandle, strin, false, "", "");
		}
	case 4003: {
			if(!response) return 1;
			new atext[16];
			GetPVarString(playerid,"AccountName",atext,16);
			strin = "";
			format(strin, sizeof(strin), "{ffffff}Счет {81cb00}№%d{ffffff}\nНазначение: {81cb00}%s{ffffff}\nВведите PIN-Код счета:", GetPVarInt(playerid,"AccountBank"),atext);
			if(!strlen(inputtext) || strlen(inputtext) < 3 || strlen(inputtext) > 16) return SPD(playerid,4003,DIALOG_STYLE_INPUT, "Банковский счет", strin, "Далее", "Отмена");
			query = "";
			format(query, sizeof(query), "SELECT * FROM `bank` WHERE `id` = '%d' and `pin` = '%s' LIMIT 1;", GetPVarInt(playerid,"AccountBank"),inputtext);
			mysql_function_query(cHandle, query, true, "GetPinAccountBank", "d", playerid);
		}
		//
	case 4004: {
			if(!response) return 1;
			switch(listitem) {
			case 0: {
					query = "";
					format(query, sizeof(query), "SELECT * FROM `bank` WHERE `id` = '%d'", GetPVarInt(playerid,"AccountBank"));
					mysql_function_query(cHandle, query, true, "InfoAccountBank", "d", playerid);
				}
			case 1: SPD(playerid,4005,DIALOG_STYLE_INPUT, "Снять деньги", "Укажите сумму:", "Снять", "Отмена");
			case 2: SPD(playerid,4006,DIALOG_STYLE_INPUT, "Положить деньги", "Укажите сумму:", "Положить", "Отмена");
			case 3: SPD(playerid,4012,DIALOG_STYLE_INPUT, "Домашний счёт", "Укажите сумму:", "Положить", "Отмена");
			case 4: SPD(playerid,4014,DIALOG_STYLE_INPUT, "Счёт бизнеса", "Укажите сумму:", "Положить", "Отмена");
			case 5: SPD(playerid,4008,DIALOG_STYLE_INPUT, "Изменение PIN-кода", "Укажите новый PIN-код.\nДлина от 4 до 20 симвалов:", "Ок", "Отмена");
			}
		}
	case 4005: {
			if(!response) {SPD(playerid, 4004, 2, "Список операций", "1. Информация о счете\n2. Снять деньги\n3. Положить деньги\n4. Домашний счет\n5. Счёт бизнеса\n6. Изменить PIN-код", "Принять", "Отмена"); return 1;}
			new money;
			if(sscanf(inputtext,"i",money)) return SPD(playerid,4005,DIALOG_STYLE_INPUT, "Снять деньги", "Укажите сумму:", "Снять", "Отмена");
			if(money < 1 || money > 1000000) return SPD(playerid,4005,DIALOG_STYLE_INPUT, "Снять деньги", "Укажите сумму:", "Снять", "Отмена");
			query = "";
			format(query, sizeof(query), "SELECT * FROM `bank` WHERE `id` = '%d' and `playerid` = '%d'", GetPVarInt(playerid,"AccountBank"), PI[playerid][pID]);
			mysql_function_query(cHandle, query, true, "GetBankMoney", "dd", playerid,money);
		}
	case 4006: {
			if(!response) return SPD(playerid, 4004, 2, "Список операций", "1. Информация о счете\n2. Снять деньги\n3. Положить деньги\n4. Домашний счет\n5. Счёт бизнеса\n6. Изменить PIN-код", "Принять", "Отмена");
			new money;
			if(sscanf(inputtext,"i",money)) return SPD(playerid,4006,DIALOG_STYLE_INPUT, "Положить деньги", "Укажите сумму:", "Положить", "Отмена");
			if(money < 1 || money > 1000000) return SPD(playerid,4006,DIALOG_STYLE_INPUT, "Положить деньги", "Укажите сумму:", "Положить", "Отмена");
			if(PI[playerid][pCash] < strval(inputtext)) return SendClientMessageEx(playerid, COLOR_GREY, "У вас не достаточно средств.");
			query = "";
			format(query, sizeof(query), "SELECT * FROM `bank` WHERE `id` = '%d' and `playerid` = '%d'", GetPVarInt(playerid,"AccountBank"), PI[playerid][pID]);
			mysql_function_query(cHandle, query, true, "PutBankMoney", "dd", playerid,money);
		}
	case 4007: {
			if(!response) return SPD(playerid, 4004, 2, "Банк", "1. Баланс счёта\n2. Снять деньги\n3. Положить деньги\n4. Перевести на другой счет\n5. Изменить PIN-код", "Принять", "Отмена");
			new account;
			if(sscanf(inputtext,"i",account)) return SPD(playerid,4007,DIALOG_STYLE_INPUT, "Перевод средств", "Укажите номер счета, на который\nхотите осуществить перевод:", "Далее", "Назад");
			if(account < 0 || account > 100000) return SPD(playerid,4007,DIALOG_STYLE_INPUT, "Перевод средств", "Укажите номер счета, на который\nхотите осуществить перевод:", "Далее", "Назад");
			SetPVarInt(playerid, "PayAccountBank", account);
			if(account == PI[playerid][pID]) return SPD(playerid,4007,DIALOG_STYLE_INPUT, "Перевод средств", "Ошибка! Вы не можете перевести деньги на свой счёт!\nУкажите номер счета, на который хотите осуществить перевод:", "Далее", "Назад");
			strin = "";
			format(strin, sizeof(strin), "{ffffff}Перевод на счет:\t{f26c00}№%d{ffffff}\nВведите сумму для перевода:", account);
			SPD(playerid,4009,DIALOG_STYLE_INPUT, "Перевод средств", strin, "Перевести", "Назад");
		}
	case 4008: {
			if(!response) {SPD(playerid, 4004, 2, "Список операций", "1. Информация о счете\n2. Снять деньги\n3. Положить деньги\n4. Домашний счет\n5. Счёт бизнеса\n6. Изменить PIN-код", "Принять", "Отмена"); return 1;}
			new AtmPass[64];
			if(sscanf(inputtext,"s",AtmPass)) return SPD(playerid,4008,DIALOG_STYLE_INPUT, "Изменение PIN-кода", "Укажите новый PIN-код.\nДлина от 4 до 8 цифр:", "Ок", "Отмена");
			if(strlen(AtmPass) < 4 && strlen(AtmPass) > 20) return SPD(playerid,4008,DIALOG_STYLE_INPUT, "Изменение PIN-кода", "Укажите новый PIN-код.\nДлина от 4 до 8 цифр:", "Ок", "Отмена");
			query = "";
			format(query, 256, "UPDATE `bank` SET `pin` = '%s' WHERE id = '%d'", AtmPass, GetPVarInt(playerid,"AccountBank"));
			mysql_function_query(cHandle, query, false, "", "");
			strin = "";
			format(strin, sizeof(strin), "{ffffff}Счет:\t\t\t\t{f26c00}№%d\n{ffffff}Новый PIN-код:\t\t{f26c00}%s", GetPVarInt(playerid,"AccountBank"),AtmPass);
			SPD(playerid,4010,0, "Изменение PIN-кода", strin, "Вернутся", "");
		}
	case 4009: {
			if(!response) return SPD(playerid, 4004, 2, "Банк", "1. Баланс счёта\n2. Снять деньги\n3. Положить деньги\n4. Перевести на другой счет\n5. Изменить PIN-код", "Принять", "Отмена");
			new money;
			strin = "";
			format(strin, sizeof(strin), "{ffffff}Перевод на счет:\t{f26c00}№%d{ffffff}\nВведите сумму для перевода:", GetPVarInt(playerid,"PayAccountBank"));
			if(sscanf(inputtext,"i",money)) return SPD(playerid,4009,DIALOG_STYLE_INPUT, "Перевод средств", strin, "Перевести", "Назад");
			if(money < 1 || money > 1000000) return SPD(playerid,4009,DIALOG_STYLE_INPUT, "Перевод средств", strin, "Перевести", "Назад");
			if(money > PI[playerid][pBank]) {
				strin = "";
				format(strin, sizeof(strin), "Ошибка! На Вашем банковском счёт недостаточно денег!\n{ffffff}Перевод на счет:\t{f26c00}№%d{ffffff}\nВведите сумму для перевода:", GetPVarInt(playerid,"PayAccountBank"));
				return SPD(playerid,4009,DIALOG_STYLE_INPUT, "Перевод средств", strin, "Перевести", "Назад");
			}
			new Transfer = GetPVarInt(playerid,"PayAccountBank"), GoOnline;
			MinusBankMoney(playerid, money);
			foreach(new i: Player) {
				if(PlayerLogged[i] == false) continue;
				if(PI[i][pID] == Transfer) {
					PlusBankMoney(playerid, money);
					SendClientMessageEx(i, -1, "{a4cd00}СМС-банк: %s перевёл на Ваш счёт $%d", NamePlayer(playerid), money);
					GoOnline = 1;
					break;
				}
			}
			if(GoOnline == 0) PlusBankMoney(Transfer, money);
			strin = "";
			format(strin, sizeof(strin), "{ffffff}Перевод на счёт:\t\t{f26c00}№%d{ffffff}\nСумма перевода:\t\t{7eb900}%d$\n{ffffff}Старый баланс:\t\t{7eb900}%d$\n{ffffff}Текущий баланс:\t\t{7eb900}%d$", Transfer,money,PI[playerid][pBank] + money, PI[playerid][pBank]);
			SPD(playerid,4010,0, "Операция прошла успешно", strin, "Назад", "");

		}
	case 4010: {
			if(!response) return 1;
			SPD(playerid, 4004, 2, "Список операций", "1. Информация о счете\n2. Снять деньги\n3. Положить деньги\n4. Домашний счет\n5. Счёт бизнеса\n6. Изменить PIN-код", "Принять", "Отмена");
		}
	case 4011: {
			if(!response) return 1;
			if(CheckNewBank[playerid] == 1) {
				query = "";
				format(query,128,"INSERT INTO `bank` (fix,playerid,name) VALUES ('1','%i','Основной счет')", PI[playerid][pID]);
				mysql_function_query(cHandle, query, false, "", "");
				SendClientMessage(playerid,COLOR_WHITE,"Вы открыли основной счет в банке!");
				SendClientMessage(playerid,COLOR_WHITE,"Ваш PIN-Код по умолчанию 0000");
				CheckNewBank[playerid] = 0;
				CheckBank(playerid);
			}
			else SendClientMessage(playerid,COLOR_WHITE,"У Вас уже есть основной счет в банке!");
		}
		//
	case 4500: {
			if(!response) return 1;
			new i = GetPVarInt(playerid, "PlayerTaxi");
			DisablePlayerCheckpoint(i);
			switch(listitem) {
			case 0: SetPlayerCheckpoint(i, 1460.6951,-1363.8898,13.2324,5.0);	//Мэрия
			case 1: SetPlayerCheckpoint(i, 1482.0594,-1743.3651,13.2740,5.0);	//Банк
			case 2: SetPlayerCheckpoint(i, 756.6379,-1412.9756,13.5358,5.0);   //Биржа труда
			case 3: SetPlayerCheckpoint(i, -763.4385,-145.0927,65.6349,5.0);	//Лесопилка
			case 4: SetPlayerCheckpoint(i, 648.1764,848.6695,-42.9609,5.0);		//Шахта
			case 5: SetPlayerCheckpoint(i, 1968.1534,-1969.2871,13.5886,5.0);	//Грузчики
			case 6: SetPlayerCheckpoint(i, 1260.6005,-1339.3640,13.0953,5.0);	//Автошкола
			}
			SetPVarInt(i,"TaxiCheck",1);
			SendClientMessage(i,COLOR_WHITE,"Доставте посажира по месту назначения!");
			SendClientMessage(playerid,COLOR_WHITE,"Маршрут выбран!");
		}
		//
	case 5000: {
			if(!response) return 1;
			if(!strlen(inputtext)) return SPD(playerid, 5000, 1, "Смена кода", "Введите новый ключь от админ панели:", "Принять", "Отмена");
			if(strlen(inputtext) < 6 || strlen(inputtext) > 32) return SPD(playerid, 5000, 1, "Смена кода", "Введите новый ключь от админ панели:", "Принять", "Отмена");
			if(NonPass(inputtext)) return SendClientMessage(playerid,COLOR_WHITE,"Этот код слишком легкий!"), SPD(playerid, 5000, 1, "Смена кода", "Введите новый ключь от админ панели:", "Принять", "Отмена");
			strmid(PI[playerid][pAdmKey], inputtext, 0, 10, 255);
			SendClientMessageEx(playerid,COLOR_GREEN,"Ваш новый код от админ панели: %s",inputtext);
			SavePlayer(playerid);
		}
		// INVITE
	case 6000: {
			new p = GetPVarInt(playerid, "PlayerInvite");
			if(response) {
				PI[playerid][pMember] = PI[p][pMember];
				SendClientMessageEx(playerid,COLOR_BLUE,"Вы присоединились к организации \"%s\"",Fraction[PI[p][pMember]-1]);
				SendClientMessageEx(p,COLOR_BLUE,"%s принял предложение присоединиться к \"%s\"",NamePlayer(playerid), Fraction[PI[p][pMember]-1]);
				PI[playerid][pRank] = 1;
				PI[playerid][pJob] = 0;
				SetPlayerTeamColor(playerid);
				SetPlayerSkin(playerid,FractionSkin[PI[p][pMember]-1][0]);
				DeletePVar(playerid, "PlayerInvite");
				return true;
			}
			else SendClientMessageEx(p,COLOR_BLUE,"%s отклонил предложение присоединиться к \"%s\"",NamePlayer(playerid), Fraction[PI[p][pMember]-1]);
			DeletePVar(playerid, "PlayerInvite");
		}
	case 7000: {
			if(!response) return SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
			switch(listitem) {
			case 0: {
					foreach(new i: Player) {
						if(PlayerLogged[i] == false) continue;
						if(PI[i][pJob] == 1)
						{
							strin = "";
							format(strin,100,"Диспетчер: %s(%d) требуется такси примерное расстояние %1.f метров",NamePlayer(playerid),playerid,GetDistanceBetweenPlayers(playerid,i));
							SendClientMessage(i,COLOR_RED,strin);
							SendClientMessage(i,COLOR_RED,"Чтобы принять вызов введите /to [id]");
						}
						SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
					}
					SendClientMessage(playerid,COLOR_RED,"Диспетчер: Ваш вызов принят, ожидайте!");
					ToCall[0] = playerid;
				}
			case 1: {
					foreach(new i: Player) {
						if(PlayerLogged[i] == false) continue;
						if(PI[i][pMember] == 5)
						{
							strin = "";
							format(strin,100,"Диспетчер: %s(%d) требуется помощь медиков, примерное расстояние %1.f метров",NamePlayer(playerid),playerid,GetDistanceBetweenPlayers(playerid,i));
							SendClientMessage(i,COLOR_RED,strin);
							SendClientMessage(i,COLOR_RED,"Чтобы принять вызов введите /to [id]");
						}
						SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
					}
					SendClientMessage(playerid,COLOR_RED,"Диспетчер: Ваш вызов принят, ожидайте!");
					ToCall[1] = playerid;
				}
			case 2: {
					foreach(new i: Player) {
						if(PlayerLogged[i] == false) continue;
						if(PI[i][pMember] == 2 || PI[i][pMember] == 11 || PI[i][pMember] == F_SFPD || PI[i][pMember] == F_LVPD)
						{
							strin = "";
							format(strin,100,"Диспетчер: %s(%d) требуется помощь полиции, примерное расстояние %1.f метров",NamePlayer(playerid),playerid,GetDistanceBetweenPlayers(playerid,i));
							SendClientMessage(i,COLOR_RED,strin);
							SendClientMessage(i,COLOR_RED,"Чтобы принять вызов введите /to [id]");
						}
						SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
					}
					SendClientMessage(playerid,COLOR_RED,"Диспетчер: Ваш вызов принят, ожидайте!");
					ToCall[2] = playerid;
				}
			case 3: {
					foreach(new i: Player) {
						if(PlayerLogged[i] == false) continue;
						if(PI[i][pJob] == 4)
						{
							strin = "";
							format(strin,100,"Диспетчер: %s(%d) требуется автомеханик, примерное расстояние %1.f метров",NamePlayer(playerid),playerid,GetDistanceBetweenPlayers(playerid,i));
							SendClientMessage(i,COLOR_RED,strin);
							SendClientMessage(i,COLOR_RED,"Чтобы принять вызов введите /to [id]");
						}
						SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
					}
					SendClientMessage(playerid,COLOR_RED,"Диспетчер: Ваш вызов принят, ожидайте!");
					ToCall[3] = playerid;
				}
			}
		}
	case 81: if(response)return SPD(playerid,82,DIALOG_STYLE_LIST,"Сейф","{FFFFFF}Положить деньги\nСнять деньги\nПоложить наркотики\nВзять наркотики","Выбрать","Закрыть");
	case 82: {
			if(!response) return true;
			switch(listitem) {
			case 0: SPD(playerid,83,DIALOG_STYLE_INPUT,"Положить деньги в сейф","Введите необходимую сумму:","Готово","");
			case 1: SPD(playerid,84,DIALOG_STYLE_INPUT,"Взять деньги из сейфа","Введите необходимую сумму:","Готово","");
			case 2: SPD(playerid,85,DIALOG_STYLE_INPUT,"Положить наркотики в сейф:","Введите необходимое кол-во наркотиков","Готово","");
			case 3: SPD(playerid,86,DIALOG_STYLE_INPUT,"Взять наркотики из сейфа","Введите необходимое кол-во наркотиков","Готово","");
			}
		}
	case 83: {
			if(response) {
				new money = strval(inputtext);
				if(money < 1 || money > 500000) return SendClientMessage(playerid,COLOR_WHITE,"Нельзя ложить меньше 1 и больше 500.000$");
				if(PI[playerid][pCash] < money) return	SendClientMessage(playerid, COLOR_WHITE, "У вас нет столько денег с собой!");
				if(PI[playerid][pHouseMoney] + money > 5000000) return SendClientMessage(playerid, COLOR_WHITE, "В сейф не помещается больше 5.000.000 долларов");
				PI[playerid][pHouseMoney] += money;
				GiveMoney(playerid,money);
				SendClientMessage(playerid, COLOR_WHITE, "Вы положили деньги в сейф.");
				return true;
			}
		}
	case 84: {
			if(response) {
				new money = strval(inputtext);
				if(PI[playerid][pHouseMoney] < money) return SendClientMessage(playerid, COLOR_WHITE, "Неверное количество");
				PI[playerid][pHouseMoney] -= money;
				GiveMoney(playerid,-money);
				SendClientMessage(playerid, COLOR_WHITE, "Вы взяли деньги из сейфа.");
				return true;
			}
		}
	case 85: {
			if(response) {
				new drugs = strval(inputtext);
				if(drugs < 1 || drugs > 500) return SendClientMessage(playerid,COLOR_WHITE,"Нельзя ложить меньше 1 и больше 150 грамм");
				if(PI[playerid][pStuf][0] < drugs) return SendClientMessage(playerid, COLOR_WHITE, "У вас нет столько наркотиков с собой!");
				if(PI[playerid][pHouseDrugs] > 1000) return SendClientMessage(playerid, COLOR_WHITE, "В сейф не помещается больше 1.000 грамм");
				PI[playerid][pHouseDrugs] += drugs;
				GiveInventory(playerid,35,-drugs);
				SendClientMessage(playerid, COLOR_WHITE, "Вы положили наркотики в сейф.");
				return true;
			}
		}
	case 86: {
			if(response) {
				new drugs = strval(inputtext);
				if(drugs < 1 || drugs > 500) return SendClientMessage(playerid,COLOR_WHITE,"Нельзя брать меньше 1 и больше 500 грамм");
				if(PI[playerid][pHouseDrugs] < drugs) return SendClientMessage(playerid, COLOR_WHITE, "У вас нет столько наркотиков в сейфе.");
				PI[playerid][pHouseMoney] -= drugs;
				GiveInventory(playerid,35,drugs);
				SendClientMessage(playerid, COLOR_WHITE, "Вы взяли наркотики из сейфа.");
				return true;
			}
		}
	case 78: {
			if(response) {
				if(!strlen(inputtext)) return SPD(playerid,78,DIALOG_STYLE_INPUT,"Покупка металла","{ffffff}Введите сколько килограмм металла\nвы хотите купить.\nЦена за 1 кг металла: 20$","Купить","Выйти");
				if(strval(inputtext) <= 0) SendClientMessage(playerid,COLOR_GREY, "Неверное кол-во металла.");
				if(strval(inputtext) <= 0) return SPD(playerid,78,DIALOG_STYLE_INPUT,"Покупка металла","{ffffff}Введите сколько килограмм металла\nвы хотите купить.\nЦена за 1 кг металла: 20$","Купить","Выйти");
				if(PI[playerid][pCash] < strval(inputtext)*20) SPD(playerid,78,DIALOG_STYLE_INPUT,"Покупка металла","{ffffff}Введите сколько килограмм металла\nвы хотите купить.\nЦена за 1 кг металла: 20$","Купить","Выйти");
				if(PI[playerid][pCash] < strval(inputtext)*20) return SendClientMessage(playerid,COLOR_GREY, "Недостаточно денег.");
				if(PI[playerid][pStuf][1] + strval(inputtext) > 200) return SendClientMessage(playerid,COLOR_WHITE,"Вы не можете брать с собой больше 200кг металла!");
				PI[playerid][pCash] -= strval(inputtext)*20;
				GiveInventory(playerid,36,strval(inputtext));
				strin = "";
				format(strin, sizeof(strin), "Вы купили %d килограмм металла за %d$", strval(inputtext),strval(inputtext)*20);
				SendClientMessage(playerid,COLOR_PAYCHEC,strin);
			}
			return 1;
		}
	case 79: {
			if(response) {
				if(!strlen(inputtext) || (!IsNumeric(inputtext))) {
					SPD(playerid,79,DIALOG_STYLE_INPUT,"Наркотики","{ffffff}Введите кол-во килограмм металла\nкоторое хотите использовать.","Готово","Отмена");
				}
				if(strval(inputtext) < 1 || strval(inputtext) > 10) return SendClientMessageEx(playerid, COLOR_GREY, "Кол-во наркотиков от 1 до 10 грамм.");
				if(PI[playerid][pStuf][0] - strval(inputtext) < 0) return SendClientMessage(playerid,COLOR_GREY,"У вас нет столько наркотиков");
				GetPlayerHealth(playerid, PI[playerid][pHeal]);
				SetHealth(playerid, PI[playerid][pHeal]+strval(inputtext)*10);
				if(PI[playerid][pHeal] > 100) SetHealth(playerid, 100);
				GiveInventory(playerid,35,-strval(inputtext));
				ApplyAnimation(playerid,"SMOKING","M_smk_drag",4.1,0,0,0,0,0);
				SendClientMessageEx(playerid, COLOR_BLUE, "Наркотиков использовано: %i грамм", strval(inputtext));
				SetTimerEx("DrugEffectGone", 120000, false, "i", playerid);
				SetPVarInt(playerid, "DrugsTime", gettime()+10);
				strin = "";
				format(strin, 90, "%s употребил(а) наркотики", NamePlayer(playerid));
				ProxDetectorNew(playerid,30.0,COLOR_PURPLE,strin);
				SendClientMessageEx(playerid,COLOR_WHITE,"(( Количество хп: %.0f ))",PI[playerid][pHeal]);
				SetPlayerTime(playerid,17,0);
				SetPlayerDrunkLevel(playerid, 3000);
				SetPlayerWeather(playerid, -68);
			}
			return 1;
		}
	case DID_CHANGEJOB: {
			if(!response) return 1;
			if(listitem == 0) // Краболов
			{
				new freePirs = findFreePirs();
				if(freePirs == -1) return SendClientMessage(playerid, -1, "Все катеры в море, подойдите позже.");
				SetPVarInt(playerid,"FishJob", JOB_KRUB);
				SetPVarInt(playerid, "jobkrub_numberPirs", freePirs);
				SetPVarInt(playerid,"FishSkin", GetPlayerSkin(playerid));
				SetPlayerSkin(playerid, 8);
				SetPVarInt(playerid,"FishCP", CPID_JOBKRUB_TAKECAGE);
				SetPlayerCheckpoint(playerid, -89.8498,-1556.2446,2.6553, 2.0);
				SendClientMessage(playerid, -1, "Вы переоделись в робу моряка. Отнесите все сетки на ваш катер. (красный маркер на радаре)");
				SetPVarInt(playerid, "jobkrub_numberMarshrut", random(3));
				SetPVarInt(playerid, "jobkrub_step", 1);
				pirsinfo[freePirs][statusp] = 1;
				GetPlayerName(playerid, pirsinfo[freePirs][renter], 24);

				strin = "";
				format(strin, 96, "%i пирс: %s", freePirs+1,pirsinfo[freePirs][renter]);
				SetDynamicObjectMaterialText(PirsTable[freePirs], 0, strin, 130, "Arial", 34, 1, -1, 0, 1);

				strin = "";
				format(strin, 96, "Пирс №%i: %s", freePirs+1, pirsinfo[freePirs][renter]);
				UpdateDynamic3DTextLabelText(pirsinfo[freePirs][renter_3d], 0xFFFFCCFF, strin);
				return 1;
			}
			else // Водолаз
			{
				SetPVarInt(playerid,"FishOxygen", 599);
				boxygen[playerid] = CreatePlayerProgressBar(playerid, 549, 59.0, 55.5, 3.2, 0xaccbf199, 600.0);
				ShowPlayerProgressBar(playerid, boxygen[playerid]);
				PTD_oxygen[playerid] = CreatePlayerTextDraw(playerid, 577.599853, 56.000034, "9:59");
				PlayerTextDrawLetterSize(playerid, PTD_oxygen[playerid], 0.334000, 1.114666);
				PlayerTextDrawAlignment(playerid, PTD_oxygen[playerid], 2);
				PlayerTextDrawColor(playerid, PTD_oxygen[playerid], -1378294017);
				PlayerTextDrawSetShadow(playerid, PTD_oxygen[playerid], 0);
				PlayerTextDrawSetOutline(playerid, PTD_oxygen[playerid], 1);
				PlayerTextDrawBackgroundColor(playerid, PTD_oxygen[playerid], 422066032);
				PlayerTextDrawFont(playerid, PTD_oxygen[playerid], 2);
				PlayerTextDrawSetProportional(playerid, PTD_oxygen[playerid], 1);
				PlayerTextDrawShow(playerid, PTD_oxygen[playerid]);
				SetPVarInt(playerid,"FishSkin", GetPlayerSkin(playerid));
				SetPlayerSkin(playerid, 268);
				if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) return 0;
				SetPlayerAttachedObject(playerid, 1, 1010, 1, 0.053070, -0.083673, -0.004646, 86.6, 354.2, 180.0, 1.0, 1.0, 1.0);
				SetPVarInt(playerid,"FishJob", JOB_MIDIA);
				SetPVarInt(playerid,"FishRCP", RCPID_JOBMIDIA_MARK);
				//		        SetPVarInt(playerid,"FishOxygen", 600);
				SetPlayerRaceCheckpoint(playerid, 1, -14.9022,-2292.3523,-7.0089, -14.9022,-2292.3523,-7.0089, 30.0);
				SetPVarInt(playerid, "score_midii", 5);
				return 1;
			}
		}
	case 8000: {
			if(!response) return 1;
			if(GetMoney(playerid) < LicPrice[0]) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
			SendClientMessage(playerid, COLOR_BLUE, "Выходите во двор и садитесь в свободный транспорт!");
			SetPVarInt(playerid, "LicTest", 1);
			SAMoney += LicPrice[0];
			GiveMoney(playerid, -LicPrice[0]);
			pPressed[playerid] = 0;
			return 1;
		}
	case 8002: {
			if(!response) return 1;
			new fuel;
			new bizz = BizzInfo[GetPVarInt(playerid, "FuelBizzID")][bTill] / 3;
			if(sscanf(inputtext, "i",fuel)) return SPD(playerid, 8002, 1,"Заправка", "Сколько литров залить?", "Ок", "Отмена");
			if(fuel < 1 || fuel > 200) {
				SendClientMessage(playerid, COLOR_RED, "Литры от 1 до 200 литров!");
				return SPD(playerid, 8002, 1,"Заправка", "Сколько литров залить?", "Ок", "Отмена");
			}
			if(fuel+Fuel[GetPlayerVehicleID(playerid)] > 200) {
				SendClientMessageEx(playerid, COLOR_GREY, "Вы не можете столько заправить.");
				return SPD(playerid, 8002, 1,"Заправка", "Сколько литров залить?", "Ок", "Отмена");
			}
			if(fuel*bizz > GetMoney(playerid)) {
				SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств!");
				return SPD(playerid, 8002, 1,"Заправка", "Сколько литров залить?", "Ок", "Отмена");
			}
			if(fuel > BizzInfo[GetPVarInt(playerid, "FuelBizzID")][bProduct]) {
				SendClientMessage(playerid, COLOR_GREY, "Недостаточно топлива в заправке!");
				return SPD(playerid, 8002, 1,"Заправка", "Сколько литров залить?", "Ок", "Отмена");
			}
			new price = fuel*bizz;
			GiveMoney(playerid, -price);
			BizzPay[GetPVarInt(playerid, "FuelBizzID")] += price;
			BizzInfo[GetPVarInt(playerid, "FuelBizzID")][bMoney] += price;
			BizzInfo[GetPVarInt(playerid, "FuelBizzID")][bProduct] -= fuel;
			SetBizzInt(BizzInfo[GetPVarInt(playerid, "FuelBizzID")][id], "product", BizzInfo[GetPVarInt(playerid, "FuelBizzID")][bProduct]);
			DeletePVar(playerid, "FuelBizzID");
			SetPVarInt(playerid, "Refueling", fuel);
			TogglePlayerControllable(playerid, false);
			ReFuelTimer[playerid] = SetTimerEx("ReFill", 500, true, "i", playerid);
			return 1;
		}
	case D_GPS: {
			if(!response) return 1;
			DisablePlayerCheckpoint(playerid);
			switch(listitem) {
			case 0: SPD(playerid, D_GPS+1, 2, "GPS", "Правительство\nПолиция LS\nФБР\nБольница LS\nАрмия SF\nАрмия LV\nРепортёры\nАвтошкола LS", "Выбрать", "Отмена");
			case 1: SPD(playerid, D_GPS+2, 2, "GPS", "Лесопилка\nГрузчики\nШахта\nРыболов\nКолхоз\nСад\nЗолотой Прииск\nМорское предприятие\n-> Автобусный Парк\n-> Таксопарк\nСклад продуктов", "Выбрать", "Отмена");
			case 2: SPD(playerid, D_GPS+3, 2, "GPS", "Магазин одежды\nАвтосалон\nБанк\nБиржа труда\nВоенкомат\nКазино\nАвтомастерская", "Выбрать", "Отмена");
			}
			SetPVarInt(playerid,"GPS",1);
		}
	case D_GPS+1: {
			if(!response) return 1;
			DisablePlayerCheckpoint(playerid);
			switch(listitem) {
			case 0: SetPlayerCheckpoint(playerid, 1460.6951,-1363.8898,13.2324,5.0);//marya
			case 1: SetPlayerCheckpoint(playerid, 1588.2457,-1637.9467,13.4229,5.0);//lspd
			case 2: SetPlayerCheckpoint(playerid, 1016.6202,-1549.8442,14.8594,5.0);//fbi
			case 3: SetPlayerCheckpoint(playerid, 1174.2292,-1323.5660,14.9922,5.0);//medic
			case 4: SetPlayerCheckpoint(playerid, -1343.2531,471.6624,7.1875,5.0);//SFa
			case 5: SetPlayerCheckpoint(playerid, 135.7410,1949.2185,19.3811,5.0);//LVa
			case 6: SetPlayerCheckpoint(playerid, 1629.5012,-1705.9374,13.3576,5.0);//sannews
			case 7: SetPlayerCheckpoint(playerid, 1271.9342,-1337.9963,13.3426,5.0);//school
			}
			SetPVarInt(playerid,"GPS",1);
			SendClientMessage(playerid,COLOR_WHITE,"Вы поставили метку на карте");
		}
	case D_GPS+2: {
			if(!response) return 1;
			DisablePlayerCheckpoint(playerid);
			switch(listitem) {
			case 0: SetPlayerCheckpoint(playerid, -762.4676,-140.5281,65.6441,5.0);
			case 1: SetPlayerCheckpoint(playerid, 1968.1534,-1969.2871,13.5886,5.0);
			case 2: SetPlayerCheckpoint(playerid, 639.9478,848.3849,-42.9609,5.0);
			case 3: SetPlayerCheckpoint(playerid, 321.1016,-1894.7426,1.5693,5.0);
			case 4: SetPlayerCheckpoint(playerid, -29.5319,161.2806,2.4297,5.0);
			case 5: SetPlayerCheckpoint(playerid, -1066.4799,-1229.7134,129.2188, 5.0);
			case 6: SetPlayerCheckpoint(playerid, -1349.1777,2067.1504,52.1061, 5.0);
			case 7: SetPlayerCheckpoint(playerid, -52.0606,-1593.2778,2.9066, 5.0);
			case 8: SetPlayerCheckpoint(playerid, 1549.3965,-2275.8274,13.5504,5.0);
			case 9: SetPlayerCheckpoint(playerid, 1548.9623,-2296.5803,13.5488,5.0);
			case 10: SetPlayerCheckpoint(playerid, 2763.7571,-2455.6719,13.5197,5.0);
			}
			SetPVarInt(playerid,"GPS",1);
			SendClientMessage(playerid,COLOR_WHITE,"Вы поставили метку на карте");
		}
	case D_GPS+3: {
			if(!response) return 1;
			DisablePlayerCheckpoint(playerid);
			switch(listitem) {
			case 0: SetPlayerCheckpoint(playerid, 503.3348,-1351.5886,15.9609,5.0);
			case 1: SetPlayerCheckpoint(playerid, 546.9620,-1280.7706,17.2482,5.0);
			case 2: SetPlayerCheckpoint(playerid, 1482.0594,-1743.3651,13.2740,5.0);
			case 3: SetPlayerCheckpoint(playerid, 756.6379,-1412.9756,13.5358,5.0);
			case 4: SetPlayerCheckpoint(playerid, -1481.3160,2664.3616,55.8359,5.0);
			case 5: SetPlayerCheckpoint(playerid, 996.1485,-1155.2185,23.8585,5.0);
			case 6: SetPlayerCheckpoint(playerid, 692.8537,-1575.0930,14.2422,5.0);
			}
			SetPVarInt(playerid,"GPS",1);
			SendClientMessage(playerid,COLOR_WHITE,"Вы поставили метку на карте");
		}
	case D_NMENU: {
			if(!response) return 1;
			switch(listitem) {
			case 0: {
					new fulln = 0, CB[16];
					for(new i = 0; i < GetMaxPlayers(); i++) {
						if(!IsPlayerConnected(i) || PlayerLogged[i] == false || playerid == i) continue;
						if(Ether[i] == true && PI[i][pMember] == PI[playerid][pMember]) fulln++;
					}
					if(fulln > 0) return SendClientMessage(playerid, COLOR_GREY, "Эфир занят! В эфире находиться ваш коллега!");
					if(Ether[playerid] == false) {
						if(PI[playerid][pMember] == F_SAN && PI[playerid][pNews] != F_SAN) PI[playerid][pNews] = F_SAN;
						Ether[playerid] = true;
						strin = "";
						format(strin, 90, "[F] %s вошел(а) в прямой эфир",NamePlayer(playerid));
						SendFMes(PI[playerid][pMember], 0x9ACD32FF, strin);
					}
					else if(Ether[playerid] == true) {
						Ether[playerid] = false;
						Convert(GetPVarInt(playerid,"InEther"),CB);
						if(EtherSms[PI[playerid][pNews]-1] == true)
						format(strin, 90, "[F] %s выключил прием СМС",NamePlayer(playerid)), SendFMes(PI[playerid][pMember], COLOR_LIGHTRED, strin);
						if(EtherCall[PI[playerid][pNews]-1] == true)
						format(strin, 90, "[F] %s выключил прием звонков",NamePlayer(playerid)), SendFMes(PI[playerid][pMember], COLOR_LIGHTRED, strin);
						strin = "";
						format(strin, 90, "[F] %s вышел(а) из прямого эфира (Время в эфире: %s, звонков: %i, СМС: %i)",NamePlayer(playerid), CB, CallNews[PI[playerid][pNews]-1], SmsNews[PI[playerid][pNews]-1]);
						SendFMes(PI[playerid][pMember], COLOR_LIGHTRED, strin);
						SmsNews[PI[playerid][pNews]-1] = 0;
						CallNews[PI[playerid][pNews]-1] = 0;
						EtherSms[PI[playerid][pNews]-1] = false;
						EtherCall[PI[playerid][pNews]-1] = false;
						DeletePVar(playerid, "InEther");
						if(Mobile[playerid] != INVALID_PLAYER_ID) MobileCrash(playerid);
					}
				}
			case 1: {
					if(Ether[playerid] == false) return SendClientMessage(playerid, COLOR_GREY, "Вы должны находиться в прямом эфире!");
					SPD(playerid, D_NMENU+1, 1, "Эфир", "Введите ID или имя игрока:", "Принять", "Отмена");
				}
			case 2: {
					if(Ether[playerid] == false) return SendClientMessage(playerid, COLOR_GREY, "Вы должны находиться в прямом эфире!");
					SPD(playerid, D_NMENU+2, 1, "Эфир", "Введите ID или имя игрока:", "Принять", "Отмена");
				}
			case 3: {
					if(Ether[playerid] == false) return SendClientMessage(playerid, COLOR_GREY, "Вы должны находиться в прямом эфире!");
					new fulln=0;
					switch(PI[playerid][pMember]) {
					case F_SAN: fulln = 0;
					}
					if(EtherCall[fulln] == false) {
						EtherCall[fulln] = true;
						strin = "";
						format(strin, 90, "[F] %s включил прием звонков",NamePlayer(playerid));
						SendFMes(PI[playerid][pMember], 0x9ACD32FF, strin);
					}
					else
					{
						EtherCall[fulln] = false;
						strin = "";
						format(strin, 90, "[F] %s выключил прием звонков",NamePlayer(playerid));
						SendFMes(PI[playerid][pMember], COLOR_LIGHTRED, strin);
					}
				}
			case 4: {
					new fulln=0;
					switch(PI[playerid][pMember]) {
					case F_SAN: fulln = 0;
					}
					if(Ether[playerid] == false) return SendClientMessage(playerid, COLOR_GREY, "Вы должны находиться в прямом эфире!");
					if(EtherSms[fulln] == false) {
						EtherSms[fulln] = true;
						strin = "";
						format(strin, 90, "[F] %s включил прием СМС",NamePlayer(playerid));
						SendFMes(PI[playerid][pMember], 0x9ACD32FF, strin);
					}
					else
					{
						EtherSms[fulln] = false;
						strin = "";
						format(strin, 90, "[F] %s выключил прием СМС",NamePlayer(playerid));
						SendFMes(PI[playerid][pMember], COLOR_LIGHTRED, strin);
					}
				}
			case 5: AdvertList(playerid);
			}
		}
	case D_NMENU+1: {
			if(!response) return 1;
			new playerd;
			if(sscanf(inputtext, "u",playerd)) SPD(playerid, D_NMENU+1, 1, "Эфир", "Введите ID или имя игрока:", "Принять", "Отмена");
			if(playerd == playerid) return SendClientMessage(playerid, COLOR_GREY, "Вы не можете пригласить себя!");
			if(!IsPlayerConnected(playerd)) return SendClientMessage(playerid, COLOR_GREY, T_OFFLINE);
			if(PlayerLogged[playerd] == false) return SendClientMessage(playerid, COLOR_GREY, T_NOLOGGED);
			if(IsPlayerInAnyVehicle(playerid)&&!IsPlayerInVehicle(playerd, GetPlayerVehicleID(playerid)) || !IsPlayerInAnyVehicle(playerid) && !IsPlayerInRangeOfPlayer(10.0, playerid, playerd)) return SendClientMessage(playerid, COLOR_GREY, "Игрок должен находиться с вами в транспорте!");
			if(EtherLive[playerd] == true) return SendClientMessage(playerid, COLOR_GREY, "Игрок уже в прямом эфире!");
			if(PI[playerid][pMember] == F_SAN && PI[playerd][pNews] != 1) return SendClientMessageEx(playerid, COLOR_GREY, "Игрок должен слушать радио: San Andreas News");
			EtherLive[playerd] = true;
			SendClientMessageEx(playerid, 0x9ACD32FF, "Вы пригласили в эфир: %s", NamePlayer(playerd));
			SendClientMessageEx(playerd, 0x9ACD32FF, "%s пригласил(а) вас в эфир", NamePlayer(playerid));
		}
	case D_NMENU+2: {
			if(!response) return 1;
			new playerd;
			if(sscanf(inputtext, "u",playerd)) SPD(playerid, D_NMENU+2, 1, "Эфир", "Введите ID или имя игрока:", "Принять", "Отмена");
			if(playerd == playerid) return SendClientMessage(playerid, COLOR_GREY, "Вы не можете выпроводить себя!");
			if(!IsPlayerConnected(playerd)) return SendClientMessage(playerid, COLOR_GREY, T_OFFLINE);
			if(PlayerLogged[playerd] == false) return SendClientMessage(playerid, COLOR_GREY, T_NOLOGGED);
			if(IsPlayerInAnyVehicle(playerid)&&!IsPlayerInVehicle(playerd, GetPlayerVehicleID(playerid)) || !IsPlayerInAnyVehicle(playerid) && !IsPlayerInRangeOfPlayer(10.0, playerid, playerd)) return SendClientMessage(playerid, COLOR_GREY, "Игрок должен находиться с вами в транспорте!");
			if(EtherLive[playerd] == false) return SendClientMessage(playerid, COLOR_GREY, "Игрок не находиться в прямом эфире!");
			EtherLive[playerd] = false;
			DeletePVar(playerd, "Etherfrac");
			SendClientMessageEx(playerid, COLOR_LIGHTRED, "Вы выпроводили из эфира: %s", NamePlayer(playerd));
			SendClientMessageEx(playerd, COLOR_LIGHTRED, "%s выпроводил(а) вас из эфира", NamePlayer(playerid));
		}
	case D_NMENU+3: {
			if(!response) return 1;
			switch(listitem) {
			case 0: SendClientMessageEx(playerid, COLOR_WHITE, "Вы слушаете радио: {8D8DFF}San Andreas News"),PI[playerid][pNews] = F_SAN;
			case 1: SendClientMessage(playerid, COLOR_LIGHTRED, "Вы выключили радио"),PI[playerid][pNews] = 0;
			}
		}
	case D_NMENU+4: {
			if(!response) return 1;
			switch(listitem) {
			case 0: SPD(playerid, D_NMENU+9, 1, "Панель", "Введите цену за 1 секунду в эфире:", "Принять", "Отмена");
			case 1: SendClientMessage(playerid, COLOR_LIGHTRED, "Временно не доступно.");//SnedSPD(playerid, D_NMENU+10, 1, "Панель", "Введите цену за СМС:", "Принять", "Отмена");
			case 2: SPD(playerid, D_NMENU+11, 1, "Панель", "Введите цену за 1 символ объявления:", "Принять", "Отмена");
			}
		}
	case D_NMENU+5: {
			if(!response) return 1;
			SetPVarInt(playerid, "AdvertID", listitem+1);
			SPD(playerid, D_NMENU+6, 2, "Объявления", "Прочитать объявление\nРедактировать объявление\nУдалить объявление\nОтправить объявление\nОтправить администрации", "Принять", "Назад");
		}
	case D_NMENU+6: {
			if(!response) return AdvertList(playerid),DeletePVar(playerid, "AdvertID");
			switch(listitem) {
			case 0: {
					strin = "";
					format(strin, 128, "Текст: %s - Прислал: %s",AI[GetPVarInt(playerid, "AdvertID")][aText],AI[GetPVarInt(playerid, "AdvertID")][aName]);
					SPD(playerid, D_NMENU+7, 0, "Объявления", strin, "Назад", "");
				}
			case 1: {
					strin = "";
					format(strin, 128, "Текст: %s - Прислал: %s",AI[GetPVarInt(playerid, "AdvertID")][aText],AI[GetPVarInt(playerid, "AdvertID")][aName]);
					SPD(playerid, D_NMENU+8, 1, "Объявления", strin, "Принять", "Назад");
				}
			case 2: {
					for(new i = GetPVarInt(playerid, "AdvertID"); i <= TOTALADVERT[0] - 1; i++) memcpy(AI[i], AI[i+1], 0, 512);
					TOTALADVERT[0]--;
					SendClientMessage(playerid, COLOR_LIGHTRED, "Объявление удалено");
					DeletePVar(playerid, "AdvertID");
					AdvertList(playerid);
				}
			case 3: {
					if(AdvertTime > gettime()) {
						DeletePVar(playerid, "AdvertID");
						SendClientMessage(playerid, COLOR_GREY, "Отправлять обьявления можно раз в 20 сек.");
						return AdvertList(playerid);
					}
					strin = "";
					format(strin, 128, "{ff7f00}Объявление: {ffffff}%s",AI[GetPVarInt(playerid, "AdvertID")][aText]);

					format(strin, 128, "- Обьявление: %s. Прислал: %s. Телефон: %i",AI[GetPVarInt(playerid, "AdvertID")][aText], AI[GetPVarInt(playerid, "AdvertID")][aName],AI[GetPVarInt(playerid, "AdvertID")][aPhone]);
					SendClientMessageToAll(COLOR_WHITE, strin);
					strin = "";
					format(strin, 128, "{ff7f00}Прислал: {ffffff}%s | {ff7f00}Тел: {ffffff}%d | {ff7f00}Проверил: {ffffff}%s", AI[GetPVarInt(playerid, "AdvertID")][aName],AI[GetPVarInt(playerid, "AdvertID")][aPhone], NamePlayer(playerid));
					SendClientMessageToAll(F_TIMESS_COLOR, strin);
					for(new i = GetPVarInt(playerid, "AdvertID"); i <= TOTALADVERT[0] - 1; i++) memcpy(AI[i], AI[i+1], 0, 512);
					TOTALADVERT[0]--;
					AdvertTime = gettime() + 20;
					DeletePVar(playerid, "AdvertID");
					AdvertList(playerid);
				}
			case 4: {
					strin = "";
					format(strin, 128, "[A] [AD] Обьявление: %s. Прислал: %s (Отправил: %s)",AI[GetPVarInt(playerid, "AdvertID")][aText], AI[GetPVarInt(playerid, "AdvertID")][aName], NamePlayer(playerid));
					SendAdminMessage(COLOR_LIGHTRED, strin);
					for(new i = GetPVarInt(playerid, "AdvertID"); i <= TOTALADVERT[0] - 1; i++) memcpy(AI[i], AI[i+1], 0, 512);
					TOTALADVERT[0]--;
					SendClientMessage(playerid, COLOR_LIGHTRED, "Объявление отправлено администрации!");
					DeletePVar(playerid, "AdvertID");
					AdvertList(playerid);
				}
			}

		}
	case D_NMENU+7: SPD(playerid, D_NMENU+6, 2, "Объявления", "Прочитать объявление\nРедактировать объявление\nУдалить объявление\nОтправить объявление\nОтправить администрации", "Принять", "Назад");
	case D_NMENU+8: {
			if(!response) return SPD(playerid, D_NMENU+6, 2, "Объявления", "Прочитать объявление\nРедактировать объявление\nУдалить объявление\nОтправить объявление\nОтправить администрации", "Принять", "Назад");
			new text[60];
			if(sscanf(inputtext, "s[60]",text)) {
				strin = "";
				format(strin, 128, "Текст: %s - Прислал: %s",AI[GetPVarInt(playerid, "AdvertID")][aText],AI[GetPVarInt(playerid, "AdvertID")][aName]);
				return SPD(playerid, D_NMENU+8, 1, "Объявления", strin, "Принять", "Назад");
			}
			strmid(AI[GetPVarInt(playerid, "AdvertID")][aText],text,0,strlen(text),sizeof(text));
			SendClientMessage(playerid, COLOR_LIGHTGREEN, "Объявление отредактировано и сохранено!");
			SPD(playerid, D_NMENU+6, 2, "Объявления", "Прочитать объявление\nРедактировать объявление\nУдалить объявление\nОтправить объявление\nОтправить администрации", "Принять", "Назад");
		}
	case D_NMENU+9: {
			if(!response) return 1;
			new price;
			if(sscanf(inputtext, "i",price)) return SPD(playerid, D_NMENU+9, 1, "Панель", "Введите цену за 1 секунду в эфире:", "Принять", "Отмена");
			if(price < 1 || price > 50) return SPD(playerid, D_NMENU+9, 1, "Панель", "Введите цену за 1 секунду в эфире:", "Принять", "Отмена");
			CallPrice[PI[playerid][pNews]-1] = price;
			SendClientMessageEx(playerid, COLOR_LIGHTGREEN, "Цена за 1 секунду в эфире: %i долларов", price);
			format(NewsPrice, sizeof(NewsPrice),"%i, %i, %i, %i, %i, %i", SmsPrice[0], SmsPrice[1], CallPrice[0], CallPrice[1]);
			SetOtherStr("newsprice", NewsPrice);
		}
	case D_NMENU+10: {
			if(!response) return 1;
			new price;
			if(sscanf(inputtext, "i",price)) return SPD(playerid, D_NMENU+10, 1, "Панель", "Введите цену за СМС:", "Принять", "Отмена");
			if(price < 1 || price > 100) return SPD(playerid, D_NMENU+10, 1, "Панель", "Введите цену за СМС:", "Принять", "Отмена");
			price = 50;
			SendClientMessageEx(playerid, COLOR_LIGHTGREEN, "Цена за СМС: %i долларов", price);
		}
	case D_NMENU+12: NewsPanel(playerid);
		//setname
	case CHANGE_NICK_1: {
			if(!response) return true;
			if(!strcmp(inputtext, PI[playerid][pPassword], true)) return SPD(playerid, CHANGE_NICK_2, 1, "Введите новый ник", "Введите Ваш новый ник", "Готово", "Выход");
			return true;
		}
	case CHANGE_NICK_2: {
			if(!response) return true;
			if(GetPVarInt(playerid, "ChangeNickQuery") == 1) return SendClientMessage(playerid, -1, "Нельзя запросить смену ника чаще, чем 1 раз за сеанс");
			new text[128];
			SetPVarInt(playerid, "ChangeNickQuery", 1);
			SetPVarString(playerid, "NewNickName", inputtext);
			format(text, sizeof(text), "Игрок %s [%d] просит сменить ник на %s.", NamePlayer(playerid), playerid, inputtext);
			SendAdminMessage(COLOR_BLUE, text);
			return true;
		}
		//spec
	case D_ADMIN_PRISON_TIME: {
			if(!response) return true;
			if(sscanf(inputtext, "d", params[0]) || params[0] < 60 || params[0] > 600) return SendClientMessage(playerid, COLOR_GREY, "Время не может быть меньше 60 сек, и больше 600"), SPD(playerid, D_ADMIN_PRISON_TIME, 1, " ", "Введите время (в сек), на которое вы хотите посадить игрока", "Далее", "Выход");
			SendClientMessage(playerid, COLOR_GREY, "Вы посадили игрока в тюрьму");
		}
	case D_ADMIN_KICK_REASON: {
			if(!response) return true;
			if(sscanf(inputtext, "s[32]", params[0])) return SendClientMessage(playerid, COLOR_GREY, "Введите причину!"), SPD(playerid, D_ADMIN_KICK_REASON, 1, " ", "Введите причину кика данного игрока", "Далее", "Выход");
			new text[50];
			format(text, sizeof(text), "%d %s", GetPVarInt(playerid, "SpecID"), params[0]);
			return cmd::kick(playerid, text);
		}
	case D_ADMIN_WARN_REASON: {
			if(!response) return true;
			if(sscanf(inputtext, "s[32]", params[0])) return SendClientMessage(playerid, COLOR_GREY, "Введите причину!"), SPD(playerid, D_ADMIN_WARN_REASON, 1, " ", "Введите причину предупреждения данного игрока", "Далее", "Выход");
			new text[50];
			format(text, sizeof(text), "/warn %d %s", GetPVarInt(playerid, "SpecID"), params[0]);
			return cmd::warn(playerid, text);
		}
	case D_ADMIN_MUTE_TIME_REASON: {
			if(!response) return true;
			if(sscanf(inputtext, "p<,>ds[32]", params[0], params[1])) return SendClientMessage(playerid, COLOR_GREY, "Введите причину!"), SPD(playerid, D_ADMIN_MUTE_TIME_REASON, 1, " ", "Введите время и причину бана чата данного игрока (через запятую)", "Далее", "Выход");
			new text[50];
			format(text, sizeof(text), "%d %d %s", GetPVarInt(playerid, "SpecID"), params[0], params[1]);
			return cmd::mute(playerid, text);
		}
	case 4012: {
			if(!response) return true;
			return cmd::houzebank(playerid, inputtext);
		}
	case 4014: {
			if(!response) return true;
			return cmd::biznesbank(playerid, inputtext);
		}
	case 4013: {
			if(!response) return true;
			return cmd::order(playerid, inputtext);
		}
		//
	case 68: {
			if(response) {
				new drugs = strval(inputtext);
				if(drugs*20 > PI[playerid][pCash]) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно денег!");
				if(drugs + PI[playerid][pGrains] > 100 || drugs < 1)return SendClientMessage(playerid, COLOR_GREY, "Неверное количество!");
				strin = "";
				format(strin, sizeof(strin),"Вы купили %d зерен, за %d баксов",drugs,drugs*10);
				SendClientMessage(playerid, COLOR_PAYCHEC, strin);
				PI[playerid][pGrains] += drugs;
				return 1;
			}
			else return SendClientMessage(playerid, COLOR_WHITE,"Проваливай отсюда, чтобы мои глаза тебя больше здесь не видели!");
		}
	case 69: {
			if(response) {
				new drugs = strval(inputtext);
				if(drugs*20 > PI[playerid][pCash]) return SendClientMessage(playerid, COLOR_GREY, "Недостаточно денег!");
				if(drugs + PI[playerid][pStuf][0] > 100 || drugs < 1)return SendClientMessage(playerid, COLOR_GREY, "Неверное количество!");
				strin = "";
				format(strin, sizeof(strin),"Вы купили %d грамм, за %d баксов",drugs,drugs*20);
				SendClientMessage(playerid, COLOR_PAYCHEC, strin);
				GiveInventory(playerid,35,drugs);
				return 1;
			}
			else return SendClientMessage(playerid, COLOR_WHITE,"Проваливай отсюда, чтобы мои глаза тебя больше здесь не видели!");
		}
	case 751: {
			if(response) {
				if(!strlen(inputtext) || (!IsNumeric(inputtext)))
				return SPD(playerid,751,DIALOG_STYLE_INPUT,"Донат меню","{FFFFFF}Введите код, полученный Вами при оплате и нажите {00FF00}'Далее':\n","Далее","Отмена");

				new code = strval(inputtext);
				new query_mysql[120];
				mysql_format(cHandle, query_mysql,120, "SELECT Money FROM "TABLE_DONATE" WHERE Code = '%d' AND Status = '1'",code);
				mysql_function_query(cHandle, query_mysql, true, "GetDonateMoney", "dd", playerid,code);
			}
		}
	case 471: {
			if(!response) return true;
			else {
				switch(listitem) {
				case 0: {
						if(PI[playerid][pSmoke] == 0) return SendClientMessage(playerid, COLOR_GREY, "У вас нет сигарет (Купите их в 24/7)"),SPD(playerid,471,DIALOG_STYLE_LIST,"{FFFFFF}Пачка | {C7001B}Пачка сигарет","{FFFFFF}~ Закурить сигарету\n~ Передать сигареты\n~ Проверить запас сигарет","Выбрать","Отмена");
						PI[playerid][pSmoke] --;
						SetPlayerChatBubble(playerid,"медленным движением руки, достал и прикурил сигарету",COLOR_PURPLE, 5.0,5000);
						SetPlayerSpecialAction(playerid,SPECIAL_ACTION_SMOKE_CIGGY);
						SetPVarInt(playerid,"Smoke",1);
						return true;
					}
				case 1: {
						SPD(playerid,48,DIALOG_STYLE_INPUT,"{FFFFFF}Пачка | {C7001B}Передать сигареты","{FFFFFF}Введите ID и кол-во сигарет\nПример: 100,10","Передать","Отмена");
						return true;
					}
				case 2: {
						strin = "";
						format(strin, sizeof(strin), "Осталось %i сигарет",PI[playerid][pSmoke]);
						SendClientMessage(playerid,COLOR_GREY,strin);
						SetPlayerChatBubble(playerid,"открыл пачку сигарет и пересчитал сигареты",COLOR_PURPLE, 5.0,5000);
						return true;
					}
				}
			}
			return true;
		}
	case 481: {
			if(!response) return SPD(playerid,471,DIALOG_STYLE_LIST,"{FFFFFF}Сигареты","{FFFFFF}Закурить сигарету\nПередать сигареты\nПроверить запас сигарет","Выбрать","Отмена");
			else {
				new ids,kolvo;
				sscanf(inputtext,"p<,>dd",ids,kolvo);
				if(!strlen(inputtext)) return SPD(playerid,481,DIALOG_STYLE_INPUT,"{FFFFFF}Пачка | {C7001B}Передать сигареты","{FFFFFF}Введите ID и кол-во сигарет\nПример: 100,10","Передать","Отмена");
				if(strval(inputtext) < 0 || strval(inputtext) > PI[playerid][pSmoke]) return SPD(playerid,481,DIALOG_STYLE_INPUT,"{FFFFFF}Пачка | {C7001B}Передать сигареты","{FFFFFF}Введите ID и кол-во сигарет\nПример: 100,10","Передать","Отмена");
				if(PI[playerid][pSmoke] < 1) return SendClientMessage(playerid, COLOR_GREY, "У вас нет сигарет (Купите их в 24/7)");
				if(!ProxDetectorS(5.0, playerid, ids)) return SendClientMessage(playerid,COLOR_GREY,"Вы далеко друг от друга!");
				PI[playerid][pSmoke] -= kolvo;
				PI[ids][pSmoke] += kolvo;
				strin = "";
				format(strin, sizeof(strin), "Осталось %i сигарет",PI[playerid][pSmoke]);
				SendClientMessage(playerid,COLOR_GREY,strin);
				SetPlayerChatBubble(playerid,"передал сигарету",COLOR_PURPLE, 5.0,5000);
				strin = "";
				format(strin, sizeof(strin), "Вам дали %i сигарет",kolvo);
				SendClientMessage(ids,COLOR_GREY,strin);
				return true;
			}
		}
	case 209: {
			if(!response) return DeletePVar(playerid, "LicName");
			if(IsPlayerInRangeOfPlayer(15.0, playerid, GetPVarInt(playerid, "LicName"))) {
				new text[32];
				switch(listitem) {
				case 0: text = "водительские права";
				case 1: text = "лицензию на судоходство";
				case 2: text = "лицензию на полеты";
				case 3: text = "лицензию на рыболовство";
				case 4: text = "лицензию на оружие";
				case 5: text = "патроны";
				case 6: text = "наркотики";
				}
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Вы забрали %s у %s", text, NamePlayer(GetPVarInt(playerid, "LicName")));
				SendClientMessageEx(GetPVarInt(playerid, "LicName"), COLOR_LIGHTBLUE, "%s забрал у вас %s", NamePlayer(playerid), text);
				if(listitem >= 0 && listitem < 5) {
					PI[GetPVarInt(playerid, "LicName")][pLic][listitem] = 0;
					if(IsPlayerInAnyVehicle(GetPVarInt(playerid, "LicName")) && listitem < 3) RemovePlayerFromVehicle(GetPVarInt(playerid, "LicName"));
				}
				else {
					if(listitem == 5) {
						if(PI[GetPVarInt(playerid, "LicName")][pStuf][2] != 0) PI[GetPVarInt(playerid, "LicName")][pStuf][2] = 0;
					}
					if(listitem == 6) {
						if(PI[GetPVarInt(playerid, "LicName")][pStuf][0] != 0) PI[GetPVarInt(playerid, "LicName")][pStuf][0] = 0;
					}
				}
			}
			else SendClientMessage(playerid, COLOR_GREY, "Игрок слишком далеко!");
			DeletePVar(playerid, "LicName");
		}
	case D_HEAL+31: {
			new playerd = GetPVarInt(playerid, "PlayerGun"), weapon = GetPVarInt(playerid, "PlayerGun_"), price = GetPVarInt(playerid, "PlayerGPrice"), ammo = GetPVarInt(playerid, "PlayerGAmmo");
			if(response) {
				if(PI[playerid][pCash] < price) {
					SendClientMessageEx(playerd,0x6495EDFF, "У игрока %s недостаточно средств", NamePlayer(playerid));
					DeletePVar(playerid, "PlayerGun");
					DeletePVar(playerid, "PlayerGun_");
					DeletePVar(playerid, "PlayerGAmmo");
					DeletePVar(playerid, "PlayerGPrice");
					return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств");
				}
				GiveMoney(playerid, -price);
				GiveMoney(playerd, price);
				new metall[MAX_PLAYERS];
				metall[playerid] = Random(6,11);
				GiveInventory(playerd,36,-metall[playerid]);
				GiveInventory(playerd,37,-ammo);
				if(weapon == 22) GiveInventory(playerid, 18, ammo);
				if(weapon == 23) GiveInventory(playerid, 19, ammo);
				if(weapon == 24) GiveInventory(playerid, 20, ammo);
				if(weapon == 25) GiveInventory(playerid, 21, ammo);
				if(weapon == 29) GiveInventory(playerid, 24, ammo);
				if(weapon == 30) GiveInventory(playerid, 26, ammo);
				if(weapon == 31) GiveInventory(playerid, 27, ammo);
				SendClientMessageEx(playerd, COLOR_BLUE, "Вы продали оружие %s'у за %i долларов.", NamePlayer(playerid), price);
				SendClientMessageEx(playerid, COLOR_BLUE, "Вы купили оружие у %s c %i патронами. Цена: %i", NamePlayer(playerd), ammo, price);
				strin = "";
				format(strin, 100, "%s сделал оружие и передал в руки %s",NamePlayer(playerd), NamePlayer(playerid));
				ProxDetectorNew(playerd, 30.0, COLOR_PURPLE, strin);
			}
			else SendClientMessageEx(playerd, COLOR_BLUE, "%s отклонил предложение купить у вас оружие", NamePlayer(playerid));
			DeletePVar(playerid, "PlayerGun");
			DeletePVar(playerid, "PlayerGun_");
			DeletePVar(playerid, "PlayerGAmmo");
			DeletePVar(playerid, "PlayerGPrice");
			return 1;
		}
	case D_HEAL+32: {
			new playerd = GetPVarInt(playerid, "PlayerDrugs"), price = GetPVarInt(playerid, "DrugsPrice"), gramm = GetPVarInt(playerid, "PlayerDrugsKG");
			if(response) {
				if(PI[playerid][pCash] < price) {
					SendClientMessageEx(playerd,0x6495EDFF, "У игрока %s недостаточно средств", NamePlayer(playerid));
					DeletePVar(playerid, "PlayerDrugs");
					DeletePVar(playerid, "DrugsPrice");
					DeletePVar(playerid, "PlayerDrugsKG");
					return SendClientMessage(playerid, COLOR_GREY, "Недостаточно средств");
				}
				GiveMoney(playerid, -price);
				GiveMoney(playerd, price);
				GiveInventory(playerd,35,-gramm);
				GiveInventory(playerid,35,gramm);
				SendClientMessageEx(playerd, COLOR_BLUE, "Вы продали наркотики (%i грамм) за %i долларов. Наркотиков в кармане: %i", gramm, price, PI[playerd][pStuf][0]);
				SendClientMessageEx(playerid, COLOR_BLUE, "Вы купили наркотики  у %s'a (%i грамм). Цена: %i", NamePlayer(playerd), gramm, price);
				strin = "";
				format(strin, 100, "%s достал наркотики и передал в руки %s",NamePlayer(playerd), NamePlayer(playerid));
				ProxDetectorNew(playerd, 30.0, COLOR_PURPLE, strin);
			}
			else SendClientMessageEx(playerd, COLOR_BLUE, "%s отклонил предложение купить у вас наркотики", NamePlayer(playerid));
			DeletePVar(playerid, "PlayerDrugs");
			DeletePVar(playerid, "DrugsPrice");
			DeletePVar(playerid, "PlayerDrugsKG");
			return 1;
		}
	case D_HEAL+22: {
			if(!response)  return ProductList(playerid), DeletePVar(playerid, "ProductID");
			if(strcmp(ProductInfo[GetPVarInt(playerid, "ProductID")][pName], NamePlayer(playerid), true) == 0) { DeletePVar(playerid, "ProductID"); ProductList(playerid); return SendClientMessage(playerid, COLOR_GREY, "Ты не можешь выполнить свой заказ!"); }
			if(ProductInfo[GetPVarInt(playerid, "ProductID")][pStatus] == true) { SendClientMessage(playerid, COLOR_GREY, "Заказ уже выполняется кем-либо!"); DeletePVar(playerid, "ProductID"); return ProductList(playerid); }
			new Float:VPos[3], i = ProductInfo[GetPVarInt(playerid, "ProductID")][pBizzid];
			SendClientMessageEx(playerid, F_BLUE_COLOR, "Вы приняли заказ от %s. Чтобы отменить, введите: /cancel", ProductInfo[GetPVarInt(playerid, "ProductID")][pName]);
			GetPlayerPos(playerid, VPos[0], VPos[1], VPos[2]);
			DisablePlayerRaceCheckpoint(playerid);
			ProductInfo[GetPVarInt(playerid, "ProductID")][pStatus] = true;
			SetPlayerRaceCheckpoint(playerid, 1, BizzInfo[i][bEntrx], BizzInfo[i][bEntry], BizzInfo[i][bEntrz], 0.0,0.0,0.0,6);
			SendClientMessageEx(playerid, COLOR_YELLOW, "На карте отмечен: %s. Расстояние: %.1f метров",BizzInfo[i][bName],GetDistanceBetweenPoints(VPos[0], VPos[1], VPos[2], BizzInfo[i][bEntrx], BizzInfo[i][bEntry], BizzInfo[i][bEntrz]));
			strin = "";
			format(strin, 50, "{9ACD32}Продуктов: {ffffff}%i", ProductInfo[GetPVarInt(playerid, "ProductID")][pTill]);
			ProductInfo[GetPVarInt(playerid, "ProductID")][pText3D] = Create3DTextLabel(strin, 0xffffffff, 0.0, 0.0, 0.0, 30.0, 0, 1);
			Attach3DTextLabelToVehicle(ProductInfo[GetPVarInt(playerid, "ProductID")][pText3D], GetPlayerVehicleID(playerid), 0, -1.0, 0.5);
		}
	case D_HEAL+23: {
			if(!response) return true;
			SetPVarInt(playerid, "ProductID", listitem+1);
			strin = "";
			format(strin, 256, "{ffffff}Номер заказа {8D8DFF}\t\t№%i %s\n\n{ffffff}Заказал:\t\t{8D8DFF}%s\n{ffffff}Куда:\t\t\t{8D8DFF}%s\n{ffffff}Количество:\t\t{8D8DFF}%i {ffffff}продуктов\n{ffffff}Оплата:\t\t{8D8DFF}2000{ffffff} долларов",
			listitem+1, (!ProductInfo[listitem+1][pStatus]) ? ("{8D8DFF}(Доступен)") : ("{FF6347}(Выполняется)"), ProductInfo[listitem+1][pName], BizzInfo[ProductInfo[listitem+1][pBizzid]][bName],ProductInfo[listitem+1][pTill]);
			SPD(playerid, D_HEAL+22, 0, "Заказ", strin, "Принять", "Назад");
		}
	case D_HEAL+24: {

			if(!response) return true;
			new till = strval(inputtext);
			new i = GetPVarInt(playerid, "PlayerBizz");
			SendClientMessageEx(playerid, F_BLUE_COLOR,"ПРОДУКТОВ: %i", till);
			if(till < 1000 || till > 20000-BizzInfo[i][bProduct]) {
				SendClientMessage(playerid, COLOR_GREY, "Кол-во продуктов от 1000 до 10000!");
				return SPD(playerid, D_HEAL+24, 1, "Продукты", "{ffffff}Введите кол-во продуктов и оплату (через запятую):\n\nНа {8D8DFF}50{ffffff} единиц продукции приходиться {8D8DFF}50 {ffffff}долларов\n\n", "Принять", "Отмена");
			}
			if(PI[playerid][pBank] < till*26) return SendClientMessage(playerid, COLOR_GREY, "На вашем счету в банке не хватает денег!");
			TOTALPRODUCT++;
			strmid(ProductInfo[TOTALPRODUCT][pName],NamePlayer(playerid),0,strlen(NamePlayer(playerid)),MAX_PLAYER_NAME);
			ProductInfo[TOTALPRODUCT][pPrice] = till*26;
			ProductInfo[TOTALPRODUCT][pTill] = till;
			ProductInfo[TOTALPRODUCT][pBizzid] = i;
			ProductInfo[TOTALPRODUCT][pStatus] = false;
			MinusBankMoney(playerid, ProductInfo[TOTALPRODUCT][pPrice]);
			SendClientMessageEx(playerid, F_BLUE_COLOR, "Вы заказали %i продуктов, Снято с кредитки: %i долларов.", till, ProductInfo[TOTALPRODUCT][pPrice]);
			foreach(new p: Player) {
				if(!IsPlayerConnected(p) || PlayerLogged[p] == false || PI[p][pJob] != 3) continue;
				SendClientMessageEx(p,  COLOR_ALLDEPT, "Поступил новый заказ от %s. Используйте: /plist", NamePlayer(playerid));
			}
		}
	case D_HEAL+55: {
	        if(response && PI[playerid][pAdmLevel] > 1) {
	            switch(listitem) {
	                case 0: {
						SendClientMessage(playerid, -1, "Команды администратора:");
						if(PI[playerid][pAdmLevel] >= 1) SendClientMessage(playerid, -1, "<> {9ACD32}(/a)dmin /mute /unmute /spec /specoff /stats /ans /admins /apanel");
						if(PI[playerid][pAdmLevel] >= 2) SendClientMessage(playerid, -1, "<> {9ACD32}/kick /goto /slap /jail /unjail /setskin ");
						if(PI[playerid][pAdmLevel] >= 3) SendClientMessage(playerid, -1, "<> {9ACD32}/fly /warn /unwarn /ban /spawncars /spcarid /delcarid /atake /setweather /settime");
						if(PI[playerid][pAdmLevel] >= 4) SendClientMessage(playerid, -1, "<> {9ACD32}/skick /givemoney /gethere /unban /veh /msg /delcar /afill /hp /showall /agivelic");
						if(PI[playerid][pAdmLevel] >= 5) SendClientMessage(playerid, -1, "<> {9ACD32}/setstats /banip /unbanip /sban /makeleader /sethp /dellac /givegun /giveinventory /givefskill /mp /scene (add/del) /derby (add/del)");
	                }
	                case 1: cmd::tp(playerid, "");
	                case 2: return mysql_function_query(cHandle, "SELECT * FROM  `"TABLE_ACCOUNT"` WHERE  `Admin` !=0 ORDER BY  `"TABLE_ACCOUNT"`.`Admin` DESC", true, "showAdmins", "i", playerid);
	                case 3: return mysql_function_query(cHandle, "SELECT * FROM  `"TABLE_ACCOUNT"` WHERE  `Leader` !=0 ORDER BY  `"TABLE_ACCOUNT"`.`Leader` DESC", true, "showLeaders", "i", playerid);
	                case 4: cmd::spawncars(playerid, "");
	                case 5: cmd::respawncars(playerid, "");
	                case 6: if(PI[playerid][pAdmLevel] >= 5) return SPD(playerid, D_HEAL + 56, DIALOG_STYLE_LIST, "Панель главного администратора", "Запустить рестарт сервера\nЗакрыть сервер на технические работы\nПродать все дома\nПродать все бизнесы\nПродать все предприятия\nСохранить всё\nПополнить все склады", "Выбрать", "Назад");
	            }
	        }
		}
	case D_HEAL+56: {
	        if(!response && PI[playerid][pAdmLevel] > 1) return SPD(playerid, D_HEAL + 55, DIALOG_STYLE_LIST, "Панель администратора", "Команды администратора\nМеню телепортаций\nСписок администрации\nСписок лидеров\nЗаспавнить незанятый транспорт\nЗаспавнить весь транспорт\nРаздел главного администратора", "Выбрать", "Отмена");
	        if(response && PI[playerid][pAdmLevel] >= 5) {
	            switch(listitem) {
	                case 0: {
						foreach(new i: Player) {
							SendClientMessage(i, COLOR_LIGHTRED, "Рестарт сервера,пожалуйста перезайдите!");
							GameTextForPlayer(i, "~b~RESTART", 5000, 0);
							SavePlayer(i);
							SetTimerEx("KickPublic", 300, false, "d", i);
						}
						SaveMoyor();
						SaveWarehouse();
						return 1;
	                }
	                case 1: {
						SendClientMessageToAll(COLOR_LIGHTRED, "Сервер закрыт на технические работы!");
						foreach(new i: Player) {
							SavePlayer(i);
							SetTimerEx("KickPublic", 300, false, "d", i);
						}
						SendRconCommand("hostname "NameServer" | Технические работы");
						SendRconCommand("password 239932");
						return 1;
	                }
	                case 2: {
	                    for(new H = 1; H < TOTALHOUSE; H++) {
							strmid(HouseInfo[H][hOwner], "None", 0, strlen("None"), MAX_PLAYER_NAME);
							SetHouseStr(H, "hOwner", "None");

							HouseInfo[H][hLock] = 0;
							HouseInfo[H][hOplata] = 0;
							HouseInfo[H][hOutput] = 0;
							HouseInfo[H][hGrant] = 0;
							HouseInfo[H][hMedicine] = 0;
							UpdateHouse(H);

							query = "";
							format(query, 300, "UPDATE "TABLE_HOUSE" SET  hOwner = '%s', hLock = %d, hOplata = %d, hOutput = '0', hGrant = '0', hMedicine = '0' WHERE id = %d LIMIT 1", HouseInfo[H][hOwner], HouseInfo[H][hLock], HouseInfo[H][hOplata],H);
							mysql_function_query(cHandle, query, false, "", "");

							return SendClientMessage(playerid, COLOR_PAYCHEC, "Вы продали все дома!");
						}
	                }
	                case 3: {
	                    for(new B = 1; B < TOTALBIZZ; B++) {

							strmid(BizzInfo[B][bOwner], "None", 0, strlen("None"), MAX_PLAYER_NAME);
							strmid(BizzInfo[B][bMafia], "None", 0, strlen("None"), MAX_PLAYER_NAME);

							PlusBankMoney(playerid, BizzInfo[B][bMoney]), CheckBank(playerid);
							PlusBankMoney(playerid, BizzInfo[B][bBank]), CheckBank(playerid);

							BizzInfo[B][bLock] = 0;
							BizzInfo[B][bBuyPrice] = 0;
							BizzInfo[B][bMoney] = 0;
							BizzInfo[B][bBank] = 0;
							BizzInfo[B][bLic] = 0;
							BizzInfo[B][bEnter] = 100;
							BizzInfo[B][bTill] = 50;
							BizzInfo[B][bProduct] = 10000000;

							query = "";
							format(query, 512, "UPDATE "TABLE_BIZZ" SET owner='%s', block=%d, money=%d, bank=%d, lic=%d, penter=%d, till=%d, buyprice=%d, Mafia = '%s', product = %d WHERE id = %d LIMIT 1",
							BizzInfo[B][bOwner], BizzInfo[B][bLock], BizzInfo[B][bMoney], BizzInfo[B][bBank], BizzInfo[B][bLic], BizzInfo[B][bEnter], BizzInfo[B][bTill], BizzInfo[B][bBuyPrice],BizzInfo[B][bMafia],BizzInfo[B][bProduct],B);
							mysql_function_query(cHandle, query, false, "", "");

							UpdateBizz(B);

							return SendClientMessage(playerid, COLOR_PAYCHEC, "Вы продали все бизнесы!");
						}
	                }
	                case 4: {
						query = "";
						format(query, 512, "UPDATE `"TABLE_LBIZZ"` SET `owner`='None',`worker1`='None',`worker2`='None',`worker3`='None' WHERE 1");
						mysql_function_query(cHandle, query, false, "", "");

						format(LBizz[1][lOwner],MAX_PLAYER_NAME,"None");
						format(LBizz[2][lOwner],MAX_PLAYER_NAME,"None");

						return SendClientMessage(playerid, COLOR_PAYCHEC, "Вы продали все предприятия!");
	                }
	                case 5: {
						foreach(new i: Player) SavePlayer(i);
						SaveMoyor();
						SaveWarehouse();

						return SendClientMessage(playerid, COLOR_PAYCHEC, "Сохранение прошло успешно!");
	                }
	                case 6: {
						for(new W = 0; W != 2; W++) ArmyMats[W] = 50000;
						for(new W = 6; W != 11; W++) Metal[W] = 50000, Drugs[W] = 5000, Mats[W] = 50000;

						UpdateWarehouse();
						SaveWarehouse();

						return SendClientMessage(playerid, COLOR_PAYCHEC, "Склады были пополнены!");
	                }
				}
	        }
		}
	case D_HEAL+57: {
	    if(response && PI[playerid][pAdmLevel] > 1)
	        return SPD(playerid, D_HEAL + 55, DIALOG_STYLE_LIST, "Панель администратора", "Команды администратора\nМеню телепортаций\nСписок администрации\nСписок лидеров\nЗаспавнить незанятый транспорт\nЗаспавнить весь транспорт\nРаздел главного администратора", "Выбрать", "Отмена");
		}

	case 70: {
			if(!response) return 1;
			switch(listitem) {
			case 0: SetPlayerTeamColor(playerid);
			case 1: SetPlayerColor(playerid, 0xFFFFFF00);
			case 2: SetPlayerColor(playerid, 0xff000020);
			case 3: SetPlayerColor(playerid, 0xffa50020);
			case 4: SetPlayerColor(playerid, 0xffd70020);
			case 5: SetPlayerColor(playerid, 0xffffff20);
			case 6: SetPlayerColor(playerid, 0xffff0020);
			case 7: SetPlayerColor(playerid, 0x00ff0020);
			case 8: SetPlayerColor(playerid, 0xa25f2a20);
			case 9: SetPlayerColor(playerid, 0x00000020);
			case 10: SetPlayerColor(playerid, 0x0000ff20);
			case 11: SetPlayerColor(playerid, 0x42aaff20);
			case 12: SetPlayerColor(playerid, 0x8b00ff20);
			case 13: SetPlayerColor(playerid, 0x66006620);
			case 14: SetPlayerColor(playerid, 0xfc0fc020);
			}
			SendClientMessageEx(playerid, -1, "Вы успешно изменили свой цвет.");
		}
	case 636: {
			if(!response) return DeletePVar(playerid, "LicName");
			new text[32];
			switch(listitem) {
			case 0: text = "водительские права";
			case 1: text = "лицензию на судоходство";
			case 2: text = "лицензию на полеты";
			case 3: text = "лицензию на оружие";
			case 4: text = "лицензию на бизнес";
			}
			if(listitem == 5 && GetPlayerBizz(GetPVarInt(playerid, "LicName")) == 0) return SendClientMessage(playerid, COLOR_GREY, "Игрок не имеет бизнеса!");
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Вы выдали %s %s", text, NamePlayer(GetPVarInt(playerid, "LicName")));
			SendClientMessageEx(GetPVarInt(playerid, "LicName"), COLOR_LIGHTBLUE, "Администратор %s выдал вам %s",NamePlayer(playerid), text);
			if(listitem == 5) {
				new i = GetPVarInt(GetPVarInt(playerid, "LicName"), "PlayerBizz");
				BizzInfo[i][bLic] = 1;
				SetBizzInt(i, "lic", BizzInfo[i][bLic]);
			}
			else PI[GetPVarInt(playerid, "LicName")][pLic][listitem] = 1;
			DeletePVar(playerid, "LicName");
		}
	case 637: {
			if(!response) return DeletePVar(playerid, "LicName");
			new text[32];
			switch(listitem) {
			case 0: text = "водительские права";
			case 1: text = "лицензию на судоходство";
			case 2: text = "лицензию на полеты";
			case 3: text = "лицензию на оружие";
			case 4: text = "лицензию на бизнес";
			case 5: text = "патроны";
			case 6: text = "наркотики";
			}
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Вы забрали %s у %s", text, NamePlayer(GetPVarInt(playerid, "LicName")));
			SendClientMessageEx(GetPVarInt(playerid, "LicName"), COLOR_LIGHTBLUE, "Администратор %s забрал у вас %s",NamePlayer(playerid), text);
			if(listitem >= 0 && listitem < 5) {
				PI[GetPVarInt(playerid, "LicName")][pLic][listitem] = 0;
				if(IsPlayerInAnyVehicle(GetPVarInt(playerid, "LicName")) && listitem < 3) RemovePlayerFromVehicle(GetPVarInt(playerid, "LicName"));
			}
			else {
				if(listitem == 5) PI[GetPVarInt(playerid, "LicName")][pStuf][2] = 0;
				if(listitem == 6) PI[GetPVarInt(playerid, "LicName")][pStuf][0] = 0;
			}
		}
	case 10000: {
			if(!response) return 1;
			SetPVarInt(playerid, "ShowAll", listitem);
			query = "";
			format(query, sizeof(query), "SELECT * FROM `"TABLE_ACCOUNT"` WHERE `Member` = '%d' ORDER by Rank DESC LIMIT 40;", GetPVarInt(playerid,"ShowAll")+1);
			mysql_function_query(cHandle, query, true, "FracMember", "d", playerid);
			return 1;
		}
	case 10001: {
			if(PI[playerid][pHeal] < 80) {
				new fullk;
				if(GetPVarInt(playerid, "MedHealPlace") > 0) {
					fullk++;
					SendClientMessage(playerid, COLOR_GREY, "У Вас уже есть койка!");
				}
				else {
					for(new i = 0; i < 15; i++) {
						if(IsPlayerInRangeOfPoint(playerid, 1.3,InMedHeal[i][0], InMedHeal[i][1], InMedHeal[i][2]))
						{
							if(GetPVarInt(playerid, "SetHeal") == 1)
							{
								if(StatusMedHeal[i] == true) return SendClientMessage(playerid, COLOR_GREY, "Данное место занято!");
								StatusMedHeal[i] = true;
								SetPVarInt(playerid, "MedHealPlace", i+1);
								fullk++;
								strin = "";
								SendClientMessageEx(playerid, COLOR_YELLOW, "Вы заняли эту койку!");
								strin = "";
								format(strin, 64, "Койка: %s", NamePlayer(playerid));
								UpdateDynamic3DTextLabelText(MedHealText3D[i],0x7CB523FF,strin);
								SetPVarInt(playerid, "MedHealPlay", 1);
								SetPVarInt(playerid, "MedHealTime", 1);
								DeletePVar(playerid, "HealDeath");
								GiveMoney(playerid, -300);
							}
						}
					}
				}
				if(fullk == 0) SendClientMessage(playerid, COLOR_GREY, "Вы должны находится возле койки!");
			}
		}
		//
	case 10002: {
			if(!response) return 1;
			new i = GetPVarInt(playerid, "PlayerBizz");
			switch(listitem) {
			case 0: BizzStats(playerid, i);
			case 1: {
					GiveMoney(playerid,BizzInfo[i][bMoney]);
					BizzInfo[i][bMoney] = 0;
					SendClientMessage(playerid, COLOR_GREEN, "Вы сняли все деньги с бизнеса.");
				}
			case 2: SPD(playerid, 10003, 1, "Цена", "Введите цену за товар в процентах:", "Принять", "Отмена");
			case 3: SPD(playerid, 4013, 1, "Заказ продуктов", "Укажите кол-во продуктов:", "Заказать", "Отмена");
			case 4: SPD(playerid, 10004, 0, "Продать бизнес", "{ffffff}Вы хотите продать свой бизнес?\n\n{FF6347}При продаже Вам вернут только половину стоимости!", "Да", "Нет");

			}
		}
	case 10003: {
			if(!response) return 1;
			new price, i = GetPVarInt(playerid, "PlayerBizz");
			if(sscanf(inputtext, "i",price)) SPD(playerid, 10003, 1, "Цена", "Введите цену за товар в процентах:", "Принять", "Отмена");
			if(price < 1 || price > 100) return SPD(playerid, 10003, 1, "Цена", "Введите цену за товар в процентах:", "Принять", "Отмена");
			BizzInfo[i][bTill] = price;
			SetBizzInt(i, "till", price);
			SendClientMessageEx(playerid, COLOR_BLUE, "Вы установили цену за товар: %i%", price);
			UpdateBizz(i);
			return 1;
		}
	case 10004: {
			if(!response) return 1;
			new i = GetPVarInt(playerid, "PlayerBizz");
			strmid(BizzInfo[i][bOwner], "None", 0, strlen("None"), MAX_PLAYER_NAME);
			strmid(BizzInfo[i][bMafia], "None", 0, strlen("None"), MAX_PLAYER_NAME);
			BizzInfo[i][bLock] = 0;
			PI[playerid][pLic][4] = 0;
			SendClientMessage(playerid, COLOR_LIGHTRED, "Вы продали свой бизнес.");
			PlusBankMoney(playerid, BizzInfo[i][bMoney]), CheckBank(playerid);
			PlusBankMoney(playerid, BizzInfo[i][bBank]), CheckBank(playerid);
			BizzInfo[i][bBuyPrice] = 0;
			BizzInfo[i][bMoney] = 0;
			BizzInfo[i][bBank] = 0;
			BizzInfo[i][bLic] = 0;
			BizzInfo[i][bEnter] = 100;
			BizzInfo[i][bTill] = 50;
			BizzInfo[i][bProduct] = 10000000;
			query = "";
			format(query, 512, "UPDATE "TABLE_BIZZ" SET owner='%s', block=%d, money=%d, bank=%d, lic=%d, penter=%d, till=%d, buyprice=%d, Mafia = '%s', product = %d WHERE id = %d LIMIT 1",
			BizzInfo[i][bOwner], BizzInfo[i][bLock], BizzInfo[i][bMoney], BizzInfo[i][bBank], BizzInfo[i][bLic], BizzInfo[i][bEnter], BizzInfo[i][bTill], BizzInfo[i][bBuyPrice],BizzInfo[i][bMafia],BizzInfo[i][bProduct],i);
			mysql_function_query(cHandle, query, false, "", "");
			UpdateBizz(i);
		}
	}
	return 1;
}
public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z) {
	return true;
}
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ) {
	return true;
}
public OnVehicleDamageStatusUpdate(vehicleid, playerid) {
	new Float:vh; GetVehicleHealth(vehicleid, vh);
	if(1000 - vh >= 500) {
		SetVehicleParamsEx(vehicleid,VEHICLE_PARAMS_OFF,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective);
		Engine[vehicleid] = false;
		GameTextForPlayer(playerid, "~r~ENGINE OFF", 5000, 6);
	}
	return 1;
}
