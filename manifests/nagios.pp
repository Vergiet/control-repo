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
/*
  exec {'make-nag-cfg-readable':
    command => "find /usr/local/nagios/etc/objects/servers -type f -name '*cfg' | xargs chmod +r",
    path => ['/usr/bin', '/usr/sbin',],
  }
  */

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
$winncpapassivechecksconfigexample = '
#
#	Basic example of Passive checks being defined
#

#[passive checks]

#%HOSTNAME%|__HOST__ = system/agent_version
#%HOSTNAME%|Disk Usage = disk/logical/C:|/used_percent --warning 80 --critical 90 --units Gi
#%HOSTNAME%|CPU Usage = cpu/percent --warning 60 --critical 80 --aggregate avg
#%HOSTNAME%|Swap Usage = memory/swap --warning 60 --critical 80 --units Gi
#%HOSTNAME%|Memory Usage = memory/virtual --warning 80 --critical 90 --units Gi
#%HOSTNAME%|Process Count = processes --warning 300 --critical 400

'


$winncpapassivechecksconfig = '

#
# AUTO GENERATED NRDP CONFIG FROM WINDOWS INSTALLER
#

[passive checks]

# Host check  - This is to stop "pending check" status in Nagios
%HOSTNAME%|__HOST__ = system/agent_version

# Service checks
%HOSTNAME%|CPU Usage = cpu/percent --warning 80 --critical 90 --aggregate avg
%HOSTNAME%|Disk Usage = disk/logical/C:|/used_percent --warning 80 --critical 90 --units Gi
%HOSTNAME%|Swap Usage = memory/swap --warning 60 --critical 80 --units Gi
%HOSTNAME%|Memory Usage = memory/virtual --warning 80 --critical 90 --units Gi
%HOSTNAME%|Process Count = processes --warning 300 --critical 400

'


$winncpaconfig = '

#
#   NCPA Main Config File
#   ---------------------
#

#
# -------------------------------
# General Configuration
# -------------------------------
#

[general]

#
# Check logging (in ncpa.db and the interface) is on by default, you can disable it
# if you do not want to record the check requests that are coming in or checks being
# sent over NRDP.
# Default: check_logging = 1
#
check_logging = 1

#
# Check logging time - how long in DAYS you\'d like to keep checks in the database.
# Default: 30
#
check_logging_time = 30

#
# Display all mounted disk partitions
# (essentially setting all=True here: https://psutil.readthedocs.io/en/latest/#psutil.disk_partitions)
# Default: 1
#
all_partitions = 1

#
# Excluded file system types removes these fs types from the disk metrics
# (This is mostly only noteable on UNIX systems but also works on Windows if you need it)
# Default: aufs,autofs,binfmt_misc,cifs,cgroup,configfs,debugfs,devpts,devtmpfs,
#          encryptfs,efivarfs,fuse,fusectl,hugetlbfs,mqueue,nfs,overlayfs,proc,pstore,
#          rpc_pipefs,securityfs,selinuxfs,smb,sysfs,tmpfs,tracefs
#
exclude_fs_types = aufs,autofs,binfmt_misc,cifs,cgroup,configfs,debugfs,devpts,devtmpfs,encryptfs,efivarfs,fuse,fusectl,hugetlbfs,mqueue,nfs,overlayfs,proc,pstore,rpc_pipefs,securityfs,selinuxfs,smb,sysfs,tmpfs,tracefs

#
# The default unit to convert bytes (B) into if no unit is specified
# (Gi = 1024 MiB, G = 1000 MB)
#
default_units = Gi

#
# -------------------------------
# Listener Configuration (daemon)
# -------------------------------
#

[listener]

#
# User and group to run plugins as (recommended to use nagios:nagios)
# Default: uid = nagios
# Default: gid = nagios
#
# ** Note - The daemon runs as root, but forks a child process when running a plugin
#    that is defined by the user, for security reasons. However, without the main daemon
#    running as root, much of the system information would be missing. This is typical behavior. **
#
# This is for Unix only (Linux, Mac OS X, etc)
#
uid = nagios
gid = nagios

#
# IP address and port number for the Listener to use for the web GUI and API
#
# :: allows for dual stack (IPv4 and IPv6 on most linux systems) but will only allow
# for IPv6 connections on Windows
# 0.0.0.0 allows for IPv4 connections only on Windows and most linux systems
#
# Default: ip = ::
# Default (Windows): ip = 0.0.0.0
# Default: port = 5693
#
# ip =
# port =

#
# SSL connection and certificate config (if an SSL option is not available on some older
# operating systems it will default back to TLSv1)
# ssl_version options: TLSv1, TLSv1_1, TLSv1_2
#
# ssl_ciphers = <list of ciphers>
#
ssl_version =TLSv1_2
certificate = adhoc

#
# Listener logging file level, location, and the PID location
# Default: loglevel = info (debug, info, warning, error)
# Default: logfile = var/log/ncpa_listener.log
# Default: pidfile = var/run/ncpa_listener.pid (leave listener in pid file name)
#
loglevel =warning
logfile = var/log/ncpa_listener.log
pidfile = var/run/ncpa_listener.pid

#
# Delay the listener (API & web GUI) from starting in seconds
# Default: 0
#
# delay_start = 30

#
# Allow admin functionality in the web GUI. When this is set to 0, the admin section will not
# be displayed in the header and will not be available to be accessed.
# Default: 1
#
admin_gui_access = 1

#
# Admin password for the admin section in the web GUI, by default there is no admin
# password and the admin section of the GUI can be accessed by anyone if admin_gui_access is set to 1.
# Default: None
#
# Note: Setting this value to \'None\' will automatically log you in, setting it empty will allow you to
# log in using a blank password.
#
admin_password = None

#
# Require admin password to access ALL of the web GUI.
# This does not affect API access via token (community_string).
# Default: 0
#
admin_auth_only = 0

#
# Comma separated list of allowed hosts that can access the API (and GUI)
# Exmaple: 192.168.23.15
# Example subnet: 192.168.0.0/28
#
# allowed_hosts =

#
# Number of maximum concurrent connections to the NCPA server.
# Use "None" for unlimited. Default is 200.
# Example: 200
#
# max_connections =

#
# Set the URL to use in the X-Frame-Options and Content-Security-Policy headers
# in order to enable the NCPA GUI to be allowed to load intp a frame
# Default: None
# Example: mycoolwebsite.com
# Example: *.mycoolwebsite.com
#
# allowed_sources = 
ip=0.0.0.0
port=5693

#
# -------------------------------
# Listener Configuration (API)
# -------------------------------
#

[api]

#
# The token that will be used to log into the basic web GUI (API browser, graphs, top charts, etc)
# and to authenticate requests to the API and requests through check_ncpa.py
#
community_string =90491701-3b9f-4821-af83-04a0c9e74294

#
# -------------------------------
# Passive Configuration (daemon)
# -------------------------------
#

[passive]

#
# Handlers are a comma separated list of what you would like the passive agent to run
# Default: None
# Options:
#   nrds, nrdp, kafkaproducer
#
# Example:
# handlers = nrds,nrdp,kafkaproducer
#
handlers =nrdp

#
# User and group to run passive checks as (Recommended to use nagios:nagios)
# Default: uid = nagios
# Default: gid = nagios
#
uid = nagios
gid = nagios

#
# Passive check interval - the amount in seconds to wait between each passive check by default,
# this can be overwritten by adding on a "|<duration>" in seconds to the passive check config
# Default: 300 (5 minutes)
#
sleep =300

#
# Passive logging file level, location, and the PID location
# Default: loglevel = info (debug, info, warning, error)
# Default: logfile = var/log/ncpa_passive.log
# Default: pidfile = var/run/ncpa_passive.pid (leave passive in pid file name)
#
loglevel =warning
logfile = var/log/ncpa_passive.log
pidfile = var/run/ncpa_passive.pid

#
# Delay passive checks from starting in seconds
# Default: 0
#
# delay_start = 30

#
# -------------------------------
# Passive Configuration (NRDP)
# -------------------------------
#

