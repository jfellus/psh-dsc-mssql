iwr https://go.microsoft.com/fwlink/?linkid=866664 -outfile mssql.exe
New-Item -Path C:\SQL2017 -ItemType Directory
$mountResult = Mount-DiskImage -ImagePath 'C:\en_sql_server_2017_enterprise_x64_dvd_11293666.iso' -PassThru
$volumeInfo = $mountResult | Get-Volume
$driveInfo = Get-PSDrive -Name $volumeInfo.DriveLetter
Copy-Item -Path ( Join-Path -Path $driveInfo.Root -ChildPath '*' ) -Destination C:\SQL2017\ -Recurse
Dismount-DiskImage $mountResult.ImagePath

Configuration SQLInstall {
    Import-DscResource -ModuleName SqlServerDsc

    node localhost {
          WindowsFeature 'NetFramework45' {
               Name   = 'NET-Framework-45-Core'
               Ensure = 'Present'
          }

          SqlSetup 'InstallDefaultInstance' {
               InstanceName        = 'MSSQLSERVER'
               Features            = 'SQLENGINE'
               SourcePath          = 'C:\SQL2017'
               SQLSysAdminAccounts = @('Administrators')
               DependsOn           = '[WindowsFeature]NetFramework45'
          }
     }
}


SQLInstall
Start-DscConfiguration -Path C:\SQLInstall -Wait -Force -Verbose

Test-DscConfiguration

Get-Service -Name *SQL*
