# frozen_string_literal: true

module MtgCardMaker
  # TypeLineLayer is a specialized layer for the type of the card
  # This is the small area in the center of the card below the artwork
  class TypeLineLayer < BaseLayer
    include LayerInitializer
    attr_reader :type_line, :color_scheme

    def initialize(dimensions:, type_line:, color: nil, color_scheme: DEFAULT_COLOR_SCHEME)
      frame_color = initialize_layer_color(color, color_scheme, :background_color)
      super(dimensions: dimensions, color: frame_color)
      @type_line = type_line
      @color_scheme = color_scheme
    end

    def render
      # Ensure gradients are defined for this color scheme
      SvgGradientService.define_all_gradients(svg, color_scheme)

      svg.g do
        render_type_background
        render_type_line
        render_type_icon
      end
    end

    private

    def render_type_background
      layer_config = LayerConfig.default
      stroke_width = layer_config.stroke_width
      corners = layer_config.corner_radius(:type)

      svg.rect x: x, y: y, width: width, height: height,
               fill: "url(##{color_scheme.scheme_name}_name_gradient)",
               stroke: ColorPalette::FRAME_STROKE_COLOR,
               stroke_width: stroke_width,
               rx: corners[:x], ry: corners[:y]
    end

    def render_type_icon
      layer_config = LayerConfig.default
      icon_config = layer_config.type_icon_config

      svg.path stroke_width: 3,
               d: jsharp_path_data,
               fill: 'none',
               stroke: ColorPalette::FRAME_STROKE_COLOR,
               transform: build_icon_transform(icon_config),
               'aria-label': 'J#'
    end

    def jsharp_path_data
      jsharp_svg = IconService.new.jsharp_svg
      raise 'J# icon not found' unless jsharp_svg

      path_match = jsharp_svg.match(/<path[^>]*d="([^"]*)"[^>]*>/)
      path_match&.[](1)
    end

    def build_icon_transform(icon_config)
      translate_part = "translate(#{width - icon_config[:x_offset]},#{y + icon_config[:y_offset]})"
      scale_part = "scale(#{icon_config[:scale]})"
      aspect_part = "scale(#{icon_config[:aspect_ratio][:x]},#{icon_config[:aspect_ratio][:y]})"

      "#{translate_part} #{scale_part} #{aspect_part}"
    end

    def render_type_line
      layer_config = LayerConfig.default
      text_service = TextRenderingService.new(
        text: type_line,
        layer_config: layer_config,
        x: layer_config.text_x_position(x),
        y: layer_config.text_y_position(y, :type_area, height),
        font_size: layer_config.font_size(:type),
        available_width: layer_config.text_width(width, :type_area),
        css_class: layer_config.css_class(:card_type)
      )
      text_service.wrapped_text_lines.each do |line, attrs|
        svg.text line, attrs
      end
    end
  end
end
