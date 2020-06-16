class nagios::server {



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


