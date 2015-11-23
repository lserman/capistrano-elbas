describe Elbas::AMI do
  describe '#tag' do
    subject { Elbas::AMI.new }

    it 'retries the tag 3 times' do
      expect(subject).to receive(:aws_counterpart).exactly(3).times { OpenStruct.new(tags: nil) }
      subject.tag 'Test' => true
    end
  end
end
