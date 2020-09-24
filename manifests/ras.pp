class ras::multitenant (

) {


  $rasroles = ["RemoteAccess","DirectAccess-VPN","Routing"]

  windowsfeature { $rasroles:
    ensure => present,
    installsubfeatures => true,
  }

}
