# frozen_string_literal: true

require_relative 'icon_service'

module MtgCardMaker
  # Mana cost class that generates SVG for the mana cost of a card.
  # This class parses mana cost strings (e.g., "2UR", "XG") and generates
  # SVG circles with appropriate colors and icons for each mana symbol.
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
  # rubocop:disable Metrics/ClassLength
  class ManaCost
    # Mapping of letters to colors
    # @return [Hash] the color mapping for mana symbols
    COLOR_MAP = {
      'B' => :black, 'S' => :black,
      'U' => :blue,  'I' => :blue,
      'G' => :green, 'F' => :green,
      'W' => :white, 'P' => :white,
      'R' => :red,   'M' => :red,
      'C' => :colorless
    }.freeze

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
      @origins = [] # :numeric, :C, or color symbol
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

    # Returns SVG string for the mana cost circles with drop shadow
    #
    # @return [String] the SVG markup for the mana cost
    def to_svg
      layer_config = LayerConfig.default
      circle_spacing = layer_config.mana_cost_config[:circle_spacing]

      # Build mana cost circles SVG
      mana_circles = @elements.each_with_index.map do |color, i|
        x = i * circle_spacing
        y = 0
        mana_element_svg(x, y, color, @origins[i])
      end.join

      <<~SVG.delete("\n")
        #{drop_shadow_filter}
        <g filter="url(#mana-cost-drop-shadow)">
        #{mana_circles}
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
      mana_string = mana_string.gsub(/^X/, '10')

      int_match = mana_string.match(/^(\d+)/)
      @int_val = int_match[1].to_i

      # If it's a double-digit number, treat as X
      @int_val = 10 if @int_val >= 10

      @elements << :colorless
      @origins << :numeric

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
      color = COLOR_MAP[char]
      if colorless_symbol?(color, char)
        @elements << :colorless
        @origins << :C
      elsif color
        @elements << color
        @origins << color
      end
    end

    def colorless_symbol?(color, char)
      color == :colorless && char == 'C'
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

    def mana_element_svg(x, y, color, origin) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      layer_config = LayerConfig.default
      circle_radius = layer_config.mana_cost_config[:circle_radius]
      icon_size = layer_config.mana_cost_config[:icon_size]

      fill = svg_color(color)
      svg = "<circle cx='#{x}' cy='#{y}' r='#{circle_radius}' fill='#{fill}' />"

      if color == :colorless && origin == :numeric
        # Add text for numeric colorless mana circles
        svg << colorless_text(x, y, origin)
      else
        # Add icon inside colored mana circles, smaller and with opacity
        icon_svg = @icon_service.icon_svg(color, size: icon_size)
        if icon_svg
          icon_x = x - (icon_size / 2)
          icon_y = y - (icon_size / 2)
          layer_config = LayerConfig.default
          opacity = layer_config.mana_cost_icon_opacity
          svg << "<g transform='translate(#{icon_x}, #{icon_y})' opacity='#{opacity}'>#{icon_svg}</g>"
        end
      end

      svg
    end

    def colorless_text(x, y, origin)
      if origin == :numeric && @int_val
        text = @int_val == 10 ? 'X' : @int_val.to_s
        text_svg(x, y, text)
      else
        ''
      end
    end

    def text_svg(x, y, text)
      # Position text in the center of the circle with appropriate styling
      layer_config = LayerConfig.default
      font_size = layer_config.mana_cost_font_size
      font_weight = text == 'X' ? 'normal' : 'semibold'
      y_offset = layer_config.mana_cost_text_y_offset

      "<text x='#{x}' y='#{y + y_offset}' fill='#000' text-anchor='middle' " \
        "font-weight='#{font_weight}' font-size='#{font_size}' font-family='serif'>#{text}</text>"
    end

    def svg_color(color)
      case color
      when :white then '#FFF9C4'  # White primary color
      when :blue then '#90CAF9'   # Blue primary color (from fixture)
      when :black then '#BDBDBD'  # Black primary color (from fixture)
      when :red then '#EF9A9A'    # Red primary color (from fixture)
      when :green then '#A5D6A7'  # Green primary color (from fixture)
      else '#DDD'
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
