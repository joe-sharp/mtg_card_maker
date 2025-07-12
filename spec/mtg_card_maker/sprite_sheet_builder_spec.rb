# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe MtgCardMaker::SpriteSheetBuilder do
  let(:builder) { described_class.new }
  let(:assets) { MtgCardMaker::SpriteSheetAssets.new }

  describe '#initialize' do
    it 'uses default values', :aggregate_failures do
      builder = described_class.new
      expect(builder.cards_per_row).to eq(5)
      expect(builder.spacing).to eq(30)
    end

    it 'accepts custom values', :aggregate_failures do
      builder = described_class.new(cards_per_row: 3, spacing: 20)
      expect(builder.cards_per_row).to eq(3)
      expect(builder.spacing).to eq(20)
    end
  end

  describe '#sprite_dimensions' do
    it 'returns [0, 0] for zero card_count' do
      dimensions = builder.sprite_dimensions(0)
      expect(dimensions).to eq([0, 0])
    end

    it 'calculates dimensions for single card', :aggregate_failures do
      dimensions = builder.sprite_dimensions(1)
      expected_width = MtgCardMaker::CARD_WIDTH
      expected_height = MtgCardMaker::CARD_HEIGHT
      expect(dimensions).to eq([expected_width, expected_height])
    end

    it 'calculates dimensions for multiple cards in one row', :aggregate_failures do
      dimensions = builder.sprite_dimensions(3)
      expected_width = (3 * MtgCardMaker::CARD_WIDTH) + (2 * 30)
      expected_height = MtgCardMaker::CARD_HEIGHT
      expect(dimensions).to eq([expected_width, expected_height])
    end

    it 'calculates dimensions for multiple rows', :aggregate_failures do
      dimensions = builder.sprite_dimensions(7)
      expected_width = (5 * MtgCardMaker::CARD_WIDTH) + (4 * 30)
      expected_height = (2 * MtgCardMaker::CARD_HEIGHT) + (1 * 30)
      expect(dimensions).to eq([expected_width, expected_height])
    end

    it 'handles card count exceeding cards_per_row', :aggregate_failures do
      builder = described_class.new(cards_per_row: 3)
      dimensions = builder.sprite_dimensions(5)
      expected_width = (3 * MtgCardMaker::CARD_WIDTH) + (2 * 30)
      expected_height = (2 * MtgCardMaker::CARD_HEIGHT) + (1 * 30)
      expect(dimensions).to eq([expected_width, expected_height])
    end
  end

  describe '#create_sprite_builder' do
    let(:card_files) do
      files = []
      2.times do |i|
        file = Tempfile.new(["test_card_#{i}", '.svg'])
        file.write('<svg><rect width="100" height="140"/></svg>')
        file.close
        files << file
      end
      files
    end

    after do
      card_files.each do |file|
        file.unlink if File.exist?(file.path)
      end
    end

    it 'creates sprite builder with correct dimensions' do
      width, height = builder.sprite_dimensions(2)
      result = builder.create_sprite_builder(width, height, card_files, assets)

      expect(result).to be_a(Nokogiri::XML::Builder)
    end

    it 'includes assets in the sprite', :aggregate_failures do
      width, height = builder.sprite_dimensions(2)
      result = builder.create_sprite_builder(width, height, card_files, assets)
      xml = result.to_xml

      expect(xml).to include('@font-face')
      expect(xml).to include('.card-name')
      expect(xml).to include('artWindowMask')
    end
  end

  describe '#write_sprite_file' do
    it 'writes sprite to file', :aggregate_failures do
      builder_obj = Nokogiri::XML::Builder.new do |xml|
        xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
          xml.rect(width: 100, height: 100)
        end
      end

      output_file = 'tmp/test_sprite.svg'
      builder.write_sprite_file(output_file, builder_obj)

      expect(File.exist?(output_file)).to be true
      expect(File.read(output_file)).to include('<svg')

      FileUtils.rm_f(output_file)
    end
  end

  describe 'private methods' do
    describe '#add_cards_to_sprite' do
      let(:card_files) do
        files = []
        2.times do |i|
          file = Tempfile.new(["test_card_#{i}", '.svg'])
          file.write('<svg><rect width="100" height="140"/></svg>')
          file.close
          files << file
        end
        files
      end

      after do
        card_files.each do |file|
          file.unlink if File.exist?(file.path)
        end
      end

      it 'adds cards to sprite', :aggregate_failures do
        builder_obj = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            builder.send(:add_cards_to_sprite, xml, card_files)
          end
        end

        xml = builder_obj.to_xml
        expect(xml).to include('<g')
        expect(xml).to include('transform')
      end
    end

    describe '#add_card_to_sprite' do
      let(:card_file) do
        file = Tempfile.new(['test_card', '.svg'])
        file.write('<svg><rect width="100" height="140"/></svg>')
        file.close
        file
      end

      after do
        card_file.unlink if File.exist?(card_file.path)
      end

      it 'adds card to sprite with correct position', :aggregate_failures do
        builder_obj = Nokogiri::XML::Builder.new
        builder.send(:add_card_to_sprite, builder_obj, card_file, 0)

        xml = builder_obj.to_xml
        expect(xml).to include('<g')
        expect(xml).to include('transform')
      end

      it 'handles missing svg element gracefully' do
        file = Tempfile.new(['test_card', '.svg'])
        file.write('<div>Not SVG</div>')
        file.close

        builder_obj = Nokogiri::XML::Builder.new
        expect { builder.send(:add_card_to_sprite, builder_obj, file, 0) }.not_to raise_error

        file.unlink
      end
    end

    describe '#calculate_card_position' do
      it 'calculates position for first card', :aggregate_failures do
        position = builder.send(:calculate_card_position, 0)
        expect(position[:x]).to eq(0)
        expect(position[:y]).to eq(0)
      end

      it 'calculates position for card in first row', :aggregate_failures do
        position = builder.send(:calculate_card_position, 2)
        expected_x = 2 * (MtgCardMaker::CARD_WIDTH + 30)
        expect(position[:x]).to eq(expected_x)
        expect(position[:y]).to eq(0)
      end

      it 'calculates position for card in second row', :aggregate_failures do
        position = builder.send(:calculate_card_position, 6)
        expected_x = 1 * (MtgCardMaker::CARD_WIDTH + 30)
        expected_y = 1 * (MtgCardMaker::CARD_HEIGHT + 30)
        expect(position[:x]).to eq(expected_x)
        expect(position[:y]).to eq(expected_y)
      end
    end

    describe '#load_card_document' do
      it 'loads card document from file', :aggregate_failures do
        file = Tempfile.new(['test_card', '.svg'])
        file.write('<svg><rect width="100" height="140"/></svg>')
        file.close

        doc = builder.send(:load_card_document, file)
        expect(doc).to be_a(Nokogiri::XML::Document)
        expect(doc.at_css('svg')).not_to be_nil

        file.unlink if File.exist?(file.path)
      end
    end

    describe '#add_card_children' do
      it 'adds card children to sprite', :aggregate_failures do
        doc = Nokogiri::XML('<svg><rect width="100" height="140"/><circle cx="50" cy="50" r="10"/></svg>')
        svg_element = doc.at_css('svg')

        builder_obj = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            builder.send(:add_card_children, xml, svg_element)
          end
        end

        xml = builder_obj.to_xml
        expect(xml).to include('<rect')
        expect(xml).to include('<circle')
      end

      it 'excludes defs and style elements', :aggregate_failures do
        doc = Nokogiri::XML('<svg><rect width="100" height="140"/><defs><style></style></defs></svg>')
        svg_element = doc.at_css('svg')

        builder_obj = Nokogiri::XML::Builder.new do |xml|
          xml.svg(xmlns: 'http://www.w3.org/2000/svg') do
            builder.send(:add_card_children, xml, svg_element)
          end
        end

        xml = builder_obj.to_xml
        expect(xml).to include('<rect')
        expect(xml).not_to include('<defs')
        expect(xml).not_to include('<style')
      end
    end
  end
end
