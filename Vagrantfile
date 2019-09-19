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
sudo yum -y update
sudo yum install -y tcpdump vim wget epel-release yum-utils net-tools bind-utils telnet lsof
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
sudo yum install -y krb5-server krb5-workstation pam_krb5
sudo sed -i "/127.0.0.1.*krbserver/d" /etc/hosts
sudo sed -i "s/EXAMPLE.COM/#{REALMNAME}/; s/#//; s/}/default_principal_flags = +preauth\n}/" /var/kerberos/krb5kdc/kdc.conf
sudo sed -i "1d; s/#//; s/# default/ default/; s/\(\.\?\)example.com/\1#{DOMAINNAME}/; s/EXAMPLE.COM/#{REALMNAME}/; s/kerberos./krbserver./" /etc/krb5.conf 
sudo sed -i "s/EXAMPLE.COM/#{REALMNAME}/"  /var/kerberos/krb5kdc/kadm5.acl
sudo sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/" /etc/ssh/sshd_config
sudo kdb5_util create -s -r #{REALMNAME} -P #{DSPASSWORD}
sudo systemctl start krb5kdc kadmin
sudo systemctl enable krb5kdc kadmin
sudo useradd user01
sudo sh -c "echo ank -pw 1qaZXsw2 root/admin |kadmin.local"
sudo sh -c "echo ank -pw 1qaZXsw2 user01 |kadmin.local"
sudo sh -c "echo ank -randkey host/krbserver.rhce-training.ru | kadmin.local"
sudo sh -c "kadmin.local ktadd host/krbserver.rhce-training.ru"
sudo sed -i "s/#GSSAPIAuthentication yes/GSSAPIAuthentication yes/"
sudo systemctl reload sshd
sudo authconfig --enablekrb5 --update
sudo firewall-cmd --add-service=kadmin --permanent
sudo firewall-cmd --add-service=kerberos --permanent
sudo firewall-cmd --add-service=smtp --permanent
sudo firewall-cmd --reload
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
			nodeconfig.vm.box = "centos/7"
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
		krbserver.vm.box = "centos/7"
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