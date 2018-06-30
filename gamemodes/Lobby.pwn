/*
		 __________   ___   ______  __       _______. __    ______   .__   __.
		|   ____\  \ /  /  /      ||  |     /       ||  |  /  __  \  |  \ |  |
		|  |__   \  V  /  |  ,----'|  |    |   (----`|  | |  |  |  | |   \|  |
		|   __|   >   <   |  |     |  |     \   \    |  | |  |  |  | |  . `  |
		|  |____ /  .  \  |  `----.|  | .----)   |   |  | |  `--'  | |  |\   |
		|_______/__/ \__\  \______||__| |_______/    |__|  \______/  |__| \__|
*/
#include		 														<a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 50

#include	 														   <a_mysql>
#include 															   <sscanf2>
#include 															  <streamer>
#include 																 <izcmd>
#include 															   <foreach>
#include 														 <weapon-config>
#include 															 <callbacks>
#include 															   <foreach>
#include 															   <antiFly>
#define function%0(%1) forward%0(%1); public%0(%1)

#define SQL_HOST 													 			"127.0.0.1"
#define SQL_USER  																"root"
#define SQL_PASS 																""
#define SQL_DB  											 					"lobby"

new
	Text:ServerName,
	Text:MapName,
	Text:TimeText,
	Text:StatsText[MAX_PLAYERS],
	Text:PingText[MAX_PLAYERS];

new maptimer;
// - Sunucu Bilgileri
#define HOSTNAME				"hostname .:: Lobby DM ::."
#define MODENAME                "LOBBY"
#define VERSION                 "v1.0.0"
#define LANGUAGE				"language English"
#define WEBSITE                 "weburl soon"
#define MAPNAME                 "mapname Bayside"
#define RCONPASS				"rcon_password excisionbabaxd09"

enum _:Dialogs
{
    DIALOG_LOGIN,
    DIALOG_REGISTER,
    DIALOG_STATS,
    DIALOG_WEAPON,
	DIALOG_WEAPON1,
	DIALOG_WEAPON2,
	DIALOG_WEAPON3,
	DIALOG_WEAPON4,
	DIALOG_ADMINS
};
enum pVar
{
	pUsername[24],
	pPassword[64],
	pIP[16],
	pMoney,
	pAdminLevel,
	pKills,
	pDeaths,
	pLogged,
	pScore,
	pWeapon,
	pWeapon2,
	pWeapon3,
	pWeapon4,
	bool:pMuted,
	pSpree
};
new PlayerInfo[MAX_PLAYERS][pVar];
enum sVar
{
	sArea
};
new sInfo[sVar];

