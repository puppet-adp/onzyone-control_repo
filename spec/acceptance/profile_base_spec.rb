require 'spec_helper_acceptance'

if hosts.length > 1
  hosts.each do |host|
    case fact_on(host, '-p', 'datacenter')
    when 'pdx'
      context %(test profile::base in PDX on #{host}) do
        describe file('/etc/ntp.conf'), node: host do
          its(:content) { should match(/^server\s+0\.us\.pool\.ntp\.org/) }
          its(:content) { should match(/^server\s+1\.us\.pool\.ntp\.org/) }
          its(:content) { should match(/^server\s+2\.us\.pool\.ntp\.org/) }
          its(:content) { should match(/^server\s+3\.us\.pool\.ntp\.org/) }
          its(:content) { should_not match(/^server\s+\d\.uk\.pool\.ntp\.org/) }
        end
        describe file('/etc/cron.deny'), node: host do
          its(:content) { should match(/^208\.67\.222\.222$/) }
          its(:content) { should match(/^208\.67\.220\.220$/) }
          its(:content) { should match(/^8\.8\.8\.8$/) }
          its(:content) { should match(/^8\.8\.4\.4$/) }
        end
      end
    when 'lon'
      context %(test profile::base in LON on #{host}) do
        describe file('/etc/ntp.conf'), node: host do
          its(:content) { should match(/^server\s+0\.uk\.pool\.ntp\.org/) }
          its(:content) { should match(/^server\s+1\.uk\.pool\.ntp\.org/) }
          its(:content) { should match(/^server\s+2\.uk\.pool\.ntp\.org/) }
          its(:content) { should match(/^server\s+3\.uk\.pool\.ntp\.org/) }
          its(:content) { should_not match(/^server\s+\d\.us\.pool\.ntp\.org/) }
        end
        describe file('/etc/cron.deny'), node: host do
          its(:content) { should_not match(/^208\.67\.222\.222$/) }
          its(:content) { should_not match(/^208\.67\.220\.220$/) }
          its(:content) { should match(/^8\.8\.8\.8$/) }
          its(:content) { should match(/^8\.8\.4\.4$/) }
        end
      end
    when 'nyc'
      context %(test profile::base in NYC on #{host}) do
        describe file('/etc/ntp.conf'), node: host do
          its(:content) { should match(/^server\s+0\.us\.pool\.ntp\.org/) }
          its(:content) { should match(/^server\s+1\.us\.pool\.ntp\.org/) }
          its(:content) { should match(/^server\s+2\.us\.pool\.ntp\.org/) }
          its(:content) { should match(/^server\s+3\.us\.pool\.ntp\.org/) }
          its(:content) { should_not match(/^server\s+\d\.uk\.pool\.ntp\.org/) }
        end
        describe file('/etc/cron.deny'), node: host do
          its(:content) { should_not match(/^208\.67\.222\.222$/) }
          its(:content) { should_not match(/^208\.67\.220\.220$/) }
          its(:content) { should match(/^8\.8\.8\.8$/) }
          its(:content) { should match(/^8\.8\.4\.4$/) }
        end
      end
    else
      logger.info %(#{host} does not match any datacenter with value '#{fact_on(host, 'datacenter')}')
      next
    end
  end
end
