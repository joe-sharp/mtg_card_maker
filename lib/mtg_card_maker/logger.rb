# frozen_string_literal: true

require 'logger'

module MtgCardMaker
  # A logger wrapper around Ruby's standard Logger that adds emoji to output
  # and provides separate streams for info (stdout) and warnings/errors (stderr).
  #
  # @example Basic usage
  #   logger = MtgCardMaker::Logger.new
  #   logger.info("Card generated successfully!")
  #   logger.warn("Warning: temp file cleanup failed")
  #   logger.error("Error: invalid configuration")
  #
  # @since 0.1.0
  class Logger
    # Initialize a new logger instance
    #
    # @param output_stream [IO] the output stream for info messages (default: $stdout)
    # @param error_stream [IO] the error stream for warnings/errors (default: $stderr)
    def initialize(output_stream: $stdout, error_stream: $stderr)
      @info_logger = ::Logger.new(output_stream)
      @error_logger = ::Logger.new(error_stream)

      # Set simple formatters that just output the message
      @info_logger.formatter = proc { |_severity, _datetime, _progname, msg| "#{msg}\n" }
      @error_logger.formatter = proc { |_severity, _datetime, _progname, msg| "#{msg}\n" }
    end

    # Log an info message to stdout
    #
    # @param message [String] the message to log
    # @return [void]
    def info(message)
      @info_logger.info(message)
    end

    # Log a warning message to stderr
    #
    # @param message [String] the warning message to log
    # @return [void]
    def warn(message)
      @error_logger.warn("❌ #{message}")
    end

    # Log an error message to stderr
    #
    # @param message [String] the error message to log
    # @return [void]
    def error(message)
      @error_logger.error("💥 Error: #{message}")
    end

    # Log a success message with sparkle emoji to stdout
    #
    # @param message [String] the success message to log
    # @return [void]
    def success(message)
      info("✨ #{message} ✨")
    end
  end
end
