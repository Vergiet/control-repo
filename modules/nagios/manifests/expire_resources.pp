class nagios::expire_resources {

  if $my_nagios_purge_hosts {
    expire_exported($my_nagios_purge_hosts)
  }
}
