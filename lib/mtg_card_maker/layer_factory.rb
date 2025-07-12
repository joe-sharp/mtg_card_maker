# frozen_string_literal: true

require_relative 'layers/art_layer'
require_relative 'layers/text_box_layer'
require_relative 'layers/frame_layer'
require_relative 'layers/name_layer'
require_relative 'layers/border_layer'
require_relative 'layers/power_layer'
require_relative 'layers/type_line_layer'

module MtgCardMaker
  # Centralized factory for creating card layers that eliminates duplication
  # between BaseCard and SpriteSheetService. This factory handles the creation
  # of all layer types with proper configuration and dependencies.
  #
  # @example
  #   layers = MtgCardMaker::LayerFactory.create_layers_for_card(card, mask_id, card_config)
  #   layers.each { |layer| template.add_layer(layer) }
  #
  # @since 0.1.0
  class LayerFactory
    # Create all layers for a card using the factory pattern
    #
    # @param card [BaseCard] the card instance
    # @param mask_id [String] the mask ID for art window
    # @param card_config [Object] the card configuration object
    # @return [Array<BaseLayer>] an array of all card layers
    def self.create_layers_for_card(card, mask_id, card_config)
      new(card, mask_id, card_config).create_layers
    end

    # Initialize a new layer factory
    #
    # @param card [BaseCard] the card instance
    # @param mask_id [String] the mask ID for art window
    # @param card_config [Object] the card configuration object
    def initialize(card, mask_id, card_config)
      @card = card
      @mask_id = mask_id
      @card_config = card_config
      @color_scheme = card.color_scheme
    end

    # Create all layers for the card in the correct order
    #
    # @return [Array<BaseLayer>] an array of all card layers in rendering order
    def create_layers
      [
        create_border_layer,
        create_frame_layer,
        create_name_layer,
        create_art_layer,
        create_type_line_layer,
        create_text_box_layer,
        create_power_layer
      ]
    end

    private

    def create_border_layer
      border_color = @card.border_color || :white
      BorderLayer.new(
        dimensions: @card_config.dimensions_for_layer(:border),
        color: border_color,
        mask_id: @mask_id
      )
    end

    def create_frame_layer
      FrameLayer.new(
        dimensions: @card_config.dimensions_for_layer(:frame),
        color_scheme: @color_scheme,
        mask_id: @mask_id
      )
    end

    def create_name_layer
      NameLayer.new(
        dimensions: @card_config.dimensions_for_layer(:name_area),
        name: @card.name,
        cost: @card.mana_cost,
        color_scheme: @color_scheme
      )
    end

    def create_art_layer
      art = @card.art
      ArtLayer.new(
        dimensions: @card_config.dimensions_for_layer(:art_layer),
        color_scheme: @color_scheme,
        art: art
      )
    end

    def create_type_line_layer
      TypeLineLayer.new(
        dimensions: @card_config.dimensions_for_layer(:type_area),
        type_line: @card.type_line,
        color_scheme: @color_scheme
      )
    end

    def create_text_box_layer
      TextBoxLayer.new(
        dimensions: @card_config.dimensions_for_layer(:text_box),
        rules_text: @card.rules_text,
        flavor_text: @card.flavor_text,
        color_scheme: @color_scheme
      )
    end

    def create_power_layer
      PowerLayer.new(
        dimensions: @card_config.dimensions_for_layer(:power_area),
        power: @card.power,
        toughness: @card.toughness,
        color_scheme: @color_scheme
      )
    end
  end
end
