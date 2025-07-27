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

  describe '#initialize' do
    it 'handles nil art parameter' do
      layer = described_class.new(
        dimensions: { x: 0, y: 0, width: 100, height: 100 },
        art: nil
      )
      expect(layer.art).to be_nil
    end

    it 'handles empty string art parameter' do
      layer = described_class.new(
        dimensions: { x: 0, y: 0, width: 100, height: 100 },
        art: ''
      )
      expect(layer.art).to be_nil
    end

    it 'parses valid image URL' do
      valid_url = 'https://example.com/image.jpg'
      layer = described_class.new(
        dimensions: { x: 0, y: 0, width: 100, height: 100 },
        art: valid_url
      )
      expect(layer.art).to eq(valid_url)
    end

    it 'raises ArgumentError for invalid URL', :aggregate_failures do
      expect do
        described_class.new(
          dimensions: { x: 0, y: 0, width: 100, height: 100 },
          art: 'invalid://url:with:colons'
        )
      end.to raise_error(ArgumentError, /Invalid image URL/)
    end
  end

  describe '#render' do
    it 'renders without image when art is nil', :aggregate_failures do
      layer = described_class.new(
        dimensions: { x: 0, y: 0, width: 100, height: 100 },
        art: nil
      )
      result = generate_svg_for_layer(layer)
      expect(result).to include('<rect')
      expect(result).not_to include('<image')
    end

    it 'renders with image when art is provided', :aggregate_failures do
      layer = described_class.new(
        dimensions: { x: 0, y: 0, width: 100, height: 100 },
        art: 'https://example.com/image.jpg'
      )
      result = generate_svg_for_layer(layer)
      expect(result).to include('<rect')
      expect(result).to include('<image')
      expect(result).to include('href="https://example.com/image.jpg"')
    end
  end
end
