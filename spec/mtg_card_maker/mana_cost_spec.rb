# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::ManaCost do
  describe '#initialize' do
    it 'handles mixed mana cost string', :aggregate_failures do
      cost = described_class.new('2RG')
      expect(cost.elements).to include(:colorless, :red, :green)
      expect(cost.int_val).to eq(2)
    end

    it 'handles only numeric mana cost', :aggregate_failures do
      cost = described_class.new('3')
      expect(cost.elements).to eq([:colorless])
      expect(cost.int_val).to eq(3)
    end

    it 'handles only colored mana cost', :aggregate_failures do
      cost = described_class.new('RW')
      expect(cost.elements).to eq([:red, :white])
      expect(cost.int_val).to be_nil
    end

    it 'handles nil or empty mana cost', :aggregate_failures do
      cost = described_class.new
      expect(cost.elements).to eq([])
      expect(cost.int_val).to be_nil

      cost = described_class.new('')
      expect(cost.elements).to eq([])
      expect(cost.int_val).to be_nil
    end

    it 'caps elements at max_circles from config' do
      cost = described_class.new('1RRRRRRRRRR')
      layer_config = MtgCardMaker::LayerConfig.default
      max_circles = layer_config.mana_cost_config[:max_circles]
      expect(cost.elements.size).to eq(max_circles)
    end

    it 'initializes with custom icon_set' do
      cost = described_class.new('R', :custom)
      expect(cost.elements).to eq([:red])
      # The icon_set parameter is used internally by IconService
    end

    context 'with variable costs' do
      it 'handles X cost', :aggregate_failures do
        cost = described_class.new('X')
        expect(cost.elements).to eq([:colorless])
        expect(cost.int_val).to eq(10)
      end

      it 'handles X cost with colored mana', :aggregate_failures do
        cost = described_class.new('XR')
        expect(cost.elements).to eq([:colorless, :red])
        expect(cost.int_val).to eq(10)
      end

      it 'handles 10 cost', :aggregate_failures do
        cost = described_class.new('10')
        expect(cost.elements).to eq([:colorless])
        expect(cost.int_val).to eq(10)
      end

      it 'handles 10 cost with colored mana', :aggregate_failures do
        cost = described_class.new('10RG')
        expect(cost.elements).to eq(%i[colorless red green])
        expect(cost.int_val).to eq(10)
      end

      it 'handles 11 cost', :aggregate_failures do
        cost = described_class.new('11')
        expect(cost.elements).to eq([:colorless])
        expect(cost.int_val).to eq(10)
      end

      it 'handles 11 cost with colored mana', :aggregate_failures do
        cost = described_class.new('11WB')
        expect(cost.elements).to eq(%i[colorless white black])
        expect(cost.int_val).to eq(10)
      end

      it 'handles case-insensitive variable costs', :aggregate_failures do
        cost = described_class.new('xrg')
        expect(cost.elements).to eq(%i[colorless red green])
        expect(cost.int_val).to eq(10)
      end
    end

    context 'with edge cases' do
      it 'handles unknown characters gracefully', :aggregate_failures do
        cost = described_class.new('2QZ')
        expect(cost.elements).to eq([:colorless])
        expect(cost.int_val).to eq(2)
      end

      it 'handles mixed case colored mana', :aggregate_failures do
        cost = described_class.new('rWb')
        expect(cost.elements).to eq(%i[red white black])
        expect(cost.int_val).to be_nil
      end

      it 'handles colorless symbol C', :aggregate_failures do
        cost = described_class.new('2C')
        expect(cost.elements).to eq([:colorless, :colorless])
        expect(cost.int_val).to eq(2)
      end
    end
  end

  describe '#to_svg' do
    it 'generates SVG with correct number of elements', :aggregate_failures do
      cost = described_class.new('2RG')
      svg = cost.to_svg
      expect(svg.scan('<circle').size).to eq(cost.elements.size)
      expect(svg).to include('filter="url(#mana-cost-drop-shadow)"')
    end

    it 'uses icons for colored mana and circles for colorless', :aggregate_failures do
      cost = described_class.new('RW2')
      svg = cost.to_svg
      expect(svg.scan('<circle').size).to eq(2) # Matches fixture/output
      expect(svg.scan('<svg').size).to eq(2) # Two icons for colored mana
    end

    it 'uses circles for colorless mana', :aggregate_failures do
      cost = described_class.new('2C')
      svg = cost.to_svg
      expect(svg.scan('<circle').size).to eq(2)
    end

    it 'handles empty mana string gracefully' do
      cost = described_class.new('')
      expect(cost.to_svg).to include('<g filter="url(#mana-cost-drop-shadow)">')
    end
  end

  describe 'private methods' do
    let(:cost) { described_class.new('2RG') }

    it 'returns correct drop shadow filter' do
      expect(cost.send(:drop_shadow_filter)).to include('<filter')
    end

    it 'returns correct svg_color for all colors', :aggregate_failures do
      expect(cost.send(:svg_color, :white)).to eq('#FFF9C4')
      expect(cost.send(:svg_color, :blue)).to eq('#90CAF9')
      expect(cost.send(:svg_color, :black)).to eq('#BDBDBD')
      expect(cost.send(:svg_color, :red)).to eq('#EF9A9A')
      expect(cost.send(:svg_color, :green)).to eq('#A5D6A7')
      expect(cost.send(:svg_color, :colorless)).to eq('#DDD')
      expect(cost.send(:svg_color, :unknown)).to eq('#DDD')
    end

    it 'renders colorless circle with int_val < 10' do
      cost = described_class.new('3')
      svg = cost.send(:mana_element_svg, 0, 0, :colorless, :numeric)
      expect(svg).to include('3</text>')
    end

    it 'renders colorless circle with int_val >= 10' do
      cost = described_class.new('12')
      svg = cost.send(:mana_element_svg, 0, 0, :colorless, :numeric)
      expect(svg).to include('X</text>')
    end

    it 'renders colorless symbol C', :aggregate_failures do
      cost = described_class.new('C')
      svg = cost.send(:mana_element_svg, 0, 0, :colorless, :C)
      expect(svg).to include('<svg')
      expect(svg).to include('opacity=\'0.7\'')
    end

    it 'renders empty text for unknown origin' do
      cost = described_class.new('R')
      svg = cost.send(:mana_element_svg, 0, 0, :colorless, :unknown)
      expect(svg).not_to include('</text>')
    end

    it 'renders empty text when int_val is nil' do
      cost = described_class.new('R')
      svg = cost.send(:mana_element_svg, 0, 0, :colorless, :numeric)
      expect(svg).not_to include('</text>')
    end

    it 'renders colored mana with icon inside circle', :aggregate_failures do
      cost = described_class.new('R')
      svg = cost.send(:mana_element_svg, 0, 0, :red, :red)
      expect(svg).to include('<circle')
      expect(svg).to include('<svg')
    end

    it 'handles parse_mana_string with nil' do
      expect { cost.send(:parse_mana_string, nil) }.not_to raise_error
    end

    it 'handles text_svg with X' do
      result = cost.send(:text_svg, 0, 0, 'X')
      expect(result).to include('font-weight=\'normal\'')
    end

    it 'handles text_svg with number' do
      result = cost.send(:text_svg, 0, 0, '5')
      expect(result).to include('font-weight=\'semibold\'')
    end

    it 'handles mana_element_svg with nil icon_svg', :aggregate_failures do
      # Mock the icon_service to return nil for icon_svg
      icon_service = instance_double(MtgCardMaker::IconService)
      allow(MtgCardMaker::IconService).to receive(:new).and_return(icon_service)
      allow(icon_service).to receive(:icon_svg).and_return(nil)
      cost = described_class.new('R')
      svg = cost.send(:mana_element_svg, 0, 0, :red, :red)
      expect(svg).to include('<circle')
      expect(svg).not_to include('<svg') # No icon should be added
    end

    it 'handles mana_element_svg with specific color returning nil icon', :aggregate_failures do
      # Mock the icon_service to return nil for a specific color
      icon_service = instance_double(MtgCardMaker::IconService)
      allow(MtgCardMaker::IconService).to receive(:new).and_return(icon_service)
      allow(icon_service).to receive(:icon_svg).with(:blue, size: 24).and_return(nil)
      allow(icon_service).to receive(:icon_svg).with(:red, size: 24).and_return('<svg>red</svg>')

      cost = described_class.new('B')
      svg = cost.send(:mana_element_svg, 0, 0, :blue, :blue)
      expect(svg).to include('<circle')
      expect(svg).not_to include('<svg') # No icon should be added for blue
    end

    it 'handles mana_element_svg with unknown color', :aggregate_failures do
      cost = described_class.new('R')
      svg = cost.send(:mana_element_svg, 0, 0, :unknown, :unknown)
      expect(svg).to include('<circle')
      expect(svg).to include('fill=\'#DDD\'') # Should use default color
    end

    it 'handles colorless_text with unknown origin' do
      cost = described_class.new('R')
      result = cost.send(:colorless_text, 0, 0, :unknown)
      expect(result).to eq('')
    end

    it 'handles colorless_text with numeric origin but nil int_val' do
      cost = described_class.new('R')
      result = cost.send(:colorless_text, 0, 0, :numeric)
      expect(result).to eq('')
    end

    it 'handles variable cost parsing with X', :aggregate_failures do
      cost = described_class.new('X')
      expect(cost.int_val).to eq(10)
      expect(cost.elements).to eq([:colorless])
    end

    it 'handles variable cost parsing with X and colored mana', :aggregate_failures do
      cost = described_class.new('XR')
      expect(cost.int_val).to eq(10)
      expect(cost.elements).to eq([:colorless, :red])
    end

    it 'handles double-digit numbers as X', :aggregate_failures do
      cost = described_class.new('15')
      expect(cost.int_val).to eq(10)
      expect(cost.elements).to eq([:colorless])
    end

    it 'handles double-digit numbers with colored mana', :aggregate_failures do
      cost = described_class.new('15RG')
      expect(cost.int_val).to eq(10)
      expect(cost.elements).to eq(%i[colorless red green])
    end

    it 'handles single-digit numbers normally', :aggregate_failures do
      cost = described_class.new('3')
      expect(cost.int_val).to eq(3)
      expect(cost.elements).to eq([:colorless])
    end

    it 'handles single-digit numbers with colored mana', :aggregate_failures do
      cost = described_class.new('3RG')
      expect(cost.int_val).to eq(3)
      expect(cost.elements).to eq(%i[colorless red green])
    end

    it 'handles string starting with X but not numeric', :aggregate_failures do
      # This should test the start_with?('X') branch
      cost = described_class.new('XBC')
      expect(cost.int_val).to eq(10)
      expect(cost.elements).to eq(%i[colorless black colorless])
    end

    it 'handles string that does not start with digit or X', :aggregate_failures do
      # This should test the else branch in parse_mana_string
      cost = described_class.new('ABC')
      expect(cost.int_val).to be_nil
      expect(cost.elements).to eq([:black, :colorless]) # A=black, B=black, C=colorless
    end

    it 'handles string with unknown characters', :aggregate_failures do
      cost = described_class.new('YZ')
      expect(cost.int_val).to be_nil
      expect(cost.elements).to eq([])
    end
  end
end
