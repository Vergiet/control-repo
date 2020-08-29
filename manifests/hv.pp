class hv::baseline (

) {


  reboot {'before_Hyper_V':
    when      => pending,
  }

  service { 'MSiSCSI':
    ensure  => running,
    enable  => true,
  }


$connectiscsi = '
if (([array](get-IscsiTargetPortal)).count -eq 0){

    New-IscsiTargetPortal -TargetPortalAddress "192.168.1.4" -InitiatorInstanceName "ROOT\\ISCSIPRT\\0000_0"
}

Get-IscsiTarget | ?{$_.IsConnected -eq $False -and $_.NodeAddress -like "*target-hv"} | Connect-IscsiTarget -IsPersistent $true
'

$renamenetadapters = '
Get-NetAdapter | ?{$_.linkspeed -eq "10 Gbps"} | Rename-NetAdapter -NewName "mshome"
Get-NetAdapter | ?{$_.linkspeed -eq "1 Gbps"} | Rename-NetAdapter -NewName "vrgt.xyz"
'

  file { "c:\\scripts\\connectiscsi.ps1" :
    ensure   => present,
    content => $connectiscsi,
  }

  file { "c:\\scripts\\renamenetadapters.ps1" :
    ensure   => present,
    content => $renamenetadapters,
  }



  exec { 'connectiscsi':
    command     => '& c:\\scripts\\connectiscsi.ps1',
    #subscribe   => File['c:\\scripts\\connectiscsi.ps1'],
    require   => File['c:\\scripts\\connectiscsi.ps1'],
    provider => 'powershell',
  }

  exec { 'renamenetadapters':
    command     => '& c:\\scripts\\renamenetadapters.ps1',
    #subscribe   => File['c:\\scripts\\connectiscsi.ps1'],
    require   => File['c:\\scripts\\renamenetadapters.ps1'],
    provider => 'powershell',
  }

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

  dsc_windowsfeature { 'AddRemoteServerAdministrationToolsClusteringManagementToolsFeature':
      dsc_ensure    => 'Present',
      dsc_name      => 'RSAT-Clustering-Mgmt',
      require => Dsc_windowsfeature['AddRemoteServerAdministrationToolsClusteringPowerShellFeature'],
      #DependsOn = '[WindowsFeature]AddRemoteServerAdministrationToolsClusteringPowerShellFeature'
  }




  dsc_waitfordisk { 'Disk2':
        dsc_diskid => '6589CFC0000006372FCD5E7AAB386935', # Disk 3
        dsc_diskidtype => 'UniqueId',
        dsc_retryintervalsec => 60,
        dsc_retrycount => 60,
  }

  # https://regex101.com/r/8yU9Oa/1
  if $hostname =~ /\A[a-zA-Z]+[0-9][2-9]\Z/ {
    dsc_xwaitforcluster { 'WaitForCluster':
        dsc_name             => 'Cluster01',
        dsc_retryintervalsec => 10,
        dsc_retrycount       => 60,
        require        => Dsc_windowsfeature['AddRemoteServerAdministrationToolsClusteringCmdInterfaceFeature'],
  }

    dsc_xcluster { 'JoinCluster':
        dsc_name => 'Cluster01',
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
        dsc_name => 'Cluster01',
        dsc_staticipaddress               => '192.168.1.13/24',
        dsc_domainadministratorcredential => {
          'user'     => 'Administrator@mshome.net',
          'password' => Sensitive('Beheer123')
        },
        require => [Dsc_windowsfeature['AddRemoteServerAdministrationToolsClusteringCmdInterfaceFeature'], Reboot['before_Hyper_V']],
    }



    dsc_disk { 'DVolume':
          dsc_diskid => '6589CFC0000006372FCD5E7AAB386935', # Disk 3
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
        require => Dsc_disk['DVolume'],
        #require => Dsc_waitfordisk['Disk2'],
    }


    reboot {'after_cluster':
      when      => pending,
      subscribe => Dsc_xcluster['CreateCluster'],
    }

  }



  dsc_xvmhost { 'hv':
    dsc_issingleinstance => 'yes',
    dsc_enableenhancedsessionmode => true,
    require => Windowsfeature['Hyper-V'],
  }


  dsc_xvmswitch { 'External':
    dsc_ensure => present,
    dsc_name => 'External',
    dsc_type => 'External',
    dsc_netadaptername => 'mshome',
    dsc_allowmanagementos => true,
    require => [Windowsfeature['Hyper-V'],Exec['renamenetadapters']],
  }

}
