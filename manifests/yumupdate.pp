class yumupdate {
  # Run a yum update on the 6th of every month between 11:00am and 11:59am.
  # Notes: A longer timout is required for this particular run,
  #        The time check can be overridden if a specific file exists in /var/tmp

  /*
  exec { "yum-update":
    command => "yum clean all; yum -q -y update --exclude cvs; rm -rf /var/tmp/forceyum",
    timeout => 1800,
    path => "/usr/bin/"
  }
  */
}
