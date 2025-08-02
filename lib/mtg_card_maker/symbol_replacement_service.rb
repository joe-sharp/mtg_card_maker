# frozen_string_literal: true

require 'cgi'

module MtgCardMaker
  # SymbolReplacementService handles the parsing and rendering of MTG symbols in text
  # It converts text with symbol notation (like {W}, {2}, {T}) into HTML with inline SVG icons
  class SymbolReplacementService
    attr_reader :font_size, :icon_service, :layer_config

    def initialize
      @layer_config = LayerConfig.default
      @font_size = layer_config.font_size(:text_box)
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
      # Get the SVG content from IconService
      icon_svg = icon_service.symbol_svg(symbol)

      return unless icon_svg

      # Determine icon size based on symbol type using IconService
      icon_size = get_icon_size_for_symbol(symbol)

      # Use the SVG content directly with proper styling
      icon_svg.gsub(/width="[^"]*"/, "width='#{icon_size}'")
              .gsub(/height="[^"]*"/, "height='#{icon_size}'")
              .gsub('<svg', '<svg style="vertical-align: middle; margin: 0 5px;"')
    end

    def get_icon_size_for_symbol(symbol)
      # Use IconService to determine if this is a hybrid or phyrexian symbol
      # Check if the symbol contains '/' which indicates hybrid or phyrexian
      if symbol.match?(%r{\{.*/.*\}})
        layer_config.text_box_config[:hybrid_icon_size]
      else
        layer_config.text_box_config[:icon_size]
      end
    end
  end
end
