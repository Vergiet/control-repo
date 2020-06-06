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


    file { 'sqlinstaller':
      ensure => present,
      subscribe => File['tempdir'],
      path => 'c:\\temp\\SQL2019-SSEI-Eval.exe',
      source => 'https://download.microsoft.com/download/4/8/6/486005eb-7aa8-4128-aac0-6569782b37b0/SQL2019-SSEI-Eval.exe',
    }
/* 
                    dsc_sqlsetup {'dsc_sqlsetup':
            InstanceName         = 'MSSQLSERVER'
            Features             = 'SQLENGINE,AS'
            SQLCollation         = 'SQL_Latin1_General_CP1_CI_AS'
            SQLSvcAccount        = $SqlServiceCredential
            AgtSvcAccount        = $SqlAgentServiceCredential
            ASSvcAccount         = $SqlServiceCredential
            SQLSysAdminAccounts  = 'COMPANY\SQL Administrators', $SqlAdministratorCredential.UserName
            ASSysAdminAccounts   = 'COMPANY\SQL Administrators', $SqlAdministratorCredential.UserName
            InstallSharedDir     = 'C:\Program Files\Microsoft SQL Server'
            InstallSharedWOWDir  = 'C:\Program Files (x86)\Microsoft SQL Server'
            InstanceDir          = 'C:\Program Files\Microsoft SQL Server'
            InstallSQLDataDir    = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLUserDBDir         = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLUserDBLogDir      = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLTempDBDir         = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLTempDBLogDir      = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLBackupDir         = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup'
            ASServerMode         = 'TABULAR'
            ASConfigDir          = 'C:\MSOLAP\Config'
            ASDataDir            = 'C:\MSOLAP\Data'
            ASLogDir             = 'C:\MSOLAP\Log'
            ASBackupDir          = 'C:\MSOLAP\Backup'
            ASTempDir            = 'C:\MSOLAP\Temp'
            SourcePath           = 'C:\InstallMedia\SQL2016RTM'
            NpEnabled            = $true
            TcpEnabled           = $true
            UpdateEnabled        = 'False'
            UseEnglish           = $true
            ForceReboot          = $false

            PsDscRunAsCredential = $SqlInstallCredential
            subscribe => dsc_windowsfeature['NET-Framework-Core']
                    }


 */
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
