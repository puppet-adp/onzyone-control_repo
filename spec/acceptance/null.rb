require 'beaker-rspec'

describe 'build docker environment' do
  context 'no tests' do
    it do
      result = shell('/bin/true')
      expect(result.exit_code).to be_zero
    end
  end
end
