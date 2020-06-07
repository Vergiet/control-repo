class vmm::master (
  
) {

    file { 'vmminstaller':
      ensure => present,
      #subscribe => File['vmm_tempdir'],
      path => 'c:\\temp\\SCVMM_2019.exe',
      source => 'http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCVMM_2019.exe',
    }

    exec { 'extractvmm':
      command     => 'c:\\temp\\SCVMM_2019.exe /SP- /silent /suppressmsgboxes',
      #subscribe   => File['vmminstaller'],
      unless => 'C:\\Windows\\System32\\cmd.exe -c if exist "C:\\System Center Virtual Machine Manager\\setup.exe" (exit) else (exit 1) ',
    }


/* 
    dsc_windowsfeature { "NET-Framework-45-Core":
        dsc_ensure => "Present",
        dsc_name => "NET-Framework-45-Core",
    }


    file { 'downloadsqlinstalleriso':
      ensure => present,
      subscribe => File['tempdir'],
      path => 'c:\\temp\\SQLServer2019-x64-ENU.iso',
      source => 'https://dh2euwstodevinfinf01.blob.core.windows.net/temp/iso/SQLServer2019-x64-ENU.iso',
    }


    file { 'downloadsqlssmsinstaller':
      ensure => present,
      subscribe => File['tempdir'],
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
     */

    reboot {'vmm_dsc_reboot':
      message => 'DSC has requested a reboot',
      when    => pending,
    }

# 
/* 
  dsc_xscvmmmanagementserversetup { 'vmminstall':
    dsc_ensure => Present,
    dsc_sourcepath => 'C:\\System Center Virtual Machine Manager\\',
    dsc_setupcredential => {
      'user' => 'Administrator',
      'password' => Sensitive('Beheer123')
    },
    dsc_CreateNewSqlDatabase => 1,



  }

 */
/* 
https://download.microsoft.com/download/4/8/6/486005eb-7aa8-4128-aac0-6569782b37b0/SQL2019-SSEI-Eval.exe
http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCO_2019.exe
http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCSM_2019.exe
http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCSM_Auth_2019.exe
http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCDPM_2019.exe
http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCOM_2019.exe
http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCVMM_2019.exe
https://download.microsoft.com/download/f/e/b/feb0e6be-21ce-4f98-abee-d74065e32d0a/SSMS-Setup-ENU.exe

 */



/* 
  dsc_dnsserveraddress { 'configurednsaddress':
    dsc_interfacealias => $facts['networking']['primary'],
    dsc_addressfamily => 'IPv4',
    dsc_address => '192.168.1.131',
    dsc_validate => $true,
  } 
*/
}
