class ras::multitenant (

) {


  reboot {'pre-reboot':
    message => 'DSC has requested a reboot before installing roles',
    when    => pending,
  }

  $rasroles = ["RemoteAccess","DirectAccess-VPN","Routing", "RSAT-RemoteAccess-PowerShell"]

  windowsfeature { $rasroles:
    ensure => present,
    installsubfeatures => true,
    require => Reboot['pre-reboot'],
    notify => Reboot['after-reboot']
  }

  reboot {'after-reboot':
    message => 'DSC has requested a reboot after installing roles',
    when    => pending,
  }

  exec { 'installvmm':
    command     => 'Install-RemoteAccess -MultiTenancy',
    provider => 'powershell',
    unless => 'if ((get-RemoteAccess).VpnMultiTenancyStatus -eq "installed"){exit} else {exit 1}',
    require => [Windowsfeature['RSAT-RemoteAccess-PowerShell'], Reboot['after-reboot']],
  }



}
