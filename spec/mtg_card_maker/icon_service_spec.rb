# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::IconService do
  let(:service) { described_class.new }

  describe '#initialize' do
    it 'creates an instance with default icon set' do
      expect(service.icon_set).to eq(:default)
    end

    it 'creates an instance with custom icon set' do
      custom_service = described_class.new(:custom)
      expect(custom_service.icon_set).to eq(:custom)
    end
  end

  describe '#symbol_svg' do
    it 'returns SVG content for basic mana symbols', :aggregate_failures do
      svg = service.symbol_svg('{W}', size: 24)
      expect(svg).to be_a(String)
      expect(svg).to include('<svg')
      expect(svg).to include('width="24px"')
      expect(svg).to include('height="24px"')
    end

    it 'returns SVG content for numeric symbols', :aggregate_failures do
      svg = service.symbol_svg('{5}', size: 24)
      expect(svg).to be_a(String)
      expect(svg).to include('<svg')
      expect(svg).to include('>5<')
      expect(svg).to include('width="24px"')
      expect(svg).to include('height="24px"')
    end

    it 'returns SVG content for double digit numeric symbols', :aggregate_failures do
      svg = service.symbol_svg('{42}', size: 24)
      expect(svg).to be_a(String)
      expect(svg).to include('<svg')
      expect(svg).to include('>42<')
      expect(svg).to include('width="24px"')
      expect(svg).to include('height="24px"')
    end

    it 'returns SVG content for hybrid symbols', :aggregate_failures do
      svg = service.symbol_svg('{W/B}', size: 24)
      expect(svg).to be_a(String)
      expect(svg).to include('<svg')
      expect(svg).to include('width="24px"')
      expect(svg).to include('height="24px"')
    end

    it 'returns SVG content for phyrexian symbols', :aggregate_failures do
      svg = service.symbol_svg('{W/P}', size: 24)
      expect(svg).to be_a(String)
      expect(svg).to include('<svg')
      expect(svg).to include('width="24px"')
      expect(svg).to include('height="24px"')
    end

    it 'returns SVG content for phyrexian hybrid symbols', :aggregate_failures do
      svg = service.symbol_svg('{W/B/P}', size: 24)
      expect(svg).to be_a(String)
      expect(svg).to include('<svg')
      expect(svg).to include('width="24px"')
      expect(svg).to include('height="24px"')
    end

    it 'returns SVG content for twobrid symbols', :aggregate_failures do
      svg = service.symbol_svg('{2/W}', size: 24)
      expect(svg).to be_a(String)
      expect(svg).to include('<svg')
      expect(svg).to include('width="24px"')
      expect(svg).to include('height="24px"')
    end

    it 'returns SVG content for special symbols', :aggregate_failures do
      svg = service.symbol_svg('{X}', size: 24)
      expect(svg).to be_a(String)
      expect(svg).to include('<svg')
      expect(svg).to include('width="24px"')
      expect(svg).to include('height="24px"')
    end

    it 'returns nil for invalid symbol strings' do
      svg = service.symbol_svg('{INVALID}')
      expect(svg).to be_nil
    end

    it 'returns nil for non-string inputs' do
      svg = service.symbol_svg(123)
      expect(svg).to be_nil
    end

    it 'resizes SVG to specified size', :aggregate_failures do
      svg = service.symbol_svg('{U}', size: 48)
      expect(svg).to include('width="48px"')
      expect(svg).to include('height="48px"')
    end
  end

  describe '#available_icon_types' do
    it 'returns available icon types for default icon set', :aggregate_failures do
      types = service.available_icon_types
      expect(types).to be_an(Array)
      expect(types).to include(:white, :black, :red, :green, :blue, :colorless)
    end
  end

  describe '#available_icon_sets' do
    it 'returns available icon sets', :aggregate_failures do
      sets = service.available_icon_sets
      expect(sets).to be_an(Array)
      expect(sets).to include(:default)
    end
  end

  describe '#qr_code_svg' do
    it 'returns QR code SVG content', :aggregate_failures do
      svg = service.qr_code_svg
      expect(svg).to be_a(String)
      expect(svg).to include('<svg')
    end
  end

  describe '#jsharp_svg' do
    it 'returns jsharp icon SVG content', :aggregate_failures do
      svg = service.jsharp_svg
      expect(svg).to be_a(String)
      expect(svg).to include('<svg')
    end
  end

  describe 'caching behavior' do
    it 'caches loaded icons' do
      # First call should load from file
      svg1 = service.symbol_svg('{R}', size: 24)

      # Second call should use cached version
      svg2 = service.symbol_svg('{R}', size: 24)

      expect(svg1).to eq(svg2)
    end
  end
end
