# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
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

  config.vm.provision "shell", inline: <<-SHELL.gsub(/^ +/, '')
    echo "Install and update basic packeges"
	sudo add-apt-repository ppa:gnome3-team/gnome3
    sudo aptitude -q -y update
    sudo aptitude -q -y dist-upgrade
	sudo aptitude -q -y install git curl wget whois unzip tree \
								linux-kernel-headers build-essential \
								xorg xclip x11-utils autocutsel \
								gdm gnome-terminal vim-gnome \
								unclutter >/dev/null

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
          wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh \
                | bash
      fi
      source ~/.nvm/nvm.sh
      nvm install node
      nvm alias default node
    HEREDOC

    echo "Install Docker and tools"
    sudo -i <<HEREDOC
        if ! docker version &>/dev/null; then
            wget -qO- https://get.docker.com/ | bash
            sudo usermod -aG docker matteo
        fi
        if ! docker-compose --version &>/dev/null; then
            curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` \
                    > /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
        fi
    HEREDOC

    if ! sudo service gdm status | grep active; then
      sudo service gdm start
    fi

    echo "That's all, rock on!"
  SHELL
end
