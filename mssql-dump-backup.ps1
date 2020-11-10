# this script is run as a scheduled task by ctlabs\sql_admin

# Dump the database "db" into c:\db_backups\<date>.sql.zip as a zipped SQL file
$db = get-sqldatabase -serverinstance localhost -name db
$db.tables.enumscript()
$o = new-object microsoft.sqlserver.management.smo.scriptingoptions
$o.scriptdata = $true
$d = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
$db.tables.enumscript($o) | out-file c:\db_backups\$d.sql
ls c:\db_backups\$d.sql | compress-archive -destinationpath c:\db_backups\$d.sql.zip
rm -force c:\db_backups\$d.sql

