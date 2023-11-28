#!/bin/bash

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

ZABBIX_SERVER='10.0.5.10'
ZABBIX_AGENT_HOSTNAME='debian'

cat 1>>/etc/sysctl.conf << EOF
net.ipv6.icmp.echo_ignore_all=1
net.ipv6.conf.all.disable_ipv6=1
EOF

sysctl -p

wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4+debian11_all.deb
dpkg -i zabbix-release_6.0-4+debian11_all.deb
apt-get update
apt-get install -y zabbix-agent2 zabbix-agent2-plugin-*
systemctl enable zabbix-agent2
sed -i "s/Server=127.0.0.1/Server=${ZABBIX_SERVER}/" /etc/zabbix/zabbix_agent2.conf
#sed -i "s/ServerActive=127.0.0.1/ServerActive=${ZABBIX_SERVER}/" /etc/zabbix/zabbix_agent2.conf
sed -i "s/Hostname=Zabbix server/Hostname=${ZABBIX_AGENT_HOSTNAME}/" /etc/zabbix/zabbix_agent2.conf
sed -i '458 s/^/AllowKey=system.run[*]/' /etc/zabbix/zabbix_agent2.conf
sed -i '470 s/^/DenyKey=system.run[*]/' /etc/zabbix/zabbix_agent2.conf
echo 'zabbix ALL=(ALL) NOPASSWD:/bin/systemctl restart apache2' 1>>/etc/sudoers
systemctl restart zabbix-agent2.service
