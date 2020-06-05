class site::basic {
  if $osfamily == 'windows' {
    include critical_policy
  }
  else {
    include motd
    include core_permissions
  }
}
