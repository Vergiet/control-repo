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

}
