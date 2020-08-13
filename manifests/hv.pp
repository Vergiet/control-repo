class hv::baseline (

) {
 windowsfeature { 'Hyper-V':
   ensure => present,
 }

 reboot {'after_Hyper_V':
   when      => pending,
   subscribe => Windowsfeature['Hyper-V'],
 }

}
