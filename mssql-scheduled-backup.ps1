# As .\administrator

mkdir c:\db_backups

$acl = get-acl c:\db_backups
$n = new-object system.security.accesscontrol.filesystemaccessrule -argumentlist ctlabs\sql_svc, FullControl, allow
$acl.setaccessrule($n)
set-acl c:\db_backups $acl

$acl = get-acl c:\db_backups
$n = new-object system.security.accesscontrol.filesystemaccessrule -argumentlist ctlabs\sql_admin, FullControl, allow
$acl.setaccessrule($n)
set-acl c:\db_backups $acl

new-smbshare -name db_backups -path c:\db_backups
grant-smbshareaccess -name db_backups -accountname ctlabs\sql_svc -accessright full
revoke-smbshareaccess -name db_backups -accountname everyone

# Scheduled task 

cp ./mssql-dump-backup.ps1 c:\db_backup.ps1
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NonInteractive -NoLogo -NoProfile -File "C:\db_backup.ps1"'
$Trigger = New-ScheduledTaskTrigger -Once -At 3am
$Settings = New-ScheduledTaskSettingsSet
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
Register-ScheduledTask -TaskName 'My PowerShell Script' -InputObject $Task -User ctlabs\sql_admin -Password '123AZEqsd!'
