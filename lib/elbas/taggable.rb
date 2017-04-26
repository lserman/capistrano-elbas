module Elbas
  # Adds tags to AWS resources
  module Taggable
    def tag(tags = {})
      with_retry do
        tags.each { |k, v| aws_counterpart.create_tags(tags: [{key: k, value: v}]) }
      end
    end
  end
end
