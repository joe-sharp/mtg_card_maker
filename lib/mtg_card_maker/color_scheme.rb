# frozen_string_literal: true

module MtgCardMaker
  # Unified color scheme system for MTG cards that provides predefined color
  # schemes for different MTG colors and card types. This class replaces
  # multiple separate color classes with a single configurable system that
  # includes gradients, metallic effects, and consistent color palettes.
  #
  # @example
  #   scheme = MtgCardMaker::ColorScheme.new(:red)
  #   scheme.frame_gradient_colors # => ["#F44336", "#D32F2F", "#B71C1C"]
  #   scheme.text_color # => "#111"
  #
  # @example Using predefined schemes
  #   red_scheme = MtgCardMaker::ColorScheme.red
  #   blue_scheme = MtgCardMaker::ColorScheme.blue
  #   colorless_scheme = MtgCardMaker::ColorScheme.colorless
  #
  # @since 0.1.0
  class ColorScheme # rubocop:disable Metrics/ClassLength
    # Predefined color schemes for all MTG colors and card types
    # @return [Hash] the predefined color scheme configurations
    SCHEMES = {
      colorless: {
        frame_gradient: ['#8B8B8B', '#6B6B6B', '#4A4A4A'],
        name_gradient: ['#F5F5F5', '#E8E8E8', '#D4D4D4'],
        description_gradient: ['#F5F5F5', '#E8E8E8', '#D4D4D4'],
        card_gradient: ['#3D3D3D', '#111', '#1A1A1A'],
        primary: '#8B8B8B',
        background: '#E8E8E8',
        border: '#8B8B8B',
        text: '#111',
        metallic_highlight: ['#FFFFFF', '#E0E0E0', '#8B8B8B'],
        metallic_shadow: ['#B0B0B0', '#8B8B8B', '#6B6B6B'],
        metallic_pattern: ['#F5F5F5', '#B0B0B0']
      },
      white: {
        frame_gradient: ['#FFF9C4', '#F5F5F5', '#BDB76B'],
        name_gradient: ['#FFFFFF', '#FFF9C4', '#E0E0E0'],
        description_gradient: ['#FFFFFF', '#F5F5F5', '#E0E0E0'],
        card_gradient: ['#D7CCC8', '#BCAAA4', '#8D6E63'],
        primary: '#8B8B8B',
        background: '#FFFFFF',
        border: '#F5F5F5',
        text: '#111'
      },
      blue: {
        frame_gradient: ['#42A5F5', '#1565C0', '#263238'],
        name_gradient: ['#E3F2FD', '#BBDEFB', '#90CAF9'],
        description_gradient: ['#F3F8FF', '#E3F2FD', '#BBDEFB'],
        card_gradient: ['#546E7A', '#37474F', '#263238'],
        primary: '#42A5F5',
        background: '#E3F2FD',
        border: '#1565C0',
        text: '#111'
      },
      black: {
        frame_gradient: ['#424242', '#212121', '#000'],
        name_gradient: ['#E0E0E0', '#BDBDBD', '#9E9E9E'],
        description_gradient: ['#F5F5F5', '#E0E0E0', '#BDBDBD'],
        card_gradient: ['#424242', '#212121', '#000'],
        primary: '#424242',
        background: '#E0E0E0',
        border: '#212121',
        text: '#111'
      },
      red: {
        frame_gradient: ['#F44336', '#D32F2F', '#B71C1C'],
        name_gradient: ['#FFEBEE', '#FFCDD2', '#EF9A9A'],
        description_gradient: ['#FFEBEE', '#FFCDD2', '#EF9A9A'],
        card_gradient: ['#8D6E63', '#6D4C41', '#4E342E'],
        primary: '#F44336',
        background: '#FFEBEE',
        border: '#D32F2F',
        text: '#111'
      },
      green: {
        frame_gradient: ['#4CAF50', '#388E3C', '#2E7D32'],
        name_gradient: ['#E8F5E8', '#C8E6C9', '#A5D6A7'],
        description_gradient: ['#F1F8E9', '#E8F5E8', '#C8E6C9'],
        card_gradient: ['#6D4C41', '#5D4037', '#4E342E'],
        primary: '#4CAF50',
        background: '#E8F5E8',
        border: '#388E3C',
        text: '#111'
      },
      gold: {
        frame_gradient: ['#FFD700', '#FFA500', '#FF8C00'],
        name_gradient: ['#F5DEB3', '#E1C16E', '#C9A13B'],
        description_gradient: ['#FFF8DC', '#FFE4B5', '#FFDAB9'],
        card_gradient: ['#8B7355', '#6B4423', '#4A2C0A'],
        primary: '#FFD700',
        background: '#FFF8DC',
        border: '#FFA500',
        text: '#111',
        metallic_highlight: ['#FFFF99', '#FFD700', '#FFA500'],
        metallic_shadow: ['#B8860B', '#8B6914', '#654321'],
        metallic_pattern: ['#FFFACD', '#DAA520']
      },
      artifact: {
        frame_gradient: ['#D2B48C', '#BC8F8F', '#A0522D'],
        name_gradient: ['#F5F5DC', '#DEB887', '#CD853F'],
        description_gradient: ['#F5F5DC', '#DEB887', '#CD853F'],
        card_gradient: ['#8B7355', '#6B4423', '#4A2C0A'],
        primary: '#D2B48C',
        background: '#F5F5DC',
        border: '#BC8F8F',
        text: '#111'
      }
    }.freeze

    # @return [Symbol] the name of the current color scheme
    attr_reader :scheme_name

    # @return [Hash] the configuration for the current color scheme
    attr_reader :config

    # Initialize a new color scheme with the given name
    #
    # @param scheme_name [Symbol, String] the name of the color scheme
    #   (default: :colorless)
    # @return [ColorScheme] a new color scheme instance
    def initialize(scheme_name = :colorless)
      @scheme_name = scheme_name.to_sym
      @config = SCHEMES[@scheme_name] || SCHEMES[:colorless]
    end

    # Frame gradient colors (outer to inner)
    #
    # @return [String] the border gradient color
    def frame_gradient_start
      config[:frame_gradient][0]
    end

    # @return [String] the middle frame gradient color
    def frame_gradient_middle
      config[:frame_gradient][1]
    end

    # @return [String] the frame gradient color
    def frame_gradient_end
      config[:frame_gradient][2]
    end

    # @return [Array<String>] all frame gradient colors from outer to inner
    def frame_gradient_colors
      config[:frame_gradient]
    end

    # Name gradient colors (light to dark)
    #
    # @return [String] the lightest name gradient color
    def name_gradient_start
      config[:name_gradient][0]
    end

    # @return [String] the middle name gradient color
    def name_gradient_middle
      config[:name_gradient][1]
    end

    # @return [String] the darkest name gradient color
    def name_gradient_end
      config[:name_gradient][2]
    end

    # @return [Array<String>] all name gradient colors from light to dark
    def name_gradient_colors
      config[:name_gradient]
    end

    # Description gradient colors
    def description_gradient_start
      config[:description_gradient][0]
    end

    def description_gradient_middle
      config[:description_gradient][1]
    end

    def description_gradient_end
      config[:description_gradient][2]
    end

    def description_gradient_colors
      config[:description_gradient]
    end

    # Card gradient colors
    def card_gradient_start
      config[:card_gradient][0]
    end

    def card_gradient_middle
      config[:card_gradient][1]
    end

    def card_gradient_end
      config[:card_gradient][2]
    end

    def card_gradient_colors
      config[:card_gradient]
    end

    # Primary colors
    def primary_color
      config[:primary]
    end

    def background_color
      config[:background]
    end

    def border_color
      config[:border]
    end

    def text_color
      config[:text]
    end

    # Metallic highlight gradient colors
    def metallic_highlight_start
      config[:metallic_highlight]&.first
    end

    def metallic_highlight_middle
      config[:metallic_highlight]&.[](1)
    end

    def metallic_highlight_end
      config[:metallic_highlight]&.[](2)
    end

    # Metallic shadow gradient colors
    def metallic_shadow_start
      config[:metallic_shadow]&.first
    end

    def metallic_shadow_middle
      config[:metallic_shadow]&.[](1)
    end

    def metallic_shadow_end
      config[:metallic_shadow]&.[](2)
    end

    # Metallic pattern colors
    def metallic_pattern_light
      config[:metallic_pattern]&.first
    end

    def metallic_pattern_dark
      config[:metallic_pattern]&.[](1)
    end

    # Convenience methods for backward compatibility
    #
    # @return [ColorScheme] a colorless color scheme
    def self.colorless
      new(:colorless)
    end

    # @return [ColorScheme] a white color scheme
    def self.white
      new(:white)
    end

    # @return [ColorScheme] a blue color scheme
    def self.blue
      new(:blue)
    end

    # @return [ColorScheme] a black color scheme
    def self.black
      new(:black)
    end

    # @return [ColorScheme] a red color scheme
    def self.red
      new(:red)
    end

    # @return [ColorScheme] a green color scheme
    def self.green
      new(:green)
    end

    # @return [ColorScheme] a gold color scheme
    def self.gold
      new(:gold)
    end

    # @return [ColorScheme] an artifact color scheme
    def self.artifact
      new(:artifact)
    end

    # @return [ColorScheme] a silver color scheme
    def self.silver
      new(:silver)
    end
  end
end