[nrdp]

#
# Connection settings to the NRDP server
# parent = NRDP server location (ex: http://<address>/nrdp)
# token = NRDP server token used to send NRDP results
#
parent =http://nagios.mshome.net/nrdp/
token =90491701-3b9f-4821-af83-04a0c9e74294

#
# The hostname that will replace %HOSTNAME% in the check definitions and will be
# sent to NRDP with the check name as the service description (service name)
#
hostname =dc01

#
# -------------------------------
# Passive Configuration (NRDS)
# -------------------------------
#

[nrds]

#
# NRDS CONFIGURATION DOES NOT WORK YET. MORE TO COME IN VERSION 2.1.0.
#

#
# NRDS connection information
#
url = 
token = 
config_name = 
config_version = 
update_config = 1
update_plugins = 1

[kafkaproducer]

#
# -------------------------------
# Passive Configuration (Kafka)
# -------------------------------
#

hostname = None
servers = localhost:9092
clientname = NCPA-Kafka
topic = ncpa

#
# -------------------------------
# Plugin Configuration
# -------------------------------
#

[plugin directives]

#
# Plugin path where all plugins will be ran from.
#
plugin_path = plugins/

#
# Plugin execution timeout in seconds. Different than the check_ncpa.py timeout, which is
# normally for network connection issues. Will return a CRITICAL value and error when the plugin
# reaches the defined max execution timeout and kills the process.
# Default: 60
#
# plugin_timeout = 60

#
# Extensions for plugins
# ----------------------
# The extension for the plugin denotes how NCPA will try to run the plugin. Use this
# for setting how you want to run the plugin in the command line.
#
# NOTE: Plugins without an extension will be ran in the cmdline as follows:
#       $plugin_name $plugin_args
#
# Defaults:
# .sh = /bin/sh $plugin_name $plugin_args
# .py = python $plugin_name $plugin_args
# .ps1 = powershell -ExecutionPolicy Bypass -File $plugin_name $plugin_args
# .vbs = cscript $plugin_name $plugin_args //NoLogo
# .bat = cmd /c $plugin_name $plugin_args
#
# Since windows NCPA is 32-bit, if you need to use 64-bit powershell, try the following for
# the powershell plugin definition:
# .ps1 = c:\\windows\\sysnative\\windowspowershell\\v1.0\\powershell.exe -ExecutionPolicy Unrestricted -File $plugin_name $plugin_args
#

# Linux / Mac OS X
.sh = /bin/sh $plugin_name $plugin_args
.py = python $plugin_name $plugin_args

# Windows
.ps1 = powershell -ExecutionPolicy Bypass -File $plugin_name $plugin_args
.vbs = cscript $plugin_name $plugin_args //NoLogo
.wsf = cscript $plugin_name $plugin_args //NoLogo
.bat = cmd /c $plugin_name $plugin_args

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

$nagios = '
##############################################################################
#
# NAGIOS.CFG - Sample Main Config File for Nagios 4.4.6
#
# Read the documentation for more information on this configuration
# file.  Ive provided some comments here, but things may not be so
# clear without further explanation.
#
#
##############################################################################


# LOG FILE
# This is the main log file where service and host events are logged
# for historical purposes.  This should be the first option specified
# in the config file!!!

log_file=/usr/local/nagios/var/nagios.log

cfg_dir=/etc/nagios

# OBJECT CONFIGURATION FILE(S)
# These are the object configuration files in which you define hosts,
# host groups, contacts, contact groups, services, etc.
# You can split your object definitions across several config files
# if you wish (as shown below), or keep them all in a single config file.

# You can specify individual object config files as shown below:
#cfg_file=/usr/local/nagios/etc/objects/commands.cfg
#cfg_file=/etc/nagios/nagios_command.cfg
#cfg_file=/etc/nagios/nagios_contact.cfg
#cfg_file=/etc/nagios/nagios_contactgroup.cfg
#cfg_file=/etc/nagios/resource.d/hostgroup_all-servers.cfg
#cfg_file=/etc/nagios/resource.d/host_nagios.mshome.net.cfg
#cfg_file=/usr/local/nagios/etc/objects/contacts.cfg
#cfg_file=/usr/local/nagios/etc/objects/timeperiods.cfg
#cfg_file=/usr/local/nagios/etc/objects/templates.cfg

# Definitions for monitoring the local (Linux) host
#cfg_file=/usr/local/nagios/etc/objects/localhost.cfg

# Definitions for monitoring a Windows machine
#cfg_file=/usr/local/nagios/etc/objects/windows.cfg

# Definitions for monitoring a router/switch
#cfg_file=/usr/local/nagios/etc/objects/switch.cfg

# Definitions for monitoring a network printer
#cfg_file=/usr/local/nagios/etc/objects/printer.cfg


# You can also tell Nagios to process all config files (with a .cfg
# extension) in a particular directory by using the cfg_dir
# directive as shown below:

#cfg_dir=/usr/local/nagios/etc/servers
#cfg_dir=/usr/local/nagios/etc/printers
#cfg_dir=/usr/local/nagios/etc/switches
#cfg_dir=/usr/local/nagios/etc/routers
#cfg_dir=/etc/nagios/resource.d
#cfg_dir=/etc/nagios




# OBJECT CACHE FILE
# This option determines where object definitions are cached when
# Nagios starts/restarts.  The CGIs read object definitions from
# this cache file (rather than looking at the object config files
# directly) in order to prevent inconsistencies that can occur
# when the config files are modified after Nagios starts.

object_cache_file=/usr/local/nagios/var/objects.cache



# PRE-CACHED OBJECT FILE
# This options determines the location of the precached object file.
# If you run Nagios with the -p command line option, it will preprocess
# your object configuration file(s) and write the cached config to this
# file.  You can then start Nagios with the -u option to have it read
# object definitions from this precached file, rather than the standard
# object configuration files (see the cfg_file and cfg_dir options above).
# Using a precached object file can speed up the time needed to (re)start
# the Nagios process if youve got a large and/or complex configuration.
# Read the documentation section on optimizing Nagios to find our more
# about how this feature works.

precached_object_file=/usr/local/nagios/var/objects.precache



# RESOURCE FILE
# This is an optional resource file that contains $USERx$ macro
# definitions. Multiple resource files can be specified by using
# multiple resource_file definitions.  The CGIs will not attempt to
# read the contents of resource files, so information that is
# considered to be sensitive (usernames, passwords, etc) can be
# defined as macros in this file and restrictive permissions (600)
# can be placed on this file.

resource_file=/usr/local/nagios/etc/resource.cfg



# STATUS FILE
# This is where the current status of all monitored services and
# hosts is stored.  Its contents are read and processed by the CGIs.
# The contents of the status file are deleted every time Nagios
#  restarts.

status_file=/usr/local/nagios/var/status.dat



# STATUS FILE UPDATE INTERVAL
# This option determines the frequency (in seconds) that
# Nagios will periodically dump program, host, and
# service status data.

status_update_interval=10



# NAGIOS USER
# This determines the effective user that Nagios should run as.
# You can either supply a username or a UID.

nagios_user=nagios



# NAGIOS GROUP
# This determines the effective group that Nagios should run as.
# You can either supply a group name or a GID.

nagios_group=nagios



# EXTERNAL COMMAND OPTION
# This option allows you to specify whether or not Nagios should check
# for external commands (in the command file defined below).
# By default Nagios will check for external commands.
# If you want to be able to use the CGI command interface
# you will have to enable this.
# Values: 0 = disable commands, 1 = enable commands

check_external_commands=1



# EXTERNAL COMMAND FILE
# This is the file that Nagios checks for external command requests.
# It is also where the command CGI will write commands that are submitted
# by users, so it must be writeable by the user that the web server
# is running as (usually nobody).  Permissions should be set at the
# directory level instead of on the file, as the file is deleted every
# time its contents are processed.

command_file=/usr/local/nagios/var/rw/nagios.cmd



# QUERY HANDLER INTERFACE
# This is the socket that is created for the Query Handler interface

#query_socket=/usr/local/nagios/var/rw/nagios.qh



