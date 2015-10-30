# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/vivid64"
  config.vm.box_check_update = false
  config.vm.hostname = "ironman"
  config.vm.synced_folder ENV["USERPROFILE"] + "/dev", "/host-dev"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "dev-box-linux"
    vb.memory = 2048
    vb.cpus = 2

    vb.customize ["modifyvm", :id, "--accelerate3d", "off"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--vram", "256"]
    vb.customize ["modifyvm", :id, "--acpi", "on"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  config.vm.provision "shell", inline: <<-SHELL
    echo "Install and update basic packeges"
    sudo apt-get update --fix-missing >/dev/null
    sudo apt-get remove -y vim-tiny >/dev/null
    sudo apt-get install -y git vim curl wget unzip virtualbox-guest-* >/dev/null

    echo "Set system configuration settings"
    sudo timedatectl set-timezone Europe/Rome
    sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  SHELL

  config.vm.provision "docker" do |d|
      d.pull_images "mongo:latest"
      d.pull_images "redis:latest"
      d.pull_images "rabbitmq:latest"
      d.pull_images "mysql:latest"
  end
end
