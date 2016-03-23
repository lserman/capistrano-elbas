describe 'ELBAS' do

  before do
    allow_any_instance_of(Elbas::AWSResource).to receive(:autoscale_group_name) { 'production' }
    webmock :get, /security-credentials/ => 'security-credentials.200.json'
    webmock(:post, /ec2.(.*).amazonaws.com\/\z/ => 'DescribeImages.200.xml') { Hash[body: /Action=DescribeImages/] }
    webmock(:post, /ec2.(.*).amazonaws.com\/\z/ => 'DescribeTags.200.xml') { Hash[body: /Action=DescribeTags/] }
    webmock(:post, /ec2.(.*).amazonaws.com\/\z/ => 'DescribeInstances.200.xml') { Hash[body: /Action=DescribeInstances/] }
    webmock(:post, /ec2.(.*).amazonaws.com\/\z/ => 'CreateImage.200.xml') { Hash[body: /Action=CreateImage/] }
    webmock(:post, /ec2.(.*).amazonaws.com\/\z/ => 'DeregisterImage.200.xml') { Hash[body: /Action=DeregisterImage/] }
    webmock(:post, /ec2.(.*).amazonaws.com\/\z/ => 'CreateTags.200.xml') { Hash[body: /Action=CreateTags/] }
    webmock(:post, /autoscaling.(.*).amazonaws.com\/\z/ => 'DescribeLaunchConfigurations.200.xml') { Hash[body: /Action=DescribeLaunchConfigurations/] }
    webmock(:post, /autoscaling.(.*).amazonaws.com\/\z/ => 'CreateLaunchConfiguration.200.xml') { Hash[body: /Action=CreateLaunchConfiguration/] }
    webmock(:post, /autoscaling.(.*).amazonaws.com\/\z/ => 'DeleteLaunchConfiguration.200.xml') { Hash[body: /Action=DeleteLaunchConfiguration/] }
    webmock(:post, /autoscaling.(.*).amazonaws.com\/\z/ => 'UpdateAutoScalingGroup.200.xml') { Hash[body: /Action=UpdateAutoScalingGroup/] }
  end

  let!(:ami) do
    _ami = nil
    Elbas::AMI.create { |ami| _ami = ami }
    _ami
  end

  describe 'AMI creation & cleanup' do
    it 'creates a new AMI on Amazon' do
      expect(ami.aws_counterpart.id).to eq 'ami-4fa54026'
    end

    it 'deletes any AMIs tagged with Deployed-with=ELBAS' do
      expect(WebMock).to have_requested(:post, /ec2.(.*).amazonaws.com\/\z/).with(body: /Action=DeregisterImage&ImageId=ami-1a2b3c4d/)
    end

    it 'tags the new AMI with Deployed-with=ELBAS' do
      expect(WebMock).to have_requested(:post, /ec2.(.*).amazonaws.com\/\z/).with(body: /Action=CreateTags&ResourceId.1=ami-4fa54026&Tag.1.Key=Deployed-with&Tag.1.Value=ELBAS/)
    end

    it 'tags the new AMI with ELBAS-Deploy-group=<autoscale group name>' do
      expect(WebMock).to have_requested(:post, /ec2.(.*).amazonaws.com\/\z/).with(body: /Action=CreateTags&ResourceId.1=ami-4fa54026&Tag.1.Key=ELBAS-Deploy-group&Tag.1.Value=production/)
    end
  end

  describe 'Launch configuration creation & cleanup' do
    let!(:launch_configuration) do
      _lc = nil
      Elbas::LaunchConfiguration.create(ami) { |lc| _lc = lc }
      _lc
    end

    it 'creates a new Launch Configuration on AWS' do
      expect(WebMock).to have_requested(:post, /autoscaling.(.*).amazonaws.com\/\z/).
        with(body: /Action=CreateLaunchConfiguration&AssociatePublicIpAddress=true&ImageId=ami-4fa54026&InstanceMonitoring.Enabled=true&InstanceType=m1.small&LaunchConfigurationName=ELBAS-production/)
    end

    it 'deletes any LCs with name =~ ELBAS-production' do
      expect(WebMock).to have_requested(:post, /autoscaling.(.*).amazonaws.com\/\z/).with(body: /Action=DeleteLaunchConfiguration&LaunchConfigurationName=ELBAS-production-production-LC-1234567890/)
    end

    it 'attaches the LC to the autoscale group' do
      launch_configuration.attach_to_autoscale_group!
      expect(WebMock).to have_requested(:post, /autoscaling.(.*).amazonaws.com\/\z/).with(body: /Action=UpdateAutoScalingGroup&AutoScalingGroupName=production&LaunchConfigurationName=ELBAS-production-production-LC-\d{10,}/)
    end
  end

end
