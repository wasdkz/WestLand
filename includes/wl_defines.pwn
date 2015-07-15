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
#define mysql_host 		"" 		// localhost
#define mysql_db 		"" 		// westland
#define mysql_user 		"" 		// root
#define mysql_pass 		"" 		// pass

#define	PRICE_SHADOW        	0   // ÷ена на колеса SHADOW
#define	PRICE_MEGA        		0   // ÷ена на колеса MEGA
#define	PRICE_WIRES				0   // ÷ена на колеса WIRES
#define	PRICE_CLASSIC			0   // ÷ена на колеса CLASSIC
#define	PRICE_TWIST				0   // ÷ена на колеса TWIST
#define	PRICE_GROVE				0   // ÷ена на колеса GROVE
#define	PRICE_ATOMIC			0   // ÷ена на колеса ATOMIC
#define	PRICE_DOLLAR			0   // ÷ена на колеса DOLLAR
#define	PRICE_HYDRAULICS		0   // ÷ена на гидравлику
#define	PRICE_HBUMPER_XFLOW		0   // ÷ена на передний бампер X-FLOW
#define	PRICE_HBUMPER_ALIEN		0   // ÷ена на передний бампер ALIEN
#define	PRICE_BBUMPER_XFLOW		0   // ÷ена на задний бампер X-FLOW
#define	PRICE_BBUMPER_ALIEN		0   // ÷ена на задний бампер ALIEN
#define	PRICE_SPOILER_XFLOW		0   // ÷ена на спойлер X-FLOW
#define	PRICE_SPOILER_ALIEN		0   // ÷ена на спойлер ALIEN
#define	PRICE_NITRO_2X			0   // ÷ена на нитро 2х
#define	PRICE_NITRO_5X			0   // ÷ена на нитро 5х
#define	PRICE_NITRO_10X			0   // ÷ена на нитро 10х
#define	PRICE_NEONS_WHITE		0   // ÷ена на неон белого цвета
#define	PRICE_NEONS_RED			0   // ÷ена на неон красного цвета
#define	PRICE_NEONS_GREEN		0   // ÷ена на неон зеленого цвета
#define	PRICE_NEONS_BLUE        0   // ÷ена на неон синего цвета
#define	PRICE_NEONS_YELLOW		0   // ÷ена на неон желтого цвета

#define BONUS_CASH         	 	1000 	// ƒеньги
#define BONUS_LEVEL         	1   	// ”ровень
#define BONUS_DONATECASH    	0   	// ƒонат

#define TABLE_ACCOUNT 		"accounts"
#define TABLE_HOUSE 		"house"
#define TABLE_CARS          "cars"
#define TABLE_BIZZ          "bizz"
#define TABLE_LBIZZ       	"lbizz"
#define TABLE_PARK          "park"
#define TABLE_CARPARK       "park_cars"
#define TABLE_GANGZONE      "gangzone"
#define TABLE_ENTERS        "enters"
#define TABLE_WAREHOUSE     "warehouse"
#define TABLE_DONATE		"donate"

#define function:%1(%2) 		forward %1(%2); public %1(%2)
#define _invTM_percent(%0) \
	8.352898 + (((174.470458 + - 8.352898) / 100) * %0)

#define OWNER_SERVER1       "Mansur_Taukenov"
#define OWNER_SERVER2       "teddyt"

#define LOGO_REGISTER       "westland"
#define TM_DEBUG

#define RconPass 			"teddyt@wasd.ml"
#define ModeServer 			"WL:RP Mode | build.3.1"
#define NameServer 			"WestLand RP"
#define NameSite 			"westland-rp.com"
#define HostName            "WestLand Role Play | Server: TEST"

#define COLOR_GRAD1 		0xB4B5B7FF
#define COLOR_LIGHTGREEN 	0x9ACD32AA
#define COLOR_PAYCHEC       0xa4cd00AA
#define COLOR_ERROR         0xd60000FF
#define COLOR_GET	        0xdfff7eFF
#define COLOR_GRAD2 		0xBFC0C2FF
#define COLOR_LIGHTBLUE 	0x33CCFFAA
#define COLOR_YELLOW 		0xFFFF00AA
#define COLOR_YELLOW2 		0xF5DEB3AA
#define COLOR_KHAKI 		0xF0E68CAA
#define COLOR_LIGHTRED 		0xFF6347AA
#define COLOR_INDIGO 		0x4B00B0AA
#define COLOR_RED 			0xAA3333AA
#define COLOR_BLUE 			0x33AAFFFF
#define COLOR_BLUEX         0x4C506BFF
#define COLOR_WHITE 		0xFFFFFFAA
#define COLOR_GREY			0xAFAFAFAA
#define COLOR_BLACK 		0x000000AA
#define COLOR_BOX   		0x00000050
#define COLOR_ORANGE 		0xFF9900AA
#define COLOR_GREEN 		0x33AA33AA
#define COLOR_FADE1 		0xE6E6E6E6
#define COLOR_FADE2 		0xC8C8C8C8
#define COLOR_FADE3 		0xAAAAAAAA
#define COLOR_FADE4 		0x8C8C8C8C
#define COLOR_FADE5 		0x6E6E6E6E
#define COLOR_PURPLE 		0xC2A2DAAA
#define COLOR_REDD 			0xFF0000AA
#define COLOR_ALLDEPT 		0xFF8282AA
#define COLOR_SMS 			0xFFFF00AA
#define F_AZTECAS_COLOR 	0x01FCFFC8
#define F_BLUE_COLOR 		0x8D8DFF00
#define F_TIMESS_COLOR 		0x1490a3C8

