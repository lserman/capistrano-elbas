describe Elbas::AWS::Taggable do
  TestTaggable = Class.new do
    include Elbas::AWS::Taggable

    def aws_counterpart
      @aws_counterpart ||= ::Aws::EC2::Instance.new 'test'
    end
  end

  let(:subject) { TestTaggable.new }



  context 'Tagging fails because resource is not created yet' do
    before do
      stub_request(:post, %r{amazonaws.com\/\z}).
        to_raise(StandardError).then.
        to_raise(StandardError).then.
        to_return(body: '')
    end

    describe '#tag' do
      it 'retries the tag up to 3 times' do
        expect(subject.aws_counterpart).to receive(:create_tags).exactly(3).times.and_call_original
        subject.tag 'test', 'true'
      end
    end

  end

  context 'Tagging succeeds' do
    before do
      webmock :post, %r{amazonaws.com\/\z} => 'CreateTags.200.xml',
        with: Hash[body: /Action=CreateTags/]
    end

    describe '#tag' do
      it 'hits the CreateTags API' do
        subject.tag 'test', 'true'
        expect(WebMock)
          .to have_requested(:post, /aws/)
          .with body: /Action=CreateTags/
      end

      it 'sends the resource, key, and value' do
        subject.tag 'test', 'true'
        expect(WebMock)
          .to have_requested(:post, /aws/)
          .with body: /ResourceId.1=test&Tag.1.Key=test&Tag.1.Value=true/
      end
    end
  end
end