# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::FrameLayer do
  let(:dimensions) { { x: 0, y: 0, width: 100, height: 100 } }

  it 'inherits from BaseLayer' do
    expect(described_class).to be < MtgCardMaker::BaseLayer
  end

  it 'uses correct default color' do
    layer = described_class.new(dimensions: dimensions)
    expect(layer.color).to eq('#8B8B8B')
  end

  it 'exposes color_scheme and mask_id', :aggregate_failures do
    scheme = instance_double(MtgCardMaker::ColorScheme,
                             primary_color:            '#123',
                             metallic_highlight_start: nil,
                             metallic_shadow_start:    nil,
                             metallic_pattern_light:   nil)
    layer = described_class.new(dimensions: dimensions, color_scheme: scheme, mask_id: 'customMask')
    expect(layer.color_scheme).to eq(scheme)
    expect(layer.mask_id).to eq('customMask')
  end

  it 'matches expected fixture output' do
    fixture_layer = described_class.new(
      dimensions: { x: 10, y: 10, width: 610, height: 860 },
      color: '#8B7355'
    )
    expect_svg_to_match_fixture(fixture_layer, 'frame_layer')
  end

  describe '#render' do
    let(:svg) { double('SVG') }
    let(:scheme) { MtgCardMaker::ColorScheme.new(:colorless) }

    it 'calls render_standard_frame for non-gold color_scheme' do
      layer = described_class.new(dimensions: dimensions, color_scheme: scheme)
      allow(MtgCardMaker::SvgGradientService).to receive(:define_all_gradients)
      allow(layer).to receive(:render_standard_frame)
      layer.render
      expect(layer).to have_received(:render_standard_frame)
    end

    it 'calls render_metallic_elements for gold color_scheme', :aggregate_failures do
      gold = MtgCardMaker::ColorScheme.new(:gold)
      layer = described_class.new(dimensions: dimensions, color_scheme: gold)
      allow(MtgCardMaker::SvgGradientService).to receive(:define_all_gradients)
      allow(layer).to receive(:render_metallic_elements).and_call_original
      # Set up template so svg is not nil
      template = MtgCardMaker::Template.new(width: 100, height: 100)
      layer.template = template
      expect { layer.render }.not_to raise_error
      expect(layer).to have_received(:render_metallic_elements)
    end
  end

  describe 'private rendering methods' do
    let(:svg) { double('SVG') }
    let(:scheme) { MtgCardMaker::ColorScheme.new(:colorless) }
    let(:layer) { described_class.new(dimensions: dimensions, color_scheme: scheme) }

    it 'renders standard frame without error' do
      allow(svg).to receive(:rect)
      template = MtgCardMaker::Template.new(width: 100, height: 100)
      layer.template = template
      expect { layer.send(:render_standard_frame) }.not_to raise_error
    end

    it 'renders metallic frame without error' do
      gold = MtgCardMaker::ColorScheme.new(:gold)
      metallic_layer = described_class.new(dimensions: dimensions, color_scheme: gold)
      template = MtgCardMaker::Template.new(width: 100, height: 100)
      metallic_layer.template = template
      expect do
        metallic_layer.send(
          :render_metallic_elements,
          mask: metallic_layer.mask_id,
          bottom_margin: 120,
          opacity: { texture: 0.3, shadow: 0.4 }
        )
      end.not_to raise_error
    end
  end
end
