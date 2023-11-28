#!/bin/bash

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

cat 1>>/etc/sysctl.conf << EOF
net.ipv6.icmp.echo_ignore_all=1
net.ipv6.conf.all.disable_ipv6=1
EOF

sysctl -p

cd

apt-get install -y git ansible python3-pymysql

git clone https://gitlab.com/adieperi/cpnv-gsi.git

ansible-galaxy collection install community.mysql
ansible-galaxy collection install community.general

ansible-playbook cpnv-gsi/ansible/playbook.yml
