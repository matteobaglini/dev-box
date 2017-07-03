# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/yakkety64"
  config.vm.box_check_update = false
  config.vm.hostname = "ironman"
  # config.vm.synced_folder ENV["USERPROFILE"] + "/dev", "/mnt/host-dev"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "dev-box-linux"
    vb.memory = 4096
    vb.cpus = 2
    vb.gui = true

    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--vram", "256"]
    vb.customize ["modifyvm", :id, "--acpi", "on"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  config.vm.provision "shell", path: "provision.sh"
end