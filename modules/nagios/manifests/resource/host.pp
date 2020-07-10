define nagios::resource::host(
  $address,
  $hostgroups,
  $bexport,
  $target,
  $check_command,
  $use,
  $ensure = 'present'
  $max_check_attempts = '5',
  $check_period = '24x7',
  $notification_interval = '30',
  $notification_period = '24x7',
) {

  include nagios::params

  if $bexport {

    @@nagios_host { $name:
      ensure => $ensure,
      address => $address,
      check_command => $check_command,
      use => $use,
      target => $target,
      hostgroups => $hostgroups ? {
        '' => undef,
        default => $hostgroups,
      },
      max_check_attempts => $max_check_attempts,
      check_period => $check_period,
      notification_interval => $notification_interval,
      notification_period => $notification_period,
    }
  } else {

    nagios_host { $name:
      ensure => $ensure,
      address => $address,
      check_command => $check_command,
      use => $use,
      target => $target,
      require => File[$nagios::params::resource_dir],
      hostgroups => $hostgroups ? {
        '' => undef,
        default => $hostgroups,
      },
      max_check_attempts => $max_check_attempts,
      check_period => $check_period,
      notification_interval => $notification_interval,
      notification_period => $notification_period,
    }
  }
}
