class base::server {

/*
  dsc_dnsserveraddress { 'configurednsaddress':
    dsc_interfacealias => $facts['networking']['primary'],
    dsc_addressfamily => 'IPv4',
    dsc_address => '192.168.1.131',
    dsc_validate => $true,
  }
*/

#include profile::os::windows::winrm

$setipaddress = '
Clear-DnsClientCache
if (Get-NetAdapter -Name provider){
  $ip = (Get-NetAdapter -Name "Default Switch" | Get-NetIPAddress -AddressFamily IPv4).IPAddress.split(".")[3]

  if (!(Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name "Provider").interfaceindex | ?{$_.ipAddress -eq "10.0.0.$ip"})){

    New-NetIPAddress -IPAddress "10.0.0.$ip" -InterfaceIndex (Get-NetAdapter -Name "Provider").interfaceindex -PrefixLength 24 -verbose
  }
}
Register-DnsClient
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


$ensuredns = '

Clear-DnsClientCache

$NetIPInterface = Get-NetIPInterface -InterfaceAlias "Default Switch" -AddressFamily IPv4

[array] $ServerAddresses = (get-DnsClientServerAddress -InterfaceIndex $NetIPInterface.InterfaceIndex).ServerAddresses

if ($ServerAddresses.count -eq 1 -or $False -eq (Test-NetConnection -ComputerName $ServerAddresses[0] -erroraction silentlycontinue).PingSucceeded){
    
    Set-DnsClientServerAddress -InterfaceIndex $NetIPInterface.InterfaceIndex -ResetServerAddresses

    $IPv4DefaultGateway = (Get-NetIPConfiguration -InterfaceIndex $NetIPInterface.InterfaceIndex).IPv4DefaultGateway.NextHop

    $IPAddress = (Resolve-DnsName dc01.mshome.net).IPAddress

    Set-DnsClientServerAddress -InterfaceIndex $NetIPInterface.InterfaceIndex -ServerAddresses $IPAddress,$IPv4DefaultGateway -verbose
}

Register-DnsClient
'

  file { "c:\\scripts\\ensuredns.ps1" :
    ensure   => present,
    content => $ensuredns,
    require => File[$scripts_dir],
  }


  exec { 'ensurednsadres':
    command     => '& c:\\scripts\\ensuredns.ps1',
    subscribe   => File['c:\\scripts\\ensuredns.ps1'],
    provider => 'powershell',
  }

$ensurejumbopackets = '

if (Get-NetAdapter -Name provider){

  $NetAdapterAdvancedProperty = Get-NetAdapterAdvancedProperty -Name provider -RegistryKeyword "*JumboPacket"

  if ($NetAdapterAdvancedProperty.RegistryValue -ne 9014){
    Set-NetAdapterAdvancedProperty -Name "provider" -RegistryKeyword "*JumboPacket" -Registryvalue 9014
  }

}
'

  $scripts_dir = 'c:\\scripts'

  file { $scripts_dir:
    ensure => directory,
  }

  file { "c:\\scripts\\ensurejumbopackets.ps1" :
    ensure   => present,
    content => $ensurejumbopackets,
    require => File[$scripts_dir],
  }


  exec { 'ensurejumbopackets':
    command     => '& c:\\scripts\\ensurejumbopackets.ps1',
    subscribe   => File['c:\\scripts\\ensurejumbopackets.ps1'],
    provider => 'powershell',
  }

  windowsfeature { 'FS-SMB1':
    ensure => present,
  }

  dsc_computer { 'joindomain':
    dsc_name => $facts['networking']['hostname'],
    dsc_domainname => 'mshome.net',
    dsc_credential => {
        'user'     => 'Administrator@mshome.net',
        'password' => Sensitive('Beheer123')
      },
    require => Exec['ensurednsadres'],
  }



  reboot {'dsc_reboot':
    message => 'DSC has requested a reboot after the domain join',
    when    => pending,
    onlyif => 'pending_domain_join',
  }


  if $os["windows"]["installation_type"] == 'Server Core' {

    package { 'ntop.portable':
      ensure   => installed,
      provider => 'chocolatey',
    }

  }

  $vmservices = ["vmicguestinterface", "vmicheartbeat", "vmickvpexchange", "vmicrdv", "vmicshutdown", "vmictimesync", "vmicvmsession", "vmicvss"]

  service { $vmservices:
    ensure  => running,
    enable  => true,
  }

  if $healthservice['name'] == 'healthservice' {
    service { 'healthservice':
      ensure  => running,
      enable  => true,
    }
  }


}
