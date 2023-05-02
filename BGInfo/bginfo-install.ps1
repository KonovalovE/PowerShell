# ======================================================= =================================
#	FILE: bginfo-install.ps1
#
#	DESCRIPTION: Installation script for BGInfo
#
#	AUTHOR: Evgeny Konovalov
#	VERSION: 1.2
#	CREATED: 02/05/2023
# ======================================================= =================================
#
# Объявляем переменные

#$BGI_LOCATION = \\dc01\gpo$\BGinfo
$BGI_LOCATION = "D:\SCRIPTS\BGInfo" 
$BGI_FOLDER = "$Env:ProgramData\CNTEC\BGInfo"
$BGI_XML = "bgi_task.xml"
$BGI_CFG_CLIENT = "Client_template.bgi"
$BGI_CFG_SERVER = "Server_template.bgi"
$BGI_CFG_FILE = "Template.bgi"
$BGI_CFG = 
$BGI_EXE = "Bginfo64.exe"
$BGI_KEY_task = "BGInfo-task"
#
$BGI_RUN_old = "BGInfo"
$BGI_Task_old = "BGInfo_Refresh"
$BGI__PATH_old = "$Env:SystemRoot\BGINFO"

$BGI_RPATH = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$BGI_RKEYVALUE = "$BGI_FOLDER\Bginfo64.exe $BGI_FOLDER\$BGI_CFG_FILE /timer:0 /silent /nolicprompt"

If (-not(Test-Path $BGI_FOLDER)) {
   New-Item -Path $BGI_FOLDER -ItemType "directory"
   New-Item -Path $BGI_FOLDER"\Extensions" -ItemType "directory"
}

Copy-Item -Path $BGI_LOCATION"\Extensions\*" -Destination $BGI_FOLDER"\Extensions\" -Recurse -Force
Copy-Item $BGI_LOCATION"\"$BGI_EXE -Destination $BGI_FOLDER -Force

If (-not((Get-WmiObject -Class Win32_OperatingSystem -Property ProductType).ProductType -gt 1 -eq $True)){
   Copy-Item $BGI_LOCATION"\Templates\"$BGI_CFG_CLIENT -Destination $BGI_FOLDER"\"$BGI_CFG_FILE -Force
  }
Else { 
   Copy-Item $BGI_LOCATION"\Templates\"$BGI_CFG_SERVER -Destination $BGI_FOLDER"\"$BGI_CFG_FILE -Force 
}

# Проверяем существвует ли задание в автозагрузке если нет то создаем
If (-not((Get-Item $BGI_RPATH -EA Ignore).Property -contains $BGI_KEY_task -eq $True)){
   New-ItemProperty -Path $BGI_RPATH -Name $BGI_KEY_task -PropertyType "String" -Value $BGI_RKEYVALUE
}

# Проверяем существвует ли задание в диспетчере заданий если нет то создаем
If (-not(Get-ScheduledTask $BGI_KEY_task -ea 0)){
    # Копируем фаил задания
    Copy-Item $BGI_LOCATION"\"$BGI_XML -Destination $BGI_FOLDER -Force
    # Импортируем новое задания
    Register-ScheduledTask -xml (Get-Content $BGI_FOLDER"\"$BGI_XML | Out-String) -TaskName $BGI_KEY_task -TaskPath "\CNTEC\" –Force
    # Удаляем фаил задания
    Remove-item $BGI_FOLDER"\"$BGI_XML -force
    #
    Start-ScheduledTask -TaskName $BGI_KEY_task -TaskPath "\CNTEC\"
}



