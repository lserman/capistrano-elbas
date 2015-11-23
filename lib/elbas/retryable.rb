module Elbas
  module Retryable

    def with_retry(max: 3, delay: 5)
      tries ||= 0
      tries += 1
      yield
    rescue => e
      if tries < max
        sleep delay
        retry
      end
    end

  end
end
