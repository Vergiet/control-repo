class wac (

) {

  /*
    file { 'c:\\temp\\WindowsAdminCenter2007.msi':
      ensure => present,
      path => 'c:\\temp\\WindowsAdminCenter2007.msi',
      source => 'https://download.microsoft.com/download/1/0/5/1059800B-F375-451C-B37E-758FFC7C8C8B/WindowsAdminCenter2007.msi',
    }


    exec { 'installwac':
      command     => 'msiexec /i c:\\temp\\WindowsAdminCenter2007.msi /qn /L*v log.txt SME_PORT=443 SSL_CERTIFICATE_OPTION=generate',
      subscribe   => File['c:\\temp\\WindowsAdminCenter2007.msi'],
      provider => 'powershell',
      unless => 'if (Test-Path -Path "c:\\Program Files\\Windows Admin Center" -PathType Container){exit} else {exit 1}',
      require => File['c:\\temp\\WindowsAdminCenter2007.msi'],
    }

    */

    package { 'windows-admin-center':
      ensure   => installed,
      provider => 'chocolatey',
    }

    service { 'ServerManagementGateway':
      ensure  => running,
      enable  => true,
      require => Package['windows-admin-center'],
    }


}
