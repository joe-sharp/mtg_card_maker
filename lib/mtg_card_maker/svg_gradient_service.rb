# frozen_string_literal: true

module MtgCardMaker
  # Simplified gradient definitions for SVG cards
  # Removes complex abstraction in favor of direct gradient creation
  class SvgGradientService # rubocop:disable Metrics/ClassLength
    class << self
      # Defines all gradients needed for a color scheme
      def define_all_gradients(svg, color_scheme = DEFAULT_COLOR_SCHEME)
        svg.defs do
          define_standard_gradients(svg, color_scheme)
          define_metallic_gradients(svg, color_scheme) if metallic_properties?(color_scheme)
        end
      end

      # Get gradient ID for card gradient
      def card_gradient_id(color_scheme)
        "#{color_scheme.scheme_name}_card_gradient"
      end

      # Get gradient ID for frame gradient
      def frame_gradient_id(color_scheme)
        "#{color_scheme.scheme_name}_frame_gradient"
      end

      # Get gradient ID for name gradient
      def name_gradient_id(color_scheme)
        "#{color_scheme.scheme_name}_name_gradient"
      end

      # Get gradient ID for description gradient
      def description_gradient_id(color_scheme)
        "#{color_scheme.scheme_name}_description_gradient"
      end

      # Get gradient ID for metallic highlight gradient
      def metallic_highlight_gradient_id(color_scheme)
        "#{color_scheme.scheme_name}_metallic_highlight_gradient"
      end

      # Get gradient ID for metallic shadow gradient
      def metallic_shadow_gradient_id(color_scheme)
        "#{color_scheme.scheme_name}_metallic_shadow_gradient"
      end

      # Get pattern ID for metallic texture
      def metallic_pattern_id(color_scheme)
        "#{color_scheme.scheme_name}_metallic_pattern"
      end

      # Check if color scheme has metallic properties
      def metallic_properties?(color_scheme)
        [:gold, :colorless].include?(color_scheme.scheme_name)
      end

      def define_standard_gradients(svg, color_scheme)
        scheme_name = color_scheme.scheme_name

        define_card_gradient(svg, color_scheme, scheme_name)
        define_frame_gradient(svg, color_scheme, scheme_name)
        define_name_gradient(svg, color_scheme, scheme_name)
        define_description_gradient(svg, color_scheme, scheme_name)
      end

      def define_card_gradient(svg, color_scheme, scheme_name)
        svg.linearGradient id: "#{scheme_name}_card_gradient", x1: '0%', y1: '0%', x2: '100%', y2: '100%' do
          svg.stop offset: '0%', 'stop-color': color_scheme.card_gradient_start
          svg.stop offset: '50%', 'stop-color': color_scheme.card_gradient_middle
          svg.stop offset: '100%', 'stop-color': color_scheme.card_gradient_end
        end
      end

      def define_frame_gradient(svg, color_scheme, scheme_name)
        svg.linearGradient id: "#{scheme_name}_frame_gradient", x1: '0%', y1: '0%', x2: '100%', y2: '100%' do
          svg.stop offset: '0%', 'stop-color': color_scheme.frame_gradient_start
          svg.stop offset: '50%', 'stop-color': color_scheme.frame_gradient_middle
          svg.stop offset: '100%', 'stop-color': color_scheme.frame_gradient_end
        end
      end

      def define_name_gradient(svg, color_scheme, scheme_name)
        svg.linearGradient id: "#{scheme_name}_name_gradient", x1: '0%', y1: '0%', x2: '100%', y2: '100%' do
          svg.stop offset: '0%', 'stop-color': color_scheme.name_gradient_start
          svg.stop offset: '50%', 'stop-color': color_scheme.name_gradient_middle
          svg.stop offset: '100%', 'stop-color': color_scheme.name_gradient_end
        end
      end

      def define_description_gradient(svg, color_scheme, scheme_name)
        svg.linearGradient id: "#{scheme_name}_description_gradient", x1: '0%', y1: '0%', x2: '100%', y2: '100%' do
          svg.stop offset: '0%', 'stop-color': color_scheme.description_gradient_start
          svg.stop offset: '50%', 'stop-color': color_scheme.description_gradient_middle
          svg.stop offset: '100%', 'stop-color': color_scheme.description_gradient_end
        end
      end

      def define_metallic_gradients(svg, color_scheme)
        scheme_name = color_scheme.scheme_name

        define_metallic_highlight_gradient(svg, color_scheme, scheme_name)
        define_metallic_shadow_gradient(svg, color_scheme, scheme_name)
        define_metallic_pattern(svg, color_scheme, scheme_name)
      end

      def define_metallic_highlight_gradient(svg, color_scheme, scheme_name)
        svg.linearGradient id: "#{scheme_name}_metallic_highlight_gradient", x1: '0%', y1: '0%', x2: '100%',
                           y2: '100%' do
          svg.stop offset: '0%', 'stop-color': color_scheme.metallic_highlight_end, 'stop-opacity': '0.6'
          svg.stop offset: '20%', 'stop-color': color_scheme.metallic_highlight_middle, 'stop-opacity': '0.9'
          svg.stop offset: '38%', 'stop-color': color_scheme.metallic_highlight_start, 'stop-opacity': '1.0'
          svg.stop offset: '42%', 'stop-color': color_scheme.metallic_highlight_middle, 'stop-opacity': '0.7'
          svg.stop offset: '62%', 'stop-color': color_scheme.metallic_highlight_end, 'stop-opacity': '0.5'
          svg.stop offset: '73%', 'stop-color': color_scheme.metallic_highlight_start, 'stop-opacity': '0.8'
          svg.stop offset: '80%', 'stop-color': color_scheme.metallic_highlight_middle, 'stop-opacity': '0.6'
          svg.stop offset: '100%', 'stop-color': color_scheme.metallic_highlight_end, 'stop-opacity': '0.4'
        end
      end

      def define_metallic_shadow_gradient(svg, color_scheme, scheme_name)
        svg.radialGradient id: "#{scheme_name}_metallic_shadow_gradient", cx: '50%', cy: '50%', r: '70%' do
          svg.stop offset: '0%', 'stop-color': color_scheme.metallic_shadow_start, 'stop-opacity': '0.3'
          svg.stop offset: '50%', 'stop-color': color_scheme.metallic_shadow_middle, 'stop-opacity': '0.5'
          svg.stop offset: '100%', 'stop-color': color_scheme.metallic_shadow_end, 'stop-opacity': '0.7'
        end
      end

      def define_metallic_pattern(svg, color_scheme, scheme_name)
        svg.pattern id: "#{scheme_name}_metallic_pattern", x: '0', y: '0', width: '20', height: '20',
                    patternUnits: 'userSpaceOnUse' do
          add_metallic_pattern_lines(svg, color_scheme)
          add_metallic_pattern_circles(svg, color_scheme)
        end
      end

      def add_metallic_pattern_lines(svg, color_scheme)
        svg.line x1: '0', y1: '0', x2: '20', y2: '20',
                 stroke: color_scheme.metallic_pattern_light,
                 'stroke-width': '0.5',
                 opacity: '0.3'
        svg.line x1: '20', y1: '0', x2: '0', y2: '20',
                 stroke: color_scheme.metallic_pattern_dark,
                 'stroke-width': '0.5',
                 opacity: '0.2'
      end

      def add_metallic_pattern_circles(svg, color_scheme)
        svg.circle cx: '5', cy: '5', r: '0.5',
                   fill: color_scheme.metallic_pattern_light,
                   opacity: '0.6'
        svg.circle cx: '15', cy: '15', r: '0.5',
                   fill: color_scheme.metallic_pattern_light,
                   opacity: '0.6'
        svg.circle cx: '10', cy: '10', r: '0.3',
                   fill: color_scheme.metallic_pattern_dark,
                   opacity: '0.4'
      end
    end
  end
end
