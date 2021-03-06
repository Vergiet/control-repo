class scom::master (

) {


  include chocolatey
/*
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
SqlMachineName=vmm01
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
VmmServerName = vmm01.mshome.net
# VMMStaticIPAddress = <comma-separated-ip-for-HAVMM>
'
*/



/* notes:

Enable-NetFirewallRule -DisplayGroup 'Remote Event Log Management' -Verbose

invoke-command -ComputerName nce-ncvm01 -ScriptBlock { Enable-NetFirewallRule -Name WINRM-HTTP-Compat-In-TCP -Verbose }






/*

$vmminstall = '
$username = "mshome\\administrator"
$password = "Beheer123"

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $username, $securePassword
start-process powershell -Credential $credential -ArgumentList "-EncodedCommand cwB0AGEAcgB0AC0AcAByAG8AYwBlAHMAcwAgACIAQwA6AFwAUwB5AHMAdABlAG0AIABDAGUAbgB0AGUAcgAgAFYAaQByAHQAdQBhAGwAIABNAGEAYwBoAGkAbgBlACAATQBhAG4AYQBnAGUAcgBcAHMAZQB0AHUAcAAuAGUAeABlACIAIAAtAEEAcgBnAHUAbQBlAG4AdABMAGkAcwB0ACAAIgAvAHMAZQByAHYAZQByACIALAAgACIALwBpACIALAAgACIALwBmACAAQwA6AFwAVABlAG0AcABcAFYATQBTAGUAcgB2AGUAcgAuAGkAbgBpACIALAAgACIALwB2AG0AbQBzAGUAcgB2AGkAYwBlAGQAbwBtAGEAaQBuACAAbQBzAGgAbwBtAGUAIgAsACAAIgAvAHYAbQBtAHMAZQByAHYAaQBjAGUAVQBzAGUAcgBOAGEAbQBlACAAYQBkAG0AaQBuAGkAcwB0AHIAYQB0AG8AcgAiACwAIAAiAC8AdgBtAG0AcwBlAHIAdgBpAGMAZQB1AHMAZQByAHAAYQBzAHMAdwBvAHIAZAAgAEIAZQBoAGUAZQByADEAMgAzACIALAAgACIALwBJAEEAQwBDAEUAUABUAFMAQwBFAFUATABBACIAIAAtAE4AbwBOAGUAdwBXAGkAbgBkAG8AdwAgAC0AVwBhAGkAdAA=" -NoNewWindow -Wait
'
*/

    file { 'scominstaller-2016':
      ensure => present,
      path => 'c:\\temp\\SC2016_SCOM_EN.EXE',
      source => 'http://download.microsoft.com/download/6/4/F/64F31A3C-D4FD-41B9-8EF5-74B1A87721E2/SC2016_SCOM_EN.EXE',
    }

/*
    file { 'vmminstall':
      ensure => present,
      path => 'c:\\scripts\\vmminstall.ps1',
      content => $vmminstall,
    }
    */

/*
    file { 'C:\\Temp\\VMServer.ini':
      ensure => present,
      content => $vmmserverconfig,
    }
    */

/*
    exec { 'extractvmm-2019':
      command     => 'start-process "c:\\temp\\SCVMM_2019.exe" -ArgumentList "/SP-", "/silent", "/suppressmsgboxes" -NoNewWindow -Wait',
      subscribe   => File['vmminstaller-2019'],
      provider => 'powershell',
      unless => 'if (Test-Path -Path "C:\\System Center Virtual Machine Manager\\setup.exe" -PathType Leaf){exit} else {exit 1}',
    }
    */


    exec { 'extractscom-2016':
      command     => 'start-process "c:\\temp\\SC2016_SCOM_EN.EXE" -ArgumentList "/SP-", "/silent", "/suppressmsgboxes" -NoNewWindow -Wait',
      subscribe   => File['scominstaller-2016'],
      provider => 'powershell',
      unless => 'if (Test-Path -Path "C:\\SC 2016 RTM SCOM\\setup.exe" -PathType Leaf){exit} else {exit 1}',
    }





    package { 'microsoft-edge':
      ensure   => installed,
      provider => 'chocolatey',
    }

    package { 'ms-reportviewer2015':
      ensure   => installed,
      provider => 'chocolatey',
    }




  # & "C:\System Center Virtual Machine Manager\setup.exe" /server /i /f C:\Temp\VMServer.ini /vmmservicedomain mshome /vmmserviceUserName administrator /vmmserviceuserpassword Beheer123 /IACCEPTSCEULA

  #if $identity["user"] == "MSHOME\\administrator"{
#OperationsManagerDW
#OperationsManager

    exec { 'installscom':
      #command     => 'start-process "C:\\System Center Virtual Machine Manager\\setup.exe" -ArgumentList "/server", "/i", "/f C:\\Temp\\VMServer.ini", "/vmmservicedomain mshome", "/vmmserviceUserName administrator", "/vmmserviceuserpassword Beheer123", "/SqlDBAdminDomain mshome", "/SqlDBAdminName administrator", "/SqlDBAdminpassword Beheer123", "/IACCEPTSCEULA" -NoNewWindow -Wait',
      #command     => 'start-process "C:\\System Center Virtual Machine Manager\\setup.exe" -ArgumentList "/server", "/i", "/f C:\\Temp\\VMServer.ini", "/vmmservicedomain mshome", "/vmmserviceUserName administrator", "/vmmserviceuserpassword Beheer123", "/IACCEPTSCEULA" -NoNewWindow -Wait',
      command     => 'start-process "C:\\SC 2016 RTM SCOM\\setup.exe" -ArgumentList "/Silent","/Install","/EnableErrorReporting:Never","/SendCEIPReports:0","/UseMicrosoftUpdate:0","/ManagementGroupName:ManagementGroup01","/DWSqlServerInstance:scom01\\MSSQLSERVER","/Components:OMserver,OMConsole","/SqlServerInstance:scom01\\MSSQLSERVER","/UseLocalSystemActionAccount","/DatareaderUser:mshome\\administrator","/DatareaderPassword:Beheer123","/DataWriterUser:mshome\\administrator","/DataWriterPassword:Beheer123","/AcceptEndUserLicenseAgreement:1","/UseLocalSystemDASAccount" -NoNewWindow -Wait',
      #command => 'c:\\scripts\\vmminstall.ps1',
      #command     => 'start-process "C:\\System Center Virtual Machine Manager\\setup.exe" -ArgumentList "/server", "/i", "/f C:\\Temp\\VMServer.ini", "/SqlDBAdminDomain mshome", "/SqlDBAdminName administrator", "/SqlDBAdminpassword Beheer123", "/IACCEPTSCEULA" -NoNewWindow -Wait',
      #command     => 'cmd',
      subscribe   => File['scominstaller-2016'],
      provider => 'powershell',
      unless => 'if (Test-Path -Path "C:\\Program Files\\Microsoft System Center 2016\\Operations Manager" -PathType Container){exit} else {exit 1}',
      require => [Exec['extractscom-2016'], Dsc_disk['DVolume']],
    }

    $scomservices = ['OMSDK', 'cshost']

    service { $scomservices:
      ensure  => running,
      enable  => true,
      require => Exec['installscom'],
    }
/*
& "C:\SC 2016 RTM SCOM\setup.exe" /Silent /Install /EnableErrorReporting:Never /SendCEIPReports:0 /UseMicrosoftUpdate:0 /ManagementGroupName:ManagementGroup01 /DWSqlServerInstance:'scom01\MSSQLSERVER' /Components:'OMserver,OMConsole' /SqlServerInstance:'scom01\MSSQLSERVER' /UseLocalSystemActionAccount /DatareaderUser:'mshome\administrator' /DatareaderPassword:Beheer123 /DataWriterUser:'mshome\administrator' /DataWriterPassword:Beheer123 /AcceptEndUserLicenseAgreement:1 /UseLocalSystemDASAccount
*/
    /*

    service { 'SCVMMService':
      ensure  => running,
      enable  => true,
      require => Exec['installvmm'],
    }

    */

/*
    dsc_xwaitforcluster { 'WaitForCluster':
          dsc_name             => 'Cluster02',
          dsc_retryintervalsec => 10,
          dsc_retrycount       => 60,
          require => Windowsfeature['RSAT-Clustering-CmdInterface'],
    }
    */

/*
    exec { 'WaitForS2D':
        command     => 'if ((Get-Cluster -Name cluster02).S2DEnabled -eq 0){exit -1} else {exit 0}',
        provider => 'powershell',
        require => Exec['installvmm'],
    }
    */

  #}







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

 /*

    reboot {'vmm_dsc_reboot':
      message => 'VMM Reboot has been requested for either dsc, ccm or domain join.',
      when    => pending,
      onlyif => ['pending_dsc_reboot', 'pending_ccm_reboot', 'pending_domain_join']
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

*/

    dsc_disk { 'DVolume':
      dsc_diskid => '1', # Disk 3
      #dsc_diskidtype => 'UniqueId',
      dsc_driveletter => 'D',
      dsc_fsformat => 'NTFS',
      dsc_allocationunitsize => 4096, #4KB
      #dsc_allowdestructive => true,
      #dsc_cleardisk => true,
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
  windowsfeature { 'RSAT-NetworkController':
    ensure => present,
  }
  */

# http://download.microsoft.com/download/1/6/6/166A63BF-E3CE-49EF-8E8D-D599995C6E75/SC2016_SCDPM.EXE
# http://download.microsoft.com/download/6/4/F/64F31A3C-D4FD-41B9-8EF5-74B1A87721E2/SC2016_SCOM_EN.EXE

  # (Get-WindowsFeature -Name 'RSAT*' | %{('"{0}"' -f $_.name )}) -join ',' | clip

  /*
  $rsat = ["RSAT","RSAT-Feature-Tools","RSAT-SMTP","RSAT-Feature-Tools-BitLocker","RSAT-Feature-Tools-BitLocker-RemoteAdminTool","RSAT-Feature-Tools-BitLocker-BdeAducExt","RSAT-Bits-Server","RSAT-DataCenterBridging-LLDP-Tools","RSAT-Clustering","RSAT-Clustering-Mgmt","RSAT-Clustering-PowerShell","RSAT-Clustering-AutomationServer","RSAT-Clustering-CmdInterface","RSAT-NLB","RSAT-Shielded-VM-Tools","RSAT-SNMP","RSAT-Storage-Replica","RSAT-WINS","RSAT-Role-Tools","RSAT-AD-Tools","RSAT-AD-PowerShell","RSAT-ADDS","RSAT-AD-AdminCenter","RSAT-ADDS-Tools","RSAT-ADLDS","RSAT-Hyper-V-Tools","RSAT-RDS-Tools","RSAT-RDS-Gateway","RSAT-RDS-Licensing-Diagnosis-UI","RSAT-ADCS","RSAT-ADCS-Mgmt","RSAT-Online-Responder","RSAT-ADRMS","RSAT-DHCP","RSAT-DNS-Server","RSAT-Fax","RSAT-File-Services","RSAT-DFS-Mgmt-Con","RSAT-FSRM-Mgmt","RSAT-NFS-Admin","RSAT-NetworkController","RSAT-NPAS","RSAT-Print-Services","RSAT-RemoteAccess","RSAT-RemoteAccess-Mgmt","RSAT-RemoteAccess-PowerShell","RSAT-VA-Tools"]

  windowsfeature { $rsat:
    ensure => present,
    installsubfeatures => true,
  }
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

