class nagios::params {

  $resource_dir = '/etc/nagios/resource.d'
  $user = 'nagios'

  case $::operatingsystem {
    centos: {
      $service = 'nagios'
    }
    debian: {
      $service = 'nagios3'
    }
    solaris: {
      $service = 'cswnagios'
    }
    default: {
      fail("This module is not supported on $::operatingsystem")
    }
  }
}
