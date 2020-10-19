class ad::pdc (
  String $ntds_dir = 'c:\\NTDS',
){


$domain = 'management.lan'


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
      dsc_domainname                    => $domain,
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

  service { 'puppet':
    ensure  => running,
    enable  => 'manual',
  }


$ensuredns = '

$domain = "management.lan"

[array] $Names += [pscustomobject]@{name = "pmom01"; ip = ""}
[array] $Names += [pscustomobject]@{name = "nagios"; ip = ""}
[array] $Names += [pscustomobject]@{name = "Cluster02"; ip = "192.168.4.50"}

#$NetIPInterface = Get-NetIPInterface -InterfaceAlias "Default Switch" -AddressFamily IPv4
$NetIPInterface = Get-NetIPInterface -InterfaceAlias "Management" -AddressFamily IPv4
$IPv4DefaultGateway = (Get-NetIPConfiguration -InterfaceIndex $NetIPInterface.InterfaceIndex).IPv4DefaultGateway.NextHop

$Name = $Names[2]

foreach ($Name in $Names){

    $DnsName = ("{0}.$domain" -f $Name.name)
  if ([string]::isnullorempty($Name.ip)){
  
  $IPAddress = (Resolve-DnsName -name $DnsName -Server $IPv4DefaultGateway).IPAddress
  } else {
    $IPAddress = $Name.ip
  }



  $DnsServerResourceRecord = Get-DnsServerResourceRecord -Name $Name.name -ZoneName $domain -ErrorAction SilentlyContinue

  if ($null -eq $DnsServerResourceRecord -or $DnsServerResourceRecord.RecordData.IPv4Address.IPAddressToString -ne $IPAddress){

      if ($null -ne $DnsServerResourceRecord){
          Remove-DnsServerResourceRecord -ZoneName $domain -Name $Name.name -RRType "A" -Confirm:$False -force

          #restart-computer
      }

      Add-DnsServerResourceRecordA -Name $Name.name -ZoneName $domain -IPv4Address $IPAddress

  }

}
'

$ensurednsforwarder = '

$domain = "management.lan"

#$NetIPInterface = Get-NetIPInterface -InterfaceAlias "Default Switch" -AddressFamily IPv4
$NetIPInterface = Get-NetIPInterface -InterfaceAlias "Management" -AddressFamily IPv4
$IPv4DefaultGateway = (Get-NetIPConfiguration -InterfaceIndex $NetIPInterface.InterfaceIndex).IPv4DefaultGateway.NextHop

if ($IPv4DefaultGateway -ne (get-DnsServerForwarder).IPAddress.IPAddressToString){
    
    Set-DnsServerForwarder -IPAddress $IPv4DefaultGateway
}

'

$configureScavaging = '
$GetDnsServerScavenging = Get-DnsServerScavenging 

$scavagingtime = (New-TimeSpan -Start (get-date).AddHours(-1) -End (get-date))

$setDnsServerScavenging = @{}

if ($GetDnsServerScavenging.ScavengingState -eq $False){

    $setDnsServerScavenging.ScavengingState = $True
}

if ($GetDnsServerScavenging.RefreshInterval -ne $scavagingtime){

    $setDnsServerScavenging.RefreshInterval = $scavagingtime
}


if ($GetDnsServerScavenging.RefreshInterval -ne $scavagingtime){

    $setDnsServerScavenging.RefreshInterval = $scavagingtime
}

if ($GetDnsServerScavenging.ScavengingInterval -ne $scavagingtime){

    $setDnsServerScavenging.ScavengingInterval = $scavagingtime
}

if ($GetDnsServerScavenging.NoRefreshInterval -ne $scavagingtime){

    $setDnsServerScavenging.NoRefreshInterval = $scavagingtime
}

if ($setDnsServerScavenging.Keys.Count -gt 0){
    Set-DnsServerScavenging -ApplyOnAllZones @setDnsServerScavenging -Verbose
}
'

$task = '
Start-Sleep -seconds 200

$domain = "management.lan"

#$NetIPInterface = Get-NetIPInterface -InterfaceAlias "Default Switch" -AddressFamily IPv4
$NetIPInterface = Get-NetIPInterface -InterfaceAlias "Management" -AddressFamily IPv4
$IPv4DefaultGateway = (Get-NetIPConfiguration -InterfaceIndex $NetIPInterface.InterfaceIndex).IPv4DefaultGateway.NextHop

if ($IPv4DefaultGateway -ne (get-DnsServerForwarder).IPAddress.IPAddressToString){
    
    Set-DnsServerForwarder -IPAddress $IPv4DefaultGateway -Verbose
}

$GetDnsServerScavenging = Get-DnsServerScavenging 

$scavagingtime = (New-TimeSpan -Start (get-date).AddHours(-4) -End (get-date))

$setDnsServerScavenging = @{}

if ($GetDnsServerScavenging.ScavengingState -eq $False){

    $setDnsServerScavenging.ScavengingState = $True
}

if ($GetDnsServerScavenging.RefreshInterval -ne $scavagingtime){

    $setDnsServerScavenging.RefreshInterval = $scavagingtime
}


if ($GetDnsServerScavenging.RefreshInterval -ne $scavagingtime){

    $setDnsServerScavenging.RefreshInterval = $scavagingtime
}

if ($GetDnsServerScavenging.ScavengingInterval -ne $scavagingtime){

    $setDnsServerScavenging.ScavengingInterval = $scavagingtime
}

if ($GetDnsServerScavenging.NoRefreshInterval -ne $scavagingtime){

    $setDnsServerScavenging.NoRefreshInterval = $scavagingtime
}

if ($setDnsServerScavenging.Keys.Count -gt 0){
    Set-DnsServerScavenging -ApplyOnAllZones @setDnsServerScavenging -Verbose
}

Start-DnsServerScavenging -Force -verbose


[array] $Names += [pscustomobject]@{name = "pmom01"; ip = ""}
[array] $Names += [pscustomobject]@{name = "nagios"; ip = ""}
[array] $Names += [pscustomobject]@{name = "Cluster02"; ip = "192.168.4.50"}

#$NetIPInterface = Get-NetIPInterface -InterfaceAlias "Default Switch" -AddressFamily IPv4
$NetIPInterface = Get-NetIPInterface -InterfaceAlias "Management" -AddressFamily IPv4
$IPv4DefaultGateway = (Get-NetIPConfiguration -InterfaceIndex $NetIPInterface.InterfaceIndex).IPv4DefaultGateway.NextHop

$Name = $Names[2]

foreach ($Name in $Names){

    $DnsName = ("{0}.$domain" -f $Name.name)
    $DnsName
  if ([string]::isnullorempty($Name.ip)){
  
  $IPAddress = (Resolve-DnsName -name $DnsName -Server $IPv4DefaultGateway -ErrorAction SilentlyContinue).IPAddress
  } else {
    $IPAddress = $Name.ip
    
  }

  $IPAddress 


  if (-not ([string]::IsNullOrEmpty($IPAddress))){
      $DnsServerResourceRecord = Get-DnsServerResourceRecord -Name $Name.name -ZoneName $domain -ErrorAction SilentlyContinue
      $DnsServerResourceRecord

      if ($null -eq $DnsServerResourceRecord -or $DnsServerResourceRecord.RecordData.IPv4Address.IPAddressToString -ne $IPAddress){

          if ($null -ne $DnsServerResourceRecord){
              Remove-DnsServerResourceRecord -ZoneName $domain -Name $Name.name -RRType "A" -Confirm:$False -force -verbose

              #restart-computer
          }

          Add-DnsServerResourceRecordA -Name $Name.name -ZoneName $domain -IPv4Address $IPAddress -verbose

      }
  }

}

ipconfig /flushdns

'

$configtask = '

$Script = "C:\scripts\Task.ps1"

if (!(Get-ScheduledTask | ?{$_.TaskName -eq (split-path -Leaf $Script)})){

    
    $Trigger= New-ScheduledTaskTrigger -AtStartup  # Specify the trigger settings
    $User= "NT AUTHORITY\SYSTEM" # Specify the account to run the script
    $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $Script # Specify what program to run and with its parameters
    Register-ScheduledTask -TaskName (split-path -Leaf $Script) -Trigger $Trigger -User $User -Action $Action -RunLevel Highest 

}
'


$setipaddress = '

if (!(Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name "Provider").interfaceindex | ?{$_.ipAddress -eq "10.0.0.2"})){

  New-NetIPAddress -IPAddress "10.0.0.2" -InterfaceIndex (Get-NetAdapter -Name "Provider").interfaceindex -PrefixLength 24 -verbose
}

