# frozen_string_literal: true

require_relative 'mtg_card_maker/version'
require 'victor'

# MTG Card Maker is a Ruby gem for creating Magic: The Gathering card templates.
# It uses the Victor SVG library to generate layered card designs with customizable
# colors, text, and artwork. The library provides a modular layer system where
# each component (frame, art, text areas) inherits from BaseLayer and implements
# its own rendering logic.
#
# @example Basic Usage
#   card = MtgCardMaker::BaseCard.new(
#     name: "Lightning Bolt",
#     mana_cost: "R",
#     type: "Instant",
#     description: "Lightning Bolt deals 3 damage to any target.",
#     color_scheme: :red
#   )
#   card.generate("lightning_bolt.svg")
#
# @example Custom Template
#   template = MtgCardMaker::Template.new
#   template.add_layer(MtgCardMaker::BorderLayer.new(dimensions: {...}, color: :red))
#   template.add_layer(MtgCardMaker::NameLayer.new(dimensions: {...}, text: "Lightning Bolt"))
#   template.save("custom_card.svg")
#
# @since 0.1.0
# @author Joe Sharp
module MtgCardMaker
  # Standard MTG card width in pixels
  # @return [Integer] the width of a standard MTG card
  CARD_WIDTH = 630

  # Standard MTG card height in pixels
  # @return [Integer] the height of a standard MTG card
  CARD_HEIGHT = 880

  # Load unified color scheme system
  require_relative 'mtg_card_maker/color_scheme'
  require_relative 'mtg_card_maker/color_palette'
  require_relative 'mtg_card_maker/layer_config'

  # Default color scheme using colorless colors
  # @return [ColorScheme] the default colorless color scheme
  DEFAULT_COLOR_SCHEME = ColorScheme.new(:colorless)

  # Default text color from the default color scheme
  # @return [String] the default text color hex value
  DEFAULT_TEXT_COLOR = DEFAULT_COLOR_SCHEME.text_color

  # White color constant for border compatibility
  # @return [String] the white color hex value
  WHITE = '#EEE'

  # Custom error class for MTG Card Maker specific errors
  class Error < StandardError; end

  # Base class for all card layers that provides common attributes and rendering interface.
  # All layer classes (frames, text areas, art) inherit from this base class and
  # implement their own specific rendering logic.
  #
  # @abstract Subclasses must implement the {#render} method
  # @since 0.1.0
  class BaseLayer
    # @return [Template, nil] the template instance this layer belongs to
    attr_accessor :template

    # @return [Integer] the x-coordinate of the layer
    attr_reader :x

    # @return [Integer] the y-coordinate of the layer
    attr_reader :y

    # @return [Integer] the width of the layer
    attr_reader :width

    # @return [Integer] the height of the layer
    attr_reader :height

    # @return [String] the color of the layer
    attr_reader :color

    # Initialize a new layer with the given dimensions and color
    #
    # @param dimensions [Hash] the layer dimensions
    # @option dimensions [Integer] :x the x-coordinate
    # @option dimensions [Integer] :y the y-coordinate
    # @option dimensions [Integer] :width the width
    # @option dimensions [Integer] :height the height
    # @param color [String] the color of the layer (default: 'white')
    def initialize(dimensions:, color: 'white')
      @x = dimensions[:x]
      @y = dimensions[:y]
      @width = dimensions[:width]
      @height = dimensions[:height]
      @color = color
      @template = nil
    end

    # Render the layer to the SVG canvas
    #
    # @abstract Subclasses must implement this method
    # @raise [NotImplementedError] if not implemented by subclass
    def render
      raise NotImplementedError, "Subclasses must implement the 'render' method."
    end

    # Access the SVG canvas through the template
    #
    # @return [Victor::SVG, nil] the SVG canvas instance
    def svg
      @template&.instance_variable_get(:@svg)
    end
  end

  require_relative 'mtg_card_maker/layer_initializer'
  require_relative 'mtg_card_maker/base_card'
  require_relative 'mtg_card_maker/layer_factory'
  require_relative 'mtg_card_maker/svg_gradient_service'
  require_relative 'mtg_card_maker/text_rendering_service'
  require_relative 'mtg_card_maker/sprite_sheet_assets'
  require_relative 'mtg_card_maker/sprite_sheet_builder'
  require_relative 'mtg_card_maker/sprite_sheet_service'
  require_relative 'mtg_card_maker/layers/border_layer'
  require_relative 'mtg_card_maker/layers/frame_layer'
  require_relative 'mtg_card_maker/layers/name_layer'
  require_relative 'mtg_card_maker/layers/art_layer'
  require_relative 'mtg_card_maker/layers/type_line_layer'
  require_relative 'mtg_card_maker/layers/text_box_layer'
  require_relative 'mtg_card_maker/layers/power_layer'
  require_relative 'mtg_card_maker/cli'

  # Main template class that manages the SVG canvas and layer composition.
  # This class handles creating the SVG canvas, adding layers, and saving
  # the final SVG file. It also manages font embedding and CSS styling.
  #
  # @example
  #   template = MtgCardMaker::Template.new
  #   template.add_layer(MtgCardMaker::BorderLayer.new(dimensions: {...}))
  #   template.add_layer(MtgCardMaker::NameLayer.new(dimensions: {...}, text: "Lightning Bolt"))
  #   template.save("card.svg")
  #
  # @since 0.1.0
  class Template
    # @return [Integer] the width of the SVG canvas
    attr_reader :width

    # @return [Integer] the height of the SVG canvas
    attr_reader :height

    # Initialize a new template with the given dimensions
    #
    # @param width [Integer] the width of the canvas (default: CARD_WIDTH)
    # @param height [Integer] the height of the canvas (default: CARD_HEIGHT)
    # @param embed_font [Boolean] whether to embed the font as base64 (default: false)
    def initialize(width: CARD_WIDTH, height: CARD_HEIGHT, embed_font: false)
      @width = width
      @height = height
      @svg = Victor::SVG.new width: width, height: height
      embed_font(embed: embed_font)
      define_css_classes
    end

    # Add a layer to the template and render it
    #
    # @param layer [BaseLayer] the layer to add and render
    # @return [void]
    def add_layer(layer)
      layer.template = self
      layer.render
    end

    # Save the SVG to a file
    #
    # @param filename [String] the filename to save to
    # @return [void]
    def save(filename)
      @svg.save(filename)
    end

    # Get the SVG as a string
    #
    # @return [String] the SVG content as a string
    def to_svg
      @svg.to_s
    end

    private

    def embed_font(embed: false)
      if embed
        font_path = File.join(__dir__, 'mtg_card_maker', 'fonts', 'goudy_base64.txt')
        base64_font_data = File.read(font_path).strip
        @svg.style <<~CSS
          @font-face {
            font-family: 'Goudy Mediaeval DemiBold';
            src: url(data:font/truetype;charset=utf-8;base64,#{base64_font_data}) format('truetype');
            font-weight: normal;
            font-style: normal;
          }
        CSS
      else
        @svg.style <<~CSS
          @font-face {
            font-family: 'Goudy Mediaeval DemiBold';
            src: url('fonts/Goudy Mediaeval DemiBold.ttf') format('truetype');
            font-weight: normal;
            font-style: normal;
          }
        CSS
      end
    end

    def define_css_classes
      @svg.style <<~CSS
        /* Font Classes */
        .card-name {
          font-family: 'Goudy Mediaeval DemiBold', serif;
          font-weight: normal;
          font-style: normal;
        }

        .card-type {
          font-family: 'Goudy Mediaeval DemiBold', serif;
          font-weight: normal;
          font-style: normal;
        }

        .card-description {
          font-family: serif;
          font-weight: normal;
          font-style: normal;
        }

        .card-flavor-text {
          font-family: serif;
          font-weight: normal;
          font-style: italic;
        }

        .card-power-toughness {
          font-family: serif;
          font-weight: bold;
          font-style: normal;
        }

        .card-copyright {
          font-family: sans-serif;
          font-weight: normal;
          font-style: normal;
        }

        .mana-cost-text {
          font-family: serif;
          font-weight: normal;
          font-style: normal;
        }

        .mana-cost-text-large {
          font-family: serif;
          font-weight: semibold;
          font-style: normal;
        }
      CSS
    end
  end
end
