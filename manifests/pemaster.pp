
/*
  cron { 'install-invoke-puppet-at-reboot':
    command => 'puppet apply /root/pemaster.pp',
    user    => 'root',
    special    => 'reboot',
    ensure => present,
    #unless => '/root/testpath.sh',
  }
  */


  file { "/etc/sysconfig/network-scripts/ifcfg-eth0" :
    ensure   => present,
    source => '/root/ifcfg-eth0',
  }

  exec { 'pmom01.vrgt.xyz':
    command => "/usr/bin/hostnamectl set-hostname PMoM01.vrgt.xyz",
    unless => "/usr/bin/test `/usr/bin/hostname` = 'pmom01.vrgt.xyz'"
  }

  reboot { 'after':
    subscribe => Exec['pmom01.vrgt.xyz'],
  }

  $peurl = "https://s3.amazonaws.com/pe-builds/released/2019.7.0/puppet-enterprise-2019.7.0-el-7-x86_64.tar.gz"

  file { "/root/puppet-enterprise-2019.7.0-el-7-x86_64.tar.gz" :
      ensure   => present,
      source => $peurl,
  }

  exec { "/root/puppet-enterprise-2019.7.0-el-7-x86_64.tar.gz":
    command => "tar zxf /root/puppet-enterprise-2019.7.0-el-7-x86_64.tar.gz",
    path => "/usr/bin/",
    unless => '/root/testpath2.sh',
    subscribe => File["/root/puppet-enterprise-2019.7.0-el-7-x86_64.tar.gz"],
  }

  firewall { '100 PE required ports':
    dport  => [22, 443, 4432, 4433, 5432, 8080, 8081, 8140, 8142, 8143, 8170],
    proto  => 'tcp',
    action => 'accept',
    subscribe => Exec["/root/puppet-enterprise-2019.7.0-el-7-x86_64.tar.gz"],
  }

  exec { '/root/startinstall.sh':
    unless => '/root/testpath.sh',
    subscribe => Firewall['100 PE required ports'],
  }
