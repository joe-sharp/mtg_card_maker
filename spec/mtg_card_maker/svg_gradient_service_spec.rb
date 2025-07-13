# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::SvgGradientService do
  let(:svg) { double('SVG') }
  let(:colorless_scheme) { MtgCardMaker::ColorScheme.new(:colorless) }
  let(:gold_scheme) { MtgCardMaker::ColorScheme.new(:gold) }

  describe '.define_all_gradients' do
    it 'defines all expected gradients in SVG defs section' do
      template = MtgCardMaker::Template.new(width: 100, height: 100)

      # Create a mock SVG object to capture the gradient definitions
      allow_any_instance_of(Victor::SVG).to receive(:defs) do |&block|
        # Capture the block execution by creating a mock context
        mock_svg = double('svg')
        allow(mock_svg).to receive(:linearGradient).and_yield
        allow(mock_svg).to receive(:stop)

        block.call if block_given?
      end

      # Test that the service can be called without error
      expect { described_class.define_all_gradients(template.instance_variable_get(:@svg)) }.not_to raise_error
    end

    it 'generates SVG with gradient definitions when used in a layer', :aggregate_failures do
      # Test integration by using it through FrameLayer
      layer = MtgCardMaker::FrameLayer.new(
        dimensions: { x: 10, y: 10, width: 100, height: 100 }
      )

      svg_content = generate_svg_for_layer(layer, canvas_width: 200, canvas_height: 200)

      # Verify that all expected gradients are present
      expect(svg_content).to include('id="colorless_card_gradient"')
      expect(svg_content).to include('id="colorless_frame_gradient"')
      expect(svg_content).to include('id="colorless_name_gradient"')

      # Verify gradient structure
      expect(svg_content).to include('<linearGradient')
      expect(svg_content).to include('<stop')
      expect(svg_content).to include('stop-color')
    end

    it 'defines metallic gradients for gold color scheme', :aggregate_failures do
      allow(svg).to receive(:defs).and_yield
      allow(svg).to receive(:linearGradient).and_yield
      allow(svg).to receive(:radialGradient).and_yield
      allow(svg).to receive(:pattern).and_yield
      allow(svg).to receive(:stop)
      allow(svg).to receive(:line)
      allow(svg).to receive(:circle)

      expect { described_class.define_all_gradients(svg, gold_scheme) }.not_to raise_error
    end

    it 'does not define metallic gradients for non-gold, non-colorless color scheme', :aggregate_failures do
      non_metallic_scheme = MtgCardMaker::ColorScheme.new(:white)
      allow(svg).to receive(:defs).and_yield
      allow(svg).to receive(:linearGradient).and_yield
      allow(svg).to receive(:stop)
      allow(svg).to receive(:radialGradient)
      allow(svg).to receive(:pattern)

      # Should not raise error and should not call metallic methods
      described_class.define_all_gradients(svg, non_metallic_scheme)
      expect(svg).not_to have_received(:radialGradient)
      expect(svg).not_to have_received(:pattern)
    end

    it 'defines metallic gradients for colorless color scheme', :aggregate_failures do
      allow(svg).to receive(:defs).and_yield
      allow(svg).to receive(:linearGradient).and_yield
      allow(svg).to receive(:radialGradient).and_yield
      allow(svg).to receive(:pattern).and_yield
      allow(svg).to receive(:stop)
      allow(svg).to receive(:line)
      allow(svg).to receive(:circle)

      expect { described_class.define_all_gradients(svg, colorless_scheme) }.not_to raise_error
    end
  end

  describe 'gradient ID methods' do
    it 'returns correct gradient IDs for colorless scheme', :aggregate_failures do
      expect(described_class.card_gradient_id(colorless_scheme)).to eq('colorless_card_gradient')
      expect(described_class.frame_gradient_id(colorless_scheme)).to eq('colorless_frame_gradient')
      expect(described_class.name_gradient_id(colorless_scheme)).to eq('colorless_name_gradient')
      expect(described_class.text_box_gradient_id(colorless_scheme)).to eq('colorless_text_box_gradient')
    end

    it 'returns correct gradient IDs for gold scheme', :aggregate_failures do
      expect(described_class.card_gradient_id(gold_scheme)).to eq('gold_card_gradient')
      expect(described_class.frame_gradient_id(gold_scheme)).to eq('gold_frame_gradient')
      expect(described_class.name_gradient_id(gold_scheme)).to eq('gold_name_gradient')
      expect(described_class.text_box_gradient_id(gold_scheme)).to eq('gold_text_box_gradient')
    end

    it 'returns correct metallic gradient IDs for gold scheme', :aggregate_failures do
      expect(described_class.metallic_highlight_gradient_id(gold_scheme)).to eq('gold_metallic_highlight_gradient')
      expect(described_class.metallic_shadow_gradient_id(gold_scheme)).to eq('gold_metallic_shadow_gradient')
      expect(described_class.metallic_pattern_id(gold_scheme)).to eq('gold_metallic_pattern')
    end
  end

  describe 'private gradient definition methods' do
    before do
      allow(svg).to receive(:linearGradient).and_yield
      allow(svg).to receive(:radialGradient).and_yield
      allow(svg).to receive(:pattern).and_yield
      allow(svg).to receive(:stop)
      allow(svg).to receive(:line)
      allow(svg).to receive(:circle)
    end

    it 'defines standard gradients without error' do
      expect { described_class.send(:define_standard_gradients, svg, colorless_scheme) }.not_to raise_error
    end

    it 'defines metallic gradients without error' do
      expect { described_class.send(:define_metallic_gradients, svg, gold_scheme) }.not_to raise_error
    end
  end
end
