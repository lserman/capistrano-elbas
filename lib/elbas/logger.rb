require 'capistrano/doctor/output_helpers'

module Elbas
  module Logger
    include Capistrano::Doctor::OutputHelpers

    PREFIX_TEXT = '[ELBAS] '.freeze

    def info(message)
      $stdout.puts [prefix, message, "\n"].join
    end

    def error(message)
      $stderr.puts [error_prefix, message, "\n"].join
    end

    private
      def prefix
        @prefix ||= cyan(PREFIX_TEXT)
      end

      def error_prefix
        @error_prefix ||= red(PREFIX_TEXT)
      end

      def cyan(text)
        color_text text, :cyan
      end

      def red(text)
        color_text text, :red
      end

      def color_text(text, coloring)
        color.colorize text, coloring
      end
  end
end
