# frozen_string_literal: true

module MtgCardMaker
  # Service class for managing CSS styles used across the application
  class CssService
    class << self
      # Generate the font face declaration
      #
      # @param embed [Boolean] whether to embed the font as base64
      # @return [String] the font face CSS
      def font_face(embed: false)
        return '' unless embed

        font_path = File.join(__dir__, 'fonts', 'goudy_base64.txt')
        base64_font_data = File.read(font_path).strip
        <<~CSS
          @font-face {
            font-family: 'Goudy Mediaeval DemiBold';
            src: url(data:font/truetype;charset=utf-8;base64,#{base64_font_data}) format('truetype');
          }
        CSS
      end

      # Generate all CSS classes
      #
      # @return [String] the CSS classes
      def css_classes(embed: false)
        <<~CSS
          /* Font Classes */
          .card-name, .card-type {
            font-family: #{font_family(embed)};
            font-weight: #{font_weight(embed)};
          }

          .card-rules-text, .mana-cost-text {
            font-family: serif;
          }

          .card-flavor-text {
            font-family: serif;
            font-style: italic;
          }

          .card-power-toughness {
            font-family: serif;
            font-weight: bold;
          }

          .card-copyright {
            font-family: sans-serif;
          }
        CSS
      end

      def font_family(embed)
        embed ? "'Goudy Mediaeval DemiBold', serif" : 'serif'
      end

      def font_weight(embed)
        embed ? 'normal' : 'bold'
      end

      # Generate complete CSS styles
      #
      # @param embed [Boolean] whether to embed the font as base64
      # @return [String] the complete CSS styles
      def complete_styles(embed: false)
        font_face(embed: embed) + css_classes(embed: embed)
      end
    end
  end
end
