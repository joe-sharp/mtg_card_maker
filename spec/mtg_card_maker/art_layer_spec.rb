# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::ArtLayer do
  it 'inherits from BaseLayer' do
    expect(described_class).to be < MtgCardMaker::BaseLayer
  end

  it 'uses correct default color' do
    layer = described_class.new(dimensions: { x: 0, y: 0, width: 100, height: 100 })
    expect(layer.color).to eq('#000')
  end

  it 'matches expected fixture output' do
    fixture_layer = described_class.new(
      dimensions: { x: 40, y: 95, width: 550, height: 400 }
    )
    expect_svg_to_match_fixture(fixture_layer, 'art_layer')
  end
end
