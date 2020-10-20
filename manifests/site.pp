## site.pp ##

# This file (./manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
# https://puppet.com/docs/puppet/latest/dirs_manifest.html
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition if you want to use it.

## Active Configurations ##

# Disable filebucket by default for all File resources:
# https://github.com/puppetlabs/docs-archive/blob/master/pe/2015.3/release_notes.markdown#filebucket-resource-no-longer-created-by-default
File { backup => false }

## Node Definitions ##

# The default node definition matches any node lacking a more specific node
# definition. If there are no other node definitions in this file, classes
# and resources declared in the default node definition will be included in
# every node's catalog.
#
# Note that node definitions in this file are merged with node data from the
# Puppet Enterprise console and External Node Classifiers (ENC's).
#
# For more on node definitions, see: https://puppet.com/docs/puppet/latest/lang_node_definitions.html
node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
   
  #if $osfamily == 'RedHat' {
    /* class { 'firewall': } */
    /*
    class { ['my_fw::pre', 'my_fw::post']: }
    
    Firewall {
      before  => Class['my_fw::post'],
      require => Class['my_fw::pre'],
    }
    */
  #}
  
}




#lookup('classes', {merge => unique}).include

node 'hv01.mshome.net' {

  include site::basic
  include nagios::ncpa
  include base::server
  include hv::baseline

}

node 'hv02.mshome.net' {

    include site::basic
    include nagios::ncpa
  include base::server
  include hv::baseline

}

node 'hv03.mshome.net' {

  include site::basic
  include nagios::ncpa
  include base::server
  include hv::baseline

}

node 'hv04.mshome.net' {

  include site::basic
  include nagios::ncpa
  include base::server
  include hv::baseline

}

node 'hv05.mshome.net' {

  include site::basic
  include nagios::ncpa
  include base::server
  include hv::baseline

}


node 'hv06.mshome.net' {

  include site::basic
  include nagios::ncpa
  include base::server
  include hv::baseline

}


node 'wac01.mshome.net' {

  include site::basic
  require temp::folder
  include nagios::ncpa
  include base::server
  include wac

}


node 'vmm01.mshome.net' {

  include site::basic
  include base::server
  include nagios::ncpa
  require sql2019::standalone
  require temp::folder
  include vmm::master

}


node 'scom01.mshome.net' {

  include site::basic
  include base::server
  include nagios::ncpa
  require sql2016::standalone
  require temp::folder
  include scom::master

}

node 'dc01.mshome.net' {

  #include site::basic
  #include nagios::ncpa
  include site::basic
  include ad::pdc
}


node 'ras01.mshome.net' {

  include site::basic
  include base::server
  include nagios::ncpa
  require temp::folder
  include ras::multitenant
}

node /^nagios\..*/ {

  #$my_nagios_purge_hosts = [ 'VM01.mshome.net' ]
  #$my_nagios_purge_hosts = 'VM01.mshome.net'

  include nagios::server::standalone
  #include nagios::server
  include nagios::export
}





node 'dc01.management.lan' {

  #include site::basic
  #include nagios::ncpa
  include site::basic
  include ad::pdc
}





node 'hv01.management.lan' {

  include site::basic
  include nagios::ncpa
  include base::server
  include hv::baseline

}

node 'hv02.management.lan' {

  include site::basic
  include nagios::ncpa
  include base::server
  include hv::baseline

}

node 'hv03.management.lan' {

  include site::basic
  include nagios::ncpa
  include base::server
  include hv::baseline

}
