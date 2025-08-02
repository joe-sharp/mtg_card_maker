# frozen_string_literal: true

require 'fileutils'
require 'nokogiri'
require_relative 'icon_filename_service'

module MtgCardMaker
  # IconService loads and renders SVG icons for mana costs.
  # This service handles loading, caching, and resizing of SVG icons
  # for different mana colors and special symbols.
  #
  # @example
  #   service = MtgCardMaker::IconService.new
  #   svg = service.symbol_svg("{W}", size: 24)
  #   svg = service.symbol_svg("{2}", size: 24)
  #   svg = service.symbol_svg("{W/B}", size: 24)
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
      @filename_service = IconFilenameService.new
    end

    # Returns the SVG content for a given symbol string
    # @param symbol_string [String] the symbol string (e.g., "{W}", "{2}", "{W/B}", "{C/P}")
    # @param size [Integer] the size of the icon in pixels
    # @return [String, nil] the SVG content or nil if symbol not found
    def symbol_svg(symbol_string, size: 30)
      icon_type = @filename_service.symbol_to_icon_type(symbol_string)
      return nil unless icon_type

      # Handle numeric icons specially since they need dynamic content
      return render_numeric_icon(symbol_string, size) if icon_type == :numeric

      # Handle regular icons
      icon_path = icon_path_for_type(icon_type)
      return nil unless File.exist?(icon_path)

      svg_content = load_icon(icon_path)
      resize_svg(svg_content, size)
    end

    # Renders a numeric icon with the specified number
    # @param symbol_string [String] the numeric symbol string (e.g., "{2}", "{42}")
    # @param size [Integer] the size of the icon in pixels
    # @return [String, nil] the SVG content or nil if symbol not found
    def render_numeric_icon(symbol_string, size)
      number = extract_number_from_symbol(symbol_string)
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

    def extract_number_from_symbol(symbol_string)
      # Extract the number from symbols like "{2}", "{42}", etc.
      match = symbol_string.match(/\{(\d{1,2})\}/)
      return 'X' unless match

      match[1].to_i
    end

    def valid_icon?(icon_type)
      # Check if the SVG file exists
      File.exist?(icon_path_for_type(icon_type))
    end

    def icon_path_for_type(icon_type)
      icon_type_str = icon_type.to_s

      if (match = icon_type_str.match(/^(phyrexian|hybrid)-(.*)$/))
        subdirectory_icon_path(icon_type: match[2], subdirectory: match[1])
      else
        standard_icon_path(icon_type)
      end
    end

    def subdirectory_icon_path(icon_type:, subdirectory:)
      filename = "#{icon_type}.svg"
      File.join(ICONS_DIR, subdirectory, filename)
    end

    def standard_icon_path(icon_type)
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
