agents = {
  'lon-agent' => 'puppetlabs/ubuntu-16.04-64-nocm',
  'nyc-agent' => 'puppetlabs/centos-7.2-64-nocm',
}

ip    = ENV['MASTERIP'] || '10.20.1.2'
parts = ip.rpartition(/\d+$/).reject { |c| c.empty? }

Vagrant.configure(2) do |config|
  config.vm.define 'pdx-master' do |master|
    master.vm.box = 'puppetlabs/centos-7.2-64-nocm'
    master.vm.provider 'virtualbox' do |v|
      v.memory = 8192
      v.cpus   = 4
    end

    master.vm.hostname = 'pdx-master'
    master.vm.network :private_network, ip: ip
    master.vm.provision :hosts, sync_hosts: true
  end

  agents.each do |nodename, platform|
    config.vm.define nodename do |node|
      node.vm.box = platform
      node.vm.hostname = 'pdx-master'
      node.vm.network :private_network, ip: %(#{parts.first}#{parts.last.to_i + 1})
      node.vm.provision :hosts, sync_hosts: true
    end
  end
end
