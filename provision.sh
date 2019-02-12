#!/bin/bash

echo ">>>> Configure system settings"
sudo timedatectl set-timezone Europe/Rome
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo ">>>> Create custom user"
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

echo ">>>> Update packages"
sudo apt -q -y update

echo ">>>> Install basic packeges"
sudo apt -q -y install \
    build-essential autoconf linux-kernel-headers \
    git curl wget tree whois unzip dkms gpg htop jq

wget -q https://github.com/sharkdp/bat/releases/download/v0.10.0/bat_0.10.0_amd64.deb


echo ">>>> Install GUI packages"
sudo apt install -q -y \
    xorg xclip x11-utils autocutsel unclutter \
    gdm3 gnome-session gnome-terminal

echo ">>>> Install VIM 8"
sudo apt remove -q -y vim-*
sudo add-apt-repository ppa:jonathonf/vim
sudo apt update -q -y
sudo apt install -q -y vim-gtk3

echo ">>>> Install utilities"
sudo -i <<HEREDOC
    if ! type bat > /dev/null; then
        cd /tmp
        wget -q https://github.com/sharkdp/bat/releases/download/v0.10.0/bat_0.10.0_amd64.deb
        sudo dpkg -i bat_0.10.0_amd64.deb
    fi
    if ! type fd > /dev/null; then
        cd /tmp
        wget -q https://github.com/sharkdp/fd/releases/download/v7.2.0/fd_7.2.0_amd64.deb
        sudo dpkg -i fd_7.2.0_amd64.deb
    fi
HEREDOC

echo ">>>> Install Google Chrome"
sudo -iu matteo <<HEREDOC
    if [ ! -f /etc/apt/sources.list.d/google.list ]; then
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
        sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
        sudo apt-get update -q -y
        sudo apt-get install -q -y google-chrome-stable
    fi
HEREDOC

echo ">>>> Install dotfiles"
sudo -iu matteo <<HEREDOC
    if [ ! -d ~/dotfiles ]; then
        git clone https://github.com/matteobaglini/dotfiles ~/dotfiles
        cd ~/dotfiles
        bash install.sh
    fi
HEREDOC

echo ">>>> Install asdf & plugins"
sudo -iu matteo <<HEREDOC
    if [ ! -d ~/.asdf ]; then
        git clone https://github.com/asdf-vm/asdf ~/.asdf --branch v0.5.0
        echo -e '\n. ~/.asdf/asdf.sh' >> ~/.bashrc
        echo -e '\n. ~/.asdf/completions/asdf.bash' >> ~/.bashrc

        ~/.asdf/bin/asdf plugin-add dotnet-core https://github.com/emersonsoares/asdf-dotnet-core
        ~/.asdf/bin/asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs
        bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
        ~/.asdf/bin/asdf plugin-add java https://github.com/skotchpine/asdf-java
        ~/.asdf/bin/asdf plugin-add maven https://github.com/skotchpine/asdf-maven
        ~/.asdf/bin/asdf plugin-add scala https://github.com/mtatheonly/asdf-scala
        ~/.asdf/bin/asdf plugin-add sbt https://github.com/gabrielelana/asdf-sbt
    fi
HEREDOC

echo ">>>> Install Haskell & Stack"
wget -qO- https://get.haskellstack.org/ | sh

echo ">>>> Install Docker & tools"
sudo -i <<HEREDOC
    if ! docker version &>/dev/null; then
        wget -qO- https://get.docker.com/ | bash
        sudo usermod -aG docker matteo
    fi
    if ! docker-compose --version &>/dev/null; then
        curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` \
                > /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
HEREDOC

echo ">>>> Install Terraform"
sudo -i <<HEREDOC
    if ! type terraform > /dev/null; then
        cd /tmp
        wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
        unzip terraform_0.11.11_linux_amd64.zip
        sudo mv terraform /usr/local/bin/
    fi
HEREDOC

echo ">>>> That's all, rock on!"
