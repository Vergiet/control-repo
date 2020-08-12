define nagios::resource::file(
  $resource_tag,
  $requires,
  $bexport = true,
  $ensure = 'present',
  $purge = true,
) {

  include nagios::params

  if $bexport {

    #@@file { $name.downcase:
    @@file { $name:
      ensure => $ensure,
      tag => $resource_tag,
      owner => $nagios::params::user,
      group => $nagios::params::user,
      require => $requires,
      purge => $purge,
    }
  } else {

    #file { $name.downcase:
    file { $name:
      ensure => $ensure,
      tag => $resource_tag,
      owner => $nagios::params::user,
      group => $nagios::params::user,
      require => $requires,
      purge => $purge,
    }
  }
}
