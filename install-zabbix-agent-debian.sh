#!/bin/bash

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

echo 'Please enter Zabbix Agent hostname :'
read ZABBIX_AGENT_HOSTNAME

echo 'Please enter Zabbix Server IP address :'
read ZABBIX_SERVER

# Debian 11
# wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4+debian11_all.deb

# Debian 12
wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian12_all.deb

# Debian 11
# dpkg -i zabbix-release_6.0-4+debian11_all.deb

# Debian 12
dpkg -i zabbix-release_6.4-1+debian12_all.deb

apt-get update
apt-get install -y sudo zabbix-agent2 zabbix-agent2-plugin-*

cat 1>/etc/zabbix/zabbix_agent2.conf << EOF 
PidFile=/var/run/zabbix/zabbix_agent2.pid
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=0
Server=${ZABBIX_SERVER}
Hostname=${ZABBIX_AGENT_HOSTNAME}
Include=/etc/zabbix/zabbix_agent2.d/*.conf
PluginSocket=/run/zabbix/agent.plugin.sock
ControlSocket=/run/zabbix/agent.sock
AllowKey=system.run[*]
EOF

cat 1>/etc/sudoers << EOF 
Defaults        env_reset
Defaults        mail_badpass
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults        use_pty
root    ALL=(ALL:ALL) ALL
zabbix ALL=(ALL) NOPASSWD:/bin/systemctl restart systemd-timesyncd.service
zabbix ALL=(ALL) NOPASSWD:/bin/systemctl restart systemd-timesyncd
%sudo   ALL=(ALL:ALL) ALL
@includedir /etc/sudoers.d
EOF

systemctl enable zabbix-agent2.service
systemctl restart zabbix-agent2.service
