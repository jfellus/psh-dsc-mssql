# As .\administrator

# Add sql_admin to local admins => this allows to run scheduled task with this account
add-localgroupmember administrators ctlabs\sql_admin

# This folder will receive hourly SQL dumps of the 'db' database
mkdir c:\db_backups

# Allow the kerberoastable SQL_SVC account to read/write the dump dir (=> misconfiguration as it's unneeded)
$acl = get-acl c:\db_backups
$n = new-object system.security.accesscontrol.filesystemaccessrule("ctlabs\sql_svc", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.AddAccessRule($n)
set-acl c:\db_backups $acl

# Allow the kerberoastable SQL_ADMIN account to read/write the dump dir (=> good configuration)
$acl = get-acl c:\db_backups
$n = new-object system.security.accesscontrol.filesystemaccessrule("ctlabs\sql_admin", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.AddAccessRule($n)
set-acl c:\db_backups $acl

# Share the c:\db_backups and restrict fullaccess to ctlabs\sql_svc (misconfig) and ctlabs\sql_admin (normal config)
new-smbshare -name db_backups -path c:\db_backups
grant-smbshareaccess -name db_backups -accountname ctlabs\sql_svc -accessright full -force
grant-smbshareaccess -name db_backups -accountname ctlabs\sql_admin -accessright full -force
revoke-smbshareaccess -name db_backups -accountname everyone


# Schedule a backup every 1 hour
cp ./mssql-dump-backup.ps1 c:\db_backup.ps1
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NonInteractive -ep bypass -NoLogo -NoProfile -File "C:\db_backup.ps1"'
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).addseconds(20) -repetitioninterval (New-Timespan -hours 1) -RepetitionDuration ([timeSpan]::maxvalue)
$Settings = New-ScheduledTaskSettingsSet
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
Register-ScheduledTask -TaskName 'My PowerShell Script' -InputObject $Task -User ctlabs\sql_admin -Password '123AZEqsd!'
