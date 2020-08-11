class nagios::collect_resources {

  include nagios::params

  Nagios_host <<||>> {
    require => File[$nagios::params::resource_dir],
    notify => Service[$nagios::params::service],
  }

  Nagios_service <<||>> {
    require => File[$nagios::params::resource_dir],
    notify => Service[$nagios::params::service],
  }

  File <<| tag == nagios_host |>> {
    notify => Service[$nagios::params::service],
  }

  File <<| tag == nagios_service |>> {
    notify => Service[$nagios::params::service],
  }

/*
  File <<| tag == nagios_passiveservice |>> {
    notify => Service[$nagios::params::service],
  }
*/

}
