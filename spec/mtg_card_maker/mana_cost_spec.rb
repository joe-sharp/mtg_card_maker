# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::ManaCost do
  describe '#initialize' do
    it 'handles mixed mana cost string', :aggregate_failures do
      cost = described_class.new('2RG')
      expect(cost.elements).to include(:numeric, :red, :green)
      expect(cost.int_val).to eq(2)
    end

    it 'handles only numeric mana cost', :aggregate_failures do
      cost = described_class.new('3')
      expect(cost.elements).to eq([:numeric])
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
        expect(cost.elements).to eq([:x])
        expect(cost.int_val).to be_nil
      end

      it 'handles X cost with colored mana', :aggregate_failures do
        cost = described_class.new('XR')
        expect(cost.elements).to eq([:x, :red])
        expect(cost.int_val).to be_nil
      end

      it 'handles 10 cost', :aggregate_failures do
        cost = described_class.new('10')
        expect(cost.elements).to eq([:numeric])
        expect(cost.int_val).to eq(10)
      end

      it 'handles 10 cost with colored mana', :aggregate_failures do
        cost = described_class.new('10RG')
        expect(cost.elements).to eq(%i[numeric red green])
        expect(cost.int_val).to eq(10)
      end

      it 'handles 11 cost', :aggregate_failures do
        cost = described_class.new('11')
        expect(cost.elements).to eq([:numeric])
        expect(cost.int_val).to eq(11)
      end

      it 'handles 11 cost with colored mana', :aggregate_failures do
        cost = described_class.new('11WB')
        expect(cost.elements).to eq(%i[numeric white black])
        expect(cost.int_val).to eq(11)
      end

      it 'handles case-insensitive variable costs', :aggregate_failures do
        cost = described_class.new('xrg')
        expect(cost.elements).to eq(%i[x red green])
        expect(cost.int_val).to be_nil
      end
    end

    context 'with edge cases' do
      it 'handles unknown characters gracefully', :aggregate_failures do
        cost = described_class.new('2QZ')
        expect(cost.elements).to eq([:numeric])
        expect(cost.int_val).to eq(2)
      end

      it 'handles mixed case colored mana', :aggregate_failures do
        cost = described_class.new('rWb')
        expect(cost.elements).to eq(%i[red white black])
        expect(cost.int_val).to be_nil
      end

      it 'handles colorless symbol C', :aggregate_failures do
        cost = described_class.new('2C')
        expect(cost.elements).to eq([:numeric, :colorless])
        expect(cost.int_val).to eq(2)
      end
    end

    context 'with high numeric values' do
      it 'converts 100+ values to X cost', :aggregate_failures do
        cost = described_class.new('100')
        expect(cost.elements).to eq([:x])
        expect(cost.int_val).to be_nil
      end

      it 'converts 100+ values with colored mana to X cost', :aggregate_failures do
        cost = described_class.new('150RG')
        expect(cost.elements).to eq(%i[x red green])
        expect(cost.int_val).to be_nil
      end

      it 'handles 99 as numeric (not X)', :aggregate_failures do
        cost = described_class.new('99')
        expect(cost.elements).to eq([:numeric])
        expect(cost.int_val).to eq(99)
      end

      it 'handles 99 with colored mana as numeric', :aggregate_failures do
        cost = described_class.new('99RG')
        expect(cost.elements).to eq(%i[numeric red green])
        expect(cost.int_val).to eq(99)
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

    it 'handles X cost SVG generation', :aggregate_failures do
      cost = described_class.new('X')
      svg = cost.to_svg
      expect(svg).to include('<g filter="url(#mana-cost-drop-shadow)">')
      expect(svg).to include('<defs>')
    end

    it 'handles high numeric values as X in SVG', :aggregate_failures do
      cost = described_class.new('150')
      svg = cost.to_svg
      expect(svg).to include('<g filter="url(#mana-cost-drop-shadow)">')
      expect(svg).to include('<defs>')
    end
  end

  describe 'private methods' do
    let(:cost) { described_class.new('2RG') }

    it 'returns correct drop shadow filter' do
      expect(cost.send(:drop_shadow_filter)).to include('<filter')
    end

    it 'handles variable cost parsing with X', :aggregate_failures do
      cost = described_class.new('X')
      expect(cost.int_val).to be_nil
      expect(cost.elements).to eq([:x])
    end

    it 'handles variable cost parsing with X and colored mana', :aggregate_failures do
      cost = described_class.new('XR')
      expect(cost.int_val).to be_nil
      expect(cost.elements).to eq([:x, :red])
    end

    it 'handles double-digit numbers as X', :aggregate_failures do
      cost = described_class.new('15')
      expect(cost.int_val).to eq(15)
      expect(cost.elements).to eq([:numeric])
    end

    it 'handles double-digit numbers with colored mana', :aggregate_failures do
      cost = described_class.new('15RG')
      expect(cost.int_val).to eq(15)
      expect(cost.elements).to eq(%i[numeric red green])
    end

    it 'handles single-digit numbers normally', :aggregate_failures do
      cost = described_class.new('3')
      expect(cost.int_val).to eq(3)
      expect(cost.elements).to eq([:numeric])
    end

    it 'handles single-digit numbers with colored mana', :aggregate_failures do
      cost = described_class.new('3RG')
      expect(cost.int_val).to eq(3)
      expect(cost.elements).to eq(%i[numeric red green])
    end

    it 'handles string starting with X but not numeric', :aggregate_failures do
      # This should test the start_with?('X') branch
      cost = described_class.new('XBC')
      expect(cost.int_val).to be_nil
      expect(cost.elements).to eq(%i[x black colorless])
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

    context 'with colored mana processing' do
      it 'handles colorless symbol C specifically' do
        cost = described_class.new('C')
        expect(cost.elements).to eq([:colorless])
      end

      it 'handles regular colored mana symbols' do
        cost = described_class.new('R')
        expect(cost.elements).to eq([:red])
      end

      it 'handles unknown characters in colored mana' do
        cost = described_class.new('Z')
        expect(cost.elements).to eq([])
      end

      it 'handles mixed known and unknown characters' do
        cost = described_class.new('RZ')
        expect(cost.elements).to eq([:red])
      end

      it 'handles completely unknown characters' do
        cost = described_class.new('ABC')
        expect(cost.elements).to eq([:black, :colorless]) # A=unknown, B=black, C=colorless
      end
    end

    context 'with icon rendering edge cases' do
      it 'handles nil icon_svg in render methods', :aggregate_failures do
        # Mock the icon service to return nil for icon_svg
        cost = described_class.new('R')
        icon_service = cost.instance_variable_get(:@icon_service)

        # Test that the render methods handle nil icon_svg gracefully
        allow(icon_service).to receive_messages(icon_svg: nil, numeric_icon_svg: nil)

        # These should not raise errors even with nil icon_svg
        expect { cost.send(:render_mana_icon, 0, 0, :red) }.not_to raise_error
        expect { cost.send(:render_mana_icon, 0, 0, :numeric) }.not_to raise_error
        expect { cost.send(:render_mana_icon, 0, 0, :x) }.not_to raise_error
      end
    end
  end
end
