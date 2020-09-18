class hv::baseline (

) {


  reboot {'before_Hyper_V':
    when      => pending,
  }

  service { 'MSiSCSI':
    ensure  => running,
    enable  => true,
  }

/*



$connectiscsi = '
if (([array](get-IscsiTargetPortal)).count -eq 0){

    New-IscsiTargetPortal -TargetPortalAddress "192.168.1.4" -InitiatorInstanceName "ROOT\\ISCSIPRT\\0000_0"
}

Get-IscsiTarget | ?{$_.IsConnected -eq $False -and $_.NodeAddress -like "*target-hv"} | Connect-IscsiTarget -IsPersistent $true
'

$renamenetadapters = '
Get-NetAdapter | ?{$_.linkspeed -eq "10 Gbps" -and $_.name -ne "mshome"} | Rename-NetAdapter -NewName "mshome"
Get-NetAdapter | ?{$_.linkspeed -eq "1 Gbps" -and $_.name -ne "vrgt.xyz"} | Rename-NetAdapter -NewName "vrgt.xyz"
'


  file { "c:\\scripts\\connectiscsi.ps1" :
    ensure   => present,
    content => $connectiscsi,
  }
  

  file { "c:\\scripts\\renamenetadapters.ps1" :
    ensure   => absent,
    content => $renamenetadapters,
  }
  */

/*

  exec { 'connectiscsi':
    command     => '& c:\\scripts\\connectiscsi.ps1',
    #subscribe   => File['c:\\scripts\\connectiscsi.ps1'],
    require   => File['c:\\scripts\\connectiscsi.ps1'],
    provider => 'powershell',
  }
  */

/*
  exec { 'renamenetadapters':
    command     => '& c:\\scripts\\renamenetadapters.ps1',
    #subscribe   => File['c:\\scripts\\connectiscsi.ps1'],
    require   => File['c:\\scripts\\renamenetadapters.ps1'],
    provider => 'powershell',
  }
  */

 windowsfeature { 'Hyper-V':
   ensure => present,
   require => Reboot['before_Hyper_V'],
 }

 reboot {'after_Hyper_V':
   when      => pending,
   subscribe => Windowsfeature['Hyper-V'],
 }

/*

  dsc_computer { 'joindomain':
    dsc_name => $facts['networking']['hostname'],
    dsc_domainname => 'mshome.net',
    dsc_credential => {
        'user'     => 'Administrator@mshome.net',
        'password' => Sensitive('Beheer123')
      },
    require => Exec['ensurednsadres'],
  }

*/

$setipaddress = '
$ip = (Get-NetAdapter -Name "Default Switch" | Get-NetIPAddress -AddressFamily IPv4).IPAddress.split(".")[0]

New-NetIPAddress -IPAddress "10.0.0.$ip" -InterfaceIndex (Get-NetAdapter -Name "Provider").interfaceindex
'

  file { "c:\\scripts\\setipaddress.ps1" :
    ensure   => present,
    content => $setipaddress,
  }


  exec { 'setipaddress':
    command     => '& c:\\scripts\\setipaddress.ps1',
    require   => File['c:\\scripts\\setipaddress.ps1'],
    provider => 'powershell',
  }

  dsc_windowsfeature { 'AddFailoverFeature':
      dsc_ensure => 'Present',
      dsc_name   => 'Failover-clustering',
  }

  dsc_windowsfeature { 'AddRemoteServerAdministrationToolsClusteringPowerShellFeature':
      dsc_ensure    => 'Present',
      dsc_name      => 'RSAT-Clustering-PowerShell',
      require => Dsc_windowsfeature['AddFailoverFeature'],
      # DependsOn = '[WindowsFeature]AddFailoverFeature'
  }

  dsc_windowsfeature { 'AddRemoteServerAdministrationToolsClusteringCmdInterfaceFeature':
      dsc_ensure    => 'Present',
      dsc_name      => 'RSAT-Clustering-CmdInterface',
      require => Dsc_windowsfeature['AddRemoteServerAdministrationToolsClusteringPowerShellFeature'],
      #DependsOn = '[WindowsFeature]AddRemoteServerAdministrationToolsClusteringPowerShellFeature'
  }

  if $os['windows']['installation_type'] == 'Server' {
    dsc_windowsfeature { 'AddRemoteServerAdministrationToolsClusteringManagementToolsFeature':
        dsc_ensure    => 'Present',
        dsc_name      => 'RSAT-Clustering-Mgmt',
        require => Dsc_windowsfeature['AddRemoteServerAdministrationToolsClusteringPowerShellFeature'],
        #DependsOn = '[WindowsFeature]AddRemoteServerAdministrationToolsClusteringPowerShellFeature'
    }
  }





/*
  dsc_waitfordisk { 'Disk2':
        dsc_diskid => '6589CFC00000085BF473AC1C6E103E0A', # Disk 3
        dsc_diskidtype => 'UniqueId',
        dsc_retryintervalsec => 60,
        dsc_retrycount => 60,
  }
  */

  # https://regex101.com/r/8yU9Oa/1
  if $hostname =~ /\A[a-zA-Z]+[0-9][2-9]\Z/ {
    dsc_xwaitforcluster { 'WaitForCluster':
        dsc_name             => 'Cluster02',
        dsc_retryintervalsec => 10,
        dsc_retrycount       => 60,
        require        => Dsc_windowsfeature['AddRemoteServerAdministrationToolsClusteringCmdInterfaceFeature'],
  }

    dsc_xcluster { 'JoinCluster':
        dsc_name => 'Cluster02',
        dsc_staticipaddress               => '192.168.1.13/24',
        dsc_domainadministratorcredential => {
          'user'     => 'Administrator@mshome.net',
          'password' => Sensitive('Beheer123')
        },
        require => [Dsc_windowsfeature['AddRemoteServerAdministrationToolsClusteringCmdInterfaceFeature'], Reboot['before_Hyper_V'], Dsc_xwaitforcluster['WaitForCluster']],
    }

    reboot {'after_cluster':
      when      => pending,
      subscribe =>Dsc_xcluster['JoinCluster'],
    }


  } else {

    dsc_xcluster { 'CreateCluster':
        dsc_name => 'Cluster02',
        dsc_staticipaddress               => '192.168.1.13/24',
        dsc_domainadministratorcredential => {
          'user'     => 'Administrator@mshome.net',
          'password' => Sensitive('Beheer123')
        },
        require => [Dsc_windowsfeature['AddRemoteServerAdministrationToolsClusteringCmdInterfaceFeature'], Reboot['before_Hyper_V']],
    }



    dsc_xclusterquorum { 'FileShareQuorum':
        dsc_issingleinstance => 'Yes',
        dsc_type => 'NodeAndFileShareMajority',
        dsc_resource => '\\\\DC01\\fsw',
        require => Dsc_xcluster['CreateCluster'],
    }

    /*

    dsc_failoverclusters2d { 'EnableS2D':
        dsc_issingleinstance => 'yes',
        dsc_ensure => 'Present',
        require => Dsc_xcluster['CreateCluster'],
    }

*/
    /*
    dsc_disk { 'DVolume':
          dsc_diskid => '6589CFC00000085BF473AC1C6E103E0A', # Disk 3
          dsc_diskidtype => 'UniqueId',
          dsc_driveletter => 'D',
          dsc_fsformat => 'NTFS',
          dsc_allocationunitsize => 4096, #4KB
          require => Dsc_waitfordisk['Disk2'],
    }


    dsc_xclusterdisk {'AddClusterDisk01':
        dsc_number => '1',
        dsc_ensure => 'Present',
        dsc_label  => 'Disk01',
        require => [Dsc_disk['DVolume'], Dsc_xcluster['CreateCluster']],
        #require => Dsc_waitfordisk['Disk2'],
    }
    */


    reboot {'after_cluster':
      when      => pending,
      subscribe => Dsc_xcluster['CreateCluster'],
    }

  }



  dsc_xvmhost { 'hv':
    dsc_issingleinstance => 'yes', # dsc requirement, must be yes.
    dsc_enableenhancedsessionmode => true,
    require => Windowsfeature['Hyper-V'],
  }


  /*


  dsc_xvmswitch { 'External':
    dsc_ensure => present,
    dsc_name => 'External',
    dsc_type => 'External',
    dsc_netadaptername => 'mshome',
    dsc_allowmanagementos => true,
    require => [Windowsfeature['Hyper-V'],Exec['renamenetadapters']],
  }

  */

}
