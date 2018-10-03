#!/bin/bash

set -x

# Detect the host os type
HOSTOS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

# Read password for ansible user 
read -p "Enter password for the ansible user: " ANSIBLEPASS

case $HOSTOS in
    '"CentOS Linux"'|'Fedora')
        # Create user ansible
        sudo useradd ansible
        # Set the password
        sudo echo $ANSIBLEPASS | sudo passwd ansible --stdin
        # Add user ansible to sudo group
        sudo usermod -aG wheel ansible
        # Allow wheel users to use sudo without password
        sudo sed -i -E s/'^%wheel[ \t]ALL=\(ALL\)[ \t]ALL'/'#%wheel ALL=(ALL) ALL'/ /etc/sudoers
        sudo sed -i -E s/'^# %wheel[ \t]ALL=\(ALL\)[ \t]NOPASSWD: ALL'/'%wheel ALL=(ALL) NOPASSWD: ALL'/ /etc/sudoers
        # Update
        sudo yum update -y
        # Install Python modules
        sudo yum install -y python2 python-simplejson
        # Install SELinux modules
        sudo yum install -y libselinux-python
        echo "Done"
        exit 0
        ;;
    '"Ubuntu"'|'"Debian"')
        # Create user ansible
        sudo useradd ansible
        # Set the password
        sudo echo $ANSIBLEPASS | sudo passwd ansible --stdin
        # Add user ansible to sudo group
        sudo usermod -aG wheel ansible
        # Allow wheel users to use sudo without password
        sudo sed -i -E s/'^%sudo[ \t]ALL=\(ALL:ALL\)[ \t]ALL'/'#%sudo ALL=(ALL:ALL) ALL'/ /etc/sudoers
        echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
        # Update
        sudo apt update -y && sudo apt upgrade -y
        # Install Python modules
        sudo yum install -y python2 python-simplejson
        echo "Done"
        exit 0
        ;;
    *)
        echo "Unknown OS"
        exit 1
esac
