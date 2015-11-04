# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/vivid64"
  config.vm.box_check_update = false
  config.vm.hostname = "ironman"
  config.vm.synced_folder ENV["USERPROFILE"] + "/dev", "/mnt/host-dev"

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

  config.vm.provision "shell", inline: <<-SHELL.gsub(/^ +/, '')
    echo "Install and update basic packeges"
    sudo apt-get update --fix-missing >/dev/null 2>&1
    sudo apt-get remove -y vim-tiny >/dev/null 2>&1
    sudo apt-get install -y git vim curl wget whois unzip virtualbox-guest-* >/dev/null 2>&1

    echo "Configure system settings"
    sudo timedatectl set-timezone Europe/Rome
    sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    echo "Create custom user"
    if ! id -u matteo >/dev/null 2>&1; then
        sudo useradd --create-home \
                     --groups sudo \
                     --comment "Matteo Baglini" \
                     --password ctM0SBzcd0pi. \
                     --shell /bin/bash \
                     matteo
    fi

    echo "Install the latest Node stable version using NVM"
    sudo -iu matteo <<HEREDOC
      if [ ! -d ~/.nvm ]; then
          wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh \
            | bash 2>&1
      fi
      source ~/.nvm/nvm.sh
      nvm install stable 2>/dev/null
      nvm alias default stable
    HEREDOC

    echo "That's all, rock on!"
  SHELL

  config.vm.provision "docker" do |d|
      d.pull_images "mongo:3.0"
      d.pull_images "redis:3.0"
      d.pull_images "rabbitmq:3.5-management"
      d.pull_images "mysql:5.7"
  end
end
