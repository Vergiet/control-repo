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

  $cpu_service_name = inline_template("CPU Usage ${::fqdn}")
  $load_service_name = inline_template("Current Load ${::fqdn}")
  case $::kernel {
    windows: {
      nagios::resource { $cpu_service_name:
        type => 'service',
        bexport => true,
        service_use => 'passive_service',
        service_description => $cpu_service_name,
        active_checks_enabled => '0',
        host_name => $::fqdn,
        flap_detection_options => 'o',
        check_command => 'check_dummy!0',
      }

    file { regsubst("C:\\Program Files (x86)\\Nagios\\NCPA\\etc\\ncpa.cfg.d\\service_${cpu_service_name}.cfg",'\\s+', '_', 'G').downcase:
      ensure => 'present',
      #owner => $nagios::params::user,
      #group => $nagios::params::user,
      content => "%HOSTNAME%|${cpu_service_name} = cpu/percent --warning 80 --critical 90 --aggregate avg",
      #notify => Service[$nagios::params::service],
    }
    }

    linux: {
      nagios::resource { $load_service_name:
        type => 'service',
        bexport => true,
        service_description => $load_service_name,
        service_use => 'local-service',
        active_checks_enabled => '1',
        host_name => $::fqdn,
        flap_detection_options => 'o',
        check_command => 'check_local_load!5.0,4.0,3.0!10.0,6.0,4.0',
      }
    }
  }

}
