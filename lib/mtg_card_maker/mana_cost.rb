# frozen_string_literal: true

require_relative 'icon_service'

module MtgCardMaker
  # Mana cost class that generates SVG for the mana cost of a card.
  # This class parses mana cost strings (e.g., "2UR", "XG") and generates
  # SVG icons for each mana symbol.
  #
  # @example
  #   mana_cost = MtgCardMaker::ManaCost.new("2UR")
  #   svg = mana_cost.to_svg
  #
  # @example
  #   mana_cost = MtgCardMaker::ManaCost.new("XG", icon_set: :custom)
  #   svg = mana_cost.to_svg
  #
  # @since 0.1.0
  class ManaCost
    # @return [Array<String>] the parsed mana elements (symbol strings)
    attr_reader :elements

    # @return [Integer, nil] the integer value for generic mana
    attr_reader :int_val

    # @return [LayerConfig] the layer configuration
    attr_reader :layer_config

    # Initialize a new mana cost parser
    #
    # @param mana_string [String, nil] the mana cost string (e.g., "2UR", "XG")
    # @param icon_set [Symbol] the icon set to use (default: :default)
    def initialize(mana_string = nil, icon_set = :default)
      @elements = []
      @int_val = nil
      @icon_service = IconService.new(icon_set)
      @layer_config = LayerConfig.default

      return if mana_string.nil? || mana_string.empty?

      parse_mana_string(mana_string.to_s.upcase)
      limit_elements
    end

    # Returns SVG string for the mana cost icons with drop shadow
    #
    # @return [String] the SVG markup for the mana cost
    def to_svg
      circle_spacing = layer_config.mana_cost_config[:circle_spacing]

      mana_icons = @elements.each_with_index.map do |symbol, i|
        render_mana_icon(i * circle_spacing, 0, symbol)
      end.join

      <<~SVG.delete("\n")
        #{drop_shadow_filter}
        <g filter="url(#mana-cost-drop-shadow)">
        #{mana_icons}
        </g>
      SVG
    end

    private

    def parse_mana_string(mana_string)
      if mana_string.start_with?('X')
        parse_x_cost(mana_string)
      elsif mana_string.match?(/^\d+/)
        parse_numeric_cost(mana_string)
      else
        parse_colored_mana(mana_string)
      end
    end

    def parse_x_cost(mana_string)
      @elements << '{X}'
      remaining_string = mana_string[1..]

      # Check if the remaining string starts with a number
      if remaining_string.match?(/^\d+/)
        parse_numeric_cost(remaining_string)
      else
        parse_colored_mana(remaining_string)
      end
    end

    def parse_numeric_cost(mana_string)
      numeric_value = mana_string.match(/^(\d+)/)[1].to_i

      if numeric_value >= 100
        @int_val = nil
        @elements << '{X}'
      else
        @int_val = numeric_value
        @elements << "{#{numeric_value}}"
      end

      parse_colored_mana(mana_string[numeric_value.to_s.length..])
    end

    def parse_colored_mana(mana_string)
      # Use regex to match symbols: single letters, 1-2 digits, or {anything between curly braces}
      mana_string.scan(/([A-Z]|\d{1,2}|\{[^}]+\})/).flatten.each do |symbol|
        # Add curly braces if not already present
        formatted_symbol = symbol.start_with?('{') ? symbol : "{#{symbol}}"

        # Allow any symbol - IconService will handle validation
        @elements << formatted_symbol
      end
    end

    def limit_elements
      max_circles = layer_config.mana_cost_config[:max_circles]
      @elements = @elements.first(max_circles)
    end

    def render_mana_icon(x, y, symbol)
      icon_size = if symbol.match?(%r{\{.*/.*\}}) # Hybrid or phyrexian symbols
                    layer_config.mana_cost_config[:hybrid_icon_size]
                  else
                    layer_config.mana_cost_config[:icon_size]
                  end

      icon_svg = @icon_service.symbol_svg(symbol, size: icon_size)
      return unless icon_svg

      icon_x = x - (icon_size / 2)
      icon_y = y - (icon_size / 2)

      "<g transform='translate(#{icon_x}, #{icon_y})'>#{icon_svg}</g>"
    end

    def drop_shadow_filter
      drop_shadow = layer_config.drop_shadow_config
      <<~SVG.delete("\n")
        <defs>
        <filter id="mana-cost-drop-shadow"
                x="-50%"
                y="-50%"
                width="200%"
                height="200%">
        <feDropShadow dx="#{drop_shadow[:dx]}"
                      dy="#{drop_shadow[:dy]}"
                      stdDeviation="#{drop_shadow[:std_deviation]}"
                      flood-color="black"/>
        </filter>
        </defs>
      SVG
    end
  end
end
