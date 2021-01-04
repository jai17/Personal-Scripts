/*
	Script file for opening directories
*/

; Open the shared drive
^#Numpad0::
{
	OpenDir("\\Server1\share","")
	return
}

OpenDir(path1,path2)
{
	Try
		Run %path1%%path2%
	Catch, tmp
	{}
}