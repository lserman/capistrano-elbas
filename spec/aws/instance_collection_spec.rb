describe Elbas::AWS::InstanceCollection do
  subject { Elbas::AWS::InstanceCollection.new ['i-1234567890', 'i-500'] }

  scenarios = [
    { context: 'Single AWS reservation', mock_response_file: 'DescribeInstances.200.xml' },
    { context: 'Multiple AWS reservation', mock_response_file: 'DescribeInstances_MultipleReservations.200.xml' }
  ]

  scenarios.each do |scenario|
    context scenario[:context] do
      before do
        webmock :post, %r{ec2.(.*).amazonaws.com\/\z} => scenario[:mock_response_file],
          with: Hash[body: /Action=DescribeInstances/]
      end

      describe '#instances' do
        it 'returns Instance objects with name/hostname/state' do
          expect(subject.instances[0].id).to eq 'i-1234567890'
          expect(subject.instances[0].hostname).to eq 'ec2-1234567890.amazonaws.com'
          expect(subject.instances[0].state).to eq 16

          expect(subject.instances[1].id).to eq 'i-500'
          expect(subject.instances[1].hostname).to eq 'ec2-500.amazonaws.com'
          expect(subject.instances[1].state).to eq 32
        end
      end

      describe '#running' do
        it 'returns only running instances' do
          expect(subject.instances.size).to eq 2
          expect(subject.running.size).to eq 1
          expect(subject.running[0].id).to eq 'i-1234567890'
        end
      end
    end
  end

end
