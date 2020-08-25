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

node 'vm01.mshome.net' {

  include site::basic
  include nagios::ncpa
  require sql::standalone
  require temp::folder
  include base::server
  include vmm::master

}

node 'dc01.mshome.net' {

  #include site::basic
  #include nagios::ncpa
  include site::basic
  include ad::pdc
}

node /^nagios\..*/ {

  #$my_nagios_purge_hosts = [ 'VM01.mshome.net' ]
  #$my_nagios_purge_hosts = 'VM01.mshome.net'

  include nagios::server::standalone
  #include nagios::server
  include nagios::export
}

