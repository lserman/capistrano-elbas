module Elbas
  class Retryable
    include Elbas::Logger

    def initialize
      @max = 0
      @delay = 0
    end

    def times(max, &block)
      @max = max
      run block if block_given?
    end

    def delay(seconds, &block)
      @delay = seconds
      run block if block_given?
    end

    def run(proc)
      attempts ||= 0
      attempts += 1
      proc.call
    rescue => e
      info "Rescued error in retryable action: #{e.message}"
      if attempts < @max
        info "Retrying in #{@delay} seconds..."
        sleep @delay
        retry
      end
    end

    def self.times(max, &block)
      new.tap { |r| r.times max }
    end

    def self.delay(seconds, &block)
      new.tap { |r| r.delay seconds }
    end
  end
end
