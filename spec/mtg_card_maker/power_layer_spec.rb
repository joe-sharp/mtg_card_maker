# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::PowerLayer do
  let(:dimensions) { { x: 0, y: 0, width: 100, height: 100 } }

  it 'inherits from BaseLayer' do
    expect(described_class).to be < MtgCardMaker::BaseLayer
  end

  it 'uses correct default color' do
    layer = described_class.new(
      dimensions: dimensions,
      power: '3',
      toughness: '3'
    )
    expect(layer.color).to eq('#E8E8E8')
  end

  it 'exposes power, toughness, and color_scheme attributes', :aggregate_failures do
    scheme = MtgCardMaker::ColorScheme.new(:colorless)
    layer = described_class.new(
      dimensions: dimensions,
      power: '3',
      toughness: '3',
      color_scheme: scheme
    )
    expect(layer.power).to eq('3')
    expect(layer.toughness).to eq('3')
    expect(layer.color_scheme).to eq(scheme)
  end

  it 'matches expected fixture output' do
    fixture_layer = described_class.new(
      dimensions: { x: 455, y: 790, width: 140, height: 40 },
      power: '9999',
      toughness: '9999'
    )
    expect_svg_to_match_fixture(fixture_layer, 'power_layer')
  end

  describe '#render' do
    let(:layer) { described_class.new(dimensions: dimensions, power: '3', toughness: '3') }

    before do
      allow(Victor::SVG).to receive(:new).and_call_original
      allow(MtgCardMaker::SvgGradientService).to receive(:define_all_gradients)
      allow(MtgCardMaker::SvgGradientService).to receive(:name_gradient_id)
    end

    it 'renders when power and toughness are valid', :aggregate_failures do
      template = MtgCardMaker::Template.new(width: 200, height: 200)
      template.add_layer(layer)

      # Verify the SVG contains the expected elements
      svg_content = template.to_svg
      expect(svg_content).to include('<g>')
      expect(svg_content).to include('<rect')
      expect(svg_content).to include('3/3')
    end

    it 'does not render when power is nil' do
      layer_with_nil_power = described_class.new(dimensions: dimensions, power: nil, toughness: '3')
      template = MtgCardMaker::Template.new(width: 200, height: 200)
      template.add_layer(layer_with_nil_power)

      # Verify no power area elements were added
      svg_content = template.to_svg
      expect(svg_content).not_to include('3/3')
    end

    it 'does not render when toughness is nil' do
      layer_with_nil_toughness = described_class.new(dimensions: dimensions, power: '3', toughness: nil)
      template = MtgCardMaker::Template.new(width: 200, height: 200)
      template.add_layer(layer_with_nil_toughness)

      # Verify no power area elements were added
      svg_content = template.to_svg
      expect(svg_content).not_to include('3/3')
    end

    it 'does not render when power is empty string' do
      layer_with_empty_power = described_class.new(dimensions: dimensions, power: '', toughness: '3')
      template = MtgCardMaker::Template.new(width: 200, height: 200)
      template.add_layer(layer_with_empty_power)

      # Should not render any text element
      svg_content = template.to_svg
      expect(svg_content).not_to include('<text')
    end

    it 'does not render when toughness is empty string' do
      layer_with_empty_toughness = described_class.new(dimensions: dimensions, power: '3', toughness: '')
      template = MtgCardMaker::Template.new(width: 200, height: 200)
      template.add_layer(layer_with_empty_toughness)

      # Should not render any text element
      svg_content = template.to_svg
      expect(svg_content).not_to include('<text')
    end

    it 'does not render when power is whitespace only' do
      layer_with_whitespace_power = described_class.new(dimensions: dimensions, power: '   ', toughness: '3')
      template = MtgCardMaker::Template.new(width: 200, height: 200)
      template.add_layer(layer_with_whitespace_power)

      # Should not render any text element
      svg_content = template.to_svg
      expect(svg_content).not_to include('<text')
    end

    it 'does not render when toughness is whitespace only' do
      layer_with_whitespace_toughness = described_class.new(dimensions: dimensions, power: '3', toughness: '   ')
      template = MtgCardMaker::Template.new(width: 200, height: 200)
      template.add_layer(layer_with_whitespace_toughness)

      # Should not render any text element
      svg_content = template.to_svg
      expect(svg_content).not_to include('<text')
    end

    it 'renders when power and toughness are valid strings with whitespace', :aggregate_failures do
      layer_with_whitespace = described_class.new(dimensions: dimensions, power: ' 3 ', toughness: ' 3 ')
      template = MtgCardMaker::Template.new(width: 200, height: 200)
      template.add_layer(layer_with_whitespace)

      # Should render the text with whitespace preserved
      svg_content = template.to_svg
      expect(svg_content).to include('<text')
      expect(svg_content).to include(' 3 / 3 ')
    end

    context 'with different color schemes' do
      it 'renders with colorless color scheme', :aggregate_failures do
        colorless_layer = described_class.new(
          dimensions: dimensions,
          power: '5',
          toughness: '5',
          color_scheme: MtgCardMaker::ColorScheme.new(:colorless)
        )
        template = MtgCardMaker::Template.new(width: 200, height: 200)
        template.add_layer(colorless_layer)

        svg_content = template.to_svg
        expect(svg_content).to include('<text')
        expect(svg_content).to include('5/5')
      end

      it 'renders with gold color scheme', :aggregate_failures do
        gold_layer = described_class.new(
          dimensions: dimensions,
          power: '7',
          toughness: '7',
          color_scheme: MtgCardMaker::ColorScheme.new(:gold)
        )
        template = MtgCardMaker::Template.new(width: 200, height: 200)
        template.add_layer(gold_layer)

        svg_content = template.to_svg
        expect(svg_content).to include('<text')
        expect(svg_content).to include('7/7')
      end
    end
  end

  describe 'dynamic sizing behavior' do
    let(:base_dimensions) { { x: 455, y: 790, width: 140, height: 40 } }

    context 'with single digit power/toughness' do
      it 'calculates correct width for 0/0', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '0', toughness: '0')
        expect(layer.send(:dynamic_width)).to eq(60) # Base width for 3 characters
        expect(layer.send(:x_position)).to eq(535) # 595 - 60
      end

      it 'calculates correct width for 1/1', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '1', toughness: '1')
        expect(layer.send(:dynamic_width)).to eq(60) # Base width for 3 characters
        expect(layer.send(:x_position)).to eq(535) # 595 - 60
      end

      it 'calculates correct width for 9/9', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '9', toughness: '9')
        expect(layer.send(:dynamic_width)).to eq(60) # Base width for 3 characters
        expect(layer.send(:x_position)).to eq(535) # 595 - 60
      end
    end

    context 'with double digit power/toughness' do
      it 'calculates correct width for 10/10', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '10', toughness: '10')
        expect(layer.send(:dynamic_width)).to eq(86) # 60 + (5-3)*13
        expect(layer.send(:x_position)).to eq(509) # 595 - 86
      end

      it 'calculates correct width for 99/99', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '99', toughness: '99')
        expect(layer.send(:dynamic_width)).to eq(86) # 60 + (5-3)*13
        expect(layer.send(:x_position)).to eq(509) # 595 - 86
      end
    end

    context 'with triple digit power/toughness' do
      it 'calculates correct width for 100/100', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '100', toughness: '100')
        expect(layer.send(:dynamic_width)).to eq(112) # 60 + (7-3)*13
        expect(layer.send(:x_position)).to eq(483) # 595 - 112
      end

      it 'calculates correct width for 999/999', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '999', toughness: '999')
        expect(layer.send(:dynamic_width)).to eq(112) # 60 + (7-3)*13
        expect(layer.send(:x_position)).to eq(483) # 595 - 112
      end
    end

    context 'with large power/toughness values' do
      it 'calculates correct width for 9999/9999', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '9999', toughness: '9999')
        expect(layer.send(:dynamic_width)).to eq(138) # 60 + (9-3)*13
        expect(layer.send(:x_position)).to eq(457) # 595 - 138
      end

      it 'calculates correct width for 99999/99999', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '99999', toughness: '99999')
        expect(layer.send(:dynamic_width)).to eq(164) # 60 + (11-3)*13
        expect(layer.send(:x_position)).to eq(431) # 595 - 164
      end
    end

    context 'with mixed digit lengths' do
      it 'calculates correct width for 1/99', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '1', toughness: '99')
        expect(layer.send(:dynamic_width)).to eq(73) # 60 + (4-3)*13
        expect(layer.send(:x_position)).to eq(522) # 595 - 73
      end

      it 'calculates correct width for 99/1', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '99', toughness: '1')
        expect(layer.send(:dynamic_width)).to eq(73) # 60 + (4-3)*13
        expect(layer.send(:x_position)).to eq(522) # 595 - 73
      end

      it 'calculates correct width for 1/999', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '1', toughness: '999')
        expect(layer.send(:dynamic_width)).to eq(86) # 60 + (5-3)*13
        expect(layer.send(:x_position)).to eq(509) # 595 - 86
      end
    end

    context 'with edge cases' do
      it 'handles numeric power and toughness', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: 5, toughness: 5)
        expect(layer.send(:dynamic_width)).to eq(60) # Base width for 3 characters
        expect(layer.send(:x_position)).to eq(535) # 595 - 60
      end

      it 'handles zero values', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: 0, toughness: 0)
        expect(layer.send(:dynamic_width)).to eq(60) # Base width for 3 characters
        expect(layer.send(:x_position)).to eq(535) # 595 - 60
      end

      it 'handles very large numeric values', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: 12_345, toughness: 67_890)
        expect(layer.send(:dynamic_width)).to eq(164) # 60 + (10-3)*13
        expect(layer.send(:x_position)).to eq(431) # 595 - 164
      end
    end
  end

  describe 'rendering with dynamic sizing' do
    let(:base_dimensions) { { x: 455, y: 790, width: 140, height: 40 } }

    context 'with different character counts' do
      it 'renders small power area correctly', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '0', toughness: '0')
        template = MtgCardMaker::Template.new(width: 630, height: 880)
        template.add_layer(layer)

        svg_content = template.to_svg
        expect(svg_content).to include('<rect')
        expect(svg_content).to include('0/0')
        expect(svg_content).to include('width="60"')
      end

      it 'renders medium power area correctly', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '99', toughness: '99')
        template = MtgCardMaker::Template.new(width: 630, height: 880)
        template.add_layer(layer)

        svg_content = template.to_svg
        expect(svg_content).to include('<rect')
        expect(svg_content).to include('99/99')
        expect(svg_content).to include('width="86"')
      end

      it 'renders large power area correctly', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '9999', toughness: '9999')
        template = MtgCardMaker::Template.new(width: 630, height: 880)
        template.add_layer(layer)

        svg_content = template.to_svg
        expect(svg_content).to include('<rect')
        expect(svg_content).to include('9999/9999')
        expect(svg_content).to include('width="138"')
      end
    end

    context 'with positioning verification' do
      it 'maintains right-aligned positioning for small area', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '1', toughness: '1')
        template = MtgCardMaker::Template.new(width: 630, height: 880)
        template.add_layer(layer)

        svg_content = template.to_svg
        # Should be positioned at x="535" (595 - 60)
        expect(svg_content).to include('x="535"')
      end

      it 'maintains right-aligned positioning for large area', :aggregate_failures do
        layer = described_class.new(dimensions: base_dimensions, power: '99999', toughness: '99999')
        template = MtgCardMaker::Template.new(width: 630, height: 880)
        template.add_layer(layer)

        svg_content = template.to_svg
        # Should be positioned at x="431" (595 - 164)
        expect(svg_content).to include('x="431"')
      end
    end
  end
end
