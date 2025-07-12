# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker do
  describe 'Color Integration' do
    describe 'color scheme rendering differences' do
      it 'renders white cards with white color scheme' do
        white_layer = MtgCardMaker::NameLayer.new(
          dimensions: { x: 30, y: 40, width: 570, height: 50 },
          name: 'White Card',
          cost: '2W',
          color_scheme: MtgCardMaker::ColorScheme.new(:white)
        )

        # White cards should have white-specific gradients
        expect_svg_to_contain(white_layer, 'white_frame_gradient')
        expect_svg_to_contain(white_layer, 'white_name_gradient')
        expect_svg_to_contain(white_layer, 'White Card')
      end

      it 'renders blue cards with blue color scheme' do
        blue_layer = MtgCardMaker::NameLayer.new(
          dimensions: { x: 30, y: 40, width: 570, height: 50 },
          name: 'Blue Card',
          cost: '2U',
          color_scheme: MtgCardMaker::ColorScheme.new(:blue)
        )

        # Blue cards should have blue-specific gradients
        expect_svg_to_contain(blue_layer, 'blue_frame_gradient')
        expect_svg_to_contain(blue_layer, 'blue_name_gradient')
        expect_svg_to_contain(blue_layer, 'Blue Card')
      end

      it 'renders gold cards with metallic effects' do
        gold_layer = MtgCardMaker::NameLayer.new(
          dimensions: { x: 30, y: 40, width: 570, height: 50 },
          name: 'Gold Card',
          cost: '2WU',
          color_scheme: MtgCardMaker::ColorScheme.new(:gold)
        )

        # Gold cards should have metallic gradients
        expect_svg_to_contain(gold_layer, 'gold_metallic_highlight_gradient')
        expect_svg_to_contain(gold_layer, 'gold_metallic_shadow_gradient')
        expect_svg_to_contain(gold_layer, 'Gold Card')
      end

      it 'renders artifact cards with artifact color scheme' do
        artifact_layer = MtgCardMaker::NameLayer.new(
          dimensions: { x: 30, y: 40, width: 570, height: 50 },
          name: 'Artifact Card',
          cost: '3',
          color_scheme: MtgCardMaker::ColorScheme.new(:artifact)
        )

        # Artifact cards should have artifact-specific gradients
        expect_svg_to_contain(artifact_layer, 'artifact_frame_gradient')
        expect_svg_to_contain(artifact_layer, 'artifact_name_gradient')
        expect_svg_to_contain(artifact_layer, 'Artifact Card')
      end
    end

    describe 'color scheme consistency' do
      it 'maintains consistent colors across different layer types' do
        white_scheme = MtgCardMaker::ColorScheme.new(:white)

        # Test that the same color scheme produces consistent colors across layers
        name_layer = MtgCardMaker::NameLayer.new(
          dimensions: { x: 30, y: 40, width: 570, height: 50 },
          name: 'Test Card',
          cost: '2W',
          color_scheme: white_scheme
        )

        type_layer = MtgCardMaker::TypeLineLayer.new(
          dimensions: { x: 30, y: 420, width: 570, height: 40 },
          type_line: 'Creature',
          color_scheme: white_scheme
        )

        # Both layers should use the same white color scheme
        expect_svg_to_contain(name_layer, 'white_frame_gradient')
        expect_svg_to_contain(type_layer, 'white_frame_gradient')
      end

      it 'applies correct text colors for each color scheme' do
        # Test that different color schemes use appropriate text colors
        white_layer = MtgCardMaker::NameLayer.new(
          dimensions: { x: 30, y: 40, width: 570, height: 50 },
          name: 'White Card',
          cost: '2W',
          color_scheme: MtgCardMaker::ColorScheme.new(:white)
        )

        black_layer = MtgCardMaker::NameLayer.new(
          dimensions: { x: 30, y: 40, width: 570, height: 50 },
          name: 'Black Card',
          cost: '2B',
          color_scheme: MtgCardMaker::ColorScheme.new(:black)
        )

        # Both should have text, but with different styling
        expect_svg_to_have_text(white_layer, 'White Card')
        expect_svg_to_have_text(black_layer, 'Black Card')

        # White should use white-specific styling
        expect_svg_to_contain(white_layer, 'white_name_gradient')

        # Black should use black-specific styling
        expect_svg_to_contain(black_layer, 'black_name_gradient')
      end
    end

    describe 'color scheme edge cases' do
      it 'handles colorless cards correctly' do
        colorless_layer = MtgCardMaker::NameLayer.new(
          dimensions: { x: 30, y: 40, width: 570, height: 50 },
          name: 'Colorless Card',
          cost: '6',
          color_scheme: MtgCardMaker::ColorScheme.new(:colorless)
        )

        # Colorless cards should have colorless-specific styling
        expect_svg_to_contain(colorless_layer, 'colorless_frame_gradient')
        expect_svg_to_contain(colorless_layer, 'Colorless Card')
      end

      it 'handles cards without color scheme gracefully' do
        default_layer = MtgCardMaker::NameLayer.new(
          dimensions: { x: 30, y: 40, width: 570, height: 50 },
          name: 'Default Card',
          cost: '2'
          # No color_scheme specified
        )

        # Should still render without errors
        expect_svg_generation_to_succeed(default_layer)
        expect_svg_to_have_text(default_layer, 'Default Card')
      end
    end
  end
end
