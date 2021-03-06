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

  $cpu_usage_service_name = inline_template("CPU Usage ${::fqdn}")
  $disk_usage_c_service_name = inline_template("Disk Usage C ${::fqdn}")
  $swap_usage_service_name = inline_template("Swap Usage ${::fqdn}")
  $memory_usage_service_name = inline_template("Memory Usage ${::fqdn}")
  $process_count_service_name = inline_template("Process Count ${::fqdn}")

  $load_service_name = inline_template("Current Load ${::fqdn}")
  case $::kernel {
    windows: {
      
      nagios::resource { $cpu_usage_service_name:
        type => 'service',
        bexport => true,
        service_use => 'passive_service',
        service_description => $cpu_usage_service_name,
        active_checks_enabled => '0',
        host_name => $::fqdn,
        flap_detection_options => 'o',
        check_command => 'check_dummy!0',
      }

      nagios::resource::ncpacheck { $cpu_usage_service_name:
       check_command => '%HOSTNAME%|<%= $name %> = cpu/percent --warning 80 --critical 90 --aggregate avg',
      }

      nagios::resource { $disk_usage_c_service_name:
        type => 'service',
        bexport => true,
        service_use => 'passive_service',
        service_description => $disk_usage_c_service_name,
        active_checks_enabled => '0',
        host_name => $::fqdn,
        flap_detection_options => 'o',
        check_command => 'check_dummy!0',
      }

      nagios::resource::ncpacheck { $disk_usage_c_service_name:
       check_command => '%HOSTNAME%|<%= $name %> = disk/logical/C:|/used_percent --warning 80 --critical 90 --units Gi',
      }

      nagios::resource { $swap_usage_service_name:
        type => 'service',
        bexport => true,
        service_use => 'passive_service',
        service_description => $swap_usage_service_name,
        active_checks_enabled => '0',
        host_name => $::fqdn,
        flap_detection_options => 'o',
        check_command => 'check_dummy!0',
      }

      nagios::resource::ncpacheck { $swap_usage_service_name:
       check_command => '%HOSTNAME%|<%= $name %> = memory/swap --warning 60 --critical 80 --units Gi',
      }

      nagios::resource { $memory_usage_service_name:
        type => 'service',
        bexport => true,
        service_use => 'passive_service',
        service_description => $memory_usage_service_name,
        active_checks_enabled => '0',
        host_name => $::fqdn,
        flap_detection_options => 'o',
        check_command => 'check_dummy!0',
      }

      nagios::resource::ncpacheck { $memory_usage_service_name:
       check_command => '%HOSTNAME%|<%= $name %> = memory/virtual --warning 80 --critical 90 --units Gi',
      }

      nagios::resource { $process_count_service_name:
        type => 'service',
        bexport => true,
        service_use => 'passive_service',
        service_description => $process_count_service_name,
        active_checks_enabled => '0',
        host_name => $::fqdn,
        flap_detection_options => 'o',
        check_command => 'check_dummy!0',
      }

      nagios::resource::ncpacheck { $process_count_service_name:
       check_command => '%HOSTNAME%|<%= $name %> = processes --warning 300 --critical 400',
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
