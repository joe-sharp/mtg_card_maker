# frozen_string_literal: true

module MtgCardMaker
  # IconFilenameService provides symbol mapping for MTG mana costs and symbols.
  # This service maps symbol notation (like {W}, {2}, {T}) to icon types.
  #
  # @example
  #   service = MtgCardMaker::IconFilenameService.new
  #   icon_type = service.symbol_to_icon_type("{W}")
  #   icon_type = service.symbol_to_icon_type("{2}")
  #
  # @since 0.1.0
  class IconFilenameService
    # Basic mana colors and their symbols
    BASIC_COLORS = {
      '{W}' => :white,
      '{B}' => :black,
      '{R}' => :red,
      '{G}' => :green,
      '{U}' => :blue,
      '{C}' => :colorless
    }.freeze

    # Special symbols, cannot be combined with other symbols
    SPECIAL_SYMBOLS = {
      '{S}' => :snow,
      '{X}' => :x,
      '{T}' => :tap,
      '{Q}' => :untap,
      '{E}' => :energy
    }.freeze

    # Get the complete symbol map
    #
    # @return [Hash<String, Symbol>] the complete mapping of symbols to icon types
    def symbol_map
      @symbol_map ||= generate_symbol_map
    end

    # Convert a symbol to an icon type
    #
    # @param symbol [String] the symbol to convert (e.g., "{W}", "{2}", "{T}")
    # @return [Symbol, nil] the icon type or nil if not found
    def symbol_to_icon_type(symbol)
      symbol_map[symbol]
    end

    private

    # Generate the complete symbol map from basic definitions
    def generate_symbol_map
      BASIC_COLORS
        .merge(SPECIAL_SYMBOLS)
        .merge(generate_hybrid_symbols)
        .merge(generate_numeric_symbols)
        .merge(generate_phyrexian_symbols)
        .merge(generate_phyrexian_hybrid_symbols)
    end

    # Generate numeric symbols (0-9 single-digit, 10-99 double-digit)
    def generate_numeric_symbols
      (0..99).to_h { |num| ["{#{num}}", :numeric] }
    end

    # Generate phyrexian mana symbols
    def generate_phyrexian_symbols
      BASIC_COLORS.transform_keys { |symbol| symbol.gsub('}', '/P}') }
                  .transform_values { |color| :"phyrexian-#{color}" }
    end

    # Generate hybrid mana symbols
    def generate_hybrid_symbols
      # Hybrid symbols are combinations of two basic colors
      generate_color_combinations.merge(
        # Twobrids are a colorless "2" plus a basic color
        generate_twobrid_symbols
      )
    end

    # Generate two-color hybrid combinations
    def generate_color_combinations
      color_symbols = color_symbols_without_braces

      color_symbols.combination(2).flat_map do |color1, color2|
        [
          ["{#{color1}/#{color2}}", :"hybrid-#{BASIC_COLORS["{#{color1}}"]}-#{BASIC_COLORS["{#{color2}}"]}"],
          ["{#{color2}/#{color1}}", :"hybrid-#{BASIC_COLORS["{#{color2}}"]}-#{BASIC_COLORS["{#{color1}}"]}"]
        ]
      end.to_h
    end

    # Generate 2/color symbols (twobrid)
    def generate_twobrid_symbols
      BASIC_COLORS.transform_keys { |symbol| "{2/#{strip_braces(symbol)}}" }
                  .transform_values { |color| :"hybrid-2-#{color}" }
    end

    # Generate phyrexian hybrid mana symbols
    def generate_phyrexian_hybrid_symbols
      color_symbols = color_symbols_without_braces

      color_symbols.combination(2).flat_map do |color1, color2|
        [
          ["{#{color1}/#{color2}/P}", :"phyrexian-#{BASIC_COLORS["{#{color1}}"]}-#{BASIC_COLORS["{#{color2}}"]}"],
          ["{#{color2}/#{color1}/P}", :"phyrexian-#{BASIC_COLORS["{#{color2}}"]}-#{BASIC_COLORS["{#{color1}}"]}"]
        ]
      end.to_h
    end

    def color_symbols_without_braces
      BASIC_COLORS.keys.map { |symbol| strip_braces(symbol) }
    end

    def strip_braces(symbol)
      symbol.gsub(/[{}]/, '')
    end
  end
end
