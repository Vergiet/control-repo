class vmm::master (

) {


  include chocolatey

$vmmserverconfig = '

[OPTIONS]
# ProductKey=xxxxx-xxxxx-xxxxx-xxxxx-xxxxx
UserName=Administrator
CompanyName=Microsoft Corporation
ProgramFiles=C:\\Program Files\\Microsoft System Center\\Virtual Machine Manager
CreateNewSqlDatabase=1
SqlInstanceName=MSSQLSERVER
SqlDatabaseName=VirtualManagerDB
RemoteDatabaseImpersonation=0
SqlMachineName=vm01
IndigoTcpPort=8100
IndigoHTTPSPort=8101
IndigoNETTCPPort=8102
IndigoHTTPPort=8103
WSManTcpPort=5985
BitsTcpPort=443
CreateNewLibraryShare=1
LibraryShareName=MSSCVMMLibrary
LibrarySharePath=D:\\ProgramData\\Virtual Machine Manager Library Files
LibraryShareDescription=Virtual Machine Manager Library Files
SQMOptIn = 1
MUOptIn = 0
VmmServiceLocalAccount = 0
#TopContainerName = VMMServer
HighlyAvailable = 0
VmmServerName = vm01.mshome.net
# VMMStaticIPAddress = <comma-separated-ip-for-HAVMM>



'

    file { 'vmminstaller':
      ensure => present,
      path => 'c:\\temp\\SCVMM_2019.exe',
      source => 'http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCVMM_2019.exe',
    }

    file { 'C:\\Temp\\VMServer.ini':
      ensure => present,
      content => $vmmserverconfig,
    }

    exec { 'extractvmm':
      command     => 'start-process "c:\\temp\\SCVMM_2019.exe" -ArgumentList "/SP-", "/silent", "/suppressmsgboxes" -NoNewWindow -Wait',
      subscribe   => File['vmminstaller'],
      provider => 'powershell',
      unless => 'if (Test-Path -Path "C:\\System Center Virtual Machine Manager\\setup.exe" -PathType Leaf){exit} else {exit 1}',
    }

    package { 'sql2012.nativeclient':
      ensure   => installed,
      provider          => 'chocolatey',
    }

    package { 'sqlserver-cmdlineutils':
      ensure   => installed,
      provider          => 'chocolatey',
      #install_options => ['--version=14.0'],
      require => Reboot['vmm_dsc_reboot'],
    }


    package { 'windows-adk-all':
      ensure   => installed,
      provider          => 'chocolatey',
    }


  # & "C:\System Center Virtual Machine Manager\setup.exe" /server /i /f C:\Temp\VMServer.ini /vmmservicedomain mshome /vmmserviceUserName administrator /vmmserviceuserpassword Beheer123 /SqlDBAdminDomain mshome /SqlDBAdminName administrator /SqlDBAdminpassword Beheer123 /IACCEPTSCEULA
  /*
    exec { 'installvmm':
      command     => 'start-process "C:\\System Center Virtual Machine Manager\\setup.exe" -ArgumentList "/server", "/i", "/f C:\\Temp\\VMServer.ini", "/vmmservicedomain mshome", "/vmmserviceUserName administrator", "/vmmserviceuserpassword Beheer123", "/SqlDBAdminDomain mshome", "/SqlDBAdminName administrator", "/SqlDBAdminpassword Beheer123", "/IACCEPTSCEULA" -NoNewWindow -Wait',
      #command     => 'start-process "C:\\System Center Virtual Machine Manager\\setup.exe" -ArgumentList "/server", "/i", "/f C:\\Temp\\VMServer.ini", "/SqlDBAdminDomain mshome", "/SqlDBAdminName administrator", "/SqlDBAdminpassword Beheer123", "/IACCEPTSCEULA" -NoNewWindow -Wait',
      #command     => 'cmd',
      subscribe   => File['vmminstaller'],
      provider => 'powershell',
      unless => 'if (Test-Path -Path "C:\\Program Files\\Microsoft System Center\\Virtual Machine Manager" -PathType Container){exit} else {exit 1}',
      require => [File['C:\\Temp\\VMServer.ini'], Package['sqlserver-cmdlineutils'], Package['sql2012.nativeclient'],Package['windows-adk-all'], Exec['extractvmm'], Dsc_disk['DVolume']],
    }
*/

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

    local_security_policy { 'Allow log on locally':
      ensure         => 'present',
      policy_setting => 'SeInteractiveLogonRight',
      policy_type    => 'Privilege Rights',
      policy_value   => '*S-1-5-32-544,*S-1-5-32-545,*S-1-5-32-551,mshome\\administrator',
      provider       => 'policy',
    }

    local_security_policy { 'Allow log on through Remote Desktop Services':
      ensure         => 'present',
      policy_setting => 'SeRemoteInteractiveLogonRight',
      policy_type    => 'Privilege Rights',
      policy_value   => '*S-1-5-32-544,*S-1-5-32-555,mshome\\administrator',
      provider       => 'policy',
    }

    

    dsc_disk { 'DVolume':
      dsc_diskid => '2', # Disk 3
      #dsc_diskidtype => 'UniqueId',
      dsc_driveletter => 'D',
      dsc_fsformat => 'NTFS',
      dsc_allocationunitsize => 4096, #4KB
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
