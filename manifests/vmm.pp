class vmm::master (
  
) {

    file {'tempdir':
      ensure => directory,
      path => 'c:\\temp\\',
    }

    file { 'vmminstaller':
      ensure => present,
      subscribe => File['tempdir'],
      path => 'c:\\temp\\SCVMM_2019.exe',
      source => 'http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCVMM_2019.exe',
    }

    exec { 'extractvmm':
      command     => 'c:\\temp\\SCVMM_2019.exe /SP- /silent /suppressmsgboxes',
      subscribe   => File['vmminstaller'],
      unless => 'C:\\Windows\\System32\\cmd.exe -c if exist "C:\\System Center Virtual Machine Manager\\setup.exe" (exit) else (exit 1) ',
    }

    dsc_windowsfeature { "NET-Framework-Core":
        dsc_ensure => "Present",
        dsc_name => "NET-Framework-Core",
    }


    file { 'downloadsqlinstalleriso':
      ensure => present,
      subscribe => File['tempdir'],
      path => 'c:\\temp\\SQLServer2019-x64-ENU.iso',
      source => 'https://dh2euwstodevinfinf01.blob.core.windows.net/temp/iso/SQLServer2019-x64-ENU.iso',
    }


    mount_iso { 'C:\\temp\\SQLServer2019-x64-ENU.iso':
      subscribe => File['downloadsqlinstalleriso'],
      drive_letter => 'S',
    }

 
    dsc_sqlsetup {'dsc_sqlsetup':
      dsc_InstanceName         => 'MSSQLSERVER',
      dsc_Features             => 'SQLENGINE,AS',
      dsc_SQLCollation         => 'SQL_Latin1_General_CP1_CI_AS',
      dsc_SQLSvcAccount        => {
        'user'     => 'Administrator@ad.contoso.com',
        'password' => Sensitive('Beheer123'),
      },
      dsc_AgtSvcAccount        => {
        'user'     => 'Administrator@ad.contoso.com',
        'password' => Sensitive('Beheer123'),
      },
      dsc_ASSvcAccount         => {
        'user'     => 'Administrator@ad.contoso.com',
        'password' => Sensitive('Beheer123'),
      },
      dsc_SQLSysAdminAccounts  => 'AD\\Domain Admins',
      dsc_ASSysAdminAccounts   => 'AD\\Domain Admins',
      dsc_InstallSharedDir     => 'C:\\Program Files\\Microsoft SQL Server',
      dsc_InstallSharedWOWDir  => 'C:\\Program Files (x86)\\Microsoft SQL Server',
      dsc_InstanceDir          => 'C:\\Program Files\\Microsoft SQL Server',
      dsc_InstallSQLDataDir    => 'C:\\Program Files\\Microsoft SQL Server\\MSSQL13.MSSQLSERVER\\MSSQL\\Data',
      dsc_SQLUserDBDir         => 'C:\\Program Files\\Microsoft SQL Server\\MSSQL13.MSSQLSERVER\\MSSQL\\Data',
      dsc_SQLUserDBLogDir      => 'C:\\Program Files\\Microsoft SQL Server\\MSSQL13.MSSQLSERVER\\MSSQL\\Data',
      dsc_SQLTempDBDir         => 'C:\\Program Files\\Microsoft SQL Server\\MSSQL13.MSSQLSERVER\\MSSQL\\Data',
      dsc_SQLTempDBLogDir      => 'C:\\Program Files\\Microsoft SQL Server\\MSSQL13.MSSQLSERVER\\MSSQL\\Data',
      dsc_SQLBackupDir         => 'C:\\Program Files\\Microsoft SQL Server\\MSSQL13.MSSQLSERVER\\MSSQL\\Backup',
      dsc_ASServerMode         => 'TABULAR',
      dsc_ASConfigDir          => 'C:\\MSOLAP\\Config',
      dsc_ASDataDir            => 'C:\\MSOLAP\\Data',
      dsc_ASLogDir             => 'C:\\MSOLAP\\Log',
      dsc_ASBackupDir          => 'C:\\MSOLAP\\Backup',
      dsc_ASTempDir            => 'C:\\MSOLAP\\Temp',
      dsc_SourcePath           => 'S:\\',
      dsc_NpEnabled            => 'true',
      dsc_TcpEnabled           => 'true',
      dsc_UpdateEnabled        => 'False',
      dsc_UseEnglish           => 'true',
      dsc_ForceReboot          => 'False',

      dsc_PsDscRunAsCredential => {
        'user'     => 'Administrator@ad.contoso.com',
        'password' => Sensitive('Beheer123'),
      },
      subscribe                => dsc_windowsfeature['NET-Framework-Core'],
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
