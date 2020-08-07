class base::server {

/*
  dsc_dnsserveraddress { 'configurednsaddress':
    dsc_interfacealias => $facts['networking']['primary'],
    dsc_addressfamily => 'IPv4',
    dsc_address => '192.168.1.131',
    dsc_validate => $true,
  }
*/

  dsc_computer { 'joindomain':
    dsc_name => $facts['networking']['hostname'],
    dsc_domainname => 'mshome.net',
    dsc_credential => {
        'user'     => 'Administrator@mshome.net',
        'password' => Sensitive('Beheer123')
      },
    dsc_joinou => 'CN=Computers,DC=mshome,DC=net',
  }

  reboot {'dsc_reboot':
    message => 'DSC has requested a reboot',
    when    => pending,
  }

}
