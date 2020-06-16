class apache::standalone (
  # $updatesys    = $::apache::standalone::params::updatesys,
  $apachename   = $::apache::standalone::params::apachename,
  $conffile   = $::apache::standalone::params::conffile,
  $confsource = $::apache::standalone::params::confsource,
) inherits ::apache::standalone::params {

  package { 'apache':
    name    => $apachename,
    ensure  => present,
  }

  file { 'configuration-file':
    path    => $conffile,
    ensure  => file,
    source  => $confsource,
    notify  => Service['apache-service'],
  }

  service { 'apache-service':
    name	  => $apachename,
    hasrestart	  => true,
  }

}
