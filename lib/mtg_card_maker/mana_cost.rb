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
    # Mapping of MTG notation to icon types
    SYMBOL_MAP = {
      'B' => :black,
      'U' => :blue,
      'G' => :green,
      'W' => :white,
      'R' => :red,
      'C' => :colorless,
      'S' => :snow,
      'X' => :x
    }.freeze

    # @return [Array<Symbol>] the parsed mana elements
    attr_reader :elements

    # @return [Integer, nil] the integer value for generic mana
    attr_reader :int_val

    # Initialize a new mana cost parser
    #
    # @param mana_string [String, nil] the mana cost string (e.g., "2UR", "XG")
    # @param icon_set [Symbol] the icon set to use (default: :default)
    def initialize(mana_string = nil, icon_set = :default)
      @elements = []
      @int_val = nil
      @icon_service = IconService.new(icon_set)

      return if mana_string.nil? || mana_string.empty?

      parse_mana_string(mana_string.to_s.upcase)
      limit_elements
    end

    # Returns SVG string for the mana cost icons with drop shadow
    #
    # @return [String] the SVG markup for the mana cost
    def to_svg
      layer_config = LayerConfig.default
      circle_spacing = layer_config.mana_cost_config[:circle_spacing]

      mana_icons = @elements.each_with_index.map do |icon_type, i|
        render_mana_icon(i * circle_spacing, 0, icon_type)
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
      return if mana_string.nil? || mana_string.empty?

      if mana_string.start_with?('X')
        parse_x_cost(mana_string)
      elsif mana_string.match?(/^\d+/)
        parse_numeric_cost(mana_string)
      else
        parse_colored_mana(mana_string)
      end
    end

    def parse_x_cost(mana_string)
      @elements << :x
      parse_colored_mana(mana_string[1..])
    end

    def parse_numeric_cost(mana_string)
      numeric_value = mana_string.match(/^(\d+)/)[1].to_i

      if numeric_value >= 100
        @int_val = nil
        @elements << :x
      else
        @int_val = numeric_value
        @elements << :numeric
      end

      parse_colored_mana(mana_string[numeric_value.to_s.length..])
    end

    def parse_colored_mana(mana_string)
      return if mana_string.nil? || mana_string.empty?

      mana_string.chars.each do |char|
        icon_type = SYMBOL_MAP[char]
        @elements << icon_type if icon_type
      end
    end

    def limit_elements
      layer_config = LayerConfig.default
      max_circles = layer_config.mana_cost_config[:max_circles]
      @elements = @elements.first(max_circles)
    end

    def render_mana_icon(x, y, icon_type)
      layer_config = LayerConfig.default
      icon_size = layer_config.mana_cost_config[:icon_size]

      icon_svg = get_icon_svg(icon_type, icon_size)
      return unless icon_svg

      icon_x = x - (icon_size / 2)
      icon_y = y - (icon_size / 2)

      "<g transform='translate(#{icon_x}, #{icon_y})'>#{icon_svg}</g>"
    end

    def get_icon_svg(icon_type, size)
      case icon_type
      when :numeric
        @icon_service.numeric_icon_svg(@int_val, size: size)
      else
        @icon_service.icon_svg(icon_type, size: size)
      end
    end

    def drop_shadow_filter
      layer_config = LayerConfig.default
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
