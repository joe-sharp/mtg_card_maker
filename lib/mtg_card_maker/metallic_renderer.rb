# frozen_string_literal: true

module MtgCardMaker
  # Mixin for metallic rendering logic shared by multiple layers
  module MetallicRenderer
    # Parameter validation and sharing class for metallic rendering
    class MetallicRenderParams
      attr_reader :mask, :corners, :bottom_margin, :opacity, :geometry_params

      def initialize(config_params = {})
        @mask = config_params[:mask]
        @corners = config_params[:corners] || LayerConfig.default.corner_radius(:inner)
        @bottom_margin = config_params[:bottom_margin] || 0
        @opacity = config_params[:opacity] || {}
        @geometry_params = config_params[:geometry] || {}
      end

      def texture_opacity
        opacity[:texture] || 0.05
      end

      def shadow_opacity
        opacity[:shadow] || 0.08
      end

      def shadow_offset
        2
      end

      def shadow_corners
        {
          x: [corners[:x] - shadow_offset, 0].max,
          y: [corners[:y] - shadow_offset, 0].max
        }
      end
    end

    # Entrypoint for metallic rendering
    def render_metallic_elements(config_params = {})
      params = MetallicRenderParams.new(config_params)

      render_base_frame(params)
      render_texture_overlay(params)
      render_shadow(params)
    end

    private

    def render_base_frame(params)
      create_rect(
        params.geometry_params,
        params.bottom_margin,
        params.mask,
        params.corners,
        fill: "url(##{SvgGradientService.metallic_highlight_gradient_id(color_scheme)})",
        stroke: color_scheme.primary_color,
        stroke_width: LayerConfig.default.stroke_width
      )
    end

    def render_texture_overlay(params)
      create_rect(
        params.geometry_params,
        params.bottom_margin,
        params.mask,
        params.corners,
        fill: "url(##{SvgGradientService.metallic_pattern_id(color_scheme)})",
        opacity: params.texture_opacity
      )
    end

    def render_shadow(params)
      shadow_attrs = shadow_attributes(params)
      create_rect(
        params.geometry_params,
        params.bottom_margin,
        params.mask,
        params.corners,
        **shadow_attrs
      )
    end

    def shadow_attributes(params)
      {
        fill: "url(##{SvgGradientService.metallic_shadow_gradient_id(color_scheme)})",
        opacity: params.shadow_opacity,
        x_offset: params.shadow_offset,
        y_offset: params.shadow_offset,
        width_offset: params.shadow_offset * 2,
        height_offset: params.shadow_offset * 2,
        rx: params.shadow_corners[:x],
        ry: params.shadow_corners[:y]
      }
    end

    def create_rect(geometry_params, bottom_margin, mask, corners, **attributes)
      rect_attributes = build_rect_attributes(geometry_params, bottom_margin, mask, corners, attributes)
      svg.rect(**rect_attributes)
    end

    def build_rect_attributes(geometry_params, bottom_margin, mask, corners, attributes)
      geometry = extract_geometry(geometry_params)
      offsets = extract_offsets(attributes)
      base_attrs = {
        x: rect_x(geometry, offsets),
        y: rect_y(geometry, offsets),
        width: rect_width(geometry, offsets),
        height: rect_height(geometry, bottom_margin, offsets),
        mask: mask ? "url(##{mask})" : nil,
        rx: attributes[:rx] || corners[:x],
        ry: attributes[:ry] || corners[:y]
      }.compact
      # Merge in all other SVG attributes (fill, opacity, stroke, etc.)
      base_attrs.merge!(attributes)
      base_attrs
    end

    def rect_x(geometry, offsets)
      geometry[:x] + geometry[:padding] + offsets[:x]
    end

    def rect_y(geometry, offsets)
      geometry[:y] + geometry[:padding] + offsets[:y]
    end

    def rect_width(geometry, offsets)
      geometry[:width] - (geometry[:padding] * 2) - offsets[:width]
    end

    def rect_height(geometry, bottom_margin, offsets)
      geometry[:height] - bottom_margin - offsets[:height]
    end

    def extract_geometry(geometry_params)
      layer_config = LayerConfig.default
      {
        x: geometry_x(geometry_params),
        y: geometry_y(geometry_params),
        width: geometry_width(geometry_params),
        height: geometry_height(geometry_params),
        padding: geometry_padding(geometry_params, layer_config)
      }
    end

    def geometry_x(geometry_params)
      geometry_params[:x] || (respond_to?(:x) ? x : 0)
    end

    def geometry_y(geometry_params)
      geometry_params[:y] || (respond_to?(:y) ? y : 0)
    end

    def geometry_width(geometry_params)
      geometry_params[:width] || (respond_to?(:width) ? width : 0)
    end

    def geometry_height(geometry_params)
      geometry_params[:height] || (respond_to?(:height) ? height : 0)
    end

    def geometry_padding(geometry_params, layer_config)
      geometry_params[:padding] || layer_config.horizontal_padding
    end

    def extract_offsets(attributes)
      {
        x: attributes.delete(:x_offset) || 0,
        y: attributes.delete(:y_offset) || 0,
        width: attributes.delete(:width_offset) || 0,
        height: attributes.delete(:height_offset) || 0
      }
    end
  end
end
