#!/bin/bash

set -x

# Detect the host os type
HOSTOS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

# Read password for ssh key encryption
#read -p "Enter passphrase for the ssh key file: " SSHPASS

# Read password for ssh key encryption
#read -p "Enter Ansible Tower IP address/FQDN: " TOWER

case $HOSTOS in
    '"CentOS Linux"'|'Fedora')
        # Update
        sudo yum update -y
        # Install Python modules
        sudo yum install -y python2 python-simplejson
        # Install SELinux modules
        sudo yum install -y libselinux-python
        # Generate SSH ID and copy to ansible tower
        #ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -q -N "$SSHPASS"
        #ssh-copy-id ansible@$TOWER
        echo "Done"
        exit 0
        ;;
    '"Ubuntu"'|'"Debian"')
        # Update
        sudo apt update -y && sudo apt upgrade -y
        # Install Python modules
        sudo yum install -y python2 python-simplejson
        # Generate SSH ID and copy to ansible tower
        #ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -q -N "$SSHPASS"
        #ssh-copy-id ansible@$TOWER
        echo "Done"
        exit 0
        ;;
    *)
        echo "Unknown OS"
        exit 1
esac
