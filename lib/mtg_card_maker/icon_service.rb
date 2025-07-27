# frozen_string_literal: true

require 'fileutils'
require 'nokogiri'

module MtgCardMaker
  # IconService loads and renders SVG icons for mana costs.
  # This service handles loading, caching, and resizing of SVG icons
  # for different mana colors and special symbols.
  #
  # @example
  #   service = MtgCardMaker::IconService.new
  #   svg = service.icon_svg(:red, size: 24)
  #   svg = service.numeric_icon_svg(5, size: 24)
  #
  # @since 0.1.0
  class IconService
    ICONS_DIR = File.join(__dir__, 'icons')
    QR_CODE_PATH = File.join(ICONS_DIR, 'qrcode.svg')
    JSHARP_PATH = File.join(ICONS_DIR, 'jsharp.svg')
    SINGLE_DIGIT_PATH = File.join(ICONS_DIR, 'single-digit.svg')
    DOUBLE_DIGIT_PATH = File.join(ICONS_DIR, 'double-digit.svg')

    attr_reader :icon_set

    def initialize(icon_set = :default)
      @icon_set = icon_set
      @cached_icons = {}
    end

    # Returns the SVG content for a given icon type and icon set
    def icon_svg(icon_type, size: 30)
      return nil unless valid_icon?(icon_type)

      icon_path = icon_path_for_type(icon_type)
      return nil unless File.exist?(icon_path)

      svg_content = load_icon(icon_path)
      resize_svg(svg_content, size)
    end

    # Returns the SVG content for a numeric icon with the specified number
    def numeric_icon_svg(number, size: 30)
      return nil unless number.is_a?(Integer) && number >= 0

      # Determine which template to use based on digit count
      template_path = number.to_s.length == 1 ? SINGLE_DIGIT_PATH : DOUBLE_DIGIT_PATH
      return nil unless File.exist?(template_path)

      svg_content = load_icon(template_path)
      updated_content = update_numeric_content(svg_content, number)
      resize_svg(updated_content, size)
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

    # Returns a list of available icon types for the current icon set
    def available_icon_types
      # Scan the icons directory for available SVG files
      Dir.glob(File.join(ICONS_DIR, '*.svg')).map do |path|
        File.basename(path, '.svg').to_sym
      end
    end

    # Returns a list of available icon sets
    def available_icon_sets
      self.class.icon_sets
    end

    # Class method to return available icon sets
    def self.icon_sets
      [:default]
    end

    private

    def valid_icon?(icon_type)
      # Check if the SVG file exists
      File.exist?(icon_path_for_type(icon_type))
    end

    def icon_path_for_type(icon_type)
      # Auto-map any symbol to {symbol}.svg
      filename = "#{icon_type}.svg"
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

    def update_numeric_content(svg_content, number)
      doc = Nokogiri::XML(svg_content)
      text_element = doc.at_css('text')

      text_element.content = number.to_s if text_element

      # Return just the SVG element content without XML declaration
      doc.at_css('svg').to_xml
    end
  end
end
