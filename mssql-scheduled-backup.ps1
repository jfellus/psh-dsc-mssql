# As .\administrator

add-localgroupmember administrators ctlabs\sql_admin

mkdir c:\db_backups

$acl = get-acl c:\db_backups
$n = new-object system.security.accesscontrol.filesystemaccessrule("ctlabs\sql_svc", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.AddAccessRule($n)
set-acl c:\db_backups $acl

$acl = get-acl c:\db_backups
$n = new-object system.security.accesscontrol.filesystemaccessrule("ctlabs\sql_admin", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.AddAccessRule($n)
set-acl c:\db_backups $acl

new-smbshare -name db_backups -path c:\db_backups
grant-smbshareaccess -name db_backups -accountname ctlabs\sql_svc -accessright full -force
grant-smbshareaccess -name db_backups -accountname ctlabs\sql_admin -accessright full -force
revoke-smbshareaccess -name db_backups -accountname everyone

# Scheduled task 

cp ./mssql-dump-backup.ps1 c:\db_backup.ps1
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NonInteractive -ep bypass -NoLogo -NoProfile -File "C:\db_backup.ps1"'
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).addseconds(20) -repetitioninterval (New-Timespan -hours 1) -RepetitionDuration ([timeSpan]::maxvalue)
$Settings = New-ScheduledTaskSettingsSet
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
Register-ScheduledTask -TaskName 'My PowerShell Script' -InputObject $Task -User ctlabs\sql_admin -Password '123AZEqsd!'
