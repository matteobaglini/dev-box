Vagrant.configure("2") do |config|
    config.vm.box = "bento/ubuntu-18.04"
    config.vm.box_check_update = false
    config.vm.hostname = "hoster"

    config.vm.provider "virtualbox" do |vb|
        vb.name = "dev-box"
        vb.cpus = 4
        vb.memory = 16384
        vb.gui = true

        vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
        vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        vb.customize ["modifyvm", :id, "--vram", "256"]
        vb.customize ["modifyvm", :id, "--acpi", "on"]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
    end

    config.vm.provision "shell", path: "provision.sh"
end
