class nagios::expire_resources {

  if $my_nagios_purge_hosts {
    call_function('expire_exported', $my_nagios_purge_hosts)
  }
}
