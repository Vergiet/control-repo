class nagios::ncpa {



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
%HOSTNAME%|CPU Usage DC01.mshome.net = cpu/percent --warning 80 --critical 90 --aggregate avg
%HOSTNAME%|Disk Usage DC01.mshome.net = disk/logical/C:|/used_percent --warning 80 --critical 90 --units Gi
%HOSTNAME%|Swap Usage DC01.mshome.net = memory/swap --warning 60 --critical 80 --units Gi
%HOSTNAME%|Memory Usage DC01.mshome.net = memory/virtual --warning 80 --critical 90 --units Gi
%HOSTNAME%|Process Count DC01.mshome.net = processes --warning 300 --critical 400

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
token =d19e2543-5c32-4c04-b193-552547f919a3

#
# The hostname that will replace %HOSTNAME% in the check definitions and will be
# sent to NRDP with the check name as the service description (service name)
#
#hostname =DC01.mshome.net
hostname =<%= $hostname %> 

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

  include nagios::params

  service { $nagios::params::ncpaservice:
    ensure => running,
    enable => true,
  }

  $downloads_dir = 'c:\\downloads'

  file { $downloads_dir:
    ensure => directory,
  }

  $tools_dir = 'c:\\downloads\\tools'

  file { $tools_dir:
    ensure => directory,
    require => File[$downloads_dir],
  }

  file { "c:\\downloads\\tools\\ncpa.exe" :
    ensure   => present,
    source => 'https://assets.nagios.com/downloads/ncpa/ncpa-2.2.2.exe',
    require => File[$downloads_dir],
  }

  exec { 'installncpa':
    command     => 'start-process "c:\\downloads\\tools\\ncpa.exe" -ArgumentList "/S", "/TOKEN=\'d19e2543-5c32-4c04-b193-552547f919a3\'", "/NRDPURL=\'http://nagios.mshome.net/nrdp/\'", "/NRDPTOKEN=\'d19e2543-5c32-4c04-b193-552547f919a3\'", "/NRDPHOSTNAME=\'dc01\'" -NoNewWindow -Wait',
    require   => File["c:\\downloads\\tools\\ncpa.exe"],
    provider => 'powershell',
    unless => 'if (Test-Path -Path "C:\\Program Files (x86)\\Nagios\\NCPA\\ncpa_passive.exe" -PathType Leaf){exit} else {exit 1}',
  }

  $winncpaconfigrender = inline_epp($winncpaconfig, {'hostname' => $::fqdn})
  file { "C:\\Program Files (x86)\\Nagios\\NCPA\\etc\\ncpa.cfg" :
    ensure   => present,
    content => $winncpaconfigrender,
    require => Exec['installncpa'],
    notify => Service[$nagios::params::ncpaservice],
  }

  file { "C:\\Program Files (x86)\\Nagios\\NCPA\\etc\\ncpa.cfg.d\\nrdp.cfg" :
    ensure   => absent,
    content => $winncpapassivechecksconfig,
    require => Exec['installncpa'],
    notify => Service[$nagios::params::ncpaservice],
  }



}
