; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design Child Mod - Forecast
; Description ...: This file Includes GUI Design
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

$hGUI_MODForecast = GUICreate("", $_GUI_MAIN_WIDTH - 28, $_GUI_MAIN_HEIGHT - 255 - 28, 5, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $hGUI_MOD)
GUISetBkColor($COLOR_WHITE, $hGUI_MODForecast)

GUISwitch($hGUI_MODForecast)

Global $grpForecast
Global $ieForecast

Local $xStart = 0, $yStart = 0
Local $x = $xStart + 5, $y = $yStart
	$ieForecast = GUICtrlCreateObj($oIE, $x , $y , 430, 310)

GUICtrlCreateGroup("", -99, -99, 1, 1)

$y += + 318
	$chkForecastBoost = GUICtrlCreateCheckbox(GetTranslated(701,1, "Boost When >"), $x, $y, -1, -1)
		$txtTip = GetTranslated(701,2, "Boost Barracks,Heroes, when the loot index.")
		GUICtrlSetTip(-1, $txtTip)
		GUICtrlSetOnEvent(-1, "chkForecastBoost")
	$txtForecastBoost = GUICtrlCreateInput("6.0", $x + 90, $y + 2, 30, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
		$txtTip = GetTranslated(701,3, "Minimum loot index for boosting.")
		GUICtrlSetLimit(-1, 3)
		GUICtrlSetTip(-1, $txtTip)
		_GUICtrlEdit_SetReadOnly(-1, True)
		GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1)

$y += - 27
	$chkForecastHopingSwitchMax = GUICtrlCreateCheckbox("", $x + 158, $y + 27, 13, 13)
			$txtTip = "" ; à renseigner
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetOnEvent(-1, "chkForecastHopingSwitchMax")
			GUICtrlCreateLabel(GetTranslated(701,4, "Switch to"), $x + 177, $y + 27, -1, -1)
	$cmbForecastHopingSwitchMax = GUICtrlCreateCombo("", $x + 225, $y + 25, 95, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			$txtTip = "" ; à renseigner
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetState(-1, $GUI_DISABLE)
	$lblForecastHopingSwitchMax = GUICtrlCreateLabel(GetTranslated(701,5, "When Index <"), $x + 325, $y + 28, -1, -1)
	$txtForecastHopingSwitchMax = GUICtrlCreateInput("2.5", $x + 400, $y + 26, 30, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
			$txtTip = "" ; à renseigner
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetLimit(-1, 3)
			GUICtrlSetData(-1, 2.5)
			GUICtrlSetTip(-1, $txtTip)
			_GUICtrlEdit_SetReadOnly(-1, True)
	$chkForecastHopingSwitchMin = GUICtrlCreateCheckbox("", $x + 158, $y + 55, 13, 13)
			$txtTip = "" ; à renseigner
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetOnEvent(-1, "chkForecastHopingSwitchMin")
			GUICtrlCreateLabel(GetTranslated(701,4, "Switch to"), $x + 177, $y + 55, -1, -1)
	$cmbForecastHopingSwitchMin = GUICtrlCreateCombo("", $x + 225, $y + 53, 95, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			$txtTip = "" ; à renseigner
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetState(-1, $GUI_DISABLE)
	$lblForecastHopingSwitchMin = GUICtrlCreateLabel(GetTranslated(701,5, "When Index >"), $x + 325, $y + 58, -1, -1)
	$txtForecastHopingSwitchMin = GUICtrlCreateInput("2.5", $x + 400, $y + 54, 30, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
			$txtTip = "" ; à renseigner
			GUICtrlSetTip(-1, $txtTip)
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetLimit(-1, 3)
			GUICtrlSetData(-1, 2.5)
			GUICtrlSetTip(-1, $txtTip)
			_GUICtrlEdit_SetReadOnly(-1, True)
GUICtrlCreateGroup("", -99, -99, 1, 1)
setupProfileComboBox()
GUICtrlCreateGroup("", -99, -99, 1, 1)
	$cmbSwLang = GUICtrlCreateCombo("", $x, $y + 50, 45, 45, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
             GUICtrlSetData(-1, "EN|RU|FR|DE|ES|IT|PT|IN", "EN")
GUICtrlCreateGroup("", -99, -99, 1, 1)
