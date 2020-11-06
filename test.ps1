[Net.ServicePointManager]::SecurityProtocol
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
[Net.ServicePointManager]::SecurityProtocol

Install-PackageProvider -Name NuGet -Force
Install-Module -Name SqlServerDsc -Force

iwr https://archive.org/download/en_sql_server_2017_enterprise_x64_dvd_11293666/en_sql_server_2017_enterprise_x64_dvd_11293666.iso -outfile C:\en_sql_server_2017_enterprise_x64_dvd_11293666.iso

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

