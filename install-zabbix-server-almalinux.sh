#!/bin/bash

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

echo "max_parallel_downloads=10" 1>>/etc/dnf/dnf.conf
dnf update -y
dnf install -y vim epel-release net-tools
dnf install -y htop
systemctl disable --now firewalld

cat 1>>/etc/sysctl.conf << EOF
net.ipv6.conf.all.disable_ipv6=1
EOF

sysctl -p

rpm -Uvh https://repo.zabbix.com/zabbix/6.0/rhel/8/x86_64/zabbix-release-6.0-4.el8.noarch.rpm

dnf clean all

curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup

bash mariadb_repo_setup --mariadb-server-version=10.6

dnf install -y MariaDB-server MariaDB-client

systemctl enable --now mariadb

dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-nginx-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent

echo 'create database zabbix character set utf8mb4 collate utf8mb4_bin;' | mysql
echo "create user zabbix@localhost identified by 'password';" | mysql
echo 'grant all privileges on zabbix.* to zabbix@localhost;' | mysql
echo 'set global log_bin_trust_function_creators = 1;' | mysql

zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -ppassword zabbix

echo 'set global log_bin_trust_function_creators = 0;' | mysql

sed -i 's/# DBPassword=/DBPassword=password/g' /etc/zabbix/zabbix_server.conf
sed -i 's/#        listen          8080/        listen          8080/g' /etc/nginx/conf.d/zabbix.conf
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
#sed -i '38,57 s/^/#/' /etc/nginx/nginx.conf

systemctl enable zabbix-server zabbix-agent nginx php-fpm

reboot;exit
