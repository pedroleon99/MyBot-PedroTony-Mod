; #FUNCTION# ====================================================================================================================
; Name ..........: DropTrophy
; Description ...: Gets trophy count of village and compares to max trophy input. Will drop a troop and return home with no screenshot or gold wait.
; Syntax ........: DropTrophy()
; Parameters ....:
; Return values .: None
; Author ........: Code Monkey #666
; Modified ......: Promac (2015-04), KnowJack(2015-08), Hervidero (2016-01), MonkeyHunter (2016-01)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func DropTrophy()

	If $iChkTrophyRange = 1 Then
		If $DebugSetlog = 1 Then SetLog("Drop Trophy START", $COLOR_DEBUG)

		If $debugDeadBaseImage = 1 Then
			DirCreate($dirTempDebug & "\SkippedZombies\")
			DirCreate($dirTempDebug & "\Zombies\")
			setZombie()
		EndIf

		$iTrophyCurrent = getTrophyMainScreen($aTrophies[0], $aTrophies[1]) ; get OCR to read current Village Trophies
		If $DebugSetlog = 1 Then SetLog("Current Trophy Count: " & $iTrophyCurrent, $COLOR_DEBUG)
		If Number($iTrophyCurrent) <= Number($iTxtMaxTrophy) Then Return ; exit on trophy count to avoid other checks

		; Check if proper troop types avail during last checkarmycamp(), no need to call separately since droptrophy checked often
		Local $bHaveTroops = False
		For $i = 0 To UBound($aDTtroopsToBeUsed, 1) - 1
			If $aDTtroopsToBeUsed[$i][1] > 0 Then
				$bDisableDropTrophy = False
				$bHaveTroops = True
				If $DebugSetlog = 1 Then
					SetLog("Drop Trophy Found " & StringFormat("%3s", $aDTtroopsToBeUsed[$i][1]) & " " & $aDTtroopsToBeUsed[$i][0], $COLOR_DEBUG)
					ContinueLoop ; display all troop counts if debug flag set
				Else
					ExitLoop ; Finding 1 troop type is enough to use trophy drop, stop checking rest when no debug flag
				EndIf
			EndIf
		Next
		; if heroes enabled, check them and reset drop trophy disable
		If $iChkTrophyHeroes = 1 And $iHeroAvailable > 0 Then
			If $DebugSetlog = 1 Then SetLog("Drop Trophy Found Hero BK|AQ|GW: " & BitOR($iHeroAvailable, $HERO_KING) & "|" & BitOR($iHeroAvailable, $HERO_QUEEN) & "|" & BitOR($iHeroAvailable, $HERO_WARDEN), $COLOR_DEBUG)
			$bDisableDropTrophy = False
			$bHaveTroops = True
		EndIf
		If $bDisableDropTrophy = True Or $bHaveTroops = False Then ; troops available?
			Setlog("Drop Trophy temporarily disabled, missing proper troop type", $COLOR_ERROR)
			If $DebugSetlog = 1 Then SetLog("Drop Trophy END: No troops in $aDTtroopsToBeUsed array", $COLOR_DEBUG)
			Return
		EndIf

		Local $bDropSuccessful
		Local $iCount, $aRandomEdge, $iRandomXY
		Local Const $DTArmyPercent = Round(Int($itxtDTArmyMin) / 100, 2)
		Local $iTxtMaxTrophyNeedCheck = $iTxtMaxTrophy ; set trophy target to max trophy
		Local Const $iWaitTime = 3 ; wait time for base recheck during long drop times in minutes (3 minutes ~5-10 drop attacks)
		Local $iDateCalc, $sWaitToDate
		$sWaitToDate = _DateAdd('n', $iWaitTime, _NowCalc()) ; find delay time for checkbasequick
		If $DebugSetlog = 1 Then SetLog("ChkBaseQuick delay time= " & $sWaitToDate & " Now= " & _NowCalc() & " Diff= " & _DateDiff('s', _NowCalc(), $sWaitToDate), $COLOR_DEBUG)

		While Number($iTrophyCurrent) > Number($iTxtMaxTrophyNeedCheck)
			$iTrophyCurrent = getTrophyMainScreen($aTrophies[0], $aTrophies[1])
			SetLog("Trophy Count : " & $iTrophyCurrent, $COLOR_SUCCESS)
			If Number($iTrophyCurrent) > Number($iTxtMaxTrophyNeedCheck) Then
				Switch $iChkTrophyAtkDead ; Check for enough troops before starting base search to save search costs
					Case 1 ; If attack dead bases during trophy drop is enabled then make sure we have enough army troops
						If ($CurCamp <= ($TotalCamp * $DTArmyPercent)) Then ; check if current troops above setting
							SetLog("Drop Trophy is waiting for " & $itxtDTArmyMin & "% full army to also attack Deadbases.", $COLOR_ACTION)
							If $DebugSetlog = 1 Then SetLog("Drop Trophy END: Drop Trophy + Dead Base skipped, army < " & $itxtDTArmyMin & "%.", $COLOR_DEBUG)
							ExitLoop ; no troops then cycle again
						EndIf
					Case 0 ; no deadbase attacks enabled, then only 1 giant or hero needed to enable drop trophy to work
						If ($CurCamp < 5) And ($iChkTrophyHeroes = 1 And $iHeroAvailable = $HERO_NOHERO) Then
							SetLog("No troops available to use on Drop Trophy", $COLOR_ERROR)
							If $DebugSetlog = 1 Then SetLog("Drop Trophy END: Drop Trophy skipped, no army.", $COLOR_DEBUG)
							ExitLoop ; no troops then cycle again
						EndIf
				EndSwitch
				$iTxtMaxTrophyNeedCheck = $itxtdropTrophy ; already checked above max trophy, so set target to min trophy value
				SetLog("Dropping Trophies to " & $itxtdropTrophy, $COLOR_INFO)
				If _Sleep($iDelayDropTrophy4) Then ExitLoop
				$bDropSuccessful = True

				; measure enemy village
				If CheckZoomOut("VillageSearch", True, False) = False Then
					; check two more times, only required for snow theme (snow fall can make it easily fail), but don't hurt to keep it
					$i = 0
					Local $bMeasured
					Do
						$i += 1
						If _Sleep($iDelayPrepareSearch3) Then Return ; wait 500 ms
						ForceCaptureRegion()
						_CaptureRegion2()
						$bMeasured = CheckZoomOut("VillageSearch", $i < 2, False)
					Until $bMeasured = True Or $i >= 2
					If $bMeasured = False Then Return ; exit func
				EndIf

				PrepareSearch()
				If $OutOfGold = 1 Then Return ; Check flag for enough gold to search
				If $Restart = True Then Return

				If _Sleep($iDelayDropTrophy4) Then ExitLoop

				If $iChkTrophyAtkDead = 1 Then
					; Check for Dead Base on 1st search
					$iAimGold[$DB] = $iMinGold[$DB]
					$iAimElixir[$DB] = $iMinElixir[$DB]
					$iAimGoldPlusElixir[$DB] = $iMinGoldPlusElixir[$DB]
					$SearchCount = 0
					GetResources(False, $DT) ; no log, use $DT matchmode (DropThrophy)

					SetLog("Identification of your troops:", $COLOR_INFO)
					PrepareAttack($DT) ; ==== Troops :checks for type, slot, and quantity ===
					If $Restart = True Then Return

					Local $G = (Number($searchGold) >= Number($iAimGold[$DB]))
					Local $E = (Number($searchElixir) >= Number($iAimElixir[$DB]))
					Local $GPE = ((Number($searchElixir) + Number($searchGold)) >= Number($iAimGoldPlusElixir[$DB]))
					If $G = True And $E = True And $GPE = True Then
						SetLog("Found [G]:" & StringFormat("%7s", $searchGold) & " [E]:" & StringFormat("%7s", $searchElixir) & " [D]:" & StringFormat("%5s", $searchDark) & " [T]:" & StringFormat("%2s", $searchTrophy), $COLOR_BLACK, "Lucida Console", 7.5)
						If $debugDeadBaseImage = 1 Then setZombie()
						ForceCaptureRegion()
						_CaptureRegion2() ; take new capture for deadbase
						If checkDeadBase() Then
							; _BlockInputEx(0, "", "", $HWnD) ; block all keyboard keys

							SetLog("      " & "Dead Base Found on Drop Trophy!", $COLOR_SUCCESS, "Lucida Console", 7.5)
							Attack()
							$FirstStart = True ;reset barracks upon return when attacked a Dead Base with 70%~100% troops capacity
							ReturnHome($TakeLootSnapShot)
							$Is_ClientSyncError = False ; reset OOS flag to get new new army
							$Is_SearchLimit = False ; reset search limit flag to get new new army
							$Restart = True ; Set restart flag after dead base attack to ensure troops are trained
							If $DebugSetlog = 1 Then SetLog("Drop Trophy END: Dead Base was attacked, reset army and return to Village.", $COLOR_DEBUG)
							ExitLoop ; or Return, Will end function, no troops left to drop Trophies, will need to Train new Troops first
						Else
							SetLog("      " & "Not a Dead Base, resuming Drop Trophy.", $COLOR_BLACK, "Lucida Console", 7.5)
						EndIf
					EndIf
				Else
					; Normal Drop Trophy, no check for Dead Base
					$SearchCount = 0
					GetResources(False, $DT)

					SetLog("Identification of your troops:", $COLOR_INFO)
					PrepareAttack($DT) ; ==== Troops :checks for type, slot, and quantity ===
					If $Restart = True Then Return

				EndIf

				If _Sleep($iDelayDropTrophy4) Then ExitLoop

				; Drop a Hero or Troop
				If $iChkTrophyHeroes = 1 Then
				    ;a) identify heroes avaiables...
					$King = -1
					$Queen = -1
					$Warden = -1
					For $i = 0 To UBound($atkTroops) - 1
						If $atkTroops[$i][0] = $eKing Then
							$King = $i
						ElseIf $atkTroops[$i][0] = $eQueen Then
							$Queen = $i
						ElseIf $atkTroops[$i][0] = $eWarden Then
							$Warden = $i
						EndIf
					Next

				    ;b) calculate random drop point...
					$aRandomEdge = $Edges[Round(Random(0, 3))]
					$iRandomXY = Round(Random(0, 4))
					If $DebugSetlog = 1 Then Setlog("Hero Loc = " & $iRandomXY & ", X:Y= " & $aRandomEdge[$iRandomXY][0] & "|" & $aRandomEdge[$iRandomXY][1], $COLOR_DEBUG)


					;c) check if hero avaiable and drop according to priority
					If ($Queen <> -1 or $King <> -1 Or $Warden <> -1) Then
					   Local $DropHeroPriority
						If $iCmbTrophyHeroesPriority = 0 Then $DropHeroPriority = "QKW"
						If $iCmbTrophyHeroesPriority = 1 Then $DropHeroPriority = "QWK"
						If $iCmbTrophyHeroesPriority = 2 Then $DropHeroPriority = "KQW"
						If $iCmbTrophyHeroesPriority = 3 Then $DropHeroPriority = "KWQ"
						If $iCmbTrophyHeroesPriority = 4 Then $DropHeroPriority = "WKQ"
						If $iCmbTrophyHeroesPriority = 5 Then $DropHeroPriority = "WQK"

						Local $t
						For $i = 1 to 3
							$t = StringMid($DropHeroPriority, $i, 1)
							Switch $t
							Case "Q"
								If $Queen <> -1 Then
									SetTrophyLoss()
									SetLog("Deploying Queen", $COLOR_INFO)
									Click(GetXPosOfArmySlot($Queen, 68), 595 + $bottomOffsetY, 1, 0, "#0179") ;Select Queen
									If _Sleep($iDelayDropTrophy1) Then ExitLoop
									Click($aRandomEdge[$iRandomXY][0], $aRandomEdge[$iRandomXY][1], 1, 0, "#0180") ;Drop Queen
									If _Sleep($iDelayDropTrophy4) Then ExitLoop
									If IsAttackPage() Then SelectDropTroop($Queen) ;If Queen was not activated: Boost Queen before EndBattle to restore some health
									ReturnHome(False, False) ;Return home no screenshot
									If _Sleep($iDelayDropTrophy1) Then ExitLoop
									ExitLoop
								EndIf
							Case "K"
								If $King <> -1 Then
									SetTrophyLoss()
									SetLog("Deploying King", $COLOR_INFO)
									Click(GetXPosOfArmySlot($King, 68), 595 + $bottomOffsetY, 1, 0, "#0177") ;Select King
									If _Sleep($iDelayDropTrophy1) Then ExitLoop
									Click($aRandomEdge[$iRandomXY][0], $aRandomEdge[$iRandomXY][1], 1, 0, "#0178") ;Drop King
									If _Sleep($iDelayDropTrophy4) Then ExitLoop
									If IsAttackPage() Then SelectDropTroop($King) ;If King was not activated: Boost King before EndBattle to restore some health
									ReturnHome(False, False) ;Return home no screenshot
									If _Sleep($iDelayDropTrophy1) Then ExitLoop
									ExitLoop
								EndIf
							Case "W"
								If $Warden <> -1 Then
									SetTrophyLoss()
									SetLog("Deploying Warden", $COLOR_INFO)
									Click(GetXPosOfArmySlot($Warden, 68), 595 + $bottomOffsetY, 1, 0, "#0000") ;Select Warden
									If _Sleep($iDelayDropTrophy1) Then ExitLoop
									Click($aRandomEdge[$iRandomXY][0], $aRandomEdge[$iRandomXY][1], 1, 0, "#0000") ;Drop Warden
									If _Sleep($iDelayDropTrophy4) Then ExitLoop
									If IsAttackPage() Then SelectDropTroop($Warden) ;If Warden was not activated: Boost Warden before EndBattle to restore some health
									ReturnHome(False, False) ;Return home no screenshot
									If _Sleep($iDelayDropTrophy1) Then ExitLoop
									ExitLoop
								EndIf
							EndSwitch
						Next
					EndIf
				EndIf
				If ($Queen = -1 And $King = -1 And $Warden = -1) Or $iChkTrophyHeroes = 0 Then
					$aRandomEdge = $Edges[Round(Random(0, 3))]
					$iRandomXY = Round(Random(0, 4))
					If $DebugSetlog = 1 Then Setlog("Troop Loc = " & $iRandomXY & ", X:Y= " & $aRandomEdge[$iRandomXY][0] & "|" & $aRandomEdge[$iRandomXY][1], $COLOR_DEBUG)
					Select
						Case $atkTroops[0][0] = $eBarb
							Click($aRandomEdge[$iRandomXY][0], $aRandomEdge[$iRandomXY][1], 1, 0, "#0181") ;Drop one troop
							$CurBarb += 1
							$ArmyComp -= 1
							SetLog("Deploying 1 Barbarian", $COLOR_INFO)
						Case $atkTroops[0][0] = $eArch
							Click($aRandomEdge[$iRandomXY][0], $aRandomEdge[$iRandomXY][1], 1, 0, "#0182") ;Drop one troop
							$CurArch += 1
							$ArmyComp -= 1
							SetLog("Deploying 1 Archer", $COLOR_INFO)
						Case $atkTroops[0][0] = $eGiant
							Click($aRandomEdge[$iRandomXY][0], $aRandomEdge[$iRandomXY][1], 1, 0, "#0183") ;Drop one troop
							$CurGiant += 1
							$ArmyComp -= 5
							SetLog("Deploying 1 Giant", $COLOR_INFO)
						Case $atkTroops[0][0] = $eWall
							Click($aRandomEdge[$iRandomXY][0], $aRandomEdge[$iRandomXY][1], 1, 0, "#0184") ;Drop one troop
							$CurWall += 1
							$ArmyComp -= 2
							SetLog("Deploying 1 WallBreaker", $COLOR_INFO)
						Case $atkTroops[0][0] = $eGobl
							Click($aRandomEdge[$iRandomXY][0], $aRandomEdge[$iRandomXY][1], 1, 0, "#0185") ;Drop one troop
							$CurGobl += 1
							$ArmyComp -= 2
							SetLog("Deploying 1 Goblin", $COLOR_INFO)
						Case $atkTroops[0][0] = $eMini
							Click($aRandomEdge[$iRandomXY][0], $aRandomEdge[$iRandomXY][1], 1, 0, "#0186") ;Drop one troop
							$CurMini += 1
							$ArmyComp -= 2
							SetLog("Deploying 1 Minion", $COLOR_INFO)
						Case Else
							SetLog("You don?t have Tier 1/2 Troops, Stop dropping trophies.", $COLOR_INFO) ; preventing of deploying Tier 2/3 expensive troops
							$bDisableDropTrophy = True
							$bDropSuccessful = False
							ExitLoop
					EndSelect
					If $bDropSuccessful Then SetTrophyLoss()
					If _Sleep($iDelayDropTrophy1) Then ExitLoop
					ReturnHome(False, False) ;Return home no screenshot
					If _Sleep($iDelayDropTrophy1) Then ExitLoop
				EndIf
				$iDateCalc = _DateDiff('s', _NowCalc(), $sWaitToDate)
				If $DebugSetlog = 1 Then SetLog("ChkBaseQuick delay= " & $sWaitToDate & " Now= " & _NowCalc() & " Diff= " & $iDateCalc, $COLOR_DEBUG)
				If $iDateCalc <= 0 Then ; check length of time in drop trophy
					Setlog(" Checking base during long drop cycle", $COLOR_INFO)
					CheckBaseQuick() ; check base during long drop times
					$sWaitToDate = _DateAdd('n', $iWaitTime, _NowCalc()) ; create new delay date/time
					If $DebugSetlog = 1 Then SetLog("ChkBaseQuick new delay time= " & $sWaitToDate, $COLOR_DEBUG)
				EndIf
			Else
				SetLog("Trophy Drop Complete", $COLOR_INFO)
				If _Sleep(1000) Then Return                                           ; added lines
				VillageReport()                                                       ; added lines
				If _Sleep(1000) Then Return                                           ; added lines
				ProfileSwitch()                                                       ; added lines
				If _Sleep(5000) Then Return                                           ; added lines
			EndIf
		WEnd
		If $DebugSetlog = 1 Then SetLog("Drop Trophy END", $COLOR_DEBUG)
	Else
		If $DebugSetlog = 1 Then SetLog("Drop Trophy SKIP", $COLOR_DEBUG)
	EndIf

EndFunc   ;==>DropTrophy

Func SetTrophyLoss()
	Local $sTrophyLoss
	If _ColorCheck(_GetPixelColor(33, 148, True), Hex(0x000000, 6), 10) or _ColorCheck(_GetPixelColor(31, 144, True), Hex(0x282020, 6), 5) Then ; check if the village have a Dark Elixir Storage
		$sTrophyLoss = getTrophyLossAttackScreen(48, 214)
	Else
		$sTrophyLoss = getTrophyLossAttackScreen(48, 184)
	EndIf
	Setlog(" Trophy loss = " & $sTrophyLoss, $COLOR_DEBUG) ; record trophy loss
	$iDroppedTrophyCount -= Number($sTrophyLoss)
	UpdateStats()
EndFunc   ;==>SetTrophyLoss
