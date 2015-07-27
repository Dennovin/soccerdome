# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "trusty64"
  config.vm.provider :libvirt do |domain|
    domain.storage_pool_name = "guests"
  end

  config.vm.network :public_network, :dev => "br0", :mode => "bridge", :type => "bridge"
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yaml"
    ansible.sudo = true
    ansible.extra_vars = { ansible_ssh_user: "vagrant" }
  end

  hosts = [:soccerdome]

  hosts.each do |hostname|
    config.vm.define hostname do |vm_config|
      vm_config.vm.hostname = hostname
    end
  end
end
