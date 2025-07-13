# frozen_string_literal: true

module MtgCardMaker
  # TextBoxLayer is a specialized layer for the rules and flavor text
  class TextBoxLayer < BaseLayer
    include LayerInitializer
    attr_reader :rules_text, :flavor_text, :color_scheme

    def initialize(dimensions:, rules_text:, flavor_text: nil, color: nil, color_scheme: DEFAULT_COLOR_SCHEME)
      frame_color = initialize_layer_color(color, color_scheme, :background_color)
      super(dimensions: dimensions, color: frame_color)
      @rules_text = rules_text
      @flavor_text = flavor_text
      @color_scheme = color_scheme
    end

    # Render the rules text and flavor text in a text box with a background and highlight
    def render
      # Ensure gradients are defined for this color scheme
      SvgGradientService.define_all_gradients(svg, color_scheme)

      render_text_box
    end

    private

    def render_text_box
      layer_config = LayerConfig.default
      stroke_width = layer_config.stroke_width

      svg.g do
        # Text box background with mask for transparent window
        svg.rect x: x, y: y, width: width, height: height,
                 fill: "url(##{SvgGradientService.text_box_gradient_id(color_scheme)})",
                 stroke: color_scheme.primary_color,
                 stroke_width: stroke_width

        render_text_content
      end
    end

    def render_text_content
      render_rules_text
      render_flavor_text if flavor_text
    end

    def render_rules_text
      layer_config = LayerConfig.default
      text_service = create_text_service(layer_config, rules_text, :description, :card_description)
      render_text_lines(text_service)
    end

    def render_flavor_text
      return unless flavor_text && !flavor_text.strip.empty?

      render_flavor_separator
      layer_config = LayerConfig.default
      text_service = create_text_service(layer_config, flavor_text, :flavor_text, :flavor_text)
      render_text_lines(text_service)
    end

    def create_text_service(layer_config, text, text_type, css_class)
      TextRenderingService.new(
        text: text,
        layer_config: layer_config,
        x: layer_config.text_x_position(x),
        y: calculate_text_y_position(layer_config, text_type),
        font_size: layer_config.font_size(text_type),
        color: color_scheme.text_color,
        available_width: layer_config.text_width(width, text_type),
        css_class: layer_config.css_class(css_class)
      )
    end

    def calculate_text_y_position(layer_config, text_type)
      if text_type == :flavor_text
        y + height - layer_config.positioning(:flavor_text)[:y_offset]
      else
        layer_config.text_y_position(y, :description)
      end
    end

    def render_text_lines(text_service)
      text_service.wrapped_text_lines.each do |line, attrs|
        svg.text line, attrs
      end
    end

    def render_flavor_separator
      svg.line(**separator_config)
    end

    def separator_config
      layer_config = LayerConfig.default
      separator_offset = layer_config.positioning(:flavor_text)[:separator_offset]
      separator_y = y + height - separator_offset
      {
        x1: layer_config.text_x_position(x),
        y1: separator_y,
        x2: x + width - layer_config.horizontal_padding,
        y2: separator_y,
        stroke: color_scheme.primary_color,
        stroke_width: 1
      }
    end
  end
end
