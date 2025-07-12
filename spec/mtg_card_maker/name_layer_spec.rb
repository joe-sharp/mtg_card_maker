# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::NameLayer do
  let(:dimensions) { { x: 0, y: 0, width: 100, height: 100 } }

  it 'inherits from BaseLayer' do
    expect(described_class).to be < MtgCardMaker::BaseLayer
  end

  it 'uses correct default color' do
    layer = described_class.new(
      dimensions: dimensions,
      name: 'Test Card',
      cost: '1R'
    )
    expect(layer.color).to eq('#E8E8E8')
  end

  it 'exposes name, cost, and color_scheme attributes', :aggregate_failures do
    cost = '1R'
    scheme = MtgCardMaker::ColorScheme.new(:colorless)
    layer = described_class.new(
      dimensions: dimensions,
      name: 'Test Card',
      cost: cost,
      color_scheme: scheme
    )
    expect(layer.name).to eq('Test Card')
    expect(layer.cost).to eq(cost)
    expect(layer.color_scheme).to eq(scheme)
  end

  it 'matches expected fixture output' do
    fixture_layer = described_class.new(
      dimensions: { x: 30, y: 40, width: 570, height: 50 },
      name: 'MTG Card Maker',
      cost: '10RRGU'
    )
    expect_svg_to_match_fixture(fixture_layer, 'name_layer')
  end

  describe '#render' do
    let(:svg) { double('SVG') }
    let(:layer) { described_class.new(dimensions: dimensions, name: 'Test', cost: '1R') }

    before do
      allow(svg).to receive(:g).and_yield
      allow(svg).to receive(:rect)
      allow(svg).to receive(:transform)
      allow(svg).to receive(:<<)
      allow(MtgCardMaker::SvgGradientService).to receive(:define_all_gradients)
      allow(MtgCardMaker::SvgGradientService).to receive(:name_gradient_id)
      allow(MtgCardMaker::TextRenderingService).to receive(:render_wrapped_text)
      allow(MtgCardMaker::ManaCost).to receive(:new).and_return(
        instance_double(MtgCardMaker::ManaCost,
                        to_svg: '<circle/>',
                        elements: [:colorless, :red])
      )
    end

    it 'renders with cost when cost is present' do
      allow(layer).to receive(:render_mana_cost)
      template = MtgCardMaker::Template.new(width: 100, height: 100)
      layer.template = template
      layer.render
      expect(layer).to have_received(:render_mana_cost)
    end

    it 'does not render cost when cost is nil' do
      layer_without_cost = described_class.new(dimensions: dimensions, name: 'Test', cost: nil)
      allow(layer_without_cost).to receive(:render_mana_cost)
      template = MtgCardMaker::Template.new(width: 100, height: 100)
      layer_without_cost.template = template
      layer_without_cost.render
      expect(layer_without_cost).not_to have_received(:render_mana_cost)
    end

    it 'does not render cost when cost is empty string' do
      layer_without_cost = described_class.new(dimensions: dimensions, name: 'Test', cost: '')
      allow(layer_without_cost).to receive(:render_mana_cost)
      template = MtgCardMaker::Template.new(width: 100, height: 100)
      layer_without_cost.template = template
      layer_without_cost.render
      expect(layer_without_cost).not_to have_received(:render_mana_cost)
    end
  end
end
