# frozen_string_literal: true

module MtgCardMaker
  # Handles the creation of shared assets (fonts, gradients, masks) for sprite sheets
  class SpriteSheetAssets
    def initialize
      @color_schemes = build_color_schemes
    end

    # Add all shared assets to the sprite sheet XML
    def add_assets_to_sprite(xml)
      add_sprite_styles(xml)
      add_sprite_masks(xml)
      add_sprite_gradients(xml)
    end

    private

    def add_sprite_styles(xml)
      xml.defs do
        xml.style(type: 'text/css') do
          xml.cdata <<~CSS
            @font-face {
              font-family: 'Goudy Mediaeval DemiBold';
              src: url('fonts/Goudy Mediaeval DemiBold.ttf') format('truetype');
              font-weight: normal;
              font-style: normal;
            }

            .card-name {
              font-family: 'Goudy Mediaeval DemiBold', serif;
              font-weight: normal;
              font-style: normal;
            }

            .card-type {
              font-family: 'Goudy Mediaeval DemiBold', serif;
              font-weight: normal;
              font-style: normal;
            }

            .card-description {
              font-family: serif;
              font-weight: normal;
              font-style: normal;
            }

            .card-flavor-text {
              font-family: serif;
              font-weight: normal;
              font-style: italic;
            }

            .card-power-toughness {
              font-family: serif;
              font-weight: bold;
              font-style: normal;
            }

            .mana-cost-text {
              font-family: serif;
              font-weight: normal;
              font-style: normal;
            }

            .mana-cost-text-large {
              font-family: serif;
              font-weight: semibold;
              font-style: normal;
            }
          CSS
        end
      end
    end

    def add_sprite_masks(xml)
      xml.defs do
        # Define the art window mask once for the entire sprite sheet
        xml.mask(id: 'artWindowMask') do
          # White rectangle covers the entire card (opaque)
          xml.rect(x: 0, y: 0, width: '100%', height: '100%', fill: '#FFF')
          # Black rectangle creates the transparent window at art position
          art_config = BaseCard::DEFAULTS[:layers][:art_layer]
          xml.rect(x: art_config[:x], y: art_config[:y],
                   width: art_config[:width], height: art_config[:height],
                   fill: '#000', rx: art_config[:corner_radius][:x], ry: art_config[:corner_radius][:y])
        end
      end
    end

    def add_sprite_gradients(xml)
      # Define gradients for all color schemes using SvgGradientService
      @color_schemes.each do |color_scheme|
        SvgGradientService.define_standard_gradients(xml, color_scheme)
        if SvgGradientService.metallic_properties?(color_scheme)
          SvgGradientService.define_metallic_gradients(xml,
                                                       color_scheme)
        end
      end
    end

    # Test compatibility methods - delegate to SvgGradientService
    def define_gradient(xml, color_scheme, scheme_name, gradient_type, _color_methods)
      case gradient_type
      when 'card'
        SvgGradientService.define_card_gradient(xml, color_scheme, scheme_name)
      when 'frame'
        SvgGradientService.define_frame_gradient(xml, color_scheme, scheme_name)
      when 'name'
        SvgGradientService.define_name_gradient(xml, color_scheme, scheme_name)
      when 'description'
        SvgGradientService.define_text_box_gradient(xml, color_scheme, scheme_name)
      end
    end

    def define_metallic_gradients(xml, color_scheme, _scheme_name)
      SvgGradientService.define_metallic_gradients(xml, color_scheme)
    end

    def define_metallic_highlight_gradient(xml, color_scheme, scheme_name)
      SvgGradientService.define_metallic_highlight_gradient(xml, color_scheme, scheme_name)
    end

    def define_metallic_shadow_gradient(xml, color_scheme, scheme_name)
      SvgGradientService.define_metallic_shadow_gradient(xml, color_scheme, scheme_name)
    end

    def define_metallic_pattern(xml, color_scheme, scheme_name)
      SvgGradientService.define_metallic_pattern(xml, color_scheme, scheme_name)
    end

    def add_metallic_pattern_lines(xml, color_scheme)
      SvgGradientService.add_metallic_pattern_lines(xml, color_scheme)
    end

    def add_metallic_pattern_circles(xml, color_scheme)
      SvgGradientService.add_metallic_pattern_circles(xml, color_scheme)
    end

    def metallic_properties?(color_scheme)
      SvgGradientService.metallic_properties?(color_scheme)
    end

    def build_color_schemes
      # Define all possible color schemes to ensure coverage
      [
        ColorScheme.new(:colorless),
        ColorScheme.new(:white),
        ColorScheme.new(:blue),
        ColorScheme.new(:black),
        ColorScheme.new(:red),
        ColorScheme.new(:green),
        ColorScheme.new(:gold),
        ColorScheme.new(:artifact)
      ]
    end
  end
end
