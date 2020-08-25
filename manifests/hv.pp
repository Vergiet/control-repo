class hv::baseline (

) {


  reboot {'before_Hyper_V':
   when      => pending,
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

  dsc_xcluster { 'CreateCluster':
      dsc_name => 'Cluster01',
      dsc_staticipaddress               => '192.168.1.13/24',
      dsc_domainadministratorcredential => {
        'user'     => 'Administrator@mshome.net',
        'password' => Sensitive('Beheer123')
      },
      require => [Dsc_windowsfeature['AddRemoteServerAdministrationToolsClusteringCmdInterfaceFeature'], Reboot['before_Hyper_V']],
  }

}
