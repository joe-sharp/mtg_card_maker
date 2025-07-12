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
end
