class ad::pdc (
  String $ntds_dir = 'c:\\NTDS',
){
  if $osfamily == 'windows' {

    file {[$ntds_dir,]:
      ensure   => directory,
    }

    dsc_windowsfeature  { 'addsinstall':
      dsc_ensure => 'Present',
      dsc_name   => 'AD-Domain-Services',
    }

    dsc_windowsfeature  {'addstools':
      dsc_ensure => 'Present',
      dsc_name   => 'RSAT-ADDS',
    }

    dsc_xaddomain   { 'firstdc':
      subscribe                         => Dsc_windowsfeature['addsinstall'],
      dsc_domainname                    => 'mshome.net',
      dsc_domainadministratorcredential => {
        'user'     => 'pagent',
        'password' => Sensitive('Test12341234')
      },
      dsc_safemodeadministratorpassword => {
        'user'     => 'pagent',
        'password' => Sensitive('Test12341234')
      },
      dsc_databasepath                  => $ntds_dir,
      dsc_logpath                       => $ntds_dir,

    }

  $scripts_dir = 'c:\\scripts'

  file { $scripts_dir:
    ensure => directory,
  }

$ensurepmom01 = '
$NetIPInterface = (Get-NetIPInterface -AddressFamily ipv4 | ?{$_.InterfaceAlias -notlike "Loopback*" -and $_.ConnectionState -eq "Connected"})[0]
$IPv4DefaultGateway = (Get-NetIPConfiguration -InterfaceIndex $NetIPInterface.InterfaceIndex).IPv4DefaultGateway.NextHop

$IPAddress = (Resolve-DnsName -name pmom01.mshome.net -Server $IPv4DefaultGateway).IPAddress

$DnsServerResourceRecord = Get-DnsServerResourceRecord -Name pmom01 -ZoneName mshome.net -ErrorAction SilentlyContinue

if ($null -eq $DnsServerResourceRecord -or $DnsServerResourceRecord.RecordData -ne $IPAddress){

    if ($null -ne $DnsServerResourceRecord){
        Remove-DnsServerResourceRecord -ZoneName mshome.net -Name pmom01 -RRType "A" -Confirm:$False -force
    }

    Add-DnsServerResourceRecordA -Name pmom01 -ZoneName mshome.net -IPv4Address $IPAddress

}

'

$ensurenagios = '

$NetIPInterface = (Get-NetIPInterface -AddressFamily ipv4 | ?{$_.InterfaceAlias -notlike "Loopback*" -and $_.ConnectionState -eq "Connected"})[0]
$IPv4DefaultGateway = (Get-NetIPConfiguration -InterfaceIndex $NetIPInterface.InterfaceIndex).IPv4DefaultGateway.NextHop

$IPAddress = (Resolve-DnsName -name nagios.mshome.net -Server $IPv4DefaultGateway).IPAddress

$DnsServerResourceRecord = Get-DnsServerResourceRecord -Name nagios -ZoneName mshome.net -ErrorAction SilentlyContinue

if ($null -eq $DnsServerResourceRecord -or $DnsServerResourceRecord.RecordData -ne $IPAddress){

    if ($null -ne $DnsServerResourceRecord){
        Remove-DnsServerResourceRecord -ZoneName mshome.net -Name nagios -RRType "A" -Confirm:$False -force
    }

    Add-DnsServerResourceRecordA -Name nagios -ZoneName mshome.net -IPv4Address $IPAddress

}

'

$ensurednsforwarder = '
$NetIPInterface = (Get-NetIPInterface -AddressFamily ipv4 | ?{$_.InterfaceAlias -notlike "Loopback*" -and $_.ConnectionState -eq "Connected"})[0]
$IPv4DefaultGateway = (Get-NetIPConfiguration -InterfaceIndex $NetIPInterface.InterfaceIndex).IPv4DefaultGateway.NextHop

if ($IPv4DefaultGateway -ne (get-DnsServerForwarder).IPAddress.IPAddressToString){
    
    Set-DnsServerForwarder -IPAddress $IPv4DefaultGateway
}

'

$configtasks = '
$Scripts = @(
    "C:\\scripts\\ensurednsforwarder.ps1"
    "C:\\scripts\\ensurenagios.ps1"
    "C:\\scripts\\ensurepmom01.ps1"
)

Foreach ($Script in $Scripts){

    $Trigger= New-ScheduledTaskTrigger -AtStartup  # Specify the trigger settings
    $User= "NT AUTHORITY\SYSTEM" # Specify the account to run the script
    $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $Script # Specify what program to run and with its parameters
    Register-ScheduledTask -TaskName (split-path -Leaf $Script) -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force # Specify the name of the task


}

'

  file { "c:\\scripts\\ensurepmom01.ps1" :
    ensure   => present,
    content => $ensurepmom01,
    require => File[$scripts_dir],
  }

  file { "c:\\scripts\\ensurenagios.ps1" :
    ensure   => present,
    content => $ensurenagios,
    require => File[$scripts_dir],
  }

  file { "c:\\scripts\\ensurednsforwarder.ps1" :
    ensure   => present,
    content => $ensurednsforwarder,
    require => File[$scripts_dir],
  }

  file { "c:\\scripts\\configtasks.ps1" :
    ensure   => present,
    content => $configtasks,
    require => File[$scripts_dir],
  }

  exec { 'configtasks':
    command     => '& c:\\scripts\\configtasks.ps1',
    subscribe   => File['c:\\scripts\\configtasks.ps1'],
    provider => 'powershell',
    require => Dsc_xaddomain['firstdc'],
  }

    reboot {'dsc_reboot':
      message => 'DSC has requested a reboot',
      when    => pending,
    }
  }
}
