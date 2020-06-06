class base::server {

  dsc_dnsserveraddress { 'configurednsaddress':
    dsc_interfacealias => $facts['networking']['primary'],
    dsc_addressfamily => 'IPv4',
    dsc_address => '192.168.1.131',
    dsc_validate => $true,
  }
/* 
  class { domain_membership:
    domain => 'ad.contoso.com',
    username => 'Administrator@ad.contoso.com',
    password => 'Beheer123',
    machine_ou => 'OU=SERVERS,OU=ORG,DC=ad,DC=contoso,DC=com',
    reboot => true,
    join_options => '3',
  }
 */


  dsc_computer { 'joindomain':
    dsc_name => $facts['networking']['hostname'],
    dsc_domainname => 'ad.contoso.com',
    dsc_credential => {
        'user'     => 'Administrator@ad.contoso.com',
        'password' => Sensitive('Beheer123')
      },
  }

}
