# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::IconService do
  let(:icon_service) { described_class.new }

  describe '#initialize' do
    it 'creates an instance with default icon set' do
      expect(icon_service.icon_set).to eq(:default)
    end

    it 'creates an instance with custom icon set' do
      custom_service = described_class.new(:custom)
      expect(custom_service.icon_set).to eq(:custom)
    end
  end

  describe '#available_colors' do
    it 'returns available colors for default icon set' do
      expected_colors = %i[white blue black red green colorless]
      expect(icon_service.available_colors).to match_array(expected_colors)
    end

    it 'returns an empty array for a non-existent icon set' do
      service = described_class.new(:nonexistent)
      expect(service.available_colors).to eq([])
    end
  end

  describe '#available_icon_sets' do
    it 'returns available icon sets' do
      expect(icon_service.available_icon_sets).to include(:default)
    end
  end

  describe '#icon_svg' do
    it 'returns SVG content for white mana', :aggregate_failures do
      svg = icon_service.icon_svg(:white)
      expect(svg).to include('<svg')
      expect(svg).to include('width="30px"')
      expect(svg).to include('height="30px"')
    end

    it 'returns SVG content for blue mana', :aggregate_failures do
      svg = icon_service.icon_svg(:blue)
      expect(svg).to include('<svg')
      expect(svg).to include('width="30px"')
    end

    it 'returns SVG content for colorless mana', :aggregate_failures do
      svg = icon_service.icon_svg(:colorless)
      expect(svg).to include('<svg')
      expect(svg).to include('width="30px"')
    end

    it 'returns nil for invalid color' do
      expect(icon_service.icon_svg(:invalid)).to be_nil
    end

    it 'resizes SVG to custom size', :aggregate_failures do
      svg = icon_service.icon_svg(:white, size: 50)
      expect(svg).to include('width="50px"')
      expect(svg).to include('height="50px"')
    end

    it 'caches loaded icons' do
      # First call should load from file
      allow(File).to receive(:read).and_return('<svg></svg>')

      icon_service.icon_svg(:white)
      icon_service.icon_svg(:white) # Second call should use cache

      expect(File).to have_received(:read).once
    end

    it 'returns nil if the icon file does not exist' do
      allow(File).to receive(:exist?).and_return(false)
      expect(icon_service.icon_svg(:white)).to be_nil
    end
  end

  describe '#qr_code_svg' do
    it 'returns nil if the QR code SVG file does not exist' do
      allow(File).to receive(:exist?).with(MtgCardMaker::IconService::QR_CODE_PATH).and_return(false)
      expect(icon_service.qr_code_svg).to be_nil
    end
  end

  describe '#jsharp_svg' do
    it 'returns nil if the jsharp SVG file does not exist' do
      allow(File).to receive(:exist?).with(MtgCardMaker::IconService::JSHARP_PATH).and_return(false)
      expect(icon_service.jsharp_svg).to be_nil
    end
  end

  describe 'icon file existence' do
    it 'has all required icon files for default set' do
      icon_service.available_colors.each do |color|
        icon_path = File.join(described_class::ICONS_DIR, described_class::ICON_SETS[:default][color])
        expect(File.exist?(icon_path)).to be true
      end
    end
  end
end
