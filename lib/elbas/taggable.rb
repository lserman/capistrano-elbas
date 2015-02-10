module Elbas
  module Taggable

    def tag(tags = {})
      tags.each do |k, v|
        aws_counterpart.tags[k] = v
      end
    end

  end
end