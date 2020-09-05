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

$ensuredns = '

[array] $Names += [pscustomobject]@{name = "pmom01"; ip = ""}
[array] $Names += [pscustomobject]@{name = "nagios"; ip = ""}
[array] $Names += [pscustomobject]@{name = "Cluster01"; ip = "192.168.1.13"}

$NetIPInterface = Get-NetIPInterface -InterfaceAlias "Default Switch" -AddressFamily IPv4
$IPv4DefaultGateway = (Get-NetIPConfiguration -InterfaceIndex $NetIPInterface.InterfaceIndex).IPv4DefaultGateway.NextHop

$Name = $Names[2]

foreach ($Name in $Names){

    $DnsName = ("{0}.mshome.net" -f $Name.name)
  if ([string]::isnullorempty($Name.ip)){
  
  $IPAddress = (Resolve-DnsName -name $DnsName -Server $IPv4DefaultGateway).IPAddress
  } else {
    $IPAddress = $Name.ip
  }



  $DnsServerResourceRecord = Get-DnsServerResourceRecord -Name $Name.name -ZoneName mshome.net -ErrorAction SilentlyContinue

  if ($null -eq $DnsServerResourceRecord -or $DnsServerResourceRecord.RecordData.IPv4Address.IPAddressToString -ne $IPAddress){

      if ($null -ne $DnsServerResourceRecord){
          Remove-DnsServerResourceRecord -ZoneName mshome.net -Name $Name.name -RRType "A" -Confirm:$False -force

          #restart-computer
      }

      Add-DnsServerResourceRecordA -Name $Name.name -ZoneName mshome.net -IPv4Address $IPAddress

  }

}
'

$ensurednsforwarder = '
$NetIPInterface = Get-NetIPInterface -InterfaceAlias "Default Switch" -AddressFamily IPv4
$IPv4DefaultGateway = (Get-NetIPConfiguration -InterfaceIndex $NetIPInterface.InterfaceIndex).IPv4DefaultGateway.NextHop

if ($IPv4DefaultGateway -ne (get-DnsServerForwarder).IPAddress.IPAddressToString){
    
    Set-DnsServerForwarder -IPAddress $IPv4DefaultGateway
}

'

$configtasks = '
$Scripts = @(
    "C:\\scripts\\01_ensurednsforwarder.ps1"
    "C:\\scripts\\02_ensurenagios.ps1"
    "C:\\scripts\\03_ensurepmom01.ps1"
)

Foreach ($Script in $Scripts){

    $Trigger= New-ScheduledTaskTrigger -AtStartup  # Specify the trigger settings
    $User= "NT AUTHORITY\SYSTEM" # Specify the account to run the script
    $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $Script # Specify what program to run and with its parameters
    Register-ScheduledTask -TaskName (split-path -Leaf $Script) -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force # Specify the name of the task


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



  file { "c:\\scripts\\ensuredns.ps1" :
    ensure   => present,
    content => $ensuredns,
    require => File[$scripts_dir],
  }

  file { "c:\\scripts\\configureScavaging.ps1" :
    ensure   => present,
    content => $configureScavaging,
    require => File[$scripts_dir],
  }

  file { "c:\\scripts\\01_ensurednsforwarder.ps1" :
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

  exec { 'ensuredns' :
    command     => '& c:\\scripts\\ensuredns.ps1',
    subscribe   => File['c:\\scripts\\ensuredns.ps1'],
    provider => 'powershell',
    require => [Dsc_xaddomain['firstdc'], File["c:\\scripts\\ensuredns.ps1"]],
  }

  exec { 'configureScavaging' :
    command     => '& c:\\scripts\\configureScavaging.ps1',
    subscribe   => File['c:\\scripts\\configureScavaging.ps1'],
    provider => 'powershell',
    require => [Dsc_xaddomain['firstdc'], File["c:\\scripts\\configureScavaging.ps1"]],
  }


  reboot {'dsc_reboot':
    message => 'DSC has requested a reboot',
    when    => pending,
  }





  windows_ad::group{'Network Controller Admins':
    ensure               => present,
    displayname          => 'Network Controller Admins',
    path                 => 'CN=Users,DC=mshome,DC=net',
    groupname            => 'Network Controller Admins',
    groupscope           => 'Global',
    groupcategory        => 'Security',
    description          => 'Network Controller Admins group',
    require => Dsc_xaddomain['firstdc'],
  }

  windows_ad::group{'Network Controller Users':
    ensure               => present,
    displayname          => 'Network Controller Users',
    path                 => 'CN=Users,DC=mshome,DC=net',
    groupname            => 'Network Controller Users',
    groupscope           => 'Global',
    groupcategory        => 'Security',
    description          => 'Network Controller Users group',
    require => Dsc_xaddomain['firstdc'],
  }




  }
}
