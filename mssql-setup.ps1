# --- on DC as ctlabs\administrator ---

# Create the MSSQLServer service account in the domain
New-ADUser -Name "SQLServer Service Account" -UserPrincipalName sql_svc `
        -SamAccountName sql_svc `
        -ServicePrincipalNames "SQL/iis.ctlabs.ct-square.com" `
        -AccountPassword (convertto-securestring "Passw0rd!" -asplaintext -force) `
        -PasswordNeverExpires $True `
        -PassThru -erroraction stop | Enable-ADAccount

# Create a MSSQLServer sysadmin account in the domain
New-ADUser -Name "SQL Sysadmin" -UserPrincipalName sql_admin `
        -SamAccountName sql_admin `
        -AccountPassword (convertto-securestring "dumbPassw0rd" -asplaintext -force) `
        -PassThru -erroraction stop | Enable-ADAccount



# --- on win2016-2 as .\administrator ----

# Download the mssql installer
iwr https://go.microsoft.com/fwlink/?linkid=866664 -outfile mssql.exe
$cwd=get-location
./mssql.exe /action=download /quiet /mediapath=$cwd/mssql /mediatype=iso

# Mount the installer image
$r = Mount-DiskImage (get-item mssql/*.iso) -passthru
$drive = ($r | get-volume).DriveLetter

# Install
cd ${drive}:/
./setup /qs /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSYSADMINACCOUNTS="ctlabs\sql_admin" /SQLSVCACCOUNT="ctlabs\sql_svc" /SQLSVCPASSWORD="Passw0rd!" /IACCEPTSQLSERVERLICENSETERMS


# Cleanup
dismount-diskimage (get-item mssql/*.iso)
rm -r
