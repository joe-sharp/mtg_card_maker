# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::BorderLayer do
  it 'inherits from BaseLayer' do
    expect(described_class).to be < MtgCardMaker::BaseLayer
  end

  it 'uses correct default color' do
    layer = described_class.new(dimensions: { x: 0, y: 0, width: 100, height: 100 })
    expect(layer.color).to eq(:white)
  end

  it 'has correct default mask_id' do
    layer = described_class.new(dimensions: { x: 0, y: 0, width: 100, height: 100 })
    expect(layer.mask_id).to eq('artWindowMask')
  end

  it 'accepts custom mask_id' do
    layer = described_class.new(
      dimensions: { x: 0, y: 0, width: 100, height: 100 },
      mask_id: 'customMask'
    )
    expect(layer.mask_id).to eq('customMask')
  end

  it 'matches expected fixture output' do
    fixture_layer = described_class.new(
      dimensions: { x: 0, y: 0, width: 630, height: 880 },
      color: :white
    )
    expect_svg_to_match_fixture(fixture_layer, 'border_layer')
  end

  describe 'color validation' do
    it 'accepts white color' do
      layer = described_class.new(
        dimensions: { x: 0, y: 0, width: 100, height: 100 },
        color: :white
      )
      expect(layer.color).to eq(:white)
    end

    it 'accepts black color' do
      layer = described_class.new(
        dimensions: { x: 0, y: 0, width: 100, height: 100 },
        color: :black
      )
      expect(layer.color).to eq(:black)
    end

    it 'accepts silver color' do
      layer = described_class.new(
        dimensions: { x: 0, y: 0, width: 100, height: 100 },
        color: :silver
      )
      expect(layer.color).to eq(:silver)
    end

    it 'accepts gold color' do
      layer = described_class.new(
        dimensions: { x: 0, y: 0, width: 100, height: 100 },
        color: :gold
      )
      expect(layer.color).to eq(:gold)
    end

    it 'raises error for unsupported color' do
      expect do
        described_class.new(
          dimensions: { x: 0, y: 0, width: 100, height: 100 },
          color: :blue
        )
      end.to raise_error(ArgumentError, /Unsupported border color: :blue. Supported: white, black, silver, gold/)
    end

    it 'converts string colors to symbols' do
      layer = described_class.new(
        dimensions: { x: 0, y: 0, width: 100, height: 100 },
        color: 'white'
      )
      expect(layer.color).to eq(:white)
    end

    it 'validates supported colors correctly' do
      expect(described_class::SUPPORTED_COLORS).to eq({
                                                        white:  '#EEE',
                                                        black:  '#000',
                                                        silver: :colorless,
                                                        gold:   :gold
                                                      })
    end
  end

  describe '#color_key_for' do
    let(:layer) { described_class.new(dimensions: { x: 0, y: 0, width: 100, height: 100 }) }

    it 'returns :colorless for silver' do
      expect(layer.send(:color_key_for, :silver)).to eq(:colorless)
    end

    it 'returns :gold for gold' do
      expect(layer.send(:color_key_for, :gold)).to eq(:gold)
    end

    it 'returns original color for white' do
      expect(layer.send(:color_key_for, :white)).to eq(:white)
    end

    it 'returns original color for black' do
      expect(layer.send(:color_key_for, :black)).to eq(:black)
    end
  end

  describe '#render_frame_by_color' do
    let(:layer) { described_class.new(dimensions: { x: 0, y: 0, width: 100, height: 100 }) }
    let(:corners) { { x: 10, y: 10 } }

    before do
      allow(layer).to receive(:render_white_frame)
      allow(layer).to receive(:render_black_frame)
      allow(layer).to receive(:render_metallic_frame)
    end

    context 'when color is :white' do
      it 'calls render_white_frame' do
        layer.send(:render_frame_by_color, :white, corners)
        expect(layer).to have_received(:render_white_frame).with(corners)
      end
    end

    context 'when color is :black' do
      it 'calls render_black_frame' do
        layer.send(:render_frame_by_color, :black, corners)
        expect(layer).to have_received(:render_black_frame).with(corners)
      end
    end

    context 'when color is :colorless' do
      it 'calls render_metallic_frame' do
        layer.send(:render_frame_by_color, :colorless, corners)
        expect(layer).to have_received(:render_metallic_frame).with(corners)
      end
    end

    context 'when color is :gold' do
      it 'calls render_metallic_frame' do
        layer.send(:render_frame_by_color, :gold, corners)
        expect(layer).to have_received(:render_metallic_frame).with(corners)
      end
    end

    context 'when color is unsupported' do
      it 'raises ArgumentError with descriptive message' do
        expect do
          layer.send(:render_frame_by_color, :unsupported, corners)
        end.to raise_error(ArgumentError,
                           'Unsupported border color: :unsupported. Supported: white, black, silver, gold.')
      end
    end
  end

  describe '#render_white_frame' do
    let(:layer) { described_class.new(dimensions: { x: 10, y: 20, width: 100, height: 150 }) }
    let(:corners) { { x: 5, y: 5 } }
    let(:template) { MtgCardMaker::Template.new(width: 200, height: 200) }

    before do
      layer.template = template
    end

    it 'renders white frame with correct attributes', :aggregate_failures do
      layer.send(:render_white_frame, corners)
      # Verify the SVG contains the expected rect element with correct attributes
      svg_content = template.to_svg
      expect(svg_content).to include('fill="#EEE"')
      expect(svg_content).to include('rx="5"')
      expect(svg_content).to include('ry="5"')
      expect(svg_content).to include('mask="url(#artWindowMask)"')
    end
  end

  describe '#render_black_frame' do
    let(:layer) { described_class.new(dimensions: { x: 10, y: 20, width: 100, height: 150 }) }
    let(:corners) { { x: 5, y: 5 } }
    let(:template) { MtgCardMaker::Template.new(width: 200, height: 200) }

    before do
      layer.template = template
    end

    it 'renders black frame with correct attributes', :aggregate_failures do
      layer.send(:render_black_frame, corners)
      # Verify the SVG contains the expected rect element with correct attributes
      svg_content = template.to_svg
      expect(svg_content).to include('fill="#000"')
      expect(svg_content).to include('rx="5"')
      expect(svg_content).to include('ry="5"')
      expect(svg_content).to include('mask="url(#artWindowMask)"')
    end
  end

  describe '#render_metallic_frame' do
    let(:layer) { described_class.new(dimensions: { x: 10, y: 20, width: 100, height: 150 }) }
    let(:corners) { { x: 5, y: 5 } }
    let(:color_scheme) { instance_double(MtgCardMaker::ColorScheme) }
    let(:template) { MtgCardMaker::Template.new(width: 200, height: 200) }

    before do
      layer.template = template
      allow(layer).to receive(:color_scheme).and_return(color_scheme)
      allow(MtgCardMaker::SvgGradientService).to receive(:define_all_gradients)
      allow(layer).to receive(:render_metallic_elements)
    end

    it 'defines gradients and renders metallic elements', :aggregate_failures do
      layer.send(:render_metallic_frame, corners)

      expect(MtgCardMaker::SvgGradientService).to have_received(:define_all_gradients).with(layer.svg, color_scheme)
      expect(layer).to have_received(:render_metallic_elements).with(
        mask: 'artWindowMask',
        corners: corners,
        geometry: { x: 10, y: 20, width: 100, height: 150, padding: 0 },
        bottom_margin: 0,
        opacity: { texture: 0.15, shadow: 0.18 }
      )
    end
  end

  describe '#render_qr_code' do
    let(:layer) { described_class.new(dimensions: { x: 0, y: 0, width: 630, height: 880 }) }
    let(:icon_service) { instance_double(MtgCardMaker::IconService) }

    before do
      allow(MtgCardMaker::IconService).to receive(:new).and_return(icon_service)
    end

    context 'when QR code SVG content is nil' do
      before do
        allow(icon_service).to receive(:qr_code_svg).and_return(nil)
      end

      it 'raises error for nil QR code SVG content' do
        expect { layer.send(:render_qr_code) }.to raise_error('QR code SVG content is nil')
      end
    end

    context 'when QR code SVG content does not contain path element' do
      let(:qr_svg_content) do
        '<?xml version="1.0" standalone="yes"?><svg version="1.1" ' \
          'xmlns="http://www.w3.org/2000/svg" width="125.1" height="1685.1">' \
          '<rect width="100" height="100"/></svg>'
      end

      before do
        allow(icon_service).to receive(:qr_code_svg).and_return(qr_svg_content)
      end

      it 'raises error for no path element found' do
        expect { layer.send(:render_qr_code) }.to raise_error('No path element found in QR code SVG')
      end
    end

    context 'when QR code SVG content is valid' do
      let(:qr_svg_content) do
        '<?xml version="1.0" standalone="yes"?><svg version="1.1" ' \
          'xmlns="http://www.w3.org/2000/svg" width="125.1" height="1685.1">' \
          '<path d="M10 10 L20 20 Z"/></svg>'
      end
      let(:template) { MtgCardMaker::Template.new(width: 200, height: 200) }

      before do
        allow(icon_service).to receive(:qr_code_svg).and_return(qr_svg_content)
        layer.template = template
      end

      it 'renders QR code path with correct attributes', :aggregate_failures do
        layer.send(:render_qr_code)
        # Verify the SVG contains the expected path element with correct attributes
        svg_content = template.to_svg
        expect(svg_content).to include('fill="#111"')
        expect(svg_content).to include('transform="translate(40,820) scale(1.1)"')
        expect(svg_content).to include('d="M10 10 L20 20 Z"')
      end
    end
  end

  describe '#render_copyright_texts' do
    let(:layer) { described_class.new(dimensions: { x: 0, y: 0, width: 630, height: 880 }) }
    let(:layer_config) { instance_double(MtgCardMaker::LayerConfig) }
    let(:copyright_config) { { x_position: 40, base_y: 850, line_spacing: 15 } }
    let(:template) { MtgCardMaker::Template.new(width: 200, height: 200) }

    before do
      allow(MtgCardMaker::LayerConfig).to receive(:default).and_return(layer_config)
      allow(layer_config).to receive(:copyright_config).and_return(copyright_config)
      allow(layer_config).to receive(:font_size).with(:copyright).and_return(12)
      layer.template = template
    end

    it 'renders all copyright texts with correct attributes', :aggregate_failures do
      expected_texts = [
        '© 2025 Joe Sharp. Some rights reserved.',
        'Portions of the materials used are property of Wizards of the Coast.',
        '© Wizards of the Coast LLC'
      ]

      layer.send(:render_copyright_texts, layer_config)

      # Verify the SVG contains the expected text elements with correct attributes
      svg_content = template.to_svg
      expected_texts.each do |text|
        expect(svg_content).to include(text)
      end
      expect(svg_content).to include('fill="#111"')
      expect(svg_content).to include('font-size="12"')
      expect(svg_content).to include('text-anchor="start"')
      expect(svg_content).to include('class="card-copyright"')
    end
  end

  describe '#fill_color' do
    context 'when color is black' do
      let(:layer) { described_class.new(dimensions: { x: 0, y: 0, width: 100, height: 100 }, color: :black) }

      it 'returns white fill color' do
        expect(layer.send(:fill_color)).to eq('#FFF')
      end
    end

    context 'when color is not black' do
      let(:layer) { described_class.new(dimensions: { x: 0, y: 0, width: 100, height: 100 }, color: :white) }

      it 'returns dark fill color' do
        expect(layer.send(:fill_color)).to eq('#111')
      end
    end
  end
end
