# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<-SHELL
echo "Install and update basic packeges"
sudo add-apt-repository ppa:gnome3-team/gnome3
sudo apt-get update -q -y 
sudo apt-get install -q -y git curl wget whois unzip tree \
                            linux-kernel-headers build-essential \
                            xorg xclip x11-utils autocutsel \
                            gdm gnome-terminal vim-gnome \
                            unclutter >/dev/null

echo "Configure system settings"
sudo timedatectl set-timezone Europe/Rome
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "Install Google Chrome"
if [ ! -f /etc/apt/sources.list.d/google.list ]; then
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list
    sudo apt-get update
    sudo apt-get install -q -y google-chrome-stable
fi

echo "Create custom user"
if ! id -u matteo &>/dev/null; then
    sudo useradd --create-home \
                    --gid users \
                    --groups sudo \
                    --comment "Matteo Baglini" \
                    --password ctM0SBzcd0pi. \
                    --shell /bin/bash \
                    matteo
    sudo chown -R matteo:users /home/matteo
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
        wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh \
            | bash
    fi
    source ~/.nvm/nvm.sh
    nvm install node
    nvm alias default node
HEREDOC

echo "Install Java"
sudo -iu matteo <<HEREDOC
    if ! javac -version &>/dev/null; then
        sudo add-apt-repository ppa:webupd8team/java
        sudo apt-get update -q -y 
        echo oracle-java8-set-default shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
        sudo apt-get install -q -y oracle-java8-set-default
    fi
HEREDOC

echo "Install Scala and SBT"
sudo -iu matteo <<HEREDOC
    if ! scala -version &>/dev/null; then
        wget -q http://www.scala-lang.org/files/archive/scala-2.12.2.deb
        sudo dpkg -i scala-2.12.2.deb
        wget -q http://dl.bintray.com/sbt/debian/sbt-0.13.15.deb
        sudo dpkg -i sbt-0.13.15.deb
        sudo apt-get -q -y update
        sudo apt-get -q -y install scala sbt
    fi
HEREDOC

echo "Install Docker and tools"
sudo -i <<HEREDOC
    if ! docker version &>/dev/null; then
        wget -qO- https://get.docker.com/ | bash
        sudo usermod -aG docker matteo
    fi
    if ! docker-compose --version &>/dev/null; then
        curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` \
                > /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
HEREDOC

echo "Remember to reboot the box"
echo "That's all, rock on!"
SHELL

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

  config.vm.provision "shell", inline: $script
end