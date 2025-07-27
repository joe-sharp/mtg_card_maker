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
    # @return [Array<Symbol>] the parsed mana elements
    attr_reader :elements

    # @return [Integer, nil] the integer value for generic mana
    attr_reader :int_val

    # Initialize a new mana cost parser
    #
    # @param mana_string [String, nil] the mana cost string (e.g., "2UR", "XG")
    # @param icon_set [Symbol] the icon set to use (default: :default)
    def initialize(mana_string = nil, icon_set = :default) # rubocop:disable Metrics/MethodLength
      @elements = []
      @origins = [] # :numeric, :C, or icon_type
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
      @origins = @origins.first(max_circles)
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
        mana_element_svg(x, y, icon_type, @origins[i])
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
        # Handle X directly as an X icon
        @int_val = nil
        @elements << :x
        @origins << :x

        # Parse remaining colored mana after X
        remaining = mana_string[1..]
        parse_colored_mana(remaining)
        return
      end

      int_match = mana_string.match(/^(\d+)/)
      @int_val = int_match[1].to_i

      # If it's more than 2 digits, treat as X
      if @int_val >= 100
        @int_val = nil
        @elements << :x
        @origins << :x
      else
        @elements << :numeric
        @origins << :numeric
      end

      # Remove the integer and parse remaining colored mana
      remaining = mana_string[int_match[1].length..]
      parse_colored_mana(remaining)
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
        @origins << :C
      elsif icon_type
        @elements << icon_type
        @origins << icon_type
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

    def mana_element_svg(x, y, icon_type, origin) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      layer_config = LayerConfig.default
      icon_size = layer_config.mana_cost_config[:icon_size]

      if icon_type == :numeric && origin == :numeric
        # Use IconService for numeric icons
        icon_svg = @icon_service.numeric_icon_svg(@int_val, size: icon_size)
        if icon_svg
          icon_x = x - (icon_size / 2)
          icon_y = y - (icon_size / 2)
          layer_config = LayerConfig.default
          opacity = layer_config.mana_cost_icon_opacity
          svg = "<g transform='translate(#{icon_x}, #{icon_y})' opacity='#{opacity}'>#{icon_svg}</g>"
        end
      elsif icon_type == :x && origin == :x
        # Use IconService for X icon
        icon_svg = @icon_service.icon_svg(:x, size: icon_size)
        if icon_svg
          icon_x = x - (icon_size / 2)
          icon_y = y - (icon_size / 2)
          layer_config = LayerConfig.default
          opacity = layer_config.mana_cost_icon_opacity
          svg = "<g transform='translate(#{icon_x}, #{icon_y})' opacity='#{opacity}'>#{icon_svg}</g>"
        end
      elsif [:untap, :tap].include?(origin)
        # Add icon without a background and slightly larger
        icon_svg = @icon_service.icon_svg(icon_type, size: icon_size)
        if icon_svg
          icon_x = x - (icon_size / 2)
          icon_y = y - (icon_size / 2)
          svg = "<g transform='translate(#{icon_x}, #{icon_y})'>#{icon_svg}</g>"
        end
      else
        icon_svg = @icon_service.icon_svg(icon_type, size: icon_size)
        if icon_svg
          icon_x = x - (icon_size / 2)
          icon_y = y - (icon_size / 2)
          layer_config = LayerConfig.default
          opacity = layer_config.mana_cost_icon_opacity
          svg = "<g transform='translate(#{icon_x}, #{icon_y})' opacity='#{opacity}'>#{icon_svg}</g>"
        end
      end

      svg
    end
  end
end
