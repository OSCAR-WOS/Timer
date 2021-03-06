void Replay_Start() {
	char[] cBuffer = new char[512];
	BuildPath(Path_SM, cBuffer, 512, "data/SourceTimer");

	if (!DirExists(cBuffer)) CreateDirectory(cBuffer, 511);
}

ArrayList Replay_Load(int iClient, int iStyle, int iGroup) {
	char[] cBuffer = new char[512];
	char[] cMapName = new char[32];
	char[] cHeader = new char[128];
	char[][] cHeaderExplode = new char[2][64];
	int iClientId;

	if (iClient != 0) iClientId = GetSteamAccountID(iClient);
	GetCurrentMap(cMapName, 32);

	BuildPath(Path_SM, cBuffer, 512, "data/SourceTimer/%i", iClientId);
	if (!DirExists(cBuffer)) return;

	BuildPath(Path_SM, cBuffer, 512, "data/SourceTimer/%i/%i-%i-%s.rec", iClientId, iStyle, iGroup, cMapName);
	if (!FileExists(cBuffer)) return;

	File fReplay;
	fReplay = OpenFile(cBuffer, "rb");

	if (!fReplay.ReadLine(cHeader, 128)) return;
	int iSize;

	TrimString(cHeader);
	ExplodeString(cHeader, "|", cHeaderExplode, 2, 64);
	iSize = StringToInt(cHeaderExplode[0]);

	ArrayList alFrames = new ArrayList(sizeof(ReplayFrame));
	any[] aFrameData = new any[REPLAY_BUFFER_SIZE * sizeof(ReplayFrame)];

	for (int i = 0; i < iSize; i++) {
		float fPos[3], fAngle[3], fVel[3];
		ReplayFrame rFrame;

		if (fReplay.Read(aFrameData, sizeof(ReplayFrame), 4) >= 0) {
			for (int k = 0; k < 3; k++) {
				fPos[k] = view_as<float>(aFrameData[k]);
				fAngle[k] = view_as<float>(aFrameData[k + 3]);
				fVel[k] = view_as<float>(aFrameData[k + 6]);

				if (k == 0) rFrame.Buttons = view_as<int>(aFrameData[9]);
			}
		}

		rFrame.SetPos(fPos);
		rFrame.SetAngle(fAngle);
		rFrame.SetVel(fVel);
		alFrames.PushArray(rFrame);
	}

	delete fReplay;
	return alFrames;
}

void Replay_Save(int iClient, int iStyle, int iGroup, float fTime, ArrayList alFrames) {
	char[] cBuffer = new char[512];
	char[] cMapName = new char[32];
	char[] cHeader = new char[128];
	char[][] cHeaderExplode = new char[2][64];
	int iClientId;

	if (iClient != 0) {
		iClientId = GetSteamAccountID(iClient);
		Replay_Save(0, iStyle, iGroup, fTime, alFrames.Clone());
	}
	GetCurrentMap(cMapName, 32);

	BuildPath(Path_SM, cBuffer, 512, "data/SourceTimer/%i", iClientId);
	if (!DirExists(cBuffer)) CreateDirectory(cBuffer, 511);

	File fReplay;
	BuildPath(Path_SM, cBuffer, 512, "data/SourceTimer/%i/%i-%i-%s.rec", iClientId, iStyle, iGroup, cMapName);
	if (FileExists(cBuffer)) {
		fReplay = OpenFile(cBuffer, "rb");
		if (fReplay.ReadLine(cHeader, 128)) {
			float fReplayTime;

			TrimString(cHeader);
			ExplodeString(cHeader, "|", cHeaderExplode, 2, 64);
			fReplayTime = StringToFloat(cHeaderExplode[1]);

			if (fTime > fReplayTime) {
				delete fReplay; return;
			}
		}
	}

	fReplay = OpenFile(cBuffer, "wb");
	fReplay.WriteLine("%i|%f", alFrames.Length, fTime);

	any[] aFrameData = new any[REPLAY_BUFFER_SIZE * sizeof(ReplayFrame)];
	int iFrameQueued;

	for (int i = 0; i < alFrames.Length; i++) {
		float fPos[3], fAngle[3], fVel[3];

		ReplayFrame rFrame; alFrames.GetArray(i, rFrame);
		rFrame.GetPos(fPos);
		rFrame.GetAngle(fAngle);
		rFrame.GetVel(fVel);

		for (int k = 0; k < 3; k++) {
			aFrameData[((iFrameQueued * sizeof(ReplayFrame)) + k)] = fPos[k];
			aFrameData[((iFrameQueued * sizeof(ReplayFrame)) + (k + 3))] = fAngle[k];
			aFrameData[((iFrameQueued * sizeof(ReplayFrame)) + (k + 6))] = fVel[k];

			if (k == 0) aFrameData[((iFrameQueued * sizeof(ReplayFrame)) + 9)] = rFrame.Buttons;
		}

		iFrameQueued++;

		if (i == (alFrames.Length - 1) || iFrameQueued == REPLAY_BUFFER_SIZE) {
			fReplay.Write(aFrameData, iFrameQueued * sizeof(ReplayFrame), 4);
			iFrameQueued = 0;
		}
	}

	delete alFrames; delete fReplay;
}

void Replay_BotAdd(int iClient) {
	for (int i = 0; i < BOTS_MAX; i++) {
		if (gB_Bot[i].Client == 0) {
			gB_Bot[i].Client = iClient;
			break;
		}
	}
}

Action Replay_Run(int iClient, int& iButtons, float fVel[3], float fAngle[3]) {
	if (Misc_CheckPlayer(iClient, PLAYER_INGAME)) {
		if (gP_Player[iClient].Record.StartTime <= 0.0) return;
		ReplayFrame rfFrame;
		float fPos[3];

		GetClientAbsOrigin(iClient, fPos);
		rfFrame.SetPos(fPos);
		rfFrame.SetAngle(fAngle);
		rfFrame.SetVel(fVel);
		rfFrame.Buttons = iButtons;

		gP_Player[iClient].Replay.Frames.Resize(gP_Player[iClient].Replay.Frame + 1);
		gP_Player[iClient].Replay.Frames.SetArray(gP_Player[iClient].Replay.Frame, rfFrame);
		gP_Player[iClient].Replay.Frame++;
	}
}
