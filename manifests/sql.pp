class sql::standalone (
  
) {

  require temp::folder

    dsc_windowsfeature { "NET-Framework-45-Core":
        dsc_ensure => "Present",
        dsc_name => "NET-Framework-45-Core",
    }

    file { 'downloadsqlinstalleriso':
      ensure => present,
      path => 'c:\\temp\\SQLServer2019-x64-ENU.iso',
      source => 'https://dh2euwstodevinfinf01.blob.core.windows.net/temp/iso/SQLServer2019-x64-ENU.iso',
    }

    file { 'downloadsqlssmsinstaller':
      ensure => present,
      path => 'c:\\temp\\SSMS-Setup-ENU.exe',
      source => 'https://download.microsoft.com/download/f/e/b/feb0e6be-21ce-4f98-abee-d74065e32d0a/SSMS-Setup-ENU.exe',
    }

    mount_iso { 'C:\\temp\\SQLServer2019-x64-ENU.iso':
      subscribe => File['downloadsqlinstalleriso'],
      drive_letter => 'S',
    }

    dsc_sqlsetup { 'InstallDefaultInstance':
      dsc_instancename        => 'MSSQLSERVER',
      dsc_features            => 'SQLENGINE',
      dsc_sourcepath          => 'S:\\',
      dsc_sqlsysadminaccounts => 'Administrators',
      subscribe               => [Dsc_windowsfeature['NET-Framework-45-Core'], Mount_iso['C:\\temp\\SQLServer2019-x64-ENU.iso']],
    }

    dsc_sqlwindowsfirewall { 'InstallDefaultInstancefw':
        subscribe => Dsc_sqlsetup['InstallDefaultInstance'],
        dsc_sourcepath => 'S:\\',
        dsc_instancename => 'MSSQLSERVER',
        dsc_features => 'SQLENGINE',
    }

    exec { 'installssms':
      command     => 'start-process "c:\temp\SSMS-Setup-ENU.exe" -ArgumentList "/install", "/quiet", "/norestart" -NoNewWindow -Wait',
      subscribe   => File['downloadsqlssmsinstaller'],
      provider => 'powershell',
      unless => 'if (Test-Path -Path "C:\\Program Files (x86)\\Microsoft SQL Server Management Studio 18" -PathType Container){exit} else {exit 1}',
    }

    reboot {'sql_dsc_reboot':
      message => 'DSC has requested a reboot',
      when    => pending,
    }

}
