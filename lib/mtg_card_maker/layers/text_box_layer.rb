# frozen_string_literal: true

require 'cgi'

module MtgCardMaker
  # Text limits for different scenarios
  MAX_RULES_LINES = 9
  MAX_FLAVOR_LINES = 7 # Two less because one line of rules is required, plus the separator

  # TextBoxLayer is a specialized layer for the rules and flavor text
  # with bidirectional text flow from a dynamic separator
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

    # Render the rules text and flavor text in a text box with bidirectional flow
    def render
      SvgGradientService.define_all_gradients(svg, color_scheme)
      render_text_box
    end

    private

    attr_reader :text_box_lines

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
      text_box_lines = create_text_box_lines

      # Render separator
      separator = text_box_lines.separator_line
      render_separator(separator[:y_pos]) if separator

      # Render text lines
      text_box_lines.text_lines.each do |line|
        render_text_line(line[:text], line[:y_pos], line[:type])
      end
    end

    def create_text_box_lines
      @text_box_lines = TextBoxLines.new(x: x, y: y, width: width, height: height)

      if flavor_text_present?
        setup_bidirectional_text
      else
        setup_rules_only_text
      end

      @text_box_lines
    end

    def setup_bidirectional_text
      rules_lines = calculate_rules_lines
      flavor_lines = calculate_flavor_lines(rules_lines.length)

      # Calculate separator line: first line after rules text, but never lower than line 4 (0-based)
      separator_line = [rules_lines.length, 4].max

      # Place rules text upward from separator
      place_text_lines(rules_lines.reverse, separator_line, direction: :upward, type: :rules_text)

      # Place separator
      text_box_lines.set_line(separator_line, type: :separator)

      # Place flavor text downward from separator
      place_text_lines(flavor_lines, separator_line, direction: :downward, type: :flavor_text)
    end

    def setup_rules_only_text
      rules_lines = calculate_rules_lines

      # Center the rules text in the available lines
      start_line = (MAX_RULES_LINES - rules_lines.length) / 2

      place_text_lines(rules_lines, start_line, direction: :forward, type: :rules_text)
    end

    def place_text_lines(lines, start_line, direction:, type:)
      lines.each_with_index do |line, index|
        line_number = calculate_line_number(start_line, index, direction)
        break if line_number.negative? || line_number >= MAX_RULES_LINES

        text_box_lines.set_line(line_number, text: line, type: type)
      end
    end

    def calculate_line_number(start_line, index, direction)
      case direction
      when :upward
        start_line - index - 1
      when :downward
        start_line + index + 1
      else
        start_line + index
      end
    end

    def render_text_line(line, y_pos, text_type)
      if contains_symbols?(line)
        render_line_with_symbols(line, y_pos, text_type)
      else
        svg.text line, {
          x: layer_config.text_x_position(x),
          y: y_pos,
          fill: color_scheme.text_color,
          font_size: layer_config.font_size(text_type),
          class: layer_config.css_class(text_type)
        }
      end
    end

    def contains_symbols?(text)
      text.match?(/\{[^}]+\}/)
    end

    def render_line_with_symbols(line, y_pos, text_type)
      parts = split_text_and_symbols(line)
      start_x = layer_config.text_x_position(x)
      font_size = layer_config.font_size(text_type)
      color = color_scheme.text_color

      # Use foreignObject with HTML for proper text/symbol alignment
      svg.foreignObject x: start_x, y: y_pos - font_size,
                        width:  layer_config.text_width(width, text_type),
                        height: font_size * 2 do
        svg << render_html_line_with_symbols(parts, font_size, color)
      end
    end

    def split_text_and_symbols(text)
      # Split text into parts: symbols and non-symbols
      parts = []
      current = ''

      text.chars.each do |char|
        if char == '{'
          parts << current unless current.empty?
          current = char
        elsif char == '}'
          current += char
          parts << current
          current = ''
        else
          current += char
        end
      end

      parts << current unless current.empty?
      parts
    end

    def render_symbol_using_mana_cost(symbol, x, y, _text_type)
      # Convert symbol to mana cost format and use ManaCost class
      mana_string = symbol.gsub(/[{}]/, '')
      mana_cost = ManaCost.new(mana_string)

      # Get the SVG content from ManaCost
      mana_svg = mana_cost.to_svg

      # Embed the mana cost SVG at the correct position with smaller size
      svg.g transform: "translate(#{x + 7}, #{y - 7}) scale(0.7)" do
        # Parse and embed the SVG content
        embed_mana_cost_svg(mana_svg)
      end
    end

    def embed_mana_cost_svg(mana_svg)
      # Parse the SVG content and embed it
      if mana_svg.include?('<g')
        # Extract the group content
        group_match = mana_svg.match(%r{<g[^>]*>(.*)</g>}m)
        svg << group_match[1] if group_match
      else
        svg << mana_svg
      end
    end

    def calculate_symbol_width(_text_type)
      # Symbols are rendered with scale(0.7) and have a circle radius of 15
      # The actual width should be the scaled circle diameter
      layer_config = LayerConfig.default
      circle_radius = layer_config.mana_cost_config[:circle_radius]
      scale_factor = 0.7
      (circle_radius * 2) * scale_factor # Diameter * scale = 30 * 0.7 = 21
    end

    def render_html_line_with_symbols(parts, font_size, color)
      html_parts = parts.map do |part|
        if part.start_with?('{') && part.end_with?('}')
          # Render symbol as inline SVG
          render_symbol_html(part)
        else
          # Escape HTML and render as text
          CGI.escape_html(part)
        end
      end

      # Wrap in a div with proper styling
      "<div xmlns=\"http://www.w3.org/1999/xhtml\" style=\"display: flex; align-items: center; font-family: serif; font-size: #{font_size}px; color: #{color}; line-height: 1.2;\">" +
        html_parts.join +
        '</div>'
    end

    def render_symbol_html(symbol)
      # Convert symbol to mana cost format and use ManaCost class
      symbol = symbol.gsub(/[{}]/, '')
      icon = IconService.new

      # Get the SVG content from IconService
      icon_svg = icon.icon_svg(SYMBOL_MAP[symbol])
      # Try numeric icon if the regular icon lookup failed and symbol is numeric
      icon_svg = icon.numeric_icon_svg(symbol.to_i) if icon_svg.nil? && symbol.match?(/^\d+$/)
      return unless icon_svg

      # Use the SVG content directly with proper styling
      icon_svg.gsub(/width="[^"]*"/, 'width="24"')
              .gsub(/height="[^"]*"/, 'height="24"')
              .gsub('<svg', '<svg style="vertical-align: middle; margin: 0 5px;"')
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

    def calculate_rules_lines
      return [] if rules_text.nil? || rules_text.strip.empty?

      text_service = create_text_service(rules_text, :rules_text)
      text_service.wrapped_text_lines.first(MAX_RULES_LINES).map(&:first)
    end

    def calculate_flavor_lines(rules_line_count)
      return [] unless flavor_text_present?

      text_service = create_text_service(flavor_text, :flavor_text)
      max_flavor_lines = [(MAX_FLAVOR_LINES - rules_line_count + 1), 1].max
      text_service.wrapped_text_lines.first(max_flavor_lines).map(&:first)
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

  # TextBoxLines manages the positioning and content of the MAX_RULES_LINES lines in a text box
  # Each line can contain rules text, flavor text, or be a separator
  class TextBoxLines
    attr_reader :x, :y, :width, :height

    def initialize(x:, y:, width:, height:)
      @width = width
      @height = height
      @lines = Array.new(MAX_RULES_LINES) { { text: nil, type: :rules_text } }
      @line_spacing = height / 10.0
      @x = x
      @y = y + (@line_spacing / 3)
      calculate_line_positions
    end

    # Set the content and type for a specific line (0-8)
    def set_line(line_number, text: nil, type: :rules_text)
      @lines[line_number] = { text: text, type: type }
    end

    # Get the content, type, and y position for a specific line (0-8)
    def get_line(line_number)
      line_data = @lines[line_number]
      {
        text: line_data[:text],
        type: line_data[:type],
        y_pos: @line_positions[line_number]
      }
    end

    # Get all lines as an array of hashes with text, type, and y_pos
    def all_lines
      @lines.map.with_index do |line_data, index|
        {
          text: line_data[:text],
          type: line_data[:type],
          y_pos: @line_positions[index]
        }
      end
    end

    # Get all lines except separators and empty lines
    def text_lines
      all_lines.reject { |line| line[:type] == :separator || line[:text].nil? || line[:text].strip.empty? }
    end

    def separator_line
      separator = all_lines.find { |line| line[:type] == :separator }
      # Position the separator in the middle of its line
      separator[:y_pos] -= (@line_spacing / 3) if separator
      separator
    end

    private

    def calculate_line_positions
      # Calculate MAX_RULES_LINES equally distributed vertical positions within the text box
      # Starting from the top of the text box (y) and ending at the bottom (y + height)
      last_line = MAX_RULES_LINES - 1
      @line_positions = (0..last_line).map do |line_num|
        @y + (@line_spacing * (line_num + 1))
      end
    end
  end
end
