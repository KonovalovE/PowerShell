# ======================================================= =================================
#	FILE: bginfo-install.ps1
#
#	DESCRIPTION: Installation script for BGInfo
#
#	AUTHOR: Evgeny Konovalov
#	VERSION: 1.0
#	CREATED: 01/04/2023 18:00:00 PM
# ======================================================= =================================
#

# Устанавливаем переменные
$InstallFolder = 'C:\zabbix'
$ZabbixMSI = 'zabbix_agent2-6.2.7-windows-amd64-openssl.msi'
$ZabbixMSIPath = $PSScriptRoot + '\zabbix_agent2-6.2.7-windows-amd64-openssl.msi'
$InstallerLogPath = Join-Path $InstallFolder ('zabbix_agent2_installer_' + (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss") + '.log')

$LogType = 'file'
$LogFile = Join-Path $InstallFolder 'zabbix_agent2.log'
$Server = '10.1.1.21'
$ServerActive = $Server
$Timeout = 15
$HostName = $env:COMPUTERNAME
$TlsConnect = 'psk'
$TlsAccept = 'psk'
$TlsPskIdentity = "PSK01"
$TlsPskValue = "7b6033dc6ad0ed09f279b96b63a"
$EnablePath = 1

# Проверяем доступность MSI пакета
if (!(Test-Path $ZabbixMSIPath)){
    Write-Host "MSI пакет агента не обнаружен по этому пути: $ZabbixMSIPath" -ForegroundColor Red
    Break
}

#Проверяем существует ли папка Zabbix если нет то создаем ее
If (!(test-path -PathType container $InstallFolder))
{
      New-Item -ItemType Directory -Path $InstallFolder
}

# Подготавляваем конфигурационный фаил
Clear-Host
$ConfigResults = @()
$HashTable = [ordered]@{
	'Путь файла установки' = $ZabbixMSIPath
	'Путь установки агента' = $InstallFolder
	'Путь к логу установки' = $InstallerLogPath
	'Тип лога агента' = $LogType
	'Путь лога агента' = $LogFile
	'Сервер для пассивной проверки' = $Server
	'Сервер для активной проверки' = $ServerActive
	'Таймуат Агента' = $Timeout
	'Имя хоста' = $HostName
	'Протокол подключения' = $TlsConnect
	'Протокол ответа' = $TlsAccept
	'Имя PSK ключа' = $TlsPskIdentity
	'Ключ PSK' = if($TlsPskValue.Length -le 0) {'Ключ пустой'} else {'Ключ указан'}
	'Добавить в переменную PATH?' = $EnablePath
}
New-Object -TypeName PSObject -Property $HashTable

# CheckConfig
$Title    = 'Проверка настройки Агента'
$Question = 'Всё ли введено верно? Готовы продолжить?'

$Choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$Choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes','Продолжить тихую установку'))
$Choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No','Отменить установку и завершить работу скрипта'))

$Decision = $Host.UI.PromptForChoice($Title, $Question, $Choices, 1)
if ($decision -eq 0)
{
    Write-Host 'Запускаем установку' -ForegroundColor DarkGray

	# Запуск установки
	$InstallExitCode = $null
	$InstallExitCode = Start-Process -FilePath msiexec -ArgumentList "/l*v `"$InstallerLogPath`" /i `"$ZabbixMSIPath`" /qn LOGTYPE=`"$LogType`" LOGFILE=`"$LogFile`" SERVER=`"$Server`" SERVERACTIVE=`"$ServerActive`" TIMEOUT=`"$Timeout`" HOSTNAME=`"$HostName`" TLSCONNECT=`"$TlsConnect`" TLSACCEPT=`"$TlsAccept`" TLSPSKIDENTITY=`"$TlsPskIdentity`" TLSPSKVALUE=`"$ConvertSecureString`" INSTALLFOLDER=`"$InstallFolder`" ENABLEPATH=`"$EnablePath`"" -Wait -PassThru
	# Добавляем разрешающее правило в Firewall Windows
        New-NetFirewallRule -DisplayName "Разрешить порт 10050 для Zabbix" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 10050

    if ($InstallExitCode.ExitCode -ge 1)
    {
        Write-Host ("Код выхода: " + $InstallExitCode.ExitCode + ". Код выхода не ноль, проверь код здесь: https://docs.microsoft.com/ru-ru/windows/win32/msi/error-codes") -ForegroundColor Red
    }
    else
    {
        $ServiceStatus = Get-Service 'Zabbix Agent 2'
        Write-Host ("Код выхода: " + $InstallExitCode.ExitCode + ". Установка успешна, проверяем службу...") -ForegroundColor Green
        if ($ServiceStatus.Status -like 'StartPending')
        {
            while ($ServiceStatus.Status -like 'StartPending')
            {
                Write-Host "Служба запускается..." -ForegroundColor DarkGray
                $ServiceStatus = Get-Service 'Zabbix Agent 2'
                Start-Sleep -Seconds 1
            }
            Write-Host ("Статус службы: " + $ServiceStatus.Status + ", тип запуска: " + $ServiceStatus.StartType) -ForegroundColor Green
        }
        else
        {
            Write-Host ("Статус службы: " + $ServiceStatus.Status + ", тип запуска: " + $ServiceStatus.StartType)
        }
    }
}
else
{
    Write-Host 'Отмена. Скрипт завершён' -ForegroundColor Red
    Break
}