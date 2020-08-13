class profile::os::windows::winrm {
  class { 'windows_puppet_certificates':
    manage_master_cert => true,
    manage_client_cert => true,
  }

  unless $facts['puppet_cert_paths']['ca_path'] {
    fail('The "puppet_cert_paths/ca_path" fact from the "puppetlabs-windows_puppet_certificates" module is missing')
  }

  winrmssl { $facts['puppet_cert_paths']['ca_path']:
    ensure  => present,
    issuer  => $facts['puppet_cert_paths']['ca_path'],
    require => Windows_puppet_certificates::Windows_certificate['puppet_master_windows_certificate'],
  }
}