new dbHandle;
new Invalid[MAX_PLAYERS];
new Area_timer;
new spawn_timer[MAX_PLAYERS];
new Float:bayside[24][4] =
{
	{-2468.0215,2237.4319,4.7984},{-2485.0359,2254.2471,4.9844},{-2475.3516,2272.6443,4.9844},{-2457.2693,2298.8416,4.9844},
	{-2476.6292,2317.3481,4.9844},{-2503.9075,2324.9614,4.9844},{-2507.1882,2350.9883,4.9861},{-2550.2883,2356.5413,4.9844},
	{-2562.0491,2359.0034,7.8263},{-2584.3374,2397.5234,12.9474},{-2612.7695,2384.6772,10.0333},{-2615.4385,2347.1699,8.3455},
	{-2615.6824,2293.8625,8.1948},{-2588.0874,2268.9619,7.4062},{-2554.4294,2290.6252,4.8359},{-2512.8477,2274.6204,4.9844},
	{-2457.1650,2335.6602,4.8359},{-2470.6943,2364.3293,8.3181},{-2505.1169,2392.3538,16.1834},{-2513.3008,2415.4797,16.5899},
	{-2531.4885,2409.1919,15.7561},{-2555.2495,2401.1543,14.7188},{-2547.6160,2432.5596,19.0258},{-2525.4048,2448.0127,17.7409}
};
new Float:sfbeach[38][4] =
{
	{-2827.1113,133.7648,10.1454},{-2802.5173,150.3827,7.1797},{-2800.8657,119.0904,7.1797},{-2799.2205,91.8452,7.1797},
	{-2808.6494,65.7056,7.0390},{-2787.6018,56.4122,7.1875},{-2781.1123,40.3444,7.0391},{-2764.5078,32.3351,7.0954},
	{-2755.0298,47.6061,7.1875},{-2738.4634,40.0578,7.0391},{-2708.1689,42.5563,4.2969},{-2694.5247,80.9633,4.1797},
	{-2695.5220,85.9400,4.1797},{-2710.1006,92.2549,4.1924},{-2696.8843,111.5605,4.3359},{-2686.9314,115.5568,7.1953},
	{-2698.5088,132.8573,4.3359},{-2718.0486,128.8348,6.0606},{-2705.2048,133.4235,4.1797},{-2714.2708,147.2233,4.3359},
	{-2720.2808,163.2620,4.9006},{-2733.4858,156.0247,6.4715},{-2747.3416,148.2155,7.1522},{-2756.5076,163.6874,7.1261},
	{-2759.1709,129.2319,7.0028},{-2761.2437,95.2280,7.2041},{-2747.9644,85.1727,6.0373},{-2762.5933,63.1642,6.9295},
	{-2796.0479,33.5549,7.1875},{-2841.2988,39.1871,10.2603},{-2847.9170,72.0562,11.2068},{-2851.2410,98.5900,11.9246},
	{-2867.0737,107.0109,8.2280},{-2876.2185,79.9160,5.3630},{-2887.4248,56.7427,4.8063},{-2892.8118,79.9157,4.7256},
	{-2888.9111,97.3138,4.5034},{-2835.8184,132.0043,12.9365}
};
new Float:fcarson[34][4] =
{
	{-139.1775,1215.4841,19.7422,141.7078},{-153.8760,1218.3271,19.7422,65.5671},{-171.4962,1222.3999,19.7422,83.7406},{-181.2467,1205.6768,19.7252,139.5145},
	{-179.0073,1192.3746,19.7422,180.2482},{-150.7592,1183.7032,19.7422,234.1420},{-117.2028,1189.5302,19.5867,266.1022},{-108.4096,1154.8414,19.6735,208.7616},
	{-111.1175,1142.3491,19.7422,167.4012},{-120.9180,1139.3656,20.6196,107.2406},{-138.8787,1133.5759,19.7500,171.4746},{-153.5029,1141.0680,20.4031,61.4935},
	{-158.9153,1160.6289,19.7422,6.3463},{-145.2504,1161.2357,19.7500,272.0322},{-175.7993,1156.1487,19.7500,97.8172},{-181.9973,1138.0840,19.7422,160.7978},
	{-183.1206,1168.9296,19.7422,345.9561},{-200.8287,1179.7640,19.7422,63.0368},{-208.9972,1205.2040,19.7422,22.3032},{-234.3392,1163.7423,19.7422,154.2177},
	{-236.1476,1130.8083,19.7344,173.0179},{-247.7604,1107.7946,19.7422,124.4508},{-268.8921,1085.3771,19.7422,145.7576},{-282.4875,1114.8331,19.7422,24.1832},
	{-261.9451,1068.9342,20.2494,189.6014},{-239.5581,1062.7266,19.7344,180.0000},{-201.8589,1037.6169,19.7422,257.2823},{-166.2479,1048.0520,19.6615,283.9158},
	{-157.5035,1061.9319,19.8184,344.7030},{-151.0909,1070.1516,19.7500,295.5092},{-115.4670,1083.8669,19.7218,197.7482},{-98.3081,1086.8555,19.7422,260.4155},
	{-64.1761,1086.5482,19.5854,256.6555},{-34.3524,1110.5773,20.1860,317.1294}
};
new Float:psquare[35][4] =
{
	{1596.8507,-1722.8380,13.5469},{1579.9988,-1738.7202,13.5362},{1562.5863,-1748.4680,13.5469},{1546.5222,-1741.7242,13.5469},
	{1538.8545,-1751.7744,14.0469},{1540.6281,-1721.4960,13.5546},{1522.0986,-1713.3840,13.5469},{1521.4884,-1694.0144,13.5469},
	{1537.5625,-1693.1890,13.5469},{1545.8583,-1676.6266,13.5612},{1541.9974,-1660.6011,13.5536},{1519.7565,-1659.6326,13.5392},
	{1539.8406,-1628.5510,13.3828},{1565.1134,-1622.2438,13.5469},{1530.7954,-1606.4110,14.1295},{1507.8767,-1599.4089,13.5815},
	{1505.3864,-1610.7913,14.0469},{1488.3834,-1613.8599,14.0393},{1477.0513,-1634.9103,14.1484},{1462.3180,-1634.6604,14.0469},
	{1437.2944,-1618.6605,13.5469},{1426.6414,-1644.0607,13.3594},{1441.7551,-1653.5764,13.7969},{1441.4268,-1672.5590,13.5469},
	{1423.6233,-1682.8241,13.5469},{1418.0233,-1703.9054,13.5469},{1437.7156,-1721.5713,13.5469},{1432.3802,-1738.5764,13.5469},
	{1463.1833,-1742.3220,13.5469},{1481.4375,-1732.1178,13.3828},{1481.2562,-1716.1274,14.0469},{1475.6593,-1696.3121,14.0469},
	{1488.7361,-1679.1930,14.0469},{1484.9581,-1668.1946,14.5532},{1497.2861,-1657.9199,14.0469}
};
new Float:temple[36][4] =
{
	{1209.1860,-946.5930,42.7253,273.6089},{1219.0128,-953.6887,42.8422,230.2465},{1216.7285,-927.8604,42.8821,9.0544},{1212.1711,-922.4661,42.9294,42.8947},
	{1210.8511,-902.7797,42.9262,4.3543},{1188.8629,-921.6407,43.1386,103.0318},{1173.4011,-906.4033,43.3339,43.1846},{1160.7131,-913.9047,42.6719,125.5921},
	{1140.0933,-927.9590,43.1797,122.4587},{1121.3844,-943.8162,42.6950,108.9853},{1110.1786,-973.1039,42.7656,171.9659},{1142.5044,-974.7628,42.7656,267.5336},
	{1146.3579,-1000.5288,36.7207,185.7528},{1161.2222,-984.1971,39.4015,344.3011},{1185.4181,-991.8577,43.4843,263.1472},{1122.9681,-1004.1006,29.8632,89.8722},
	{1097.6840,-1006.9481,34.5468,87.9921},{1071.7909,-992.9601,38.8383,69.8186},{1081.5629,-975.5244,41.3031,339.6012},{1082.7950,-1054.2004,31.0584,180.4264},
	{1070.0968,-1069.9083,29.0174,168.2063},{1104.3099,-1079.2284,29.3323,264.0875},{1121.5052,-1083.6727,26.4084,251.2641},{1129.9788,-1042.4882,31.6995,322.3914},
	{1142.9447,-1031.8563,31.9876,294.8178},{1173.0790,-1047.7653,31.7878,254.3975},{1195.3423,-1031.0123,31.9297,286.9844},{1217.5659,-1062.5029,29.4544,204.5766},
	{1215.2301,-1065.1698,30.4375,112.8146},{1203.4875,-1079.2415,29.1240,142.2227},{1244.8640,-1048.5183,31.8939,285.7308},{1262.7087,-1015.5209,33.3528,345.5780},
	{1271.4772,-995.1876,35.5784,323.0179},{1285.5336,-963.2109,34.5859,280.0909},{1289.2921,-982.1328,32.6953,239.3571},{1272.9884,-941.0987,42.3422,50.1253}
};
new Float:enorth[34][4] =
{
	{-1667.0264,1310.1635,7.1875,191.9115},{-1678.5259,1320.0492,7.1875,25.2166},{-1664.0835,1339.3635,7.1855,314.7159},{-1671.0406,1367.5499,7.1722,332.5761},
	{-1645.4203,1367.0571,7.1797,228.8617},{-1616.0942,1389.9009,7.1741,319.9755},{-1619.9160,1405.3523,7.1809,3.8866},{-1639.0302,1411.0756,7.1875,58.4071},
	{-1645.8350,1405.0081,9.8047,125.7744},{-1668.7094,1398.0873,11.3906,90.0000},{-1681.4673,1400.3319,12.2031,82.4136},{-1659.9058,1383.9050,9.8047,223.7620},
	{-1669.1945,1363.8678,9.8047,130.4745},{-1690.1013,1359.6693,9.7971,45.0594},{-1691.4535,1355.9893,7.1797,169.2772},{-1721.1653,1327.6372,7.0391,121.7012},
	{-1740.8599,1291.9722,6.9178,137.6813},{-1741.5392,1271.1891,7.0814,180.6084},{-1738.0513,1243.2505,7.5469,185.3084},{-1729.5306,1245.5106,7.5469,287.1427},
	{-1723.7137,1241.7795,17.9201,225.7287},{-1724.9263,1265.3325,17.9272,6.7301},{-1709.0659,1260.3344,17.9219,252.6756},{-1707.9510,1244.5370,17.9203,181.2349},
	{-1696.3998,1238.5999,20.6923,269.7887},{-1681.6467,1232.6141,20.7016,248.6023},{-1648.0487,1231.2203,7.0391,267.7158},{-1657.5555,1213.3115,7.2500,137.1107},
	{-1666.8551,1206.5538,13.6719,185.3412},{-1659.2870,1217.7537,13.6719,328.2225},{-1641.0428,1237.7196,7.1875,320.1320},{-1625.3763,1251.8796,7.1779,310.1052},
	{-1635.4999,1267.2788,7.1814,34.0793},{-1617.8167,1278.6882,7.0469,292.2450}
};
new Float:fintersection[33][4] =
{
	{-193.2766,-1438.5994,4.8479,226.7582},{-164.6540,-1440.0411,4.6740,271.5745}, {-153.9982,-1422.8977,3.0391,331.4218},{-129.5283,-1426.9924,3.7081,250.5810},
	{-105.1287,-1406.6932,6.6307,297.2679},{-85.2188,-1436.7418,6.4607,205.7738}, {-80.7755,-1467.1910,6.2696,194.4936},{-88.6013,-1490.1915,2.5801,149.6865},
	{-91.8154,-1519.3381,2.9395,176.9468},{-115.7950,-1536.2228,2.7379,119.6063}, {-141.0677,-1550.3240,4.2412,123.8725},{-127.1159,-1577.1346,7.0059,207.0271},
	{-110.3815,-1571.4741,2.6172,291.0012},{-89.8260,-1585.2454,2.6172,208.9069}, {-63.3648,-1563.1489,2.6172,311.0546},{-56.2579,-1536.0868,2.3616,13.7219},
	{-22.5712,-1522.7439,1.8203,281.9146},{-22.1054,-1500.8571,2.3004,358.0552}, {5.4259,-1466.8180,4.6178,330.7950},{-4.1911,-1425.2972,9.2527,28.1355},
	{-34.8234,-1406.7279,11.5224,61.3491},{-36.6760,-1391.0349,11.2783,325.4682}, {-54.1573,-1386.6997,11.8554,103.3361},{-70.8423,-1379.9421,11.7691,67.9291},
	{-106.4056,-1416.5011,12.5298,135.9231},{-113.9818,-1443.3822,12.8047,148.7699}, {-131.1322,-1474.9382,12.8047,141.2498},{-167.0684,-1479.5399,12.8211,100.8294},
	{-179.8524,-1467.2821,8.1724,47.2489},{-81.8190,-1298.7784,5.6743,260.6073}, {-61.9966,-1312.6229,7.8631,223.6569},{-56.9057,-1341.8336,10.7082,184.4899},
	{-55.2765,-1365.2666,11.4455,162.8697}
};
new Float:elquebrados[50][4] =
{
	{-1546.8826,2600.7251,55.6875,88.9573},{-1535.3271,2598.7444,55.6888,271.4890},{-1538.5468,2610.5127,55.8359,16.4567},{-1552.8682,2627.8936,55.8359,33.6902},
	{-1532.5859,2629.3809,55.8359,266.4755},{-1525.0286,2642.0735,55.8359,331.6495},{-1544.3547,2654.6653,55.6875,46.5369},{-1563.9609,2647.4653,55.8359,132.0777},
	{-1578.6793,2662.8958,55.8468,29.3034},{-1592.0409,2685.3291,55.3430,24.6034},{-1595.1698,2696.7361,55.0749,12.3833},{-1581.2349,2708.9751,55.7378,168.0880},
	{-1569.5688,2699.9912,55.8359,224.1752},{-1544.6544,2707.2300,55.8403,263.6555},{-1528.1859,2695.9468,55.8359,249.8687},{-1540.2407,2683.1140,55.8359,143.0210},
	{-1502.1917,2694.0408,55.8359,293.7358},{-1504.7490,2658.8689,55.8359,157.1212},{-1490.4036,2650.5010,55.8359,234.5152},{-1473.7260,2653.4670,55.8359,276.8157},
	{-1483.1969,2637.9238,58.7813,184.3815},{-1478.3207,2615.1011,58.7879,193.7815},{-1471.5847,2613.8113,58.7879,262.0889},{-1464.3140,2629.9814,58.7734,264.9089},
	{-1459.8176,2618.4243,58.7734,183.7549},{-1448.8698,2617.2908,61.0269,272.7423},{-1465.5635,2620.9912,62.0625,97.6107},{-1482.4075,2618.6062,62.3357,83.8240},
	{-1482.4064,2599.9165,55.6875,182.2841},{-1463.9857,2588.4446,55.8359,201.0117},{-1475.6803,2571.6592,55.8359,125.8111},{-1448.5939,2574.5735,55.8359,294.0727},
	{-1431.0421,2571.7632,55.8359,274.9592},{-1443.3533,2551.1213,55.8359,123.9545},{-1466.7520,2549.2070,55.8359,89.8008},{-1497.1040,2536.3916,55.6875,112.0477},
	{-1506.9033,2522.4158,55.6875,133.9812},{-1526.0604,2524.0713,55.7805,90.1141},{-1513.6055,2550.0461,55.6875,318.8263},{-1532.4633,2555.0105,55.6875,78.2074},
	{-1522.4945,2571.0505,55.8359,281.5393},{-1506.1741,2577.7188,55.8359,280.5992},{-1493.0643,2576.9260,55.6882,261.1724},{-1437.1060,2677.6128,55.8359,249.5790},
	{-1496.3018,2599.9167,55.6900,54.3938},{-1516.9894,2600.3450,55.6900,91.3675},{-1514.6716,2620.3916,55.8359,10.5267},{-1504.6250,2639.3267,55.8359,315.6929},
	{-1462.0348,2663.2993,55.8359,273.7060},{-1449.5140,2678.6682,55.8359,321.9597}
};
#define MAX_DROPS 				(1000)