# LOCK FILE
# This is the lockfile that Nagios will use to store its PID number
# in when it is running in daemon mode.

lock_file=/run/nagios.lock



# TEMP FILE
# This is a temporary file that is used as scratch space when Nagios
# updates the status log, cleans the comment file, etc.  This file
# is created, used, and deleted throughout the time that Nagios is
# running.

temp_file=/usr/local/nagios/var/nagios.tmp



# TEMP PATH
# This is path where Nagios can create temp files for service and
# host check results, etc.

temp_path=/tmp



# EVENT BROKER OPTIONS
# Controls what (if any) data gets sent to the event broker.
# Values:  0      = Broker nothing
#         -1      = Broker everything
#         <other> = See documentation

event_broker_options=-1



# EVENT BROKER MODULE(S)
# This directive is used to specify an event broker module that should
# by loaded by Nagios at startup.  Use multiple directives if you want
# to load more than one module.  Arguments that should be passed to
# the module at startup are separated from the module path by a space.
#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# WARNING !!! WARNING !!! WARNING !!! WARNING !!! WARNING !!! WARNING
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Do NOT overwrite modules while they are being used by Nagios or Nagios
# will crash in a fiery display of SEGFAULT glory.  This is a bug/limitation
# either in dlopen(), the kernel, and/or the filesystem.  And maybe Nagios...
#
# The correct/safe way of updating a module is by using one of these methods:
#    1. Shutdown Nagios, replace the module file, restart Nagios
#    2. Delete the original module file, move the new module file into place,
#       restart Nagios
#
# Example:
#
#   broker_module=<modulepath> [moduleargs]

#broker_module=/somewhere/module1.o
#broker_module=/somewhere/module2.o arg1 arg2=3 debug=0



# LOG ROTATION METHOD
# This is the log rotation method that Nagios should use to rotate
# the main log file. Values are as follows..
#       n       = None - don\'t rotate the log
#       h       = Hourly rotation (top of the hour)
#       d       = Daily rotation (midnight every day)
#       w       = Weekly rotation (midnight on Saturday evening)
#       m       = Monthly rotation (midnight last day of month)

log_rotation_method=d



# LOG ARCHIVE PATH
# This is the directory where archived (rotated) log files should be
# placed (assuming you\'ve chosen to do log rotation).

log_archive_path=/usr/local/nagios/var/archives



# LOGGING OPTIONS
# If you want messages logged to the syslog facility, as well as the
# Nagios log file set this option to 1.  If not, set it to 0.

use_syslog=1



# NOTIFICATION LOGGING OPTION
# If you don\'t want notifications to be logged, set this value to 0.
# If notifications should be logged, set the value to 1.

log_notifications=1



# SERVICE RETRY LOGGING OPTION
# If you don\'t want service check retries to be logged, set this value
# to 0.  If retries should be logged, set the value to 1.

log_service_retries=1



# HOST RETRY LOGGING OPTION
# If you don\'t want host check retries to be logged, set this value to
# 0.  If retries should be logged, set the value to 1.

log_host_retries=1



# EVENT HANDLER LOGGING OPTION
# If you don\'t want host and service event handlers to be logged, set
# this value to 0.  If event handlers should be logged, set the value
# to 1.

log_event_handlers=1



# INITIAL STATES LOGGING OPTION
# If you want Nagios to log all initial host and service states to
# the main log file (the first time the service or host is checked)
# you can enable this option by setting this value to 1.  If you
# are not using an external application that does long term state
# statistics reporting, you do not need to enable this option.  In
# this case, set the value to 0.

log_initial_states=0



# CURRENT STATES LOGGING OPTION
# If you don\'t want Nagios to log all current host and service states
# after log has been rotated to the main log file, you can disable this
# option by setting this value to 0. Default value is 1.

log_current_states=1



# EXTERNAL COMMANDS LOGGING OPTION
# If you don\'t want Nagios to log external commands, set this value
# to 0.  If external commands should be logged, set this value to 1.
# Note: This option does not include logging of passive service
# checks - see the option below for controlling whether or not
# passive checks are logged.

log_external_commands=1



# PASSIVE CHECKS LOGGING OPTION
# If you don\'t want Nagios to log passive host and service checks, set
# this value to 0.  If passive checks should be logged, set
# this value to 1.

log_passive_checks=1



# GLOBAL HOST AND SERVICE EVENT HANDLERS
# These options allow you to specify a host and service event handler
# command that is to be run for every host or service state change.
# The global event handler is executed immediately prior to the event
# handler that you have optionally specified in each host or
# service definition. The command argument is the short name of a
# command definition that you define in your host configuration file.
# Read the HTML docs for more information.

#global_host_event_handler=somecommand
#global_service_event_handler=somecommand



# SERVICE INTER-CHECK DELAY METHOD
# This is the method that Nagios should use when initially
# "spreading out" service checks when it starts monitoring.  The
# default is to use smart delay calculation, which will try to
# space all service checks out evenly to minimize CPU load.
# Using the dumb setting will cause all checks to be scheduled
# at the same time (with no delay between them)!  This is not a
# good thing for production, but is useful when testing the
# parallelization functionality.
#       n       = None - don\'t use any delay between checks
#       d       = Use a "dumb" delay of 1 second between checks
#       s       = Use "smart" inter-check delay calculation
#       x.xx    = Use an inter-check delay of x.xx seconds

service_inter_check_delay_method=s



# MAXIMUM SERVICE CHECK SPREAD
# This variable determines the timeframe (in minutes) from the
# program start time that an initial check of all services should
# be completed.  Default is 30 minutes.

max_service_check_spread=30



# SERVICE CHECK INTERLEAVE FACTOR
# This variable determines how service checks are interleaved.
# Interleaving the service checks allows for a more even
# distribution of service checks and reduced load on remote
# hosts.  Setting this value to 1 is equivalent to how versions
# of Nagios previous to 0.0.5 did service checks.  Set this
# value to s (smart) for automatic calculation of the interleave
# factor unless you have a specific reason to change it.
#       s       = Use "smart" interleave factor calculation
#       x       = Use an interleave factor of x, where x is a
#                 number greater than or equal to 1.

service_interleave_factor=s



# HOST INTER-CHECK DELAY METHOD
# This is the method that Nagios should use when initially
# "spreading out" host checks when it starts monitoring.  The
# default is to use smart delay calculation, which will try to
# space all host checks out evenly to minimize CPU load.
# Using the dumb setting will cause all checks to be scheduled
# at the same time (with no delay between them)!
#       n       = None - don\'t use any delay between checks
#       d       = Use a "dumb" delay of 1 second between checks
#       s       = Use "smart" inter-check delay calculation
#       x.xx    = Use an inter-check delay of x.xx seconds

host_inter_check_delay_method=s



# MAXIMUM HOST CHECK SPREAD
# This variable determines the timeframe (in minutes) from the
# program start time that an initial check of all hosts should
# be completed.  Default is 30 minutes.

max_host_check_spread=30



# MAXIMUM CONCURRENT SERVICE CHECKS
# This option allows you to specify the maximum number of
# service checks that can be run in parallel at any given time.
# Specifying a value of 1 for this variable essentially prevents
# any service checks from being parallelized.  A value of 0
# will not restrict the number of concurrent checks that are
# being executed.

max_concurrent_checks=0



# HOST AND SERVICE CHECK REAPER FREQUENCY
# This is the frequency (in seconds!) that Nagios will process
# the results of host and service checks.

check_result_reaper_frequency=10




# MAX CHECK RESULT REAPER TIME
# This is the max amount of time (in seconds) that  a single
# check result reaper event will be allowed to run before
# returning control back to Nagios so it can perform other
# duties.

max_check_result_reaper_time=30




# CHECK RESULT PATH
# This is directory where Nagios stores the results of host and
# service checks that have not yet been processed.
#
# Note: Make sure that only one instance of Nagios has access
# to this directory!

check_result_path=/usr/local/nagios/var/spool/checkresults




