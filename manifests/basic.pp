class site::basic {
  if $osfamily == 'windows' {
    include critical_policy
    include nagios::export
  }
  else {
    include motd
    include core_permissions
  }
}
