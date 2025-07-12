# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe MtgCardMaker do
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    # Reload the version file to ensure code coverage is accurate
    %i[MAJOR MINOR PATCH VERSION].each do |const|
      described_class.send(:remove_const, const) # rubocop:disable RSpec/RemoveConst
    end
    $LOADED_FEATURES.delete(
      File.absolute_path(
        File.join(__dir__, '../lib/mtg_card_maker/version.rb')
      )
    )
    require_relative '../lib/mtg_card_maker/version'
  end

  it 'has a non-zero version number', :aggregate_failures do
    expect(described_class::VERSION).not_to be_nil
    expect(Gem::Version.new(described_class::VERSION)).to be > Gem::Version.new('0.0.0')
  end

  it 'follows semantic versioning', :aggregate_failures do
    expect(described_class::MAJOR).to be_a(Integer)
    expect(described_class::MINOR).to be_a(Integer)
    expect(described_class::PATCH).to be_a(Integer)
    expect(described_class::VERSION).to match(/\d+\.\d+\.\d+/)
  end

  it 'defines an Error class' do
    expect(described_class::Error).to be < StandardError
  end

  describe MtgCardMaker::BaseLayer do
    it 'raises NotImplementedError for render' do
      layer = described_class.new(dimensions: { x: 0, y: 0, width: 100, height: 100 })
      expect { layer.render }.to raise_error(NotImplementedError, /render/)
    end

    it 'returns nil for svg if template is nil' do
      layer = described_class.new(dimensions: { x: 0, y: 0, width: 100, height: 100 })
      expect(layer.svg).to be_nil
    end
  end

  describe MtgCardMaker::Template do
    let(:template) { described_class.new }
    let(:test_layer) do
      MtgCardMaker::BorderLayer.new(
        dimensions: { x: 0, y: 0, width: 100, height: 150 },
        color: :white
      )
    end

    it 'initializes with default dimensions' do
      expect(template).to be_a(described_class)
    end

    it 'initializes with custom dimensions' do
      custom_template = described_class.new(width: 800, height: 1000)
      expect(custom_template).to be_a(described_class)
    end

    it 'adds layer and generates SVG successfully' do
      expect_svg_generation_to_succeed(test_layer)
    end

    it 'saves to file successfully', :aggregate_failures do
      temp_file = Tempfile.new(['test', '.svg'])
      expect { template.save(temp_file.path) }.not_to raise_error
      expect(File.exist?(temp_file.path)).to be true
      temp_file.close
      temp_file.unlink
    end

    it 'can add multiple layers' do
      layer1 = MtgCardMaker::BorderLayer.new(
        dimensions: { x: 0, y: 0, width: 100, height: 150 }
      )
      layer2 = MtgCardMaker::FrameLayer.new(
        dimensions: { x: 10, y: 10, width: 80, height: 130 }
      )

      template.add_layer(layer1)
      template.add_layer(layer2)

      temp_file = Tempfile.new(['multi_layer', '.svg'])
      expect { template.save(temp_file.path) }.not_to raise_error

      # Should have rect elements from both layers
      expect_svg_to_have_elements(temp_file.path, 'rect')

      temp_file.close
      temp_file.unlink
    end

    it 'generates valid SVG structure' do
      template.add_layer(test_layer)

      temp_file = Tempfile.new(['structure_test', '.svg'])
      template.save(temp_file.path)

      # Verify SVG structure
      expect_svg_to_have_elements(temp_file.path, 'svg')
      expect_svg_to_contain(temp_file.path, 'xmlns="http://www.w3.org/2000/svg"')
      expect_svg_to_contain(temp_file.path, '</svg>')

      temp_file.close
      temp_file.unlink
    end

    context 'with different file formats' do
      it 'saves with different extensions' do
        temp_file = Tempfile.new(['test', '.png'])
        expect { template.save(temp_file.path) }.not_to raise_error
        temp_file.close
        temp_file.unlink
      end
    end

    it 'embeds font when embed_font is true' do
      template = described_class.new(embed_font: true)
      svg = template.to_svg
      expect(svg).to include('data:font/truetype;charset=utf-8;base64')
    end
  end

  describe 'Integration tests' do
    it 'can create a complete card template', :aggregate_failures do
      # Use the helper method to create a complete card with custom layers
      custom_layers = {
        border: described_class::BorderLayer.new(
          dimensions: { x: 0, y: 0, width: 100, height: 150 }
        ),
        frame: described_class::FrameLayer.new(
          dimensions: { x: 5, y: 5, width: 90, height: 140 }
        ),
        name_area: described_class::NameLayer.new(
          dimensions: { x: 10, y: 10, width: 200, height: 80 },
          name: 'Test Card',
          cost: '1R'
        )
      }

      svg_content = generate_complete_card_svg(custom_layers)

      # Verify content
      expect_svg_to_have_text(svg_content, 'Test')
      expect_svg_to_contain(svg_content, '1')
    end

    it 'processes layers in order and generates valid SVG' do
      # Use the helper method to create a complete card with custom layers
      custom_layers = {
        border: described_class::BorderLayer.new(
          dimensions: { x: 0, y: 0, width: 200, height: 300 }
        ),
        frame: described_class::FrameLayer.new(
          dimensions: { x: 10, y: 10, width: 180, height: 280 }
        )
      }

      svg_content = generate_complete_card_svg(custom_layers)

      # Verify SVG structure
      expect_svg_to_have_elements(svg_content, 'svg')
      expect_svg_to_contain(svg_content, 'width="630"') # Default template size
      expect_svg_to_contain(svg_content, 'height="880"') # Default template size
      expect_svg_to_have_elements(svg_content, 'rect') # Should have rectangles from both layers
      expect_svg_to_contain(svg_content, '</svg>')
    end

    it 'generates a complete card matching fixture' do
      # Create card with explicit power/toughness to match fixture
      config = {
        name: 'MTG Card Maker',
        mana_cost: '10RRGUBW',
        type_line: 'Ruby - SVG - Shell',
        description: 'MTG Card Maker is a tool for creating fan-made MTG cards. ' \
                     'MTG Card Maker is unofficial Fan Content permitted under the Fan Content Policy. ' \
                     'Not approved/endorsed by Wizards. Portions of the materials used are property of ' \
                     'Wizards of the Coast. ©Wizards of the Coast LLC.',
        flavor_text: "MTG Card Maker is a tool for creating fan-made MTG cards\n -- Joe Sharp",
        power: '9999',
        toughness: '9999'
      }

      basic_card = MtgCardMaker::BaseCard.new(config)

      # Test that the complete card contains all expected elements
      expect_svg_to_contain(basic_card, 'MTG Card Maker')
      expect_svg_to_contain(basic_card, 'Ruby - SVG - Shell')
      expect_svg_to_contain(basic_card, 'MTG Card Maker is a tool for creating fan-made MTG cards')
      expect_svg_to_contain(basic_card, '9999/9999')
      expect_svg_to_contain(basic_card, '© 2025 Joe Sharp')
      expect_svg_to_contain(basic_card, 'Wizards of the Coast')

      # Test that it has the expected SVG structure
      expect_svg_to_have_elements(basic_card, 'svg', 'rect', 'text', 'defs')
      expect_svg_to_contain(basic_card, 'width="630"')
      expect_svg_to_contain(basic_card, 'height="880"')
    end
  end

  describe 'Module constants and structure' do
    it 'has the expected module structure', :aggregate_failures do
      expect(described_class).to be_a(Module)
      expect(described_class::BaseLayer).to be_a(Class)
      expect(described_class::Template).to be_a(Class)
      expect(described_class::Error).to be_a(Class)
    end

    it 'loads all layer classes', :aggregate_failures do
      expect(described_class::BorderLayer).to be_a(Class)
      expect(described_class::FrameLayer).to be_a(Class)
      expect(described_class::NameLayer).to be_a(Class)
      expect(described_class::ArtLayer).to be_a(Class)
      expect(described_class::TypeLineLayer).to be_a(Class)
      expect(described_class::TextBoxLayer).to be_a(Class)
      expect(described_class::PowerLayer).to be_a(Class)
    end

    it 'has all layers inherit from BaseLayer' do
      layer_classes = [
        described_class::BorderLayer,
        described_class::FrameLayer,
        described_class::NameLayer,
        described_class::ArtLayer,
        described_class::TypeLineLayer,
        described_class::TextBoxLayer,
        described_class::PowerLayer
      ]

      expect(layer_classes).to all(be < described_class::BaseLayer)
    end
  end
end
