class profile::ad::pdc (
  String $ntds_dir = 'c:\NTDS',
) {

  dsc_file  {'adfile':
    dsc_destinationpath => $ntds_dir
    dsc_type => 'Directory',
    dsc_ensure => 'Present',
  } ->

  dsc_windowsfeature  { 'addsinstall':
    dsc_ensure => 'Present',
    dsc_name => 'AD-Domain-Services',
  }

  dsc_windowsfeature  {'addstools':
    dsc_ensure => 'Present',
    dsc_name => 'RSAT-ADDS',
  }

  dsc_xaddomain   { 'firstdc':
    subscribe => Dsc_windowsfeature['addsinstall'],
    dsc_domainname => 'ad.contoso.com',
    dsc_domainadministratorcredential => {
      'user' => 'pagent',
      'password' => Sensitive('Test12341234')
    },
    dsc_safemodeadministratorpassword   => {
      'user' => 'pagent',
      'password' => Sensitive('Test12341234')
    },
    dsc_databasepath => $ntds_dir,
    dsc_logpath => $ntds_dir,
  }

  reboot {'dsc_reboot':
    message => 'DSC has requested a reboot',
    when => pending,
  }

}
