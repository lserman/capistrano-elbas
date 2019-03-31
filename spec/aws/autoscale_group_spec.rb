describe Elbas::AWS::AutoscaleGroup do
  subject { Elbas::AWS::AutoscaleGroup.new 'test-asg' }

  before do
    webmock :post, %r{autoscaling.(.*).amazonaws.com\/\z} => 'DescribeAutoScalingGroups.200.xml',
      with: Hash[body: /Action=DescribeAutoScalingGroups/]

    webmock :post, %r{ec2.(.*).amazonaws.com\/\z} => 'DescribeInstances.200.xml',
      with: Hash[body: /Action=DescribeInstances/]
  end

  describe '#initialize' do
    it 'sets the name' do
      expect(subject.name).to eq 'test-asg'
    end

    it 'has an aws-sdk counterpart' do
      expect(subject.aws_counterpart).to be_a_kind_of ::Aws::AutoScaling::Types::AutoScalingGroup
      expect(subject.aws_counterpart.auto_scaling_group_name).to eq 'test-asg'
    end
  end

  describe '#instance_ids' do
    it 'returns every instance ID in the ASG' do
      expect(subject.instance_ids).to eq ['i-1234567890', 'i-500']
    end
  end

  describe '#instances' do
    it 'returns an instance collection with all instances' do
      instances = subject.instances
      expect(instances.count).to eq 2
    end
  end

  describe '#launch_template' do
    it 'throws an error if there is no launch template' do
      expect { subject.launch_template }.to raise_error(Elbas::Errors::NoLaunchTemplate)
    end

    it 'returns a LaunchTemplate object with the id/name/version set' do
      allow(subject.aws_counterpart).to receive(:launch_template) do
        double(:lt, launch_template_id: 'test-1', launch_template_name: 'Test', version: '$Latest')
      end

      expect(subject.launch_template.id).to eq 'test-1'
      expect(subject.launch_template.name).to eq 'Test'
      expect(subject.launch_template.version).to eq '$Latest'
    end

    it 'returns a LauchTemplate object for fleet composition' do
      allow(subject.aws_counterpart).to receive(:launch_template) { nil }
      allow(subject.aws_counterpart).to receive_message_chain(
        :mixed_instances_policy, :launch_template,
        :launch_template_specification) do
        double(launch_template_id: 'test-2',
               launch_template_name: 'mixed_instance',
               version: '$Latest')
      end

      expect(subject.launch_template.id).to eq 'test-2'
      expect(subject.launch_template.name).to eq 'mixed_instance'
      expect(subject.launch_template.version).to eq '$Latest'
    end

  end
end