if (!(Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name "Management").interfaceindex | ?{$_.ipAddress -eq "192.168.4.2"})){

  New-NetIPAddress -IPAddress "192.168.4.2" -InterfaceIndex (Get-NetAdapter -Name "Management").interfaceindex -PrefixLength 24 -verbose
}
'


  file { "c:\\scripts\\configtask.ps1" :
    ensure   => present,
    content => $configtask,
    require => File[$scripts_dir],
  }


  file { "c:\\scripts\\task.ps1" :
    ensure   => present,
    content => $task,
    require => File[$scripts_dir],
  }

  file { "c:\\fsw" :
    ensure   => directory,
  }


  file { "c:\\scripts\\setipaddress.ps1" :
    ensure   => present,
    content => $setipaddress,
    require => File[$scripts_dir],
  }

  fileshare { 'fsw':
    ensure  => present,
    path    => 'C:\\fsw',
    require => File["c:\\fsw"],
  }


  exec { 'setipaddress' :
    command     => '& c:\\scripts\\setipaddress.ps1',
    subscribe   => File['c:\\scripts\\setipaddress.ps1'],
    provider => 'powershell',
    require => [Dsc_xaddomain['firstdc'], File["c:\\scripts\\setipaddress.ps1"]],
  }

  exec { 'task' :
    command     => '& c:\\scripts\\task.ps1',
    subscribe   => File['c:\\scripts\\task.ps1'],
    provider => 'powershell',
    require => [Dsc_xaddomain['firstdc'], File["c:\\scripts\\task.ps1"]],
  }

  exec { 'configtask' :
    command     => '& c:\\scripts\\configtask.ps1',
    subscribe   => File['c:\\scripts\\configtask.ps1'],
    provider => 'powershell',
    require => [Dsc_xaddomain['firstdc'], File["c:\\scripts\\configtask.ps1"], File["c:\\scripts\\task.ps1"]],
  }

  reboot {'dsc_reboot':
    message => 'DSC has requested a reboot',
    when    => pending,
  }


$path = "CN=Users,DC=management,DC=lan"


  windows_ad::group{'Network Controller Admins':
    ensure               => present,
    displayname          => 'Network Controller Admins',
    path                 => $path,
    groupname            => 'Network Controller Admins',
    groupscope           => 'Global',
    groupcategory        => 'Security',
    description          => 'Network Controller Admins group',
    require => Dsc_xaddomain['firstdc'],
  }


  windows_ad::group{'NetworkControllers':
    ensure               => present,
    displayname          => 'NetworkControllers',
    path                 => $path,
    groupname            => 'NetworkControllers',
    groupscope           => 'Global',
    groupcategory        => 'Security',
    description          => 'NetworkControllers group',
    require => Dsc_xaddomain['firstdc'],
  }


  windows_ad::group{'Network Controller Users':
    ensure               => present,
    displayname          => 'Network Controller Users',
    path                 => $path,
    groupname            => 'Network Controller Users',
    groupscope           => 'Global',
    groupcategory        => 'Security',
    description          => 'Network Controller Users group',
    require => Dsc_xaddomain['firstdc'],
  }




  }

}
