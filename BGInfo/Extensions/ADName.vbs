'	DESCRIPTION: Special BGInfo Script 
'
'	AUTHOR: Evgeny Konovalov
'	E-MAIL: kev@modbon.ru
'	WWW: https://modbon.ru
'
'	VERSION: 1.1
'	CREATED: 02/05/2023
' 
' --------------------------------------------------------

' Определяем к какому контроллеру домена подключен пользователь
Set objWMISvc = GetObject( "winmgmts:\\.\root\cimv2" )
Set colItems = objWMISvc.ExecQuery( "Select * from Win32_ComputerSystem" )
For Each objItem in colItems
    strDomainName = objItem.Domain
    Echo strDomainName
Next