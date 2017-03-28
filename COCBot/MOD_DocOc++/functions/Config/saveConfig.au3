; #FUNCTION# ====================================================================================================================
; Name ..........: saveConfig.au3
; Description ...: Saves all of the GUI values to the config.ini and building.ini files
; Syntax ........: saveConfig()
; Parameters ....: NA
; Return values .: NA
; Author ........: NguyenAnhHD, Demen
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func SaveConfig_MOD()
	; <><><> DocOc++ Team MOD (NguyenAnhHD, Demen) <><><>
	ApplyConfig_MOD("Save")
	; Auto Hide (NguyenAnhHD) - Added by NguyenAnhHD
	IniWriteS($g_sProfileConfigPath, "general", "AutoHide", $ichkAutoHide ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "general", "AutoHideDelay", $ichkAutoHideDelay)


	; CoC Stats - Added by NguyenAnhHD
	IniWriteS($g_sProfileConfigPath, "Stats", "chkCoCStats", $ichkCoCStats ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "Stats", "txtAPIKey", $MyApiKey)

	; Check Collector Outside (McSlither) - Added by NguyenAnhHD
	IniWriteS($g_sProfileConfigPath, "search", "DBMeetCollOutside", $ichkDBMeetCollOutside ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "search", "DBMinCollOutsidePercent", $iDBMinCollOutsidePercent)

	; CSV Deploy Speed (Roro-Titi) - Added by NguyenAnhHD
	IniWriteS($g_sProfileConfigPath, "DeploymentSpeed", "DB", $g_iCmbCSVSpeed[$DB])
	IniWriteS($g_sProfileConfigPath, "DeploymentSpeed", "LB", $g_iCmbCSVSpeed[$LB])

	; Smart Upgrade (Roro-Titi) - Added by NguyenAnhHD
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkSmartUpgrade", $ichkSmartUpgrade ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreTH", $ichkIgnoreTH ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreKing", $ichkIgnoreKing ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreQueen", $ichkIgnoreQueen ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreWarden", $ichkIgnoreWarden ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreCC", $ichkIgnoreCC ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreLab", $ichkIgnoreLab ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreBarrack", $ichkIgnoreBarrack ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreDBarrack", $ichkIgnoreDBarrack ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreFactory", $ichkIgnoreFactory ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreDFactory", $ichkIgnoreDFactory ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreGColl", $ichkIgnoreGColl ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreEColl", $ichkIgnoreEColl ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "chkIgnoreDColl", $ichkIgnoreDColl ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "upgrade", "SmartMinGold", $iSmartMinGold)
	IniWriteS($g_sProfileConfigPath, "upgrade", "SmartMinElixir", $iSmartMinElixir)
	IniWriteS($g_sProfileConfigPath, "upgrade", "SmartMinDark", $iSmartMinDark)

	; Switch Profile (IceCube) - Added by NguyenAnhHD
	IniWriteS($g_sProfileConfigPath, "profiles", "chkGoldSwitchMax", $ichkGoldSwitchMax ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "profiles", "cmbGoldMaxProfile", $icmbGoldMaxProfile)
	IniWriteS($g_sProfileConfigPath, "profiles", "txtMaxGoldAmount", $itxtMaxGoldAmount)
	IniWriteS($g_sProfileConfigPath, "profiles", "chkGoldSwitchMin", $ichkGoldSwitchMin ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "profiles", "cmbGoldMinProfile", $icmbGoldMinProfile)
	IniWriteS($g_sProfileConfigPath, "profiles", "txtMinGoldAmount", $itxtMinGoldAmount)

	IniWriteS($g_sProfileConfigPath, "profiles", "chkElixirSwitchMax", $ichkElixirSwitchMax ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "profiles", "cmbElixirMaxProfile", $icmbElixirMaxProfile)
	IniWriteS($g_sProfileConfigPath, "profiles", "txtMaxElixirAmount", $itxtMaxElixirAmount)
	IniWriteS($g_sProfileConfigPath, "profiles", "chkElixirSwitchMin", $ichkElixirSwitchMin ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "profiles", "cmbElixirMinProfile", $icmbElixirMinProfile)
	IniWriteS($g_sProfileConfigPath, "profiles", "txtMinElixirAmount", $itxtMinElixirAmount)

	IniWriteS($g_sProfileConfigPath, "profiles", "chkDESwitchMax", $ichkDESwitchMax ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "profiles", "cmbDEMaxProfile", $icmbDEMaxProfile)
	IniWriteS($g_sProfileConfigPath, "profiles", "txtMaxDEAmount", $itxtMaxDEAmount)
	IniWriteS($g_sProfileConfigPath, "profiles", "chkDESwitchMin", $ichkDESwitchMin ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "profiles", "cmbDEMinProfile", $icmbDEMinProfile)
	IniWriteS($g_sProfileConfigPath, "profiles", "txtMinDEAmount", $itxtMinDEAmount)

	IniWriteS($g_sProfileConfigPath, "profiles", "chkTrophySwitchMax", $ichkTrophySwitchMax ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "profiles", "cmbTrophyMaxProfile", $icmbTrophyMaxProfile)
	IniWriteS($g_sProfileConfigPath, "profiles", "txtMaxTrophyAmount", $itxtMaxTrophyAmount)
	IniWriteS($g_sProfileConfigPath, "profiles", "chkTrophySwitchMin", $ichkTrophySwitchMin ? 1 : 0)
	IniWriteS($g_sProfileConfigPath, "profiles", "cmbTrophyMinProfile", $icmbTrophyMinProfile)
	IniWriteS($g_sProfileConfigPath, "profiles", "txtMinTrophyAmount", $itxtMinTrophyAmount)

	; SimpleTrain (Demen) - Added by Demen
	IniWriteS($g_sProfileConfigPath, "SimpleTrain", "Enable", $ichkSimpleTrain)
	IniWriteS($g_sProfileConfigPath, "SimpleTrain", "PreciseTroops", $ichkPreciseTroops)
	IniWriteS($g_sProfileConfigPath, "SimpleTrain", "ChkFillArcher", $ichkFillArcher)
	IniWriteS($g_sProfileConfigPath, "SimpleTrain", "FillArcher", $iFillArcher)
	IniWriteS($g_sProfileConfigPath, "SimpleTrain", "FillEQ", $ichkFillEQ)

	; Notify Bot Speep (Kychera) - Added By NguyenAnhHD
	IniWriteS($g_sProfileConfigPath, "notify", "AlertPBSleep", $g_bNotifyAlertBOTSleep ? 1 : 0)

	; Upgrade Management (MMHK) - Added by NguyenAnhHD
	IniWriteS($g_sProfileConfigPath, "upgrade", "UpdateNewUpgradesOnly", $g_ibUpdateNewUpgradesOnly ? 1 : 0)

