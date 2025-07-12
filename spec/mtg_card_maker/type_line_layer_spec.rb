# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::TypeLineLayer do
  it 'inherits from BaseLayer' do
    expect(described_class).to be < MtgCardMaker::BaseLayer
  end

  it 'uses correct default color' do
    layer = described_class.new(
      dimensions: { x: 0, y: 0, width: 100, height: 100 },
      type_line: 'Instant'
    )
    expect(layer.color).to eq('#E8E8E8')
  end

  it 'matches expected fixture output' do
    fixture_layer = described_class.new(
      dimensions: { x: 30, y: 500, width: 570, height: 40 },
      type_line: 'Ruby - SVG - Shell',
      color: '#E8DCC6'
    )
    expect_svg_to_match_fixture(fixture_layer, 'type_line_layer')
  end

  describe '#jsharp_path_data' do
    let(:layer) { described_class.new(dimensions: { x: 0, y: 0, width: 100, height: 100 }, type_line: 'Instant') }
    let(:icon_service) { instance_double(MtgCardMaker::IconService) }

    before do
      allow(MtgCardMaker::IconService).to receive(:new).and_return(icon_service)
    end

    context 'when J# icon SVG content is nil' do
      before do
        allow(icon_service).to receive(:jsharp_svg).and_return(nil)
      end

      it 'raises error for nil J# icon SVG content' do
        expect { layer.send(:jsharp_path_data) }.to raise_error('J# icon not found')
      end
    end

    context 'when J# icon SVG content does not contain path element' do
      let(:jsharp_svg_content) do
        '<?xml version="1.0" standalone="yes"?><svg version="1.1" ' \
          'xmlns="http://www.w3.org/2000/svg" width="100" height="100">' \
          '<rect width="100" height="100"/></svg>'
      end

      before do
        allow(icon_service).to receive(:jsharp_svg).and_return(jsharp_svg_content)
      end

      it 'returns nil when no path element found' do
        expect(layer.send(:jsharp_path_data)).to be_nil
      end
    end
  end
end
