# This class will be used by the nagios server
# https://www.linuxjournal.com/content/puppet-and-nagios-roadmap-advanced-configuration
class nagios {

  include nagios::params
  require nagios::expire_resources
  include nagios::purge_resources

  service { $nagios::params::service:
    ensure => running,
    enable => true,
  }

  # nagios.cfg needs this specified via the cfg_dir directive
  file { $nagios::params::resource_dir:
    ensure => directory,
    owner => $nagios::params::user,
  }

  # Local Nagios resources
  nagios::resource { [ 'all-servers' ]:
    type => hostgroup,
    bexport => false;
  }
}
