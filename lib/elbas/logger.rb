require 'capistrano/doctor/output_helpers'

module Elbas
  module Logger
    include Capistrano::Doctor::OutputHelpers

    def info(message)
      $stdout.puts [prefix, message, "\n"].join
    end

    def cyan(text)
      color.colorize text, :cyan
    end

    private
      def prefix
        @prefix ||= cyan('[ELBAS] ')
      end
  end
end
