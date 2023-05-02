On Error Resume Next

'Bind to Shell
Set objShell = WScript.CreateObject("WScript.Shell")

'Read Servers NetbiosName
'strComputer = objShell.RegRead("HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\ComputerName")

strComputer = "."
'wscript.echo strComputer

Set objWMIService = GetObject("winmgmts:" _
 & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colNicConfigs = objWMIService.ExecQuery _
 ("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
 
For Each objNicConfig In colNicConfigs
	If Not IsNull(objNicConfig.IPSubnet) Then
		For Each strDNSServer In objNicConfig.IPSubnet
			'Echo strDNSServer
			If InStr(strDNSServer,"64") = 0 Then Echo strDNSServer
		Next
	End If
Next