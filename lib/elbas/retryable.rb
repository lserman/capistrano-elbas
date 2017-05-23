module Elbas
  module Retryable
    def with_retry(max: fetch(:elbas_retry_max, 3), delay: fetch(:elbas_retry_delay, 5))
      tries ||= 0
      tries += 1
      yield
    rescue => e
      puts "Rescued #{e.message}"
      if tries < max
        puts "Retrying in #{delay} seconds..."
        sleep delay
        retry
      end
    end
  end
end
