define nagios::resource::hostgroup(
  $target,
  $ensure = 'present',
  $hostgroup_alias = '',
  $bexport = false
) {

  include nagios::params

  if $bexport {
    fail("It is not appropriate to export the Nagios_hostgroup 
↪type since it will result in duplicate resources.")
  } else {
    nagios_hostgroup { $name:
      ensure => $ensure,
      target => $target,
      require => File[$nagios::params::resource_dir],
    }
  }
}
