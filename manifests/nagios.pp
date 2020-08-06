class nagios::server::standalone {

  require firewall
  include firewall
  include mysql::client

  package { [ "nagios-plugins-all", "nagios-plugins", "nagios-plugins-nrpe", "httpd", "php", "php-mysql", "wget", "perl", "postfix", "php-fpm", "gcc", "glibc" ,"glibc-common", "gd", "gd-devel", "make", "net-snmp", "openssl-devel", "xinetd", "unzip", "gettext", "automake", "autoconf", "net-snmp-utils", "epel-release", "perl-Net-SNMP"]:
    ensure => installed,
  }

  service { 'httpd':
    ensure  => running,
    enable  => true,
  }

  /*
  service { 'nagios':
    ensure  => running,
    enable  => true,
    subscribe => Exec['/root/installnagios.sh'],
    #require => Exec['make-nag-cfg-readable'],
  }
  */

  # This is because puppet writes the config files so nagios can't read them

  exec {'make-nag-cfg-readable':
    command => "find /usr/local/nagios/etc/objects/servers -type f -name '*cfg' | xargs chmod +r",
    path => ['/usr/bin', '/usr/sbin',],
  }

  /*
  file { 'resource-d':
    path   => '/etc/nagios/resource.d',
    ensure => directory,
    owner  => 'nagios',
  }
  */

  /*
  file { 'servers':
    path   => '/usr/local/nagios/etc/objects/servers',
    ensure => directory,
    owner  => 'nagios',
    group => 'nagios',
  }
  */


$testpath = '#!/bin/bash

if [ -d $1 ]; then
    exit 0
else 
    exit 1
fi
'

$testfile = '#!/bin/sh
if [ -f $1 ]; then
    exit 0
else 
    exit 1
fi
'


$installnagios = '#!/bin/sh

cd ~
curl -L -O https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz
tar xvf nagios-*.tar.gz
cd nagios-*
./configure
make all
make install-groups-users
usermod -a -G nagios apache
make install
make install-daemoninit
make install-commandmode
make install-config
make install-webconf

'

$installnagiosplugins = '#!/bin/sh

cd ~
curl -L -O http://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
tar xvf nagios-plugins-*.tar.gz
cd nagios-plugins-*
./configure
make
make install
'


$installnagiosnrpe = '#!/bin/sh

cd ~
curl -L -O https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.2/nrpe-4.0.2.tar.gz
#https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.3/nrpe-4.0.3.tar.gz
tar xvf nrpe-*.tar.gz
cd nrpe-*
./configure

make all
make install-groups-users
make install
make install-config
make install-inetd
make install-init
'

$installnagiosnrdp = '#!/bin/sh

cd /tmp
wget -O nrdp.tar.gz https://github.com/NagiosEnterprises/nrdp/archive/2.0.3.tar.gz
tar xzf nrdp.tar.gz

cd /tmp/nrdp*
mkdir -p /usr/local/nrdp
cp -r clients server LICENSE* CHANGES* /usr/local/nrdp
chown -R nagios:nagios /usr/local/nrdp 
cp nrdp.conf /etc/httpd/conf.d/nrdp.conf
'
/*
$hostgroups = '
define hostgroup {
  hostgroup_name    all-servers
  alias             All my servers
  members           *
}
'
*/


$services = '
define service{
  hostgroup_name            all-servers
  use                       generic-service
  service_description       /var freespace
  check_command             check_nrpe!check_var
}

define service{
    hostgroup_name           all-servers
    use                      generic-service
    service_description      / freespace
    check_command            check_nrpe!check_slash
}
'

$templates = '


###############################################################################
# TEMPLATES.CFG - SAMPLE OBJECT TEMPLATES
#
#
# NOTES: This config file provides you with some example object definition
#        templates that are referred by other host, service, contact, etc.
#        definitions in other config files.
#
#        You dont need to keep these definitions in a separate file from your
#        other object definitions.  This has been done just to make things
#        easier to understand.
#
###############################################################################



###############################################################################
#
# CONTACT TEMPLATES
#
###############################################################################

# Generic contact definition template
# This is NOT a real contact, just a template!

define contact {

    name                            generic-contact         ; The name of this contact template
    service_notification_period     24x7                    ; service notifications can be sent anytime
    host_notification_period        24x7                    ; host notifications can be sent anytime
    service_notification_options    w,u,c,r,f,s             ; send notifications for all service states, flapping events, and scheduled downtime events
    host_notification_options       d,u,r,f,s               ; send notifications for all host states, flapping events, and scheduled downtime events
    service_notification_commands   notify-service-by-email ; send service notifications via email
    host_notification_commands      notify-host-by-email    ; send host notifications via email
    register                        0                       ; DONT REGISTER THIS DEFINITION - ITS NOT A REAL CONTACT, JUST A TEMPLATE!
}

###############################################################################
#
# HOST TEMPLATES
#
###############################################################################

# Generic host definition template
# This is NOT a real host, just a template!

define host {

    name                            generic-host            ; The name of this host template
    notifications_enabled           1                       ; Host notifications are enabled
    event_handler_enabled           1                       ; Host event handler is enabled
    flap_detection_enabled          1                       ; Flap detection is enabled
    process_perf_data               1                       ; Process performance data
    retain_status_information       1                       ; Retain status information across program restarts
    retain_nonstatus_information    1                       ; Retain non-status information across program restarts
    notification_period             24x7                    ; Send host notifications at any time
    register                        0                       ; DONT REGISTER THIS DEFINITION - ITS NOT A REAL HOST, JUST A TEMPLATE!
}



# Linux host definition template
# This is NOT a real host, just a template!

define host {

    name                            linux-server            ; The name of this host template
    use                             generic-host            ; This template inherits other values from the generic-host template
    check_period                    24x7                    ; By default, Linux hosts are checked round the clock
    check_interval                  5                       ; Actively check the host every 5 minutes
    retry_interval                  1                       ; Schedule host check retries at 1 minute intervals
    max_check_attempts              10                      ; Check each Linux host 10 times (max)
    check_command                   check-host-alive        ; Default command to check Linux hosts
    notification_period             workhours               ; Linux admins hate to be woken up, so we only notify during the day
                                                            ; Note that the notification_period variable is being overridden from
                                                            ; the value that is inherited from the generic-host template!
    notification_interval           120                     ; Resend notifications every 2 hours
    notification_options            d,u,r                   ; Only send notifications for specific host states
    contact_groups                  admins                  ; Notifications get sent to the admins by default
    register                        0                       ; DONT REGISTER THIS DEFINITION - ITS NOT A REAL HOST, JUST A TEMPLATE!
}




# Windows host definition template
# This is NOT a real host, just a template!

define host {

    name                            windows-server          ; The name of this host template
    use                             generic-host            ; Inherit default values from the generic-host template
    check_period                    24x7                    ; By default, Windows servers are monitored round the clock
    check_interval                  5                       ; Actively check the server every 5 minutes
    retry_interval                  1                       ; Schedule host check retries at 1 minute intervals
    max_check_attempts              10                      ; Check each server 10 times (max)
    check_command                   check-host-alive        ; Default command to check if servers are "alive"
    notification_period             24x7                    ; Send notification out at any time - day or night
    notification_interval           30                      ; Resend notifications every 30 minutes
    notification_options            d,r                     ; Only send notifications for specific host states
    contact_groups                  admins                  ; Notifications get sent to the admins by default
    hostgroups                      windows-servers         ; Host groups that Windows servers should be a member of
    register                        0                       ; DONT REGISTER THIS - ITS JUST A TEMPLATE
}



# We define a generic printer template that can
# be used for most printers we monitor

define host {

    name                            generic-printer         ; The name of this host template
    use                             generic-host            ; Inherit default values from the generic-host template
    check_period                    24x7                    ; By default, printers are monitored round the clock
    check_interval                  5                       ; Actively check the printer every 5 minutes
    retry_interval                  1                       ; Schedule host check retries at 1 minute intervals
    max_check_attempts              10                      ; Check each printer 10 times (max)
    check_command                   check-host-alive        ; Default command to check if printers are "alive"
    notification_period             workhours               ; Printers are only used during the workday
    notification_interval           30                      ; Resend notifications every 30 minutes
    notification_options            d,r                     ; Only send notifications for specific host states
    contact_groups                  admins                  ; Notifications get sent to the admins by default
    register                        0                       ; DONT REGISTER THIS - ITS JUST A TEMPLATE
}



# Define a template for switches that we can reuse
define host {

    name                            generic-switch          ; The name of this host template
    use                             generic-host            ; Inherit default values from the generic-host template
    check_period                    24x7                    ; By default, switches are monitored round the clock
    check_interval                  5                       ; Switches are checked every 5 minutes
    retry_interval                  1                       ; Schedule host check retries at 1 minute intervals
    max_check_attempts              10                      ; Check each switch 10 times (max)
    check_command                   check-host-alive        ; Default command to check if routers are "alive"
    notification_period             24x7                    ; Send notifications at any time
    notification_interval           30                      ; Resend notifications every 30 minutes
    notification_options            d,r                     ; Only send notifications for specific host states
    contact_groups                  admins                  ; Notifications get sent to the admins by default
    register                        0                       ; DONT REGISTER THIS - ITS JUST A TEMPLATE
}



###############################################################################
#
# SERVICE TEMPLATES
#
###############################################################################

# Generic service definition template
# This is NOT a real service, just a template!

define service {

    name                            generic-service         ; The name of this service template
    active_checks_enabled           1                       ; Active service checks are enabled
    passive_checks_enabled          1                       ; Passive service checks are enabled/accepted
    parallelize_check               1                       ; Active service checks should be parallelized (disabling this can lead to major performance problems)
    obsess_over_service             1                       ; We should obsess over this service (if necessary)
    check_freshness                 0                       ; Default is to NOT check service freshness
    notifications_enabled           1                       ; Service notifications are enabled
    event_handler_enabled           1                       ; Service event handler is enabled
    flap_detection_enabled          1                       ; Flap detection is enabled
    process_perf_data               1                       ; Process performance data
    retain_status_information       1                       ; Retain status information across program restarts
    retain_nonstatus_information    1                       ; Retain non-status information across program restarts
    is_volatile                     0                       ; The service is not volatile
    check_period                    24x7                    ; The service can be checked at any time of the day
    max_check_attempts              3                       ; Re-check the service up to 3 times in order to determine its final (hard) state
    check_interval                  10                      ; Check the service every 10 minutes under normal conditions
    retry_interval                  2                       ; Re-check the service every two minutes until a hard state can be determined
    contact_groups                  admins                  ; Notifications get sent out to everyone in the admins group
    notification_options            w,u,c,r                 ; Send notifications about warning, unknown, critical, and recovery events
    notification_interval           60                      ; Re-notify about service problems every hour
    notification_period             24x7                    ; Notifications can be sent out at any time
    register                        0                       ; DONT REGISTER THIS DEFINITION - ITS NOT A REAL SERVICE, JUST A TEMPLATE!
}



# Local service definition template
# This is NOT a real service, just a template!

define service {

    name                            local-service           ; The name of this service template
    use                             generic-service         ; Inherit default values from the generic-service definition
    max_check_attempts              4                       ; Re-check the service up to 4 times in order to determine its final (hard) state
    check_interval                  5                       ; Check the service every 5 minutes under normal conditions
    retry_interval                  1                       ; Re-check the service every minute until a hard state can be determined
    register                        0                       ; DONT REGISTER THIS DEFINITION - ITS NOT A REAL SERVICE, JUST A TEMPLATE!
}

'

  file { "/root/installnagios.sh" :
    ensure   => present,
    content => $installnagios,
    mode => '0655',
  }

  file { "/usr/local/nagios/etc/objects/services.cfg" :
    #ensure   => present,
    ensure   => absent,
    content => $services,
    owner => 'nagios',
    group => 'nagios',
    mode => '0664',
  }

  file { "/etc/nagios/templates.cfg" :
    ensure   => present,
    #ensure   => absent,
    content => $templates,
    owner => 'nagios',
    group => 'nagios',
    mode => '0664',
  }

/*
  file { "/usr/local/nagios/etc/objects/hostgroups.cfg" :
    #ensure   => present,
    ensure   => absent,
    content => $hostgroups,
    owner => 'nagios',
    group => 'nagios',
    mode => '0664',
  }
*/

  file { "/usr/local/nagios/libexec/check_ncpa.py" :
    ensure   => present,
    source => 'https://raw.githubusercontent.com/NagiosEnterprises/ncpa/master/client/check_ncpa.py',
    mode => '0755',
    require => Exec['/root/installnagios.sh'],
  }

  file { "/root/installnagiosplugins.sh" :
    ensure   => present,
    content => $installnagiosplugins,
    mode => '0655',
  }

  file { "/root/installnagiosnrpe.sh" :
    ensure   => present,
    content => $installnagiosnrpe,
    mode => '0655',
  }

  file { "/root/installnagiosnrdp.sh" :
    ensure   => present,
    content => $installnagiosnrdp,
    mode => '0655',
  }

  file { "/root/testpath.sh" :
    ensure   => present,
    content => $testpath,
    mode => '0655',
  }

  file { "/root/testfile.sh" :
    ensure   => present,
    content => $testfile,
    mode => '0655',
  }

  exec { '/root/installnagios.sh':
    unless => '/root/testpath.sh /root/nagios-*',
    subscribe => [File['/root/installnagios.sh'], Firewall['100 WEB required ports']],
    timeout => 1800,
    #notify => [Service['httpd'], File['servers']],
    notify => Service['httpd'],
  }

  exec { '/root/installnagiosplugins.sh':
    unless => '/root/testpath.sh /root/nagios-plugins-*',
    subscribe => [File['/root/installnagiosplugins.sh'], Firewall['100 WEB required ports'], Exec['/root/installnagios.sh']],
    timeout => 1800,
    notify => Service['nagios'],
  }

  exec { '/root/installnagiosnrpe.sh':
    unless => '/root/testpath.sh /root/nrpe-*',
    subscribe => [File['/root/installnagiosnrpe.sh'], Firewall['100 WEB required ports'], Exec['/root/installnagiosplugins.sh']],
    timeout => 1800,
  }

  exec { '/root/installnagiosnrdp.sh':
    unless => '/root/testpath.sh /tmp/nrdp*',
    subscribe => [File['/root/installnagiosnrdp.sh'], Firewall['100 WEB required ports'], Exec['/root/installnagiosnrpe.sh']],
    timeout => 1800,
    notify => Service['httpd'],
  }

  service { 'nrpe':
    ensure  => running,
    enable  => true,
    subscribe => Exec['/root/installnagiosnrpe.sh'],
  }

  httpauth { 'nagiosadmin':
    username => 'nagiosadmin',
    file     => '/usr/local/nagios/etc/htpasswd.users',
    mode     => '0644',
    password => 'password',
    realm => 'realm',
    mechanism => basic,
    ensure => present,
    subscribe => Exec['/root/installnagios.sh'],
  }

  firewall { '100 WEB required ports':
    dport  => [22, 443, 80, 5666],
    proto  => 'tcp',
    action => 'accept',
  }

  class { 'mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

  include nagios::params
  require nagios::expire_resources
  include nagios::purge_resources

  service { $nagios::params::service:
    ensure => running,
    enable => true,
  }

  # nagios.cfg needs this specified via the cfg_dir directive
  file { $nagios::params::resource_dir:
    ensure => directory,
    owner => $nagios::params::user,
    group => $nagios::params::user,
  }

  # Local Nagios resources
  nagios::resource { 'all-servers':
    type => hostgroup,
    bexport => false;
  }

  nagios_command {'check_nrpe':
    ensure => present,
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }

  nagios_command {'notify-host-by-email':
    ensure => present,
    command_line => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\nHost: $HOSTNAME$\nState: $HOSTSTATE$\nAddress: $HOSTADDRESS$\nInfo: $HOSTOUTPUT$\n\nDate/Time: $LONGDATETIME$\n" | /usr/bin/mail -s "** $NOTIFICATIONTYPE$ Host Alert: $HOSTNAME$ is $HOSTSTATE$ **" $CONTACTEMAIL$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }

  nagios_command {'notify-service-by-email':
    ensure => present,
    command_line => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\n\nService: $SERVICEDESC$\nHost: $HOSTALIAS$\nAddress: $HOSTADDRESS$\nState: $SERVICESTATE$\n\nDate/Time: $LONGDATETIME$\n\nAdditional Info:\n\n$SERVICEOUTPUT$\n" | /usr/bin/mail -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" $CONTACTEMAIL$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check-host-alive':
    ensure => present,
    command_line => '$USER1$/check_ping -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 5',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_local_disk':
    ensure => present,
    command_line => '$USER1$/check_disk -w $ARG1$ -c $ARG2$ -p $ARG3$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_local_load':
    ensure => present,
    command_line => '$USER1$/check_load -w $ARG1$ -c $ARG2$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_local_procs':
    ensure => present,
    command_line => '$USER1$/check_procs -w $ARG1$ -c $ARG2$ -s $ARG3$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_local_users':
    ensure => present,
    command_line => '$USER1$/check_users -w $ARG1$ -c $ARG2$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_local_swap':
    ensure => present,
    command_line => '$USER1$/check_swap -w $ARG1$ -c $ARG2$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_local_mrtgtraf':
    ensure => present,
    command_line => '$USER1$/check_mrtgtraf -F $ARG1$ -a $ARG2$ -w $ARG3$ -c $ARG4$ -e $ARG5$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_ftp':
    ensure => present,
    command_line => '$USER1$/check_ftp -H $HOSTADDRESS$ $ARG1$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_hpjd':
    ensure => present,
    command_line => '$USER1$/check_hpjd -H $HOSTADDRESS$ $ARG1$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_snmp':
    ensure => present,
    command_line => '$USER1$/check_snmp -H $HOSTADDRESS$ $ARG1$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_http':
    ensure => present,
    command_line => '$USER1$/check_http -I $HOSTADDRESS$ $ARG1$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_ssh':
    ensure => present,
    command_line => '$USER1$/check_ssh $ARG1$ $HOSTADDRESS$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_dhcp':
    ensure => present,
    command_line => '$USER1$/check_dhcp $ARG1$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_ping':
    ensure => present,
    command_line => '$USER1$/check_ping -H $HOSTADDRESS$ -w $ARG1$ -c $ARG2$ -p 5',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_pop':
    ensure => present,
    command_line => '$USER1$/check_pop -H $HOSTADDRESS$ $ARG1$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_imap':
    ensure => present,
    command_line => '$USER1$/check_imap -H $HOSTADDRESS$ $ARG1$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_smtp':
    ensure => present,
    command_line => '$USER1$/check_smtp -H $HOSTADDRESS$ $ARG1$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_tcp':
    ensure => present,
    command_line => '$USER1$/check_tcp -H $HOSTADDRESS$ -p $ARG1$ $ARG2$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_udp':
    ensure => present,
    command_line => '$USER1$/check_udp -H $HOSTADDRESS$ -p $ARG1$ $ARG2$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'check_nt':
    ensure => present,
    command_line => '$USER1$/check_nt -H $HOSTADDRESS$ -p 12489 -v $ARG1$ $ARG2$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }

  ################################################################################
  #
  # SAMPLE PERFORMANCE DATA COMMANDS
  #
  # These are sample performance data commands that can be used to send performance
  # data output to two text files (one for hosts, another for services).  If you
  # plan on simply writing performance data out to a file, consider using the
  # host_perfdata_file and service_perfdata_file options in the main config file.
  #
  ################################################################################

  nagios_command {'process-host-perfdata':
    ensure => present,
    command_line => '/usr/bin/printf "%b" "$LASTHOSTCHECK$\t$HOSTNAME$\t$HOSTSTATE$\t$HOSTATTEMPT$\t$HOSTSTATETYPE$\t$HOSTEXECUTIONTIME$\t$HOSTOUTPUT$\t$HOSTPERFDATA$\n" >> /usr/local/nagios/var/host-perfdata.out',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'process-service-perfdata':
    ensure => present,
    command_line => '/usr/bin/printf "%b" "$LASTSERVICECHECK$\t$HOSTNAME$\t$SERVICEDESC$\t$SERVICESTATE$\t$SERVICEATTEMPT$\t$SERVICESTATETYPE$\t$SERVICEEXECUTIONTIME$\t$SERVICELATENCY$\t$SERVICEOUTPUT$\t$SERVICEPERFDATA$\n" >> /usr/local/nagios/var/service-perfdata.out',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }

  #/etc/nagios/resource.d/hostgroup_all-servers.cfg
  #/etc/nagios/resource.d/host_nagios.mshome.net.cfg

  #ls -la /usr/local/nagios/etc/objects/

  ###############################################################################
  #
  # CONTACTS
  #
  ###############################################################################

  # Just one contact defined by default - the Nagios admin (that's you)
  # This contact definition inherits a lot of default values from the
  # 'generic-contact' template which is defined elsewhere.

  nagios_contact { 'nagiosadmin':
    ensure => present,
    use => 'generic-contact',
    alias => 'Nagios Admin',
    email => 'nagios@localhost',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }

  ###############################################################################
  #
  # CONTACT GROUPS
  #
  ###############################################################################

  # We only have one contact in this simple configuration file, so there is
  # no need to create more than one contact group.

  nagios_contactgroup { 'admins':
    ensure => present,
    alias => 'Nagios Administrators',
    members => 'nagiosadmin',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }





}



/*


*/






















/*
class nagios::export {
  @@nagios_host { $::fqdn:
    ensure => present,
    use           => 'linux-server',
    address       => $::ipaddress,
    #check_command => 'check-host-alive!3000.0,80%!5000.0,100%!10',
    check_command => 'check-host-alive',
    #hostgroups    => 'linux-servers',
    target        => "/usr/local/nagios/etc/objects/servers/host_${::fqdn}.cfg",
    max_check_attempts => '5',
    check_period => '24x7',
    notification_interval => '30',
    notification_period => '24x7',
  }
}

*/

/*

###############################################################################
# LOCALHOST.CFG - SAMPLE OBJECT CONFIG FILE FOR MONITORING THIS MACHINE
#
#
# NOTE: This config file is intended to serve as an *extremely* simple
#       example of how you can create configuration entries to monitor
#       the local (Linux) machine.
#
###############################################################################



###############################################################################
#
# HOST DEFINITION
#
###############################################################################

# Define a host for the local machine

define host {

    use                     linux-server            ; Name of host template to use
                                                    ; This host definition will inherit all variables that are defined
                                                    ; in (or inherited by) the linux-server host template definition.
    host_name               localhost
    alias                   localhost
    address                 127.0.0.1
}



###############################################################################
#
# HOST GROUP DEFINITION
#
###############################################################################

# Define an optional hostgroup for Linux machines

define hostgroup {

    hostgroup_name          linux-servers           ; The name of the hostgroup
    alias                   Linux Servers           ; Long name of the group
    members                 localhost,*               ; Comma separated list of hosts that belong to this group
}



###############################################################################
#
# SERVICE DEFINITIONS
#
###############################################################################

# Define a service to "ping" the local machine

define service {

    use                     local-service           ; Name of service template to use
    host_name               localhost
    service_description     PING
    check_command           check_ping!100.0,20%!500.0,60%
}



# Define a service to check the disk space of the root partition
# on the local machine.  Warning if < 20% free, critical if
# < 10% free space on partition.

define service {

    use                     local-service           ; Name of service template to use
    host_name               localhost
    service_description     Root Partition
    check_command           check_local_disk!20%!10%!/
}



# Define a service to check the number of currently logged in
# users on the local machine.  Warning if > 20 users, critical
# if > 50 users.

define service {

    use                     local-service           ; Name of service template to use
    host_name               localhost
    service_description     Current Users
    check_command           check_local_users!20!50
}



# Define a service to check the number of currently running procs
# on the local machine.  Warning if > 250 processes, critical if
# > 400 processes.

define service {

    use                     local-service           ; Name of service template to use
    host_name               localhost
    service_description     Total Processes
    check_command           check_local_procs!250!400!RSZDT
}



# Define a service to check the load on the local machine.

define service {

    use                     local-service           ; Name of service template to use
    host_name               localhost
    service_description     Current Load
    check_command           check_local_load!5.0,4.0,3.0!10.0,6.0,4.0
}



# Define a service to check the swap usage the local machine.
# Critical if less than 10% of swap is free, warning if less than 20% is free

define service {

    use                     local-service           ; Name of service template to use
    host_name               localhost
    service_description     Swap Usage
    check_command           check_local_swap!20%!10%
}



# Define a service to check SSH on the local machine.
# Disable notifications for this service by default, as not all users may have SSH enabled.

define service {

    use                     local-service           ; Name of service template to use
    host_name               localhost
    service_description     SSH
    check_command           check_ssh
    notifications_enabled   0
}



# Define a service to check HTTP on the local machine.
# Disable notifications for this service by default, as not all users may have HTTP enabled.

define service {

    use                     local-service           ; Name of service template to use
    host_name               localhost
    service_description     HTTP
    check_command           check_http
    notifications_enabled   0
}

*/

