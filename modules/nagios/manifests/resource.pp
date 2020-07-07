define nagios::resource(
  $bexport,
  $type,
  $host_use = 'generic-host',
  $ensure = 'present',
  $owner = 'nagios',
  $address = '',
  $hostgroups = '',
  $check_command = ''
) {

  include nagios::params

  # figure out where to write the file
  # replace spaces with an underscore and convert 
  # everything to lowercase
  $target = inline_template("${nagios::params::resource_dir}/${type}_<%=name.gsub(/\\s+/, '_').downcase %>.cfg")

  case $bexport {
    true, false: {}
    default: { fail("The export parameter must be set to true or false.") }
  }

  case $type {
    host: {
      nagios::resource::host { $name:
        ensure => $ensure,
        use => $host_use,
        check_command => $check_command,
        address => $address,
        hostgroups => $hostgroups,
        target => $target,
        bexport => $bexport,
      }
    }
    hostgroup: {
      nagios::resource::hostgroup { $name:
        ensure => $ensure,
        target => $target,
        bexport => $bexport,
      }
    }
    default: {
      fail("Unknown type passed to this define: $type")
    }
  }

  # create or export the file resource needed to support 
  # the nagios type above
  nagios::resource::file { $target:
    ensure => $ensure,
    bexport => $bexport,
    resource_tag => "nagios_${type}",
    requires => "Nagios_${type}[${name}]",
  }
}
