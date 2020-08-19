class hv::baseline (

) {


  reboot {'before_Hyper_V':
   when      => pending,
 }



 windowsfeature { 'Hyper-V':
   ensure => present,
   require => Reboot['before_Hyper_V'],
 }

 reboot {'after_Hyper_V':
   when      => pending,
   subscribe => Windowsfeature['Hyper-V'],
 }

 mount { "D:":
  ensure   => mounted,
  provider => windows_smb,
  device   => "//DESKTOP-2866BO2/D",
  options  => '{"user":"DESKTOP-2866BO2/HvShareAccess","password":"Beheer123"}',
}

}
