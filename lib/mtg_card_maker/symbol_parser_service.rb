# frozen_string_literal: true

require_relative 'icon_service'

module MtgCardMaker
  # SymbolParserService parses MTG symbols from rule text and converts them to inline SVG.
  # This service handles parsing of mana symbols, tap/untap symbols, and other MTG symbols
  # and replaces them with appropriate SVG icons while maintaining text flow.
  #
  # @example
  #   service = MtgCardMaker::SymbolParserService.new
  #   processed_text = service.process_text("{T}: Add {G}.")
  #
  # @since 0.1.0
  class SymbolParserService
    # Supported symbol patterns
    SYMBOL_PATTERNS = {
      # Colored mana symbols
      '{W}' => { type: :colored_mana, color: :white, size: 16 },
      '{U}' => { type: :colored_mana, color: :blue, size: 16 },
      '{B}' => { type: :colored_mana, color: :black, size: 16 },
      '{R}' => { type: :colored_mana, color: :red, size: 16 },
      '{G}' => { type: :colored_mana, color: :green, size: 16 },
      '{C}' => { type: :colored_mana, color: :colorless, size: 16 },

      # Generic mana symbols
      '{0}' => { type: :generic_mana, value: 0, size: 16 },
      '{1}' => { type: :generic_mana, value: 1, size: 16 },
      '{2}' => { type: :generic_mana, value: 2, size: 16 },
      '{3}' => { type: :generic_mana, value: 3, size: 16 },
      '{4}' => { type: :generic_mana, value: 4, size: 16 },
      '{5}' => { type: :generic_mana, value: 5, size: 16 },
      '{6}' => { type: :generic_mana, value: 6, size: 16 },
      '{7}' => { type: :generic_mana, value: 7, size: 16 },
      '{8}' => { type: :generic_mana, value: 8, size: 16 },
      '{9}' => { type: :generic_mana, value: 9, size: 16 },
      '{10}' => { type: :generic_mana, value: 10, size: 16 },
      '{X}' => { type: :generic_mana, value: 'X', size: 16 },

      # Hybrid mana symbols
      '{W/U}' => { type: :hybrid_mana, colors: [:white, :blue], size: 16 },
      '{W/B}' => { type: :hybrid_mana, colors: [:white, :black], size: 16 },
      '{U/B}' => { type: :hybrid_mana, colors: [:blue, :black], size: 16 },
      '{U/R}' => { type: :hybrid_mana, colors: [:blue, :red], size: 16 },
      '{B/R}' => { type: :hybrid_mana, colors: [:black, :red], size: 16 },
      '{B/G}' => { type: :hybrid_mana, colors: [:black, :green], size: 16 },
      '{R/G}' => { type: :hybrid_mana, colors: [:red, :green], size: 16 },
      '{R/W}' => { type: :hybrid_mana, colors: [:red, :white], size: 16 },
      '{G/W}' => { type: :hybrid_mana, colors: [:green, :white], size: 16 },
      '{G/U}' => { type: :hybrid_mana, colors: [:green, :blue], size: 16 },

      # Action symbols
      '{T}' => { type: :action_symbol, action: :tap, size: 16 },
      '{Q}' => { type: :action_symbol, action: :untap, size: 16 },
      '{E}' => { type: :action_symbol, action: :energy, size: 16 }
    }.freeze

    # @return [IconService] the icon service for rendering symbols
    attr_reader :icon_service

    # Initialize a new symbol parser service
    #
    # @param icon_set [Symbol] the icon set to use (default: :default)
    def initialize(icon_set = :default)
      @icon_service = IconService.new(icon_set)
    end

    # Process text and replace symbols with inline SVG
    #
    # @param text [String] the text containing symbols to process
    # @return [String] the processed text with symbols replaced by SVG
    def process_text(text)
      return text if text.nil? || text.empty?

      processed_text = text.dup

      # Process symbols in order of specificity (longer patterns first)
      sorted_patterns = SYMBOL_PATTERNS.sort_by { |pattern, _| -pattern.length }

      sorted_patterns.each do |pattern, config|
        processed_text = replace_symbol(processed_text, pattern, config)
      end

      # Handle unsupported symbols with fallback
      replace_unsupported_symbols(processed_text)
    end

    # Get a list of all supported symbols
    #
    # @return [Array<String>] list of supported symbol patterns
    def supported_symbols
      SYMBOL_PATTERNS.sort_by { |pattern, _| -pattern.length }.map(&:first)
    end

    # Check if a symbol is supported
    #
    # @param symbol [String] the symbol to check
    # @return [Boolean] true if the symbol is supported
    def supported?(symbol)
      SYMBOL_PATTERNS.key?(symbol)
    end

    private

    def replace_symbol(text, pattern, config)
      text.gsub(pattern) do |match|
        generate_symbol_svg(match, config)
      end
    end

    def generate_symbol_svg(symbol, config)
      case config[:type]
      when :colored_mana
        generate_colored_mana_svg(config)
      when :generic_mana
        generate_generic_mana_svg(config)
      when :hybrid_mana
        generate_hybrid_mana_svg(config)
      when :action_symbol
        generate_action_symbol_svg(config)
      else
        symbol # Return original if unknown type
      end
    end

    def generate_colored_mana_svg(config)
      color = config[:color]
      size = config[:size]

      icon_svg = @icon_service.icon_svg(color, size: size)
      return symbol_fallback(size) unless icon_svg

      # Create a circle with the icon inside
      circle_radius = size / 2
      fill = svg_color(color)

      <<~SVG.delete("\n")
        <g style="display: inline-block; vertical-align: middle;">
        <circle cx="#{circle_radius}" cy="#{circle_radius}" r="#{circle_radius}" fill="#{fill}" />
        <g transform="translate(0, 0)" opacity="0.8">#{icon_svg}</g>
        </g>
      SVG
    end

    def generate_generic_mana_svg(config)
      value = config[:value]
      size = config[:size]

      circle_radius = size / 2
      text = value.to_s
      font_size = (size * 0.6).to_i

      <<~SVG.delete("\n")
        <g style="display: inline-block; vertical-align: middle;">
        <circle cx="#{circle_radius}" cy="#{circle_radius}" r="#{circle_radius}" fill="#DDD" />
        <text x="#{circle_radius}" y="#{circle_radius + (font_size / 3)}"
              fill="#000" text-anchor="middle"
              font-weight="#{text == 'X' ? 'normal' : 'semibold'}"
              font-size="#{font_size}" font-family="serif">#{text}</text>
        </g>
      SVG
    end

    def generate_hybrid_mana_svg(config)
      colors = config[:colors]
      size = config[:size]

      # For now, use the first color as a fallback
      # TODO: Implement proper hybrid mana rendering
      color = colors.first
      icon_svg = @icon_service.icon_svg(color, size: size)
      return symbol_fallback(size) unless icon_svg

      circle_radius = size / 2
      fill = svg_color(color)

      <<~SVG.delete("\n")
        <g style="display: inline-block; vertical-align: middle;">
        <circle cx="#{circle_radius}" cy="#{circle_radius}" r="#{circle_radius}" fill="#{fill}" />
        <g transform="translate(0, 0)" opacity="0.8">#{icon_svg}</g>
        </g>
      SVG
    end

    def generate_action_symbol_svg(config)
      action = config[:action]
      size = config[:size]

      case action
      when :tap
        generate_tap_symbol_svg(size)
      when :untap
        generate_untap_symbol_svg(size)
      when :energy
        generate_energy_symbol_svg(size)
      else
        symbol_fallback(size)
      end
    end

    def generate_tap_symbol_svg(size)
      # Simple tap symbol using text
      <<~SVG.delete("\n")
        <g style="display: inline-block; vertical-align: middle;">
        <text x="0" y="#{size / 2}" fill="#000" text-anchor="middle"
              font-weight="bold" font-size="#{size}" font-family="serif">⟳</text>
        </g>
      SVG
    end

    def generate_untap_symbol_svg(size)
      # Simple untap symbol using text
      <<~SVG.delete("\n")
        <g style="display: inline-block; vertical-align: middle;">
        <text x="0" y="#{size / 2}" fill="#000" text-anchor="middle"
              font-weight="bold" font-size="#{size}" font-family="serif">⟲</text>
        </g>
      SVG
    end

    def generate_energy_symbol_svg(size)
      # Simple energy symbol using text
      <<~SVG.delete("\n")
        <g style="display: inline-block; vertical-align: middle;">
        <text x="0" y="#{size / 2}" fill="#000" text-anchor="middle"
              font-weight="bold" font-size="#{size}" font-family="serif">⚡</text>
        </g>
      SVG
    end

    def symbol_fallback(size)
      # Fallback for unsupported symbols
      <<~SVG.delete("\n")
        <g style="display: inline-block; vertical-align: middle;">
        <circle cx="#{size / 2}" cy="#{size / 2}" r="#{size / 2}" fill="#DDD" />
        <text x="#{size / 2}" y="#{(size / 2) + (size / 6)}" fill="#000" text-anchor="middle"
              font-weight="bold" font-size="#{size / 2}" font-family="serif">?</text>
        </g>
      SVG
    end

    def replace_unsupported_symbols(text)
      # Find any remaining {symbol} patterns that weren't processed
      text.gsub(/\{[^}]+\}/) do |_match|
        symbol_fallback(16)
      end
    end

    def svg_color(color)
      case color
      when :white then '#FFF9C4'  # White primary color
      when :blue then '#90CAF9'   # Blue primary color
      when :black then '#BDBDBD'  # Black primary color
      when :red then '#EF9A9A'    # Red primary color
      when :green then '#A5D6A7'  # Green primary color
      else '#DDD'
      end
    end
  end
end
