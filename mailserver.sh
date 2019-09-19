#!/bin/bash

adduser --system --home /var/archive/mail/ --no-create-home mailarchive
rpm -qa | grep -qw postfix || yum install -y postfix
mkdir -p /var/archive/mail/{tmp,cur,new}
chown -R nobody:nobody /var/archive
postconf -e always_bcc=mailarchive@localhost
echo "mailarchive: /var/archive/mail/" >> /etc/aliases
newaliases
systemctl restart postfix
semanage fcontext -a -t user_home_dir_t "/var/archive(/.*)?"
restorecon -R /var/archive
semanage boolean -a http