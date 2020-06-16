class myapache (
  #$updatesys    = $::myapache::params::updatesys,
  $apachename   = $::myapache::params::apachename,
  $conffile   = $::myapache::params::conffile,
  $confsource = $::myapache::params::confsource,
) inherits ::myapache::params {

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