# MAX CHECK RESULT FILE AGE
# This option determines the maximum age (in seconds) which check
# result files are considered to be valid.  Files older than this
# threshold will be mercilessly deleted without further processing.

max_check_result_file_age=3600




# CACHED HOST CHECK HORIZON
# This option determines the maximum amount of time (in seconds)
# that the state of a previous host check is considered current.
# Cached host states (from host checks that were performed more
# recently that the timeframe specified by this value) can immensely
# improve performance in regards to the host check logic.
# Too high of a value for this option may result in inaccurate host
# states being used by Nagios, while a lower value may result in a
# performance hit for host checks.  Use a value of 0 to disable host
# check caching.

cached_host_check_horizon=15



# CACHED SERVICE CHECK HORIZON
# This option determines the maximum amount of time (in seconds)
# that the state of a previous service check is considered current.
# Cached service states (from service checks that were performed more
# recently that the timeframe specified by this value) can immensely
# improve performance in regards to predictive dependency checks.
# Use a value of 0 to disable service check caching.

cached_service_check_horizon=15



# ENABLE PREDICTIVE HOST DEPENDENCY CHECKS
# This option determines whether or not Nagios will attempt to execute
# checks of hosts when it predicts that future dependency logic test
# may be needed.  These predictive checks can help ensure that your
# host dependency logic works well.
# Values:
#  0 = Disable predictive checks
#  1 = Enable predictive checks (default)

enable_predictive_host_dependency_checks=1



# ENABLE PREDICTIVE SERVICE DEPENDENCY CHECKS
# This option determines whether or not Nagios will attempt to execute
# checks of service when it predicts that future dependency logic test
# may be needed.  These predictive checks can help ensure that your
# service dependency logic works well.
# Values:
#  0 = Disable predictive checks
#  1 = Enable predictive checks (default)

enable_predictive_service_dependency_checks=1



# SOFT STATE DEPENDENCIES
# This option determines whether or not Nagios will use soft state
# information when checking host and service dependencies. Normally
# Nagios will only use the latest hard host or service state when
# checking dependencies. If you want it to use the latest state (regardless
# of whether its a soft or hard state type), enable this option.
# Values:
#  0 = Don\'t use soft state dependencies (default)
#  1 = Use soft state dependencies

soft_state_dependencies=0



# TIME CHANGE ADJUSTMENT THRESHOLDS
# These options determine when Nagios will react to detected changes
# in system time (either forward or backwards).

#time_change_threshold=900



# AUTO-RESCHEDULING OPTION
# This option determines whether or not Nagios will attempt to
# automatically reschedule active host and service checks to
# "smooth" them out over time.  This can help balance the load on
# the monitoring server.
# WARNING: THIS IS AN EXPERIMENTAL FEATURE - IT CAN DEGRADE
# PERFORMANCE, RATHER THAN INCREASE IT, IF USED IMPROPERLY

auto_reschedule_checks=0



# AUTO-RESCHEDULING INTERVAL
# This option determines how often (in seconds) Nagios will
# attempt to automatically reschedule checks.  This option only
# has an effect if the auto_reschedule_checks option is enabled.
# Default is 30 seconds.
# WARNING: THIS IS AN EXPERIMENTAL FEATURE - IT CAN DEGRADE
# PERFORMANCE, RATHER THAN INCREASE IT, IF USED IMPROPERLY

auto_rescheduling_interval=30



# AUTO-RESCHEDULING WINDOW
# This option determines the "window" of time (in seconds) that
# Nagios will look at when automatically rescheduling checks.
# Only host and service checks that occur in the next X seconds
# (determined by this variable) will be rescheduled. This option
# only has an effect if the auto_reschedule_checks option is
# enabled.  Default is 180 seconds (3 minutes).
# WARNING: THIS IS AN EXPERIMENTAL FEATURE - IT CAN DEGRADE
# PERFORMANCE, RATHER THAN INCREASE IT, IF USED IMPROPERLY

auto_rescheduling_window=180



# TIMEOUT VALUES
# These options control how much time Nagios will allow various
# types of commands to execute before killing them off.  Options
# are available for controlling maximum time allotted for
# service checks, host checks, event handlers, notifications, the
# ocsp command, and performance data commands.  All values are in
# seconds.

service_check_timeout=60
host_check_timeout=30
event_handler_timeout=30
notification_timeout=30
ocsp_timeout=5
ochp_timeout=5
perfdata_timeout=5



# RETAIN STATE INFORMATION
# This setting determines whether or not Nagios will save state
# information for services and hosts before it shuts down.  Upon
# startup Nagios will reload all saved service and host state
# information before starting to monitor.  This is useful for
# maintaining long-term data on state statistics, etc, but will
# slow Nagios down a bit when it (re)starts.  Since its only
# a one-time penalty, I think its well worth the additional
# startup delay.

retain_state_information=1



# STATE RETENTION FILE
# This is the file that Nagios should use to store host and
# service state information before it shuts down.  The state
# information in this file is also read immediately prior to
# starting to monitor the network when Nagios is restarted.
# This file is used only if the retain_state_information
# variable is set to 1.

state_retention_file=/usr/local/nagios/var/retention.dat



# RETENTION DATA UPDATE INTERVAL
# This setting determines how often (in minutes) that Nagios
# will automatically save retention data during normal operation.
# If you set this value to 0, Nagios will not save retention
# data at regular interval, but it will still save retention
# data before shutting down or restarting.  If you have disabled
# state retention, this option has no effect.

retention_update_interval=60



# USE RETAINED PROGRAM STATE
# This setting determines whether or not Nagios will set
# program status variables based on the values saved in the
# retention file.  If you want to use retained program status
# information, set this value to 1.  If not, set this value
# to 0.

use_retained_program_state=1



# USE RETAINED SCHEDULING INFO
# This setting determines whether or not Nagios will retain
# the scheduling info (next check time) for hosts and services
# based on the values saved in the retention file.  If you
# If you want to use retained scheduling info, set this
# value to 1.  If not, set this value to 0.

use_retained_scheduling_info=1



# RETAINED ATTRIBUTE MASKS (ADVANCED FEATURE)
# The following variables are used to specify specific host and
# service attributes that should *not* be retained by Nagios during
# program restarts.
#
# The values of the masks are bitwise ANDs of values specified
# by the "MODATTR_" definitions found in include/common.h.
# For example, if you do not want the current enabled/disabled state
# of flap detection and event handlers for hosts to be retained, you
# would use a value of 24 for the host attribute mask...
# MODATTR_EVENT_HANDLER_ENABLED (8) + MODATTR_FLAP_DETECTION_ENABLED (16) = 24

# This mask determines what host attributes are not retained
retained_host_attribute_mask=0

# This mask determines what service attributes are not retained
retained_service_attribute_mask=0

# These two masks determine what process attributes are not retained.
# There are two masks, because some process attributes have host and service
# options.  For example, you can disable active host checks, but leave active
# service checks enabled.
retained_process_host_attribute_mask=0
retained_process_service_attribute_mask=0

# These two masks determine what contact attributes are not retained.
# There are two masks, because some contact attributes have host and
# service options.  For example, you can disable host notifications for
# a contact, but leave service notifications enabled for them.
retained_contact_host_attribute_mask=0
retained_contact_service_attribute_mask=0



# INTERVAL LENGTH
# This is the seconds per unit interval as used in the
# host/contact/service configuration files.  Setting this to 60 means
# that each interval is one minute long (60 seconds).  Other settings
# have not been tested much, so your mileage is likely to vary...

interval_length=60



# CHECK FOR UPDATES
# This option determines whether Nagios will automatically check to
# see if new updates (releases) are available.  It is recommend that you
# enable this option to ensure that you stay on top of the latest critical
# patches to Nagios.  Nagios is critical to you - make sure you keep it in
# good shape.  Nagios will check once a day for new updates. Data collected
# by Nagios Enterprises from the update check is processed in accordance
# with our privacy policy - see https://api.nagios.org for details.

check_for_updates=1



