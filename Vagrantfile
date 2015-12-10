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
    vb.gui = true

    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--vram", "256"]
    vb.customize ["modifyvm", :id, "--acpi", "on"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  config.vm.provision "shell", inline: <<-SHELL.gsub(/^ +/, '')
    echo "Install and update basic packeges"
    sudo apt-get update --fix-missing >/dev/null
    sudo apt-get install -y git vim curl wget whois unzip xclip >/dev/null
    sudo apt-get install xorg gnome-core gnome-system-tools gnome-app-install >/dev/null

    echo "Configure system settings"
    sudo timedatectl set-timezone Europe/Rome
    sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    echo "Create custom user"
    if ! id -u matteo &>/dev/null; then
        sudo useradd --create-home \
                     --groups sudo \
                     --comment "Matteo Baglini" \
                     --password ctM0SBzcd0pi. \
                     --shell /bin/bash \
                     matteo
        sudo touch /home/matteo/.hushlogin
    fi

    echo "Install dotfiles"
    sudo -iu matteo <<HEREDOC
      if [ ! -d ~/dotfiles ]; then
        git clone --depth 1 \
            https://github.com/matteobaglini/dotfiles.git \
            ~/dotfiles
      fi
      cd ~/dotfiles
      bash install.sh
    HEREDOC

    echo "Install the latest Node version using NVM"
    sudo -iu matteo <<HEREDOC
      if [ ! -d ~/.nvm ]; then
          wget -qO- \
           https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh \
           | bash
      fi
      source ~/.nvm/nvm.sh
      nvm install node
      nvm alias default node
    HEREDOC

    echo "Install Docker"
    if ! docker version &>/dev/null; then
        wget -qO- https://get.docker.com/ | bash
        sudo usermod -aG docker matteo
    fi

    echo "That's all, rock on!"
  SHELL
end
