iwr https://go.microsoft.com/fwlink/?linkid=866664 -outfile mssql.exe
$cwd=get-location
./mssql.exe /action=download /quiet /mediapath=$cwd/mssql /mediatype=iso

$r = Mount-DiskImage (get-item mssql/*.iso) -passthru
$vol = ($r | get-volume).DriveLetter
$drive = Get-PSDrive -Name $vol
dismount-diskimage (get-item mssql/*.iso)

