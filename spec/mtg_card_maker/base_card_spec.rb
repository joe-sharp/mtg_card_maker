# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::BaseCard do
  let(:color_scheme) { MtgCardMaker::ColorScheme.new(:blue) }

  describe '#initialize' do
    it 'creates a basic card with default settings', :aggregate_failures do
      card = described_class.new({})
      expect(card.name).to be_nil
      expect(card.color_scheme).to eq(MtgCardMaker::DEFAULT_COLOR_SCHEME)
      expect(card.mana_cost).to be_nil
      expect(card.type_line).to be_nil
      expect(card.rules_text).to be_nil
      expect(card.flavor_text).to be_nil
      expect(card.power).to be_nil
      expect(card.toughness).to be_nil
    end

    it 'accepts custom color scheme', :aggregate_failures do
      card = described_class.new(color: :blue)
      expect(card.color_scheme).to be_a(MtgCardMaker::ColorScheme)
      expect(card.color_scheme.primary_color).to eq(MtgCardMaker::ColorScheme.new(:blue).primary_color)
    end

    it 'accepts custom name' do
      card = described_class.new(name: 'Custom Card')
      expect(card.name).to eq('Custom Card')
    end

    it 'accepts all configurable parameters', :aggregate_failures do
      card = described_class.new(
        name: 'Test Card',
        mana_cost: '2U',
        type_line: 'Instant',
        rules_text: 'Test description',
        flavor_text: 'Test flavor text',
        power: '3',
        toughness: '3',
        color: :blue
      )

      expect(card.name).to eq('Test Card')
      expect(card.mana_cost).to eq('2U')
      expect(card.type_line).to eq('Instant')
      expect(card.rules_text).to eq('Test description')
      expect(card.flavor_text).to eq('Test flavor text')
      expect(card.power).to eq('3')
      expect(card.toughness).to eq('3')
      expect(card.color_scheme).to be_a(MtgCardMaker::ColorScheme)
      expect(card.color_scheme.primary_color).to eq(MtgCardMaker::ColorScheme.new(:blue).primary_color)
    end
  end

  describe '#save' do
    it 'saves the card to a file', :aggregate_failures do
      card = described_class.new({})
      temp_file = Tempfile.new(['test_card', '.svg'])

      expect { card.save(temp_file.path) }.not_to raise_error
      expect(File.exist?(temp_file.path)).to be true

      temp_file.close
      temp_file.unlink
    end
  end

  describe 'dimension methods' do
    let(:card) { described_class.new({}) }

    it 'provides layer dimensions', :aggregate_failures do
      border = card.dimensions_for_layer(:border)
      expect(border[:x]).to eq(0)
      expect(border[:y]).to eq(0)
      expect(border[:width]).to eq(630)
      expect(border[:height]).to eq(880)

      frame = card.dimensions_for_layer(:frame)
      expect(frame[:x]).to eq(10)
      expect(frame[:y]).to eq(10)
      expect(frame[:width]).to eq(610)
      expect(frame[:height]).to eq(860)
    end

    it 'provides art window configuration', :aggregate_failures do
      art_config = card.art_window_config
      expect(art_config[:x]).to eq(40)
      expect(art_config[:y]).to eq(95)
      expect(art_config[:width]).to eq(550)
      expect(art_config[:height]).to eq(400)
    end

    it 'provides frame stroke width' do
      expect(card.frame_stroke_width).to eq(2)
    end
  end

  describe 'layer creation methods' do
    let(:card) { described_class.new(color: :blue) }

    it 'creates layers using LayerFactory with correct properties', :aggregate_failures do
      layers = MtgCardMaker::LayerFactory.create_layers_for_card(card, 'artWindowMask', card)

      expect(layers.length).to eq(7)

      # Test border layer
      border = layers[0]
      expect(border).to be_a(MtgCardMaker::BorderLayer)
      expect(border.x).to eq(0)
      expect(border.y).to eq(0)
      expect(border.width).to eq(630)
      expect(border.height).to eq(880)

      # Test frame layer
      frame = layers[1]
      expect(frame).to be_a(MtgCardMaker::FrameLayer)
      expect(frame.x).to eq(10)
      expect(frame.y).to eq(10)
      expect(frame.width).to eq(610)
      expect(frame.height).to eq(860)
      expect(frame.color_scheme).to eq(card.color_scheme)

      # Test name area layer
      name_area = layers[2]
      expect(name_area).to be_a(MtgCardMaker::NameLayer)
      expect(name_area.name).to be_nil
      expect(name_area.color_scheme).to eq(card.color_scheme)

      # Test art layer
      art_layer = layers[3]
      expect(art_layer).to be_a(MtgCardMaker::ArtLayer)
      expect(art_layer.x).to eq(40)
      expect(art_layer.y).to eq(95)
      expect(art_layer.width).to eq(550)
      expect(art_layer.height).to eq(400)
      expect(art_layer.color_scheme).to eq(card.color_scheme)

      # Test type area layer
      type_area = layers[4]
      expect(type_area).to be_a(MtgCardMaker::TypeLineLayer)
      expect(type_area.type_line).to be_nil
      expect(type_area.color_scheme).to eq(card.color_scheme)

      # Test description layer
      description_layer = layers[5]
      expect(description_layer).to be_a(MtgCardMaker::TextBoxLayer)
      expect(description_layer.rules_text).to be_nil
      expect(description_layer.color_scheme).to eq(card.color_scheme)

      # Test power area layer
      power_area = layers[6]
      expect(power_area).to be_a(MtgCardMaker::PowerLayer)
      expect(power_area.x).to eq(455)
      expect(power_area.y).to eq(790)
      expect(power_area.width).to eq(140)
      expect(power_area.height).to eq(40)
      expect(power_area.color_scheme).to eq(card.color_scheme)
    end
  end

  describe 'art window mask' do
    it 'defines art window mask with correct dimensions', :aggregate_failures do
      card = described_class.new({})
      template = card.instance_variable_get(:@template)
      svg = template.instance_variable_get(:@svg)

      # The mask should be defined in the SVG
      svg_content = svg.to_s
      expect(svg_content).to include('mask id="artWindowMask"')
      expect(svg_content).to include('x="40" y="95"')
      expect(svg_content).to include('width="550" height="400"')
    end
  end

  describe 'template creation' do
    it 'creates template with correct dimensions', :aggregate_failures do
      card = described_class.new({})
      template = card.instance_variable_get(:@template)

      expect(template.width).to eq(630)
      expect(template.height).to eq(880)
    end
  end

  describe 'DEFAULTS constant' do
    it 'defines layer dimensions', :aggregate_failures do
      expect(described_class::DEFAULTS[:layers][:border][:x]).to eq(0)
      expect(described_class::DEFAULTS[:layers][:border][:y]).to eq(0)
      expect(described_class::DEFAULTS[:layers][:border][:width]).to eq(630)
      expect(described_class::DEFAULTS[:layers][:border][:height]).to eq(880)
    end

    it 'defines art window configuration', :aggregate_failures do
      expect(described_class::DEFAULTS[:layers][:art_layer][:x]).to eq(40)
      expect(described_class::DEFAULTS[:layers][:art_layer][:y]).to eq(95)
      expect(described_class::DEFAULTS[:layers][:art_layer][:width]).to eq(550)
      expect(described_class::DEFAULTS[:layers][:art_layer][:height]).to eq(400)
      expect(described_class::DEFAULTS[:layers][:art_layer][:corner_radius]).to eq({ x: 5, y: 5 })
    end

    it 'defines mask ID and frame stroke width', :aggregate_failures do
      expect(described_class::DEFAULTS[:mask_id]).to eq('artWindowMask')
      expect(described_class::DEFAULTS[:frame_stroke_width]).to eq(2)
    end
  end
end
