module Elbas
  module AWS
    module Taggable
      def tag(key, value)
        @tags ||= {}

        Elbas::Retryable.times(3).delay(5) do
          aws_counterpart.create_tags tags: [{ key: key, value: value }]
          @tags[key] = value
        end
      end

      def tags
        @tags || {}
      end
    end
  end
end