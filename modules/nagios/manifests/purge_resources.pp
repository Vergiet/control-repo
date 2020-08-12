class nagios::purge_resources {

  require nagios::collect_resources

/*
  if $my_nagios_purge_hosts {
    purge_exported($my_nagios_purge_hosts)
  }
*/
}
