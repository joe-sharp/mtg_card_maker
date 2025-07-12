# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::LayerConfig do
  describe '.default' do
    it 'returns a new instance with default configuration', :aggregate_failures do
      config = described_class.default
      expect(config).to be_a(described_class)
      expect(config.config).to eq(described_class::DEFAULT_CONFIG)
    end
  end

  describe '#initialize' do
    it 'uses default configuration when no custom config provided' do
      config = described_class.new
      expect(config.config).to eq(described_class::DEFAULT_CONFIG)
    end

    it 'merges custom configuration with defaults', :aggregate_failures do
      custom_config = {
        font_sizes: { name: 40 },
        padding: { horizontal: 20 }
      }
      config = described_class.new(custom_config)

      expect(config.font_size(:name)).to eq(40)
      expect(config.horizontal_padding).to eq(20)
      expect(config.font_size(:type)).to eq(22) # Should still be default
    end

    it 'deep merges nested configurations', :aggregate_failures do
      custom_config = {
        font_sizes: { name: 40 },
        positioning: {
          name_area: { y_offset: 15 }
        }
      }
      config = described_class.new(custom_config)

      expect(config.font_size(:name)).to eq(40)
      expect(config.positioning(:name_area)[:y_offset]).to eq(15)
      expect(config.positioning(:name_area)[:width_ratio]).to eq(0.75) # Should still be default
    end
  end

  describe '#font_size' do
    it 'returns correct font sizes for different layer types', :aggregate_failures do
      config = described_class.default

      expect(config.font_size(:name)).to eq(32)
      expect(config.font_size(:type)).to eq(22)
      expect(config.font_size(:description)).to eq(24)
      expect(config.font_size(:flavor_text)).to eq(18)
      expect(config.font_size(:power_area)).to eq(28)
      expect(config.font_size(:copyright)).to eq(14)
    end
  end

  describe '#horizontal_padding' do
    it 'returns the horizontal padding value' do
      config = described_class.default
      expect(config.horizontal_padding).to eq(15)
    end
  end

  describe '#vertical_padding' do
    it 'returns the vertical padding value' do
      config = described_class.default
      expect(config.vertical_padding).to eq(30)
    end
  end

  describe '#positioning' do
    it 'returns positioning config for known layer types', :aggregate_failures do
      config = described_class.default

      name_area_pos = config.positioning(:name_area)
      expect(name_area_pos[:y_offset]).to eq(10)
      expect(name_area_pos[:width_ratio]).to eq(0.75)

      flavor_text_pos = config.positioning(:flavor_text)
      expect(flavor_text_pos[:y_offset]).to eq(45)
      expect(flavor_text_pos[:separator_offset]).to eq(70)
    end

    it 'returns empty hash for unknown layer types' do
      config = described_class.default
      expect(config.positioning(:unknown)).to eq({})
    end
  end

  describe '#stroke_width' do
    it 'returns the stroke width value' do
      config = described_class.default
      expect(config.stroke_width).to eq(2)
    end
  end

  describe '#corner_radius' do
    it 'returns corner radius for known layer types', :aggregate_failures do
      config = described_class.default

      name_radius = config.corner_radius(:name)
      expect(name_radius[:x]).to eq(10)
      expect(name_radius[:y]).to eq(25)

      art_radius = config.corner_radius(:art)
      expect(art_radius[:x]).to eq(8)
      expect(art_radius[:y]).to eq(8)
    end

    it 'returns default corner radius for unknown layer types', :aggregate_failures do
      config = described_class.default
      default_radius = config.corner_radius(:unknown)
      expect(default_radius[:x]).to eq(5)
      expect(default_radius[:y]).to eq(5)
    end
  end

  describe '#mana_cost_config' do
    it 'returns the mana cost configuration', :aggregate_failures do
      config = described_class.default
      mana_config = config.mana_cost_config

      expect(mana_config[:circle_radius]).to eq(15)
      expect(mana_config[:circle_spacing]).to eq(35)
      expect(mana_config[:icon_size]).to eq(24)
      expect(mana_config[:max_circles]).to eq(10)
      expect(mana_config[:margin]).to eq(10)
    end
  end

  describe '#copyright_config' do
    it 'returns the copyright configuration', :aggregate_failures do
      config = described_class.default
      copyright_config = config.copyright_config

      expect(copyright_config[:base_y]).to eq(830)
      expect(copyright_config[:line_spacing]).to eq(18)
      expect(copyright_config[:x_position]).to eq(90)
    end
  end

  describe '#text_width' do
    it 'calculates text width without layer type' do
      config = described_class.default
      width = config.text_width(100)
      expect(width).to eq(70) # 100 - (15 * 2)
    end

    it 'calculates text width with layer type width ratio' do
      config = described_class.default
      width = config.text_width(100, :name_area)
      expect(width).to eq(45) # (100 * 0.75) - (15 * 2)
    end
  end

  describe '#text_x_position' do
    it 'calculates text x position with horizontal padding' do
      config = described_class.default
      x_pos = config.text_x_position(50)
      expect(x_pos).to eq(65) # 50 + 15
    end
  end

  describe '#text_y_position' do
    it 'calculates text y position without height' do
      config = described_class.default
      y_pos = config.text_y_position(100, :description)
      expect(y_pos).to eq(130) # 100 + 30
    end

    it 'calculates text y position with height' do
      config = described_class.default
      y_pos = config.text_y_position(100, :name_area, 50)
      expect(y_pos).to eq(135) # 100 + (50/2) + 10
    end

    it 'handles layer types without y_offset' do
      config = described_class.default
      y_pos = config.text_y_position(100, :unknown, 50)
      expect(y_pos).to eq(125) # 100 + (50/2) + 0
    end
  end

  describe '#default_font_size' do
    it 'returns the default font size from text rendering config' do
      config = described_class.default
      expect(config.default_font_size).to eq(16)
    end
  end
end
