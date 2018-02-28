#!/opt/puppetlabs/puppet/bin/ruby
require 'puppet'

Puppet.initialize_settings
require File.join(Puppet['plugindest'], 'puppet', 'util', 'nc_https.rb')

platforms = ENV['PE_REPO_PLATFORMS'] ? ENV['PE_REPO_PLATFORMS'].split(',') : nil
raise ArgumentError, 'Please supply PE_REPO_PLATFORMS environment variable' unless platforms

classifier = Puppet::Util::Nc_https.new

# Using T/P to collect group instances
Puppet::Type.type(:node_group)
Puppet::Type::Node_group::ProviderHttps.instances

id = $ngs.select { |g| g['name'] == 'PE Master' }.first['id']

puts %(PE Master ID: #{id})

platform_hash = {}
platforms.each do |platform|
  platform_hash[%(pe_repo::platform::#{platform})] = {}
end

data = {
  'id'      => id,
  'classes' => platform_hash,
}

classifier.update_group(data)
