#!/bin/bash

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

cd

apt-get install -y git ansible python3-pymysql

git clone https://gitlab.com/adieperi/cpnv-gsi.git

ansible-galaxy collection install community.mysql
ansible-galaxy collection install community.general

ansible-playbook cpnv-gsi/ansible/playbook.yml

sed -i 's/^Listen 80$/Listen 8080/g' /etc/apache2/ports.conf
sed -i 's/:80>$/:8080>/g' /etc/apache2/sites-available/000-default.conf

systemctl restart apache2.service
