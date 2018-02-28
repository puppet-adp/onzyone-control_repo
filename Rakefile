require 'puppetlabs_spec_helper/rake_tasks'

desc 'Build docker environment'
RSpec::Core::RakeTask.new(:docker) do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'install'
end