EndFunc

Func SaveConfig_SwitchAcc($SwitchAcc_Style = False)
	; <><><> SwitchAcc_Demen_Style <><><>
	ApplyConfig_SwitchAcc("Save", $SwitchAcc_Style)
	If $SwitchAcc_Style = True Then IniWriteS($profile, "SwitchAcc_Demen_Style", "SwitchType", $iSwitchAccStyle)	; 1 = DocOc Style, 2 = Demen Style

	IniWriteS($profile, "SwitchAcc_Demen_Style", "Enable", $ichkSwitchAcc ? 1 : 0)
	IniWriteS($profile, "SwitchAcc_Demen_Style", "Pre-train", $ichkTrain ? 1 : 0)
	IniWriteS($profile, "SwitchAcc_Demen_Style", "Total Coc Account", $icmbTotalCoCAcc)		; 1 = 1 Acc, 2 = 2 Acc, etc.
	IniWriteS($profile, "SwitchAcc_Demen_Style", "Smart Switch", $ichkSmartSwitch ? 1 : 0)
	IniWriteS($profile, "SwitchAcc_Demen_Style", "Force Switch", $ichkForceSwitch ? 1 : 0)
	IniWriteS($profile, "SwitchAcc_Demen_Style", "Force Switch Search", $iForceSwitch)
	IniWriteS($profile, "SwitchAcc_Demen_Style", "Force Stay Donate", $ichkForceStayDonate? 1 : 0)
	IniWriteS($profile, "SwitchAcc_Demen_Style", "Sleep Combo", $ichkCloseTraining)			; 0 = No Sleep, 1 = Close CoC, 2 = Close Android
	For $i = 1 to 8
		IniWriteS($profile, "SwitchAcc_Demen_Style", "MatchProfileAcc." & $i, _GUICtrlCombobox_GetCurSel($cmbAccountNo[$i-1])+1)		; 1 = Acc 1, 2 = Acc 2, etc.
		IniWriteS($profile, "SwitchAcc_Demen_Style", "ProfileType." & $i, _GUICtrlCombobox_GetCurSel($cmbProfileType[$i-1])+1)			; 1 = Active, 2 = Donate, 3 = Idle
	Next
EndFunc

