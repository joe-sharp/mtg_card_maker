# frozen_string_literal: true

require_relative '../mana_cost'

module MtgCardMaker
  # NameLayer is a specialized layer
  # This is the area that surrounds the name and cost of the card
  class NameLayer < BaseLayer
    include LayerInitializer
    attr_reader :name, :cost, :color_scheme

    def initialize(dimensions:, name:, cost:, color: nil, color_scheme: DEFAULT_COLOR_SCHEME)
      frame_color = initialize_layer_color(color, color_scheme, :background_color)
      super(dimensions: dimensions, color: frame_color)
      @name = name
      @cost = cost
      @color_scheme = color_scheme
    end

    def render
      # Ensure gradients are defined for this color scheme
      SvgGradientService.define_all_gradients(svg, color_scheme)

      svg.g do
        render_name_area
        render_card_name
        render_mana_cost if cost && !cost.empty?
      end
    end

    private

    def render_name_area
      layer_config = LayerConfig.default
      stroke_width = layer_config.stroke_width
      corners = layer_config.corner_radius(:name)

      svg.rect x: x, y: y, width: width, height: height,
               fill: "url(##{SvgGradientService.name_gradient_id(color_scheme)})",
               stroke: ColorPalette::FRAME_STROKE_COLOR,
               stroke_width: stroke_width,
               rx: corners[:x], ry: corners[:y], mask: "url(##{@mask_id})"
    end

    def render_card_name
      layer_config = LayerConfig.default
      text_service = TextRenderingService.new(
        text: name,
        layer_config: layer_config,
        x: layer_config.text_x_position(x),
        y: layer_config.text_y_position(y, :name_area, height),
        font_size: layer_config.font_size(:name),
        available_width: layer_config.text_width(width, :name_area),
        css_class: layer_config.css_class(:card_name)
      )
      lines = text_service.wrapped_text_lines
      lines.each do |line, attrs|
        svg.text line, attrs
      end
    end

    def render_mana_cost
      mana_cost = ManaCost.new(cost)
      cost_x = cost_position_x(mana_cost)
      cost_y = cost_position_y
      svg.g transform: "translate(#{cost_x}, #{cost_y})" do
        svg << mana_cost.to_svg
      end
    end

    def cost_position_x(mana_cost)
      layer_config = LayerConfig.default
      config = layer_config.mana_cost_config
      base_x = x + width - config[:margin] - config[:circle_radius]
      base_x - (config[:circle_spacing] * (mana_cost.elements.length - 1))
    end

    def cost_position_y
      y + (height / 2) - 2
    end
  end
end