# BARE UPDATE CHECK
# This option determines what data Nagios will send to api.nagios.org when
# it checks for updates.  By default, Nagios will send information on the
# current version of Nagios you have installed, as well as an indicator as
# to whether this was a new installation or not.  Nagios Enterprises uses
# this data to determine the number of users running specific version of
# Nagios.  Enable this option if you do not want this information to be sent.

bare_update_check=0



# AGGRESSIVE HOST CHECKING OPTION
# If you don\'t want to turn on aggressive host checking features, set
# this value to 0 (the default).  Otherwise set this value to 1 to
# enable the aggressive check option.  Read the docs for more info
# on what aggressive host check is or check out the source code in
# base/checks.c

use_aggressive_host_checking=0



# SERVICE CHECK EXECUTION OPTION
# This determines whether or not Nagios will actively execute
# service checks when it initially starts.  If this option is
# disabled, checks are not actively made, but Nagios can still
# receive and process passive check results that come in.  Unless
# you\'re implementing redundant hosts or have a special need for
# disabling the execution of service checks, leave this enabled!
# Values: 1 = enable checks, 0 = disable checks

execute_service_checks=1



# PASSIVE SERVICE CHECK ACCEPTANCE OPTION
# This determines whether or not Nagios will accept passive
# service checks results when it initially (re)starts.
# Values: 1 = accept passive checks, 0 = reject passive checks

accept_passive_service_checks=1



# HOST CHECK EXECUTION OPTION
# This determines whether or not Nagios will actively execute
# host checks when it initially starts.  If this option is
# disabled, checks are not actively made, but Nagios can still
# receive and process passive check results that come in.  Unless
# you\'re implementing redundant hosts or have a special need for
# disabling the execution of host checks, leave this enabled!
# Values: 1 = enable checks, 0 = disable checks

execute_host_checks=1



# PASSIVE HOST CHECK ACCEPTANCE OPTION
# This determines whether or not Nagios will accept passive
# host checks results when it initially (re)starts.
# Values: 1 = accept passive checks, 0 = reject passive checks

accept_passive_host_checks=1



# NOTIFICATIONS OPTION
# This determines whether or not Nagios will sent out any host or
# service notifications when it is initially (re)started.
# Values: 1 = enable notifications, 0 = disable notifications

enable_notifications=1



# EVENT HANDLER USE OPTION
# This determines whether or not Nagios will run any host or
# service event handlers when it is initially (re)started.  Unless
# you\'re implementing redundant hosts, leave this option enabled.
# Values: 1 = enable event handlers, 0 = disable event handlers

enable_event_handlers=1



# PROCESS PERFORMANCE DATA OPTION
# This determines whether or not Nagios will process performance
# data returned from service and host checks.  If this option is
# enabled, host performance data will be processed using the
# host_perfdata_command (defined below) and service performance
# data will be processed using the service_perfdata_command (also
# defined below).  Read the HTML docs for more information on
# performance data.
# Values: 1 = process performance data, 0 = do not process performance data

process_performance_data=0



# HOST AND SERVICE PERFORMANCE DATA PROCESSING COMMANDS
# These commands are run after every host and service check is
# performed.  These commands are executed only if the
# enable_performance_data option (above) is set to 1.  The command
# argument is the short name of a command definition that you
# define in your host configuration file.  Read the HTML docs for
# more information on performance data.

#host_perfdata_command=process-host-perfdata
#service_perfdata_command=process-service-perfdata



# HOST AND SERVICE PERFORMANCE DATA FILES
# These files are used to store host and service performance data.
# Performance data is only written to these files if the
# enable_performance_data option (above) is set to 1.

#host_perfdata_file=/usr/local/nagios/var/host-perfdata
#service_perfdata_file=/usr/local/nagios/var/service-perfdata



# HOST AND SERVICE PERFORMANCE DATA FILE TEMPLATES
# These options determine what data is written (and how) to the
# performance data files.  The templates may contain macros, special
# characters (\\t for tab, \\r for carriage return, \\n for newline)
# and plain text.  A newline is automatically added after each write
# to the performance data file.  Some examples of what you can do are
# shown below.

#host_perfdata_file_template=[HOSTPERFDATA]\\t$TIMET$\\t$HOSTNAME$\\t$HOSTEXECUTIONTIME$\\t$HOSTOUTPUT$\\t$HOSTPERFDATA$
#service_perfdata_file_template=[SERVICEPERFDATA]\\t$TIMET$\\t$HOSTNAME$\\t$SERVICEDESC$\\t$SERVICEEXECUTIONTIME$\\t$SERVICELATENCY$\\t$SERVICEOUTPUT$\\t$SERVICEPERFDATA$



# HOST AND SERVICE PERFORMANCE DATA FILE MODES
# This option determines whether or not the host and service
# performance data files are opened in write ("w") or append ("a")
# mode. If you want to use named pipes, you should use the special
# pipe ("p") mode which avoid blocking at startup, otherwise you will
# likely want the default append ("a") mode.

#host_perfdata_file_mode=a
#service_perfdata_file_mode=a



# HOST AND SERVICE PERFORMANCE DATA FILE PROCESSING INTERVAL
# These options determine how often (in seconds) the host and service
# performance data files are processed using the commands defined
# below.  A value of 0 indicates the files should not be periodically
# processed.

#host_perfdata_file_processing_interval=0
#service_perfdata_file_processing_interval=0



# HOST AND SERVICE PERFORMANCE DATA FILE PROCESSING COMMANDS
# These commands are used to periodically process the host and
# service performance data files.  The interval at which the
# processing occurs is determined by the options above.

#host_perfdata_file_processing_command=process-host-perfdata-file
#service_perfdata_file_processing_command=process-service-perfdata-file



# HOST AND SERVICE PERFORMANCE DATA PROCESS EMPTY RESULTS
# These options determine whether the core will process empty perfdata
# results or not. This is needed for distributed monitoring, and intentionally
# turned on by default.
# If you don\'t require empty perfdata - saving some cpu cycles
# on unwanted macro calculation - you can turn that off. Be careful!
# Values: 1 = enable, 0 = disable

#host_perfdata_process_empty_results=1
#service_perfdata_process_empty_results=1


# OBSESS OVER SERVICE CHECKS OPTION
# This determines whether or not Nagios will obsess over service
# checks and run the ocsp_command defined below.  Unless you\'re
# planning on implementing distributed monitoring, do not enable
# this option.  Read the HTML docs for more information on
# implementing distributed monitoring.
# Values: 1 = obsess over services, 0 = do not obsess (default)

obsess_over_services=0



# OBSESSIVE COMPULSIVE SERVICE PROCESSOR COMMAND
# This is the command that is run for every service check that is
# processed by Nagios.  This command is executed only if the
# obsess_over_services option (above) is set to 1.  The command
# argument is the short name of a command definition that you
# define in your host configuration file. Read the HTML docs for
# more information on implementing distributed monitoring.

#ocsp_command=somecommand



# OBSESS OVER HOST CHECKS OPTION
# This determines whether or not Nagios will obsess over host
# checks and run the ochp_command defined below.  Unless you\'re
# planning on implementing distributed monitoring, do not enable
# this option.  Read the HTML docs for more information on
# implementing distributed monitoring.
# Values: 1 = obsess over hosts, 0 = do not obsess (default)

obsess_over_hosts=0



# OBSESSIVE COMPULSIVE HOST PROCESSOR COMMAND
# This is the command that is run for every host check that is
# processed by Nagios.  This command is executed only if the
# obsess_over_hosts option (above) is set to 1.  The command
# argument is the short name of a command definition that you
# define in your host configuration file. Read the HTML docs for
# more information on implementing distributed monitoring.

#ochp_command=somecommand



# TRANSLATE PASSIVE HOST CHECKS OPTION
# This determines whether or not Nagios will translate
# DOWN/UNREACHABLE passive host check results into their proper
# state for this instance of Nagios.  This option is useful
# if you have distributed or failover monitoring setup.  In
# these cases your other Nagios servers probably have a different
# "view" of the network, with regards to the parent/child relationship
# of hosts.  If a distributed monitoring server thinks a host
# is DOWN, it may actually be UNREACHABLE from the point of
# this Nagios instance.  Enabling this option will tell Nagios
# to translate any DOWN or UNREACHABLE host states it receives
# passively into the correct state from the view of this server.
# Values: 1 = perform translation, 0 = do not translate (default)

