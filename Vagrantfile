# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "gem-mirror-berkshelf"
  config.vm.box = "npm-mirror"
  # TODO: Find a suitable basebox for Vagrant (we need dozens of gigs!)
  # TODO: VM box URL
  # config.vm.box_url = ""

  config.berkshelf.enabled = true
  config.vm.provision :chef_solo do |chef|
    chef.json = {
      'gem_mirror' => {
        'data_dir' => '/home/vagrant/rubygems',
        'user' => 'vagrant'
      }
    }

    chef.run_list = [
        "recipe[gem-mirror::default]",
    ]
  end
end
