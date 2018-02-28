require 'beaker-rspec'
require 'yaml'

# Record original log_level
orig_llevel = logger.log_level

RSpec.configure do |c|
  c.formatter = :documentation
end

PROJECT_ROOT = File.join(__dir__, '..')

# Repo configuration
begin
  config = YAML.load_file(File.join(PROJECT_ROOT, './config.yaml'))
rescue StandardError
  logger.error 'Could not file config.yaml'
  exit 1
else
  user          = ENV['USERNAME'] ? ENV['USERNAME'] : 'WhatsARanjit'
  repo_url      = %(#{config['repo_site']}/#{config['repo_owner']}/#{user}-#{config['repo_name']})
  master_script = %(#{repo_url}/#{config['repo_branch']}/install/pe_master_install.sh)
  agent_script  = %(#{repo_url}/#{config['repo_branch']}/install/pe_agent_install.sh)
end

# PE varibles
version    = ENV['PE_VERSION']
platform   = ENV['PE_PLATFORM']
arch       = ENV['PE_ARCH']
pe_version = %(puppet-enterprise-#{version}-#{platform}-#{arch})
pe_pkg     = %(#{pe_version}.tar.gz)

if File.exist?(File.join(PROJECT_ROOT, pe_pkg))
  logger.info '=> Copying PE tarball...'
  scp_to 'master', File.join(PROJECT_ROOT, pe_pkg), '/root'
  logger.success '=> PE tarball copied.'
else
  logger.info '=> Downloading PE tarball...'
  on 'master', %(wget --quiet --content-disposition https://s3.amazonaws.com/pe-builds/released/#{version}/#{pe_pkg})
  logger.success '=> PE tarball downloaded.'
end

logger.info '=> Expanding tarball...'
on 'master', %(tar zxpf #{pe_pkg})
logger.info '=> Creating puppet-enterprise symlink...'
on 'master', %(test -e puppet-enterprise || ln -s #{pe_version} puppet-enterprise)

logger.info '=> Copying pe.conf to master from install directory...'
scp_to 'master', File.join(PROJECT_ROOT, 'install/pe.conf'), '/tmp/pe.conf'

logger.info "=> Using script from #{master_script}."
logger.info '=> Installing PE. This may take a few minutes.'
# Force debug for install output
logger.log_level = :debug
on 'master', %(curl -sk #{master_script} | bash)
logger.log_level = orig_llevel
logger.success 'PE installed!'

logger.info '=> Allowing auto-sign for all.'
create_remote_file 'master', '/etc/puppetlabs/puppet/autosign.conf', '*'

logger.info '=> Setting up pe_repos'
on 'master', puppet('module', 'install', 'puppetlabs/stdlib', '--modulepath', '/opt/puppetlabs/puppet/modules')
on 'master', puppet('module', 'install', 'WhatsARanjit/node_manager', '--modulepath', '/opt/puppetlabs/puppet/modules')
run_script_on 'master', File.join(PROJECT_ROOT, 'spec', 'helpers', 'clear_cache.sh')
on 'master', puppet('plugin', 'download')
run_script_on 'master', File.join(PROJECT_ROOT, 'spec', 'helpers', 'add_pe_repo.rb'), environment: { 'PE_REPO_PLATFORMS' => 'ubuntu_1604_amd64' }

logger.info '=> Running puppet on the master'
on 'master', puppet('node_manager', 'classes', '--update')
on 'master', puppet('agent', '-t'), accept_all_exit_codes: true

if File.exist?(File.join(PROJECT_ROOT, 'install/groups.json'))
  logger.info '=> Importing groups.json classification'
  scp_to 'master', File.join(PROJECT_ROOT, 'install/groups.json'), '/tmp/groups.json'
  logger.log_level = :debug
  run_script_on 'master', File.join(PROJECT_ROOT, 'spec', 'helpers', 'import_groups.sh')
  on 'master', puppet('agent', '-t'), acceptable_exit_codes: [0, 2]
  logger.log_level = orig_llevel
end

hosts.each do |host|
  next if host['roles'].include?('master')
  logger.info "=> Using script from #{agent_script}."
  logger.info "=> Installing agent on #{host}..."
  logger.log_level = :debug
  on host, %(curl -sk #{agent_script} | bash)
  logger.log_level = orig_llevel
  logger.success "==> Done installing agent on #{host}."
  # https://stackoverflow.com/questions/43896191/error-could-not-find-a-suitable-provider-for-cron
  on host, puppet('resource', 'package', 'cron', 'ensure=installed') if fact_on(host, 'operatingsystem') == 'Ubuntu'
  logger.success "==> Waiting for agent run on #{host}."
  on host, 'while [ -f /opt/puppetlabs/puppet/cache/state/agent_catalog_run.lock ]; do sleep 5; done'
  on host, puppet('agent', '-t'), accept_all_exit_codes: true
end
