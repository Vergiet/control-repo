class myapache (
  #$updatesys    = $::myapache::params::updatesys,
  $apachename   = $::myapache::params::apachename,
  $conffile   = $::myapache::params::conffile,
  $confsource = $::myapache::params::confsource,
) inherits ::myapache::params {

  include apache

/*
  if $osfamily == 'RedHat' {
     class { 'firewall': } 
    
    class { ['my_fw::pre', 'my_fw::post']: }
    
    Firewall {
      before  => Class['my_fw::post'],
      require => Class['my_fw::pre'],
    }
    
  }
  */

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
    ensure     => running,
    enable     => true,
    require    => Package['apache'],
  }

  firewall { '100 allow http and https access':
    dport  => [80, 443],
    proto  => 'tcp',
    action => 'accept',
  }



}
