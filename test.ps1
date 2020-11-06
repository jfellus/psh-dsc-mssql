iwr https://go.microsoft.com/fwlink/?linkid=866664 -outfile mssql.exe
$cwd=get-location
./mssql.exe /action=download /quiet /mediapath=$cwd/mssql /mediatype=iso

$r = Mount-DiskImage (get-item mssql/*.iso) -passthru
$drive = ($r | get-volume).DriveLetter
cd ${drive}:/
./setup /qs /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSYSADMINACCOUNTS="ctlabs\sql_admin" /SQLSVCACCOUNT="ctlabs\sql_svc"  /IACCEPTSQLSERVERLICENSETERMS
dismount-diskimage (get-item mssql/*.iso)
rm -r
