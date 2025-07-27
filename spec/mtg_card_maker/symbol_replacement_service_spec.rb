# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::SymbolReplacementService do
  let(:service) { described_class.new }

  describe '#initialize' do
    it 'creates an instance with default font size from LayerConfig' do
      service = described_class.new
      expect(service.font_size).to eq(MtgCardMaker::LayerConfig::DEFAULT_CONFIG[:font_sizes][:text_box])
    end

    it 'creates an instance with correct font size' do
      service = described_class.new
      expect(service.font_size).to be_a(Integer)
    end

    it 'creates an icon service instance' do
      expect(service.icon_service).to be_a(MtgCardMaker::IconService)
    end
  end

  describe '#contains_symbols?' do
    it 'returns true for text with symbols', :aggregate_failures do
      expect(service.contains_symbols?('Deal {R} damage')).to be true
      expect(service.contains_symbols?('Add {W}{W}')).to be true
      expect(service.contains_symbols?('{T}: Add {1}')).to be true
    end

    it 'returns false for text without symbols', :aggregate_failures do
      expect(service.contains_symbols?('Deal damage')).to be false
      expect(service.contains_symbols?('Add mana')).to be false
      expect(service.contains_symbols?('')).to be false
      expect(service.contains_symbols?(nil)).to be false
    end

    it 'handles edge cases', :aggregate_failures do
      expect(service.contains_symbols?('{')).to be false
      expect(service.contains_symbols?('}')).to be false
      expect(service.contains_symbols?('{}')).to be false
      expect(service.contains_symbols?('{ }')).to be true
    end
  end

  describe '#split_text_and_symbols' do
    it 'splits text with symbols correctly' do
      result = service.split_text_and_symbols('Deal {R} damage')
      expect(result).to eq(['Deal ', '{R}', ' damage'])
    end

    it 'splits text with multiple symbols' do
      result = service.split_text_and_symbols('Add {W}{W} to your mana pool')
      expect(result).to eq(['Add ', '{W}', '{W}', ' to your mana pool'])
    end

    it 'handles text with mixed symbols and numbers' do
      result = service.split_text_and_symbols('{T}: Add {1} or {R}')
      expect(result).to eq(['{T}', ': Add ', '{1}', ' or ', '{R}'])
    end

    it 'handles text without symbols' do
      result = service.split_text_and_symbols('Deal damage')
      expect(result).to eq(['Deal damage'])
    end

    it 'handles empty text' do
      result = service.split_text_and_symbols('')
      expect(result).to eq([])
    end

    it 'handles edge cases', :aggregate_failures do
      expect(service.split_text_and_symbols('{}')).to eq(['{}'])
      expect(service.split_text_and_symbols('{ }')).to eq(['{ }'])
      expect(service.split_text_and_symbols('{')).to eq(['{'])
      expect(service.split_text_and_symbols('}')).to eq(['}'])
    end
  end

  describe '#render_line_with_symbols' do
    it 'renders text with colored mana symbols', :aggregate_failures do
      result = service.render_line_with_symbols('Deal {R} damage', 200)
      expect(result).to include('<div xmlns=\'http://www.w3.org/1999/xhtml\'')
      expect(result).to include('display: flex; align-items: center; font-size:')
      expect(result).to include('px;')
      expect(result).to include('Deal ')
      expect(result).to include('damage')
    end

    it 'renders text with numeric symbols', :aggregate_failures do
      result = service.render_line_with_symbols('Add {1} to your mana pool', 200)
      expect(result).to include('<div xmlns=\'http://www.w3.org/1999/xhtml\'')
      expect(result).to include('display: flex; align-items: center; font-size:')
      expect(result).to include('px;')
      expect(result).to include('Add ')
      expect(result).to include('to your mana pool')
    end

    it 'renders text with action symbols', :aggregate_failures do
      result = service.render_line_with_symbols('{T}: Add {1}', 200)
      expect(result).to include('<div xmlns=\'http://www.w3.org/1999/xhtml\'')
      expect(result).to include('display: flex; align-items: center; font-size:')
      expect(result).to include('px;')
      expect(result).to include(': Add ')
    end

    it 'handles text with mixed symbols and regular text', :aggregate_failures do
      result = service.render_line_with_symbols('{T}: Add {1} or {R} to your mana pool', 200)
      expect(result).to include('<div xmlns=\'http://www.w3.org/1999/xhtml\'')
      expect(result).to include('display: flex; align-items: center; font-size:')
      expect(result).to include('px;')
      expect(result).to include(': Add ')
      expect(result).to include(' or ')
      expect(result).to include(' to your mana pool')
    end

    it 'escapes HTML in regular text' do
      result = service.render_line_with_symbols('Deal <damage>', 200)
      expect(result).to include('Deal &lt;damage&gt;')
    end

    it 'handles text without symbols', :aggregate_failures do
      result = service.render_line_with_symbols('Deal damage', 200)
      expect(result).to include('<div xmlns=\'http://www.w3.org/1999/xhtml\'')
      expect(result).to include('display: flex; align-items: center; font-size:')
      expect(result).to include('px;')
      expect(result).to include('Deal damage')
    end

    it 'handles empty text', :aggregate_failures do
      result = service.render_line_with_symbols('', 200)
      expect(result).to include('<div xmlns=\'http://www.w3.org/1999/xhtml\'')
      expect(result).to include('</div>')
    end
  end

  describe 'private methods' do
    describe '#render_html_line_with_symbols' do
      it 'renders HTML with symbols and text', :aggregate_failures do
        parts = ['Deal ', '{R}', ' damage']
        result = service.send(:render_html_line_with_symbols, parts, 200)
        expect(result).to include('<div xmlns=\'http://www.w3.org/1999/xhtml\'')
        expect(result).to include('display: flex; align-items: center; font-size:')
        expect(result).to include('px;')
        expect(result).to include('Deal ')
        expect(result).to include('damage')
      end

      it 'handles parts with symbols' do
        parts = ['{R}', '{W}', '{B}']
        result = service.send(:render_html_line_with_symbols, parts, 200)
        expect(result).to include('<div xmlns=\'http://www.w3.org/1999/xhtml\'')
      end

      it 'handles parts without symbols' do
        parts = ['Deal ', 'damage']
        result = service.send(:render_html_line_with_symbols, parts, 200)
        expect(result).to include('Deal damage')
      end
    end

    describe '#render_symbol_html' do
      it 'renders colored mana symbols', :aggregate_failures do
        result = service.send(:render_symbol_html, '{R}')
        expect(result).to include('<svg')
        expect(result).to include('width="24"')
        expect(result).to include('height="24"')
        expect(result).to include('vertical-align: middle; margin: 0 5px;')
      end

      it 'renders numeric symbols', :aggregate_failures do
        result = service.send(:render_symbol_html, '{1}')
        expect(result).to include('<svg')
        expect(result).to include('width="24"')
        expect(result).to include('height="24"')
      end

      it 'returns nil for unsupported symbols' do
        result = service.send(:render_symbol_html, '{Z}')
        expect(result).to be_nil
      end

      it 'handles empty braces' do
        result = service.send(:render_symbol_html, '{}')
        expect(result).to be_nil
      end

      it 'handles malformed symbols' do
        result = service.send(:render_symbol_html, '{')
        expect(result).to be_nil
      end
    end
  end

  describe 'integration with IconService' do
    it 'uses IconService for symbol rendering' do
      icon_service = instance_double(MtgCardMaker::IconService)
      allow(MtgCardMaker::IconService).to receive(:new).and_return(icon_service)
      allow(icon_service).to receive(:icon_svg).with(:red).and_return('<svg>red</svg>')

      service = described_class.new
      result = service.send(:render_symbol_html, '{R}')

      expect(result).to include('<svg style="vertical-align: middle; margin: 0 5px;">red</svg>')
    end

    it 'falls back to numeric icons for numbers' do
      icon_service = instance_double(MtgCardMaker::IconService)
      allow(MtgCardMaker::IconService).to receive(:new).and_return(icon_service)
      allow(icon_service).to receive(:icon_svg).with(nil).and_return(nil)
      allow(icon_service).to receive(:numeric_icon_svg).with(1).and_return('<svg>1</svg>')

      service = described_class.new
      result = service.send(:render_symbol_html, '{1}')

      expect(result).to include('<svg style="vertical-align: middle; margin: 0 5px;">1</svg>')
    end
  end
end
