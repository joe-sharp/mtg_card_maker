# frozen_string_literal: true

require 'fileutils'

module MtgCardMaker
  # IconService loads and renders SVG icons for mana costs.
  # This service handles loading, caching, and resizing of SVG icons
  # for different mana colors and special symbols.
  #
  # @example
  #   service = MtgCardMaker::IconService.new
  #   svg = service.icon_svg(:red, size: 24)
  #
  # @since 0.1.0
  class IconService
    ICONS_DIR = File.join(__dir__, 'icons')
    QR_CODE_PATH = File.join(ICONS_DIR, 'qrcode.svg')
    JSHARP_PATH = File.join(ICONS_DIR, 'jsharp.svg')

    # Available icon sets
    ICON_SETS = {
      default: {
        white: 'white.svg',
        blue: 'blue.svg',
        black: 'black.svg',
        red: 'red.svg',
        green: 'green.svg',
        colorless: 'colorless.svg'
      }
    }.freeze

    attr_reader :icon_set

    def initialize(icon_set = :default)
      @icon_set = icon_set
      @cached_icons = {}
    end

    # Returns the SVG content for a given color and icon set
    def icon_svg(color, size: 30)
      return nil unless valid_color?(color)

      icon_path = icon_path_for_color(color)
      return nil unless File.exist?(icon_path)

      svg_content = load_icon(icon_path)
      resize_svg(svg_content, size)
    end

    # Returns the QR code SVG content
    def qr_code_svg
      return nil unless File.exist?(QR_CODE_PATH)

      load_icon(QR_CODE_PATH)
    end

    # Returns the jsharp icon SVG content
    def jsharp_svg
      return nil unless File.exist?(JSHARP_PATH)

      load_icon(JSHARP_PATH)
    end

    # Returns a list of available colors for the current icon set
    def available_colors
      ICON_SETS[icon_set]&.keys || []
    end

    # Returns a list of available icon sets
    def available_icon_sets
      ICON_SETS.keys
    end

    private

    def valid_color?(color)
      available_colors.include?(color)
    end

    def icon_path_for_color(color)
      filename = ICON_SETS[icon_set][color]
      File.join(ICONS_DIR, filename)
    end

    def load_icon(path)
      @cached_icons[path] ||= File.read(path)
    end

    def resize_svg(svg_content, size)
      # Replace the width and height attributes with the new size
      svg_content.gsub(/width="[^"]*"/, "width=\"#{size}px\"")
                 .gsub(/height="[^"]*"/, "height=\"#{size}px\"")
    end
  end
end
