# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::TextRenderingService do
  describe '.wrapped_text_lines' do
    it 'wraps text correctly', :aggregate_failures do
      layer_config = MtgCardMaker::LayerConfig.default
      text_service = described_class.new(
        text: 'This is a long text that should wrap',
        layer_config: layer_config,
        x: 10,
        y: 20,
        font_size: 12,
        available_width: 50
      )
      result = text_service.wrapped_text_lines
      expect(result.length).to be > 1
      expect(result.first[0]).to eq('This is a')
      expect(result.first[1][:x]).to eq(10)
      expect(result.first[1][:y]).to eq(20)
    end

    it 'handles single line text', :aggregate_failures do
      layer_config = MtgCardMaker::LayerConfig.default
      text_service = described_class.new(
        text: 'Short text',
        layer_config: layer_config,
        x: 10,
        y: 20,
        font_size: 12,
        available_width: 100
      )
      result = text_service.wrapped_text_lines
      expect(result.length).to eq(1)
      expect(result.first[0]).to eq('Short text')
    end

    it 'applies custom styling options', :aggregate_failures do
      layer_config = MtgCardMaker::LayerConfig.default
      text_service = described_class.new(
        text: 'Styled Text',
        layer_config: layer_config,
        x: 15,
        y: 25,
        font_size: 14,
        color: '#FF0000'
      )
      result = text_service.wrapped_text_lines
      _, attrs = result.first
      expect(attrs[:x]).to eq(15)
      expect(attrs[:y]).to eq(25)
      expect(attrs[:font_size]).to eq(14)
      expect(attrs[:fill]).to eq('#FF0000')
    end

    it 'uses default styling when not specified', :aggregate_failures do
      layer_config = MtgCardMaker::LayerConfig.default
      text_service = described_class.new(
        text: 'Default Text',
        layer_config: layer_config,
        x: 10,
        y: 20,
        font_size: 12,
        available_width: 100
      )
      result = text_service.wrapped_text_lines
      _, attrs = result.first
      expect(attrs[:fill]).to eq(layer_config.default_text_color)
      expect(attrs[:class]).to be_nil
    end

    it 'applies CSS class when provided', :aggregate_failures do
      layer_config = MtgCardMaker::LayerConfig.default
      text_service = described_class.new(
        text: 'CSS Text',
        layer_config: layer_config,
        x: 10,
        y: 20,
        font_size: 12,
        available_width: 100,
        css_class: 'card-name'
      )
      result = text_service.wrapped_text_lines
      _, attrs = result.first
      expect(attrs[:class]).to eq('card-name')
    end

    it 'handles empty text gracefully', :aggregate_failures do
      layer_config = MtgCardMaker::LayerConfig.default
      text_service = described_class.new(
        text: '',
        layer_config: layer_config,
        x: 10,
        y: 20,
        font_size: 12,
        available_width: 100
      )
      result = text_service.wrapped_text_lines
      expect(result).to be_empty
    end

    it 'handles text with empty lines from consecutive newlines', :aggregate_failures do
      layer_config = MtgCardMaker::LayerConfig.default
      text_with_empty_lines = "Line 1\n\n\nLine 2"
      text_service = described_class.new(
        text: text_with_empty_lines,
        layer_config: layer_config,
        x: 10,
        y: 20,
        font_size: 12,
        available_width: 100
      )
      result = text_service.wrapped_text_lines
      expect(result.length).to eq(2)
      expect(result[0][0]).to eq('Line 1')
      expect(result[1][0]).to eq('Line 2')
    end

    it 'handles single word that does not wrap', :aggregate_failures do
      layer_config = MtgCardMaker::LayerConfig.default
      very_long_word = 'Supercalifragilisticexpialidocious'
      text_service = described_class.new(
        text: very_long_word,
        layer_config: layer_config,
        x: 10,
        y: 20,
        font_size: 12,
        available_width: 50
      )
      result = text_service.wrapped_text_lines
      expect(result.length).to eq(1)
      expect(result.first[0]).to eq(very_long_word)
    end

    it 'handles rendering without a block', :aggregate_failures do
      layer_config = MtgCardMaker::LayerConfig.default
      text_service = described_class.new(
        text: 'Test text',
        layer_config: layer_config,
        x: 10,
        y: 20,
        font_size: 12,
        available_width: 100
      )
      result = text_service.wrapped_text_lines
      expect(result).to be_an(Array)
      expect(result.first).to be_an(Array)
      expect(result.first.length).to eq(2)
    end

    it 'calculates line heights correctly', :aggregate_failures do
      layer_config = MtgCardMaker::LayerConfig.default
      text_service = described_class.new(
        text: "Line 1\nLine 2",
        layer_config: layer_config,
        x: 10,
        y: 20,
        font_size: 12,
        line_height: 20
      )
      result = text_service.wrapped_text_lines
      expect(result.length).to eq(2)
      expect(result[0][1][:y]).to eq(20)
      expect(result[1][1][:y]).to eq(40) # 20 + 20
    end

    it 'uses default line height when not specified', :aggregate_failures do
      layer_config = MtgCardMaker::LayerConfig.default
      text_service = described_class.new(
        text: "Line 1\nLine 2",
        layer_config: layer_config,
        x: 10,
        y: 20,
        font_size: 12
      )
      result = text_service.wrapped_text_lines
      expect(result.length).to eq(2)
      expected_line_height = 12 * layer_config.default_line_height_multiplier
      expect(result[0][1][:y]).to eq(20)
      expect(result[1][1][:y]).to eq(20 + expected_line_height.to_i)
    end

    it 'uses default line height if not provided' do
      layer_config = MtgCardMaker::LayerConfig.default
      service = described_class.new(text: 'foo', layer_config: layer_config)
      expect(service.line_height).to eq(service.font_size * layer_config.default_line_height_multiplier)
    end

    it 'class method wrapped_text_lines works' do
      layer_config = MtgCardMaker::LayerConfig.default
      result = described_class.wrapped_text_lines(
        text: 'test',
        layer_config: layer_config,
        x: 10,
        y: 20,
        font_size: 12
      )
      expect(result).to be_an(Array)
    end
  end
end
