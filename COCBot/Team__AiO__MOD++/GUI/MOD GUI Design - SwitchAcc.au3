; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design Child Bot - Profiles Switch Account
; Description ...:
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Demen
; Modified ......: Team AiO MOD++ (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; SwitchAcc_Demen
Global $lblProfileNo[8], $lblProfileName[8], $cmbAccountNo[8], $cmbProfileType[8]
Global $chkSwitchAcc = 0, $chkTrain = 0, $cmbTotalAccount = 0, $radNormalSwitch = 0, $radSmartSwitch = 0, $chkUseTrainingClose = 0, $radCloseCoC = 0, $radCloseAndroid = 0, $cmbLocateAcc = 0
Global $g_hChkForceSwitch = 0, $g_txtForceSwitch = 0, $g_lblForceSwitch = 0, $g_hChkForceStayDonate = 0
Global $g_StartHideSwitchAcc = 0, $g_SecondHideSwitchAcc, $g_EndHideSwitchAcc = 0

Func CreateBotSwitchAcc()
	$ProfileList = _GUICtrlComboBox_GetListArray($g_hCmbProfile)
	$nTotalProfile = _Min(_GUICtrlComboBox_GetCount($g_hCmbProfile), 8)

	Local $sTxtTip = ""
	Local $x = 20, $y = 105

	$g_StartHideSwitchAcc = GUICtrlCreateDummy()
	GUICtrlCreateGroup(GetTranslatedFileIni("MOD GUI Design - Switch Account", "Group_01", "Switch Account Mode"), $x - 15, $y - 20, 203, 295)
	$chkSwitchAcc = GUICtrlCreateCheckbox(GetTranslatedFileIni("MOD GUI Design - Switch Account", "SwitchAcc", "Enable Switch Account"), $x - 5, $y, -1, -1)
	$sTxtTip = GetTranslatedFileIni("MOD GUI Design - Switch Account", "SwitchAcc_Info_01", "Switch to another account & profile when troop training time is >= 1 minutes") & _
			@CRLF & GetTranslatedFileIni("MOD GUI Design - Switch Account", "SwitchAcc_Info_02", "This function supports maximum 8 CoC accounts & 8 Bot profiles") & _
			@CRLF & GetTranslatedFileIni("MOD GUI Design - Switch Account", "SwitchAcc_Info_03", "Make sure to create sufficient Profiles equal to number of CoC Accounts")
	GUICtrlSetTip(-1, $sTxtTip)
	GUICtrlSetOnEvent(-1, "chkSwitchAcc")

	$chkTrain = GUICtrlCreateCheckbox(GetTranslatedFileIni("MOD GUI Design - Switch Account", "chkTrain", "Pre-train"), $x + 127, $y, -1, -1)
	$sTxtTip = GetTranslatedFileIni("MOD GUI Design - Switch Account", "chkTrain_Info_01", "Enable it to pre-train donated troops in quick train 3 before switch to next account.") & _
			@CRLF & GetTranslatedFileIni("MOD GUI Design - Switch Account", "chkTrain_Info_02", "This function requires use Quick Train, not Custom Train.") & _
			@CRLF & GetTranslatedFileIni("MOD GUI Design - Switch Account", "chkTrain_Info_03", "Use army 1 for farming troops, army 2 for spells and army 3 for donated troops.")
	GUICtrlSetTip(-1, $sTxtTip)

	GUICtrlCreateLabel(GetTranslatedFileIni("MOD GUI Design - Switch Account", "Label_01", "Total CoC Acc:"), $x + 10, $y + 29, -1, -1)
	$sTxtTip = GetTranslatedFileIni("MOD GUI Design - Switch Account", "Label_01_Info_01", "Choose number of CoC Accounts pre-logged")

	$cmbTotalAccount = GUICtrlCreateCombo("", $x + 95, $y + 25, 60, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "1 Acc." & "|" & "2 Acc." & "|" & "3 Acc." & "|" & "4 Acc." & "|" & "5 Acc." & "|" & "6 Acc." & "|" & "7 Acc." & "|" & "8 Acc.")
	GUICtrlSetTip(-1, $sTxtTip)

	$radNormalSwitch = GUICtrlCreateRadio(GetTranslatedFileIni("MOD GUI Design - Switch Account", "radNormalSwitch", "Normal switch"), $x + 10, $y + 55, -1, 16)
	GUICtrlSetTip(-1, GetTranslatedFileIni("MOD GUI Design - Switch Account", "radNormalSwitch_Info_01", "Switching accounts continously"))
	GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetOnEvent(-1, "radNormalSwitch")

	$radSmartSwitch = GUICtrlCreateRadio(GetTranslatedFileIni("MOD GUI Design - Switch Account", "radSmartSwitch", "Smart switch"), $x + 100, $y + 55, -1, 16)
	GUICtrlSetTip(-1, GetTranslatedFileIni("MOD GUI Design - Switch Account", "radSmartSwitch_Info_01", "Switch to account with the shortest remain training time"))
	GUICtrlSetOnEvent(-1, "radNormalSwitch")

	$y += 80
	$g_hChkForceSwitch = GUICtrlCreateCheckbox(GetTranslatedFileIni("MOD GUI Design - Switch Account", "ChkForceSwitch", "Force switch after:"), $x - 5, $y, -1, -1)
	GUICtrlSetTip(-1, GetTranslatedFileIni("MOD GUI Design - Switch Account", "ChkForceSwitch_Info_01", "Force the Bot to switch account when searching for too long") & _
			@CRLF & GetTranslatedFileIni("MOD GUI Design - Switch Account", "ChkForceSwitch_Info_02", "First switch to all donate accounts") & _
			@CRLF & GetTranslatedFileIni("MOD GUI Design - Switch Account", "ChkForceSwitch_Info_03", "Then switch to another active account if its army is ready"))
	GUICtrlSetOnEvent(-1, "chkForceSwitch")
	$g_txtForceSwitch = GUICtrlCreateInput("100", $x + 105, $y - 3 , 27, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetLimit(-1, 3)
	$g_lblForceSwitch = GUICtrlCreateLabel(GetTranslatedFileIni("MOD GUI Design - Switch Account", "lblForceSwitch", "searches"), $x + 135, $y, -1, -1)
	GUICtrlSetState(-1, $GUI_DISABLE)

	$y += 30
	$g_hChkForceStayDonate = GUICtrlCreateCheckbox(GetTranslatedFileIni("MOD GUI Design - Switch Account", "ChkForceStayDonate", "Stay on donation while training"), $x - 5, $y, -1, -1)
	GUICtrlSetTip(-1, GetTranslatedFileIni("MOD GUI Design - Switch Account", "ChkForceStayDonate_Info_01", "Stay at donate account until an active account is getting troops ready in 1 minute") & _
			@CRLF & GetTranslatedFileIni("MOD GUI Design - Switch Account", "ChkForceStayDonate_Info_02", "Circulate among the donate accounts if there are more than 1"))

	$y += 30
	$chkUseTrainingClose = GUICtrlCreateCheckbox(GetTranslatedFileIni("MOD GUI Design - Switch Account", "chkUseTrainingClose", "Combo Sleep after Switch Acc."), $x - 5, $y, -1, -1)
	$sTxtTip = GetTranslatedFileIni("MOD GUI Design - Switch Account", "chkUseTrainingClose_Info_01", "Close CoC combo with Switch Account when there is more than 3 mins remaining on training time of all accounts.")
	GUICtrlSetTip(-1, $sTxtTip)

	GUIStartGroup()
	$radCloseCoC = GUICtrlCreateRadio(GetTranslatedFileIni("MOD GUI Design - Switch Account", "radCloseCoC", "Close CoC"), $x + 10, $y + 30, -1, 16)
	GUICtrlSetState(-1, $GUI_CHECKED)

	$radCloseAndroid = GUICtrlCreateRadio(GetTranslatedFileIni("MOD GUI Design - Switch Account", "radCloseAndroid", "Close Android"), $x + 100, $y + 30, -1, 16)

	$y += 60
	GUICtrlCreateLabel(GetTranslatedFileIni("MOD GUI Design - Switch Account", "Label_02", "Manually locate account coordinates"), $x, $y, -1, -1)

	$cmbLocateAcc = GUICtrlCreateCombo("", $x + 15, $y + 21, 60, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	$sTxtTip = GetTranslatedFileIni("MOD GUI Design - Switch Account", "cmbLocateAcc", "Select CoC Account to manually locate its y-coordinate")
	GUICtrlSetData(-1, "Acc. 1" & "|" & "Acc. 2" & "|" & "Acc. 3" & "|" & "Acc. 4" & "|" & "Acc. 5" & "|" & "Acc. 6" & "|" & "Acc. 7" & "|" & "Acc. 8", "Acc. 1")
	GUICtrlSetTip(-1, $sTxtTip)

	GUICtrlCreateButton(GetTranslatedFileIni("MOD GUI Design - Switch Account", "BtnLocate", "Locate"), $x + 80, $y + 20, 50, 23)
	GUICtrlSetTip(-1, GetTranslatedFileIni("MOD GUI Design - Switch Account", "BtnLocate_Info_01", "Starting locate your CoC Account"))
	GUICtrlSetOnEvent(-1, "btnLocateAcc")

	GUICtrlCreateButton(GetTranslatedFileIni("MOD GUI Design - Switch Account", "BtnClearAll", "Clear All"), $x + 135, $y + 20, 50, 23, $BS_MULTILINE)
	GUICtrlSetTip(-1, GetTranslatedFileIni("MOD GUI Design - Switch Account", "BtnClearAll_Info_01", "Clear location data of all accounts"))
	GUICtrlSetOnEvent(-1, "btnClearAccLocation")

	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Profiles & Account matching
	Local $x = 230, $y = 105

	GUICtrlCreateGroup(GetTranslatedFileIni("MOD GUI Design - Switch Account", "Group_02", "Profiles"), $x - 20, $y - 20, 225, 295)
	GUICtrlCreateButton(GetTranslatedFileIni("MOD GUI Design - Switch Account", "BtnUpdateProfiles", "Update Profiles"), $x + 40, $y - 5, -1, 25)
	GUICtrlSetOnEvent(-1, "g_btnUpdateProfile")
	GUICtrlCreateButton(GetTranslatedFileIni("MOD GUI Design - Switch Account", "BtnClearProfiles", "Clear Profiles"), $x + 130, $y - 5, -1, 25)
	GUICtrlSetOnEvent(-1, "btnClearProfile")

	$y += 35
	GUICtrlCreateLabel(GetTranslatedFileIni("MOD GUI Design - Switch Account", "Label_03", "No."), $x - 10, $y, 15, -1, $SS_CENTER)
	GUICtrlCreateLabel(GetTranslatedFileIni("MOD GUI Design - Switch Account", "Label_04", "Profile Name"), $x + 10, $y, 90, -1, $SS_CENTER)
	GUICtrlCreateLabel(GetTranslatedFileIni("MOD GUI Design - Switch Account", "Label_05", "Acc."), $x + 105, $y, 30, -1, $SS_CENTER)
	GUICtrlCreateLabel(GetTranslatedFileIni("MOD GUI Design - Switch Account", "Label_06", "Bot Type"), $x + 140, $y, 60, -1, $SS_CENTER)

	$y += 20
	GUICtrlCreateGraphic($x - 10, $y, 205, 1, $SS_GRAYRECT)
	GUICtrlCreateGraphic($x + 10, $y - 25, 1, 40, $SS_GRAYRECT)

	$g_SecondHideSwitchAcc = GUICtrlCreateDummy()
	$y += 10
	For $i = 0 To 7
		$lblProfileNo[$i] = GUICtrlCreateLabel($i + 1 & ".", $x - 10, $y + 4 + ($i) * 25, 15, 18, $SS_CENTER)
		GUICtrlCreateGraphic($x + 10, $y + ($i) * 25, 1, 25, $SS_GRAYRECT)

		$lblProfileName[$i] = GUICtrlCreateLabel(GetTranslatedFileIni("MOD GUI Design - Switch Account", "lblProfileName", "Village Name"), $x + 10, $y + 4 + ($i) * 25, 90, 18, $SS_CENTER)
		If $i <= $nTotalProfile - 1 Then GUICtrlSetData(-1, $ProfileList[$i + 1])
		$cmbAccountNo[$i] = GUICtrlCreateCombo("", $x + 105, $y + ($i) * 25, 30, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		$sTxtTip = GetTranslatedFileIni("MOD GUI Design - Switch Account", "lblProfileName_Info_01", "Select the index of CoC Account to match with this Profile")
		GUICtrlSetData(-1, "1" & "|" & "2" & "|" & "3" & "|" & "4" & "|" & "5" & "|" & "6" & "|" & "7" & "|" & "8")
		GUICtrlSetTip(-1, $sTxtTip)
		GUICtrlSetOnEvent(-1, "cmbMatchProfileAcc" & $i + 1)
		$cmbProfileType[$i] = GUICtrlCreateCombo("", $x + 140, $y + ($i) * 25, 60, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		$sTxtTip = GetTranslatedFileIni("MOD GUI Design - Switch Account", "cmbProfileType", "Define the botting type of this profile")
		GUICtrlSetData(-1, GetTranslatedFileIni("MOD GUI Design - Switch Account", "cmbProfileType_Info_01", "Active") & "|" & GetTranslatedFileIni("MOD GUI Design - Switch Account", "cmbProfileType_Info_02", "Donate") & "|" & GetTranslatedFileIni("MOD GUI Design - Switch Account", "cmbProfileType_Info_03", "Idle"))
		GUICtrlSetTip(-1, $sTxtTip)
		If $i > $nTotalProfile - 1 Then
			For $j = $lblProfileNo[$i] To $cmbProfileType[$i]
				GUICtrlSetState($j, $GUI_HIDE)
			Next
		EndIf
	Next
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$g_EndHideSwitchAcc = GUICtrlCreateDummy()

EndFunc   ;==>CreateBotSwitchAcc


