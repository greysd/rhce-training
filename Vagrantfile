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
sudo cp /vagrant/id_rsa* /home/vagrant/.ssh/
chown vagrant:vagrant /home/vagrant/.ssh/id_rsa*
chmod 600 /home/vagrant/.ssh/id_rsa
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
SCRIPT

$script = <<-SCRIPT
sudo sed -i "/127.0.0.1.*#{NODENAMES}.*/d" /etc/hosts
sudo cp /vagrant/lxc3.0.repo /etc/yum.repos.d/
sudo chown root:root /etc/yum.repos.d/lxc3.0.repo
#sudo systemctl stop firewalld
#sudo yum install -y debootstrap lxc lxc-templates lxc-extra libcap-devel lbcgroup
sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine krb5-workstation pam_krb5
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#sudo yum install -y docker-ce docker-ce-cli containerd.io
SCRIPT

$script_ipa = <<-SCRIPT
sudo yum install -y ipa-server ipa-server-dns
sudo sed -i '/127.0.0.1.*ipaserver/d' /etc/hosts
sudo firewall-cmd --add-service=freeipa-ldap --permanent
sudo firewall-cmd --add-service=freeipa-ldaps --permanent
sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --reload
ipa-server-install --ds-password="#{DSPASSWORD}" \
--setup-dns \
--admin-password="#{ADMINPASSWORD}" \
--ip-address="#{IPSPACE}.11" \
--domain="#{DOMAINNAME}" \
--realm="#{REALMNAME}" \
--hostname="ipaserver.#{DOMAINNAME}" \
--mkhomedir \
--auto-reverse \
--auto-forwarders \
--no-dnssec-validation \
--no-ntp \
--quiet \
--unattended

echo '1qaZXsw2' | kinit admin
echo "1qaZXsw2" | ipa user-add --first="Test" --last="User" --cn="Test User" --password
SCRIPT

$script_trigger = <<-SCRIPT
vagrant ssh master -- cp "/vagrant/.vagrant/machines/ipaserver/virtualbox/private_key" ~/.ssh/id_rsa
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
	config.vm.define "ipaserver" do |ipaserver|
		ipaserver.vm.box = "centos/7"
		ipaserver.vm.hostname = "ipaserver.#{DOMAINNAME}"
		ipaserver.vm.network :private_network, ip: "#{IPSPACE}.11"
		ipaserver.vm.provision "shell", inline: $script_common
		ipaserver.vm.provider :virtualbox do |vb|
			vb.customize [
							"modifyvm", :id,
							"--memory", 1024,
						]
		end
		ipaserver.vm.provision "shell", inline: $script_ipa
		
	end
end