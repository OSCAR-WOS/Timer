public Action Command_Admin(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_INGAME, true)) return Plugin_Handled;
	ClearAdminData(iClient);

	Admin_Menu(iClient);
	return Plugin_Handled;
}

void Admin_Menu(int iClient) {
	char[] cBuffer = new char[512];
	Menu mMenu = new Menu(Menu_Admin);

	Format(cBuffer, 512, "%s (%s)", PLUGIN_NAME, PLUGIN_VERSION);
	mMenu.SetTitle(cBuffer);

	mMenu.AddItem("", "", ITEMDRAW_SPACER);

	Format(cBuffer, 512, "%t", "menu_zone");
	mMenu.AddItem("", cBuffer);

	mMenu.Display(iClient, 0);
}

public int Menu_Admin(Menu mMenu, MenuAction maAction, int iParam1, int iParam2) {
	if (maAction == MenuAction_Select) {
		switch (iParam2) {
			case 1: {
				Admin_Zone(iParam1);
			}
		}
	}

	if (maAction == MenuAction_End) { delete mMenu; }
}

public Action Command_Zone(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_INGAME, true)) return Plugin_Handled;
	ClearAdminData(iClient);

	Admin_Zone(iClient);
	return Plugin_Handled;
}

void Admin_Zone(int iClient) {
	char[] cBuffer = new char[512];
	Menu mMenu = new Menu(Menu_Zone);
	mMenu.ExitBackButton = true;

	Format(cBuffer, 512, "%s (%s) - %t", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone");
	mMenu.SetTitle(cBuffer);

	mMenu.AddItem("", "", ITEMDRAW_SPACER);

	Format(cBuffer, 512, "%t", "menu_addzone");
	mMenu.AddItem("", cBuffer, Misc_CheckPlayer(iClient, PLAYER_ALIVE) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	Format(cBuffer, 512, "%t", "menu_editzone");
	mMenu.AddItem("", cBuffer, ITEMDRAW_DISABLED);

	Format(cBuffer, 512, "%t", "menu_delzone");
	mMenu.AddItem("", cBuffer, ITEMDRAW_DISABLED);

	mMenu.Display(iClient, 0);
}

public int Menu_Zone(Menu mMenu, MenuAction maAction, int iParam1, int iParam2) {
	if (maAction == MenuAction_Select) {
		switch (iParam2) {
			case 1: {
				g_Global.Players.SetAdminSetting(iParam1, 0);
				g_Global.Players.SetAdminOption(iParam1, 0);

				Admin_AddZone(iParam1);
			}
			case 2: { }
			case 3: { }
		}
	} else if (maAction == MenuAction_Cancel) {
		if (iParam2 == MenuCancel_ExitBack) Admin_Menu(iParam1);
	}

	if (maAction == MenuAction_End) { delete mMenu; }
}

public Action Command_AddZone(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_ALIVE, true)) return Plugin_Handled;
	ClearAdminData(iClient);

	g_Global.Players.SetAdminSetting(iClient, 0);
	g_Global.Players.SetAdminOption(iClient, 0);

	Admin_AddZone(iClient);
	return Plugin_Handled;
}

