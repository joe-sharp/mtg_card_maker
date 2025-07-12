# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::ColorPalette do
  let(:default_palette) do
    {
      primary_color: '#FF0000',
      background_color: '#00FF00',
      border_color: '#0000FF',
      frame_stroke_color: '#333333',
      accent_color: '#FFFF00'
    }
  end
  let(:palette) { described_class.new(**default_palette) }

  describe 'constants' do
    it 'defines FRAME_STROKE_COLOR' do
      expect(described_class::FRAME_STROKE_COLOR).to eq('#111')
    end
  end

  describe '#initialize' do
    it 'uses default values when no colors provided', :aggregate_failures do
      palette = described_class.new
      expect(palette.primary_color).to eq(MtgCardMaker::DEFAULT_COLOR_SCHEME.primary_color)
      expect(palette.background_color).to eq(MtgCardMaker::DEFAULT_COLOR_SCHEME.background_color)
      expect(palette.border_color).to eq(MtgCardMaker::DEFAULT_COLOR_SCHEME.border_color)
      expect(palette.frame_stroke_color).to eq('#111')
      expect(palette.accent_color).to eq(MtgCardMaker::DEFAULT_COLOR_SCHEME.primary_color)
    end

    it 'uses provided colors when specified', :aggregate_failures do
      palette = described_class.new(**default_palette)
      expect(palette.primary_color).to eq('#FF0000')
      expect(palette.background_color).to eq('#00FF00')
      expect(palette.border_color).to eq('#0000FF')
      expect(palette.frame_stroke_color).to eq('#333333')
      expect(palette.accent_color).to eq('#FFFF00')
    end
  end

  describe '.from_color_scheme' do
    it 'creates a palette from a color scheme', :aggregate_failures do
      color_scheme = MtgCardMaker::DEFAULT_COLOR_SCHEME
      palette = described_class.from_color_scheme(color_scheme)

      expect(palette.primary_color).to eq(color_scheme.primary_color)
      expect(palette.background_color).to eq(color_scheme.background_color)
      expect(palette.border_color).to eq(color_scheme.border_color)
      expect(palette.frame_stroke_color).to eq('#111')
      expect(palette.accent_color).to eq(color_scheme.primary_color)
    end
  end

  describe '.default' do
    it 'creates a default palette', :aggregate_failures do
      palette = described_class.default
      expect(palette.primary_color).to eq(MtgCardMaker::DEFAULT_COLOR_SCHEME.primary_color)
      expect(palette.background_color).to eq(MtgCardMaker::DEFAULT_COLOR_SCHEME.background_color)
      expect(palette.border_color).to eq(MtgCardMaker::DEFAULT_COLOR_SCHEME.border_color)
      expect(palette.frame_stroke_color).to eq('#111')
      expect(palette.accent_color).to eq(MtgCardMaker::DEFAULT_COLOR_SCHEME.primary_color)
    end
  end

  describe '.dark' do
    it 'creates a dark theme palette', :aggregate_failures do
      palette = described_class.dark
      expect(palette.primary_color).to eq('#2A2A2A')
      expect(palette.background_color).to eq('#1A1A1A')
      expect(palette.border_color).to eq('#4A4A4A')
      expect(palette.frame_stroke_color).to eq('#333')
      expect(palette.accent_color).to eq('#6B6B6B')
    end
  end

  describe '.light' do
    it 'creates a light theme palette', :aggregate_failures do
      palette = described_class.light
      expect(palette.primary_color).to eq('#E8E8E8')
      expect(palette.background_color).to eq('#F5F5F5')
      expect(palette.border_color).to eq('#D4D4D4')
      expect(palette.frame_stroke_color).to eq('#666')
      expect(palette.accent_color).to eq('#8B8B8B')
    end
  end

  describe '#to_h' do
    it 'returns colors as a hash', :aggregate_failures do
      expected = {
        primary_color: '#FF0000',
        background_color: '#00FF00',
        border_color: '#0000FF',
        frame_stroke_color: '#333333',
        accent_color: '#FFFF00'
      }

      expect(palette.to_h).to eq(expected)
    end
  end

  describe '#to_a' do
    it 'returns colors as an array', :aggregate_failures do
      expected = ['#FF0000', '#00FF00', '#0000FF', '#333333', '#FFFF00']
      expect(palette.to_a).to eq(expected)
    end
  end

  describe '#==' do
    it 'returns true for identical palettes', :aggregate_failures do
      palette2 = described_class.new(**default_palette)

      expect(palette).to eq(palette2)
    end

    it 'returns false for different palettes' do
      palette1 = described_class.new(primary_color: '#FF0000')
      palette2 = described_class.new(primary_color: '#00FF00')

      expect(palette1).not_to eq(palette2)
    end

    it 'returns false for non-palette objects' do
      palette = described_class.new
      expect(palette).not_to eq('not a palette')
    end
  end

  describe '#hash' do
    it 'generates consistent hash for identical palettes' do
      palette2 = described_class.new(**default_palette)

      expect(palette.hash).to eq(palette2.hash)
    end
  end
end
