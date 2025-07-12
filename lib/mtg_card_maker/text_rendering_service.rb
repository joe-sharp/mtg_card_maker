# frozen_string_literal: true

module MtgCardMaker
  # Minimal text rendering service with basic word wrapping for SVG.
  # This service handles text layout, wrapping, and attribute generation
  # for SVG text elements with configurable font sizes, colors, and spacing.
  #
  # @example
  #   service = MtgCardMaker::TextRenderingService.new(
  #     text: "Lightning Bolt deals 3 damage to any target.",
  #     x: 40, y: 545, font_size: 24, available_width: 550
  #   )
  #   lines = service.wrapped_text_lines
  #
  # @since 0.1.0
  class TextRenderingService
    # @return [String] the text to render
    attr_accessor :text

    # @return [LayerConfig] the layer configuration
    attr_accessor :layer_config

    # @return [Integer] the x-coordinate for text positioning
    attr_accessor :x

    # @return [Integer] the y-coordinate for text positioning
    attr_accessor :y

    # @return [Integer] the font size
    attr_accessor :font_size

    # @return [String] the text color
    attr_accessor :color

    # @return [Integer] the available width for text wrapping
    attr_accessor :available_width

    # @return [Integer] the line height
    attr_accessor :line_height

    # @return [String, nil] the CSS class for styling
    attr_accessor :css_class

    # Initialize a new text rendering service
    #
    # @param kwargs [Hash] the initialization parameters
    # @option kwargs [String] :text the text to render (default: '')
    # @option kwargs [LayerConfig] :layer_config the layer configuration (default: LayerConfig.default)
    # @option kwargs [Integer] :x the x-coordinate (default: 0)
    # @option kwargs [Integer] :y the y-coordinate (default: 0)
    # @option kwargs [Integer] :font_size the font size (default: from layer_config)
    # @option kwargs [String] :color the text color (default: from layer_config)
    # @option kwargs [Integer] :available_width the available width (default: CARD_WIDTH)
    # @option kwargs [Integer] :line_height the line height (default: calculated)
    # @option kwargs [String] :css_class the CSS class (default: nil)
    def initialize(**kwargs)
      # Set defaults
      defaults = {
        text: '',
        layer_config: LayerConfig.default,
        x: 0,
        y: 0,
        font_size: nil,
        color: nil,
        available_width: nil,
        line_height: nil,
        css_class: nil
      }

      # Merge defaults with provided kwargs
      final_params = defaults.merge(kwargs)

      # Set instance variables
      final_params.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end

      # Post-process dependent values
      @font_size ||= @layer_config.default_font_size
      @color ||= @layer_config.default_text_color
      @available_width ||= CARD_WIDTH
      @line_height ||= calculate_default_line_height
    end

    # Returns an array of [line, attrs] for SVG text elements
    #
    # @param text [String, nil] optional text to override current text
    # @return [Array<Array>] array of [line_text, attributes_hash] pairs
    def wrapped_text_lines(text = nil)
      @text = text if text
      render_text_lines
    end

    private

    def calculate_default_line_height
      @font_size * @layer_config.default_line_height_multiplier
    end

    def render_text_lines
      lines = text_to_lines
      build_text_attributes(lines)
    end

    def text_to_lines
      @text.to_s.split(/\r?\n/).flat_map do |line|
        wrap_line(line)
      end.reject(&:empty?)
    end

    def build_text_attributes(lines)
      lines.each_with_index.map do |line, idx|
        attrs = {
          x: @x,
          y: @y + (idx * @line_height).to_i,
          fill: @color,
          font_size: @font_size
        }
        attrs[:class] = @css_class if @css_class
        [line, attrs]
      end
    end

    def wrap_line(line)
      return [''] if line.strip.empty?

      char_width = @font_size * @layer_config.char_width_multiplier
      words = line.split(/\s+/)
      process_words(words, char_width)
    end

    def process_words(words, char_width)
      lines = []
      current = ''

      words.each do |word|
        current, completed_line = process_word(word, current, char_width)
        lines << completed_line if completed_line
      end
      lines << current unless current.empty?
      lines
    end

    def process_word(word, current, char_width)
      test = current.empty? ? word : "#{current} #{word}"
      if test.length * char_width <= @available_width
        [test, nil]
      else
        [word, current]
      end
    end

    class << self
      # Convenience method for backward compatibility
      def wrapped_text_lines(*, **)
        new(*, **).wrapped_text_lines
      end
    end
  end
end
