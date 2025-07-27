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
  class ManaCost # rubocop:disable Metrics/ClassLength
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
      @original_string = mana_string
      @icon_service = IconService.new(icon_set)

      return if mana_string.nil? || mana_string.empty?

      # Convert to uppercase for consistency
      mana_string = mana_string.to_s.upcase

      # Parse the mana string
      parse_mana_string(mana_string)

      # Limit to maximum circles
      layer_config = LayerConfig.default
      max_circles = layer_config.mana_cost_config[:max_circles]
      @elements = @elements.first(max_circles)
    end

    # Returns SVG string for the mana cost icons with drop shadow
    #
    # @return [String] the SVG markup for the mana cost
    def to_svg
      layer_config = LayerConfig.default
      circle_spacing = layer_config.mana_cost_config[:circle_spacing]

      # Build mana cost icons SVG
      mana_icons = @elements.each_with_index.map do |icon_type, i|
        x = i * circle_spacing
        y = 0
        mana_element_svg(x, y, icon_type)
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
      return if mana_string.nil?

      if numeric_cost?(mana_string) || mana_string.start_with?('X')
        parse_numeric_cost(mana_string)
      else
        parse_colored_mana(mana_string)
      end
    end

    def numeric_cost?(mana_string)
      mana_string.match?(/^\d+/)
    end

    def parse_numeric_cost(mana_string)
      if mana_string.start_with?('X')
        handle_x_cost(mana_string)
      else
        handle_numeric_cost(mana_string)
      end
    end

    def handle_x_cost(mana_string)
      set_x_cost
      parse_remaining_colored_mana(mana_string[1..])
    end

    def handle_numeric_cost(mana_string)
      numeric_value = extract_numeric_value(mana_string)
      process_numeric_value(numeric_value)
      parse_remaining_colored_mana(mana_string[numeric_value.to_s.length..])
    end

    def set_x_cost
      @int_val = nil
      @elements << :x
    end

    def extract_numeric_value(mana_string)
      int_match = mana_string.match(/^(\d+)/)
      int_match[1].to_i
    end

    def process_numeric_value(value)
      @int_val = value

      if value >= 100
        set_x_cost
      else
        @elements << :numeric
      end
    end

    def parse_remaining_colored_mana(remaining_string)
      parse_colored_mana(remaining_string)
    end

    def parse_colored_mana(mana_string)
      return if mana_string.nil? || mana_string.empty?

      mana_string.chars.each do |char|
        process_colored_character(char)
      end
    end

    def process_colored_character(char)
      icon_type = SYMBOL_MAP[char]
      if colorless_symbol?(icon_type, char)
        @elements << :colorless
      elsif icon_type
        @elements << icon_type
      end
    end

    def colorless_symbol?(icon_type, char)
      icon_type == :colorless && char == 'C'
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
                      flood-color="black"
                      flood-opacity="#{drop_shadow[:flood_opacity]}"/>
        </filter>
        </defs>
      SVG
    end

    def mana_element_svg(x, y, icon_type)
      case icon_type
      when :numeric
        render_numeric_icon(x, y)
      when :x
        render_x_icon(x, y)
      when :untap, :tap
        render_tap_icon(x, y, icon_type)
      else
        render_colored_icon(x, y, icon_type)
      end
    end

    def render_numeric_icon(x, y)
      layer_config = LayerConfig.default
      icon_size = layer_config.mana_cost_config[:icon_size]

      icon_svg = @icon_service.numeric_icon_svg(@int_val, size: icon_size)
      return unless icon_svg

      icon_x = x - (icon_size / 2)
      icon_y = y - (icon_size / 2)
      opacity = layer_config.mana_cost_icon_opacity
      "<g transform='translate(#{icon_x}, #{icon_y})' opacity='#{opacity}'>#{icon_svg}</g>"
    end

    def render_x_icon(x, y)
      layer_config = LayerConfig.default
      icon_size = layer_config.mana_cost_config[:icon_size]

      icon_svg = @icon_service.icon_svg(:x, size: icon_size)
      return unless icon_svg

      icon_x = x - (icon_size / 2)
      icon_y = y - (icon_size / 2)
      opacity = layer_config.mana_cost_icon_opacity
      "<g transform='translate(#{icon_x}, #{icon_y})' opacity='#{opacity}'>#{icon_svg}</g>"
    end

    def render_tap_icon(x, y, icon_type)
      layer_config = LayerConfig.default
      icon_size = layer_config.mana_cost_config[:icon_size]

      icon_svg = @icon_service.icon_svg(icon_type, size: icon_size)
      return unless icon_svg

      icon_x = x - (icon_size / 2)
      icon_y = y - (icon_size / 2)
      "<g transform='translate(#{icon_x}, #{icon_y})'>#{icon_svg}</g>"
    end

    def render_colored_icon(x, y, icon_type)
      layer_config = LayerConfig.default
      icon_size = layer_config.mana_cost_config[:icon_size]

      icon_svg = @icon_service.icon_svg(icon_type, size: icon_size)
      return unless icon_svg

      icon_x = x - (icon_size / 2)
      icon_y = y - (icon_size / 2)
      opacity = layer_config.mana_cost_icon_opacity
      "<g transform='translate(#{icon_x}, #{icon_y})' opacity='#{opacity}'>#{icon_svg}</g>"
    end
  end
end
