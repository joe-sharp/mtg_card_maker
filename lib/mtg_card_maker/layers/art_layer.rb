# frozen_string_literal: true

require 'addressable/uri'
require_relative '../../mtg_card_maker'

module MtgCardMaker
  # ArtLayer is a specialized layer for card artwork.
  # It provides a placeholder for the art area,
  # the art itself is not a feature of this gem.
  class ArtLayer < BaseLayer
    attr_reader :color_scheme, :art

    def initialize(dimensions:, color_scheme: DEFAULT_COLOR_SCHEME, art: nil)
      super(dimensions: dimensions, color: '#000')
      @color_scheme = color_scheme
      @art = parse_image_url(art)
    end

    # Render the art area with an ornate frame and optional image
    def render
      layer_config = LayerConfig.default
      stroke_width = layer_config.stroke_width
      outer_corners = layer_config.corner_radius(:art)
      inner_corners = { x: 5, y: 5 } # Inner frame uses smaller radius

      svg.g do
        # Ornate art frame
        svg.rect x: x - 3, y: y - 3,
                 width: width + 6, height: height + 6,
                 fill: 'none',
                 stroke: color_scheme.primary_color,
                 stroke_width: stroke_width,
                 rx: outer_corners[:x], ry: outer_corners[:y]

        # Frame border for the transparent window
        svg.rect x: x, y: y, width: width, height: height, fill: 'none',
                 stroke: ColorPalette::FRAME_STROKE_COLOR, stroke_width: stroke_width,
                 rx: inner_corners[:x], ry: inner_corners[:y]

        # Render image if provided
        render_image if art
      end
    end

    private

    def parse_image_url(url)
      return nil if url.nil? || url.empty?

      begin
        Addressable::URI.parse(url).to_s
      rescue Addressable::URI::InvalidURIError => e
        raise ArgumentError, "Invalid image URL: '#{url}'. Error: #{e.message}"
      end
    end

    def render_image
      svg.image href: art,
                x: x, y: y, width: width, height: height,
                preserveAspectRatio: 'xMidYMid slice'
    end
  end
end
