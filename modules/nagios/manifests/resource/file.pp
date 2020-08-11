define nagios::resource::file(
  $resource_tag,
  $requires,
  $bexport = true,
  $ensure = 'present',
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
    }
  } else {

    #file { $name.downcase:
    file { $name:
      ensure => $ensure,
      tag => $resource_tag,
      owner => $nagios::params::user,
      group => $nagios::params::user,
      require => $requires,
    }
  }
}
