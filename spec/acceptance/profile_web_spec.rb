require 'spec_helper_acceptance'

if hosts.length > 1
  hosts_as('master').each do |host|
    context %(test profile::web should not be on #{host}) do
      describe port(9090), node: host do
        it { should_not be_listening }
      end
    end
  end
  hosts_as('agent').each do |host|
    case fact_on(host, 'operatingsystem')
    when 'CentOS'
      context %(test profile::web on CentOS on #{host}) do
        describe port(9090), node: host do
          it { should_not be_listening }
        end
      end
    when 'Ubuntu'
      context %(test profile::web on Ubuntu on #{host}) do
        describe port(9090), node: host do
          it { should be_listening }
        end
        describe command('curl -sk http://localhost:9090/hello.html'), node: host do
          its(:stdout) { should match(/Hello, World!/i) }
        end
      end
    else
      logger.info %(#{host} does not match any operatingsystem with value '#{fact_on(host, 'operatingsystem')}')
      next
    end
  end
end
