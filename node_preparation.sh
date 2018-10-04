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
	'"CentOS Linux"'|'Fedora'|'"Red Hat Enterprise Linux Server"')
	# Update
	printf "***Update the System\n"
	sudo yum -y -q update
	printf ">>>Update finished\n\n"
	# Install Python modules
	printf "***Install packages: python2 python-simplejson\n"
	sudo yum -y -q install python2 python-simplejson
	printf ">>>Installation finished\n\n"
	# Install SELinux modules
	printf "***Install packages: libselinux-python\n"
	sudo yum -y -q install libselinux-python
	printf ">>>Installation finished\n\n"
	# Install SSH server
	printf "***Install packages: openssh-server\n"
	sudo yum -y -q install openssh-server
	printf ">>>Installation finished\n\n"
	# Enable SSH and check if server is running
	sudo systemctl enable sshd
	sudo systemctl start sshd	
	SSHSTATUS=$(sudo systemctl show -p ActiveState sshd)
	if [ "$SSHSTATUS" != "ActiveState=active" ]
		then echo "SSH Server is not running. Please Check the shhd service"
		exit 1
	fi
	# Create user ansible
	printf "***Create user: ansible\n"
	sudo useradd ansible
	printf ">>>Creation finished\n\n"
	# Set the password
	printf "***Set password for user ansible\n"
	sudo echo $ANSIBLEPASS | sudo passwd ansible --stdin
	printf ">>>Password set\n\n"
	# Add user ansible to sudo group
	printf "***Add user ansible to wheel group\n"
	sudo usermod -aG wheel ansible
	printf ">>>Group set\n\n"
	# Allow wheel users to use sudo without password
	printf "*Altering sudoers file to allow the wheel group to use sudo without password confirtmation\n"
	sudo sed -i -E s/'^%wheel[ \t]ALL=\(ALL\)[ \t]ALL'/'#%wheel ALL=(ALL) ALL'/ /etc/sudoers
	sudo sed -i -E s/'^# %wheel[ \t]ALL=\(ALL\)[ \t]NOPASSWD: ALL'/'%wheel ALL=(ALL) NOPASSWD: ALL'/ /etc/sudoers
	printf ">>>Altering sudoers finished\n\n"
	printf "Done\n"
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
	apt -y -q update && apt -y -q upgrade
	# Install Python modules
	apt -y -q install python
	# Install ssh/sshd
	apt -y -q install openssh-server
	# Install sudo
	apt -y -q install sudo
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
