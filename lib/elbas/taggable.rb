module Elbas
  module Taggable

    def tag(tags = {})
      with_retry do
        tags.each { |k, v| aws_counterpart.tags[k] = v }
      end
    end

  end
end
