class my_apache (
  #$updatesys    = $::my_apache::params::updatesys,
  $apachename   = $::my_apache::params::apachename,
  $conffile   = $::my_apache::params::conffile,
  $confsource = $::my_apache::params::confsource,
) inherits ::my_apache::params {

  include appache

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
