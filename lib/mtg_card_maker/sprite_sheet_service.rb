# frozen_string_literal: true

require 'tempfile'

module MtgCardMaker
  # Service for creating sprite sheets by generating individual cards
  # and stitching them together using SpriteSheetBuilder and SpriteSheetAssets.
  # This service handles the complete workflow from card configurations to
  # final sprite sheet output, including temporary file management.
  #
  # @example
  #   service = MtgCardMaker::SpriteSheetService.new(cards_per_row: 4, spacing: 30)
  #   success = service.create_sprite_sheet(card_configs, 'output.svg')
  #   width, height = service.sprite_dimensions(card_configs.length)
  #
  # @since 0.1.0
  class SpriteSheetService
    # @return [Integer] the number of cards per row in the sprite sheet
    attr_reader :cards_per_row

    # @return [Integer] the spacing between cards in pixels
    attr_reader :spacing

    # Initialize a new sprite sheet service
    #
    # @param cards_per_row [Integer] the number of cards per row (default: 5)
    # @param spacing [Integer] the spacing between cards in pixels (default: 30)
    def initialize(cards_per_row: 5, spacing: 30)
      @cards_per_row = cards_per_row
      @spacing = spacing
      @builder = SpriteSheetBuilder.new(cards_per_row: cards_per_row, spacing: spacing)
      @assets = SpriteSheetAssets.new
    end

    # Create a sprite sheet from an array of card configurations
    #
    # @param card_configs [Hash] the card configurations
    # @param output_file [String] the output file path
    # @return [Boolean] true if successful, false if no cards provided
    # @raise [StandardError] if card generation or sprite creation fails
    def create_sprite_sheet(card_configs, output_file)
      return false if card_configs.empty?

      begin
        # Generate individual cards first
        card_files = generate_individual_cards(card_configs)

        # Stitch them together into a sprite sheet
        stitch_cards_into_sprite(card_files, output_file)
      ensure
        # Clean up temporary files
        cleanup_temp_files(card_files)
      end
    end

    # Calculate sprite sheet dimensions for a given number of cards
    #
    # @param card_count [Integer] the number of cards in the sprite sheet
    # @return [Array<Integer>] the width and height of the sprite sheet
    def sprite_dimensions(card_count)
      @builder.sprite_dimensions(card_count)
    end

    private

    def logger
      @logger ||= MtgCardMaker::Logger.new
    end

    def generate_individual_cards(card_configs)
      card_files = []

      card_configs.values.each_with_index do |config, index|
        card = card_from_config(config)
        temp_file = save_card_to_temp_file(card, index)
        card_files << temp_file
      rescue StandardError => e
        handle_card_generation_error(e, index, card_files)
      end

      card_files
    end

    def handle_card_generation_error(error, index, card_files)
      cleanup_temp_files(card_files)
      raise "❌ Error generating card #{index}: #{error.message}"
    end

    def card_from_config(config)
      BaseCard.new(
        name: config['name'],
        mana_cost: config['mana_cost'],
        type_line: config['type_line'],
        rules_text: config['rules_text'],
        flavor_text: config['flavor_text'],
        power: config['power'],
        toughness: config['toughness'],
        color: config['color'],
        border_color: config['border_color'],
        art: config['art']
      )
    end

    def save_card_to_temp_file(card, index)
      temp_file = Tempfile.new(["card_#{index}", '.svg'])
      card.save(temp_file.path)
      temp_file
    end

    def stitch_cards_into_sprite(card_files, output_file)
      width, height = sprite_dimensions(card_files.length)
      builder = @builder.create_sprite_builder(width, height, card_files, @assets)
      @builder.write_sprite_file(output_file, builder)
      true
    rescue StandardError => e
      raise "❌ Error creating sprite sheet: #{e.message}"
    end

    def cleanup_temp_files(card_files)
      return if card_files.nil?

      card_files.each do |file|
        file.close
        file.unlink
      rescue StandardError => e
        logger.warn("Could not clean up temp file #{file.path}: #{e.message}")
      end
    end
  end
end
