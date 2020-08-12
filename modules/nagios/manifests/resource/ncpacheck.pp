define nagios::resource::ncpacheck(
  #$resource_tag,
  #$requires,
  #$bexport = true,
  $ensure = 'present',
  $check_command,
) {

  include nagios::params

  $rendered_command = inline_epp($check_command, {'name' => $name})
  $filename = regsubst($name,'\\s+', '_', 'G').downcase
  file { "C:\\Program Files (x86)\\Nagios\\NCPA\\etc\\ncpa.cfg.d\\service_${filename}.cfg":
    ensure => $ensure,
    content => "[passive checks]\n${rendered_command}",
  }
}