#define F_GOV				1
#define F_SAPD				2
#define F_SAN           	3
#define F_VMF            	4
#define F_HLS            	5
#define F_GROVE          	6
#define F_BALLAS         	7
#define F_AZTEC          	8
#define F_VAGOS          	9
#define F_RIFA           	10
#define F_FBI            	11
#define F_LIC            	12
#define F_ARMY           	13
#define F_SFPD           	14
#define F_LVPD           	15
#define F_HSF            	16
#define F_HLV            	17
#define F_MAFIA            	18

#define TAZE_TIMER 			8000
#define TAZE_SPARK 			18717
#define TAZE_DESTROY 		1250
#define TAZE_LOSEHP 		1

#define T_MUTED		 		"” вас бан чата!"
#define T_CMD		 		"¬ам не доступна данна¤ команда!"
#define T_FLOOD		 		"ѕисать сообщение можно раз в 2 секунды!"
#define T_OFFLINE	 		"»грок с этим ID оффлайн!"
#define T_NOLOGGED	 		"»грок с этим ID не авторизирован"

#define D_ADMIN_PRISON_TIME             14999
#define D_ADMIN_KICK_REASON     		15000
#define D_ADMIN_WARN_REASON     		15001
#define D_ADMIN_MUTE_TIME_REASON    	15002

#define G_STATE_NOT_GAMBLING    		0
#define G_STATE_READY           		1
#define G_STATE_GAMBLING        		2
#define G_STATE_DISPLAY         		3
#define G_STATE_PLAY_AGAIN      		4

#define MAX_PIRS 						4
#define JOB_NOPE    					0
#define JOB_KRUB 						1
#define JOB_MIDIA   					2

#define CPID_NOPE 						0
#define CPID_JOBKRUB_TAKECAGE 			1
#define CPID_JOBKRUB_PUTCAGE    		2
#define CPID_JOBKRUB_TAKECAGE2  		3
#define CPID_JOBKRUB_PUTCAGE2   		4

#define RCPID_NOPE                      0
#define RCPID_JOBKRUB_START_MARSHRUT    1
#define RCPID_JOBKRUB_MARSHRUT_PUT    	2
#define RCPID_JOBKRUB_MARSHRUT_TAKE     3
#define RCPID_JOBKRUB_RETURN_PIRS       4
#define RCPID_JOBMIDIA_MARK    			5

#define PRICE_KRUB  					6

#define D_GPS               8006
#define D_HEAL 				106
#define D_NMENU     		9000
#define D_SPAWN        		540
#define D_GRAIN             430
#define D_RECEPT       		555
#define D_CLOTHJOB          640
#define PHONE_PRICE         10
#define PHONE_SMS_PRICE     2
#define CHANGE_NICK_1       2250
#define CHANGE_NICK_2       2251
#define DIALOG_GARAGE       490
#define DIALOG_HOUSE        500
#define DIALOG_HOTEL        550
#define DIALOG_JOB 			131
#define DIALOG_FRACTION     1000
#define DIALOG_NEWS         3000
#define DID_CHANGEJOB   	1581
#define THFREE_SECOND_FLOOD 3

#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define HOLDING(%0) \
	((Keys & (%0)) == (%0))
#define HOLDINGNEWKEY(%0) \
	((newkeys & (%0)) == (%0))
#define send(%0,%1) SendClientMessage(%0, -1, %1)
#define BYTES_PER_CELL (cellbits / 8)

#define MAX_OBJECT     1000
#define MAX_ITEMS      20
#define ALL_ITEMS_SIZE 40

#define SDK_BASKETBALL_MDL 	2114
#define SDK_BASKET_MDL 		2114
#define SDK_BASKETBALL_SLOT 9
#define SDK_TACKLE_COOLDOWN 2

#define PlayAgainTimer(%0) 		ExitPlayerFromSlotMachine(%0)
#define NamePlayer(%0) 			PI[%0][pName_str]
#define PreloadAnimLib(%0,%1) 	ApplyAnimation(%0,%1,"null",0.0,0,0,0,0,0)
