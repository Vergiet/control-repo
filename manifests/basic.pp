class site::basic {
  if $osfamily == 'windows' {

    #include profile::os::windows::winrm
    include critical_policy
    include nagios::ncpa
    include nagios::export

    Package { provider => chocolatey, }
    windows_updates::list {'*':
      ensure    => 'present',
      name_mask => '*'
    }
  }
  else {
    include motd
    include core_permissions
  }
}
