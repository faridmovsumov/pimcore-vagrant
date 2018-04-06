Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  config.vm.network "forwarded_port", guest: 80, host: 8001

  config.vm.network "private_network", ip: "192.168.33.56"

  # config.vm.synced_folder "./", "/vagrant", create: true, group: "www-data", owner: "www-data"

  config.vm.synced_folder "./Projects", "/var/www", nfs: true, create: true

  config.vm.provision "shell" do |s|
    s.path = ".provision/bootstrap.sh"
  end

  config.vm.provider "virtualbox" do |vb|
     vb.memory = "6144"
     vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
     vb.customize ["modifyvm", :id, "--uartmode1", "disconnected" ]
  end

end