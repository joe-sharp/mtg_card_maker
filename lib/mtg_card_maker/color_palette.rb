# frozen_string_literal: true

module MtgCardMaker
  # ColorPalette aggregates the five core interface colors for cohesive design.
  # It focuses on background elements, buttons, borders, and other UI components,
  # excluding text color. Multiple instances can be created for different themes
  # (default, dark, corporate, etc.).
  #
  # @example
  #   palette = MtgCardMaker::ColorPalette.new(
  #     primary_color: '#42A5F5',
  #     background_color: '#E3F2FD',
  #     border_color: '#1565C0'
  #   )
  #   palette.primary_color # => "#42A5F5"
  #
  # @example Using predefined themes
  #   dark_palette = MtgCardMaker::ColorPalette.dark
  #   light_palette = MtgCardMaker::ColorPalette.light
  #   default_palette = MtgCardMaker::ColorPalette.default
  #
  # @since 0.1.0
  class ColorPalette
    # @return [String] the primary color
    attr_reader :primary_color

    # @return [String] the background color
    attr_reader :background_color

    # @return [String] the border color
    attr_reader :border_color

    # @return [String] the frame stroke color
    attr_reader :frame_stroke_color

    # @return [String] the accent color
    attr_reader :accent_color

    # Default frame stroke color used across the application
    # @return [String] the default frame stroke color
    FRAME_STROKE_COLOR = '#111'

    # Initialize a new color palette
    #
    # @param primary_color [String, nil] the primary color (default: from default color scheme)
    # @param background_color [String, nil] the background color (default: from default color scheme)
    # @param border_color [String, nil] the border color (default: from default color scheme)
    # @param frame_stroke_color [String] the frame stroke color (default: FRAME_STROKE_COLOR)
    # @param accent_color [String, nil] the accent color (default: from default color scheme)
    def initialize(primary_color: nil, background_color: nil, border_color: nil,
                   frame_stroke_color: FRAME_STROKE_COLOR, accent_color: nil)
      @primary_color = primary_color || DEFAULT_COLOR_SCHEME.primary_color
      @background_color = background_color || DEFAULT_COLOR_SCHEME.background_color
      @border_color = border_color || DEFAULT_COLOR_SCHEME.border_color
      @frame_stroke_color = frame_stroke_color
      @accent_color = accent_color || DEFAULT_COLOR_SCHEME.primary_color
    end

    # Create a palette from a color scheme
    #
    # @param color_scheme [ColorScheme] the color scheme to create palette from
    # @return [ColorPalette] a new color palette based on the color scheme
    def self.from_color_scheme(color_scheme)
      new(
        primary_color: color_scheme.primary_color,
        background_color: color_scheme.background_color,
        border_color: color_scheme.border_color,
        accent_color: color_scheme.primary_color
      )
    end

    # Default palette using the default color scheme
    #
    # @return [ColorPalette] the default color palette
    def self.default
      from_color_scheme(DEFAULT_COLOR_SCHEME)
    end

    # Dark theme palette
    #
    # @return [ColorPalette] a dark theme color palette
    def self.dark
      new(
        primary_color: '#2A2A2A',
        background_color: '#1A1A1A',
        border_color: '#4A4A4A',
        frame_stroke_color: '#333',
        accent_color: '#6B6B6B'
      )
    end

    # Light theme palette
    #
    # @return [ColorPalette] a light theme color palette
    def self.light
      new(
        primary_color: '#E8E8E8',
        background_color: '#F5F5F5',
        border_color: '#D4D4D4',
        frame_stroke_color: '#666',
        accent_color: '#8B8B8B'
      )
    end

    # Return all colors as a hash for easy access
    def to_h
      {
        primary_color: @primary_color,
        background_color: @background_color,
        border_color: @border_color,
        frame_stroke_color: @frame_stroke_color,
        accent_color: @accent_color
      }
    end

    # Return all colors as an array
    def to_a
      [@primary_color, @background_color, @border_color, @frame_stroke_color, @accent_color]
    end

    # Check if this palette matches another
    def ==(other)
      return false unless other.is_a?(ColorPalette)

      to_h == other.to_h
    end

    alias_method :eql?, :==

    # Generate a hash for this palette
    def hash
      to_h.hash
    end
  end
end
