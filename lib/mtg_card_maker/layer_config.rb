# frozen_string_literal: true

require_relative 'core_ext/deep_merge'

module MtgCardMaker
  # Configuration class for layer-specific styling and positioning that centralizes
  # all hardcoded values used across different layers. This class provides a
  # centralized configuration system for font sizes, positioning, frame styling,
  # and other layer-specific settings.
  #
  # @example
  #   config = MtgCardMaker::LayerConfig.new
  #   config.font_size(:name) # => 32
  #   config.corner_radius(:outer) # => { x: 25, y: 25 }
  #
  # @example Custom configuration
  #   custom_config = {
  #     font_sizes: { name: 36, type: 24 },
  #     padding: { horizontal: 20 }
  #   }
  #   config = MtgCardMaker::LayerConfig.new(custom_config)
  #
  # @since 0.1.0
  class LayerConfig
    # Default configuration for all layers
    # @return [Hash] the default configuration hash
    DEFAULT_CONFIG = {
      # Text rendering settings
      font_sizes: {
        name: 32,
        type: 22,
        description: 24,
        flavor_text: 18,
        power_area: 28,
        copyright: 14
      },

      # Text rendering configuration
      text_rendering: {
        default_font_size: 16,
        default_color: '#111',
        default_line_height_multiplier: 1.2,
        char_width_multiplier: 0.42,
        css_classes: {
          card_name: 'card-name',
          card_type: 'card-type',
          card_description: 'card-description',
          flavor_text: 'card-flavor-text',
          power_area: 'card-power-toughness',
          copyright: 'card-copyright'
        }
      },

      # Positioning and spacing
      padding: {
        horizontal: 15,
        vertical: 30
      },

      # Layer-specific positioning offsets
      positioning: {
        name_area: {
          y_offset: 10,
          width_ratio: 0.75
        },
        type_area: {
          y_offset: 8,
          width_ratio: 0.75
        },
        description: {
          y_offset: 30,
          width_ratio: 1.0
        },
        flavor_text: {
          y_offset: 45,
          width_ratio: 1.0,
          separator_offset: 70
        },
        power_area: {
          y_offset: 9
        }
      },

      # Frame styling
      frames: {
        stroke_width: 2,
        corner_radius: {
          name: { x: 10, y: 25 },
          type: { x: 10, y: 25 },
          power: { x: 10, y: 25 },
          art: { x: 8, y: 8 },
          inner: { x: 10, y: 10 },
          outer: { x: 25, y: 25 }
        }
      },

      # Mana cost settings
      mana_cost: {
        circle_radius: 15,
        circle_spacing: 35,
        icon_size: 24,
        max_circles: 10,
        margin: 10
      },

      # Copyright text settings
      copyright: {
        base_y: 830,
        line_spacing: 18,
        x_position: 90
      },

      # Type line icon settings
      type_icon: {
        x_offset: 13,
        y_offset: 4,
        scale: 0.23,
        aspect_ratio: { x: 0.93839063, y: 1.0656543 }
      },

      # Frame settings
      frame: {
        bottom_margin: 120
      },

      # Drop shadow settings
      drop_shadow: {
        dx: -2,
        dy: 2,
        std_deviation: 1,
        flood_opacity: 1.0
      },

      # Text positioning adjustments
      text_positioning: {
        mana_cost_text_y_offset: 7,
        mana_cost_font_size: 24
      },

      # Icon opacity settings
      icon_opacity: {
        mana_cost: 0.7
      }
    }.freeze

    # @return [Hash] the merged configuration hash
    attr_reader :config

    # Initialize a new layer configuration
    #
    # @param custom_config [Hash] custom configuration to merge with defaults
    def initialize(custom_config = {})
      # Extend the DEFAULT_CONFIG hash with deep merge functionality
      default_config_with_merge = DEFAULT_CONFIG.dup.extend(DeepMerge)
      @config = default_config_with_merge.deep_merge(custom_config)
    end

    # Font size getters
    def font_size(layer_type)
      config[:font_sizes][layer_type]
    end

    # Padding getters
    def horizontal_padding
      config[:padding][:horizontal]
    end

    def vertical_padding
      config[:padding][:vertical]
    end

    # Positioning getters
    def positioning(layer_type)
      config[:positioning][layer_type] || {}
    end

    # Frame styling getters
    def stroke_width
      config[:frames][:stroke_width]
    end

    def corner_radius(layer_type)
      config[:frames][:corner_radius][layer_type] || { x: 5, y: 5 }
    end

    # Mana cost getters
    def mana_cost_config
      config[:mana_cost]
    end

    # Copyright getters
    def copyright_config
      config[:copyright]
    end

    # Type icon getters
    def type_icon_config
      config[:type_icon]
    end

    # Text rendering getters
    def text_rendering_config
      config[:text_rendering]
    end

    def default_font_size
      text_rendering_config[:default_font_size]
    end

    def default_text_color
      text_rendering_config[:default_color]
    end

    def default_line_height_multiplier
      text_rendering_config[:default_line_height_multiplier]
    end

    def char_width_multiplier
      text_rendering_config[:char_width_multiplier]
    end

    def css_class(layer_type)
      text_rendering_config[:css_classes][layer_type]
    end

    # Frame getters
    def frame_config
      config[:frame]
    end

    def frame_bottom_margin
      frame_config[:bottom_margin]
    end

    # Drop shadow getters
    def drop_shadow_config
      config[:drop_shadow]
    end

    # Text positioning getters
    def text_positioning_config
      config[:text_positioning]
    end

    def mana_cost_text_y_offset
      text_positioning_config[:mana_cost_text_y_offset]
    end

    def mana_cost_font_size
      text_positioning_config[:mana_cost_font_size]
    end

    # Icon opacity getters
    def icon_opacity_config
      config[:icon_opacity]
    end

    def mana_cost_icon_opacity
      icon_opacity_config[:mana_cost]
    end

    # Convenience methods for common calculations
    def text_width(base_width, layer_type = nil)
      if layer_type && positioning(layer_type)[:width_ratio]
        (base_width * positioning(layer_type)[:width_ratio]) - (horizontal_padding * 2)
      else
        base_width - (horizontal_padding * 2)
      end
    end

    def text_x_position(base_x)
      base_x + horizontal_padding
    end

    def text_y_position(base_y, layer_type, height = nil)
      offset = positioning(layer_type)[:y_offset] || 0
      if height
        base_y + (height / 2) + offset
      else
        base_y + offset
      end
    end

    # Class method for easy access to default config
    def self.default
      new
    end
  end
end
