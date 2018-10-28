# About
## This bash script prepares a (fresh) Linux installation for being orchestrated by Ansible
The following prerequisites are needed for Ansible:
- A system user which has the ability to exec sudo commands __without getting promted for password confirmation__
- SSH running
- Python2.6 or later

This script will make sure all of the above is setup.

# How
The following steps are taken to acomplish the above listed requirements:
- A complete system update
- Install *python2 python-simplejson openssh-server*
- Enable and start the SSH Server
- Verify that SSH is running
- Create a system user named ansible
- Set the password for the ansible user
- Add the ansible user to the sudo/wheel group
- Alter the /etc/sudoers file to allow the ansible user to exec sudo commands without getting promted for a password verification
- Print network information of the installed host

# Supported Linux systems
- RHEL 7.5
- CentOS 7
- Fedora Server 28
- Debian 9.5
- Ubuntu 18.04

*Note: This script may work for other Linux derivatives. Only the above are tested.*
