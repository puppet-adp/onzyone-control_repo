require 'spec_helper_acceptance'

describe 'puppet master tests' do
  context 'test PE install' do
    %w[pe-activemq pe-console-services pe-nginx pe-orchestration-services pe-postgresql pe-puppetdb pe-puppetserver].each do |pe_service|
      describe service(pe_service), node: 'master' do
        it { should be_running }
      end
    end
  end
end
