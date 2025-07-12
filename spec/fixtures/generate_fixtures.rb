#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../lib/mtg_card_maker'

# Generate fixture SVG files for testing
module FixtureGenerator
  def self.generate_all
    puts 'Generating SVG fixtures...'

    # Create individual layer fixtures
    generate_art_fixture
    generate_border_fixture
    generate_frame_fixture
    generate_name_fixture
    generate_type_line_fixture
    generate_text_box_fixture
    generate_power_fixture

    # Create a complete card fixture
    generate_complete_card_fixture

    puts 'All fixtures generated successfully!'
  end

  def self.generate_border_fixture
    template = MtgCardMaker::Template.new
    layer = MtgCardMaker::BorderLayer.new(
      dimensions: {
        x: 0,
        y: 0,
        width: MtgCardMaker::CARD_WIDTH,
        height: MtgCardMaker::CARD_HEIGHT
      },
      color: :white
    )
    template.add_layer(layer)
    template.save('spec/fixtures/border_layer.svg')
  end

  # To generate a fixture with embedded font, use:
  # template = MtgCardMaker::Template.new(embed_font: true)

  def self.generate_frame_fixture
    template = MtgCardMaker::Template.new
    layer = MtgCardMaker::FrameLayer.new(
      dimensions: {
        x: 10,
        y: 10,
        width: MtgCardMaker::CARD_WIDTH - 20,
        height: MtgCardMaker::CARD_HEIGHT - 20
      },
      color: '#8B7355'
    )
    template.add_layer(layer)
    template.save('spec/fixtures/frame_layer.svg')
  end

  def self.generate_name_fixture
    template = MtgCardMaker::Template.new
    layer = MtgCardMaker::NameLayer.new(
      dimensions: { x: 30, y: 40, width: MtgCardMaker::CARD_WIDTH - 60, height: 50 },
      name: 'MTG Card Maker',
      cost: '10RRGU'
    )
    template.add_layer(layer)
    template.save('spec/fixtures/name_layer.svg')
  end

  def self.generate_art_fixture
    template = MtgCardMaker::Template.new
    layer = MtgCardMaker::ArtLayer.new(
      dimensions: { x: 40, y: 95, width: MtgCardMaker::CARD_WIDTH - 80, height: 400 }
    )
    template.add_layer(layer)
    template.save('spec/fixtures/art_layer.svg')
  end

  def self.generate_type_line_fixture
    template = MtgCardMaker::Template.new
    layer = MtgCardMaker::TypeLineLayer.new(
      dimensions: { x: 30, y: 500, width: MtgCardMaker::CARD_WIDTH - 60, height: 40 },
      type_line: 'Ruby - SVG - Shell',
      color: '#E8DCC6'
    )
    template.add_layer(layer)
    template.save('spec/fixtures/type_line_layer.svg')
  end

  def self.generate_text_box_fixture
    template = MtgCardMaker::Template.new
    layer = MtgCardMaker::TextBoxLayer.new(
      dimensions: {
        x: 40,
        y: 545,
        width: MtgCardMaker::CARD_WIDTH - 80,
        height: 265
      },
      rules_text: 'MTG Card Maker is a tool for creating fan-made MTG cards. ' \
                  'MTG Card Maker is unofficial Fan Content permitted under the Fan Content Policy. ' \
                  'Not approved/endorsed by Wizards. Portions of the materials used are property of ' \
                  'Wizards of the Coast. ©Wizards of the Coast LLC.',
      flavor_text: "MTG Card Maker is a tool for creating fan-made MTG cards\n -- Joe Sharp"
    )
    template.add_layer(layer)
    template.save('spec/fixtures/text_box_layer.svg')
  end

  def self.generate_power_fixture
    template = MtgCardMaker::Template.new
    layer = MtgCardMaker::PowerLayer.new(
      dimensions: {
        x: MtgCardMaker::CARD_WIDTH - 175,
        y: MtgCardMaker::CARD_HEIGHT - 90,
        width: 140,
        height: 40
      },
      power: '9999',
      toughness: '9999'
    )
    template.add_layer(layer)
    template.save('spec/fixtures/power_layer.svg')
  end

  def self.generate_complete_card_fixture
    # Create an instance of BaseCard with the same config as bin/generate_card
    config = {
      name: 'MTG Card Maker',
      mana_cost: '10RRGUBW',
      type_line: 'Ruby - SVG - Shell',
      rules_text: 'MTG Card Maker is a tool for creating fan-made MTG cards. ' \
                  'MTG Card Maker is unofficial Fan Content permitted under the Fan Content Policy. ' \
                  'Not approved/endorsed by Wizards. Portions of the materials used are property of ' \
                  'Wizards of the Coast. ©Wizards of the Coast LLC.',
      flavor_text: "MTG Card Maker is a tool for creating fan-made MTG cards\n -- Joe Sharp",
      power: '9999',
      toughness: '9999'
    }

    basic_card = MtgCardMaker::BaseCard.new(config)
    basic_card.save('spec/fixtures/complete_card.svg')
  end
end

# Generate fixtures if this file is run directly
FixtureGenerator.generate_all if __FILE__ == $PROGRAM_NAME
