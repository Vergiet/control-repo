class vmm::master (
  
) {

  require sql::standalone
  require temp::folder

    file { 'vmminstaller':
      ensure => present,
      path => 'c:\\temp\\SCVMM_2019.exe',
      source => 'http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCVMM_2019.exe',
    }

    exec { 'extractvmm':
      command     => 'start-process "c:\\temp\\SCVMM_2019.exe" -ArgumentList "/SP-", "/silent", "/suppressmsgboxes" -NoNewWindow -Wait',
      subscribe   => File['vmminstaller'],
      provider => 'powershell',
      unless => 'if (Test-Path -Path "C:\\System Center Virtual Machine Manager\\setup.exe" -PathType Leaf){exit} else {exit 1}',
    }

    package { 'sql2012.nativeclient':
      ensure   => latest,
    }

    exec { 'installvmm':
      command     => 'start-process "C:\\System Center Virtual Machine Manager\\setup.exe" -ArgumentList "/server", "/i", "/vmmservicedomain "ad.contoso.com"", "/vmmserviceUserName "administrator"", "/vmmserviceuserpassword "Beheer123"", "/SqlDBAdminDomain "ad.contoso.com"", "/SqlDBAdminName "administrator"", "/SqlDBAdminpassword "Beheer123"" -NoNewWindow -Wait',
      subscribe   => File['vmminstaller'],
      provider => 'powershell',
      unless => 'if (Test-Path -Path "C:\\System Center Virtual Machine Manager\\setup.exe" -PathType Leaf){exit} else {exit 1}',
    }

/* 
    dsc_xscvmmmanagementserversetup { "VMMMS":
        dsc_ensure => "Present",
        subscribe   => Exec['extractvmm'],
        dsc_sourcepath => "C:\\System Center Virtual Machine Manager\\",
        dsc_sourcefolder => '',
        dsc_setupcredential => {
          'user'     => 'ad\\Administrator',
          'password' => Sensitive('Beheer123'),
        },
        dsc_vmmservice => {
          'user'     => 'ad\\Administrator',
          'password' => Sensitive('Beheer123'),
        },
        dsc_sqlmachinename => $facts['networking']['fqdn'],
        dsc_sqlinstancename => 'MSSQLSERVER',
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
