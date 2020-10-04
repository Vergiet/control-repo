class hv::baseline (

) {




  service { 'MSiSCSI':
    ensure  => running,
    enable  => true,
  }

/*
    package { 'microsoft-monitoring-agent':
      ensure   => installed,
      provider => 'chocolatey',
      install_options => ["/WorkspaceId:44170c64-6ba4-4627-99ed-ccf7c7262862" ,"/workspaceKey:M9Lc4WWPAAhv4GWfMCC98/HuMo1GYqidtqus7t/jDEuUF+2cSS2epemGHh8Ym5WmZaVeM8SnakFFglyQReYmPw=="]
    }
    */

/*



$connectiscsi = '
if (([array](get-IscsiTargetPortal)).count -eq 0){

    New-IscsiTargetPortal -TargetPortalAddress "192.168.1.4" -InitiatorInstanceName "ROOT\\ISCSIPRT\\0000_0"
}

Get-IscsiTarget | ?{$_.IsConnected -eq $False -and $_.NodeAddress -like "*target-hv"} | Connect-IscsiTarget -IsPersistent $true
'

$renamenetadapters = '
Get-NetAdapter | ?{$_.linkspeed -eq "10 Gbps" -and $_.name -ne "mshome"} | Rename-NetAdapter -NewName "mshome"
Get-NetAdapter | ?{$_.linkspeed -eq "1 Gbps" -and $_.name -ne "vrgt.xyz"} | Rename-NetAdapter -NewName "vrgt.xyz"
'


  file { "c:\\scripts\\connectiscsi.ps1" :
    ensure   => present,
    content => $connectiscsi,
  }
  

  file { "c:\\scripts\\renamenetadapters.ps1" :
    ensure   => absent,
    content => $renamenetadapters,
  }
  */

/*

  exec { 'connectiscsi':
    command     => '& c:\\scripts\\connectiscsi.ps1',
    #subscribe   => File['c:\\scripts\\connectiscsi.ps1'],
    require   => File['c:\\scripts\\connectiscsi.ps1'],
    provider => 'powershell',
  }
  */

/*
  exec { 'renamenetadapters':
    command     => '& c:\\scripts\\renamenetadapters.ps1',
    #subscribe   => File['c:\\scripts\\connectiscsi.ps1'],
    require   => File['c:\\scripts\\renamenetadapters.ps1'],
    provider => 'powershell',
  }
  */

reboot {'after_Hyper_V':
  message => 'DSC has requested a reboot after installing hyper-v',
  when      => pending,
  subscribe => Windowsfeature['Hyper-V'],
}

/*

  dsc_computer { 'joindomain':
    dsc_name => $facts['networking']['hostname'],
    dsc_domainname => 'mshome.net',
    dsc_credential => {
        'user'     => 'Administrator@mshome.net',
        'password' => Sensitive('Beheer123')
      },
    require => Exec['ensurednsadres'],
  }

*/
/*
$setipaddress = '
Clear-DnsClientCache
$ip = (Get-NetAdapter -Name "Default Switch" | Get-NetIPAddress -AddressFamily IPv4).IPAddress.split(".")[3]

if (!(Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name "Provider").interfaceindex | ?{$_.ipAddress -eq "10.0.0.$ip"})){

  New-NetIPAddress -IPAddress "10.0.0.$ip" -InterfaceIndex (Get-NetAdapter -Name "Provider").interfaceindex -PrefixLength 24 -verbose
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
  */

$configs2d = '
$ErrorActionPreference = "Stop"

if ((Get-ClusterNode -Cluster Cluster02 | ?{$_.state -eq "up"}).count -ge 3){


  if ((Get-Cluster -Name cluster02).S2DEnabled -eq 0){

    $Computernames = @(
        "hv01"
        "hv02"
        "hv03"
    )


    Invoke-Command ($Computernames) {
        Update-StorageProviderCache
        Get-StoragePool | ? IsPrimordial -eq $false | Set-StoragePool -IsReadOnly:$false #-ErrorAction SilentlyContinue
        Get-StoragePool | ? IsPrimordial -eq $false | Get-VirtualDisk | Remove-VirtualDisk -Confirm:$false #-ErrorAction SilentlyContinue
        Get-StoragePool | ? IsPrimordial -eq $false | Remove-StoragePool -Confirm:$false #-ErrorAction SilentlyContinue
        Get-PhysicalDisk | Reset-PhysicalDisk #-ErrorAction SilentlyContinue
        Get-Disk | ? Number -ne $null | ? IsBoot -ne $true | ? IsSystem -ne $true | ? PartitionStyle -ne "RAW" | % {
            $_ | Set-Disk -isoffline:$false
            $_ | Set-Disk -isreadonly:$false
            $_ | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false
            $_ | Set-Disk -isreadonly:$true
            $_ | Set-Disk -isoffline:$true
        }
        Get-Disk | Where Number -Ne $Null | Where IsBoot -Ne $True | Where IsSystem -Ne $True | Where PartitionStyle -Eq "RAW" | Group -NoElement -Property FriendlyName
    } | Sort -Property PsComputerName, Count


    Test-Cluster -Node $Computernames -Include "Storage Spaces Direct", "Inventory", "Network", "System Configuration"

    Enable-ClusterStorageSpacesDirect -CimSession Cluster02 -Confirm:$False



    (Get-Cluster -Name Cluster02).BlockCacheSize = 2048

  }


}

if ((Get-Cluster -Name cluster02).S2DEnabled -eq 1){

  if (!(Get-Volume | ?{$_.FileSystemLabel -eq "Volume1"})){
    New-Volume -FriendlyName "Volume1" -FileSystem CSVFS_ReFS -StoragePoolFriendlyName "S2D*" -Size 100GB
  } 
}


'

$configsddc = '

if (!(get-ClusterResourceType -Name "SDDC Management")){
  Add-ClusterResourceType -Name "SDDC Management" -dll "$env:SystemRoot\Cluster\sddcres.dll" -DisplayName "SDDC Management"
}

'

/*

  dsc_windowsfeature { 'AddFailoverFeature':
      dsc_ensure => 'Present',
      dsc_name   => 'Failover-clustering',
  }

  dsc_windowsfeature { 'AddRemoteServerAdministrationToolsClusteringPowerShellFeature':
      dsc_ensure    => 'Present',
      dsc_name      => 'RSAT-Clustering-PowerShell',
      require => Dsc_windowsfeature['AddFailoverFeature'],
      # DependsOn = '[WindowsFeature]AddFailoverFeature'
  }

  dsc_windowsfeature { 'AddRemoteServerAdministrationToolsClusteringCmdInterfaceFeature':
      dsc_ensure    => 'Present',
      dsc_name      => 'RSAT-Clustering-CmdInterface',
      require => Dsc_windowsfeature['AddRemoteServerAdministrationToolsClusteringPowerShellFeature'],
      #DependsOn = '[WindowsFeature]AddRemoteServerAdministrationToolsClusteringPowerShellFeature'
  }
  */



#"FS-FileServer",
#"Data-Center-Bridging",
  $featurelijst = ["Failover-Clustering",  "RSAT-Clustering-PowerShell", "Hyper-V-PowerShell",  "RSAT-Clustering-CmdInterface", 'Hyper-V', 'RSAT-NetworkController']

  windowsfeature { $featurelijst:
    ensure => present,
    installsubfeatures => true,
    require => Reboot['before_Hyper_V'],
  }

  /*

  windowsfeature {'FS-Data-Deduplication':
    ensure => absent,
    installsubfeatures => true,
    require => Reboot['before_Hyper_V'],
  }

  windowsfeature {'FS-BranchCache':
    ensure => absent,
    installsubfeatures => true,
    require => Reboot['before_Hyper_V'],
  }

  */

  if $os['windows']['installation_type'] == 'Server' {
    dsc_windowsfeature { 'AddRemoteServerAdministrationToolsClusteringManagementToolsFeature':
        dsc_ensure    => 'Present',
        dsc_name      => 'RSAT-Clustering-Mgmt',
        #require => Dsc_windowsfeature['AddRemoteServerAdministrationToolsClusteringPowerShellFeature'],
        require => Windowsfeature["RSAT-Clustering-PowerShell"],
        #DependsOn = '[WindowsFeature]RSAT-Clustering-PowerShell'
    }
  }



/*
  dsc_waitfordisk { 'Disk2':
        dsc_diskid => '6589CFC00000085BF473AC1C6E103E0A', # Disk 3
        dsc_diskidtype => 'UniqueId',
        dsc_retryintervalsec => 60,
        dsc_retrycount => 60,
  }
  */

$configdiagtools = '

if ([Net.ServicePointManager]::SecurityProtocol -notmatch [Net.SecurityProtocolType]::Tls12){
  [Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::Tls12
}

if (!(Get-PackageProvider | ?{$_.name -eq "Nuget"})){
  Install-PackageProvider -Name Nuget -verbose
}

if (!(Get-PSRepository)){
  Register-PSRepository -Default -verbose
}

$Modules = @(
  "privatecloud.diagnosticinfo"
  "MSFT.network.diag"
)

Foreach ($Module in $Modules){
  if (!(Get-Module -ListAvailable | ?{$_.name -eq $Module})){
    Install-module -name $Module -verbose -confirm:$False -force
  }
}

'



    file { "c:\\scripts\\configdiagtools.ps1" :
      ensure   => present,
      content => $configdiagtools,
    }

    exec { 'configdiagtools':
      command     => '& c:\\scripts\\configdiagtools.ps1',
      require => [File["c:\\scripts\\configdiagtools.ps1"], Exec['removepester']],
      provider => 'powershell',
    }

$cleanupphysdisk = '
  get-PhysicalDisk -Usage Retired | %{remove-PhysicalDisk -Storagepool (Get-StoragePool -FriendlyName "S2D*") -PhysicalDisks $_ -Confirm:$False}
'

$removepester = '

$destination = "C:\Program Files\WindowsPowerShell\Modules\Pester\3.4.0"

if (Test-path -path $destination -pathtype container){
  $TemporaryFile = New-TemporaryFile
  remove-item -path $TemporaryFile -verbose

  $Tempdir = (new-item -path $TemporaryFile.fullname -itemtype "directory" -verbose).fullname

  robocopy $Tempdir $destination /MIR /MT:16 /LOG:NUL

  remove-item -path $Tempdir -verbose
  remove-item -path $destination -verbose
}

exit 0

'


    file { "c:\\scripts\\removepester.ps1" :
      ensure   => present,
      content => $removepester,
    }

    exec { 'removepester':
      command     => '& c:\\scripts\\removepester.ps1',
      require => File["c:\\scripts\\removepester.ps1"],
      provider => 'powershell',
    }

  # https://regex101.com/r/8yU9Oa/1
  if $hostname =~ /\A[a-zA-Z]+[0-9][2-9]\Z/ {
    dsc_xwaitforcluster { 'WaitForCluster':
        dsc_name             => 'Cluster02',
        dsc_retryintervalsec => 10,
        dsc_retrycount       => 60,
        require        => Windowsfeature['RSAT-Clustering-CmdInterface'],
    }

    dsc_xcluster { 'JoinCluster':
        dsc_name => 'Cluster02',
        dsc_staticipaddress               => '192.168.1.13/24',
        dsc_domainadministratorcredential => {
          'user'     => 'Administrator@mshome.net',
          'password' => Sensitive('Beheer123')
        },
        require => [Windowsfeature['RSAT-Clustering-CmdInterface'], Reboot['before_Hyper_V'], Dsc_xwaitforcluster['WaitForCluster']],
    }

    reboot {'after_cluster':
      message => 'DSC has requested a reboot after joining the cluster',
      when      => pending,
      subscribe =>Dsc_xcluster['JoinCluster'],
    }


  } else {

    dsc_xcluster { 'CreateCluster':
        dsc_name => 'Cluster02',
        dsc_staticipaddress               => '192.168.1.13/24',
        dsc_domainadministratorcredential => {
          'user'     => 'Administrator@mshome.net',
          'password' => Sensitive('Beheer123')
        },
        require => [Windowsfeature['RSAT-Clustering-CmdInterface'], Reboot['before_Hyper_V']],
    }



    dsc_xclusterquorum { 'FileShareQuorum':
        dsc_issingleinstance => 'Yes',
        dsc_type => 'NodeAndFileShareMajority',
        dsc_resource => '\\\\DC01\\fsw',
        require => Dsc_xcluster['CreateCluster'],
    }



    file { "c:\\scripts\\cleanupphysdisk.ps1" :
      ensure   => present,
      content => $cleanupphysdisk,
    }

    exec { 'cleanupphysdisk':
      command     => '& c:\\scripts\\cleanupphysdisk.ps1',
      require => [File["c:\\scripts\\cleanupphysdisk.ps1"], Exec['configsddc']],
      provider => 'powershell',
    }


    /*

    dsc_failoverclusters2d { 'EnableS2D':
        dsc_issingleinstance => 'yes',
        dsc_ensure => 'Present',
        require => Dsc_xcluster['CreateCluster'],
    }

*/
    /*
    dsc_disk { 'DVolume':
          dsc_diskid => '6589CFC00000085BF473AC1C6E103E0A', # Disk 3
          dsc_diskidtype => 'UniqueId',
          dsc_driveletter => 'D',
          dsc_fsformat => 'NTFS',
          dsc_allocationunitsize => 4096, #4KB
          require => Dsc_waitfordisk['Disk2'],
    }


    dsc_xclusterdisk {'AddClusterDisk01':
        dsc_number => '1',
        dsc_ensure => 'Present',
        dsc_label  => 'Disk01',
        require => [Dsc_disk['DVolume'], Dsc_xcluster['CreateCluster']],
        #require => Dsc_waitfordisk['Disk2'],
    }
    */


    reboot {'after_cluster':
      message => 'DSC has requested a reboot after creating the cluster',
      when      => pending,
      subscribe => Dsc_xcluster['CreateCluster'],
    }

    dsc_xwaitforcluster { 'WaitForClusterToDeployS2D':
          dsc_name             => 'Cluster02',
          dsc_retryintervalsec => 10,
          dsc_retrycount       => 60,
          require        => Windowsfeature['RSAT-Clustering-CmdInterface'],
    }

    file { "c:\\scripts\\configs2d.ps1" :
      ensure   => present,
      content => $configs2d,
    }

  
    exec { 'configs2d':
      command     => '& c:\\scripts\\configs2d.ps1',
      require => [File["c:\\scripts\\configs2d.ps1"], Dsc_xwaitforcluster["WaitForClusterToDeployS2D"]],
      provider => 'powershell',
    }
    

    file { "c:\\scripts\\configsddc.ps1" :
      ensure   => present,
      content => $configsddc,
    }

    exec { 'configsddc':
      command     => '& c:\\scripts\\configsddc.ps1',
      require => [File["c:\\scripts\\configsddc.ps1"], Dsc_xwaitforcluster["WaitForClusterToDeployS2D"]],
      provider => 'powershell',
    }





  }

  dsc_xvmhost { 'hv':
    dsc_issingleinstance => 'yes', # dsc requirement, must be yes.
    dsc_enableenhancedsessionmode => true,
    require => Windowsfeature['Hyper-V'],
  }




  /*


  dsc_xvmswitch { 'External':
    dsc_ensure => present,
    dsc_name => 'External',
    dsc_type => 'External',
    dsc_netadaptername => 'mshome',
    dsc_allowmanagementos => true,
    require => [Windowsfeature['Hyper-V'],Exec['renamenetadapters']],
  }

  */

  reboot {'before_Hyper_V':
    message => 'DSC has requested a reboot before installing hyper-v',
    when      => pending,
  }

}