#define PICKUP_MODEL_WEAPONS 	331,333..341,321..326,342..355,372,356..371
#define PICKUP_MODEL_HEALTH  (1240)

enum e_STATIC_PICKUP
{
	pickupModel,
	pickupAmount,
	pickupPickupid,
	pickupTimer
};
new g_StaticPickup[MAX_DROPS][e_STATIC_PICKUP];


stock GetPlayerNameEx(playerid)
{
    new gName[MAX_PLAYER_NAME];
	GetPlayerName( playerid, gName, sizeof gName );
	return gName;
}

stock MySQL_Register(playerid, passwordstring[])
{
    new Query[512], IP[16];
    GetPlayerIp(playerid, IP, sizeof(IP));

	strcat(Query,"INSERT INTO `PlayerData`(`Username`,`Password`,`pMoney`,`pAdminLevel`,`pKills`,`pDeaths`,`pIP`,`pScore`)");
	strcat(Query," VALUES ('%s', SHA1('%s'),0,0,0,0,'%s',0)");
	mysql_format(dbHandle,Query,sizeof(Query),Query,GetPlayerNameEx(playerid),passwordstring,IP);
	mysql_query(dbHandle,Query,false);
	SendClientMessage(playerid, 0xCCCC99FF, "[Server] {FFFFFF}Succcessfully registered. Welcome!");
	
    PlayerInfo[playerid][pLogged] = 1;
	return 1;
}

