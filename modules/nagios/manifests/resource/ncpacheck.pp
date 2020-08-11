define nagios::resource::ncpacheck(
  #$resource_tag,
  #$requires,
  #$bexport = true,
  $ensure = 'present',
  #$check_command,
) {

  include nagios::params

  $check_command = '%HOSTNAME%|<%= $name %> = cpu/percent --warning 80 --critical 90 --aggregate avg'
  $rendered_command = inline_epp($check_command, {'name' => $name})
  $filename = regsubst($name,'\\s+', '_', 'G').downcase
  file { "C:\\Program Files (x86)\\Nagios\\NCPA\\etc\\ncpa.cfg.d\\service_${filename}.cfg":
    ensure => $ensure,
    content => "[passive checks]\r${rendered_command}",
  }
}


