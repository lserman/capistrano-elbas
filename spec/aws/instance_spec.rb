describe Elbas::AWS::Instance do
  subject { Elbas::AWS::Instance.new 'i-1234567890', 'ec2-1234567890.amazonaws.com', 16 }

  describe '#initialize' do
    it 'sets the AWS counterpart' do
      expect(subject.aws_counterpart).to be_a_kind_of ::Aws::EC2::Instance
      expect(subject.aws_counterpart.id).to eq 'i-1234567890'
    end
  end

  describe '#hostname' do
    it 'returns the public DNS' do
      expect(subject.hostname).to eq 'ec2-1234567890.amazonaws.com'
    end
  end

  describe '#running?' do
    it 'returns true if the state code is 16 ("running")' do
      expect(subject).to receive(:state) { 16 }
      expect(subject).to be_running
    end

    it 'returns false for every other state code' do
      [0, 32, 48, 64, 80].each do |code|
        expect(subject).to receive(:state) { code }
        expect(subject).to_not be_running
      end
    end
  end
end