# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe MtgCardMaker::SpriteSheetService do
  let(:service) { described_class.new }
  let(:card_configs) do
    {
      'white' => {
        'name' => 'Test Card 1',
        'type_line' => 'Creature',
        'description' => 'A test creature',
        'color' => 'white'
      },
      'blue' => {
        'name' => 'Test Card 2',
        'type_line' => 'Instant',
        'description' => 'A test instant',
        'color' => 'blue'
      }
    }
  end

  describe '#initialize' do
    it 'uses default values', :aggregate_failures do
      service = described_class.new
      expect(service.cards_per_row).to eq(5)
      expect(service.spacing).to eq(30)
    end

    it 'accepts custom values', :aggregate_failures do
      service = described_class.new(cards_per_row: 3, spacing: 20)
      expect(service.cards_per_row).to eq(3)
      expect(service.spacing).to eq(20)
    end
  end

  describe '#create_sprite_sheet' do
    let(:output_file) { 'tmp/test_sprite.svg' }

    after do
      FileUtils.rm_f(output_file)
    end

    it 'returns false for empty card_configs' do
      result = service.create_sprite_sheet({}, output_file)
      expect(result).to be false
    end

    it 'creates a sprite sheet successfully', :aggregate_failures do
      result = service.create_sprite_sheet(card_configs, output_file)
      expect(result).to be true
      expect(File.exist?(output_file)).to be true
    end

    it 'handles error during sprite creation', :aggregate_failures do
      allow(service.instance_variable_get(:@builder)).to receive(:create_sprite_builder).and_raise(StandardError,
                                                                                                   'Test error')

      expect do
        service.create_sprite_sheet(card_configs, output_file)
      end.to raise_error(RuntimeError, /❌ Error creating sprite sheet: Test error/)
    end
  end

  describe '#sprite_dimensions' do
    it 'returns [0, 0] for zero card_count' do
      dimensions = service.sprite_dimensions(0)
      expect(dimensions).to eq([0, 0])
    end

    it 'calculates dimensions for single card', :aggregate_failures do
      dimensions = service.sprite_dimensions(1)
      expected_width = MtgCardMaker::CARD_WIDTH
      expected_height = MtgCardMaker::CARD_HEIGHT
      expect(dimensions).to eq([expected_width, expected_height])
    end

    it 'calculates dimensions for multiple cards in one row', :aggregate_failures do
      dimensions = service.sprite_dimensions(3)
      expected_width = (3 * MtgCardMaker::CARD_WIDTH) + (2 * 30)
      expected_height = MtgCardMaker::CARD_HEIGHT
      expect(dimensions).to eq([expected_width, expected_height])
    end

    it 'calculates dimensions for multiple rows', :aggregate_failures do
      dimensions = service.sprite_dimensions(7)
      expected_width = (5 * MtgCardMaker::CARD_WIDTH) + (4 * 30)
      expected_height = (2 * MtgCardMaker::CARD_HEIGHT) + (1 * 30)
      expect(dimensions).to eq([expected_width, expected_height])
    end

    it 'handles card count exceeding cards_per_row', :aggregate_failures do
      service = described_class.new(cards_per_row: 3)
      dimensions = service.sprite_dimensions(5)
      expected_width = (3 * MtgCardMaker::CARD_WIDTH) + (2 * 30)
      expected_height = (2 * MtgCardMaker::CARD_HEIGHT) + (1 * 30)
      expect(dimensions).to eq([expected_width, expected_height])
    end
  end

  describe 'private methods' do
    describe '#generate_individual_cards' do
      it 'generates individual card files', :aggregate_failures do
        card_files = service.send(:generate_individual_cards, card_configs)

        expect(card_files).to be_an(Array)
        expect(card_files.length).to eq(2)
        expect(card_files.first).to be_a(Tempfile)

        # Clean up
        card_files.each do |file|
          file.close
          file.unlink
        end
      end
    end

    describe '#stitch_cards_into_sprite' do
      let(:card_files) do
        files = []
        2.times do |_i|
          file = Tempfile.new(['test_card_', '.svg'])
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

      it 'raises error during sprite creation error' do
        allow(service.instance_variable_get(:@builder)).to receive(:create_sprite_builder).and_raise(StandardError,
                                                                                                     'Test error')
        expect do
          service.send(:stitch_cards_into_sprite, card_files, 'test_sprite.svg')
        end.to raise_error(RuntimeError, /❌ Error creating sprite sheet: Test error/)
      end
    end

    describe '#cleanup_temp_files' do
      let(:card_files) do
        files = []
        2.times do |_i|
          file = Tempfile.new(['test_card_', '.svg'])
          file.write('<svg><rect width="100" height="140"/></svg>')
          file.close
          files << file
        end
        files
      end

      it 'prints warning to stderr during cleanup error' do
        card_files.each do |file|
          allow(file).to receive(:unlink).and_raise(StandardError, 'Cleanup error')
        end
        expect do
          service.send(:cleanup_temp_files, card_files)
        end.to output(/Warning: Could not clean up temp file .*: Cleanup error/).to_stderr
      end
    end
  end
end
