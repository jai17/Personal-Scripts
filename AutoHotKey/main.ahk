/*
	Main script file which individual scripts run from
	- main.ahk is the only .ahk file that needs to be run
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2

#Include OpenDir.ahk
#Include OpenApp.ahk
#Include GenericCoding.ahk
#Include windowDragging.ahk
#Include LabWindows.ahk
#Include TestStand.ahk


; Minimize current window
^+m::
{
	Send {CtrlUp}{ShiftUp}
	Send !{Space}
	Sleep 100
	Send n
	return
}

; Suspend AutoHotKey (Is a toggle)
#ScrollLock::Suspend

; Reload script
~!r::
{
	Reload
	return
}

; Exit script
~!^s::
{
	ExitApp
	return
}
