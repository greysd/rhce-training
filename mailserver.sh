#!/bin/bash

adduser --system --home /var/archive/mail/ --no-create-home mailarchive
rpm -qa | grep -qw postfix || yum install -y postfix
mkdir -p /var/archive/mail/{tmp,cur,new}
chown -R nobody:nobody /var/archive
postconf -e always_bcc=mailarchive@localhost
echo "mailarchive: /var/archive/mail/" >> /etc/aliases
newaliases
grep "^inet_interfaces = all" /etc/postfix/main.cf || sed -i '/inet_interfaces/ s/localhost/all/' /etc/postfix/main.cf
systemctl restart postfix
#semanage fcontext -a -t user_home_dir_t "/var/archive(/.*)?"
#restorecon -R /var/archive
