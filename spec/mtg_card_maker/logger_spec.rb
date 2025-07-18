# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe MtgCardMaker::Logger, :logger_spec do
  let(:output_stream) { StringIO.new }
  let(:error_stream) { StringIO.new }
  let(:logger) { described_class.new(output_stream: output_stream, error_stream: error_stream) }

  describe '#info' do
    it 'writes to stdout' do
      logger.info('Test message')
      expect(output_stream.string).to eq("Test message\n")
    end
  end

  describe '#warn' do
    it 'writes warning message with red X emoji to stderr' do
      logger.warn('Warning message')
      expect(error_stream.string).to eq("❌ Warning message\n")
    end
  end

  describe '#error' do
    it 'writes error message with explosion emoji to stderr' do
      logger.error('Error message')
      expect(error_stream.string).to eq("💥 Error: Error message\n")
    end
  end

  describe '#success' do
    it 'writes success message with sparkle emoji to stdout' do
      logger.success('Card generated')
      expect(output_stream.string).to eq("✨ Card generated ✨\n")
    end
  end

  describe 'default streams' do
    let(:default_logger) { described_class.new }

    it 'uses $stdout for info logger' do
      expect(default_logger.instance_variable_get(:@info_logger).instance_variable_get(:@logdev).dev).to eq($stdout)
    end

    it 'uses $stderr for error logger' do
      expect(default_logger.instance_variable_get(:@error_logger).instance_variable_get(:@logdev).dev).to eq($stderr)
    end
  end

  describe 'formatter' do
    it 'uses simple formatter that only outputs the message' do
      logger.info('Test message')
      expect(output_stream.string).to eq("Test message\n")
    end

    it 'does not include INFO in output' do
      logger.info('Test message')
      expect(output_stream.string).not_to include('INFO')
    end

    it 'does not include DateTime in output' do
      logger.info('Test message')
      expect(output_stream.string).not_to include('DateTime')
    end
  end
end
