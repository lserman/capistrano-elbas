describe Elbas::AWS::LaunchTemplate do
  subject { Elbas::AWS::LaunchTemplate.new 'test-lt', 'test', '1' }

  before do
    webmock :post, %r{ec2.(.*).amazonaws.com\/\z} => 'CreateLaunchTemplateVersion.200.xml',
                   with: Hash[body: /Action=CreateLaunchTemplateVersion/]
    webmock :post, %r{ec2.(.*).amazonaws.com\/\z} => 'ModifyLaunchTemplate.200.xml',
                   with: Hash[body: /Action=ModifyLaunchTemplate/]
  end

  describe '#initialize' do
    it 'sets the id' do
      expect(subject.id).to eq 'test-lt'
    end

    it 'sets the name' do
      expect(subject.name).to eq 'test'
    end

    it 'sets the version' do
      expect(subject.version).to eq '1'
    end
  end

  describe '#update' do
    it 'hits the CreateLaunchTemplateVersion API' do
      subject.update double(:ami, id: 'ami-123')
      expect(WebMock)
        .to have_requested(:post, /ec2/)
        .with(body: %r{Action=CreateLaunchTemplateVersion})
    end

    it 'creates a new launch template from the given AMI' do
      subject.update double(:ami, id: 'ami-123')
      expect(WebMock)
        .to have_requested(:post, /ec2/)
        .with(body: %r{LaunchTemplateData.ImageId=ami-123})
    end

    it 'uses itself as the source' do
      subject.update double(:ami, id: 'ami-123')
      expect(WebMock)
        .to have_requested(:post, /ec2/)
        .with(body: %r{LaunchTemplateId=test-lt&SourceVersion=1})
    end

    it 'updates default launch template version' do
      subject.update double(:ami, id: 'ami-123')
      expect(WebMock)
        .to have_requested(:post, /ec2/)
        .with(body: %r{Action=ModifyLaunchTemplate})
    end

    it 'returns a new launch template' do
      launch_template = subject.update double(:ami, id: 'ami-123')
      expect(launch_template.id).to eq 'lt-1234567890'
      expect(launch_template.name).to eq 'elbas-test'
      expect(launch_template.version).to eq 123
    end
  end
end
