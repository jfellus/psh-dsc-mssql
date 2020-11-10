# on DC as ctlabs\administrator

New-ADUser -Name "SQLServer Service Account" -UserPrincipalName sql_svc `
        -SamAccountName sql_svc `
        -ServicePrincipalNames "SQL/iis.ctlabs.ct-square.com" `
        -AccountPassword (convertto-securestring "Passw0rd" -asplaintext -force) `
        -PasswordNeverExpires $True `
        -PassThru -erroraction stop | Enable-ADAccount

New-ADUser -Name "SQL Sysadmin" -UserPrincipalName sql_admin `
        -SamAccountName sql_admin `
        -AccountPassword (convertto-securestring "dumbPassw0rd" -asplaintext -force) `
        -PassThru -erroraction stop | Enable-ADAccount


# as .\administrator

iwr https://go.microsoft.com/fwlink/?linkid=866664 -outfile mssql.exe
$cwd=get-location
./mssql.exe /action=download /quiet /mediapath=$cwd/mssql /mediatype=iso

$r = Mount-DiskImage (get-item mssql/*.iso) -passthru
$drive = ($r | get-volume).DriveLetter
cd ${drive}:/
./setup /qs /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSYSADMINACCOUNTS="ctlabs\sql_admin" /SQLSVCACCOUNT="ctlabs\sql_svc" /SQLSVCPASSWORD="Passw0rd!" /IACCEPTSQLSERVERLICENSETERMS
dismount-diskimage (get-item mssql/*.iso)
rm -r
