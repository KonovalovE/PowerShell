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

Option Explicit
Dim fso, tsIn, str, MyStr
Set fso = CreateObject("Scripting.FileSystemObject")

' Проверяем установлен ли корпоративная версия AnyDesk Если установлен то берем нужные даные
If fso.FolderExists("C:\ProgramData\AnyDesk\ad_83578153_msi") Then
	Set tsIn = fso.OpenTextFile("C:\ProgramData\AnyDesk\ad_83578153_msi\system.conf",1)
		Do While Not tsIn.AtEndOfStream
		str = tsIn.ReadLine 'читаем построчно исходный файл
			If UBound(Split(str, "ad.anynet.id="))>0 Then 'ищем нужное значение
				MyStr = Mid(str, 14)
				echo MyStr 
			End If
		Loop
	tsIn.Close
	Set fso = Nothing
Else
	Set tsIn = fso.OpenTextFile("C:\ProgramData\AnyDesk\system.conf",1)
		Do While Not tsIn.AtEndOfStream
		str = tsIn.ReadLine 'читаем построчно исходный файл
			If UBound(Split(str, "ad.anynet.id="))>0 Then 'ищем нужное значение
				MyStr = Mid(str, 14)
				echo MyStr 
			End If
		Loop
	tsIn.Close
	Set fso = Nothing
End if



