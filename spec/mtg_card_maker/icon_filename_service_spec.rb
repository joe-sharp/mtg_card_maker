# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::IconFilenameService do
  let(:service) { described_class.new }

  describe '#symbol_to_icon_type' do
    context 'with basic mana colors' do
      it 'maps basic colors correctly', :aggregate_failures do
        expect(service.symbol_to_icon_type('{W}')).to eq(:white)
        expect(service.symbol_to_icon_type('{B}')).to eq(:black)
        expect(service.symbol_to_icon_type('{R}')).to eq(:red)
        expect(service.symbol_to_icon_type('{G}')).to eq(:green)
        expect(service.symbol_to_icon_type('{U}')).to eq(:blue)
        expect(service.symbol_to_icon_type('{C}')).to eq(:colorless)
      end
    end

    context 'with special symbols' do
      it 'maps special symbols correctly', :aggregate_failures do
        expect(service.symbol_to_icon_type('{S}')).to eq(:snow)
        expect(service.symbol_to_icon_type('{X}')).to eq(:x)
        expect(service.symbol_to_icon_type('{T}')).to eq(:tap)
        expect(service.symbol_to_icon_type('{Q}')).to eq(:untap)
        expect(service.symbol_to_icon_type('{E}')).to eq(:energy)
      end
    end

    context 'with numeric symbols' do
      it 'maps single digit numbers to numeric' do
        (0..9).each do |num|
          expect(service.symbol_to_icon_type("{#{num}}")).to eq(:numeric)
        end
      end

      it 'maps double digit numbers to numeric', :aggregate_failures do
        expect(service.symbol_to_icon_type('{10}')).to eq(:numeric)
        expect(service.symbol_to_icon_type('{25}')).to eq(:numeric)
        expect(service.symbol_to_icon_type('{99}')).to eq(:numeric)
      end

      it 'returns nil for numbers 100+', :aggregate_failures do
        expect(service.symbol_to_icon_type('{100}')).to be_nil
        expect(service.symbol_to_icon_type('{999}')).to be_nil
      end
    end

    context 'with phyrexian symbols' do
      it 'maps phyrexian mana symbols correctly', :aggregate_failures do
        expect(service.symbol_to_icon_type('{W/P}')).to eq(:'phyrexian-white')
        expect(service.symbol_to_icon_type('{B/P}')).to eq(:'phyrexian-black')
        expect(service.symbol_to_icon_type('{R/P}')).to eq(:'phyrexian-red')
        expect(service.symbol_to_icon_type('{G/P}')).to eq(:'phyrexian-green')
        expect(service.symbol_to_icon_type('{U/P}')).to eq(:'phyrexian-blue')
        expect(service.symbol_to_icon_type('{C/P}')).to eq(:'phyrexian-colorless')
      end
    end

    context 'with hybrid symbols' do
      it 'maps two-color hybrid symbols correctly', :aggregate_failures do
        expect(service.symbol_to_icon_type('{W/B}')).to eq(:'hybrid-white-black')
        expect(service.symbol_to_icon_type('{B/W}')).to eq(:'hybrid-black-white')
        expect(service.symbol_to_icon_type('{U/R}')).to eq(:'hybrid-blue-red')
        expect(service.symbol_to_icon_type('{R/U}')).to eq(:'hybrid-red-blue')
        expect(service.symbol_to_icon_type('{G/C}')).to eq(:'hybrid-green-colorless')
        expect(service.symbol_to_icon_type('{C/G}')).to eq(:'hybrid-colorless-green')
      end
    end

    context 'with twobrid symbols' do
      it 'maps 2/hybrid symbols correctly', :aggregate_failures do
        expect(service.symbol_to_icon_type('{2/W}')).to eq(:'hybrid-2-white')
        expect(service.symbol_to_icon_type('{2/B}')).to eq(:'hybrid-2-black')
        expect(service.symbol_to_icon_type('{2/R}')).to eq(:'hybrid-2-red')
        expect(service.symbol_to_icon_type('{2/G}')).to eq(:'hybrid-2-green')
        expect(service.symbol_to_icon_type('{2/U}')).to eq(:'hybrid-2-blue')
        expect(service.symbol_to_icon_type('{2/C}')).to eq(:'hybrid-2-colorless')
      end
    end

    context 'with phyrexian hybrid symbols' do
      it 'maps phyrexian hybrid symbols correctly', :aggregate_failures do
        expect(service.symbol_to_icon_type('{W/B/P}')).to eq(:'phyrexian-white-black')
        expect(service.symbol_to_icon_type('{B/W/P}')).to eq(:'phyrexian-black-white')
        expect(service.symbol_to_icon_type('{U/R/P}')).to eq(:'phyrexian-blue-red')
        expect(service.symbol_to_icon_type('{R/U/P}')).to eq(:'phyrexian-red-blue')
        expect(service.symbol_to_icon_type('{G/C/P}')).to eq(:'phyrexian-green-colorless')
        expect(service.symbol_to_icon_type('{C/G/P}')).to eq(:'phyrexian-colorless-green')
      end
    end

    context 'with invalid symbols' do
      it 'returns nil for unknown symbols', :aggregate_failures do
        expect(service.symbol_to_icon_type('{Z}')).to be_nil
        expect(service.symbol_to_icon_type('{W/B/C}')).to be_nil
        expect(service.symbol_to_icon_type('W')).to be_nil
        expect(service.symbol_to_icon_type('')).to be_nil
        expect(service.symbol_to_icon_type(nil)).to be_nil
      end
    end
  end

  describe '#symbol_map' do
    it 'returns a hash with all symbol mappings', :aggregate_failures do
      map = service.symbol_map
      expect(map).to be_a(Hash)
      expect(map).not_to be_empty
    end

    it 'includes all basic colors', :aggregate_failures do
      map = service.symbol_map
      expect(map['{W}']).to eq(:white)
      expect(map['{B}']).to eq(:black)
      expect(map['{R}']).to eq(:red)
      expect(map['{G}']).to eq(:green)
      expect(map['{U}']).to eq(:blue)
      expect(map['{C}']).to eq(:colorless)
    end

    it 'includes all special symbols', :aggregate_failures do
      map = service.symbol_map
      expect(map['{S}']).to eq(:snow)
      expect(map['{X}']).to eq(:x)
      expect(map['{T}']).to eq(:tap)
      expect(map['{Q}']).to eq(:untap)
      expect(map['{E}']).to eq(:energy)
    end

    it 'includes numeric symbols', :aggregate_failures do
      map = service.symbol_map
      expect(map['{0}']).to eq(:numeric)
      expect(map['{5}']).to eq(:numeric)
      expect(map['{10}']).to eq(:numeric)
      expect(map['{99}']).to eq(:numeric)
      expect(map['{100}']).to be_nil
    end

    it 'includes hybrid symbols', :aggregate_failures do
      map = service.symbol_map
      expect(map['{W/B}']).to eq(:'hybrid-white-black')
      expect(map['{2/W}']).to eq(:'hybrid-2-white')
    end

    it 'includes phyrexian symbols', :aggregate_failures do
      map = service.symbol_map
      expect(map['{W/P}']).to eq(:'phyrexian-white')
      expect(map['{W/B/P}']).to eq(:'phyrexian-white-black')
    end
  end
end
