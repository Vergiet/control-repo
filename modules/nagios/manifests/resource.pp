define nagios::resource(
  $bexport,
  $type,
  $host_use = 'generic-host',
  $service_use = 'generic-service',
  $ensure = 'present',
  $owner = 'nagios',
  $address = '',
  $hostgroups = '',
  $hostgroup_name = '',
  Optional $check_command = '',
  $max_check_attempts = '5',
  $check_period = '24x7',
  $notification_interval = '30',
  $notification_period = '24x7',
  $first_notification_delay = '0',
  $active_checks_enabled = '1',
  $passive_checks_enabled = '1',
  $parallelize_check = '1',
  #$obsess_over_service = '1',
  $check_freshness = '0',
  $notifications_enabled = '1',
  $event_handler_enabled = '0',
  #Optional[String] $event_handler = '',
  $flap_detection_enabled = '1',
  $flap_detection_options = 'o',
  $low_flap_threshold = '0',
  $high_flap_threshold = '0',
  $process_perf_data = '1',
  $retain_status_information = '1',
  $retain_nonstatus_information = '1',
  #$is_volatile = '0',
  $check_interval = '10',
  $retry_interval = '2',
  $contact_groups = 'admins',
  $notification_options = 'w,u,c,r',
  $register = '0',
  $service_description = '',
  $display_name = '',
  $parents = '',
  #$servicegroups = '',
  $initial_state = 'o',
  $freshness_threshold = '0',
  $stalking_options = 'c',
  $notes = '',
  $notes_url = '',
  $action_url = '',
  $use = '',
  $host_name = '',
) {

  include nagios::params

  # figure out where to write the file
  # replace spaces with an underscore and convert 
  # everything to lowercase
/*
$target_path_template = @("END")
<%- | 
  String  $resource_dir,
  String  $type,
  String  $name,
| -%>
"<%= $resource_dir -%>/<%= regsubst($type,'/\\s+/', '_')  -%>_<%= $name.downcase() -%>.cfg"
|-END

*/

  #$target = inline_epp($target_path_template, {'resource_dir' => $nagios::params::resource_dir, 'type' => $type, 'name' => $name})

  #$target = inline_template("${nagios::params::resource_dir}/${type}_${name}.cfg")
  #$target = "${nagios::params::resource_dir}/${type}_${name}.cfg".downcase
  $target = regsubst("${nagios::params::resource_dir}/${type}_${name}.cfg",'\\s+', '_', 'G').downcase
  #$target = inline_template("${nagios::params::resource_dir}/${type}_${::fqdn}.cfg")
  #$target = inline_template("${nagios::params::resource_dir}/${type}_<%=name.gsub(/\\s+/, '_').downcase %>.cfg")

  case $bexport {
    true, false: {}
    default: { fail("The export parameter must be set to true or false.") }
  }

  case $type {
    host: {
      nagios::resource::host { $name:
        ensure => $ensure,
        use => $host_use,
        check_command => $check_command,
        address => $address,
        hostgroups => $hostgroups,
        target => $target,
        bexport => $bexport,
        max_check_attempts => $max_check_attempts,
        check_period => $check_period,
        notification_interval => $notification_interval,
        notification_period => $notification_period,
      }
    }
    passiveservice: {
      nagios::resource::passiveservice { $name:
        host_name => $host_name,
        ensure => $ensure,
        use => $service_use,
        check_command => $check_command,
        #hostgroup_name => $hostgroup_name,
        target => $target,
        bexport => $bexport,
        max_check_attempts => $max_check_attempts,
        check_period => $check_period,
        notification_interval => $notification_interval,
        notification_period => $notification_period,
        first_notification_delay => $first_notification_delay,
        active_checks_enabled => $active_checks_enabled,
        passive_checks_enabled => $passive_checks_enabled,
        #obsess_over_service => $obsess_over_service,
        check_freshness => $check_freshness,
        notifications_enabled => $notifications_enabled,
        event_handler_enabled => $event_handler_enabled,
        #event_handler => $event_handler,
        flap_detection_enabled => $flap_detection_enabled,
        flap_detection_options => $flap_detection_options,
        low_flap_threshold => $low_flap_threshold,
        high_flap_threshold => $high_flap_threshold,
        process_perf_data => $process_perf_data,
        retain_status_information => $retain_status_information,
        retain_nonstatus_information => $retain_nonstatus_information,
        #is_volatile => $is_volatile,
        check_interval => $check_interval,
        retry_interval => $retry_interval,
        contact_groups => $contact_groups,
        notification_options => $notification_options,
        service_description => $service_description,
        display_name => $display_name,
        #parents => $parents,
        #servicegroups => $servicegroups,
        initial_state	=> $initial_state,
        stalking_options => $stalking_options,
        notes => $notes,
        notes_url => $notes_url,
        action_url => $action_url,
      }
    }
    hostgroup: {
      nagios::resource::hostgroup { $name:
        ensure => $ensure,
        target => $target,
        bexport => $bexport,
      }
    }
    default: {
      fail("Unknown type passed to this define: $type")
    }
  }

  # create or export the file resource needed to support 
  # the nagios type above
  nagios::resource::file { $target:
    ensure => $ensure,
    bexport => $bexport,
    resource_tag => "nagios_${type}",
    requires => "Nagios_${type}[${name}]",
  }
}
