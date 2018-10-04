#!/bin/bash

set -x

# Detect the host os type
HOSTOS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

# Read password for ansible user 
read -p "Enter password for the ansible user: " ANSIBLEPASS

case $HOSTOS in
        ######################################################################################
	# HOST OS IS CENTOS/FEDORA/RHEL
	######################################################################################
    '"CentOS Linux"'|'Fedora')
        # Update
        sudo yum update -y
        # Install Python modules
        sudo yum install -y python2 python-simplejson
        # Install SELinux modules
        sudo yum install -y libselinux-python
        # Create user ansible
        sudo useradd ansible
        # Set the password
        sudo echo $ANSIBLEPASS | sudo passwd ansible --stdin
        # Add user ansible to sudo group
        sudo usermod -aG wheel ansible
        # Allow wheel users to use sudo without password
        sudo sed -i -E s/'^%wheel[ \t]ALL=\(ALL\)[ \t]ALL'/'#%wheel ALL=(ALL) ALL'/ /etc/sudoers
        sudo sed -i -E s/'^# %wheel[ \t]ALL=\(ALL\)[ \t]NOPASSWD: ALL'/'%wheel ALL=(ALL) NOPASSWD: ALL'/ /etc/sudoers
        echo "Done"
        exit 0
        ;;
        ######################################################################################
	# HOST OS IS UBUNTU
	######################################################################################
    '"Ubuntu"')
        # Check if user is root
        if [ "$EUID" -ne 0 ]
          then echo "Please run this script as root"
          exit 1
        fi
	# Update
        apt update -y && sudo apt upgrade -y
        # Install Python modules
        apt install -y python2 python-simplejson
        # Install ssh/sshd
        apt install -y openssh-server
        # Enable SSH and check if server is running
        systemctl enable ssh
        systemctl start sshd	
        SSHSTATUS=$(systemctl show -p ActiveState --value sshd)
	if [ "$SSHSTATUS" == "active" ]
	  then echo "SSH Server is not running. Please Check the shhd service"
	  exit 1
	fi
        # Create user ansible
        adduser ansible --shell /bin/bash --gecos "" --disabled-password
        # Set the password
        echo -e  "$ANSIBLEPASS\n$ANSIBLEPASS" | passwd ansible
        # Add user ansible to sudo group
        usermod -aG sudo ansible
        # Allow sudo users to use sudo without password
        sed -i -E s/'^%sudo[ \t]ALL=\(ALL:ALL\)[ \t]ALL'/'#%sudo ALL=(ALL:ALL) ALL'/ /etc/sudoers
        echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
        echo "Done"
        exit 0
        ;;
	######################################################################################
	# HOST OS IS DEBIAN
	######################################################################################
	'"Debian GNU/Linux"')
        # Check if user is root
        if [ "$EUID" -ne 0 ]
          then echo "Please run this script as root"
          exit 1
        fi
	# Update
        apt -qy update && apt -qy upgrade
        # Install Python modules
        apt -qy install python
        # Install ssh/sshd
        apt -qy install openssh-server
	# Install sudo
	apt -qy install sudo
        # Enable SSH and check if server is running
        systemctl enable ssh
        systemctl start ssh	
        SSHSTATUS=$(systemctl show -p ActiveState --value ssh)
	if [ "$SSHSTATUS" != "active" ]
	  then echo "SSH Server is not running. Please Check the shhd service"
	  exit 1
	fi
        # Create user ansible
        adduser ansible --shell /bin/bash --gecos "" --disabled-password
        # Set the password
        echo -e  "$ANSIBLEPASS\n$ANSIBLEPASS" | passwd ansible
        # Add user ansible to sudo group
        usermod -aG sudo ansible
        # Allow sudo users to use sudo without password
        sed -i -E s/'^%sudo[ \t]ALL=\(ALL:ALL\)[ \t]ALL'/'#%sudo ALL=(ALL:ALL) ALL'/ /etc/sudoers
        echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
        echo "Done"
        exit 0
        ;;
    *)
        echo "Unknown OS"
        exit 1
esac
