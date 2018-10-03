!/bin/bash

# Detect the host os type
$HOSTOS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

case $HOSTOS in
    '"CentOS Linux"'|'Fedora')
        # Install Python modules
        sudo yum install -y python2 python-simplejson
        # Install SELinux modules
        sudo yum install -y libselinux-python
        ;;
    '"Ubuntu"'|'"Debian"')
        # Install Python modules
        sudo yum install -y python2 python-simplejson
        ;;
    *)
        echo "Unknown OS"
        exit 1
esac
