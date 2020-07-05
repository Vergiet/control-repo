class nagiosxi::server::standalone {

  exec { 'curl https://assets.nagios.com/downloads/nagiosxi/install.sh | sh':
    timeout => 1800,
    path => ['/usr/bin', '/usr/sbin',],
    unless => 'test -f /tmp/nagiosxi/install.log',
  }

}
