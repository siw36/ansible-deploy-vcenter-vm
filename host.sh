
IP4=$(ip addr | grep -Po 'inet \K[\d.]+')
IP6=$(ip addr | grep -Po 'inet6 \K[\d.]+')
FQDN=$(hostname -f)

