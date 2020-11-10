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


# As ctlabs\sql_admin 

$db = get-sqldatabase -serverinstance localhost -name db
$db.tables.enumscript()
$o = new-object microsoft.sqlserver.management.smo.scriptingoptions
$o.scriptdata = $true
$d = Get-Date -Format "yyyy-MM-dd"
$db.tables.enumscript($o) | out-file c:\db_backups\$d.sql
ls c:\db_backups\$d.sql | compress-archive -destinationpath c:\db_backups\$d.sql.zip
rm -force c:\db_backups\$d.sql

