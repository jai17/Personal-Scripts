/*
	Script file for running applications
*/

^+!c::
{
	OpenApp("C:\Program Files (x86)\National Instruments\CVI2019\","cvi.exe")
	return
}

^+!l::
{
	OpenApp("C:\Program Files (x86)\National Instruments\LabVIEW 2019\","LabVIEW.exe")
	return
}

^+!g::
{
	OpenApp("C:\Program Files\Git\","git-bash.exe")
	return
}

^+g::
{
	WinGetActiveTitle, repoName

	Run https://github.com/ArxtronTech/%repoName%
	
	return
}

OpenApp(path1, exename)
{
	Try
		IfWinExist, ahk_exe %exename%
		{
			WinActivateBottom, ahk_exe %exename%
		}
		Else
		{
			Run %path1%%exename%
		}
	Catch, tmp
	{}
}