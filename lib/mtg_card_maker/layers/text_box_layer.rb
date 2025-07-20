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
      return render_rules_only unless flavor_text_present?

      render_bidirectional_text
    end

    def render_rules_only
      layer_config = LayerConfig.default
      text_service = create_text_service(layer_config, rules_text, :rules_text)

      rules_lines = text_service.wrapped_text_lines.map(&:first)
      line_height = calculate_line_height(layer_config, :rules_text)

      start_y = calculate_rules_start_position(rules_lines, line_height)

      render_rules_lines(rules_lines, start_y, line_height, layer_config)
    end

    def render_bidirectional_text
      layer_config = LayerConfig.default

      # Calculate separator position and text limits
      separator_y = calculate_separator_position
      rules_lines = calculate_rules_lines
      flavor_lines = calculate_flavor_lines(rules_lines.length)

      # Render separator first
      render_separator(separator_y)

      # Render rules text flowing upward from separator
      render_rules_text_upward(rules_lines, separator_y, layer_config) if rules_lines.any?

      # Render flavor text flowing downward from separator
      return unless flavor_lines.any?

      render_flavor_text_downward(flavor_lines, separator_y, layer_config)
    end

    def render_rules_text_upward(rules_lines, separator_y, layer_config)
      line_height = calculate_line_height(layer_config, :rules_text)

      # Reverse the lines so the first line is closest to the separator
      rules_lines.reverse.each_with_index do |line, index|
        # Position rules text above the separator, flowing upward
        # Reduce spacing to be closer to separator
        y_pos = separator_y - (line_height * (index + 0.5))

        render_text_line(line, y_pos, layer_config, :rules_text)
      end
    end

    def render_flavor_text_downward(flavor_lines, separator_y, layer_config)
      line_height = calculate_line_height(layer_config, :flavor_text)

      flavor_lines.each_with_index do |line, index|
        # Position flavor text below the separator, flowing downward
        y_pos = separator_y + (line_height * (index + 1))

        render_text_line(line, y_pos, layer_config, :flavor_text)
      end
    end

    def render_rules_lines(rules_lines, start_y, line_height, layer_config)
      rules_lines.each_with_index do |line, index|
        y_pos = start_y + (line_height * index)
        render_text_line(line, y_pos, layer_config, :rules_text)
      end
    end

    def render_text_line(line, y_pos, layer_config, text_type)
      svg.text line, {
        x: layer_config.text_x_position(x),
        y: y_pos,
        fill: color_scheme.text_color,
        font_size: layer_config.font_size(text_type),
        class: layer_config.css_class(text_type)
      }
    end

    def create_text_service(layer_config, text, text_type)
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

    def render_separator(separator_y)
      layer_config = LayerConfig.default

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
      layer_config = LayerConfig.default
      base_separator_y = y + (height / 2.0)

      # Move separator down for each line of rules text beyond BASE_RULES_LINES
      rules_lines = calculate_rules_lines
      extra_lines = [rules_lines.length - BASE_RULES_LINES, 0].max
      line_height = calculate_line_height(layer_config, :rules_text)

      base_separator_y + (extra_lines * line_height)
    end

    def calculate_rules_lines
      return [] if rules_text.nil? || rules_text.strip.empty?

      layer_config = LayerConfig.default
      text_service = create_text_service(layer_config, rules_text, :rules_text)
      lines = text_service.wrapped_text_lines

      # Limit to maximum lines
      lines.first(MAX_RULES_LINES).map(&:first)
    end

    def calculate_flavor_lines(rules_line_count)
      return [] unless flavor_text_present?

      layer_config = LayerConfig.default
      text_service = create_text_service(layer_config, flavor_text, :flavor_text)
      lines = text_service.wrapped_text_lines

      # Calculate maximum flavor lines based on rules lines
      max_flavor_lines = MAX_FLAVOR_LINES - [rules_line_count - 1, 0].max
      max_flavor_lines = [max_flavor_lines, 1].max # Ensure at least 1 line

      lines.first(max_flavor_lines).map(&:first)
    end

    def calculate_line_height(layer_config, text_type)
      layer_config.font_size(text_type) * layer_config.default_line_height_multiplier
    end

    def calculate_rules_start_position(rules_lines, line_height)
      # Calculate center position for the text block
      total_text_height = rules_lines.length * line_height
      center_y = y + (height / 2.0) + (line_height / 2.0)

      # Move down by half a line when there are exactly 9 lines
      center_y += (line_height / 3.0) if rules_lines.length == 9

      center_y - (total_text_height / 2.0)
    end

    def flavor_text_present?
      flavor_text && !flavor_text.strip.empty?
    end
  end
end
