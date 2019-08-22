# -*- mode: ruby -*-
# vi: set ft=ruby :

numberOfNodes = 2
domainname = 'rhce-training.ru'
ipspace = '192.168.13'
nodenames = 'node'
dspassword = '12345678'


$script = <<-SCRIPT
sudo yum -y update
sudo yum install -y tcpdump vim wget epel-release yum-utils device-mapper-persistent-data lvm2 net-tools bind-utils telnet
sudo cp /vagrant/lxc3.0.repo /etc/yum.repos.d/
sudo chown root:root /etc/yum.repos.d/lxc3.0.repo
#sudo systemctl stop firewalld
#sudo yum install -y debootstrap lxc lxc-templates lxc-extra libcap-devel lbcgroup
sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#sudo yum install -y docker-ce docker-ce-cli containerd.io
SCRIPT

$script_ipa = <<-SCRIPT
sudo yum -y update
sudo yum install -y tcpdump vim wget epel-release yum-utils ipa-server net-tools bind-utils telnet ipa-server-dns
SCRIPT

unless Vagrant.has_plugin?("vagrant-hostmanager")
	raise 'use first: vagrant plugin install vagrant-hostmanager'
end

Vagrant.configure("2") do |config|
	config.hostmanager.enabled = true
	config.hostmanager.manage_guest = true
	config.hostmanager.manage_host = true
	config.hostmanager.ignore_private_ip = true
	config.hostmanager.include_offline = true
	(1..numberOfNodes).each do |i|
		config.vm.define "#{nodenames}-#{i}" do |nodeconfig|
			nodeconfig.vm.box = "centos/7"
			nodeconfig.vm.hostname = "#{nodenames}-#{i}.#{domainname}"
			nodeconfig.vm.network :private_network, ip: "#{ipspace}.2#{i}"
			nodeconfig.vm.provider :virtualbox do |vb|
				vb.customize [
					"modifyvm", :id,
					"--memory", 1024,
					"--nic3", "intnet",
					"--nic4", "intnet"
				]
			nodeconfig.hostmanager.aliases = ["#{nodenames}.#{domainname}","#{nodenames}"]
			nodeconfig.vm.provision "shell", inline: $script
			end
		end
	end
	config.vm.define "ipaserver" do |ipaserver|
		ipaserver.vm.box = "centos/7"
		ipaserver.vm.hostname = "ipaserver.#{domainname}"
		ipaserver.vm.network :private_network, ip: "#{ipspace}.11"
		ipaserver.vm.provider :virtualbox do |vb|
			vb.customize [
							"modifyvm", :id,
							"--memory", 1024,
						]
		end
		ipaserver.hostmanager.aliases = ["ipaserver.#{domainname}","ipaserver"]
		ipaserver.vm.provision "shell", inline: $script_ipa
		
	end
end