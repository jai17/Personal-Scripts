/*
	Script file for LabWindows programming setups
*/

#IfWinActive, .cws

::err::
send errmsg[ERRLEN]
return

; Generate doxygen comment block
#c::
{
	tmpClip := clipboard
	AutoTrim, Off
	clipboard =
	(
/***************************************************************************//*!
* \brief%A_Space%
*
* 
*******************************************************************************/`r`n
	)
	AutoTrim, On
	Send ^v

	Loop, 4
	{
		Send {Up}
	}
		
	Send {End}
	clipboard = %tmpClip%
	return
}

; NewLine within a doxygen comment block
+Enter::
{
	AutoTrim, Off
	clipboard = `r*%A_Space%
	AutoTrim, On
	Send ^v
	return
}

; Parameter line within a doxygen comment block
+p::
{
	AutoTrim, Off
	tmpClip := clipboard
	clipboard = *%A_Space%\param%A_Space%[in]
	AutoTrim, On
	Send ^v
	clipboard = %tmpClip%
	return
}

; Generate header include
#h::
{
	tmpClip := clipboard
	WinGetActiveTitle, headerName
	startPos := InStr(headerName, "[") + 1
	nameLength := InStr(headerName, "]") - startPos
	headerName := SubStr(headerName, startPos, nameLength)
	
	dotC := InStr(headerName, ".c")
	if dotC
		headerName := SubStr(headerName, 1, dotC) . "h"
	clipboard = `r`n#include "%headerName%"
	Send ^v
	clipboard = %tmpClip%
	return
}

; Generate cond/endcond block with region markers
#!c::
{
	tmpClip := clipboard
	clipboard =
	(
/// REGION START%A_Space%
//! \endcond

//! \cond
/// REGION END`r`n
	)
	Send ^v
	clipboard = %tmpClip%
	return
}
#IfWinActive,

