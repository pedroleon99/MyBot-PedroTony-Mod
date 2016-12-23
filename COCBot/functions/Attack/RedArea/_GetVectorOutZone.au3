
; #FUNCTION# ====================================================================================================================
; Name ..........: _GetVectorOutZone
; Description ...:
; Syntax ........: _GetVectorOutZone($eVectorType)
; Parameters ....: $eVectorType         - an unknown value.
; Return values .: None
; Author ........: didipe
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: NoNo
; ===============================================================================================================================
Func _GetVectorOutZone($eVectorType)
	debugRedArea("_GetVectorOutZone IN")
	Local $vectorOutZone[0]
	Local $iSteps = 100
	Local $xMin, $yMin, $xMax, $yMax

	If ($eVectorType = $eVectorLeftTop) Then
		$xMin = $ExternalArea[0][0] + 2
		$yMin = $ExternalArea[0][1]
		$xMax = $ExternalArea[2][0]
		$yMax = $ExternalArea[2][1] + 2
	ElseIf ($eVectorType = $eVectorRightTop) Then
		$xMin = $ExternalArea[2][0]
		$yMin = $ExternalArea[2][1] + 2
		$xMax = $ExternalArea[1][0] - 2
		$yMax = $ExternalArea[1][1]
	ElseIf ($eVectorType = $eVectorLeftBottom) Then
		$xMin = $ExternalArea[0][0] + 2
		$yMin = $ExternalArea[0][1]
		$xMax = $ExternalArea[3][0]
		$yMax = $ExternalArea[3][1] - 2
	Else ; bottom right
		$xMin = $ExternalArea[3][0]
		$yMin = $ExternalArea[3][1] - 2
		$xMax = $ExternalArea[1][0] - 2
		$yMax = $ExternalArea[1][1]
	EndIf
	$xStep = ($xMax - $xMin) / $iSteps
	$yStep = ($yMax - $yMin) / $iSteps

	For $i = 0 To $iSteps
		Local $pixel = [Round($xMin + (($xMax - $xMin) * $i) / $iSteps), Round($yMin + (($yMax - $yMin) * $i) / $iSteps)]
		ReDim $vectorOutZone[UBound($vectorOutZone) + 1]
		$vectorOutZone[UBound($vectorOutZone) - 1] = $pixel
		$x += $xStep
		$y += $yStep
	Next

	Return $vectorOutZone
EndFunc   ;==>_GetVectorOutZone
