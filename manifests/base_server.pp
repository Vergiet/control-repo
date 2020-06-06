class base::server {

  if $osfamily == 'windows' {
    dsc_networkingdsc { 'ConfigStaticNetworking':
      dsc_dnsserveraddress => '192.168.1.131',
    }
  }

}
