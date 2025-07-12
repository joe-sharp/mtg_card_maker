# frozen_string_literal: true

require_relative '../metallic_renderer'

module MtgCardMaker
  # BorderLayer is a specialized layer for the border of the card.
  # It renders the outermost border of the card and supports four color options:
  # white, black, silver (colorless), and gold. The layer includes QR codes
  # and copyright text at the bottom.
  #
  # @example
  #   layer = MtgCardMaker::BorderLayer.new(
  #     dimensions: { x: 0, y: 0, width: 630, height: 880 },
  #     color: :gold,
  #     mask_id: 'artWindowMask'
  #   )
  #   layer.render
  #
  # @since 0.1.0
  class BorderLayer < BaseLayer
    include MetallicRenderer
    include LayerInitializer

    # @return [ColorScheme] the color scheme for this layer
    attr_reader :color_scheme

    # @return [String] the mask ID for the art window
    attr_reader :mask_id

    # Supported colors for the border
    # @return [Hash] the supported color mappings
    SUPPORTED_COLORS = {
      white: '#EEE',
      black: '#000',
      silver: :colorless,
      gold: :gold
    }.freeze

    # Initialize a new border layer
    #
    # @param dimensions [Hash] the layer dimensions
    # @option dimensions [Integer] :x the x-coordinate
    # @option dimensions [Integer] :y the y-coordinate
    # @option dimensions [Integer] :width the width
    # @option dimensions [Integer] :height the height
    # @param color [Symbol] the frame color (default: :white)
    # @param mask_id [String] the mask ID for art window (default: 'artWindowMask')
    # @raise [ArgumentError] if the color is not supported
    def initialize(dimensions:, color: :white, mask_id: 'artWindowMask')
      @color = color.to_sym
      validate_color!

      @mask_id = mask_id
      @icon_service = IconService.new
      @color_scheme = ColorScheme.new(color_key_for(@color))
      super(dimensions: dimensions, color: @color)
    end

    # Render the border layer with QR code and copyright text
    #
    # @return [void]
    def render
      layer_config = LayerConfig.default
      corners = layer_config.corner_radius(:outer)
      color_key = color_key_for(@color)

      render_frame_by_color(color_key, corners)
      render_qr_code
      render_copyright_texts(layer_config)
    end

    private

    def render_frame_by_color(color, corners)
      case color
      when :white
        render_white_frame(corners)
      when :black
        render_black_frame(corners)
      when :colorless, :gold
        render_metallic_frame(corners)
      else
        raise ArgumentError, "Unsupported border color: #{color.inspect}. Supported: white, black, silver, gold."
      end
    end

    def render_white_frame(corners)
      svg.rect x: x, y: y, width: width, height: height,
               fill: SUPPORTED_COLORS[:white], rx: corners[:x], ry: corners[:y],
               mask: "url(##{@mask_id})"
    end

    def render_black_frame(corners)
      svg.rect x: x, y: y, width: width, height: height,
               fill: SUPPORTED_COLORS[:black], rx: corners[:x], ry: corners[:y],
               mask: "url(##{@mask_id})"
    end

    def render_metallic_frame(corners)
      svg.rect x: x, y: y,
               width: width, height: height,
               rx: corners[:x], ry: corners[:y],
               fill: '#EEE',
               mask: "url(##{@mask_id})"
      SvgGradientService.define_all_gradients(svg, color_scheme)
      render_metallic_elements(
        mask: @mask_id,
        corners: corners,
        geometry: { x: x, y: y, width: width, height: height, padding: 0 },
        bottom_margin: 0,
        opacity: { texture: 0.15, shadow: 0.18 }
      )
    end

    def validate_color!
      return if SUPPORTED_COLORS.key?(@color)

      raise ArgumentError, "Unsupported border color: #{@color.inspect}. Supported: white, black, silver, gold."
    end

    def color_key_for(color)
      return :colorless if color == :silver
      return :gold if color == :gold

      color
    end

    def fill_color
      @color == :black ? '#FFF' : '#111'
    end

    def render_qr_code
      qr_svg_content = @icon_service.qr_code_svg
      raise 'QR code SVG content is nil' unless qr_svg_content

      # Extract the path data from the SVG content
      path_match = qr_svg_content.match(/<path[^>]*d="([^"]*)"[^>]*>/)
      raise 'No path element found in QR code SVG' unless path_match

      svg.path fill: fill_color, transform: 'translate(40,820) scale(1.1)',
               d: path_match[1]
    end

    def render_copyright_texts(layer_config)
      copyright_texts = [
        '© 2025 Joe Sharp. Some rights reserved.',
        'Portions of the materials used are property of Wizards of the Coast.',
        '© Wizards of the Coast LLC'
      ]

      copyright_config = layer_config.copyright_config

      copyright_texts.each_with_index do |text, index|
        copyright_attrs = {
          x: copyright_config[:x_position],
          y: copyright_config[:base_y] + (index * copyright_config[:line_spacing]),
          fill: fill_color,
          font_size: layer_config.font_size(:copyright),
          text_anchor: 'start',
          class: 'card-copyright'
        }
        svg.text text, copyright_attrs
      end
    end
  end
end
