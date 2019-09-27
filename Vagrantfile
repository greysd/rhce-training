# -*- mode: ruby -*-
# vi: set ft=ruby :

NUMBEROFNODES = 2
DOMAINNAME = 'rhce-training.ru'
IPSPACE = '192.168.13'
NODENAMES = 'node'
DSPASSWORD = '1qaZXsw2'
ADMINPASSWORD = '1qaZXsw2'
REALMNAME=DOMAINNAME.upcase
USERPASS = '1qaZXsw2'

$script_common = <<-SCRIPT
#do not update server
#sudo yum -y update
sudo yum install -y tcpdump vim wget yum-utils net-tools bind-utils telnet lsof
sudo systemctl start firewalld
/bin/bash /vagrant/sshkey.sh
SCRIPT

$script = <<-SCRIPT
sudo sed -i "/127.0.0.1.*#{NODENAMES}.*/d" /etc/hosts
#sudo cp /vagrant/lxc3.0.repo /etc/yum.repos.d/
#sudo chown root:root /etc/yum.repos.d/lxc3.0.repo
#sudo systemctl stop firewalld
#sudo yum install -y debootstrap lxc lxc-templates lxc-extra libcap-devel lbcgroup
#sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine krb5-workstation pam_krb5
#sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#sudo yum install -y docker-ce docker-ce-cli containerd.io
SCRIPT

$script_ipa = <<-SCRIPT
#echo "change selinux mode in confi file"
#sudo sed -i "s/SELINUX=disabled/SELINUX=enforcing/" /etc/selinux/config
sudo yum install -y krb5-server krb5-workstation pam_krb5 setroubleshoot-server
echo "=== hosts"
sudo sed -i "/127.0.0.1.*krbserver/d" /etc/hosts
echo "=== kdc.conf change REALMNAME"
sudo sed -i "s/EXAMPLE.COM/#{REALMNAME}/" /var/kerberos/krb5kdc/kdc.conf
echo "=== kdc.conf delete all comment signs"
sudo sed -i "s/#//" /var/kerberos/krb5kdc/kdc.conf
echo "=== kdc.conf remove last }"
sudo sed -i "s/}//" /var/kerberos/krb5kdc/kdc.conf
echo "=== add default principal flag"
sudo echo '  default_principal_flags = +preauth' >> /var/kerberos/krb5kdc/kdc.conf
echo "=== add last }"
sudo echo "}" >> /var/kerberos/krb5kdc/kdc.conf
echo "=== krb5.conf first line"
sudo sed -i "1d" /etc/krb5.conf 
echo "=== krb5.conf remove comment sign"
sudo sed -i 's/#//' /etc/krb5.conf
echo "=== krb5.conf remove comment"
sudo sed -i 's/# default/ default/' /etc/krb5.conf
echo "=== krb5.conf change domain name"
sudo sed -i "s/example.com/#{DOMAINNAME}/" /etc/krb5.conf
echo "=== krb5.conf change realmname"
sudo sed -i "s/EXAMPLE.COM/#{REALMNAME}/" /etc/krb5.conf
echo "=== krb5.conf change server name"
sudo sed -i "s/kerberos./krbserver./" /etc/krb5.conf 
echo "=== kadm5.acl"
sudo sed -i "s/EXAMPLE.COM/#{REALMNAME}/"  /var/kerberos/krb5kdc/kadm5.acl
echo "=== sshd_config"
sudo sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/" /etc/ssh/sshd_config
echo "=== create kdb5_util "
sudo kdb5_util create -s -r #{REALMNAME} -P #{DSPASSWORD}
echo "start services"
sudo systemctl start krb5kdc kadmin
sudo systemctl enable krb5kdc kadmin
echo "=== add user user01"
echo "=== add user user01"
sudo useradd user01
echo "create admin principal"
sudo sh -c "echo ank -pw 1qaZXsw2 root/admin |kadmin.local"
echo "create user01 principal"
sudo sh -c "echo ank -pw 1qaZXsw2 user01 |kadmin.local"
echo "create host/krbserver principal"
sudo sh -c "echo ank -randkey host/krbserver.rhce-training.ru | kadmin.local"
echo "=== save ktfile"
sudo sh -c "kadmin.local ktadd host/krbserver.rhce-training.ru"
echo "=== change sshd config" 
sudo sed -i "s/#GSSAPIAuthentication yes/GSSAPIAuthentication yes/" /etc/ssh/sshd_config
echo "=== reload sshd"
sudo systemctl reload sshd
echo "== authconfig"
sudo authconfig --enablekrb5 --update
sudo firewall-cmd --add-port=749/tcp --permanent
sudo firewall-cmd --add-service=kerberos --permanent
sudo firewall-cmd --add-service=smtp --permanent
sudo firewall-cmd --reload
echo "run mailserver install"
sudo /vagrant/mailserver.sh
SCRIPT

$script_trigger = <<-SCRIPT
vagrant ssh master -- cp "/vagrant/.vagrant/machines/krbserver/virtualbox/private_key" ~/.ssh/id_rsa
SCRIPT

unless Vagrant.has_plugin?("vagrant-hostmanager")
	raise 'use first: vagrant plugin install vagrant-hostmanager'
end

Vagrant.configure("2") do |config|
	config.hostmanager.enabled = true
	config.hostmanager.manage_guest = true
	config.hostmanager.manage_host = true
	config.hostmanager.ignore_private_ip = false
	config.hostmanager.include_offline = true
	(1..NUMBEROFNODES).each do |i|
		config.vm.define "#{NODENAMES}-#{i}" do |nodeconfig|
			nodeconfig.vm.box = "rafacas/centos70-plain"
			nodeconfig.vm.hostname = "#{NODENAMES}-#{i}.#{DOMAINNAME}"
			nodeconfig.vm.network :private_network, ip: "#{IPSPACE}.2#{i}"
			nodeconfig.vm.provision "shell", inline: $script_common
			nodeconfig.vm.provider :virtualbox do |vb|
				vb.customize [
					"modifyvm", :id,
					"--memory", 1024,
					"--nic3", "intnet",
					"--nic4", "intnet"
				]
			end
			nodeconfig.vm.provision "shell", inline: $script
		end
	end
	config.vm.define "krbserver" do |krbserver|
		krbserver.vm.box = "rafacas/centos70-plain"
		krbserver.vm.hostname = "krbserver.#{DOMAINNAME}"
		krbserver.vm.network :private_network, ip: "#{IPSPACE}.11"
		krbserver.vm.provision "shell", inline: $script_common
		krbserver.vm.provider :virtualbox do |vb|
			vb.customize [
							"modifyvm", :id,
							"--memory", 1024,
						]
		end
		krbserver.vm.provision "shell", inline: $script_ipa
		
	end
end