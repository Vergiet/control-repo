class apache (
  #$updatesys    = $::my_apache::params::updatesys,
  $apachename   = $::apache::params::apachename,
  $conffile   = $::apache::params::conffile,
  $confsource = $::apache::params::confsource,
) inherits ::apache::params {


  include apache

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

  firewall { '100 allow http and https access':
    dport  => [80, 443],
    proto  => 'tcp',
    action => 'accept',
  }

}
