require 'capistrano/doctor/output_helpers'

module Elbas
  module Logger
    include Capistrano::Doctor::OutputHelpers

    def info(message)
      $stdout.puts [prefix, message, "\n"].join
    end

    def prefix
      @prefix ||= color.colorize("\n[ELBAS] ", :cyan)
    end
  end
end