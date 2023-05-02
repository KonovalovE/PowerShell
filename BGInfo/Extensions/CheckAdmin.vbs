Dim WshShell, colItems, objItem, objGroup, objUser
Dim strUser, strAdministratorsGroup, bAdmin
bAdmin = False

On Error Resume Next
Set WshShell = CreateObject("WScript.Shell")
strUser = WshShell.ExpandEnvironmentStrings("%Username%")

winmgt = "winmgmts:{impersonationLevel=impersonate}!//"
Set colItems = GetObject(winmgt).ExecQuery("Select Name from Win32_Group where SID='S-1-5-32-544'",,48)

For Each objItem in colItems
	strAdministratorsGroup = objItem.Name
Next

Set objGroup = GetObject("WinNT://./" & strAdministratorsGroup)

For Each objUser in objGroup.Members
    If objUser.Name = strUser Then
         bAdmin = True
         Exit For
    End If
Next
On Error Goto 0

If bAdmin Then
	Echo "Admin"
Else
	Echo "User"
End If