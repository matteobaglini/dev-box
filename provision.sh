#!/bin/bash

echo ">>>> Install basic packeges and GUI"
sudo apt-get update -q -y
sudo apt-get install -q -y linux-kernel-headers build-essential \
                            git curl wget whois unzip tree \
                            xorg xclip x11-utils autocutsel unclutter \
                            virtualbox-guest-x11 dkms virtualbox-guest-dkms \
                            libglib2.0-bin gnome-terminal gdm3 vim-gnome

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

echo ">>>> Install Vim 8"
sudo -i <<HEREDOC
    if ! vim -h | grep 8 &>/dev/null; then
        sudo apt-get remove -q -y --purge vim vim-*
        sudo add-apt-repository ppa:pi-rho/dev
        sudo apt-get update -q -y
        sudo apt-get install -q -y vim-gnome
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
        wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
    fi
    source ~/.nvm/nvm.sh
    if ! node -v &>/dev/null; then
        nvm install node
        nvm alias default node
    fi
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

echo "Install .NET Core"
sudo -iu matteo <<HEREDOC
    if ! dotnet --version &>/dev/null; then
        sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ yakkety main" > /etc/apt/sources.list.d/dotnetdev.list'
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
        sudo apt-get update -q -y
        sudo apt-get install -q -y dotnet-dev-1.0.4
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

echo ">>>> Remember to reboot the box"
echo ">>>> That's all, rock on!"