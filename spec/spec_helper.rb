# frozen_string_literal: true

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/'

    enable_coverage :branch

    minimum_coverage line: 90, branch: 90

    add_group 'Layers', 'lib/mtg_card_maker/layers'
    add_group 'Colors', 'lib/mtg_card_maker/colors'
    add_group 'Core', 'lib/mtg_card_maker'
    add_group 'Bin', 'bin'
  end
end

require 'mtg_card_maker'

require_relative 'support/svg_fixture_helper'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Include SVG fixture helper methods
  config.include SVGFixtureHelper
  config.include SVGFixtureExpectations

  # Suppress logger output during tests by setting logger level to none
  config.before do
    # Create a null logger that discards all output
    null_logger = MtgCardMaker::Logger.new(output_stream: File::NULL, error_stream: File::NULL)
    allow(MtgCardMaker::Logger).to receive(:new).and_return(null_logger)
  end

  # Don't mock the logger in logger specs
  config.before(:each, :logger_spec) do
    allow(MtgCardMaker::Logger).to receive(:new).and_call_original
  end
end
