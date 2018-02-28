require 'spec_helper_acceptance'

if hosts.length > 1
  hosts_as('agent').each do |host|
    case fact_on(host, 'operatingsystem')
    when 'CentOS'
      context %(test profile::sysctl on CentOS on #{host}) do
        describe file('/etc/sysctl.conf'), node: host do
          its(:content) { should match(/^net.ipv4.conf.all.send_redirects\s*=\s*0$/) }
          its(:content) { should match(/^net\.ipv4\.conf\.default\.send_redirects\s*=\s*0$/) }
          its(:content) { should match(/^net\.ipv4\.conf\.all\.accept_source_route\s*=\s*0$/) }
          its(:content) { should match(/^net\.ipv4\.conf\.all\.accept_redirects\s*=\s*0$/) }
          its(:content) { should match(/^net\.ipv4\.conf\.all\.secure_redirects\s*=\s*0$/) }
          its(:content) { should match(/^net\.ipv4\.conf\.all\.log_martians\s*=\s*1$/) }
          its(:content) { should match(/^net\.ipv4\.conf\.default\.accept_source_route\s*=\s*0$/) }
          its(:content) { should match(/^net\.ipv4\.conf\.default\.accept_redirects\s*=\s*0$/) }
          its(:content) { should match(/^net\.ipv4\.conf\.default\.secure_redirects\s*=\s*0$/) }
          its(:content) { should match(/^net\.ipv4\.icmp_echo_ignore_broadcasts\s*=\s*1$/) }
          its(:content) { should match(/^net\.ipv4\.tcp_syncookies\s*=\s*1$/) }
          its(:content) { should match(/^net\.ipv4\.conf\.all\.rp_filter\s*=\s*1$/) }
          its(:content) { should match(/^net\.ipv4\.conf\.default\.rp_filter\s*=\s*1$/) }
        end
      end
    when 'Ubuntu'
      context %(test profile::sysctl on Ubuntu on #{host}) do
        describe file('/etc/sysctl.conf'), node: host do
          its(:content) { should match(/^kernel\.shmall\s*=\s*2097152$/) }
          its(:content) { should match(/^kernel\.shmmax\s*=\s*2147483648$/) }
          its(:content) { should match(/^kernel\.shmmni\s*=\s*4096$/) }
          its(:content) { should match(/^fs\.file\-max\s*=\s*65536$/) }
          its(:content) { should match(/^vm\.swappiness\s*=\s*0$/) }
          its(:content) { should match(/^vm\.vfs_cache_pressure\s*=\s*50$/) }
        end
      end
    else
      logger.info %(#{host} does not match any operatingsystem with value '#{fact_on(host, 'operatingsystem')}')
      next
    end
  end
end
