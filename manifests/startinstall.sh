#!/bin/bash

if [ -d /opt/puppetlabs/server ]; then

    echo 'PE already installed'
else 

    export LANG=en_US.UTF-8
    export LANGUAGE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    /root/puppet-enterprise-2019.7.0-el-7-x86_64/puppet-enterprise-installer -c /root/pe.conf

fi


