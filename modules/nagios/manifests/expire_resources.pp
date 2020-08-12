class nagios::expire_resources {

  if $my_nagios_purge_hosts {
    #call_function('expire_exported', $my_nagios_purge_hosts)
    #call_expire_exported('expire_exported', $my_nagios_purge_hosts)
    #function_expire_exported($my_nagios_purge_hosts)
    nagios::expire_exported($my_nagios_purge_hosts)
  }
}

