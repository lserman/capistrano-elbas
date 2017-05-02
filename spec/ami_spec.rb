describe Elbas::AMI do
  describe '#tag' do
    subject { Elbas::AMI.new }

    it 'retries the tag 3 times' do
      expect(subject).to receive(:aws_counterpart).exactly(3).times { raise RuntimeError }
      subject.tag 'Test' => true
    end
  end
end
