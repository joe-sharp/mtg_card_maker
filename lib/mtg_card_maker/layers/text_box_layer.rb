# frozen_string_literal: true

module MtgCardMaker
  # TextBoxLayer is a specialized layer for the rules and flavor text
  # with bidirectional text flow from a dynamic separator
  class TextBoxLayer < BaseLayer
    include LayerInitializer
    attr_reader :rules_text, :flavor_text, :color_scheme

    # Text limits for different scenarios
    MAX_RULES_LINES = 9
    MAX_FLAVOR_LINES = 7 # Two less because one line of rules is required, plus the separator
    BASE_RULES_LINES = 4

    def initialize(dimensions:, rules_text:, flavor_text: nil, color: nil, color_scheme: DEFAULT_COLOR_SCHEME)
      frame_color = initialize_layer_color(color, color_scheme, :background_color)
      super(dimensions: dimensions, color: frame_color)
      @rules_text = rules_text
      @flavor_text = flavor_text
      @color_scheme = color_scheme
    end

    # Render the rules text and flavor text in a text box with bidirectional flow
    def render
      SvgGradientService.define_all_gradients(svg, color_scheme)
      render_text_box
    end

    private

    def render_text_box
      svg.g do
        render_background
        render_text_content
      end
    end

    def render_background
      svg.rect x: x, y: y, width: width, height: height,
               fill: "url(##{SvgGradientService.text_box_gradient_id(color_scheme)})",
               stroke: color_scheme.primary_color,
               stroke_width: layer_config.stroke_width
    end

    def render_text_content
      if flavor_text_present?
        render_bidirectional_text
      else
        render_rules_only
      end
    end

    def render_rules_only
      rules_lines = calculate_rules_lines
      line_height = calculate_line_height(:rules_text)
      start_y = calculate_rules_start_position(rules_lines, line_height)

      rules_lines.each_with_index do |line, index|
        y_pos = start_y + (line_height * index)
        render_text_line(line, y_pos, :rules_text)
      end
    end

    def render_bidirectional_text
      separator_y = calculate_separator_position
      rules_lines = calculate_rules_lines
      flavor_lines = calculate_flavor_lines(rules_lines.length)

      render_separator(separator_y)
      render_rules_text_upward(rules_lines, separator_y)
      render_flavor_text_downward(flavor_lines, separator_y) if flavor_lines.any?
    end

    def render_rules_text_upward(rules_lines, separator_y)
      line_height = calculate_line_height(:rules_text)

      rules_lines.reverse.each_with_index do |line, index|
        y_pos = separator_y - (line_height * (index + 0.5))
        render_text_line(line, y_pos, :rules_text)
      end
    end

    def render_flavor_text_downward(flavor_lines, separator_y)
      line_height = calculate_line_height(:flavor_text)

      flavor_lines.each_with_index do |line, index|
        y_pos = separator_y + (line_height * (index + 1))
        render_text_line(line, y_pos, :flavor_text)
      end
    end

    def render_text_line(line, y_pos, text_type)
      svg.text line, {
        x: layer_config.text_x_position(x),
        y: y_pos,
        fill: color_scheme.text_color,
        font_size: layer_config.font_size(text_type),
        class: layer_config.css_class(text_type)
      }
    end

    def render_separator(separator_y)
      svg.line(
        x1: layer_config.text_x_position(x),
        y1: separator_y,
        x2: x + width - layer_config.horizontal_padding,
        y2: separator_y,
        stroke: color_scheme.primary_color,
        stroke_width: 1
      )
    end

    def calculate_separator_position
      base_separator_y = y + (height / 2.0)
      rules_lines = calculate_rules_lines
      extra_lines = [rules_lines.length - BASE_RULES_LINES, 0].max
      line_height = calculate_line_height(:rules_text)

      base_separator_y + (extra_lines * line_height)
    end

    def calculate_rules_lines
      return [] if rules_text.nil? || rules_text.strip.empty?

      text_service = create_text_service(rules_text, :rules_text)
      text_service.wrapped_text_lines.first(MAX_RULES_LINES).map(&:first)
    end

    def calculate_flavor_lines(rules_line_count)
      return [] unless flavor_text_present?

      text_service = create_text_service(flavor_text, :flavor_text)
      max_flavor_lines = [MAX_FLAVOR_LINES - [rules_line_count - 1, 0].max, 1].max
      text_service.wrapped_text_lines.first(max_flavor_lines).map(&:first)
    end

    def calculate_line_height(text_type)
      layer_config.font_size(text_type) * layer_config.default_line_height_multiplier
    end

    def calculate_rules_start_position(rules_lines, line_height)
      total_text_height = rules_lines.length * line_height
      center_y = y + (height / 2.0) + (line_height / 2.0)
      center_y += (line_height / 3.0) if rules_lines.length == 9

      center_y - (total_text_height / 2.0)
    end

    def create_text_service(text, text_type)
      TextRenderingService.new(
        text: text,
        layer_config: layer_config,
        x: layer_config.text_x_position(x),
        y: 0, # Will be calculated per line
        font_size: layer_config.font_size(text_type),
        color: color_scheme.text_color,
        available_width: layer_config.text_width(width, text_type),
        css_class: layer_config.css_class(text_type)
      )
    end

    def layer_config
      @layer_config ||= LayerConfig.default
    end

    def flavor_text_present?
      flavor_text && !flavor_text.strip.empty?
    end
  end
end
