#!/bin/bash

if [ -d /opt/puppetlabs/server ]; then
    exit 0
else 
    exit 1
fi

