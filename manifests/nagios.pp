class nagios::server::standalone {

  include mysql::server
  include mysql::client

  package { ["nagios", "nagios-plugins", "nagios-plugins-nrpe", "httpd", "php", "php-mysql", "php-fpm", "gcc", "glibc" ,"glibc-common", "gd", "gd-devel", "make", "net-snmp", "openssl-devel", "xinetd", "unzip"]:
    ensure => installed,
  }

  service { 'httpd':
    ensure  => running,
    enable  => true,
  }

/*
  service { 'nrpe':
    ensure  => running,
    enable  => true,
  }
  */


  group { 'nagcmd':
    ensure   => present,
  }

  user { 'nagios':
    ensure   => present,
    password => Sensitive("password"),
    groups => 'nagcmd',
    subscribe => Group['nagcmd'],
  }

  user { 'apache':
    ensure   => present,
    groups => 'nagcmd',
    subscribe => Group['nagcmd'],
  }






  firewall { '100 WEB required ports':
    dport  => [22, 443, 80, 5666],
    proto  => 'tcp',
    action => 'accept',
    subscribe => Service['httpd'],
  }

  class { 'mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

/*

  service { 'mariadb':
    ensure  => running,
    enable  => true,
  }

  */




/*

  package { ["httpd","mariadb-server","mariadb", "php", "php-mysql", "php-fpm", "gcc", "glibc" ,"glibc-common", "gd", "gd-devel", "make", "net-snmp", "openssl-devel", "xinetd", "unzip"]:
    ensure => installed,
  }

  */

/*
  service { nagios:
    ensure  => running,
    enable  => true,
    require => Exec['make-nag-cfg-readable'],
  }
  */

/*
  # This is because puppet writes the config files so nagios can't read them
  exec {'make-nag-cfg-readable':
    command => "find /etc/nagios -type f -name '*cfg' | xargs chmod +r",
  }
  */

/*
  file { 'resource-d':
    path   => '/etc/nagios/resource.d',
    ensure => directory,
    owner  => 'nagios',
  }
  */





}


