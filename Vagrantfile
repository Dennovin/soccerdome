# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.define :soccerdome do |vm_config|
    vm_config.vm.provision "shell", inline: <<-EOB
      apt-get -y update
      apt-get -y install python python-dev python-psycopg2 python-requests python-bs4 postgresql-9.3
      sudo -u postgres createdb vagrant -E UTF8
      sudo -u postgres createuser vagrant
      sudo -u postgres psql -c 'grant all on database vagrant to vagrant'
    EOB
  end
end
