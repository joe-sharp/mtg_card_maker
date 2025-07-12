# frozen_string_literal: true

module MtgCardMaker
  # PowerLayer is a specialized layer
  # This is the area that surrounds the power and toughness of the card
  class PowerLayer < BaseLayer
    include LayerInitializer
    attr_reader :power, :toughness, :color_scheme

    def initialize(dimensions:, power:, toughness:, color: nil, color_scheme: DEFAULT_COLOR_SCHEME)
      frame_color = initialize_layer_color(color, color_scheme, :background_color)
      super(dimensions: dimensions, color: frame_color)
      @power = power
      @toughness = toughness
      @color_scheme = color_scheme
    end

    def render
      # Don't render if power or toughness are nil, empty, or invalid
      return if power.nil? || toughness.nil? || power.to_s.strip.empty? || toughness.to_s.strip.empty?

      # Ensure gradients are defined for this color scheme
      SvgGradientService.define_all_gradients(svg, color_scheme)

      layer_config = LayerConfig.default
      stroke_width = layer_config.stroke_width
      corners = layer_config.corner_radius(:power)

      svg.g do
        # P/T box with ornate frame
        svg.rect x: x_position, y: y, width: dynamic_width, height: height,
                 fill: "url(##{SvgGradientService.name_gradient_id(color_scheme)})",
                 stroke: ColorPalette::FRAME_STROKE_COLOR,
                 stroke_width: stroke_width, rx: corners[:x], ry: corners[:y]

        # P/T text with bold styling
        cost_attrs = {
          x:           x_position + (dynamic_width / 2),
          y:           y + (height / 2) + layer_config.positioning(:power_area)[:y_offset],
          fill:        DEFAULT_TEXT_COLOR,
          font_size:   layer_config.font_size(:power_area),
          text_anchor: 'middle',
          class:       'card-power-toughness'
        }
        svg.text "#{power}/#{toughness}", cost_attrs
      end
    end

    private

    def dynamic_width
      # Calculate total character count: power + toughness + "/"
      total_chars = power.to_s.length + toughness.to_s.length + 1

      # Base width for 3 characters, with steady increase per additional character
      base_width = 60
      width_per_char = 13
      base_width + ((total_chars - 3) * width_per_char)
    end

    def x_position
      # Anchor right side to card width (630px) with 35px margin
      # Right edge should be at 595px (630 - 35)
      margin = 35
      right_edge = CARD_WIDTH - margin
      right_edge - dynamic_width
    end
  end
end
