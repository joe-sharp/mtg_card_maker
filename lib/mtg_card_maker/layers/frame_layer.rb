# frozen_string_literal: true

require_relative '../metallic_renderer'

module MtgCardMaker
  # FrameLayer is a specialized layer for the colored frame of the card
  # You choose the color, making it possible to make a blue card
  # that costs mountains, for example.
  class FrameLayer < BaseLayer
    include MetallicRenderer
    include LayerInitializer
    attr_reader :color_scheme, :mask_id, :layer_config

    def initialize(dimensions:, color: nil, color_scheme: DEFAULT_COLOR_SCHEME, mask_id: 'artWindowMask')
      frame_color = initialize_layer_color(color, color_scheme, :primary_color)
      super(dimensions: dimensions, color: frame_color)
      @color_scheme = color_scheme
      @mask_id = mask_id
      @layer_config = LayerConfig.default
    end

    # Render the frame with a gradient background
    def render
      SvgGradientService.define_all_gradients(svg, color_scheme)
      if metallic_properties?
        render_metallic_frame
      else
        render_standard_frame
      end
    end

    private

    def render_metallic_frame
      render_standard_frame
      render_metallic_elements(
        mask: @mask_id,
        bottom_margin: layer_config.frame_bottom_margin,
        opacity: { texture: 0.3, shadow: 0.4 }
      )
    end

    def metallic_properties?
      color_scheme.scheme_name == :gold
    end

    def render_standard_frame # rubocop:disable Metrics/AbcSize
      stroke_width = layer_config.stroke_width
      corners = layer_config.corner_radius(:inner)
      padding = layer_config.horizontal_padding
      bottom_margin = layer_config.frame_bottom_margin # Space for type line and power/toughness

      # Inner decorative frame with mask for transparent window
      svg.rect x: x + padding, y: y + padding,
               width: width - (padding * 2), height: height - bottom_margin,
               fill: "url(##{SvgGradientService.frame_gradient_id(color_scheme)})",
               stroke: color_scheme.primary_color,
               stroke_width: stroke_width,
               rx: corners[:x], ry: corners[:y], mask: "url(##{@mask_id})"
    end
  end
end
