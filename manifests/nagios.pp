class nagios::server::standalone {

  require firewall
  include firewall
  include mysql::client

  package { [ "nagios-plugins-all", "nagios-plugins", "nagios-plugins-nrpe", "httpd", "php", "php-mysql", "wget", "perl", "postfix", "php-fpm", "gcc", "glibc" ,"glibc-common", "gd", "gd-devel", "make", "net-snmp", "openssl-devel", "xinetd", "unzip", "gettext", "automake", "autoconf", "net-snmp-utils", "epel-release", "perl-Net-SNMP"]:
    ensure => installed,
  }

  service { 'httpd':
    ensure  => running,
    enable  => true,
  }

  service { 'nagios':
    ensure  => running,
    enable  => true,
    subscribe => Exec['/root/installnagios.sh'],
  }


/*
  service { 'nrpe':
    ensure  => running,
    enable  => true,
  }
*/

$testpath = '#!/bin/bash

if [ -d $1 ]; then
    exit 0
else 
    exit 1
fi
'

$testfile = '#!/bin/sh
if [ -f $1 ]; then
    exit 0
else 
    exit 1
fi
'


$installnagios = '#!/bin/sh

cd ~
curl -L -O https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz
tar xvf nagios-*.tar.gz
cd nagios-*
./configure
make all
make install-groups-users
usermod -a -G nagios apache
make install
make install-daemoninit
make install-commandmode
make install-config
make install-webconf

'
/* 
make install-init

make install-exfoliation
*/

$installnagiosplugins = '#!/bin/sh

cd ~
curl -L -O http://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
tar xvf nagios-plugins-*.tar.gz
cd nagios-plugins-*
./configure
make
make install
'


$installnagiosnrpe = '#!/bin/sh

cd ~
curl -L -O https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.2/nrpe-4.0.2.tar.gz
#https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.3/nrpe-4.0.3.tar.gz
tar xvf nrpe-*.tar.gz
cd nrpe-*
./configure

make all
make install-groups-users
make install
make install-config
make install-inetd
make install-init
'

$installnagiosnrdp = '#!/bin/sh

cd /tmp
wget -O nrdp.tar.gz https://github.com/NagiosEnterprises/nrdp/archive/2.0.3.tar.gz
tar xzf nrdp.tar.gz

cd /tmp/nrdp*
mkdir -p /usr/local/nrdp
cp -r clients server LICENSE* CHANGES* /usr/local/nrdp
chown -R nagios:nagios /usr/local/nrdp 
cp nrdp.conf /etc/httpd/conf.d/nrdp.conf
'

file { "/root/installnagios.sh" :
  ensure   => present,
  content => $installnagios,
  mode => '0655',
}


file { "/usr/local/nagios/libexec/check_ncpa.py" :
  ensure   => present,
  source => 'https://raw.githubusercontent.com/NagiosEnterprises/ncpa/master/client/check_ncpa.py',
  mode => '0755',
  require => Exec['/root/installnagios.sh'],
}



file { "/root/installnagiosplugins.sh" :
  ensure   => present,
  content => $installnagiosplugins,
  mode => '0655',
}

file { "/root/installnagiosnrpe.sh" :
  ensure   => present,
  content => $installnagiosnrpe,
  mode => '0655',
}

file { "/root/installnagiosnrdp.sh" :
  ensure   => present,
  content => $installnagiosnrdp,
  mode => '0655',
}

  file { "/root/testpath.sh" :
    ensure   => present,
    content => $testpath,
    mode => '0655',
  }

file { "/root/testfile.sh" :
  ensure   => present,
  content => $testfile,
  mode => '0655',
}

/*
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
  */

  exec { '/root/installnagios.sh':
    unless => '/root/testpath.sh /root/nagios-*',
    subscribe => [File['/root/installnagios.sh'], Firewall['100 WEB required ports']],
    timeout => 1800,
    notify => Service['httpd'],
  }

  

  exec { '/root/installnagiosplugins.sh':
    unless => '/root/testpath.sh /root/nagios-plugins-*',
    subscribe => [File['/root/installnagiosplugins.sh'], Firewall['100 WEB required ports'], Exec['/root/installnagios.sh']],
    timeout => 1800,
    notify => Service['nagios'],
  }

  

  exec { '/root/installnagiosnrpe.sh':
    unless => '/root/testpath.sh /root/nrpe-*',
    subscribe => [File['/root/installnagiosnrpe.sh'], Firewall['100 WEB required ports'], Exec['/root/installnagiosplugins.sh']],
    timeout => 1800,
  }
  

  exec { '/root/installnagiosnrdp.sh':
    unless => '/root/testpath.sh /tmp/nrdp*',
    subscribe => [File['/root/installnagiosnrdp.sh'], Firewall['100 WEB required ports'], Exec['/root/installnagiosnrpe.sh']],
    timeout => 1800,
    notify => Service['httpd'],
  }

  service { 'nrpe':
    ensure  => running,
    enable  => true,
    subscribe => Exec['/root/installnagiosnrpe.sh'],
  }




  httpauth { 'nagiosadmin':
    username => 'nagiosadmin',
    file     => '/usr/local/nagios/etc/htpasswd.users',
    mode     => '0644',
    password => 'password',
    realm => 'realm',
    mechanism => basic,
    ensure => present,
    subscribe => Exec['/root/installnagios.sh'],
  }

  firewall { '100 WEB required ports':
    dport  => [22, 443, 80, 5666],
    proto  => 'tcp',
    action => 'accept',
  }

  class { 'mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

}


class nagios::server {
  package { ["nagios"]:
    ensure => installed,
  }
  service { 'nagios2':
    ensure  => running,
    enable  => true,
    require => Exec['make-nag-cfg-readable'],
  }

  # This is because puppet writes the config files so nagios can't read them
  exec {'make-nag-cfg-readable':
    command => "find /etc/nagios -type f -name '*cfg' | xargs chmod +r",
    path => ['/usr/bin', '/usr/sbin',],
  }

  file { 'resource-d':
    path   => '/etc/nagios/resource.d',
    ensure => directory,
    owner  => 'nagios',
  }

  # Collect the nagios_host resources
  Nagios_host <<||>> {
    require => File[resource-d],
    notify  => [Exec[make-nag-cfg-readable],Service['nagios2']],
  }
}

/*
class nagios::export {
  @@nagios_host { $::fqdn:
    address       => $::ipaddress,
    check_command => 'check-host-alive!3000.0,80%!5000.0,100%!10',
    hostgroups    => 'all-servers',
    target        => "/etc/nagios/resource.d/host_${::fqdn}.cfg"
  }
}
*/
