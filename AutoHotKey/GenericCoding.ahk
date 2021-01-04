/*
	Script file for general programming setups
*/

; Generate XML tag
#x::
{
	InputBox, varName, XML, XML Tag
	InputBox, varVal, XML, XML Value
	tmpClip := clipboard
	AutoTrim, Off
	clipboard =
	(
<%varName%>%varVal%</%varName%>
	)
	Sleep 1
	Send ^v
	Sleep 1
	Send {Enter}
	Sleep 1
	AutoTrim, On
	clipboard = %tmpClip%
	return
}

; Generate a single line comment block
#b::
{
	tmpClip := clipboard
	AutoTrim, Off
	clipboard =
	(
/* %A_YYYY%/%A_MM%/%A_DD% */
	)
	Send ^v
	Send {Left}{Left}
	AutoTrim, On
	clipboard = %tmpClip%
	return
}

; Set/Get function for a private global
; Default int
; Else include *[varType] (Ex. asdf*s for a string named asdf)
#g::
{
	varType := ""
	varNameCap := ""
	InputBox, varName, GetSet Generator, Enter Variable Name
	
	GetType(varName,varType)
	varNameCap := CapVarName(varName)
	
	tmpClip := clipboard
	
	#Include GenericCodingBigVars.ahk
	
	; Source
	If (varType == "")
	{
		clipboard = %varTypeInt%
	}
	Else If (varType == "s")
	{
		clipboard = %varTypeChar%
	}
	
	Sleep 1
	Send ^v
	Sleep 100
	
	; Header
	If (varType == "")
	{
		clipboard =
		(
`r`nvoid set%varNameCap%(int value);
int get%varNameCap%();
		)
	}
	Else If (varType == "s")
	{
		clipboard =
		(
`r`nvoid set%varNameCap%(char* value);
char* get%varNameCap%();
		)
	}
	
	MsgBox, , , Paste functions in header, 60
	clipboard = %tmpClip%
	return
}

GetType(ByRef varName, ByRef varType)
{
	If (Instr(varName, "*"))
	{
		StringRight, varType, varName, 1
		StringLeft, varName, varName, StrLen(varName) - 2
	}
}

CapVarName(varName)
{
	StringLeft, CapFirstLetter, varName, 1
	StringMid, tmpVarName, varName, 2
	StringUpper, CapFirstLetter, CapFirstLetter
	return CapFirstLetter . tmpVarName
}