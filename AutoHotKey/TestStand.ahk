#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


WinGetActiveTitle, repoName

; Hotkey to try and set the enum data type in TestStand
#t::
{
	MouseGetPos, xpos, ypos
	InputBox, varName, Enum, Enum Name
	InputBox, enumVals, Enum Values, Enum Key Value Pairs `n(Comma Seperated)`nExample: XNET_PROTOCOL_CAN = 1, XNET_PROTOCOL_LIN = 2
	Click, right, xpos, ypos
	Send {Down 1}
	Send (Right 1}
	Send {Down 1}{Enter}
	clipboard = %varName%
	Send ^v
	ControlClick, WindowsForms10.Window.8.app.0.12ab327_r9_ad2
	return
}
;copy "%CVITARGETPATH%"  "..\..\DLLs\"