

$testpath = '#!/bin/bash

if [ -d $1 ]; then
    exit 0
else 
    exit 1
fi
'

file { "/root/testpath.sh" :
  ensure   => present,
  content => $testpath,
  mode => '0655',
}

exec { 'puppetlabs-firewall':
  command => "/opt/puppetlabs/bin/puppet module install puppetlabs-firewall",
  unless => "/root/testpath.sh '/etc/puppetlabs/code/environments/production/modules/firewall/'",
  subscribe => File['/root/testpath.sh'],
}

exec { 'puppetlabs-reboot':
  command => "/opt/puppetlabs/bin/puppet module install puppetlabs-reboot",
  unless => "/root/testpath.sh '/etc/puppetlabs/code/environments/production/modules/reboot/'",
  subscribe => File['/root/testpath.sh'],
}
