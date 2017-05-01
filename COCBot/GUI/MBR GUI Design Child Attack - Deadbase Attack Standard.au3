; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "Standard Attack" tab under the "Attack" tab under the "DeadBase" tab under the "Search & Attack" tab under the "Attack Plan" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hGUI_DEADBASE_ATTACK_STANDARD = 0
Global $g_hCmbStandardDropOrderDB = 0, $g_hCmbStandardDropSidesDB = 0, $g_hCmbStandardUnitDelayDB = 0, $g_hCmbStandardWaveDelayDB = 0, $g_hChkRandomSpeedAtkDB = 0, _
	   $g_hChkSmartAttackRedAreaDB = 0, $g_hCmbSmartDeployDB = 0, $g_hChkAttackNearGoldMineDB = 0, $g_hChkAttackNearElixirCollectorDB = 0, $g_hChkAttackNearDarkElixirDrillDB = 0

Global $g_hLblSmartDeployDB = 0, $g_hPicAttackNearDarkElixirDrillDB = 0

Func CreateAttackSearchDeadBaseStandard()

   $g_hGUI_DEADBASE_ATTACK_STANDARD = _GUICreate("", $_GUI_MAIN_WIDTH - 195, $g_iSizeHGrpTab4, 150, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_DEADBASE)
   ;GUISetBkColor($COLOR_WHITE, $g_hGUI_DEADBASE_ATTACK_STANDARD)

   Local $sTxtTip
   Local $x = 25, $y = 20
	   GUICtrlCreateGroup(GetTranslated(608,1,"Deploy"), $x - 20, $y - 20, 270, $g_iSizeHGrpTab4)
   ;	$x -= 15
		   GUICtrlCreateLabel(GetTranslated(608,2,"Troop Drop Order"),$x, $y, 143,18,$SS_LEFT)

		   $y += 15
		   $g_hCmbStandardDropOrderDB = GUICtrlCreateCombo("", $x, $y, 150, Default, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			   GUICtrlSetData(-1, GetTranslated(608,25,"Default(All Troops)")&"|Barch/BAM/BAG|GiBarch", GetTranslated(608,25, -1))
			   _GUICtrlSetTip(-1, GetTranslated(608,33,"Select a preset troop drop order.") & @CRLF & _
								  GetTranslated(608,34,"Each option deploys troops in a different order and in different waves") & @CRLF & _
								  GetTranslated(608,35,"Only the troops selected in the ""Only drop these troops"" option will be dropped"))

		   $y += 25
		   GUICtrlCreateLabel(GetTranslated(608,3, "Attack on")&":", $x, $y + 5, -1, -1)
		   $g_hCmbStandardDropSidesDB = GUICtrlCreateCombo("", $x + 55, $y, 120, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			   _GUICtrlSetTip(-1, GetTranslated(608,4, "Attack on a single side, penetrates through base") & @CRLF & _
								  GetTranslated(608,5, "Attack on two sides, penetrates through base") & @CRLF & _
								  GetTranslated(608,6, "Attack on three sides, gets outer and some inside of base"), _
								  GetTranslated(608,40, "Attack on Classic Four Fingers"), _
								  GetTranslated(671,42, "Attack on Multi Finger"), _
								  GetTranslated(608,7,"Select the No. of sides to attack on."))
			   GUICtrlSetData(-1, GetTranslated(608,8, "one side") & "|" & GetTranslated(608,9, "two sides") & "|" & _
								  GetTranslated(608,10, "three sides") & "|" & GetTranslated(608,11, "all sides equally") & "|" & GetTranslated(608,41, "Classic Four Fingers") & "|" & GetTranslated(671,43, "Multi Finger"), _
								  GetTranslated(608,11, -1))
			   GUICtrlSetOnEvent(-1, "Bridge") ; Uncheck SmartAttack Red Area when enable FourFinger to avoid conflict

		   $y += 25
		   GUICtrlCreateLabel(GetTranslated(608,12, "Delay Unit") & ":", $x, $y + 5, -1, -1)
			   $sTxtTip = GetTranslated(608,13, "This delays the deployment of troops, 1 (fast) = like a Bot, 10 (slow) = Like a Human.") & @CRLF & _
						  GetTranslated(608,14, "Random will make bot more varied and closer to a person.")
			   _GUICtrlSetTip(-1, $sTxtTip)
		   $g_hCmbStandardUnitDelayDB = GUICtrlCreateCombo("", $x + 55, $y, 36, 21, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			   _GUICtrlSetTip(-1, $sTxtTip)
			   GUICtrlSetData(-1, "1|2|3|4|5|6|7|8|9|10", "4")
		   GUICtrlCreateLabel(GetTranslated(608,15, "Wave") & ":", $x + 100, $y + 5, -1, -1)
			   _GUICtrlSetTip(-1, $sTxtTip)
		   $g_hCmbStandardWaveDelayDB = GUICtrlCreateCombo("", $x + 140, $y, 36, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			   _GUICtrlSetTip(-1, $sTxtTip)
			   GUICtrlSetData(-1, "1|2|3|4|5|6|7|8|9|10", "4")

		  $y += 22
		   $g_hChkRandomSpeedAtkDB = GUICtrlCreateCheckbox(GetTranslated(608,16, "Randomize delay for Units && Waves"), $x, $y, -1, -1)
			   _GUICtrlSetTip(-1, $sTxtTip)
			   GUICtrlSetOnEvent(-1, "chkRandomSpeedAtkDB")

		   $y +=22
		   $g_hChkSmartAttackRedAreaDB = GUICtrlCreateCheckbox(GetTranslated(608,17, "Use Smart Attack: Near Red Line."), $x, $y, -1, -1)
			   _GUICtrlSetTip(-1, GetTranslated(608,18, "Use Smart Attack to detect the outer 'Red Line' of the village to attack. And drop your troops close to it."))
			   GUICtrlSetState(-1, $GUI_CHECKED)
			   GUICtrlSetOnEvent(-1, "chkSmartAttackRedAreaDB")

		   $y += 22
		   $g_hLblSmartDeployDB = GUICtrlCreateLabel(GetTranslated(608,19, "Drop Type") & ":", $x, $y + 5, -1, -1)
			   $sTxtTip = GetTranslated(608,20, "Select the Deploy Mode for the waves of Troops.") & @CRLF & GetTranslated(608,21, "Type 1: Drop a single wave of troops on each side then switch troops, OR") & @CRLF & GetTranslated(608,22, "Type 2: Drop a full wave of all troops (e.g. giants, barbs and archers) on each side then switch sides.")
			   _GUICtrlSetTip(-1, $sTxtTip)
		   $g_hCmbSmartDeployDB = GUICtrlCreateCombo("", $x + 55, $y, 120, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			   GUICtrlSetData(-1, GetTranslated(608,23, "Sides, then Troops") & "|" & GetTranslated(608,24, "Troops, then Sides") , GetTranslated(608,23, -1))
			   _GUICtrlSetTip(-1, $sTxtTip)

		   $y += 26
		   $g_hChkAttackNearGoldMineDB = GUICtrlCreateCheckbox("", $x + 20, $y, 17, 17)
			   $sTxtTip = GetTranslated(608,26, "Drop troops near Gold Mines")
			   _GUICtrlSetTip(-1, $sTxtTip)
		   GUICtrlCreateIcon($g_sLibIconPath, $eIcnMine, $x + 40 , $y - 3 , 24, 24)
			   _GUICtrlSetTip(-1, $sTxtTip)

		   $x += 75
		   $g_hChkAttackNearElixirCollectorDB = GUICtrlCreateCheckbox("", $x, $y, 17, 17)
			   $sTxtTip = GetTranslated(608,27, "Drop troops near Elixir Collectors")
			   _GUICtrlSetTip(-1, $sTxtTip)
		   GUICtrlCreateIcon($g_sLibIconPath, $eIcnCollector, $x + 20 , $y - 3 , 24, 24)
			   _GUICtrlSetTip(-1, $sTxtTip)

		   $x += 55
		   $g_hChkAttackNearDarkElixirDrillDB = GUICtrlCreateCheckbox("", $x, $y, 17, 17)
			   $sTxtTip = GetTranslated(608,28, "Drop troops near Dark Elixir Drills")
			   _GUICtrlSetTip(-1, $sTxtTip)
		   $g_hPicAttackNearDarkElixirDrillDB = GUICtrlCreateIcon($g_sLibIconPath, $eIcnDrill, $x + 20 , $y - 3, 24, 24)
			   _GUICtrlSetTip(-1, $sTxtTip)

; ====================================================== MULTI FINGERS ======================================================
	$x  =  23
	$y += -67
	$LblDBMultiFinger = GUICtrlCreateLabel(GetTranslated(671,44, "Style:"), $x, $y + 3, 30, -1, $SS_RIGHT)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$CmbDBMultiFinger = GUICtrlCreateCombo("", $x + 56, $y, 122, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		$sTxtTip = GetTranslated(671,45, "Select a Multi-Fingers Attack Style.") & @CRLF & @CRLF & _
			GetTranslated(671,46, "* Random Mode, Chooses One Of The Attack Styles By Random.") & @CRLF & _
			GetTranslated(671,47, "* 4Fingers And 8Fingers Styles, Will Attack From All 4 Sides At Once.") & @CRLF & _
			GetTranslated(671,48, "* 4Fingers And 8Fingers Styles, Are Risky And Bot Like!")
	GUICtrlSetTip(-1, $sTxtTip)
	GUICtrlSetData(-1,  GetTranslated(671,49, "Random Mode") & "|" & _
						GetTranslated(671,50, "4Fingers Standard") & "|" & _
						GetTranslated(671,51, "4Fingers Spiral Left") & "|" & _
						GetTranslated(671,52, "4Fingers Spiral Right") & "|" & _
						GetTranslated(671,53, "8Fingers Blossom") & "|" & _
						GetTranslated(671,54, "8Fingers Implosion") & "|" & _
						GetTranslated(671,55, "8Fingers Spiral Left") & "|" & _
						GetTranslated(671,56, "8Fingers Spiral Right"), GetTranslated(671,50, "4Fingers Standard"))
	GUICtrlSetOnEvent(-1, "cmbDBMultiFinger")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

; ==================================================== UNIT WAVE FACTOR ====================================================
$x = 23
$y = 140

GUICtrlCreateGroup(GetTranslated(671, 100, "Settings"), $x, $y, 180, 105)

$y += 5
$ChkGiantSlot = GUICtrlCreateCheckbox(GetTranslated(671, 101, "GiantSlot"), $x+10, $y + 10, 89, 25)
	$sTxtTip = GetTranslated(671, 102, "perimeter (> = 12, recommended)") & @CRLF & _
			   GetTranslated(671, 103, "two points on each side (> = 8, recommended)")
	_GUICtrlSetTip(-1, $sTxtTip)
	GUICtrlSetOnEvent(-1, "ChkGiantSlot")
	GUICtrlSetState(-1, $GUI_UNCHECKED)
$CmbGiantSlot = GUICtrlCreateCombo("", $x + 99, $y + 12, 73, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1,  GetTranslated(671, 104, "Perimeter") & "|" & _
                    GetTranslated(671, 105, "TwoPoints"), GetTranslated(671, 104, "Perimeter"))
					GUICtrlSetOnEvent(-1, "CmbGiantSlot")
; ==========================================================================================================================
$y += 34
$ChkUnitFactor = GUICtrlCreateCheckbox(GetTranslated(671, 106, "Modify Unit Factor"), $x + 10, $y + 4, 130, 25)
	$sTxtTip = GetTranslated(671, 107, "Unit deploy delay = Unit setting x Unit Factor (millisecond)")
	_GUICtrlSetTip(-1, $sTxtTip)
	GUICtrlSetOnEvent(-1, "chkUnitFactor")
	GUICtrlSetState(-1, $GUI_UNCHECKED)

$TxtUnitFactor = GUICtrlCreateInput("10", $x + 140, $y + 6, 31, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	$sTxtTip = GetTranslated(671, 107, "Unit deploy delay = Unit setting x Unit Factor (millisecond)")
	_GUICtrlSetTip(-1, $sTxtTip)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetData(-1, 10)
	GUICtrlSetOnEvent(-1, "chkUnitFactor")
$y += 30
$ChkWaveFactor = GUICtrlCreateCheckbox(GetTranslated(671, 109, "Modify Wave Factor"), $x + 10, $y + 2, 130, 25)
	$sTxtTip = GetTranslated(671, 108, "Switch troop delay = Wave setting x Wave Factor (millisecond)")
	_GUICtrlSetTip(-1, $sTxtTip)
	GUICtrlSetOnEvent(-1, "chkWaveFactor")
	GUICtrlSetState(-1, $GUI_UNCHECKED)

$TxtWaveFactor = GUICtrlCreateInput("100", $x + 140, $y + 4, 31, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	$sTxtTip = GetTranslated(671, 108, "Switch troop delay = Wave setting x Wave Factor (millisecond)")
	_GUICtrlSetTip(-1, $sTxtTip)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetData(-1, 100)
	GUICtrlSetOnEvent(-1, "chkWaveFactor")
	   GUICtrlCreateGroup("", -99, -99, 1, 1)
 GUICtrlCreateGroup("", -99, -99, 1, 1)
EndFunc
