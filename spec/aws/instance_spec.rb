describe Elbas::AWS::Instance do
  let (:public_instance) { Elbas::AWS::Instance.new 'i-1234567890', 'ec2-1234567890.amazonaws.com', 'ec2-1234567890.internal',  16 }
  let (:private_instance) { Elbas::AWS::Instance.new 'i-1234567890', nil, 'ec2-1234567890.internal',  16 }

  describe '#initialize' do
    it 'sets the AWS counterpart' do
      expect(public_instance.aws_counterpart).to be_a_kind_of ::Aws::EC2::Instance
      expect(public_instance.aws_counterpart.id).to eq 'i-1234567890'
    end
  end

  describe '#hostname' do
    it 'returns the public DNS if it is set' do
      expect(public_instance.hostname).to eq 'ec2-1234567890.amazonaws.com'
    end

    it 'returns private DNS if public one is not available' do
        expect(private_instance.hostname).to eq 'ec2-1234567890.internal'
    end
  end

  describe '#running?' do
    it 'returns true if the state code is 16 ("running")' do
      expect(public_instance).to receive(:state) { 16 }
      expect(public_instance).to be_running
    end

    it 'returns false for every other state code' do
      [0, 32, 48, 64, 80].each do |code|
        expect(public_instance).to receive(:state) { code }
        expect(public_instance).to_not be_running
      end
    end
  end
end
