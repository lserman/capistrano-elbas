require 'elbas/capistrano'

describe '#autoscale' do
  before do
    Capistrano::Configuration.reset!
    Rake::Task.define_task('deploy') {}

    webmock :post, %r{autoscaling.(.*).amazonaws.com\/\z} => 'DescribeAutoScalingGroups.200.xml',
      with: Hash[body: /Action=DescribeAutoScalingGroups/]
  end

  context 'one server'  do
    before do
      webmock :post, %r{ec2.(.*).amazonaws.com\/\z} => 'DescribeInstances.200.xml',
      with: Hash[body: /Action=DescribeInstances/]
    end

    it 'adds the server hostname' do
      autoscale 'test-asg'
      expect(env.servers.count).to eq 1
      expect(env.servers.first.hostname).to eq 'ec2-1234567890.amazonaws.com'
    end

    it 'passes along the properties' do
      autoscale 'test-asg', roles: [:db], primary: true
      expect(env.servers.first.properties.roles).to match_array [:db]
      expect(env.servers.first.properties.primary).to eq true
    end
  end

  context 'multiple servers' do
    before do
      webmock :post, %r{ec2.(.*).amazonaws.com\/\z} => 'DescribeInstances_MultipleRunning.200.xml',
        with: Hash[body: /Action=DescribeInstances/]
    end

    it 'adds multiple server hostnames' do
      autoscale 'test-asg'
      expect(env.servers.count).to eq 2
      expect(env.servers.map(&:hostname)).to match_array ['ec2-1234567890.amazonaws.com', 'ec2-1122334455.amazonaws.com']
    end

    it 'passes along the properties' do
      autoscale 'test-asg', roles: [:db], primary: true
      count = 0
      env.servers.each do |server|
        count = count + 1
        expect(server.properties.roles).to match_array [:db]
        expect(server.properties.primary).to eq true
      end
      expect(count).to eq 2
    end

    it 'yields to find properties if a block is given' do
      autoscale 'test-asg', roles: [:web] do |server, i|
        { roles: [:web, :db], primary: true } if i == 0
      end

      expect(env.servers.to_a[0].properties.roles).to match_array [:web, :db]
      expect(env.servers.to_a[0].properties.primary).to eq true

      expect(env.servers.to_a[1].properties.roles).to match_array [:web]
      expect(env.servers.to_a[1].properties.keys).to_not include :primary
    end
  end

  context 'no servers' do
    before do
      webmock :post, %r{ec2.(.*).amazonaws.com\/\z} => 'DescribeInstances_Empty.200.xml',
        with: Hash[body: /Action=DescribeInstances/]
    end

    it 'logs as an error' do
      expect { autoscale 'test-asg' }.to output.to_stderr
    end
  end
end