stock MySQL_Login(playerid)
{
	if(IsPlayerConnected(playerid))
	{
	    new Query[512], savestr[50], rows, fields;
		mysql_format(dbHandle,Query, sizeof(Query), "SELECT * FROM `PlayerData` WHERE `Username` = '%s'", GetPlayerNameEx(playerid));
		mysql_query(dbHandle,Query);
	    cache_get_data(rows, fields,dbHandle);
	    if(rows)
	    {
	        cache_get_field_content(0, "pMoney", savestr);   		PlayerInfo[playerid][pMoney] = strval(savestr);
	        cache_get_field_content(0, "pAdminLevel", savestr);  	PlayerInfo[playerid][pAdminLevel] = strval(savestr);
			cache_get_field_content(0, "pKills", savestr);   		PlayerInfo[playerid][pKills] = strval(savestr);
			cache_get_field_content(0, "pDeaths", savestr);  		PlayerInfo[playerid][pDeaths] = strval(savestr);
			cache_get_field_content(0, "pScore", savestr); 			PlayerInfo[playerid][pScore] = strval(savestr);
			ResetPlayerMoney(playerid);
			GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
			SetPlayerScore(playerid, PlayerInfo[playerid][pScore]);
		    PlayerInfo[playerid][pLogged] = 1;
	  	}
		PlayerInfo[playerid][pLogged] = 1;
	}
	return 1;
}
stock SaveStats(playerid)
{
	if(PlayerInfo[playerid][pLogged] == 1)
	{
		new Query[512], ip[16];
		GetPlayerIp(playerid, ip, 16);
		mysql_format(dbHandle,Query, sizeof(Query), "UPDATE `PlayerData` SET `pMoney` = '%d', `pAdminLevel` = '%d' WHERE `Username` = '%s'",
		GetPlayerMoney(playerid),
		PlayerInfo[playerid][pAdminLevel],
		GetPlayerNameEx(playerid));
		mysql_query(dbHandle,Query,false);
		mysql_format(dbHandle,Query, sizeof(Query), "UPDATE `PlayerData` SET `pKills` = '%d', `pDeaths` = '%d', `pScore` = '%d', `pIP` = '%d' WHERE `Username` = '%s'",
		PlayerInfo[playerid][pKills],
		PlayerInfo[playerid][pDeaths],
		GetPlayerScore(playerid),
		ip,
		GetPlayerNameEx(playerid));
		mysql_query(dbHandle,Query,false);
	}
	return 1;
}
stock ResetVars(playerid)
{
	ResetPlayerMoney(playerid);
	SetPlayerScore(playerid, 0);
    PlayerInfo[playerid][pMoney] = 0;
    PlayerInfo[playerid][pAdminLevel] = 0;
    PlayerInfo[playerid][pKills] = 0;
    PlayerInfo[playerid][pDeaths] = 0;
    PlayerInfo[playerid][pScore] = 0;
    PlayerInfo[playerid][pLogged] = 0;
	PlayerInfo[playerid][pMuted] = false;
	PlayerInfo[playerid][pSpree] = 0;
    PlayerInfo[playerid][pWeapon] = -1;
    PlayerInfo[playerid][pWeapon2] = -1;
    PlayerInfo[playerid][pWeapon3] = -1;
    PlayerInfo[playerid][pWeapon4] = -1;
	return 1;
}
main()
{
	new Yil,Ay,Gun,Saat,Dakika,Saniye;
	getdate(Yil, Ay, Gun);
	gettime(Saat,Dakika,Saniye);

	printf("» ===============[E][X][C][I][S][I][O][N]=============== «");
	printf("»                                                        «");
	printf("»                        Lobby DM                        «");
	printf("»                       By Excision                      «");
	printf("»                                                        «");
	printf("» ===============[E][X][C][I][S][I][O][N]=============== «");
	printf("» =========== Date: %d/%d/%d  Time: %d:%d:%d =========== «",Gun, Ay, Yil, Saat, Dakika, Saniye);
}
public OnGameModeInit()
{
    SetTimer("TabloYenile", 1000, true);
    UsePlayerPedAnims();
    EnableStuntBonusForAll(0);
	SendRconCommand(HOSTNAME);
	SendRconCommand(LANGUAGE);
	SendRconCommand(WEBSITE);
	SendRconCommand(MAPNAME);
	SendRconCommand(RCONPASS);
	SetGameModeText(MODENAME);
	
    mysql_log(LOG_ERROR | LOG_WARNING);
    dbHandle = mysql_connect(SQL_HOST, SQL_USER, SQL_DB, SQL_PASS);
	if(!mysql_errno(dbHandle))
	{
	    print("[SERVER SUCCESS]: Connection to database succcessfully establishied.");
	}else
	{
		print("[CRITICAL SERVER ERROR]: Connection to database could not pass. Gamemode wont work.");
		SendRconCommand("exit");
	}
	for(new i = false; i <= 311; i++)
	{
		AddPlayerClass(i, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	}
	sInfo[sArea] = 1;
	KillTimer(Area_timer);
	Area_timer = SetTimer("ChangeArea",1000*60*15,true);
	maptimer = 900;
    SetTimer("ServerTimer", 1000, true);
	ServerName = TextDrawCreate(638.000000, 429.000000, "~g~~h~~h~Lobby ~w~~h~~h~DM");
	TextDrawAlignment(ServerName, 3);
	TextDrawBackgroundColor(ServerName, 17);
	TextDrawFont(ServerName, 2);
	TextDrawLetterSize(ServerName, 0.500000, 2.000000);
	TextDrawColor(ServerName, -1);
	TextDrawSetOutline(ServerName, 1);
	TextDrawSetProportional(ServerName, 1);
	TextDrawSetSelectable(ServerName, 0);
	
	MapName = TextDrawCreate(89.000000, 297.000000, "~r~~h~~h~Map~n~ ~w~~h~~h~San Fierro Beach");
	TextDrawAlignment(MapName, 2);
	TextDrawBackgroundColor(MapName, 17);
	TextDrawFont(MapName, 3);
	TextDrawLetterSize(MapName, 0.250000, 1.000000);
	TextDrawColor(MapName, -1);
	TextDrawSetOutline(MapName, 1);
	TextDrawSetProportional(MapName, 1);
	TextDrawSetSelectable(MapName, 0);

	TimeText = TextDrawCreate(89.000000, 316.000000, "~b~~h~~h~Time~n~~w~~h~~h~15:00");
	TextDrawAlignment(TimeText, 2);
	TextDrawBackgroundColor(TimeText, 17);
	TextDrawFont(TimeText, 3);
	TextDrawLetterSize(TimeText, 0.250000, 1.000000);
	TextDrawColor(TimeText, -1);
	TextDrawSetOutline(TimeText, 1);
	TextDrawSetProportional(TimeText, 1);
	TextDrawSetSelectable(TimeText, 0);
	for(new playerid; playerid <= GetMaxPlayers(); playerid++)
	{
		StatsText[playerid] = TextDrawCreate(89.000000, 429.000000, "~y~~h~Kill: ~w~~h~10 ~g~~h~Death: ~w~~h~5 ~p~~h~Ratio: ~w~~h~2");
		TextDrawAlignment(StatsText[playerid], 2);
		TextDrawBackgroundColor(StatsText[playerid], 68);
		TextDrawFont(StatsText[playerid], 2);
		TextDrawLetterSize(StatsText[playerid], 0.180000, 1.500000);
		TextDrawColor(StatsText[playerid], -1);
		TextDrawSetOutline(StatsText[playerid], 1);
		TextDrawSetProportional(StatsText[playerid], 1);
		TextDrawSetSelectable(StatsText[playerid], 0);

		PingText[playerid] = TextDrawCreate(499.000000, 100.000000, "~g~~h~~h~Ping: ~w~~h~~h~100 ~r~~h~~h~FPS: ~w~~h~~h~100 ~b~~h~~h~PL: ~w~~h~~h~0.0");
		TextDrawBackgroundColor(PingText[playerid], 17);
		TextDrawFont(PingText[playerid], 2);
		TextDrawLetterSize(PingText[playerid], 0.200000, 1.000000);
		TextDrawColor(PingText[playerid], -1);
		TextDrawSetOutline(PingText[playerid], 1);
		TextDrawSetProportional(PingText[playerid], 1);
		TextDrawSetSelectable(PingText[playerid], 0);
	}
	return 1;
}
public OnGameModeExit()
{
	for (new i; i < MAX_DROPS; i++)
	{
	    if (IsValidStaticPickup(i))
		{
	    	DestroyStaticPickup(i);
	    }
    }
    mysql_close(dbHandle);
	return 1;
}
function ServerTimer()
{
	maptimer--;
	new str[50];
	format(str,128,"~b~~h~~h~Time~n~~w~~h~~h~%s",TimeConvert(maptimer));
	TextDrawSetString(TimeText, str);
	
	foreach(new i: Player)
	{
	    if(GetPlayerPing(i) > 400)
	    {
	        KickReason(i, "Max Ping","System");
	        return 1;
		}
		if(GetPlayerHealth(i) > 101)
		{
			KickReason(i, "Health Hack", "System");
		}
		if(GetPlayerArmour(i) > 101)
		{
			KickReason(i, "Armour Hack", "System");
		}
	}
	return 1;
}
TimeConvert(seconds, tarz=1)
{
	new tmp[16];
 	new minutes = floatround(seconds/60);
	seconds -= minutes*60;
  	if(tarz == 1)
  	{
   		format(tmp, sizeof(tmp), "%d:%02d", minutes, seconds);
	}
   	return tmp;
}
public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerSkin(playerid, classid);
	SetPlayerPos(playerid, 376.681793,-2028.681396,7.830100);
	SetPlayerFacingAngle(playerid, 90.0000);
	SetPlayerCameraPos(playerid, 365.210510,-2039.654053,17.300800);
	SetPlayerCameraLookAt(playerid, 376.681793,-2028.681396,7.830100);
	return 1;
}
public OnPlayerRequestSpawn(playerid)
{
	if(PlayerInfo[playerid][pLogged] == 0) return 0;
	if(PlayerInfo[playerid][pAdminLevel] >= 1)
	{
	    SetPlayerColor(playerid, 0xFF0000FF);
	}else
	{
	    SetPlayerColor(playerid, 0x99FFCCFF);
	}
    ShowPlayerDialog(playerid, DIALOG_WEAPON,DIALOG_STYLE_LIST,"{93FF93}Lobby DM - {FFFFFF}Weapon 1", "{FFFFFF}» Silenced\n» Deagle\n» Shotgun\n» Sawn off\n» Spas\n» M4\n» MP5\n» Rifle\n» Sniper","Okay","");
    TextDrawShowForPlayer(playerid, ServerName);
    TextDrawShowForPlayer(playerid, MapName);
    TextDrawShowForPlayer(playerid, TimeText);
    TextDrawShowForPlayer(playerid, StatsText[playerid]);
    TextDrawShowForPlayer(playerid, PingText[playerid]);
	return 1;
}
public OnPlayerConnect(playerid)
{
    new string[40 + MAX_PLAYER_NAME];
    format(string, sizeof(string), "[JOIN] {FFFFFF}%s has joined the server..", GetPlayerNameEx(playerid));
    SendClientMessageToAll(0xCCCC99FF, string);
    
    ResetVars(playerid);
	new Query[300], rows, fields, ip[16], kayit[16];
	GetPlayerIp(playerid, ip, 16);
	mysql_format(dbHandle, Query, sizeof(Query), "SELECT * FROM `PlayerData` WHERE `Username` = '%e'", GetPlayerNameEx(playerid));
	mysql_query(dbHandle, Query);
	cache_get_data(rows, fields);
	if(rows)
	{
	    cache_get_field_content(0, "pIP", kayit);
	    if(!strcmp(kayit, ip, true))
	    {
	        MySQL_Login(playerid);
        	SendClientMessageToAll(0xCCCC99FF, "[SERVER] {FFFFFF}Automatic login succesfully.");
	    }else
    	{
 			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,"{93FF93}Lobby DM - {FFFFFF}Login","{FFFFFF}Please login to contiune.","Login","Quit");
		}
	}else
	if(!rows)
	{
 		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,"{93FF93}Lobby DM - {FFFFFF}Register","{FFFFFF}Enter new password and click register to continue.","Register","Quit");
 	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new string[60 + MAX_PLAYER_NAME];
    switch(reason)
    {
        case 0: format(string, sizeof(string), "[LEFT] {FFFFFF}%s left the server.. (Crash)", GetPlayerNameEx(playerid));
        case 1: format(string, sizeof(string), "[LEFT] {FFFFFF}%s left the server..", GetPlayerNameEx(playerid));
    }
	if(reason != 2) SendClientMessageToAll(0xCCCC99FF, string);
    SaveStats(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerHealth(playerid, 100.0);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerRandomPos(playerid);
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid,PlayerInfo[playerid][pWeapon],500);
	GivePlayerWeapon(playerid,PlayerInfo[playerid][pWeapon2],500);
	GivePlayerWeapon(playerid,PlayerInfo[playerid][pWeapon3],500);
	GivePlayerWeapon(playerid,PlayerInfo[playerid][pWeapon4],500);
	return 1;
}
public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	for (new i; i < MAX_DROPS; i++)
	{
	    if (pickupid == g_StaticPickup[i][pickupPickupid])
		{
			switch (g_StaticPickup[i][pickupModel])
			{
			    case PICKUP_MODEL_WEAPONS:
				{
					GivePlayerWeapon(playerid, GetModelWeaponID(g_StaticPickup[i][pickupModel]), g_StaticPickup[i][pickupAmount]);
				}
			    case PICKUP_MODEL_HEALTH:
				{
			        new Float:value;
			        GetPlayerHealth(playerid, value);
			        if((value + g_StaticPickup[i][pickupAmount]) >= 100)
					{
						SetPlayerHealth(playerid, 100.0);
					}else
					{
						SetPlayerHealth(playerid, (value + g_StaticPickup[i][pickupAmount]));
					}
			    }
			}
		}
	}
	return 1;
}
stock SetPlayerRandomPos(playerid)
{
	switch(sInfo[sArea])
	{
		case 1:
		{
			new rand = random(sizeof bayside);
			SetPlayerPos(playerid,bayside[rand][0],bayside[rand][1],bayside[rand][2]);
			SetPlayerFacingAngle(playerid,bayside[rand][3]);
		}
		case 2:
		{
			new rand = random(sizeof sfbeach);
			SetPlayerPos(playerid,sfbeach[rand][0],sfbeach[rand][1],sfbeach[rand][2]);
			SetPlayerFacingAngle(playerid,sfbeach[rand][3]);
		}
		case 3:
		{
			new rand = random(sizeof fcarson);
			SetPlayerPos(playerid,fcarson[rand][0],fcarson[rand][1],fcarson[rand][2]);
			SetPlayerFacingAngle(playerid,fcarson[rand][3]);
		}
		case 4:
		{
			new rand = random(sizeof psquare);
			SetPlayerPos(playerid,psquare[rand][0],psquare[rand][1],psquare[rand][2]);
			SetPlayerFacingAngle(playerid,psquare[rand][3]);
		}
		case 5:
		{
			new rand = random(sizeof temple);
			SetPlayerPos(playerid,temple[rand][0],temple[rand][1],temple[rand][2]);
			SetPlayerFacingAngle(playerid,temple[rand][3]);
		}
		case 6:
		{
			new rand = random(sizeof enorth);
			SetPlayerPos(playerid,enorth[rand][0],enorth[rand][1],enorth[rand][2]);
			SetPlayerFacingAngle(playerid,enorth[rand][3]);
		}
		case 7:
		{
			new rand = random(sizeof fintersection);
			SetPlayerPos(playerid,fintersection[rand][0],fintersection[rand][1],fintersection[rand][2]);
			SetPlayerFacingAngle(playerid,fintersection[rand][3]);
		}
		case 8:
		{
			new rand = random(sizeof elquebrados);
			SetPlayerPos(playerid,elquebrados[rand][0],elquebrados[rand][1],elquebrados[rand][2]);
			SetPlayerFacingAngle(playerid,elquebrados[rand][3]);
		}
	}
}
function ChangeArea()
{
	maptimer = 900;
	switch(sInfo[sArea])
	{
		case 1:
		{
		    sInfo[sArea] = 2;
			SendClientMessageToAll(0xCCCC99FF, "[SERVER] {FFFFFF}Current map is San Fierro Beach");
			SendRconCommand("mapname San Fierro Beach");
			TextDrawSetString(MapName,"~r~~h~~h~Map~n~ ~w~~h~~h~San Fierro Beach");
		}
		case 2:
		{
		    sInfo[sArea] = 3;
		    SendClientMessageToAll(0xCCCC99FF, "[SERVER] {FFFFFF}Current map is Fort Carson");
		    SendRconCommand("mapname Fort Carson");
		    TextDrawSetString(MapName,"~r~~h~~h~Map~n~ ~w~~h~~h~Fort Carson");
		}
		case 3:
		{
		    sInfo[sArea] = 4;
		    SendClientMessageToAll(0xCCCC99FF, "[SERVER] {FFFFFF}Current map is Pershing Square");
		    SendRconCommand("mapname Pershing Square");
		    TextDrawSetString(MapName,"~r~~h~~h~Map~n~ ~w~~h~~h~Pershing Square");
		}
		case 4:
		{
		    sInfo[sArea] = 5;
		    SendClientMessageToAll(0xCCCC99FF, "[SERVER] {FFFFFF}Current map is Temple");
		    SendRconCommand("mapname Temple");
		    TextDrawSetString(MapName,"~r~~h~~h~Map~n~ ~w~~h~~h~Temple");
		}
		case 5:
		{
		    sInfo[sArea] = 6;
		    SendClientMessageToAll(0xCCCC99FF, "[SERVER] {FFFFFF}Current map is Esplanade North");
		    SendRconCommand("mapname Esplanade North");
		    TextDrawSetString(MapName,"~r~~h~~h~Map~n~ ~w~~h~~h~Esplanade North");
		}
		case 6:
		{
		    sInfo[sArea] = 7;
		    SendClientMessageToAll(0xCCCC99FF, "[SERVER] {FFFFFF}Current map is Flint Intersection");
		    SendRconCommand("mapname Flint Intersection");
		    TextDrawSetString(MapName,"~r~~h~~h~Map~n~ ~w~~h~~h~Flint Intersection");
		}
		case 7:
		{
		    sInfo[sArea] = 8;
		    SendClientMessageToAll(0xCCCC99FF, "[SERVER] {FFFFFF}Current map is El Quebrados");
		    SendRconCommand("mapname El Quebrados");
		    TextDrawSetString(MapName,"~r~~h~~h~Map~n~ ~w~~h~~h~El Quebrados");
		}
		case 8:
		{
		    sInfo[sArea] = 1;
		    SendClientMessageToAll(0xCCCC99FF, "[SERVER] {FFFFFF}Current map is Bayside");
		    SendRconCommand("mapname Bayside");
		    TextDrawSetString(MapName,"~r~~h~~h~Map~n~ ~w~~h~~h~Bayside");
		}
	}
	foreach(new i: Player)
	{
		KillTimer(spawn_timer[i]);
		spawn_timer[i] = SetTimerEx("SpawnPlayerEx", 500, false, "d", i);
	}
	return 1;
}
function SpawnPlayerEx(i)
{
	SpawnPlayer(i);
	return 1;
}
public OnPlayerDeath(playerid, killerid, reason)
{
	new	Float:x, Float:y, Float:z, weapon, ammo;
	GetPlayerPos(playerid, x, y, z);
	for (new i; i < 13; i++)
	{
		GetPlayerWeaponData(playerid, i, weapon, ammo);
		switch(weapon)
		{
		    case 1..37:
			{
				if (weapon != 0)
				{
					CreateStaticPickup(GetWeaponModelID(weapon), ammo, 19, x + random(4), y + random(4), z);
				}
			}
		}
	}
	CreateStaticPickup(PICKUP_MODEL_HEALTH, 25, 19, x + random(4), y + random(4), z);
	if(killerid != INVALID_PLAYER_ID)
	{
	    SendDeathMessage(killerid, playerid, reason);
	    PlayerInfo[killerid][pKills]++;
	    PlayerInfo[playerid][pDeaths]++;
	    GivePlayerMoney(killerid, 1000);
	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 1);
 		PlayerInfo[playerid][pSpree] = 0;
	    PlayerInfo[killerid][pSpree]++;
	    switch(PlayerInfo[killerid][pSpree])
	    {
	        case 3: GameTextForPlayer(killerid, "~n~~n~~n~~r~3x ~w~Combo!", 3000, 3), GivePlayerScore(killerid,2), GivePlayerMoney(killerid, 1000);
	        case 5: GameTextForPlayer(killerid, "~n~~n~~n~~r~5x ~w~Combo!", 3000, 3), GivePlayerScore(killerid,3), GivePlayerMoney(killerid, 1500);
	        case 8: GameTextForPlayer(killerid, "~n~~n~~n~~r~8x ~w~Combo!", 3000, 3), GivePlayerScore(killerid,5), GivePlayerMoney(killerid, 2000);
	        case 10: GameTextForPlayer(killerid, "~n~~n~~n~~r~10x ~w~Combo!", 3000, 3), GivePlayerScore(killerid,7), GivePlayerMoney(killerid, 2500);
	        case 15: GameTextForPlayer(killerid, "~n~~n~~n~~r~15x ~w~Combo!", 3000, 3), GivePlayerScore(killerid,10), GivePlayerMoney(killerid, 3000);
	        case 18: GameTextForPlayer(killerid, "~n~~n~~n~~r~18x ~w~Combo!", 3000, 3), GivePlayerScore(killerid,15), GivePlayerMoney(killerid, 3500);
	        case 20: GameTextForPlayer(killerid, "~n~~n~~n~~r~20x ~w~Combo!", 3000, 3), GivePlayerScore(killerid,20), GivePlayerMoney(killerid, 4000);
	    }
	}else
	if(killerid == INVALID_PLAYER_ID)
	{
	    SendDeathMessage(INVALID_PLAYER_ID, playerid, reason);
		PlayerInfo[playerid][pDeaths]++;
		PlayerInfo[playerid][pSpree] = 0;
		GivePlayerMoney(playerid, -1000);
	}
	return 1;
}
public OnPlayerText(playerid, text[])
{
	if(PlayerInfo[playerid][pMuted] == true)
	{
		SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You are muted");
		return 0;
 	}
	new textstring[156];
	format(textstring, sizeof textstring, "%s[%i]: {FFFFFF}%s", GetPlayerNameEx(playerid), playerid, text);
	SendClientMessageToAll(GetPlayerColor(playerid), textstring);
	SetPlayerChatBubble(playerid, text, GetPlayerColor(playerid), 50.0, 10000);
	return 0;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
    	case DIALOG_REGISTER:
	    {
	        if(!response)
	        {
    			SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You must register to continue.");
				_Kick(playerid);
	        }
	        if(response)
	        {
	            if(!strlen(inputtext) || strlen(inputtext) > 128)
	            {
	                SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You must insert a password between 1-128 characters!");
					ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,"{93FF93}Lobby DM - {FFFFFF}Register","{FFFFFF}Enter new password and click register to contiune.","Register","Quit");
	            }else
				if(strlen(inputtext) > 0 && strlen(inputtext) < 128)
	            {
   		        	new escpass[100];
			        mysql_escape_string(inputtext, escpass);
			        MySQL_Register(playerid, escpass);
	            }
	        }
	    }
	    case DIALOG_LOGIN:
	    {
	        if(!response)
	        {
 				SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You must login to continue.");
				_Kick(playerid);
	        }
	        if(response)
			{
	            new query[300], rows, fields;
	            mysql_format(dbHandle, query, sizeof(query), "SELECT `Username` FROM `PlayerData` WHERE `Username` = '%s' AND `Password` = SHA1('%e')", GetPlayerNameEx(playerid), inputtext);
	            mysql_query(dbHandle, query);
	            cache_get_data(rows, fields);
	            if(rows) MySQL_Login(playerid);
	            if(!rows)
	            {
	                Invalid[playerid]++;
	                if(Invalid[playerid]==4)
	                {
						_Kick(playerid);
					}else
					{
		                new str1[256];
				 		format(str1,sizeof(str1),"{FFFFFF}Wrong password!\n\nPlease login to contiune.\n\n{CCFFCC}Login chance: %d",4-Invalid[playerid]);
				 		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,"{93FF93}Lobby DM - {FFFFFF}Login",str1,"Login","Quit");
					}
	            }
	        }
		}
		case DIALOG_WEAPON:
		{
	        if(!response)
	        {
			    ShowPlayerDialog(playerid, DIALOG_WEAPON,DIALOG_STYLE_LIST,"{93FF93}Lobby DM - {FFFFFF}Weapon 1", "{FFFFFF}» Silenced\n\
																								       » Deagle\n\
																									   » Shotgun\n\
																									   » Sawn off\n\
																									   » Spas\n\
																									   » M4\n\
																									   » MP5\n\
																									   » Rifle\n\
																									   » Sniper","Okay","");
	        }
	        if(response)
			{
				switch(listitem)
				{
				    case 0: PlayerInfo[playerid][pWeapon] = 23,silahamk(playerid);
				    case 1: PlayerInfo[playerid][pWeapon] = 24,silahamk(playerid);
				    case 2: PlayerInfo[playerid][pWeapon] = 25,silahamk(playerid);
				    case 3: PlayerInfo[playerid][pWeapon] = 26,silahamk(playerid);
				    case 4: PlayerInfo[playerid][pWeapon] = 27,silahamk(playerid);
				    case 5: PlayerInfo[playerid][pWeapon] = 31,silahamk(playerid);
				    case 6: PlayerInfo[playerid][pWeapon] = 29,silahamk(playerid);
				    case 7: PlayerInfo[playerid][pWeapon] = 33,silahamk(playerid);
				    case 8: PlayerInfo[playerid][pWeapon] = 34,silahamk(playerid);
				}
			}
		}
		case DIALOG_WEAPON2:
		{
	        if(!response)
	        {
			    ShowPlayerDialog(playerid, DIALOG_WEAPON2,DIALOG_STYLE_LIST,"{93FF93}Lobby DM - {FFFFFF}Weapon 2", "{FFFFFF}» Silenced\n\
																								       » Deagle\n\
																									   » Shotgun\n\
																									   » Sawn off\n\
																									   » Spas\n\
																									   » M4\n\
																									   » MP5\n\
																									   » Rifle\n\
																									   » Sniper","Okay","");
	        }
	        if(response)
			{
				switch(listitem)
				{
				    case 0: PlayerInfo[playerid][pWeapon2] = 23,silahamk2(playerid);
				    case 1: PlayerInfo[playerid][pWeapon2] = 24,silahamk2(playerid);
				    case 2: PlayerInfo[playerid][pWeapon2] = 25,silahamk2(playerid);
				    case 3: PlayerInfo[playerid][pWeapon2] = 26,silahamk2(playerid);
				    case 4: PlayerInfo[playerid][pWeapon2] = 27,silahamk2(playerid);
				    case 5: PlayerInfo[playerid][pWeapon2] = 31,silahamk2(playerid);
				    case 6: PlayerInfo[playerid][pWeapon2] = 29,silahamk2(playerid);
				    case 7: PlayerInfo[playerid][pWeapon2] = 33,silahamk2(playerid);
				    case 8: PlayerInfo[playerid][pWeapon2] = 34,silahamk2(playerid);
				}
			}
		}
		case DIALOG_WEAPON3:
		{
	        if(!response)
	        {
			    ShowPlayerDialog(playerid, DIALOG_WEAPON3,DIALOG_STYLE_LIST,"{93FF93}Lobby DM - {FFFFFF}Weapon 3", "{FFFFFF}» Silenced\n\
																								       » Deagle\n\
																									   » Shotgun\n\
																									   » Sawn off\n\
																									   » Spas\n\
																									   » M4\n\
																									   » MP5\n\
																									   » Rifle\n\
																									   » Sniper","Okay","");
	        }
	        if(response)
			{
				switch(listitem)
				{
				    case 0: PlayerInfo[playerid][pWeapon3] = 23,silahamk3(playerid);
				    case 1: PlayerInfo[playerid][pWeapon3] = 24,silahamk3(playerid);
				    case 2: PlayerInfo[playerid][pWeapon3] = 25,silahamk3(playerid);
				    case 3: PlayerInfo[playerid][pWeapon3] = 26,silahamk3(playerid);
				    case 4: PlayerInfo[playerid][pWeapon3] = 27,silahamk3(playerid);
				    case 5: PlayerInfo[playerid][pWeapon3] = 31,silahamk3(playerid);
				    case 6: PlayerInfo[playerid][pWeapon3] = 29,silahamk3(playerid);
				    case 7: PlayerInfo[playerid][pWeapon3] = 33,silahamk3(playerid);
				    case 8: PlayerInfo[playerid][pWeapon3] = 34,silahamk3(playerid);
				}
			}
		}
		case DIALOG_WEAPON4:
		{
	        if(!response)
	        {
			    ShowPlayerDialog(playerid, DIALOG_WEAPON4,DIALOG_STYLE_LIST,"{93FF93}Lobby DM - {FFFFFF}Weapon 4", "{FFFFFF}» Silenced\n\
																								       » Deagle\n\
																									   » Shotgun\n\
																									   » Sawn off\n\
																									   » Spas\n\
																									   » M4\n\
																									   » MP5\n\
																									   » Rifle\n\
																									   » Sniper","Okay","");
	        }
	        if(response)
			{
				switch(listitem)
				{
				    case 0: PlayerInfo[playerid][pWeapon4] = 23;
				    case 1: PlayerInfo[playerid][pWeapon4] = 24;
				    case 2: PlayerInfo[playerid][pWeapon4] = 25;
				    case 3: PlayerInfo[playerid][pWeapon4] = 26;
				    case 4: PlayerInfo[playerid][pWeapon4] = 27;
				    case 5: PlayerInfo[playerid][pWeapon4] = 31;
				    case 6: PlayerInfo[playerid][pWeapon4] = 29;
				    case 7: PlayerInfo[playerid][pWeapon4] = 33;
				    case 8: PlayerInfo[playerid][pWeapon4] = 34;
				}
				ResetPlayerWeapons(playerid);
				GivePlayerWeapon(playerid,PlayerInfo[playerid][pWeapon],500);
				GivePlayerWeapon(playerid,PlayerInfo[playerid][pWeapon2],500);
				GivePlayerWeapon(playerid,PlayerInfo[playerid][pWeapon3],500);
				GivePlayerWeapon(playerid,PlayerInfo[playerid][pWeapon4],500);
			}
		}
	}
	return 1;
}
stock silahamk(playerid)
{
			    ShowPlayerDialog(playerid, DIALOG_WEAPON2,DIALOG_STYLE_LIST,"{93FF93}Lobby DM - {FFFFFF}Weapon 2", "{FFFFFF}» Silenced\n\
																								       » Deagle\n\
																									   » Shotgun\n\
																									   » Sawn off\n\
																									   » Spas\n\
																									   » M4\n\
																									   » MP5\n\
																									   » Rifle\n\
																									   » Sniper","Okay","");
}
stock silahamk2(playerid)
{
			    ShowPlayerDialog(playerid, DIALOG_WEAPON3,DIALOG_STYLE_LIST,"{93FF93}Lobby DM - {FFFFFF}Weapon 3", "{FFFFFF}» Silenced\n\
																								       » Deagle\n\
																									   » Shotgun\n\
																									   » Sawn off\n\
																									   » Spas\n\
																									   » M4\n\
																									   » MP5\n\
																									   » Rifle\n\
																									   » Sniper","Okay","");
}
stock silahamk3(playerid)
{
			    ShowPlayerDialog(playerid, DIALOG_WEAPON4,DIALOG_STYLE_LIST,"{93FF93}Lobby DM - {FFFFFF}Weapon 4", "{FFFFFF}» Silenced\n\
																								       » Deagle\n\
																									   » Shotgun\n\
																									   » Sawn off\n\
																									   » Spas\n\
																									   » M4\n\
																									   » MP5\n\
																									   » Rifle\n\
																									   » Sniper","Okay","");
}
public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &weapon, &bodypart)
{
	if(issuerid != INVALID_PLAYER_ID)
	{
	    if(IsPlayerPaused(playerid))
	    {
	    	GameTextForPlayer(issuerid, "~r~~h~AFK~w~!", 1000, 1);
	    	return 0;
		}
	}
	return 1;
}
public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(!success) SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}Unknown command.");
    return 1;
}
// Admin commands
CMD:changemap(playerid, params[])
{
	if(PlayerInfo[playerid][pAdminLevel] < 1) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You are not authorized to use this command.");
	KillTimer(Area_timer);
	Area_timer = SetTimer("ChangeArea",1000*60*15,true);
	maptimer = 900;
	ChangeArea();
	return 1;
}
CMD:setlevel(playerid, params[])
{
    new level, id;
    if(PlayerInfo[playerid][pAdminLevel] < 5) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You are not authorized to use this command.");
    if(sscanf(params, "ui", id, level)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/setlevel id level(max 5)");
    if(level < 0 || level > 5) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}Max level 5, min level 0 submit!");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}Player is not connected!");
    if(PlayerInfo[id][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You cant use this command to him/her");
    PlayerInfo[id][pAdminLevel] = level;
	if(PlayerInfo[id][pAdminLevel] >= 1)
	{
	    SetPlayerColor(id, 0xFF0000FF);
	}else
	{
	    SetPlayerColor(id, 0x99FFCCFF);
	}
	return 1;
}
CMD:deleteacc(playerid, params[])
{
    new use[24], query[128];
    if(PlayerInfo[playerid][pAdminLevel] < 5) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You are not authorized to use this command.");
    if(sscanf(params, "s[24]", use)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/deleteacc isim");
   	if(!CheckNick(use)) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}No player");
	mysql_format(dbHandle, query, sizeof(query), "DELETE FROM `PlayerData` WHERE `Username` = '%e'", use);
 	mysql_query(dbHandle, query);
	return 1;
}
stock CheckNick(params[])
{
	new Query[128];
	mysql_format(dbHandle, Query, sizeof(Query), "SELECT * FROM `PlayerData` WHERE `Username` = '%e'", params);
	new Cache:cache = mysql_query(dbHandle,Query);
	if(cache_get_row_count() > 0)
	{
		cache_delete(cache);
		return 0;
	}
	cache_delete(cache);
	return 1;
}
CMD:ban(playerid,params[])
{
    new id, reason[40];
    if(PlayerInfo[playerid][pAdminLevel] < 3) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You are not authorized to use this command.");
	if(sscanf(params,"ds",id,reason)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/ban id reason");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}Player is not connected!");
    if(PlayerInfo[id][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You cant use this command to him/her");
    BanReason(id, reason, GetPlayerNameEx(playerid));
	return 1;
}
CMD:kick(playerid,params[])
{
    new id, reason[40];
    if(PlayerInfo[playerid][pAdminLevel] < 2) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You are not authorized to use this command.");
	if(sscanf(params,"ds",id,reason)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/kick id reason");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}Player is not connected!");
    if(PlayerInfo[id][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You cant use this command to him/her");
    KickReason(id, reason, GetPlayerNameEx(playerid));
	return 1;
}
CMD:mute(playerid,params[])
{
    new id, reason[40];
    if(PlayerInfo[playerid][pAdminLevel] < 3) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You are not authorized to use this command.");
	if(sscanf(params,"ds",id,reason)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/mute id reason");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}Player is not connected!");
    if(PlayerInfo[id][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You cant use this command to him/her");
    new str[128];
    format(str, sizeof(str), "[MUTE] {FFFFFF}You have been muted. Admin: %s Reason: %s", GetPlayerNameEx(playerid), reason);
	SendClientMessage(playerid, 0xFF0000FF, str);
    format(str, sizeof(str), "[MUTE] {FFFFFF}%s have been muted. Admin: %s Reason: %s", GetPlayerNameEx(id), GetPlayerNameEx(playerid), reason);
	SendClientMessageToAll(0xFF0000FF, str);
    PlayerInfo[id][pMuted] = true;
	return 1;
}
CMD:unmute(playerid,params[])
{
    new id;
    if(PlayerInfo[playerid][pAdminLevel] < 3) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You are not authorized to use this command.");
	if(sscanf(params,"d",id)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/unmute id");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}Player is not connected!");
    if(PlayerInfo[id][pAdminLevel] > PlayerInfo[playerid][pAdminLevel]) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You cant use this command to him/her");
    new str[128];
    format(str, sizeof(str), "[MUTE] {FFFFFF}You have been un-muted. Admin: %s", GetPlayerNameEx(playerid));
	SendClientMessage(playerid, 0xFF0000FF, str);
    format(str, sizeof(str), "[MUTE] {FFFFFF}%s have been un-muted. Admin: %s", GetPlayerNameEx(id), GetPlayerNameEx(playerid));
	SendClientMessageToAll(0xFF0000FF, str);
    PlayerInfo[id][pMuted] = false;
	return 1;
}
CMD:goto(playerid, params[])
{
    new id, String[128], Float:mypos[3];
    if(PlayerInfo[playerid][pAdminLevel] < 3) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You are not authorized to use this command.");
	if(sscanf(params,"u", id)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/goto id");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}Player is not connected!");
    if(playerid == id) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You cant teleport yourself");
    GetPlayerPos(id, mypos[0], mypos[1], mypos[2]);
    SetPlayerPos(playerid, mypos[0], mypos[1], mypos[2]+3);
    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(id));
   	format(String, sizeof(String), "[GOTO] {FFFFFF}You are teleported to %s", GetPlayerNameEx(id));
    SendClientMessage(playerid, 0xFF0000FF, String);
	format(String, sizeof(String), "[GOTO] {FFFFFF}%s teleported to you", GetPlayerNameEx(playerid));
    SendClientMessage(id, 0xFF0000FF, String);
	return 1;
}
CMD:get(playerid, params[])
{
    new id, Float:mypos[3];
    if(PlayerInfo[playerid][pAdminLevel] < 3) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You are not authorized to use this command.");
	if(sscanf(params,"u", id)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/get id");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}Player is not connected!");
    if(playerid == id) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You cant get yourself");
    GetPlayerPos(playerid, mypos[0], mypos[1], mypos[2]);
    SetPlayerPos(id, mypos[0], mypos[1], mypos[2]+3);
    SetPlayerVirtualWorld(id, GetPlayerVirtualWorld(playerid));
	return 1;
}
CMD:cc(playerid, params[])
{
    if(PlayerInfo[playerid][pAdminLevel] < 1) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}You are not authorized to use this command.");
    for(new i = 0; i < 30; i++) SendClientMessageToAll(-1, " ");
    SendClientMessageToAll(0xCCCC99FF, "[SERVER] {FFFFFF}Chat cleared");
    return 1;
}
CMD:changename(playerid, params[])
{
	new newname[25], Query[256], rows, fields;
	if(sscanf(params,"s[24]",newname)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/changename [newname(max:24 char)]");
	if(strlen(newname) > 24) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/changename [newname(max:24 char)]");
	mysql_format(dbHandle,Query, sizeof(Query), "SELECT * FROM `PlayerData` WHERE `Username` = '%e'", newname);
	mysql_query(dbHandle,Query);
	cache_get_data(rows, fields);
	if(rows) SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}This name already used! Try another!");
	else if(!rows)
	{
		mysql_format(dbHandle,Query, sizeof(Query), "UPDATE `PlayerData` SET `Username` = '%e' WHERE `Username` = '%e'", newname, GetPlayerNameEx(playerid));
		mysql_query(dbHandle,Query,false);
		SetPlayerName(playerid, newname);
	}
	return 1;
}
CMD:changepass(playerid, params[])
{
	new newpass[65], Query[256];
	if(sscanf(params,"s[64]",newpass)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/changepass [newpass(max:64)]");
	if(strlen(newpass) > 64) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/changepass [newpass(max:64 char)]");
	mysql_format(dbHandle, Query, sizeof(Query), "UPDATE `PlayerData` SET `Password` = SHA1('%e') WHERE `Username` = '%s'", newpass, GetPlayerNameEx(playerid));
	mysql_query(dbHandle, Query, false);
	return 1;
}

CMD:skin(playerid, params[])
{
	new skin;
	if(sscanf(params, "i", skin)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/skin id ");
	if(strval(params) < 0 || strval(params) > 311) return 1;
	SetPlayerSkin(playerid, skin);
	return 1;
}
CMD:time(playerid, params[])
{
    new time;
   	if(sscanf(params,"i", time)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/time id ");
    if((time < 0) || (time > 24)) return 1;
    SetPlayerTime(playerid, time,0);
    return 1;
}
CMD:weather(playerid, params[])
{
    new weather;
   	if(sscanf(params,"i", weather)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/weather id ");
    if((weather < 0) || (weather > 100)) return 1;
    SetPlayerWeather(playerid, weather);
    return 1;
}
CMD:gunmenu(playerid, params[])
{
    ShowPlayerDialog(playerid, DIALOG_WEAPON,DIALOG_STYLE_LIST,"{93FF93}Lobby DM - {FFFFFF}Weapon 1", "» Silenced\n\
	       					                                                                   	» Deagle\n\
		   																						» Shotgun\n\
		   																						» Sawn off\n\
		   																						» Spas\n\
		   																						» M4\n\
			  																				 	» MP5\n\
			   																					» Rifle\n\
		   																						» Sniper","Okay","");
	return 1;
}
CMD:stats(playerid, params[])
{
	new id, str[256];
	if(sscanf(params,"u", id)) return SendClientMessage(playerid, 0xCCCC99FF, "[USAGE] {FFFFFF}/stats id");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR] {FFFFFF}Player is not connected!");
    new Float:rat =  floatdiv(PlayerInfo[id][pKills], PlayerInfo[id][pDeaths]);
	format(str, sizeof(str), "{93FF93}» {FFFFFF}Nick: %s\n\
							  {93FF93}» {FFFFFF}Level: %d\n\
							  {93FF93}» {FFFFFF}Kills: %d\n\
							  {93FF93}» {FFFFFF}Deaths: %d\n\
							  {93FF93}» {FFFFFF}Ratio: %.2f\n\
							  {93FF93}» {FFFFFF}Money: %d\n\
							  {93FF93}» {FFFFFF}Score: %d", GetPlayerNameEx(id), PlayerInfo[id][pAdminLevel], PlayerInfo[id][pKills], PlayerInfo[id][pDeaths], rat, PlayerInfo[id][pMoney], PlayerInfo[id][pScore]);
	ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX,"{93FF93}Lobby DM - {FFFFFF}Stats",str,"Okay","");
	return 1;
}
CMD:alladmins(playerid,params[])
{
	foreach(new i: Player) SaveStats(i);
	new	query[256], Cache:VeriCek;
	mysql_format(dbHandle, query, sizeof(query), "SELECT `pAdminLevel`, `Username` FROM `PlayerData` ORDER BY `pAdminLevel` DESC LIMIT 20");
	VeriCek = mysql_query(dbHandle, query);
	new rows = cache_num_rows();
	if(rows)
	{
		new list[1024], IsimCek[MAX_PLAYER_NAME], count = 1, levell;
		for(new i = 0; i < rows; ++i)
		{
			cache_get_field_content(i, "Username", IsimCek);
			levell = cache_get_field_content_int(i, "pAdminLevel");
			if(levell > 0)
			{
				format(list,sizeof(list),"%s{FF0000}%02d:{FFFFFF}\t\t%s\t\t\t{00FF00}%s\n", list, count, levell, IsimCek);
				count++;
			}
		}
		ShowPlayerDialog(playerid, DIALOG_ADMINS, DIALOG_STYLE_MSGBOX, "{93FF93}Lobby DM - {FFFFFF}All Admins", list, "Kapat", "");
	}
	cache_delete(VeriCek);
	return 1;
}
public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	new str[3];
	format(str, sizeof(str), "%d", clickedplayerid);
	return cmd_stats(playerid, str);
}
stock GivePlayerScore(playerid, miktar) return SetPlayerScore(playerid, GetPlayerScore(playerid)+miktar);
function KickReason(id, reason[], admin[])
{
	new stringx[156];
	format(stringx,sizeof(stringx),"[KICK] {FFFFFF}%s is kicked. Admin: %s Reason: %s.", GetPlayerNameEx(id),admin, reason);
	SendClientMessageToAll(0xFF0000FF,stringx);
	GameTextForPlayer(id, "~r~~h~KICKED~w~!", 30000, 5);
    PlayerPlaySound(id, 1085, 0, 0, 0);
	_Kick(id);
	return 1;
}
function BanReason(id, reason[], admin[])
{
	new stringx[156];
	format(stringx,sizeof(stringx),"[BAN] {FFFFFF}%s is banned. Admin: %s Reason: %s.", GetPlayerNameEx(id),admin, reason);
	SendClientMessageToAll(0xFF0000FF,stringx);
	GameTextForPlayer(id, "~r~~h~BANNED~w~!", 30000, 5);
	PlayerPlaySound(id, 1085, 0, 0, 0);
	_Ban(id);
	return 1;
}
stock SureYasagi(playerid, _0xyasakIsim[], _n0xsure)
{
	new _v3r1[35], string[200], _@0xsaniye;
	format(_v3r1, sizeof(_v3r1), "nTempSure_%s", _0xyasakIsim);
	if(GetPVarInt(playerid, _v3r1) > GetTickCount())
	{
	    new verilenSure = (GetPVarInt(playerid, _v3r1) - GetTickCount()) / 1000;
		_@0xsaniye = floatround(verilenSure);
		format(string, sizeof(string), "[ERROR] {FFFFFF}Wait %d second!", _@0xsaniye);
	    return SendClientMessage(playerid, 0xFF0000FF, string);
	}else
	{
	    SetPVarInt(playerid, _v3r1, GetTickCount() + _n0xsure * 1000);
	    return 0;
	}
}
public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
    printf( "< [MySQL] > HATAID: %d | HATA: %s | callback: %s | query: %s", errorid, error, callback, query);
	return 1;
}
stock _Kick(playerid)
{
 	SetTimerEx("DelayAction", 100, false, "ii", playerid, 1);
    return 1;
}

stock _Ban(playerid)
{
 	SetTimerEx("DelayAction", 100, false, "ii", playerid, 2);
    return 1;
}
function DelayAction(playerid, action)
{
	switch(action)
	{
		case 1: Kick(playerid);
		case 2: Ban(playerid);
	}
    return 1;
}
public AntiFly(playerid)
{
	KickReason(playerid, "Fly Hack", "System");
 	return 1;
}
function TabloYenile()
{
	foreach(new i: Player) TabloGuncelle(i);
}
stock TabloGuncelle(playerid)
{
    new Float:rat =  floatdiv(PlayerInfo[playerid][pKills], PlayerInfo[playerid][pDeaths]);
	new string[128];
	format(string,sizeof string,"~y~~h~Kill: ~w~~h~%d ~g~~h~~h~Death: ~w~~h~%d ~p~~h~Ratio: ~w~~h~%.02f",PlayerInfo[playerid][pKills],PlayerInfo[playerid][pDeaths], rat);
	TextDrawSetString(StatsText[playerid],string);
	format(string,sizeof string,"~g~~h~~h~Ping: ~w~~h~~h~%d ~r~~h~~h~FPS: ~w~~h~~h~%d ~b~~h~~h~PL: ~w~~h~~h~%.02f",GetPlayerPing(playerid),GetPlayerFPS(playerid), GetPlayerPacketLoss(playerid));
	TextDrawSetString(PingText[playerid],string);
}
CreateStaticPickup(modelid, ammount, type, Float:x, Float:y, Float:z)
{
	for (new i = 0; i < MAX_DROPS; i++)
	{
	    if (!IsValidStaticPickup(i))
		{
			g_StaticPickup[i][pickupModel] = modelid;
    		g_StaticPickup[i][pickupAmount] = ammount;
 			g_StaticPickup[i][pickupPickupid] = CreateDynamicPickup(modelid, type, x, y, z, -1, -1);
			g_StaticPickup[i][pickupTimer] = SetTimerEx("OnAutoPickupDestroy", 5000, false, "i", i);
			return i;
    	}
    }
    return -1;
}
DestroyStaticPickup(pickupid)
{
	DestroyDynamicPickup(g_StaticPickup[pickupid][pickupPickupid]);
    if(g_StaticPickup[pickupid][pickupTimer] != -1)
	{
		KillTimer(g_StaticPickup[pickupid][pickupTimer]);
	}
	g_StaticPickup[pickupid][pickupTimer] = -1;
   	return true;
}
IsValidStaticPickup(pickupid)
{
    return IsValidDynamicPickup(g_StaticPickup[pickupid][pickupPickupid]);
}
function OnAutoPickupDestroy(pickupid)
{
	return DestroyStaticPickup(pickupid);
}
GetModelWeaponID(weaponid)
{
	switch (weaponid)
	{
	    case 331: return 1;
	    case 333: return 2;
	    case 334: return 3;
	    case 335: return 4;
	    case 336: return 5;
	    case 337: return 6;
	    case 338: return 7;
	    case 339: return 8;
	    case 341: return 9;
	    case 321: return 10;
	    case 322: return 11;
	    case 323: return 12;
	    case 324: return 13;
	    case 325: return 14;
	    case 326: return 15;
	    case 342: return 16;
	    case 343: return 17;
	    case 344: return 18;
	    case 346: return 22;
	    case 347: return 23;
	    case 348: return 24;
	    case 349: return 25;
	    case 350: return 26;
	    case 351: return 27;
	    case 352: return 28;
	    case 353: return 29;
	    case 355: return 30;
	    case 356: return 31;
	    case 372: return 32;
	    case 357: return 33;
	    case 358: return 34;
	    case 359: return 35;
	    case 360: return 36;
	    case 361: return 37;
	    case 362: return 38;
	    case 363: return 39;
	    case 364: return 40;
	    case 365: return 41;
	    case 366: return 42;
	    case 367: return 43;
	    case 368: return 44;
	    case 369: return 45;
	    case 371: return 46;
	}
	return -1;
}

GetWeaponModelID(weaponid)
{
	switch (weaponid)
	{
	    case 1: return 331;
	    case 2: return 333;
	    case 3: return 334;
	    case 4: return 335;
	    case 5: return 336;
	    case 6: return 337;
	    case 7: return 338;
	    case 8: return 339;
	    case 9: return 341;
	    case 10: return 321;
	    case 11: return 322;
	    case 12: return 323;
	    case 13: return 324;
	    case 14: return 325;
	    case 15: return 326;
	    case 16: return 342;
	    case 17: return 343;
	    case 18: return 344;
	    case 22: return 346;
	    case 23: return 347;
	    case 24: return 348;
	    case 25: return 349;
	    case 26: return 350;
	    case 27: return 351;
	    case 28: return 352;
	    case 29: return 353;
	    case 30: return 355;
	    case 31: return 356;
	    case 32: return 372;
	    case 33: return 357;
	    case 34: return 358;
	    case 35: return 359;
	    case 36: return 360;
	    case 37: return 361;
	    case 38: return 362;
	    case 39: return 363;
	    case 40: return 364;
	    case 41: return 365;
	    case 42: return 366;
	    case 43: return 367;
	    case 44: return 368;
	    case 45: return 369;
	    case 46: return 371;
	}
	return -1;
}