void Admin_AddZone(int iClient) {
	char[] cBuffer = new char[512];
	Menu mMenu = new Menu(Menu_AddZone);
	mMenu.ExitBackButton = true;

	float fX[3], fY[3];

	g_Global.Players.GetAdminZoneX(iClient, fX);
	g_Global.Players.GetAdminZoneY(iClient, fY);

	mMenu.AddItem("", "", ITEMDRAW_SPACER);

	switch (g_Global.Players.GetAdminSetting(iClient)) {
		case 0: {
			switch (g_Global.Players.GetAdminOption(iClient)) {
				case 0: {
					Format(cBuffer, 512, "%s (%s) - %t - %t", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", "menu_addzone");
					mMenu.SetTitle(cBuffer);

					Format(cBuffer, 512, "%t", "menu_addzone_saveregion");
					mMenu.AddItem("", cBuffer, (fX[0] != 0.0 && fY[0] != 0.0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

					mMenu.AddItem("", "", ITEMDRAW_SPACER);

					Format(cBuffer, 512, "%t", "menu_addzone_editp1");
					mMenu.AddItem("", cBuffer, (fX[0] != 0.0 && fY[0] != 0.0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

					Format(cBuffer, 512, "%t", "menu_addzone_editp2");
					mMenu.AddItem("", cBuffer, (fY[0] != 0.0 && fY[0] != 0.0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
				}
			}
		} case 1: {

		} case 2: {
			Format(cBuffer, 512, "%s (%s) - %t - %t", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", "menu_addzone_editp1");
			mMenu.SetTitle(cBuffer);

			Format(cBuffer, 512, "%t", "menu_addzone_editx");
			mMenu.AddItem("", cBuffer, (g_Global.Players.GetAdminOption(iClient) != 0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_addzone_edity");
			mMenu.AddItem("", cBuffer, (g_Global.Players.GetAdminOption(iClient) != 1) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_addzone_editz");
			mMenu.AddItem("", cBuffer, (g_Global.Players.GetAdminOption(iClient) != 2) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		} case 3: {
			Format(cBuffer, 512, "%s (%s) - %t - %t", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", "menu_addzone_editp2");
			mMenu.SetTitle(cBuffer);

			Format(cBuffer, 512, "%t", "menu_addzone_editx");
			mMenu.AddItem("", cBuffer, (g_Global.Players.GetAdminOption(iClient) != 0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_addzone_edity");
			mMenu.AddItem("", cBuffer, (g_Global.Players.GetAdminOption(iClient) != 1) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_addzone_editz");
			mMenu.AddItem("", cBuffer, (g_Global.Players.GetAdminOption(iClient) != 2) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}
	}

	mMenu.Display(iClient, 0);
}

public int Menu_AddZone(Menu mMenu, MenuAction maAction, int iParam1, int iParam2) {
	if (maAction == MenuAction_Select) {
		float fX[3], fY[3];

		g_Global.Players.GetAdminZoneX(iParam1, fX);
		g_Global.Players.GetAdminZoneY(iParam1, fY);

		if (fX[2] == fY[2]) { fY[2] += BOX_BOUNDRY; g_Global.Players.SetAdminZoneY(iParam1, fY); }
		switch (g_Global.Players.GetAdminSetting(iParam1)) {
			case 0: {
				switch (iParam2) {
					case 1: { g_Global.Players.SetAdminSetting(iParam1, 1); }
					case 3: { g_Global.Players.SetAdminSetting(iParam1, 2); }
					case 4: { g_Global.Players.SetAdminSetting(iParam1, 3); }
				}
			} case 2: { g_Global.Players.SetAdminOption(iParam1, iParam2 - 1); }
			case 3: { g_Global.Players.SetAdminOption(iParam1, iParam2 - 1); }
		}

		Admin_AddZone(iParam1);
	}

	if (maAction == MenuAction_Cancel) {
		switch (iParam2) {
			case MenuCancel_ExitBack: {
				switch (g_Global.Players.GetAdminSetting(iParam1)) {
					case 0: { g_Global.Players.SetAdminSetting(iParam1, -1); g_Global.Players.SetAdminOption(iParam1, -1); Admin_Zone(iParam1); }
					case 1: { g_Global.Players.SetAdminSetting(iParam1, 0); g_Global.Players.SetAdminOption(iParam1, 0); Admin_AddZone(iParam1); }
					case 2: { g_Global.Players.SetAdminSetting(iParam1, 0); g_Global.Players.SetAdminOption(iParam1, 0); Admin_AddZone(iParam1); }
					case 3: { g_Global.Players.SetAdminSetting(iParam1, 0); g_Global.Players.SetAdminOption(iParam1, 0); Admin_AddZone(iParam1); }
				}
			} case MenuCancel_Exit: { ClearAdminData(iParam1); }
		}
	}

	if (maAction == MenuAction_End) { delete mMenu; }
}

void Timer_Admin() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!Misc_CheckPlayer(i, PLAYER_INGAME)) return;

		Player pPlayer = view_as<Player>(g_Global.Players.Get(i));
		if (pPlayer.Admin.Setting == -1) return;

		float xPos[3], yPos[3];

		pPlayer.Zone.GetX(xPos);
		pPlayer.Zone.GetY(yPos);

		if (xPos[0] != 0.0 && yPos[0] != 0.0) {
			if (xPos[2] == yPos[2]) { yPos[2] += BOX_BOUNDRY; }
			Zone_DrawSprite(xPos, 0, 0.5, false, i);
			Zone_DrawSprite(yPos, 1, 0.5, false, i);
		}

		switch (pPlayer.Admin.Setting) {
			case 0: {
				float fPos[3];
				Zone_RayTrace(i, fPos);

				if (xPos[0] != 0.0 && yPos[0] != 0.0) {
					if (xPos[2] == yPos[2]) { yPos[2] += BOX_BOUNDRY; }
					Zone_Draw(i, xPos, yPos, 4, true);
				} else if (xPos[0] != 0.0) {
					if (fPos[2] == xPos[2]) { fPos[2] += BOX_BOUNDRY; }
					Zone_Draw(i, xPos, fPos, 3, true);
				} else if (yPos[0] != 0.0) {
					if (fPos[2] == yPos[2]) { fPos[2] += BOX_BOUNDRY; }
					Zone_Draw(i, fPos, yPos, 3, true);
				} else {
					Zone_DrawSprite(fPos, 0, 0.1, false, i);
				}
			} case 1: { Zone_Draw(i, xPos, yPos, 0, true); }
			case 2: { Zone_DrawAdmin(i, xPos); }
			case 3: { Zone_DrawAdmin(i, yPos); }
		}
	}
}

void ClearAdminData(int iClient) {
	Player pPlayer = view_as<Player>(g_Global.Players.Get(iClient));
	pPlayer.Clear();

	pPlayer.Admin = new Admin();
	pPlayer.Zone = new Zone();

	g_Global.Players.Set(iClient, pPlayer);
}