translate_passive_host_checks=0



# PASSIVE HOST CHECKS ARE SOFT OPTION
# This determines whether or not Nagios will treat passive host
# checks as being HARD or SOFT.  By default, a passive host check
# result will put a host into a HARD state type.  This can be changed
# by enabling this option.
# Values: 0 = passive checks are HARD, 1 = passive checks are SOFT

passive_host_checks_are_soft=0



# ORPHANED HOST/SERVICE CHECK OPTIONS
# These options determine whether or not Nagios will periodically
# check for orphaned host service checks.  Since service checks are
# not rescheduled until the results of their previous execution
# instance are processed, there exists a possibility that some
# checks may never get rescheduled.  A similar situation exists for
# host checks, although the exact scheduling details differ a bit
# from service checks.  Orphaned checks seem to be a rare
# problem and should not happen under normal circumstances.
# If you have problems with service checks never getting
# rescheduled, make sure you have orphaned service checks enabled.
# Values: 1 = enable checks, 0 = disable checks

check_for_orphaned_services=1
check_for_orphaned_hosts=1



# SERVICE FRESHNESS CHECK OPTION
# This option determines whether or not Nagios will periodically
# check the "freshness" of service results.  Enabling this option
# is useful for ensuring passive checks are received in a timely
# manner.
# Values: 1 = enabled freshness checking, 0 = disable freshness checking

check_service_freshness=1



# SERVICE FRESHNESS CHECK INTERVAL
# This setting determines how often (in seconds) Nagios will
# check the "freshness" of service check results.  If you have
# disabled service freshness checking, this option has no effect.

service_freshness_check_interval=60



# SERVICE CHECK TIMEOUT STATE
# This setting determines the state Nagios will report when a
# service check times out - that is does not respond within
# service_check_timeout seconds.  This can be useful if a
# machine is running at too high a load and you do not want
# to consider a failed service check to be critical (the default).
# Valid settings are:
# c - Critical (default)
# u - Unknown
# w - Warning
# o - OK

service_check_timeout_state=c



# HOST FRESHNESS CHECK OPTION
# This option determines whether or not Nagios will periodically
# check the "freshness" of host results.  Enabling this option
# is useful for ensuring passive checks are received in a timely
# manner.
# Values: 1 = enabled freshness checking, 0 = disable freshness checking

check_host_freshness=0



# HOST FRESHNESS CHECK INTERVAL
# This setting determines how often (in seconds) Nagios will
# check the "freshness" of host check results.  If you have
# disabled host freshness checking, this option has no effect.

host_freshness_check_interval=60




# ADDITIONAL FRESHNESS THRESHOLD LATENCY
# This setting determines the number of seconds that Nagios
# will add to any host and service freshness thresholds that
# it calculates (those not explicitly specified by the user).

additional_freshness_latency=15




# FLAP DETECTION OPTION
# This option determines whether or not Nagios will try
# and detect hosts and services that are "flapping".
# Flapping occurs when a host or service changes between
# states too frequently.  When Nagios detects that a
# host or service is flapping, it will temporarily suppress
# notifications for that host/service until it stops
# flapping.  Flap detection is very experimental, so read
# the HTML documentation before enabling this feature!
# Values: 1 = enable flap detection
#         0 = disable flap detection (default)

enable_flap_detection=1



# FLAP DETECTION THRESHOLDS FOR HOSTS AND SERVICES
# Read the HTML documentation on flap detection for
# an explanation of what this option does.  This option
# has no effect if flap detection is disabled.

low_service_flap_threshold=5.0
high_service_flap_threshold=20.0
low_host_flap_threshold=5.0
high_host_flap_threshold=20.0



# DATE FORMAT OPTION
# This option determines how short dates are displayed. Valid options
# include:
#       us              (MM-DD-YYYY HH:MM:SS)
#       euro            (DD-MM-YYYY HH:MM:SS)
#       iso8601         (YYYY-MM-DD HH:MM:SS)
#       strict-iso8601  (YYYY-MM-DDTHH:MM:SS)
#

date_format=us




# TIMEZONE OFFSET
# This option is used to override the default timezone that this
# instance of Nagios runs in.  If not specified, Nagios will use
# the system configured timezone.
#
# NOTE: In order to display the correct timezone in the CGIs, you
# will also need to alter the Apache directives for the CGI path
# to include your timezone.  Example:
#
#   <Directory "/usr/local/nagios/sbin/">
#      SetEnv TZ "Australia/Brisbane"
#      ...
#   </Directory>

#use_timezone=US/Mountain
#use_timezone=Australia/Brisbane



# ILLEGAL OBJECT NAME CHARACTERS
# This option allows you to specify illegal characters that cannot
# be used in host names, service descriptions, or names of other
# object types.

illegal_object_name_chars=`~!$%^&*|\'"<>?,()=



# ILLEGAL MACRO OUTPUT CHARACTERS
# This option allows you to specify illegal characters that are
# stripped from macros before being used in notifications, event
# handlers, etc.  This DOES NOT affect macros used in service or
# host check commands.
# The following macros are stripped of the characters you specify:
#       $HOSTOUTPUT$
#       $LONGHOSTOUTPUT$
#       $HOSTPERFDATA$
#       $HOSTACKAUTHOR$
#       $HOSTACKCOMMENT$
#       $SERVICEOUTPUT$
#       $LONGSERVICEOUTPUT$
#       $SERVICEPERFDATA$
#       $SERVICEACKAUTHOR$
#       $SERVICEACKCOMMENT$

illegal_macro_output_chars=`~$&|\'"<>



# REGULAR EXPRESSION MATCHING
# This option controls whether or not regular expression matching
# takes place in the object config files.  Regular expression
# matching is used to match host, hostgroup, service, and service
# group names/descriptions in some fields of various object types.
# Values: 1 = enable regexp matching, 0 = disable regexp matching

use_regexp_matching=0



# "TRUE" REGULAR EXPRESSION MATCHING
# This option controls whether or not "true" regular expression
# matching takes place in the object config files.  This option
# only has an effect if regular expression matching is enabled
# (see above).  If this option is DISABLED, regular expression
# matching only occurs if a string contains wildcard characters
# (* and ?).  If the option is ENABLED, regexp matching occurs
# all the time (which can be annoying).
# Values: 1 = enable true matching, 0 = disable true matching

use_true_regexp_matching=0



# ADMINISTRATOR EMAIL/PAGER ADDRESSES
# The email and pager address of a global administrator (likely you).
# Nagios never uses these values itself, but you can access them by
# using the $ADMINEMAIL$ and $ADMINPAGER$ macros in your notification
# commands.

admin_email=nagios@localhost
admin_pager=pagenagios@localhost



# DAEMON CORE DUMP OPTION
# This option determines whether or not Nagios is allowed to create
# a core dump when it runs as a daemon.  Note that it is generally
# considered bad form to allow this, but it may be useful for
# debugging purposes.  Enabling this option doesn\'t guarantee that
# a core file will be produced, but that\'s just life...
# Values: 1 - Allow core dumps
#         0 - Do not allow core dumps (default)

daemon_dumps_core=0



# LARGE INSTALLATION TWEAKS OPTION
# This option determines whether or not Nagios will take some shortcuts
# which can save on memory and CPU usage in large Nagios installations.
# Read the documentation for more information on the benefits/tradeoffs
# of enabling this option.
# Values: 1 - Enabled tweaks
#         0 - Disable tweaks (default)

use_large_installation_tweaks=0



# ENABLE ENVIRONMENT MACROS
# This option determines whether or not Nagios will make all standard
# macros available as environment variables when host/service checks
# and system commands (event handlers, notifications, etc.) are
# executed.
# Enabling this is a very bad idea for anything but very small setups,
# as it means plugins, notification scripts and eventhandlers may run
# out of environment space. It will also cause a significant increase
# in CPU- and memory usage and drastically reduce the number of checks
# you can run.
# Values: 1 - Enable environment variable macros
#         0 - Disable environment variable macros (default)

