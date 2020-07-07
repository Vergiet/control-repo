# All agents (including the nagios server) will use this
class nagios::export {

  nagios::resource { $::hostname:
    type => 'host',
    address => inline_template("<%= has_variable?('my_nagios_interface') ?
↪eval('ipaddress_' + my_nagios_interface) : ipaddress %>"),
    hostgroups => inline_template("<%= has_variable?('my_nagios_hostgroups') ?
↪$my_nagios_hostgroups : 'Other' %>"),
    check_command => 'check_host_alive!3000.0,80%!5000.0,100%!10',
    bexport => true,
  }
}
