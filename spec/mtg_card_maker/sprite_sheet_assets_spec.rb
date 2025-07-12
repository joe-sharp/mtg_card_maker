# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::SpriteSheetAssets do
  let(:assets) { described_class.new }

  describe '#initialize' do
    it 'creates an instance with color schemes', :aggregate_failures do
      expect(assets).to be_a(described_class)
      expect(assets.instance_variable_get(:@color_schemes)).to be_an(Array)
      expect(assets.instance_variable_get(:@color_schemes).length).to eq(8)
    end
  end

  describe '#add_assets_to_sprite' do
    it 'adds all assets to sprite', :aggregate_failures do
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
          assets.add_assets_to_sprite(xml)
        end
      end

      xml = builder.to_xml
      expect(xml).to include('@font-face')
      expect(xml).to include('.card-name')
      expect(xml).to include('artWindowMask')
      expect(xml).to include('linearGradient')
    end
  end

  describe 'private methods' do
    describe '#add_sprite_styles' do
      it 'adds CSS styles to sprite', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new
        assets.send(:add_sprite_styles, builder)

        xml = builder.to_xml
        expect(xml).to include('@font-face')
        expect(xml).to include('.card-name')
        expect(xml).to include('.card-type')
        expect(xml).to include('.card-description')
        expect(xml).to include('.card-flavor-text')
        expect(xml).to include('.card-power-toughness')
        expect(xml).to include('.mana-cost-text')
        expect(xml).to include('.mana-cost-text-large')
      end
    end

    describe '#add_sprite_masks' do
      it 'adds art window mask to sprite', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new
        assets.send(:add_sprite_masks, builder)

        xml = builder.to_xml
        expect(xml).to include('artWindowMask')
        expect(xml).to include('fill="#FFF"')
        expect(xml).to include('fill="#000"')
      end
    end

    describe '#add_sprite_gradients' do
      it 'adds gradients for all color schemes', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            assets.send(:add_sprite_gradients, xml)
          end
        end

        xml = builder.to_xml
        expect(xml).to include('colorless_card_gradient')
        expect(xml).to include('white_card_gradient')
        expect(xml).to include('blue_card_gradient')
        expect(xml).to include('black_card_gradient')
        expect(xml).to include('red_card_gradient')
        expect(xml).to include('green_card_gradient')
        expect(xml).to include('gold_card_gradient')
        expect(xml).to include('artifact_card_gradient')
      end
    end

    describe '#define_gradient' do
      it 'defines card gradient for colorless scheme', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            color_scheme = MtgCardMaker::ColorScheme.new(:colorless)
            assets.send(:define_gradient, xml, color_scheme, 'colorless', 'card', nil)
          end
        end

        xml = builder.to_xml
        expect(xml).to include('colorless_card_gradient')
        expect(xml).to include('stop-color')
        expect(xml).to include('offset')
      end

      it 'defines frame gradient for gold scheme', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            color_scheme = MtgCardMaker::ColorScheme.new(:gold)
            assets.send(:define_gradient, xml, color_scheme, 'gold', 'frame', nil)
          end
        end

        xml = builder.to_xml
        expect(xml).to include('gold_frame_gradient')
        expect(xml).to include('stop-color')
        expect(xml).to include('offset')
      end

      it 'defines name gradient for blue scheme', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            color_scheme = MtgCardMaker::ColorScheme.new(:blue)
            assets.send(:define_gradient, xml, color_scheme, 'blue', 'name', nil)
          end
        end

        xml = builder.to_xml
        expect(xml).to include('blue_name_gradient')
        expect(xml).to include('stop-color')
        expect(xml).to include('offset')
      end

      it 'defines description gradient for white scheme', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            color_scheme = MtgCardMaker::ColorScheme.new(:white)
            assets.send(:define_gradient, xml, color_scheme, 'white', 'description', nil)
          end
        end

        xml = builder.to_xml
        expect(xml).to include('white_description_gradient')
        expect(xml).to include('stop-color')
        expect(xml).to include('offset')
      end
    end

    describe '#define_metallic_gradients' do
      it 'defines all metallic gradients for gold scheme', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            color_scheme = MtgCardMaker::ColorScheme.new(:gold)
            assets.send(:define_metallic_gradients, xml, color_scheme, 'gold')
          end
        end

        xml = builder.to_xml
        expect(xml).to include('gold_metallic_highlight_gradient')
        expect(xml).to include('gold_metallic_shadow_gradient')
        expect(xml).to include('gold_metallic_pattern')
      end
    end

    describe '#define_metallic_highlight_gradient' do
      it 'defines metallic highlight gradient', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            color_scheme = MtgCardMaker::ColorScheme.new(:gold)
            assets.send(:define_metallic_highlight_gradient, xml, color_scheme, 'gold')
          end
        end

        xml = builder.to_xml
        expect(xml).to include('gold_metallic_highlight_gradient')
        expect(xml).to include('stop-opacity')
        expect(xml).to include('offset')
      end
    end

    describe '#define_metallic_shadow_gradient' do
      it 'defines metallic shadow gradient', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            color_scheme = MtgCardMaker::ColorScheme.new(:gold)
            assets.send(:define_metallic_shadow_gradient, xml, color_scheme, 'gold')
          end
        end

        xml = builder.to_xml
        expect(xml).to include('gold_metallic_shadow_gradient')
        expect(xml).to include('radialGradient')
        expect(xml).to include('stop-opacity')
      end
    end

    describe '#define_metallic_pattern' do
      it 'defines metallic pattern with lines and circles', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            color_scheme = MtgCardMaker::ColorScheme.new(:gold)
            assets.send(:define_metallic_pattern, xml, color_scheme, 'gold')
          end
        end

        xml = builder.to_xml
        expect(xml).to include('gold_metallic_pattern')
        expect(xml).to include('pattern')
        expect(xml).to include('line')
        expect(xml).to include('circle')
      end
    end

    describe '#add_metallic_pattern_lines' do
      it 'adds metallic pattern lines', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            color_scheme = MtgCardMaker::ColorScheme.new(:gold)
            assets.send(:add_metallic_pattern_lines, xml, color_scheme)
          end
        end

        xml = builder.to_xml
        expect(xml).to include('<line')
        expect(xml).to include('stroke-width')
        expect(xml).to include('opacity')
      end
    end

    describe '#add_metallic_pattern_circles' do
      it 'adds metallic pattern circles', :aggregate_failures do
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            color_scheme = MtgCardMaker::ColorScheme.new(:gold)
            assets.send(:add_metallic_pattern_circles, xml, color_scheme)
          end
        end

        xml = builder.to_xml
        expect(xml).to include('<circle')
        expect(xml).to include('opacity')
      end
    end

    describe '#metallic_properties?' do
      it 'returns true for gold color scheme' do
        color_scheme = MtgCardMaker::ColorScheme.new(:gold)
        expect(assets.send(:metallic_properties?, color_scheme)).to be true
      end

      it 'returns true for colorless color scheme' do
        color_scheme = MtgCardMaker::ColorScheme.new(:colorless)
        expect(assets.send(:metallic_properties?, color_scheme)).to be true
      end

      it 'returns false for non-metallic color schemes' do
        color_scheme = MtgCardMaker::ColorScheme.new(:white)
        expect(assets.send(:metallic_properties?, color_scheme)).to be false
      end
    end

    describe '#build_color_schemes' do
      it 'builds all color schemes', :aggregate_failures do
        schemes = assets.send(:build_color_schemes)
        expect(schemes).to be_an(Array)
        expect(schemes.length).to eq(8)

        scheme_names = schemes.map(&:scheme_name)
        expect(scheme_names).to include(:colorless, :white, :blue, :black, :red, :green, :gold, :artifact)
      end
    end
  end
end