enable_environment_macros=0



# CHILD PROCESS MEMORY OPTION
# This option determines whether or not Nagios will free memory in
# child processes (processed used to execute system commands and host/
# service checks).  If you specify a value here, it will override
# program defaults.
# Value: 1 - Free memory in child processes
#        0 - Do not free memory in child processes

#free_child_process_memory=1



# CHILD PROCESS FORKING BEHAVIOR
# This option determines how Nagios will fork child processes
# (used to execute system commands and host/service checks).  Normally
# child processes are fork()ed twice, which provides a very high level
# of isolation from problems.  Fork()ing once is probably enough and will
# save a great deal on CPU usage (in large installs), so you might
# want to consider using this.  If you specify a value here, it will
# program defaults.
# Value: 1 - Child processes fork() twice
#        0 - Child processes fork() just once

#child_processes_fork_twice=1



# DEBUG LEVEL
# This option determines how much (if any) debugging information will
# be written to the debug file.  OR values together to log multiple
# types of information.
# Values:
#         -1      = Everything
#          0      = Nothing
#          1      = Functions
#          2      = Configuration
#          4      = Process information
#          8      = Scheduled events
#          16     = Host/service checks
#          32     = Notifications
#          64     = Event broker
#          128    = External commands
#          256    = Commands
#          512    = Scheduled downtime
#          1024   = Comments
#          2048   = Macros
#          4096   = Interprocess communication
#          8192   = Scheduling
#          16384  = Workers

debug_level=0



# DEBUG VERBOSITY
# This option determines how verbose the debug log out will be.
# Values: 0 = Brief output
#         1 = More detailed
#         2 = Very detailed

debug_verbosity=1



# DEBUG FILE
# This option determines where Nagios should write debugging information.

debug_file=/usr/local/nagios/var/nagios.debug



# MAX DEBUG FILE SIZE
# This option determines the maximum size (in bytes) of the debug file.  If
# the file grows larger than this size, it will be renamed with a .old
# extension.  If a file already exists with a .old extension it will
# automatically be deleted.  This helps ensure your disk space usage doesn\'t
# get out of control when debugging Nagios.

max_debug_file_size=1000000



# Should we allow hostgroups to have no hosts, we default this to off since
# that was the old behavior

allow_empty_hostgroup_assignment=0



# Normally worker count is dynamically allocated based on 1.5 * number of cpu\'s
# with a minimum of 4 workers.  This value will override the defaults

#check_workers=3



# DISABLE SERVICE CHECKS WHEN HOST DOWN
# This option will disable all service checks if the host is not in an UP state
#
# While desirable in some environments, enabling this value can distort report
# values as the expected quantity of checks will not have been performed

#host_down_disable_service_checks=0



# SET SERVICE/HOST STATUS WHEN SERVICE CHECK SKIPPED
# These options will allow you to set the status of a service when its
# service check is skipped due to one of three reasons:
# 1) failed dependency check; 2) parent\'s status; 3) host not up
# Number 3 can only happen if \'host_down_disable_service_checks\' above
# is set to 1.
# Valid values for the service* options are:
#     -1     Do not change the service status (default - same as before 4.4)
#      0     Set the service status to STATE_OK
#      1     Set the service status to STATE_WARNING
#      2     Set the service status to STATE_CRITICAL
#      3     Set the service status to STATE_UNKNOWN
# The host_skip_check_dependency_status option will allow you to set the
# status of a host when itscheck is skipped due to a failed dependency check.
# Valid values for the host_skip_check_dependency_status are:
#     -1     Do not change the service status (default - same as before 4.4)
#      0     Set the host status to STATE_UP
#      1     Set the host status to STATE_DOWN
#      2     Set the host status to STATE_UNREACHABLE
# We may add one or more statuses in the future.

#service_skip_check_dependency_status=-1
#service_skip_check_parent_status=-1
#service_skip_check_host_down_status=-1
#host_skip_check_dependency_status=-1



# LOAD CONTROL OPTIONS
# To get current defaults based on your system, issue this command to
# the query handler:
#    echo -e \'@core loadctl\\0\' | nc -U /usr/local/nagios/var/rw/nagios.qh
#
# Please note that used incorrectly these options can induce enormous latency.
#
# loadctl_options:
#   jobs_max        The maximum amount of jobs to run at one time
#   jobs_min        The minimum amount of jobs to run at one time
#   jobs_limit      The maximum amount of jobs the current load lets us run
#   backoff_limit   The minimum backoff_change
#   backoff_change  # of jobs to remove from jobs_limit when backing off
#   rampup_limit    Minimum rampup_change
#   rampup_change   # of jobs to add to jobs_limit when ramping up

#loadctl_options=jobs_max=100;backoff_limit=10;rampup_change=5

