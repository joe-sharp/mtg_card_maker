# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'fileutils'

RSpec.describe MtgCardMaker::CLI do
  let(:cli) { described_class.new }
  let(:temp_dir) { Dir.mktmpdir }
  let(:yaml_file) { File.join(temp_dir, 'test_cards.yml') }
  let(:output_file) { File.join(temp_dir, 'output.svg') }

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '#generate_card' do
    it 'generates a card with valid options', :aggregate_failures do
      base_card = instance_double(MtgCardMaker::BaseCard)
      allow(MtgCardMaker::BaseCard).to receive(:new).and_return(base_card)
      allow(base_card).to receive(:save)

      cli.options = {
        name: 'Test Card',
        type_line: 'Creature - Test',
        rules_text: 'A test card',
        output: output_file
      }

      expect { cli.generate_card }.not_to raise_error
    end

    # Thor handles required options automatically, so this test is not applicable
    # it 'handles missing required options' do
    #   cli.options = {}
    #
    #   expect { cli.generate_card }.to raise_error(SystemExit)
    # end
  end

  describe '#generate_sprite' do
    let(:valid_yaml_content) do
      {
        'test_card' => {
          'name' => 'Test Card',
          'type_line' => 'Creature - Test',
          'rules_text' => 'A test card'
        }
      }.to_yaml
    end

    before do
      File.write(yaml_file, valid_yaml_content)
    end

    it 'generates sprite sheet with valid YAML', :aggregate_failures do
      sprite_service = instance_double(MtgCardMaker::SpriteSheetService)
      allow(MtgCardMaker::SpriteSheetService).to receive(:new).and_return(sprite_service)
      allow(sprite_service).to receive_messages(
        create_sprite_sheet: true,
        sprite_dimensions: [100, 100]
      )

      cli.options = { cards_per_row: 4, spacing: 30 }

      expect { cli.generate_sprite(yaml_file, output_file) }.not_to raise_error
    end

    it 'handles non-existent YAML file' do
      expect { cli.generate_sprite('nonexistent.yml', output_file) }.to raise_error(SystemExit)
    end

    it 'handles invalid YAML syntax' do
      File.write(yaml_file, 'invalid: yaml: content:')

      expect { cli.generate_sprite(yaml_file, output_file) }.to raise_error(SystemExit)
    end

    it 'handles empty YAML file' do
      File.write(yaml_file, '')

      expect { cli.generate_sprite(yaml_file, output_file) }.to raise_error(SystemExit)
    end

    it 'handles sprite sheet generation failure' do
      sprite_service = instance_double(MtgCardMaker::SpriteSheetService)
      allow(MtgCardMaker::SpriteSheetService).to receive(:new).and_return(sprite_service)
      allow(sprite_service).to receive(:create_sprite_sheet).and_return(false)

      expect { cli.generate_sprite(yaml_file, output_file) }.to raise_error(SystemExit)
    end
  end

  describe '#add_card' do
    it 'adds card to existing YAML file', :aggregate_failures do
      existing_content = { 'existing_card' => { 'name' => 'Existing' } }.to_yaml
      File.write(yaml_file, existing_content)

      cli.options = {
        name: 'New Card',
        type_line: 'Creature - New',
        rules_text: 'A new card'
      }

      expect { cli.send(:add_card, yaml_file) }.not_to raise_error

      result = YAML.safe_load_file(yaml_file)
      expect(result).to have_key('new_card')
    end

    it 'creates new YAML file if it does not exist', :aggregate_failures do
      cli.options = {
        name: 'New Card',
        type_line: 'Creature - New',
        rules_text: 'A new card'
      }

      expect { cli.send(:add_card, yaml_file) }.not_to raise_error

      result = YAML.safe_load_file(yaml_file)
      expect(result).to have_key('new_card')
    end

    it 'generates unique keys for duplicate card names', :aggregate_failures do
      existing_content = { 'new_card' => { 'name' => 'New Card' } }.to_yaml
      File.write(yaml_file, existing_content)

      cli.options = {
        name: 'New Card',
        type_line: 'Creature - New',
        rules_text: 'A new card'
      }

      expect { cli.send(:add_card, yaml_file) }.not_to raise_error

      result = YAML.safe_load_file(yaml_file)
      expect(result).to have_key('new_card_1')
    end

    it 'handles optional fields correctly', :aggregate_failures do
      cli.options = {
        name: 'Test Card',
        type_line: 'Creature - Test',
        rules_text: 'A test card',
        mana_cost: '2R',
        flavor_text: 'Flavor text',
        power: '3',
        toughness: '3',
        border_color: 'black',
        color: 'red'
      }

      expect { cli.send(:add_card, yaml_file) }.not_to raise_error

      result = YAML.safe_load_file(yaml_file)
      card = result['test_card']
      expect(card['mana_cost']).to eq('2R')
      expect(card['flavor_text']).to eq('Flavor text')
      expect(card['power']).to eq('3')
      expect(card['toughness']).to eq('3')
      expect(card['border_color']).to eq('black')
      expect(card['color']).to eq('red')
    end
  end

  describe 'private methods' do
    describe '#validate_yaml' do
      it 'does not raise error for existing file' do
        File.write(yaml_file, 'test')
        expect { cli.send(:validate_yaml, yaml_file) }.not_to raise_error
      end

      it 'returns empty hash for non-existent file' do
        result = cli.send(:validate_yaml, 'nonexistent.yml')
        expect(result).to eq({})
      end
    end

    describe '#process_sprite_generation' do
      it 'handles successful sprite generation' do
        sprite_service = instance_double(MtgCardMaker::SpriteSheetService)
        allow(sprite_service).to receive_messages(
          create_sprite_sheet: true,
          sprite_dimensions: [100, 100]
        )

        expect { cli.send(:process_sprite_generation, {}, sprite_service, output_file) }.not_to raise_error
      end

      it 'handles failed sprite generation' do
        sprite_service = instance_double(MtgCardMaker::SpriteSheetService)
        allow(sprite_service).to receive(:create_sprite_sheet).and_return(false)

        expect { cli.send(:process_sprite_generation, {}, sprite_service, output_file) }.to raise_error(SystemExit)
      end
    end

    describe '#handle_yaml_error' do
      it 'raises SystemExit with error message' do
        # Create a mock error that responds to message
        error = instance_double(Psych::SyntaxError, message: 'Invalid YAML')
        expect { cli.send(:handle_yaml_error, error) }.to raise_error(SystemExit)
      end
    end

    describe '#handle_general_error' do
      it 'raises SystemExit with error message' do
        error = StandardError.new('General error')
        expect { cli.send(:handle_general_error, error) }.to raise_error(SystemExit)
      end
    end

    describe '#display_success_message' do
      it 'displays success message with sprite dimensions' do
        sprite_service = instance_double(MtgCardMaker::SpriteSheetService)
        allow(sprite_service).to receive(:sprite_dimensions).and_return([200, 150])

        expect do
          cli.send(:display_success_message, { 'card1' => {}, 'card2' => {} }, sprite_service, output_file)
        end.not_to raise_error
      end
    end

    describe '#build_card_config_from_options' do
      it 'builds config with required fields', :aggregate_failures do
        cli.options = {
          name: 'Test Card',
          type_line: 'Creature - Test',
          rules_text: 'A test card'
        }

        result = cli.send(:build_card_config_from_options)
        expect(result['name']).to eq('Test Card')
        expect(result['type_line']).to eq('Creature - Test')
        expect(result['rules_text']).to eq('A test card')
      end

      it 'includes optional fields when provided', :aggregate_failures do
        cli.options = {
          name: 'Test Card',
          type_line: 'Creature - Test',
          rules_text: 'A test card',
          mana_cost: '2R',
          flavor_text: 'Flavor text'
        }

        result = cli.send(:build_card_config_from_options)
        expect(result['mana_cost']).to eq('2R')
        expect(result['flavor_text']).to eq('Flavor text')
      end

      it 'excludes optional fields when not provided', :aggregate_failures do
        cli.options = {
          name: 'Test Card',
          type_line: 'Creature - Test',
          rules_text: 'A test card'
        }

        result = cli.send(:build_card_config_from_options)
        expect(result).not_to have_key('mana_cost')
        expect(result).not_to have_key('flavor_text')
      end
    end

    describe '#generate_card_key' do
      it 'generates key from card name' do
        result = cli.send(:generate_card_key, 'Test Card', {})
        expect(result).to eq('test_card')
      end

      it 'handles special characters in name' do
        result = cli.send(:generate_card_key, 'Test-Card 123!', {})
        expect(result).to eq('test_card_123')
      end

      it 'appends number for duplicate keys' do
        existing_config = { 'test_card' => {} }
        result = cli.send(:generate_card_key, 'Test Card', existing_config)
        expect(result).to eq('test_card_1')
      end

      it 'increments number for multiple duplicates' do
        existing_config = { 'test_card' => {}, 'test_card_1' => {} }
        result = cli.send(:generate_card_key, 'Test Card', existing_config)
        expect(result).to eq('test_card_2')
      end
    end
  end
end
