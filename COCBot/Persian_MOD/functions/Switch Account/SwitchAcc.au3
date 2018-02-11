; #FUNCTION# ====================================================================================================================
; Name ..........: SwitchAccount (#-12)
; Description ...: This file contains the Sequence that runs all MBR Bot
; Author ........: DEMEN (based on original idea of NDTHUAN)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; Return True or False if Switch Account is enabled and current profile in configured list
Func ProfileSwitchAccountEnabled()
	If Not $g_bChkSwitchAcc Or Not aquireSwitchAccountMutex() Then Return False
	Return SetError(0, 0, _ArraySearch($g_asProfileName, $g_sProfileCurrentName) >= 0)
EndFunc   ;==>ProfileSwitchAccountEnabled

; Return True or False if specified Profile is enabled for Switch Account and controlled by this bot instance
Func SwitchAccountEnabled($IdxOrProfilename = $g_sProfileCurrentName)
	Local $sProfile
	Local $iIdx
	If IsInt($IdxOrProfilename) Then
		$iIdx = $IdxOrProfilename
		$sProfile = $g_asProfileName[$iIdx]
	Else
		$sProfile = $IdxOrProfilename
		$iIdx = _ArraySearch($g_asProfileName, $sProfile)
	EndIf

	If Not $sProfile Or $iIdx < 0 Or Not $g_abAccountNo[$iIdx] Then
		; not in list or not enabled
		Return False
	EndIf

	; check if mutex is or can be aquired
	Return aquireProfileMutex($sProfile) <> 0
EndFunc   ;==>SwitchAccountEnabled

; retuns copy of $g_abAccountNo validated with SwitchAccountEnabled
Func AccountNoActive()
	Local $a[UBound($g_abAccountNo)]

	For $i = 0 To UBound($g_abAccountNo) - 1
		$a[$i] = SwitchAccountEnabled($i)
	Next

	Return $a
EndFunc   ;==>AccountNoActive

Func InitiateSwitchAcc() ; Checking profiles setup in Mybot, First matching CoC Acc with current profile, Reset all Timers relating to Switch Acc Mode.

	If Not ProfileSwitchAccountEnabled() Or Not $g_bInitiateSwitchAcc Then Return
	UpdateMultiStats()
	$g_iNextAccount = -1
	SetLog("Switch Account enable for " & $g_iTotalAcc + 1 & " accounts")
	SetSwitchAccLog("Initiating: " & $g_iTotalAcc + 1 & " acc", $COLOR_SUCCESS)

	;Local $iCurProfile = _GUICtrlComboBox_GetCurSel($g_hCmbProfile)
	For $i = 0 To $g_iTotalAcc
		; listing all accounts
		Local $sBotType = "Idle"
		If $g_abAccountNo[$i] = True Then
			If SwitchAccountEnabled($i) Then
				$sBotType = "Active"
				If $g_abDonateOnly[$i] = True Then $sBotType = "Donate"
				If $g_iNextAccount = -1 Then $g_iNextAccount = $i
				If $g_asProfileName[$i] = $g_sProfileCurrentName Then $g_iNextAccount = $i
			Else
				$sBotType = "Other bot"
			EndIf
		EndIf
		SetLog("  - Account [" & $i + 1 & "]: " & $g_asProfileName[$i] & " - " & $sBotType)
		SetSwitchAccLog("  - Acc. " & $i + 1 & ": " & $sBotType)

		; reset all timers
		$g_aiTimerStart[$i] = 0
		$g_aiRemainTrainTime[$i] = 0
		$g_aLabTimeAcc[$i] = 0
		$g_aLabTimerStart[$i] = 0
		$g_abPBActive[$i] = False
	Next
	$g_iCurAccount = $g_iNextAccount ; make sure no crash
	SetLog("Let's start with Account [" & $g_iNextAccount + 1 & "]")

	SwitchCOCAcc($g_iNextAccount)

EndFunc   ;==>InitiateSwitchAcc

Func CheckSwitchAcc()

	Local $abAccountNo = AccountNoActive()

	Local $aActiveAccount = _ArrayFindAll($abAccountNo, True)
	If UBound($aActiveAccount) <= 1 Then Return

	Local $aDonateAccount = _ArrayFindAll($g_abDonateOnly, True)
	Local $bReachAttackLimit = ($g_aiAttackedCountSwitch[$g_iCurAccount] <= $g_aiAttackedCountAcc[$g_iCurAccount] - 2)
	Local $bForceSwitch = False
	Local $nMinRemainTrain, $iWaitTime

	SetLog("Start Switch Account...!", $COLOR_INFO)
	If $g_iCommandStop = 0 Then ; Forced to switch when in halt attack mode
		SetLog("This account is in halt attack mode, switching to another account", $COLOR_ACTION)
		SetSwitchAccLog(" - HaltAttack, Force switch")
		$bForceSwitch = True
	ElseIf $g_bWaitForCCTroopSpell Then
		SetLog("Still waiting for CC Troops/Spells, switching to another Account", $COLOR_ACTION)
		SetSwitchAccLog(" - Waiting for CC")
		$bForceSwitch = True
	Else
		getArmyTroopTime(True, False) ; update $g_aiTimeTrain[0]

		$g_aiTimeTrain[1] = 0
		If IsWaitforSpellsActive() Then getArmySpellTime() ; update $g_aiTimeTrain[1]

		$g_aiTimeTrain[2] = 0
		If IsWaitforHeroesActive() Then CheckWaitHero() ; update $g_aiTimeTrain[2]

		ClickP($aAway, 1, 0, "#0000") ;Click Away

		$iWaitTime = _ArrayMax($g_aiTimeTrain)
		If $bReachAttackLimit And $iWaitTime <= 0 Then
			SetLog("This account has attacked twice in a row, switching to another account", $COLOR_INFO)
			SetSwitchAccLog(" - Reach attack limit: " & $g_aiAttackedCountAcc[$g_iCurAccount] - $g_aiAttackedCountSwitch[$g_iCurAccount])
			$bForceSwitch = True
		EndIf
	EndIf

	Local $sLogSkip = ""
	If Not $g_abDonateOnly[$g_iCurAccount] And $iWaitTime <= $g_iTrainTimeToSkip And Not $bForceSwitch Then
		If $iWaitTime > 0 Then $sLogSkip = " in " & Round($iWaitTime, 1) & "m"
		SetLog("Army is ready" & $sLogSkip & ", skip switching account", $COLOR_INFO)
		SetSwitchAccLog(" - Army is ready" & $sLogSkip)
		SetSwitchAccLog("Stay at [" & $g_iNextAccount + 1 & "]", $COLOR_SUCCESS)
		If _Sleep(500) Then Return
	Else
		$nMinRemainTrain = CheckTroopTimeAllAccount($bForceSwitch)

		If $g_bChkSmartSwitch = 1 Then ; Smart switch
			If $nMinRemainTrain <= 1 And Not $bForceSwitch Then ; Active (force switch shall give priority to Donate Account)
				If $g_bDebugSetlog Then SetDebugLog("Switch to or Stay at Active Account: " & $g_iNextAccount + 1, $COLOR_DEBUG)
				$g_iDonateSwitchCounter = 0
			Else
				If $g_iDonateSwitchCounter < UBound($aDonateAccount) Then ; Donate
					$g_iNextAccount = $aDonateAccount[$g_iDonateSwitchCounter]
					$g_iDonateSwitchCounter += 1
					If $g_bDebugSetlog Then SetDebugLog("Switch to Donate Account " & $g_iNextAccount + 1 & ". $g_iDonateSwitchCounter = " & $g_iDonateSwitchCounter, $COLOR_DEBUG)
					SetSwitchAccLog(" - Donate Acc [" & $g_iNextAccount + 1 & "]")
				Else ; Active
					$g_iDonateSwitchCounter = 0
					#cs					If $g_iCurAccount = $g_iNextAccount And $nMinRemainTrain > 3 Then ; Random
						Local $iRandomElement = Random(0, UBound($aActiveAccount) - 1, 1)
						$g_iNextAccount = $aActiveAccount[$iRandomElement]
						SetLog("Still " & Round($nMinRemainTrain, 2) & " min until army is ready. Switch to a random account: " & $g_iNextAccount + 1, $COLOR_INFO)
						SetSwitchAccLog(" - Random Acc [" & $g_iNextAccount + 1 & "]")
					#ce					EndIf
				EndIf
			EndIf
		Else ; Normal switch (continuous)
			$g_iNextAccount = $g_iCurAccount + 1
			If $g_iNextAccount > $g_iTotalAcc Then $g_iNextAccount = 0
			While $abAccountNo[$g_iNextAccount] = False
				$g_iNextAccount += 1
				If $g_iNextAccount > $g_iTotalAcc Then $g_iNextAccount = 0 ; avoid idle Account
			WEnd
		EndIf

		If $g_iNextAccount <> $g_iCurAccount Then
			If $g_bRequestTroopsEnable And $g_bCanRequestCC Then
				SetLog("Try Request troops before switching account", $COLOR_INFO)
				RequestCC(True)
			EndIf
			If Not IsMainPage() Then checkMainScreen()
			SwitchCOCAcc($g_iNextAccount)
		Else
			SetLog("Staying in this account")
			SetSwitchAccLog("Stay at [" & $g_iNextAccount + 1 & "]", $COLOR_SUCCESS)
		EndIf
	EndIf

EndFunc   ;==>CheckSwitchAcc

Func SwitchCOCAcc($NextAccount)
	Local $abAccountNo = AccountNoActive()
	If $NextAccount < 0 And $NextAccount > $g_iTotalAcc Then $NextAccount = _ArraySearch(True, $abAccountNo)
	Static $iRetry = 0
	Static $StartOnlineTime = 0
	Local $bResult

	SetLog("Switching to Account [" & $NextAccount + 1 & "]")

	If $g_bInitiateSwitchAcc Then
		$StartOnlineTime = 0
		$g_bInitiateSwitchAcc = False
	EndIf

	If $StartOnlineTime <> 0 And Not $g_bReMatchAcc Then SetSwitchAccLog(" - Acc " & $g_iCurAccount + 1 & ", online: " & Round(TimerDiff($StartOnlineTime) / 1000 / 60, 1) & "m")

	If IsMainPage() Then Click($aButtonSetting[0], $aButtonSetting[1], 1, 0, "Click Setting")
	If _Sleep(500) Then Return

	While 1

		Switch SwitchCOCAcc_DisconnectConnect($bResult)
			Case "OK"
				; all good
			Case "Error"
				; some problem
				ExitLoop
			Case "Exit"
				; no $g_bRunState
				Return
		EndSwitch

		Switch SwitchCOCAcc_ClickAccount($bResult, $NextAccount)
			Case "OK"
				; all good
			Case "Error"
				; some problem
				ExitLoop
			Case "Exit"
				; no $g_bRunState
				Return
		EndSwitch

		Switch SwitchCOCAcc_ConfirmAccount($bResult)
			Case "OK"
				; all good
			Case "Error"
				; some problem
				ExitLoop
			Case "Exit"
				; no $g_bRunState
				Return
		EndSwitch

		ExitLoop
	WEnd

	If _Sleep(500) Then Return
	If $bResult = True Then
		$iRetry = 0
		$g_bReMatchAcc = False
		$g_abNotNeedAllTime[0] = 1
		$g_abNotNeedAllTime[1] = 1
		$g_aiAttackedCountSwitch[$g_iCurAccount] = $g_aiAttackedCountAcc[$g_iCurAccount]
		$g_iCurAccount = $NextAccount
		If $g_sProfileCurrentName <> $g_asProfileName[$g_iNextAccount] Then
			If $g_iGuiMode = 1 Then
				; normal GUI Mode
				_GUICtrlComboBox_SetCurSel($g_hCmbProfile, _GUICtrlComboBox_FindStringExact($g_hCmbProfile, $g_asProfileName[$g_iNextAccount]))
				cmbProfile()
				DisableGUI_AfterLoadNewProfile()
			Else
				; mini or headless GUI Mode
				saveConfig()
				$g_sProfileCurrentName = $g_asProfileName[$g_iNextAccount]
				LoadProfile(False)
			EndIf
		EndIf
		$StartOnlineTime = TimerInit()
		SetSwitchAccLog("Switched to Acc [" & $NextAccount + 1 & "]", $COLOR_SUCCESS)
	Else
		$iRetry += 1
		$g_bReMatchAcc = True
		SetLog("Switching account failed!", $COLOR_ERROR)
		SetSwitchAccLog("Switching to Acc " & $NextAccount + 1 & " Failed!", $COLOR_ERROR)
		If $iRetry <= 3 Then
			ClickP($aAway, 3, 500)
			checkMainScreen()
		Else
			$iRetry = 0
			UniversalCloseWaitOpenCoC()
		EndIf
	EndIf
	waitMainScreen()
	If $g_bForceSinglePBLogoff Then $g_bGForcePBTUpdate = True
	runBot()

EndFunc   ;==>SwitchCOCAcc

Func SwitchCOCAcc_DisconnectConnect(ByRef $bResult)
	For $i = 0 To 20 ; Checking Green Connect Button continuously in 20sec
		If _ColorCheck(_GetPixelColor($aButtonConnected[0], $aButtonConnected[1], True), Hex($aButtonConnected[2], 6), $aButtonConnected[3]) Then ;	Green
			Click($aButtonConnected[0], $aButtonConnected[1], 2, 1000) ; Click Connect & Disconnect
			SetLog("   1. Click Connect & Disconnect")
			If _Sleep(200) Then Return "Exit"
			;ExitLoop
			Return "OK"
		ElseIf _ColorCheck(_GetPixelColor($aButtonDisconnected[0], $aButtonDisconnected[1], True), Hex($aButtonDisconnected[2], 6), $aButtonDisconnected[3]) Then ; Red
			Click($aButtonDisconnected[0], $aButtonDisconnected[1]) ; Click Disconnect
			SetLog("   1. Click Disconnect")
			If _Sleep(200) Then Return "Exit"
			;ExitLoop
			Return "OK"
		EndIf
		If $i = 20 Then
			$bResult = False
			;ExitLoop 2
			Return "Error"
		EndIf
		If _Sleep(900) Then Return "Exit"
	Next
	Return "" ; should never get here
EndFunc   ;==>SwitchCOCAcc_DisconnectConnect

Func SwitchCOCAcc_ClickAccount(ByRef $bResult, $NextAccount)
	Local $YCoord = Int(373.5 - $g_iTotalAcc * 36.5 + 73 * $NextAccount)
	For $i = 0 To 20 ; Checking Account List continuously in 20sec
		If _ColorCheck(_GetPixelColor($aListAccount[0], $aListAccount[1], True), Hex($aListAccount[2], 6), $aListAccount[3]) Then ;	Grey
			If _Sleep(600) Then Return "Exit"
			Click(383, $YCoord) ; Click Account
			SetLog("   2. Click Account [" & $NextAccount + 1 & "]")
			If _Sleep(600) Then Return "Exit"
			;ExitLoop
			Return "OK"
		ElseIf _ColorCheck(_GetPixelColor($aButtonDisconnected[0], $aButtonDisconnected[1], True), Hex($aButtonDisconnected[2], 6), $aButtonDisconnected[3]) And $i = 6 Then ; Red, double click did not work, try click Disconnect 1 more time
			If _Sleep(250) Then Return "Exit"
			Click($aButtonDisconnected[0], $aButtonDisconnected[1]) ; Click Disconnect
			SetLog("   1.1. Click Disconnect again")
			If _Sleep(600) Then Return "Exit"
		EndIf
		If $i = 20 Then
			$bResult = False
			;ExitLoop 2
			Return "Error"
		EndIf
		If _Sleep(900) Then Return "Exit"
	Next
	Return "" ; should never get here
EndFunc   ;==>SwitchCOCAcc_ClickAccount

Func SwitchCOCAcc_ConfirmAccount(ByRef $bResult, $iStep = 3)
	For $i = 0 To 30 ; Checking Load Button continuously in 30sec
		If _ColorCheck(_GetPixelColor($aButtonConnected[0], $aButtonConnected[1], True), Hex($aButtonConnected[2], 6), $aButtonConnected[3]) Then ; Green
			SetLog("Already in current account")
			ClickP($aAway, 2, 0, "#0167") ; Click Away
			If _Sleep(500) Then Return "Exit"
			$bResult = True
			;ExitLoop 2 ; no more step needed
			Return "OK"
		ElseIf _ColorCheck(_GetPixelColor($aButtonVillageLoad[0], $aButtonVillageLoad[1], True), Hex($aButtonVillageLoad[2], 6), $aButtonVillageLoad[3]) Then ; Load Button
			If _Sleep(250) Then Return "Exit"
			Click($aButtonVillageLoad[0], $aButtonVillageLoad[1], 1, 0, "Click Load") ; Click Load
			SetLog("   " & $iStep & ". Click Load button")

			For $j = 0 To 25 ; Checking Text Box and OKAY Button continuously in 25sec
				If _ColorCheck(_GetPixelColor($aButtonVillageOkay[0], $aButtonVillageOkay[1], True), Hex($aButtonVillageOkay[2], 6), $aButtonVillageOkay[3]) Then ; with modified texts.csv OKAY Button may be already green
					If _Sleep(250) Then Return "Exit"
					Click($aButtonVillageOkay[0], $aButtonVillageOkay[1], 1, 0, "Click OKAY")
					SetLog("   " & ($iStep + 1) & ". Click OKAY")
					SetLog("Please wait for loading CoC...!")
					$bResult = True
					;ExitLoop 2
					Return "OK"
				ElseIf _ColorCheck(_GetPixelColor($aTextBox[0], $aTextBox[1], True), Hex($aTextBox[2], 6), $aTextBox[3]) Then ; Pink (close icon)
					If _Sleep(250) Then Return "Exit"
					Click($aTextBox[0], $aTextBox[1], 1, 0, "Click Text box")
					SetLog("   " & ($iStep + 1) & ". Click text box & type CONFIRM")
					If _Sleep(500) Then Return "Exit"
					AndroidSendText("CONFIRM")
					ExitLoop
				EndIf
				If $j = 25 Then
					$bResult = False
					;ExitLoop 3
					Return "Error"
				EndIf
				If _Sleep(900) Then Return "Exit"
			Next

			For $k = 0 To 10 ; Checking OKAY Button continuously in 10sec
				If _ColorCheck(_GetPixelColor($aButtonVillageOkay[0], $aButtonVillageOkay[1], True), Hex($aButtonVillageOkay[2], 6), $aButtonVillageOkay[3]) Then
					If _Sleep(250) Then Return "Exit"
					Click($aButtonVillageOkay[0], $aButtonVillageOkay[1], 1, 0, "Click OKAY")
					SetLog("   " & ($iStep + 2) & ". Click OKAY")
					SetLog("Please wait for loading CoC...!")
					$bResult = True
					;ExitLoop 2
					Return "OK"
				EndIf
				If $k = 10 Then
					$bResult = False
					;ExitLoop 3
					Return "Error"
				EndIf
				If _Sleep(900) Then Return "Exit"
			Next

		EndIf
		If $i = 30 Then
			$bResult = False
			;ExitLoop 2
			Return "Error"
		EndIf
		If _Sleep(900) Then Return "Exit"
	Next
	Return "" ; should never get here
EndFunc   ;==>SwitchCOCAcc_ConfirmAccount

Func CheckWaitHero() ; get hero regen time remaining if enabled
	Local $iActiveHero
	Local $aHeroResult[3]
	$g_aiTimeTrain[2] = 0

	$aHeroResult = getArmyHeroTime("all")

	If @error Then
		SetLog("getArmyHeroTime return error, exit Check Hero's wait time!", $COLOR_ERROR)
		Return ; if error, then quit Check Hero's wait time
	EndIf

	If $aHeroResult = "" Then
		SetLog("You have no hero or bad TH level detection Pls manually locate TH", $COLOR_ERROR)
		Return
	EndIf

	If _Sleep($DELAYRESPOND) Then Return
	If $aHeroResult[0] > 0 Or $aHeroResult[1] > 0 Or $aHeroResult[2] > 0 Then ; check if hero is enabled to use/wait and set wait time
		For $pTroopType = $eKing To $eWarden ; check all 3 hero
			For $pMatchMode = $DB To $g_iModeCount - 1 ; check all attack modes
				$iActiveHero = -1
				If IsSpecialTroopToBeUsed($pMatchMode, $pTroopType) And _
						BitOR($g_aiAttackUseHeroes[$pMatchMode], $g_aiSearchHeroWaitEnable[$pMatchMode]) = $g_aiAttackUseHeroes[$pMatchMode] Then ; check if Hero enabled to wait
					$iActiveHero = $pTroopType - $eKing ; compute array offset to active hero
				EndIf
				If $iActiveHero <> -1 And $aHeroResult[$iActiveHero] > 0 Then ; valid time?
					; check exact time & existing time is less than new time
					If $g_aiTimeTrain[2] < $aHeroResult[$iActiveHero] Then
						$g_aiTimeTrain[2] = $aHeroResult[$iActiveHero] ; use exact time
					EndIf
				EndIf
			Next
			If _Sleep($DELAYRESPOND) Then Return
		Next
	EndIf

EndFunc   ;==>CheckWaitHero

Func CheckTroopTimeAllAccount($bExcludeCurrent = False) ; Return the minimum remain training time

	Local $abAccountNo = AccountNoActive()
	Local $iMinRemainTrain
	If $bExcludeCurrent = False Then
		$g_aiRemainTrainTime[$g_iCurAccount] = _ArrayMax($g_aiTimeTrain) ; remaintraintime of current account - in minutes
		$g_aiTimerStart[$g_iCurAccount] = TimerInit() ; start counting elapse of training time of current account
	EndIf

	SetSwitchAccLog(" - Train times: ")

	For $i = 0 To $g_iTotalAcc
		If $bExcludeCurrent And $i = $g_iCurAccount Then ContinueLoop
		If $abAccountNo[$i] And Not $g_abDonateOnly[$i] Then ;	Only check Active profiles
			If $g_aiTimerStart[$i] <> 0 Then
				$g_aiRemainTrainTime[$i] -= Round(TimerDiff($g_aiTimerStart[$i]) / 1000 / 60, 1) ;   updated remain train time of Active accounts
				$g_aiTimerStart[$i] = TimerInit() ; reset timer
				If $g_aiRemainTrainTime[$i] >= 0 Then
					SetLog("Account [" & $i + 1 & "]: " & $g_asProfileName[$i] & " will have full army in:" & $g_aiRemainTrainTime[$i] & " minutes")
				Else
					SetLog("Account [" & $i + 1 & "]: " & $g_asProfileName[$i] & " was ready:" & - $g_aiRemainTrainTime[$i] & " minutes ago")
				EndIf
				SetSwitchAccLog("    Acc " & $i + 1 & ": " & $g_aiRemainTrainTime[$i] & "m")
			Else ; for accounts first Run
				SetLog("Account [" & $i + 1 & "]: " & $g_asProfileName[$i] & " has not been read its remain train time")
				$g_aiRemainTrainTime[$i] = -999
				SetSwitchAccLog("    Acc " & $i + 1 & ": Unknown")
			EndIf
		EndIf
	Next

	$iMinRemainTrain = _ArrayMax($g_aiRemainTrainTime)
	For $i = 0 To $g_iTotalAcc
		If $bExcludeCurrent And $i = $g_iCurAccount Then ContinueLoop
		If $abAccountNo[$i] And Not $g_abDonateOnly[$i] Then ;	Only check Active profiles
			If $g_aiRemainTrainTime[$i] <= $iMinRemainTrain Then
				$iMinRemainTrain = $g_aiRemainTrainTime[$i]
				$g_iNextAccount = $i
			EndIf
		EndIf
	Next

	Return $iMinRemainTrain

EndFunc   ;==>CheckTroopTimeAllAccount

Func DisableGUI_AfterLoadNewProfile()
	$g_bGUIControlDisabled = True
	For $i = $g_hFirstControlToHide To $g_hLastControlToHide
		If IsAlwaysEnabledControl($i) Then ContinueLoop
		If $g_bNotifyPBEnable And $i = $g_hBtnNotifyDeleteMessages Then ContinueLoop ; exclude the DeleteAllMesages button when PushBullet is enabled
		If BitAND(GUICtrlGetState($i), $GUI_ENABLE) Then GUICtrlSetState($i, $GUI_DISABLE)
	Next
	ControlEnable("", "", $g_hCmbGUILanguage)
	$g_bGUIControlDisabled = False
EndFunc   ;==>DisableGUI_AfterLoadNewProfile

Func aquireSwitchAccountMutex($iSwitchAccountGroup = $g_iCmbSwitchAcc, $bReturnOnlyMutex = False, $bShowMsgBox = False)
	Local $sMsg = GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Msg_SwitchAccounts_InUse", "My Bot with Switch Accounts Group %s is already in use or active.", $iSwitchAccountGroup)
	If $iSwitchAccountGroup Then
		Local $hMutex_Profile = 0
		If $g_ahMutex_SwitchAccountsGroup[0] = $iSwitchAccountGroup And $g_ahMutex_SwitchAccountsGroup[1] Then
			$hMutex_Profile = $g_ahMutex_SwitchAccountsGroup[1]
		Else
			$hMutex_Profile = CreateMutex(StringReplace($g_sProfilePath & "\SwitchAccount.0" & $iSwitchAccountGroup, "\", "-"))
			$g_ahMutex_SwitchAccountsGroup[0] = $iSwitchAccountGroup
			$g_ahMutex_SwitchAccountsGroup[1] = $hMutex_Profile
		EndIf
		;SetDebugLog("Aquire Switch Accounts Group " & $iSwitchAccountGroup & " Mutex: " & $hMutex_Profile)
		If $bReturnOnlyMutex Then
			Return $hMutex_Profile
		EndIf

		If $hMutex_Profile = 0 Then
			; mutex already in use
			SetLog($sMsg, $COLOR_ERROR)
			;SetLog($sMsg, "Cannot switch to profile " & $sProfile, $COLOR_ERROR)
			If $bShowMsgBox Then
				MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION, $MB_TOPMOST), $g_sBotTitle, $sMsg)
			EndIf
		EndIf
		Return $hMutex_Profile <> 0
	EndIf
	Return False
EndFunc   ;==>aquireSwitchAccountMutex

Func releaseSwitchAccountMutex()
	If $g_ahMutex_SwitchAccountsGroup[1] Then
		;SetDebugLog("Release Switch Accounts Group " & $g_ahMutex_SwitchAccountsGroup[0] & " Mutex: " & $g_ahMutex_SwitchAccountsGroup[1])
		ReleaseMutex($g_ahMutex_SwitchAccountsGroup[1])
		$g_ahMutex_SwitchAccountsGroup[0] = 0
		$g_ahMutex_SwitchAccountsGroup[1] = 0
		Return True
	EndIf
	Return False
EndFunc   ;==>releaseSwitchAccountMutex

; Checks if Acc Account is shown and returns true if not or sucessfully switched, clicks first account if $bSelectFirst is true
Func CheckGoogleSelectAccount($bSelectFirst = True)

	Local $bResult = True

	If _ColorCheck(_GetPixelColor($aListAccount[0], $aListAccount[1], False), Hex($aListAccount[2], 6), $aListAccount[3]) Then ;	Grey

		SetDebugLog("Found open Google Accounts list pixel")

		; Account List check be there, validate with imgloc
		If UBound(decodeSingleCoord(FindImageInPlace("GoogleSelectAccount", $g_sImgGoogleSelectAccount, "180,400(90,300)", False))) > 1 Then
			; Google Account selection found
			SetLog("Found open Google Accounts list")

			Local $a = decodeSingleCoord(FindImageInPlace("GoogleSelectEmail", $g_sImgGoogleSelectEmail, "220,80(400,600)", False))
			If UBound($a) > 1 Then
				SetLog("   1. Click first Google Account")
				ClickP($a)
				Switch SwitchCOCAcc_ConfirmAccount($bResult, 2)
					Case "OK"
						; all good
					Case "Error"
						; some problem
					Case "Exit"
						; no $g_bRunState
						Return
				EndSwitch
			Else
				SetLog("Cannot find Google Account Email", $COLOR_ERROR)
				$bResult = False
			EndIf
		Else
			SetDebugLog("Open Google Accounts list not verified")
		EndIf
	EndIf

	Return $bResult
EndFunc   ;==>CheckGoogleSelectAccount

Func SwitchAccountCheckProfileInUse($sNewProfile)
	; now check if profile is used in another group
	Local $sInGroups = ""
	For $g = 1 To 8
		If $g = $g_iCmbSwitchAcc Then ContinueLoop
		; find group this profile belongs to: no switch profile config is saved in config.ini on purpose!
		Local $sSwitchAccFile = $g_sProfilePath & "\SwitchAccount.0" & $g & ".ini"
		If FileExists($sSwitchAccFile) = 0 Then ContinueLoop
		Local $sProfile
		Local $bEnabled
		For $i = 1 To Int(IniRead($sSwitchAccFile, "SwitchAccount", "TotalCocAccount", 0)) + 1
			$bEnabled = IniRead($sSwitchAccFile, "SwitchAccount", "Enable", "") = "1"
			If $bEnabled Then
				$bEnabled = IniRead($sSwitchAccFile, "SwitchAccount", "AccountNo." & $i, "") = "1"
				If $bEnabled Then
					$sProfile = IniRead($sSwitchAccFile, "SwitchAccount", "ProfileName." & $i, "")
					If $sProfile = $sNewProfile Then
						; found profile
						If $sInGroups <> "" Then $sInGroups &= ", "
						$sInGroups &= $g
					EndIf
				EndIf
			EndIf
		Next
	Next

	If $sInGroups Then
		If StringLen($sInGroups) > 2 Then
			$sInGroups = "used in groups " & $sInGroups
		Else
			$sInGroups = "used in group " & $sInGroups
		EndIf
	EndIf

	; test if profile can be aquired
	Local $iAquired = aquireProfileMutex($sNewProfile)
	If $iAquired Then
		If $iAquired = 1 Then
			; ok, release again
			releaseProfileMutex($sNewProfile)
		EndIf

		If $sInGroups Then
			; write to log
			SetLog("Profile " & $sNewProfile & " not active, but " & $sInGroups & "!", $COLOR_ERROR)
			SetSwitchAccLog($sNewProfile & " " & $sInGroups & "!", $COLOR_ERROR)
			Return False
		EndIf

		Return True
	Else
		; write to log
		If $sInGroups Then
			SetLog("Profile " & $sNewProfile & " active and " & $sInGroups & "!", $COLOR_ERROR)
			SetSwitchAccLog($sNewProfile & " active & " & $sInGroups & "!", $COLOR_ERROR)
		Else
			SetLog("Profile " & $sNewProfile & " active in another bot instance!", $COLOR_ERROR)
			SetSwitchAccLog($sNewProfile & " active!", $COLOR_ERROR)
		EndIf
		Return False
	EndIf
EndFunc   ;==>SwitchAccountCheckProfileInUse
