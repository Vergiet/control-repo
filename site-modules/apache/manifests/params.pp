class apache::params {

  if $osfamily == 'RedHat' {
    $apachename = 'httpd'
    $conffile     = '/etc/httpd/conf/httpd.conf'
    $confsource   = 'puppet:///modules/apache/httpd.conf'
  }

}

