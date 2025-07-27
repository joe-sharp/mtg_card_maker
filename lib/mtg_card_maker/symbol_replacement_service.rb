# frozen_string_literal: true

require 'cgi'

module MtgCardMaker
  # SymbolReplacementService handles the parsing and rendering of MTG symbols in text
  # It converts text with symbol notation (like {W}, {2}, {T}) into HTML with inline SVG icons
  class SymbolReplacementService
    # Mapping of mtg notation to icons
    SYMBOL_MAP = {
      'B' => :black,
      'U' => :blue,
      'G' => :green,
      'W' => :white,
      'R' => :red,
      'C' => :colorless,
      'T' => :tap,
      'Q' => :untap,
      'E' => :energy,
      'S' => :snow,
      'X' => :x
    }.freeze
    attr_reader :font_size, :icon_service

    def initialize
      @font_size = LayerConfig.default.font_size(:text_box)
      @icon_service = IconService.new
    end

    # Check if text contains MTG symbols
    # @param text [String] the text to check
    # @return [Boolean] true if text contains symbols
    def contains_symbols?(text)
      return false if text.nil?

      text.match?(/\{[^}]+\}/)
    end

    # Split text into parts: symbols and non-symbols
    # @param text [String] the text to split
    # @return [Array<String>] array of text parts and symbols
    def split_text_and_symbols(text)
      # Split text into parts: symbols and non-symbols using regex
      # This matches symbols like {W}, {2}, {T}, etc. and captures them as separate parts
      # Regex: The character { followed by any character except }, then closed by }
      text.split(/(\{[^}]+\})/).reject(&:empty?)
    end

    # Render a line with symbols as HTML
    # @param line [String] the line containing symbols
    # @param text_width [Integer] the width available for text
    # @return [String] HTML string with symbols rendered as inline SVG
    def render_line_with_symbols(line, text_width)
      parts = split_text_and_symbols(line)

      # Use foreignObject with HTML for proper text/symbol alignment
      render_html_line_with_symbols(parts, text_width)

      # Return the HTML content that can be embedded in SVG foreignObject
    end

    private

    # Render HTML line with symbols
    # @param parts [Array<String>] array of text parts and symbols
    # @param text_width [Integer] the width available for text
    # @return [String] HTML string with proper styling
    def render_html_line_with_symbols(parts, _text_width)
      html_parts = parts.map do |part|
        if part.start_with?('{') && part.end_with?('}')
          # Render symbol as inline SVG
          render_symbol_html(part)
        else
          # Escape HTML and render as text
          CGI.escape_html(part)
        end
      end

      # Wrap in a div with proper styling
      <<~HTML
        <div xmlns='http://www.w3.org/1999/xhtml' style='display: flex; align-items: center; font-size: #{font_size}px;'>
          #{html_parts.join}
        </div>
      HTML
    end

    # Render a single symbol as HTML
    # @param symbol [String] the symbol in {symbol} format
    # @return [String, nil] HTML string for the symbol or nil if not found
    def render_symbol_html(symbol)
      # Convert symbol to mana cost format and use IconService
      symbol = symbol.gsub(/[{}]/, '')

      # Get the SVG content from IconService
      icon_svg = if symbol.match?(/^\d+$/)
                   handle_numeric_symbol(symbol)
                 else
                   icon_service.icon_svg(SYMBOL_MAP[symbol])
                 end

      return unless icon_svg

      # Use the SVG content directly with proper styling
      icon_svg.gsub(/width="[^"]*"/, 'width="24"')
              .gsub(/height="[^"]*"/, 'height="24"')
              .gsub('<svg', '<svg style="vertical-align: middle; margin: 0 5px;"')
    end

    # Handle numeric symbols, converting numbers 100+ to X symbols
    # @param symbol [String] the numeric symbol string
    # @return [String, nil] SVG content for the symbol or nil if not found
    def handle_numeric_symbol(symbol)
      numeric_value = symbol.to_i

      # Convert numbers 100 and above to X symbols (like ManaCost does)
      if numeric_value >= 100
        icon_service.icon_svg(:x)
      else
        icon_service.numeric_icon_svg(numeric_value)
      end
    end
  end
end
