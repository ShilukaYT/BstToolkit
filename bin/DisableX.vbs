sCurPath = CreateObject("Scripting.FileSystemObject").GetAbsolutePathName(".")
Set UAC = CreateObject("Shell.Application") 
UAC.ShellExecute sCurPath & "\DisableX.exe", "", "", "runas", 1