'




  file { "/root/installnagios.sh" :
    ensure   => present,
    content => $installnagios,
    mode => '0655',
  }

  file { "/var/www/html/index.html" :
    ensure   => present,
    #ensure   => absent,
    content => '',
    #owner => 'nagios',
    #group => 'nagios',
    mode => '0755',
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


  file { "/usr/local/nagios/etc/nagios.cfg" :
    ensure   => present,
    #ensure   => absent,
    content => $nagios,
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
    notify => Service['nagios'],
  }

  nagios_command {'notify-host-by-email':
    ensure => present,
    command_line => '/usr/bin/printf "%b" "***** Nagios *****\\n\\nNotification Type: $NOTIFICATIONTYPE$\\nHost: $HOSTNAME$\\nState: $HOSTSTATE$\\nAddress: $HOSTADDRESS$\\nInfo: $HOSTOUTPUT$\\n\\nDate/Time: $LONGDATETIME$\\n" | /usr/bin/mail -s "** $NOTIFICATIONTYPE$ Host Alert: $HOSTNAME$ is $HOSTSTATE$ **" $CONTACTEMAIL$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }

  nagios_command {'notify-service-by-email':
    ensure => present,
    command_line => '/usr/bin/printf "%b" "***** Nagios *****\\n\\nNotification Type: $NOTIFICATIONTYPE$\\n\\nService: $SERVICEDESC$\\nHost: $HOSTALIAS$\\nAddress: $HOSTADDRESS$\\nState: $SERVICESTATE$\\n\\nDate/Time: $LONGDATETIME$\\n\\nAdditional Info:\\n\\n$SERVICEOUTPUT$\\n" | /usr/bin/mail -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" $CONTACTEMAIL$',
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
    command_line => '/usr/bin/printf "%b" "$LASTHOSTCHECK$\\t$HOSTNAME$\\t$HOSTSTATE$\\t$HOSTATTEMPT$\\t$HOSTSTATETYPE$\\t$HOSTEXECUTIONTIME$\\t$HOSTOUTPUT$\\t$HOSTPERFDATA$\\n" >> /usr/local/nagios/var/host-perfdata.out',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }


  nagios_command {'process-service-perfdata':
    ensure => present,
    command_line => '/usr/bin/printf "%b" "$LASTSERVICECHECK$\\t$HOSTNAME$\\t$SERVICEDESC$\\t$SERVICESTATE$\\t$SERVICEATTEMPT$\\t$SERVICESTATETYPE$\\t$SERVICEEXECUTIONTIME$\\t$SERVICELATENCY$\\t$SERVICEOUTPUT$\\t$SERVICEPERFDATA$\\n" >> /usr/local/nagios/var/service-perfdata.out',
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

  ###############################################################################
  # TIMEPERIODS.CFG - SAMPLE TIMEPERIOD DEFINITIONS
  #
  #
  # NOTES: This config file provides you with some example timeperiod definitions
  #        that you can reference in host, service, contact, and dependency
  #        definitions.
  #
  #        You don't need to keep timeperiods in a separate file from your other
  #        object definitions.  This has been done just to make things easier to
  #        understand.
  #
  ###############################################################################



  ###############################################################################
  #
  # TIMEPERIOD DEFINITIONS
  #
  ###############################################################################

  # This defines a timeperiod where all times are valid for checks,
  # notifications, etc.  The classic "24x7" support nightmare. :-)

  nagios_timeperiod { '24x7':
    ensure => present,
    alias => '24 Hours A Day, 7 Days A Week',
    sunday => '00:00-24:00',
    monday => '00:00-24:00',
    tuesday => '00:00-24:00',
    wednesday => '00:00-24:00',
    thursday => '00:00-24:00',
    friday => '00:00-24:00',
    saturday => '00:00-24:00',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,

  }


  # This defines a timeperiod that is normal workhours for
  # those of us monitoring networks and such in the U.S.


  nagios_timeperiod { 'workhours':
    ensure => present,
    alias => 'Normal Work Hours',
    monday => '09:00-17:00',
    tuesday => '09:00-17:00',
    wednesday => '09:00-17:00',
    thursday => '09:00-17:00',
    friday => '09:00-17:00',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,

  }


  # This defines the *perfect* check and notification
  # timeperiod

  nagios_timeperiod { 'none':
    ensure => present,
    alias => 'No Time Is A Good Time',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,

  }



  # Some U.S. holidays
  # Note: The timeranges for each holiday are meant to *exclude* the holidays from being
  # treated as a valid time for notifications, etc.  You probably don't want your pager
  # going off on New Year's.  Although your employer might... :-)

  # january 1 ; New Years
  # monday -1 may ; Memorial Day (last Monday in May)
  # july 4 ; Independence Day
  # monday 1 september ; Labor Day (first Monday in September)
  # thursday 4 november ; Thanksgiving (4th Thursday in November)
  # december 25 ; Christmas

/*

  nagios_timeperiod { 'us-holidays':
    ensure => present,
    january 1 => '00:00-00:00',     ; New Years
    monday -1 may => '00:00-00:00',     ; Memorial Day (last Monday in May)
    july 4 => '00:00-00:00',     ; Independence Day
    monday 1 september => '00:00-00:00',     ; Labor Day (first Monday in September)
    thursday 4 november => '00:00-00:00',     ; Thanksgiving (4th Thursday in November)
    december 25 => '00:00-00:00',     ; Christmas
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,

  }

*/

  # This defines a modified "24x7" timeperiod that covers every day of the
  # year, except for U.S. holidays (defined in the timeperiod above).

  # Get holiday exceptions from other timeperiod

  nagios_timeperiod { '24x7_sans_holidays':
    ensure => present,
    alias => '24x7_sans_holidays',
    sunday => '00:00-24:00',
    monday => '00:00-24:00',
    tuesday => '00:00-24:00',
    wednesday => '00:00-24:00',
    thursday => '00:00-24:00',
    friday => '00:00-24:00',
    saturday => '00:00-24:00',
    #use => 'us-holidays',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,

  }


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


  nagios_host { 'localhost':
    ensure => present,
    alias => 'localhost',
    use => 'linux-server',
    address => '127.0.0.1',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }

  ###############################################################################
  #
  # HOST GROUP DEFINITION
  #
  ###############################################################################

  # Define an optional hostgroup for Linux machines

  nagios_hostgroup { 'linux-servers':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    alias => 'Linux Servers',
    members => 'localhost',
    notify => Service['nagios'],
  }



  ###############################################################################
  #
  # SERVICE DEFINITIONS
  #
  ###############################################################################

  # Define a service to "ping" the local machine

  nagios_service { 'local ping':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    use => 'local-service',
    host_name => 'localhost',
    service_description => 'PING',
    check_command => 'check_ping!100.0,20%!500.0,60%',

  }


  # Define a service to check the disk space of the root partition
  # on the local machine.  Warning if < 20% free, critical if
  # < 10% free space on partition.

/*
  nagios_service { '':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    use => 'local-service',
    host_name => 'localhost',
    service_description => '',
    check_command => '',

  }
  */

  nagios_service { 'local / free space':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    use => 'local-service',
    host_name => 'localhost',
    service_description => 'Root Partition',
    check_command => 'check_local_disk!20%!10%!/',

  }


  # Define a service to check the number of currently logged in
  # users on the local machine.  Warning if > 20 users, critical
  # if > 50 users.

  nagios_service { 'Current Users':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    use => 'local-service',
    host_name => 'localhost',
    service_description => 'Current Users',
    check_command => 'check_local_users!20!50',

  }



  # Define a service to check the number of currently running procs
  # on the local machine.  Warning if > 250 processes, critical if
  # > 400 processes.



  nagios_service { 'Total Processes':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    use => 'local-service',
    host_name => 'localhost',
    service_description => 'Total Processes',
    check_command => 'check_local_procs!250!400!RSZDT',

  }


  # Define a service to check the load on the local machine.

  nagios_service { 'Current Load':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    use => 'local-service',
    host_name => 'localhost',
    service_description => 'Current Load',
    check_command => 'check_local_load!5.0,4.0,3.0!10.0,6.0,4.0',

  }

  # Define a service to check the swap usage the local machine.
  # Critical if less than 10% of swap is free, warning if less than 20% is free

  nagios_service { 'Swap Usage':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    use => 'local-service',
    host_name => 'localhost',
    service_description => 'Swap Usage',
    check_command => 'check_local_swap!20%!10%',

  }



  # Define a service to check SSH on the local machine.
  # Disable notifications for this service by default, as not all users may have SSH enabled.


  nagios_service { 'SSH':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    use => 'local-service',
    host_name => 'localhost',
    service_description => 'SSH',
    check_command => 'check_ssh',
    notifications_enabled => '0',

  }


  # Define a service to check HTTP on the local machine.
  # Disable notifications for this service by default, as not all users may have HTTP enabled.

  nagios_service { 'HTTP':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    use => 'local-service',
    host_name => 'localhost',
    service_description => 'HTTP',
    check_command => 'check_http',
    notifications_enabled => '0',
    notify => Service['nagios'],

  }














  # NCPA config DC01

  nagios_command {'check_dummy':
    ensure => present,
    command_line => '$USER1$/check_dummy $ARG1$',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }

  nagios_host { 'passive_host':
    ensure => present,
    use => 'generic-host',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    active_checks_enabled => '0',
    passive_checks_enabled => '1',
    flap_detection_enabled => '0',
    register => '0',
    check_period => '24x7',
    max_check_attempts => '1',
    check_interval => '5',
    retry_interval => '1',
    check_freshness => '0',
    contact_groups => 'admins',
    check_command => 'check_dummy!0',
    notification_interval => '60',
    notification_period => '24x7',
    notification_options => 'd,u,r',
  }


  nagios_service { 'passive_service':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    use => 'generic-service',
    active_checks_enabled => '0',
    passive_checks_enabled => '1',
    flap_detection_enabled => '0',
    register => '0',
    check_period => '24x7',
    max_check_attempts => '1',
    check_interval => '5',
    retry_interval => '1',
    check_freshness => '0',
    contact_groups => 'admins',
    check_command => 'check_dummy!0',
    notification_interval => '60',
    notification_period => '24x7',
    notification_options => 'w,u,c,r',
    service_description => 'passive_service',

  }




  nagios_host { 'dc01':
    ensure => present,
    use => 'passive_host',
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
  }



  nagios_service { 'CPU Usage':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    host_name => 'dc01',
    use => 'passive_service',
    #service_description => 'CPU Usage',

  }

  nagios_service { 'Disk Usage':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    host_name => 'dc01',
    use => 'passive_service',
    #service_description => 'Disk Usage',

  }

  /*

  nagios_service { 'Swap Usage':
    ensure => absent,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    host_name => 'dc01',
    use => 'passive_service',

  }

  */

  nagios_service { 'Memory Usage':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    host_name => 'dc01',
    use => 'passive_service',
    #service_description => 'Memory Usage',

  }

  nagios_service { 'Process Count':
    ensure => present,
    mode => '0777',
    group => $nagios::params::user,
    owner => $nagios::params::user,
    host_name => 'dc01',
    use => 'passive_service',
    #service_description => 'Process Count',

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
