iwr https://go.microsoft.com/fwlink/?linkid=866664 -outfile mssql.exe
$cwd=get-location
./mssql.exe /action=download /quiet /mediapath=$cwd/mssql /mediatype=iso

$r = Mount-DiskImage (get-item mssql/*.iso)


