# All agents (including the nagios server) will use this
class nagios::export {

  nagios::resource { $::fqdn:
    type => 'host',
    #address => inline_template("<%= has_variable?('my_nagios_interface') ? eval('ipaddress_' + my_nagios_interface) : ipaddress %>"),
    address => $::ipaddress,
    #hostgroups => inline_template("<%= has_variable?('my_nagios_hostgroups') ? $my_nagios_hostgroups : 'Other' %>"),
    hostgroups => 'all-servers',
    check_command => 'check-host-alive',
    bexport => true,
    max_check_attempts => '5',
    check_period => '24x7',
    notification_interval => '30',
    notification_period => '24x7',
  }


  if $::kernel == 'windows' {
    $cpuservicename = inline_template("CPU Usage ${::fqdn}")
    nagios::resource { $cpuservicename:
      type => 'service',
      bexport => true,
      service_use => 'passive_service',
      service_description => $cpuservicename,
      active_checks_enabled => '0',
      host_name => $::fqdn,
      flap_detection_options => 'o',
      check_command => 'check_dummy!0',
    }
  }

}
