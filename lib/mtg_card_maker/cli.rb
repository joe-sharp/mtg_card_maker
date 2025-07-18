# frozen_string_literal: true

require 'thor'
require 'yaml'
require 'fileutils'

module MtgCardMaker
  # Thor-based command-line interface for MTG Card Maker.
  # Provides commands for generating individual cards and sprite sheets
  # from YAML configuration files.
  #
  # @example Generate a single card
  #   mtg_card_maker generate_card --name "Lightning Bolt" --type-text "Instant" \
  #     --rules-text "Lightning Bolt deals 3 damage to any target." --color red
  #
  # @example Generate a sprite sheet
  #   mtg_card_maker generate_sprite cards.yml sprite.svg
  #
  # @example Add a card to YAML file
  #   mtg_card_maker add_card cards.yml --name "Lightning Bolt" --type-text "Instant" \
  #     --rules-text "Lightning Bolt deals 3 damage to any target." --color red
  #
  # @since 0.1.0
  class CLI < Thor # rubocop:disable Metrics/ClassLength
    package_name 'mtg_card_maker'
    map 'a'  => :add_card
    map 'ac' => :add_card
    map 'g'  => :generate_card
    map 'gc' => :generate_card
    map 'gcs'=> :generate_sprite
    map 'gs' => :generate_sprite

    def self.exit_on_failure?
      true
    end

    # Define the standard card options for CLI commands
    #
    # @return [Hash] the card option definitions for Thor
    def self.card_options
      {
        name: { type: :string, required: true, desc: 'Card name' },
        mana_cost: { type: :string, aliases: ['mana', 'cost'], desc: 'Mana cost (e.g., "2RR", "XG")' },
        type_line: { type: :string, required: true, aliases: ['type'],
                     desc: 'Card type & subtype (e.g., "Creature - Dragon", "Instant")' },
        rules_text: { type: :string, required: true, aliases: ['rules'], desc: 'Card rules text' },
        flavor_text: { type: :string, aliases: ['flavor'], desc: 'Flavor text (optional)' },
        power: { type: :string, desc: 'Power (for creatures)' },
        toughness: { type: :string, desc: 'Toughness (for creatures)' },
        border_color: { type: :string, aliases: ['border'], desc: 'Border color (white, black, gold, silver)' },
        color: { type: :string,
                 default: 'colorless',
                 desc: 'Card color (white, blue, black, red, green, colorless)' },
        art: { type: :string, aliases: ['artwork', 'image'], desc: 'Image URL or path for card artwork' }
      }
    end

    # Generate a single MTG card with specified parameters
    #
    # @option options [String] :name the card name (required)
    # @option options [String] :mana_cost the mana cost in MTG notation
    # @option options [String] :type_line the card type (required)
    # @option options [String] :rules_text the card rules (required)
    # @option options [String] :flavor_text the flavor text
    # @option options [String] :power the power value for creatures
    # @option options [String] :toughness the toughness value for creatures
    # @option options [String] :border_color the border color
    # @option options [String] :color the card color scheme
    # @option options [String] :art the URL for card artwork
    # @option options [String] :output the output filename (default: output_card.svg)
    # @return [void]
    # @!method generate_card
    #   Generate a single MTG card with specified parameters
    desc 'generate_card [OPTIONS]', 'Generate a single MTG card with specified parameters'
    card_options.each { |option, config| option option, config }
    option :output, type: :string, default: 'output_card.svg', desc: 'Output filename'
    def generate_card
      config = build_card_config_from_options
      # Convert string keys to symbols for BaseCard compatibility
      config = config.transform_keys(&:to_sym)
      card = BaseCard.new(config)
      card.save(options[:output])
      logger.success("Generated #{options[:output]}!")
    end

    # @!method generate_sprite(yaml_file, output_file)
    #   Generate a sprite sheet from YAML configuration
    desc 'generate_sprite YAML_FILE OUTPUT_FILE [OPTIONS]', 'Generate a sprite sheet from YAML configuration'
    option :cards_per_row, type: :numeric, default: 4, desc: 'Number of cards per row in sprite'
    option :spacing, type: :numeric, default: 30, desc: 'Spacing between cards in pixels'
    def generate_sprite(yaml_file, output_file)
      config = validate_yaml(yaml_file)
      sprite_service = create_sprite_service
      process_sprite_generation(config, sprite_service, output_file)
    end

    # @!method add_card(yaml_file)
    #   Add a new card configuration to YAML file
    desc 'add_card YAML_FILE [OPTIONS]', 'Add a new card configuration to YAML file'
    card_options.each { |option, config| option option, config }
    def add_card(yaml_file)
      # Create directory and load/validate config
      config = create_directory_and_load_config(yaml_file)

      # Generate a unique key for the card
      card_key = generate_card_key(options[:name], config)

      # Build card configuration
      card_config = build_card_config_from_options

      # Add to config
      config[card_key] = card_config

      # Save back to file
      File.write(yaml_file, config.to_yaml)
      logger.success("Added card '#{options[:name]}' to #{yaml_file}!")
      logger.info("🎴 Key: #{card_key}")
    end

    private

    def logger
      @logger ||= MtgCardMaker::Logger.new
    end

    def process_sprite_generation(config, sprite_service, output_file)
      if sprite_service.create_sprite_sheet(config, output_file)
        display_success_message(config, sprite_service, output_file)
      else
        logger.error('Failed to generate sprite sheet')
        exit 1
      end
    end

    def handle_yaml_error(error)
      logger.error("Invalid YAML syntax: #{error.message}")
      exit 1
    end

    def handle_general_error(error)
      logger.error(error.message)
      exit 1
    end

    def display_success_message(config, sprite_service, output_file)
      logger.success("Generated #{output_file}!")
      width, height = sprite_service.sprite_dimensions(config.length)
      logger.info("📏 Sprite dimensions: #{width}x#{height} pixels")
      logger.info("🎨 Contains #{config.length} cards")
    end

    def create_sprite_service
      SpriteSheetService.new(
        cards_per_row: options[:cards_per_row],
        spacing: options[:spacing]
      )
    end

    def build_card_config_from_options
      config = build_required_config
      add_optional_fields(config)
      config
    end

    def build_required_config
      {
        'name' => options[:name],
        'type_line' => options[:type_line],
        'rules_text' => process_newlines(options[:rules_text])
      }
    end

    def add_optional_fields(config)
      optional_fields = %w[mana_cost power toughness border_color color art]
      optional_fields.each do |field|
        config[field] = options[field.to_sym] if options[field.to_sym]
      end

      # Handle flavor_text separately to process newlines
      return unless options[:flavor_text]

      config['flavor_text'] = process_newlines(options[:flavor_text])
    end

    def process_newlines(text)
      # Convert literal \n to actual newlines
      text.gsub('\\n', "\n")
    end

    def create_directory_and_load_config(yaml_file)
      # Create directory if it doesn't exist
      FileUtils.mkdir_p(File.dirname(yaml_file))

      # Load and validate config
      validate_yaml(yaml_file)
    end

    def validate_yaml(yaml_file)
      return {} unless File.exist?(yaml_file)

      YAML.safe_load_file(yaml_file) || {}
    rescue Psych::SyntaxError => e
      logger.error("Invalid YAML syntax: #{e.message}")
      exit 1
    rescue StandardError => e
      logger.error("Error reading YAML file: #{e.message}")
      exit 1
    end

    def generate_card_key(name, config)
      base_key = name.downcase.gsub(/[^a-z0-9]/, '_').squeeze('_').chomp('_')

      # If key already exists, append a number
      if config.key?(base_key)
        counter = 1
        counter += 1 while config.key?("#{base_key}_#{counter}")
        "#{base_key}_#{counter}"
      else
        base_key
      end
    end
  end
end
