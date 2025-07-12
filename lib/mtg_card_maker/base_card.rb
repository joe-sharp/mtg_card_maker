# frozen_string_literal: true

require_relative 'layers/art_layer'
require_relative 'layers/text_box_layer'
require_relative 'layers/frame_layer'
require_relative 'layers/name_layer'
require_relative 'layers/border_layer'
require_relative 'layers/power_layer'
require_relative 'layers/type_line_layer'

module MtgCardMaker
  # Base class for all Magic: The Gathering card types that provides common
  # functionality with simplified configuration. This class handles the creation
  # of complete MTG cards with all necessary layers (frames, text, art, etc.)
  # using predefined dimensions and layouts.
  #
  # @example
  #   card = MtgCardMaker::BaseCard.new(
  #     name: "Lightning Bolt",
  #     mana_cost: "R",
  #     type_line: "Instant",
  #     rules_text: "Lightning Bolt deals 3 damage to any target.",
  #     color_scheme: :red
  #   )
  #   card.save("lightning_bolt.svg")
  #
  # @since 0.1.0
  class BaseCard
    # Fixed defaults for card layout and dimensions
    # @return [Hash] the default configuration for card layers and dimensions
    DEFAULTS = {
      layers: {
        border: {
          x: 0,
          y: 0,
          width: 630,
          height: 880
        },
        frame: {
          x: 10,
          y: 10,
          width: 610,
          height: 860
        },
        name_area: {
          x: 30,
          y: 40,
          width: 570,
          height: 50
        },
        art_layer: {
          x: 40,
          y: 95,
          width: 550,
          height: 400,
          corner_radius: { x: 5, y: 5 }
        },
        type_area: {
          x: 30,
          y: 500,
          width: 570,
          height: 40
        },
        text_box: {
          x: 40,
          y: 545,
          width: 550,
          height: 265
        },
        power_area: {
          x: 455,
          y: 790,
          width: 140,
          height: 40
        }
      },
      mask_id: 'artWindowMask',
      frame_stroke_width: 2
    }.freeze

    # @return [String, nil] the card name
    attr_reader :name

    # @return [String, nil] the mana cost in MTG notation (e.g., "R", "1U")
    attr_reader :mana_cost

    # @return [String, nil] the card type (e.g., "Instant", "Creature")
    attr_reader :type_line

    # @return [String, nil] the card description/rules text
    attr_reader :rules_text

    # @return [String, nil] the flavor text (italic text at bottom)
    attr_reader :flavor_text

    # @return [String, nil] the power value for creatures
    attr_reader :power

    # @return [String, nil] the toughness value for creatures
    attr_reader :toughness

    # @return [String, nil] the border color
    attr_reader :border_color

    # @return [ColorScheme] the color scheme for the card
    attr_reader :color_scheme

    # @return [String, nil] the URL or path for the card artwork
    attr_reader :art

    # Initialize a new card with the given configuration
    #
    # @param config [Hash] the card configuration
    # @option config [String] :name the card name
    # @option config [String] :mana_cost the mana cost in MTG notation
    # @option config [String] :type_line the card type
    # @option config [String] :rules_text the card rules text
    # @option config [String] :flavor_text the flavor text
    # @option config [String] :power the power value for creatures
    # @option config [String] :toughness the toughness value for creatures
    # @option config [String] :border_color the border color
    # @option config [Symbol, String] :color the color scheme
    # @option config [String] :art the URL or path for card artwork
    def initialize(config)
      assign_attributes(config)
      @template = Template.new
      add_layers
    end

    # Save the card to an SVG file
    #
    # @param filename [String] the filename to save to
    # @return [void]
    def save(filename)
      @template.save(filename)
    end

    # @private
    def use_color_scheme(color)
      if color
        ColorScheme.new(color)
      else
        DEFAULT_COLOR_SCHEME
      end
    end

    # Delegate dimension methods to DEFAULTS for LayerFactory compatibility
    # @private
    def card_width
      CARD_WIDTH
    end

    # @private
    def card_height
      CARD_HEIGHT
    end

    # @private
    def dimensions_for_layer(layer_name)
      DEFAULTS[:layers][layer_name.to_sym] || {}
    end

    # @private
    def art_window_config
      DEFAULTS[:layers][:art_layer]
    end

    # @private
    def frame_stroke_width
      DEFAULTS[:frame_stroke_width]
    end

    private

    def assign_attributes(config)
      @name = config[:name]
      @mana_cost = config[:mana_cost]
      @type_line = config[:type_line]
      @rules_text = config[:rules_text]
      @flavor_text = config[:flavor_text]
      @power = config[:power]
      @toughness = config[:toughness]
      @border_color = config[:border_color]
      @color_scheme = use_color_scheme(config[:color])
      @art = config[:art]
    end

    def define_art_window_mask
      svg = @template.instance_variable_get(:@svg)
      svg.defs do
        svg.mask id: DEFAULTS[:mask_id] do
          # White rectangle covers the entire card (opaque)
          svg.rect x: 0, y: 0, width: '100%', height: '100%', fill: '#FFF'
          # Black rectangle creates the transparent window at art position
          art_config = art_window_config
          svg.rect x: art_config[:x], y: art_config[:y],
                   width: art_config[:width], height: art_config[:height],
                   fill: '#000', rx: art_config[:corner_radius][:x], ry: art_config[:corner_radius][:y]
        end
      end
    end

    def add_layers
      define_art_window_mask
      # Use LayerFactory to create layers in order
      layers = LayerFactory.create_layers_for_card(self, DEFAULTS[:mask_id], self)
      layers.each { |layer| @template.add_layer(layer) }
    end
  end
end
