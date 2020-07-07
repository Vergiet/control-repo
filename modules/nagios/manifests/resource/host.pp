define nagios::resource::host(
  $address,
  $hostgroups,
  $bexport,
  $target,
  $check_command,
  $use,
  $ensure = 'present'
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
    }
  }
}
