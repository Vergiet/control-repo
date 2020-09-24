class ras::multitenant (

) {


  reboot {'pre-reboot':
    message => 'DSC has requested a reboot before installing roles',
    when    => pending,
  }

  $rasroles = ["RemoteAccess","DirectAccess-VPN","Routing", "RSAT-RemoteAccess-PowerShell"]

  windowsfeature { $rasroles:
    ensure => present,
    installsubfeatures => true,
    require => Reboot['pre-reboot'],
    notify => Reboot['after-reboot']
  }

  reboot {'after-reboot':
    message => 'DSC has requested a reboot after installing roles',
    when    => pending,
  }

  exec { 'installvmm':
    command     => 'Install-RemoteAccess -MultiTenancy',
    provider => 'powershell',
    unless => 'if ((get-RemoteAccess).VpnMultiTenancyStatus -eq "installed"){exit} else {exit 1}',
    require => [Windowsfeature['RSAT-RemoteAccess-PowerShell'], Reboot['after-reboot']],
  }

$setipaddress = '
$ip = (Get-NetAdapter -Name "Default Switch" | Get-NetIPAddress -AddressFamily IPv4).IPAddress.split(".")[3]

if (!(Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name "Provider").interfaceindex | ?{$_.ipAddress -eq "10.0.0.$ip"})){

  New-NetIPAddress -IPAddress "10.0.0.$ip" -InterfaceIndex (Get-NetAdapter -Name "Provider").interfaceindex -PrefixLength 24 -verbose
}
'

  file { "c:\\scripts\\setipaddress.ps1" :
    ensure   => present,
    content => $setipaddress,
  }


  exec { 'setipaddress':
    command     => '& c:\\scripts\\setipaddress.ps1',
    require   => File['c:\\scripts\\setipaddress.ps1'],
    provider => 'powershell',
  }


}
