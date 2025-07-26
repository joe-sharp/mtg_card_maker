# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::SymbolParserService do
  let(:service) { described_class.new }

  describe '#initialize' do
    it 'creates a new symbol parser service with default icon set' do
      expect(service.icon_service).to be_a(MtgCardMaker::IconService)
    end

    it 'accepts custom icon set' do
      custom_service = described_class.new(:custom)
      expect(custom_service.icon_service.icon_set).to eq(:custom)
    end
  end

  describe '#process_text' do
    context 'with colored mana symbols' do
      it 'processes white mana symbol' do
        result = service.process_text('Add {W}.')
        expect(result).to include('<circle')
        expect(result).to include('fill="#FFF9C4"')
      end

      it 'processes blue mana symbol' do
        result = service.process_text('Add {U}.')
        expect(result).to include('<circle')
        expect(result).to include('fill="#90CAF9"')
      end

      it 'processes black mana symbol' do
        result = service.process_text('Add {B}.')
        expect(result).to include('<circle')
        expect(result).to include('fill="#BDBDBD"')
      end

      it 'processes red mana symbol' do
        result = service.process_text('Add {R}.')
        expect(result).to include('<circle')
        expect(result).to include('fill="#EF9A9A"')
      end

      it 'processes green mana symbol' do
        result = service.process_text('Add {G}.')
        expect(result).to include('<circle')
        expect(result).to include('fill="#A5D6A7"')
      end

      it 'processes colorless mana symbol' do
        result = service.process_text('Add {C}.')
        expect(result).to include('<circle')
        expect(result).to include('fill="#DDD"')
      end

      it 'processes multiple colored mana symbols', :aggregate_failures do
        result = service.process_text('Cost: {W}{U}{B}{R}{G}')
        expect(result).to include('fill="#FFF9C4"') # White
        expect(result).to include('fill="#90CAF9"') # Blue
        expect(result).to include('fill="#BDBDBD"') # Black
        expect(result).to include('fill="#EF9A9A"') # Red
        expect(result).to include('fill="#A5D6A7"') # Green
      end
    end

    context 'with generic mana symbols' do
      it 'processes single digit generic mana', :aggregate_failures do
        (0..9).each do |digit|
          result = service.process_text("Cost: {#{digit}}")
          expect(result).to include(">#{digit}<")
          expect(result).to include('fill="#DDD"')
        end
      end

      it 'processes double digit generic mana' do
        result = service.process_text('Cost: {10}')
        expect(result).to include('>10<')
        expect(result).to include('fill="#DDD"')
      end

      it 'processes X generic mana' do
        result = service.process_text('Cost: {X}')
        expect(result).to include('>X<')
        expect(result).to include('fill="#DDD"')
      end

      it 'processes multiple generic mana symbols', :aggregate_failures do
        result = service.process_text('Cost: {1}{2}{3}{X}')
        expect(result).to include('>1<')
        expect(result).to include('>2<')
        expect(result).to include('>3<')
        expect(result).to include('>X<')
      end
    end

    context 'with hybrid mana symbols' do
      it 'processes white/blue hybrid mana' do
        result = service.process_text('Cost: {W/U}')
        expect(result).to include('<circle')
        expect(result).to include('fill="#FFF9C4"') # Uses first color
      end

      it 'processes multiple hybrid mana symbols', :aggregate_failures do
        result = service.process_text('Cost: {W/U}{B/G}{R/U}')
        expect(result).to include('<circle')
        expect(result.scan('<circle').length).to eq(3)
      end
    end

    context 'with action symbols' do
      it 'processes tap symbol' do
        result = service.process_text('{T}: Add {G}.')
        expect(result).to include('⟳')
      end

      it 'processes untap symbol' do
        result = service.process_text('{Q}: Add {W}.')
        expect(result).to include('⟲')
      end

      it 'processes energy symbol' do
        result = service.process_text('Add {E}.')
        expect(result).to include('⚡')
      end

      it 'processes multiple action symbols', :aggregate_failures do
        result = service.process_text('{T}: Add {E}. {Q}: Add {W}.')
        expect(result).to include('⟳')
        expect(result).to include('⟲')
        expect(result).to include('⚡')
      end
    end

    context 'with mixed symbols' do
      it 'processes complex rule text with multiple symbol types', :aggregate_failures do
        result = service.process_text('{T}: Add {W} or {U}. {1}{G}: Add {E}.')
        expect(result).to include('⟳') # Tap symbol
        expect(result).to include('fill="#FFF9C4"') # White mana
        expect(result).to include('fill="#90CAF9"') # Blue mana
        expect(result).to include('>1<') # Generic mana
        expect(result).to include('fill="#A5D6A7"') # Green mana
        expect(result).to include('⚡') # Energy symbol
      end
    end

    context 'with edge cases' do
      it 'handles nil text' do
        expect(service.process_text(nil)).to be_nil
      end

      it 'handles empty text' do
        expect(service.process_text('')).to eq('')
      end

      it 'handles text without symbols' do
        text = 'This is plain text without any symbols.'
        expect(service.process_text(text)).to eq(text)
      end

      it 'handles unsupported symbols' do
        text = 'Cost: {Z}{Y}{A}'
        result = service.process_text(text)
        expect(result).to include('?') # Fallback symbol
        expect(result.scan('<circle').length).to eq(3)
      end

      it 'handles malformed symbols' do
        text = 'Cost: {W}{U}{B}'
        result = service.process_text(text)
        expect(result).to include('fill="#FFF9C4"')
        expect(result).to include('fill="#90CAF9"')
        expect(result).to include('fill="#BDBDBD"')
      end
    end

    context 'with symbol ordering' do
      it 'processes longer patterns before shorter ones' do
        # {W/U} should be processed before {W} and {U}
        result = service.process_text('Cost: {W/U}')
        expect(result).to include('fill="#FFF9C4"') # Should use first color of hybrid
      end
    end
  end

  describe '#supported_symbols' do
    it 'returns all supported symbol patterns' do
      symbols = service.supported_symbols
      expect(symbols).to include('{W}', '{U}', '{B}', '{R}', '{G}', '{C}')
      expect(symbols).to include('{1}', '{2}', '{X}')
      expect(symbols).to include('{W/U}', '{B/G}')
      expect(symbols).to include('{T}', '{Q}', '{E}')
    end

    it 'returns symbols in the correct order for processing' do
      symbols = service.supported_symbols
      # Check that longer patterns come before shorter ones
      w_u_index = symbols.index('{W/U}')
      w_index = symbols.index('{W}')
      u_index = symbols.index('{U}')

      expect(w_u_index).to be < w_index
      expect(w_u_index).to be < u_index
    end
  end

  describe '#supported?' do
    it 'returns true for supported symbols' do
      expect(service.supported?('{W}')).to be true
      expect(service.supported?('{1}')).to be true
      expect(service.supported?('{W/U}')).to be true
      expect(service.supported?('{T}')).to be true
    end

    it 'returns false for unsupported symbols' do
      expect(service.supported?('{Z}')).to be false
      expect(service.supported?('{11}')).to be false
      expect(service.supported?('{W/Z}')).to be false
      expect(service.supported?('{A}')).to be false
    end
  end

  describe 'SVG generation' do
    it 'generates proper SVG structure for colored mana' do
      result = service.process_text('{W}')
      expect(result).to include('<g style="display: inline-block; vertical-align: middle;">')
      expect(result).to include('<circle')
      expect(result).to include('opacity="0.8"')
    end

    it 'generates proper SVG structure for generic mana' do
      result = service.process_text('{1}')
      expect(result).to include('<g style="display: inline-block; vertical-align: middle;">')
      expect(result).to include('<circle')
      expect(result).to include('<text')
      expect(result).to include('>1<')
    end

    it 'generates proper SVG structure for action symbols' do
      result = service.process_text('{T}')
      expect(result).to include('<g style="display: inline-block; vertical-align: middle;">')
      expect(result).to include('<text')
      expect(result).to include('⟳')
    end

    it 'generates fallback for missing icons' do
      # Mock icon service to return nil
      allow(service.icon_service).to receive(:icon_svg).and_return(nil)
      result = service.process_text('{W}')
      expect(result).to include('?')
    end
  end

  describe 'integration with icon service' do
    it 'uses icon service for colored mana symbols' do
      expect(service.icon_service).to receive(:icon_svg).with(:white, size: 16).and_return('<svg>test</svg>')
      service.process_text('{W}')
    end

    it 'handles icon service failures gracefully' do
      allow(service.icon_service).to receive(:icon_svg).and_return(nil)
      result = service.process_text('{W}')
      expect(result).to include('?')
    end
  end
end
