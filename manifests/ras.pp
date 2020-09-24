class ras::multitenant (

) {


  reboot {'pre-reboot':
    message => 'DSC has requested a reboot before installing roles',
    when    => pending,
  }

  $rasroles = ["RemoteAccess","DirectAccess-VPN","Routing"]

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



}
