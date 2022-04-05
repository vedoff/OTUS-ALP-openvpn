# -*- mode: ruby -*-
# vim: set ft=ruby :
home = ENV['HOME']
ENV["LC_ALL"] = "en_US.UTF-8"

Vagrant.configure(2) do |config|
  # ========================================= VPN-Server ========================================
    config.vm.define "vpnserver" do |server|
    # имя виртуальной машины
    server.vm.box = 'vedoff/centos-7-5'
    #server.vm.box_version = 'v1230.1'
    server.vm.provider "virtualbox" do |vb|
      vb.name = "vpnserver"
    end
    # hostname виртуальной машины
    server.vm.hostname = "vpnserver"
    # настройки сети
    server.vm.network "private_network", ip: "10.10.11.1", adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "vpn-net"
    server.vm.network "private_network", ip: "192.168.80.11", adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: "office-mng"
    server.vm.network "private_network", ip: "192.168.56.60",adapter: 4, netmask: "255.255.255.0"
    server.vm.synced_folder ".", "/vagrant",  
          type: "rsync",
          rsync_auto: "true",
          rsync_exclude: [".git/",".vagrant/",".gitignore","Vagrantfile"]
          #server.vm.provision "shell", path: "provision/prepare-iroute.sh"
  end

  # ========================================= VPN-Client =====================================
    config.vm.define "vpnclient" do |client|
    # имя виртуальной машины
    client.vm.box = 'vedoff/centos-7-5'
    #client.vm.box_version = 'v1230.1' 
    client.vm.provider "virtualbox" do |vbc|
      vbc.name = "vpnclient"
    end
    # hostname виртуальной машины
    client.vm.hostname = "vpnclient"
    # настройки сети
    client.vm.network "private_network", ip: "10.10.11.2", adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "vpn-net"
    client.vm.network "private_network", ip: "192.168.70.11", adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: "office-net"
    client.vm.network "private_network", ip: "192.168.56.61",adapter: 4, netmask: "255.255.255.0"
    client.vm.synced_folder ".", "/vagrant",  
          type: "rsync",
          rsync_auto: "true",
          rsync_exclude: [".git/",".vagrant/",".gitignore","Vagrantfile"]
          #client.vm.provision "shell", path: "provision/prepare-croute.sh"

  end

# =========================================== Office-user ===================================================
    config.vm.define "office-user" do |office|
    # имя виртуальной машины
    office.vm.box = 'centos/7'
    office.vm.box_version = '1804.02'
    office.vm.provider "virtualbox" do |vb|
      vb.name = "office-user"
    end
    # hostname виртуальной машины
    office.vm.hostname = "office-user"
    # настройки сети
    office.vm.network "private_network", ip: "192.168.70.10", adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "office-net"
    office.vm.network "private_network", ip: "192.168.56.50",adapter: 3, netmask: "255.255.255.0"
    office.vm.synced_folder ".", "/vagrant",  
          type: "rsync",
          rsync_auto: "true",
          rsync_exclude: [".git/",".vagrant/",".gitignore","Vagrantfile"]
          office.vm.provision "shell", path: "provision/add-default-office.sh"
    end
# =========================================== Office-mng ===================================================
config.vm.define "office-mng" do |mng|
  # имя виртуальной машины
  mng.vm.box = 'centos/7'
  mng.vm.box_version = '1804.02'
  mng.vm.provider "virtualbox" do |vb|
    vb.name = "office-mng"
  end
  # hostname виртуальной машины
  mng.vm.hostname = "office-mng"
  # настройки сети
  mng.vm.network "private_network", ip: "192.168.80.10", adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "office-mng"
  mng.vm.network "private_network", ip: "192.168.56.51",adapter: 3, netmask: "255.255.255.0"
  mng.vm.synced_folder ".", "/vagrant",  
        type: "rsync",
        rsync_auto: "true",
        rsync_exclude: [".git/",".vagrant/",".gitignore","Vagrantfile"]
        mng.vm.provision "shell", path: "provision/add-default-mng.sh"
  end
  # ssh-pub add in server
    config.vm.provision "shell", inline: <<-SHELL
    cat /vagrant/provision/vagrant-key.pub >> /home/vagrant/.ssh/authorized_keys
    SHELL
end