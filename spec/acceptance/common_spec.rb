require 'spec_helper_acceptance'

describe 'common tests' do
  context 'test datacenter fact' do
    it 'should match first 3 letters of hostname' do
      pp = <<-EOS
        validate_re($hostname, "^$datacenter", "Hostname: '${hostname}'; Datacenter: '${datacenter}'")
      EOS

      apply_manifest(pp, catch_failures: true)
      expect(apply_manifest(pp, catch_failures: true).exit_code).to be_zero
    end
  end
end
