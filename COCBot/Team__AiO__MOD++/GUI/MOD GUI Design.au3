; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "MOD" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Team AiO & RK MOD++ (2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hGUI_MOD = 0
Global $g_hGUI_MOD_TAB = 0, $g_hGUI_MOD_TAB_ITEM1 = 0 , $g_hGUI_MOD_TAB_ITEM2 = 0 ,$g_hGUI_MOD_TAB_ITEM3 = 0 ,$g_hGUI_MOD_TAB_ITEM4 = 0 ,$g_hGUI_MOD_TAB_ITEM5 = 0

; Switch Account & Profiles
#include "MOD GUI Design - Profiles.au3"
#include "MOD GUI Design - ProfileStats.au3"

; Bot Humanization
#include "MOD GUI Design - BotHumanization.au3"

; Goblin XP
#include "MOD GUI Design - GoblinXP.au3"

; Forecast
#include "MOD GUI Design - Forecast.au3"

Func CreateMODTab()

	$g_hGUI_MOD = GUICreate("", $_GUI_MAIN_WIDTH - 20, $_GUI_MAIN_HEIGHT - 255, $_GUI_CHILD_LEFT, $_GUI_CHILD_TOP, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hFrmBotEx)

	CreateModProfiles()
	GUISwitch($g_hGUI_MOD)
	$g_hGUI_MOD_TAB = GUICtrlCreateTab(0, 0, $_GUI_MAIN_WIDTH - 20, $_GUI_MAIN_HEIGHT - 255, BitOR($TCS_SINGLELINE, $TCS_RIGHTJUSTIFY))
		$g_hGUI_MOD_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_01", "Profiles"))
		$g_hGUI_MOD_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_02", "Humanization"))
			HumanizationGUI()
		$g_hGUI_MOD_TAB_ITEM3 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_03", "Goblin XP"))
			GoblinXPGUI()
		$g_hGUI_MOD_TAB_ITEM4 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_04", "Stat's")) ; Has to be outside of the Last Control to hide
			$g_hLastControlToHide = GUICtrlCreateDummy()
			ReDim $g_aiControlPrevState[$g_hLastControlToHide + 1]
			CreateProfileStats()
		$g_hGUI_MOD_TAB_ITEM5 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_06_STab_05", "Forecast"))
			ForecastGUI()

	; needed to init the window now, like if it's a tab
	CreateDropOrderGUI()

	GUICtrlCreateTabItem("")
EndFunc   ;==>CreateMODTab
