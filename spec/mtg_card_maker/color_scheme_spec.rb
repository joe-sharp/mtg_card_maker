# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::ColorScheme do
  describe 'colorless scheme' do
    subject(:colorless) { described_class.new(:colorless) }

    describe 'frame gradient colors' do
      it 'returns correct frame gradient colors', :aggregate_failures do
        expect(colorless.frame_gradient_start).to eq('#8B8B8B')
        expect(colorless.frame_gradient_middle).to eq('#6B6B6B')
        expect(colorless.frame_gradient_end).to eq('#4A4A4A')
      end
    end

    describe 'name gradient colors' do
      it 'returns correct name gradient colors', :aggregate_failures do
        expect(colorless.name_gradient_start).to eq('#F5F5F5')
        expect(colorless.name_gradient_middle).to eq('#E8E8E8')
        expect(colorless.name_gradient_end).to eq('#D4D4D4')
      end
    end

    describe 'description gradient colors' do
      it 'returns correct description gradient colors', :aggregate_failures do
        expect(colorless.description_gradient_start).to eq('#F5F5F5')
        expect(colorless.description_gradient_middle).to eq('#E8E8E8')
        expect(colorless.description_gradient_end).to eq('#D4D4D4')
      end
    end

    describe 'card gradient colors' do
      it 'returns correct card gradient colors', :aggregate_failures do
        expect(colorless.card_gradient_start).to eq('#3D3D3D')
        expect(colorless.card_gradient_middle).to eq('#111')
        expect(colorless.card_gradient_end).to eq('#1A1A1A')
      end
    end

    describe 'primary colors' do
      it 'returns correct primary colors', :aggregate_failures do
        expect(colorless.primary_color).to eq('#8B8B8B')
        expect(colorless.background_color).to eq('#E8E8E8')
        expect(colorless.border_color).to eq('#8B8B8B')
        expect(colorless.text_color).to eq('#111')
      end
    end
  end

  describe 'white scheme' do
    subject(:white) { described_class.new(:white) }

    describe 'frame gradient colors' do
      it 'returns correct frame gradient colors', :aggregate_failures do
        expect(white.frame_gradient_start).to eq('#FFF9C4')
        expect(white.frame_gradient_middle).to eq('#F5F5F5')
        expect(white.frame_gradient_end).to eq('#BDB76B')
      end
    end

    describe 'primary colors' do
      it 'returns correct primary colors', :aggregate_failures do
        expect(white.primary_color).to eq('#8B8B8B')
        expect(white.background_color).to eq('#FFFFFF')
        expect(white.border_color).to eq('#F5F5F5')
        expect(white.text_color).to eq('#111')
      end
    end
  end

  describe 'blue scheme' do
    subject(:blue) { described_class.new(:blue) }

    describe 'frame gradient colors' do
      it 'returns correct frame gradient colors', :aggregate_failures do
        expect(blue.frame_gradient_start).to eq('#42A5F5')
        expect(blue.frame_gradient_middle).to eq('#1565C0')
        expect(blue.frame_gradient_end).to eq('#263238')
      end
    end

    describe 'primary colors' do
      it 'returns correct primary colors', :aggregate_failures do
        expect(blue.primary_color).to eq('#42A5F5')
        expect(blue.background_color).to eq('#E3F2FD')
        expect(blue.border_color).to eq('#1565C0')
        expect(blue.text_color).to eq('#111')
      end
    end
  end

  describe 'black scheme' do
    subject(:black) { described_class.new(:black) }

    describe 'frame gradient colors' do
      it 'returns correct frame gradient colors', :aggregate_failures do
        expect(black.frame_gradient_start).to eq('#424242')
        expect(black.frame_gradient_middle).to eq('#212121')
        expect(black.frame_gradient_end).to eq('#000')
      end
    end

    describe 'primary colors' do
      it 'returns correct primary colors', :aggregate_failures do
        expect(black.primary_color).to eq('#424242')
        expect(black.background_color).to eq('#E0E0E0')
        expect(black.border_color).to eq('#212121')
        expect(black.text_color).to eq('#111')
      end
    end
  end

  describe 'red scheme' do
    subject(:red) { described_class.new(:red) }

    describe 'frame gradient colors' do
      it 'returns correct frame gradient colors', :aggregate_failures do
        expect(red.frame_gradient_start).to eq('#F44336')
        expect(red.frame_gradient_middle).to eq('#D32F2F')
        expect(red.frame_gradient_end).to eq('#B71C1C')
      end
    end

    describe 'primary colors' do
      it 'returns correct primary colors', :aggregate_failures do
        expect(red.primary_color).to eq('#F44336')
        expect(red.background_color).to eq('#FFEBEE')
        expect(red.border_color).to eq('#D32F2F')
        expect(red.text_color).to eq('#111')
      end
    end
  end

  describe 'green scheme' do
    subject(:green) { described_class.new(:green) }

    describe 'frame gradient colors' do
      it 'returns correct frame gradient colors', :aggregate_failures do
        expect(green.frame_gradient_start).to eq('#4CAF50')
        expect(green.frame_gradient_middle).to eq('#388E3C')
        expect(green.frame_gradient_end).to eq('#2E7D32')
      end
    end

    describe 'primary colors' do
      it 'returns correct primary colors', :aggregate_failures do
        expect(green.primary_color).to eq('#4CAF50')
        expect(green.background_color).to eq('#E8F5E8')
        expect(green.border_color).to eq('#388E3C')
        expect(green.text_color).to eq('#111')
      end
    end
  end

  describe 'gold scheme' do
    subject(:gold) { described_class.new(:gold) }

    describe 'frame gradient colors' do
      it 'returns correct frame gradient colors', :aggregate_failures do
        expect(gold.frame_gradient_start).to eq('#FFD700')
        expect(gold.frame_gradient_middle).to eq('#FFA500')
        expect(gold.frame_gradient_end).to eq('#FF8C00')
      end
    end

    describe 'primary colors' do
      it 'returns correct primary colors', :aggregate_failures do
        expect(gold.primary_color).to eq('#FFD700')
        expect(gold.background_color).to eq('#FFF8DC')
        expect(gold.border_color).to eq('#FFA500')
        expect(gold.text_color).to eq('#111')
      end
    end

    describe 'name gradient colors' do
      it 'returns correct name gradient colors', :aggregate_failures do
        expect(gold.name_gradient_start).to eq('#F5DEB3')
        expect(gold.name_gradient_middle).to eq('#E1C16E')
        expect(gold.name_gradient_end).to eq('#C9A13B')
      end
    end

    describe 'metallic properties' do
      it 'returns correct metallic highlight colors', :aggregate_failures do
        expect(gold.metallic_highlight_start).to eq('#FFFF99')
        expect(gold.metallic_highlight_middle).to eq('#FFD700')
        expect(gold.metallic_highlight_end).to eq('#FFA500')
      end

      it 'returns correct metallic shadow colors', :aggregate_failures do
        expect(gold.metallic_shadow_start).to eq('#B8860B')
        expect(gold.metallic_shadow_middle).to eq('#8B6914')
        expect(gold.metallic_shadow_end).to eq('#654321')
      end

      it 'returns correct metallic pattern colors', :aggregate_failures do
        expect(gold.metallic_pattern_light).to eq('#FFFACD')
        expect(gold.metallic_pattern_dark).to eq('#DAA520')
      end

      it 'returns nil for missing metallic keys', :aggregate_failures do
        scheme = described_class.new(:artifact) # artifact has no metallic keys
        expect(scheme.metallic_highlight_start).to be_nil
        expect(scheme.metallic_highlight_middle).to be_nil
        expect(scheme.metallic_highlight_end).to be_nil
        expect(scheme.metallic_shadow_start).to be_nil
        expect(scheme.metallic_shadow_middle).to be_nil
        expect(scheme.metallic_shadow_end).to be_nil
        expect(scheme.metallic_pattern_light).to be_nil
        expect(scheme.metallic_pattern_dark).to be_nil
      end
    end
  end

  describe 'artifact scheme' do
    subject(:artifact) { described_class.new(:artifact) }

    describe 'frame gradient colors' do
      it 'returns correct frame gradient colors', :aggregate_failures do
        expect(artifact.frame_gradient_start).to eq('#D2B48C')
        expect(artifact.frame_gradient_middle).to eq('#BC8F8F')
        expect(artifact.frame_gradient_end).to eq('#A0522D')
      end
    end

    describe 'primary colors' do
      it 'returns correct primary colors', :aggregate_failures do
        expect(artifact.primary_color).to eq('#D2B48C')
        expect(artifact.background_color).to eq('#F5F5DC')
        expect(artifact.border_color).to eq('#BC8F8F')
        expect(artifact.text_color).to eq('#111')
      end
    end
  end

  describe 'convenience methods' do
    it 'provides class methods for each color scheme', :aggregate_failures do
      expect(described_class.colorless).to be_a(described_class)
      expect(described_class.white).to be_a(described_class)
      expect(described_class.blue).to be_a(described_class)
      expect(described_class.black).to be_a(described_class)
      expect(described_class.red).to be_a(described_class)
      expect(described_class.green).to be_a(described_class)
      expect(described_class.gold).to be_a(described_class)
      expect(described_class.artifact).to be_a(described_class)
    end

    it 'creates correct schemes via convenience methods', :aggregate_failures do
      expect(described_class.colorless.scheme_name).to eq(:colorless)
      expect(described_class.white.scheme_name).to eq(:white)
      expect(described_class.blue.scheme_name).to eq(:blue)
      expect(described_class.black.scheme_name).to eq(:black)
      expect(described_class.red.scheme_name).to eq(:red)
      expect(described_class.green.scheme_name).to eq(:green)
      expect(described_class.gold.scheme_name).to eq(:gold)
      expect(described_class.artifact.scheme_name).to eq(:artifact)
    end
  end

  describe 'gradient color methods' do
    subject(:colorless) { described_class.new(:colorless) }

    it 'returns correct gradient color arrays', :aggregate_failures do
      expect(colorless.frame_gradient_colors).to eq(['#8B8B8B', '#6B6B6B', '#4A4A4A'])
      expect(colorless.name_gradient_colors).to eq(['#F5F5F5', '#E8E8E8', '#D4D4D4'])
      expect(colorless.description_gradient_colors).to eq(['#F5F5F5', '#E8E8E8', '#D4D4D4'])
      expect(colorless.card_gradient_colors).to eq(['#3D3D3D', '#111', '#1A1A1A'])
    end

    it 'returns correct gradient colors for other schemes', :aggregate_failures do
      white = described_class.new(:white)
      expect(white.frame_gradient_colors).to eq(['#FFF9C4', '#F5F5F5', '#BDB76B'])
      expect(white.name_gradient_colors).to eq(['#FFFFFF', '#FFF9C4', '#E0E0E0'])
      expect(white.description_gradient_colors).to eq(['#FFFFFF', '#F5F5F5', '#E0E0E0'])
      expect(white.card_gradient_colors).to eq(['#D7CCC8', '#BCAAA4', '#8D6E63'])
    end
  end

  describe 'fallback behavior' do
    it 'falls back to colorless for unknown schemes', :aggregate_failures do
      unknown = described_class.new(:unknown)
      expect(unknown.scheme_name).to eq(:unknown)
      expect(unknown.primary_color).to eq('#8B8B8B') # colorless primary
    end

    it 'handles nil metallic properties gracefully', :aggregate_failures do
      # Create a scheme without metallic properties
      scheme = described_class.new(:artifact)
      expect(scheme.metallic_highlight_start).to be_nil
      expect(scheme.metallic_highlight_middle).to be_nil
      expect(scheme.metallic_highlight_end).to be_nil
      expect(scheme.metallic_shadow_start).to be_nil
      expect(scheme.metallic_shadow_middle).to be_nil
      expect(scheme.metallic_shadow_end).to be_nil
      expect(scheme.metallic_pattern_light).to be_nil
      expect(scheme.metallic_pattern_dark).to be_nil
    end
  end
end
