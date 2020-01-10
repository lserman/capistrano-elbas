describe Elbas::AWS::AMI do
  subject { Elbas::AWS::AMI.new 'test' }

  describe '#initialize' do
    it 'sets the id' do
      expect(subject.id).to eq 'test'
    end

    it 'has an aws-sdk counterpart' do
      expect(subject.aws_counterpart).to be_a_kind_of ::Aws::EC2::Image
      expect(subject.aws_counterpart.id).to eq 'test'
    end

    context 'with snapshots' do
      subject do
        Elbas::AWS::AMI.new 'test', [
          double(:bdm, ebs: double(:ebs, snapshot_id: 'snap-1'))
        ]
      end

      it 'sets snapshots to Snapshot objects' do
        expect(subject.snapshots.size).to eq 1
        expect(subject.snapshots[0]).to be_a_kind_of Elbas::AWS::Snapshot
      end

      it 'sets the ID on the Snapshots' do
        expect(subject.snapshots[0].id).to eq 'snap-1'
      end
    end
  end

  describe '#deploy_id' do
    it 'returns the ELBAS-Deploy-id tag, if set' do
      webmock :post, /ec2/ => 201, with: Hash[body: /Action=CreateTags/]
      subject.tag 'ELBAS-Deploy-id', 'test'
      expect(subject.deploy_id).to eq 'test'
    end

    it 'returns nil if the tag was never set' do
      expect(subject.deploy_id).to be_nil
    end
  end

  describe '#deploy_group' do
    it 'returns the ELBAS-Deploy-group tag, if set' do
      webmock :post, /ec2/ => 201, with: Hash[body: /Action=CreateTags/]
      subject.tag 'ELBAS-Deploy-group', 'test'
      expect(subject.deploy_group).to eq 'test'
    end

    it 'returns nil if the tag was never set' do
      expect(subject.deploy_group).to be_nil
    end
  end

  describe '#ancestors' do
    before do
      webmock :post, /ec2/ => 201, with: Hash[body: /Action=CreateTags/]
      subject.tag 'ELBAS-Deploy-group', 'test'
      subject.tag 'ELBAS-Deploy-id', 'test'

      webmock :post, %r{ec2.(.*).amazonaws.com\/\z} => 'DescribeImages.200.xml',
        with: Hash[body: /Action=DescribeImages/]
    end

    it 'includes AMIs from the same deploy group, different deploy ID' do
      expect {
        subject.tag 'ELBAS-Deploy-id', 'not-test'
      }.to change {
        subject.ancestors.size
      }.by 1
    end
  end

  describe '#delete' do
    before do
      webmock :post, /ec2/ => 201, with: Hash[body: /Action=DeregisterImage/]
    end

    it 'calls the deregister AMI API' do
      subject.delete
      expect(WebMock)
        .to have_requested(:post, /ec2/)
        .with body: /Action=DeregisterImage&ImageId=test/
    end

    context 'with snapshots' do
      subject do
        Elbas::AWS::AMI.new 'test', [
          double(:bdm, ebs: double(:ebs, snapshot_id: 'snap-1'))
        ]
      end

      it 'deletes the AMIs snapshots too' do
        webmock :post, /ec2/ => 201, with: Hash[body: /Action=DeleteSnapshot/]

        subject.delete
        expect(WebMock)
          .to have_requested(:post, /ec2/)
          .with body: /Action=DeleteSnapshot&SnapshotId=snap-1/
      end
    end
  end

  describe '.create' do
    subject { described_class }
    let(:instance) { Elbas::AWS::Instance.new 'i-1234567890', nil, nil }

    before do
      webmock :post, %r{ec2.(.*).amazonaws.com\/\z} => 'CreateImage.200.xml',
        with: Hash[body: /Action=CreateImage/]
    end

    it 'calls the API with the instance given' do
      subject.create instance
      expect(WebMock)
        .to have_requested(:post, /ec2/)
        .with body: /Action=CreateImage&InstanceId=i-1234567890&Name=ELBAS-ami-(\d+)/
    end

    it 'uses the no_reboot option by default' do
      subject.create instance
      expect(WebMock)
        .to have_requested(:post, /ec2/)
        .with(body: /NoReboot=true/)
    end

    it 'uses no_reboot as false, if given' do
      subject.create instance, no_reboot: false
      expect(WebMock)
        .to have_requested(:post, /ec2/)
        .with(body: /NoReboot=false/)
    end

    it 'returns the an AMI object with the new id' do
      ami = subject.create instance
      expect(ami.id).to eq 'ami-4fa54026' # from stub
    end
  end
end