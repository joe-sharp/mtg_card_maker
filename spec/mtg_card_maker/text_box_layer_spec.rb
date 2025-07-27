# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::TextBoxLayer do
  let(:rules_text) { 'Deal 3 damage to any target.' }
  let(:flavor_text) { 'The spark of inspiration.' }

  it 'inherits from BaseLayer' do
    expect(described_class).to be < MtgCardMaker::BaseLayer
  end

  it 'uses correct default color' do
    layer = described_class.new(
      dimensions: { x: 0, y: 0, width: 100, height: 100 },
      rules_text: rules_text
    )
    expect(layer.color).to eq('#E8E8E8')
  end

  it 'matches expected fixture output' do
    fixture_layer = described_class.new(
      dimensions: { x: 40, y: 545, width: 550, height: 265 },
      rules_text: 'MTG Card Maker is unofficial Fan Content permitted ' \
                  'under the Fan Content Policy. Not approved/endorsed ' \
                  'by Wizards. Portions of the materials used are ' \
                  "property of Wizards of the Coast.\n\n" \
                  '©Wizards of the Coast LLC.',
      flavor_text: 'MTG Card Maker is a tool for creating fan-made MTG cards\t\t-- Joe Sharp'
    )
    expect_svg_to_match_fixture(fixture_layer, 'text_box_layer')
  end

  context 'with text wrapping behavior' do
    it 'breaks long text into multiple lines' do
      long_text = 'This is a very long piece of text that should be broken into multiple lines'
      long_layer = described_class.new(dimensions: { x: 10, y: 10, width: 100, height: 100 }, rules_text: long_text)

      # Should have multiple text elements for wrapped lines
      svg_content = generate_svg_for_layer(long_layer, canvas_width: 200, canvas_height: 200)
      text_count = svg_content.scan('<text').length
      expect(text_count).to be > 3 # Should be broken into multiple lines
    end

    it 'handles short text without unnecessary wrapping' do
      short_text = 'Short text'
      short_layer = described_class.new(dimensions: { x: 10, y: 10, width: 200, height: 50 }, rules_text: short_text)

      # Should have minimal text elements for short text
      svg_content = generate_svg_for_layer(short_layer, canvas_width: 300, canvas_height: 100)
      text_count = svg_content.scan('<text').length
      expect(text_count).to be >= 1 # At least one text element
    end

    it 'handles empty rules text' do
      empty_layer = described_class.new(dimensions: { x: 10, y: 10, width: 100, height: 50 }, rules_text: '')

      # Should still generate SVG structure even with empty text
      expect_svg_to_have_elements(empty_layer, 'g', 'rect')
    end

    it 'respects manual line breaks' do
      manual_breaks = "a very long line\nthat is manually broken\nup how the user wants"
      manual_breaks_layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 500, height: 100 },
        rules_text: manual_breaks
      )

      # Count text elements to verify line wrapping
      svg_content = generate_svg_for_layer(manual_breaks_layer, canvas_width: 600, canvas_height: 200)
      text_count = svg_content.scan('<text').length
      expect(text_count).to eq(3) # One text element per line (due to manual breaks)
    end

    it 'handles text with empty lines from consecutive newlines' do
      # This tests the branch where current_line.empty? in build_lines_from_words
      text_with_empty_lines = "word1\n\nword2"
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 200, height: 100 },
        rules_text: text_with_empty_lines
      )

      # Should handle empty lines gracefully without adding them
      expect_svg_to_have_text(layer, 'word1')
      expect_svg_to_have_text(layer, 'word2')

      svg_content = generate_svg_for_layer(layer, canvas_width: 300, canvas_height: 200)
      text_count = svg_content.scan('<text').length
      expect(text_count).to eq(2) # Should have 2 text elements; empty lines are not represented as text elements)
    end

    it 'handles single word that starts a new line' do
      # This tests the current_line.empty? ? word branch in append_word_to_line
      very_long_word = 'Abracadabra-Alakazam-Expelliarmus-Stupefy'
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 80, height: 100 }, # Very narrow width
        rules_text: very_long_word
      )

      # Should render the long word as the first word on a line
      expect_svg_to_have_text(layer, very_long_word)

      svg_content = generate_svg_for_layer(layer, canvas_width: 200, canvas_height: 200)
      text_count = svg_content.scan('<text').length
      expect(text_count).to eq(1) # Should have exactly one text element
    end
  end

  context 'with flavor text' do
    it 'renders flavor text with separator line' do
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 100, height: 100 },
        rules_text: rules_text,
        flavor_text: flavor_text
      )

      # Should have separator line when flavor text is present
      svg_content = generate_svg_for_layer(layer, canvas_width: 200, canvas_height: 200)
      # Count only separator lines (not metallic pattern lines)
      separator_lines = svg_content.scan(/<line[^>]*stroke-width="1"[^>]*>/).length
      expect(separator_lines).to eq(1)
    end

    it 'does not render separator line without flavor text' do
      layer_no_flavor = described_class.new(
        dimensions: { x: 10, y: 10, width: 100, height: 100 },
        rules_text: rules_text,
        flavor_text: nil
      )

      # Should not have separator line when flavor text is absent
      svg_content = generate_svg_for_layer(layer_no_flavor, canvas_width: 200, canvas_height: 200)
      # Count only separator lines (not metallic pattern lines)
      separator_lines = svg_content.scan(/<line[^>]*stroke-width="1"[^>]*>/).length
      expect(separator_lines).to eq(0)
    end
  end

  context 'with symbol rendering' do
    it 'renders text with mana symbols', :aggregate_failures do
      text_with_symbols = 'Deal {R} damage to any target.'
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 200, height: 100 },
        rules_text: text_with_symbols
      )

      svg_content = generate_svg_for_layer(layer, canvas_width: 300, canvas_height: 200)

      # Should use foreignObject for symbol rendering
      expect(svg_content).to include('<foreignObject')
      expect(svg_content).to include('xmlns=\'http://www.w3.org/1999/xhtml\'')
      expect(svg_content).to include('display: flex')
      expect(svg_content).to include('align-items: center')
    end

    it 'renders text with numeric symbols', :aggregate_failures do
      text_with_numeric = 'Add {1} to your mana pool.'
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 200, height: 100 },
        rules_text: text_with_numeric
      )

      svg_content = generate_svg_for_layer(layer, canvas_width: 300, canvas_height: 200)

      # Should use foreignObject for numeric symbol rendering
      expect(svg_content).to include('<foreignObject')
      expect(svg_content).to include('xmlns=\'http://www.w3.org/1999/xhtml\'')
    end

    it 'handles text with mixed symbols and regular text', :aggregate_failures do
      mixed_text = 'Deal {R} damage to any target. {1}{U}'
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 200, height: 100 },
        rules_text: mixed_text
      )

      svg_content = generate_svg_for_layer(layer, canvas_width: 300, canvas_height: 200)

      # Should use foreignObject for mixed content
      expect(svg_content).to include('<foreignObject')
      expect(svg_content).to include('xmlns=\'http://www.w3.org/1999/xhtml\'')
    end

    it 'handles text with unmatched braces gracefully' do
      text_with_unmatched = 'Deal {R damage to any target.'
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 200, height: 100 },
        rules_text: text_with_unmatched
      )

      # Should not crash and should render as regular text
      expect { generate_svg_for_layer(layer, canvas_width: 300, canvas_height: 200) }.not_to raise_error
    end

    it 'handles text ending with unmatched brace' do
      text_ending_brace = 'Deal damage to any target {'
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 200, height: 100 },
        rules_text: text_ending_brace
      )

      # Should not crash and should render as regular text
      expect { generate_svg_for_layer(layer, canvas_width: 300, canvas_height: 200) }.not_to raise_error
    end

    it 'handles text starting with closing brace' do
      text_starting_brace = '} Deal damage to any target'
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 200, height: 100 },
        rules_text: text_starting_brace
      )

      # Should not crash and should render as regular text
      expect { generate_svg_for_layer(layer, canvas_width: 300, canvas_height: 200) }.not_to raise_error
    end

    it 'handles text with empty braces' do
      text_with_empty_braces = 'Deal {} damage to any target.'
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 200, height: 100 },
        rules_text: text_with_empty_braces
      )

      # Should not crash and should render as regular text
      expect { generate_svg_for_layer(layer, canvas_width: 300, canvas_height: 200) }.not_to raise_error
    end
  end

  context 'with line placement logic' do
    it 'handles bidirectional text placement with separator', :aggregate_failures do
      # Test the upward and downward direction branches in calculate_line_number
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 200, height: 100 },
        rules_text: 'Short rules text.',
        flavor_text: 'Short flavor text.'
      )

      svg_content = generate_svg_for_layer(layer, canvas_width: 300, canvas_height: 200)

      # Should render both rules and flavor text
      expect(svg_content).to include('<text')
      expect(svg_content).to include('<line') # Separator line
    end

    it 'handles forward direction placement', :aggregate_failures do
      # Test the forward direction branch in calculate_line_number
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 200, height: 100 },
        rules_text: 'Short rules text only.'
      )

      svg_content = generate_svg_for_layer(layer, canvas_width: 300, canvas_height: 200)

      # Should render rules text only
      expect(svg_content).to include('<text')
      # Should not have separator lines (only metallic pattern lines)
      separator_lines = svg_content.scan(/<line[^>]*stroke-width="1"[^>]*>/).length
      expect(separator_lines).to eq(0)
    end

    it 'handles line number bounds checking', :aggregate_failures do
      # Test the break conditions in place_text_lines
      very_long_text = 'This is a very long piece of text that will exceed the maximum ' \
                       'number of lines allowed by the text box layer'
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 50, height: 50 }, # Very narrow and short
        rules_text: very_long_text
      )

      svg_content = generate_svg_for_layer(layer, canvas_width: 200, canvas_height: 200)

      # Should still render without crashing
      expect(svg_content).to include('<text')
      expect(svg_content).to include('<rect')
    end
  end

  context 'with separator positioning' do
    it 'handles separator line positioning correctly', :aggregate_failures do
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 200, height: 100 },
        rules_text: 'Short rules.',
        flavor_text: 'Short flavor.'
      )

      svg_content = generate_svg_for_layer(layer, canvas_width: 300, canvas_height: 200)

      # Should have separator line with correct positioning
      expect(svg_content).to include('<line')
      expect(svg_content).to include('stroke-width="1"')
    end

    it 'handles case where no separator exists', :aggregate_failures do
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 200, height: 100 },
        rules_text: 'Rules only.'
      )

      svg_content = generate_svg_for_layer(layer, canvas_width: 300, canvas_height: 200)

      # Should not have separator line
      separator_lines = svg_content.scan(/<line[^>]*stroke-width="1"[^>]*>/).length
      expect(separator_lines).to eq(0)
    end
  end

  context 'with text box lines management' do
    it 'handles text box lines initialization', :aggregate_failures do
      text_box_lines = MtgCardMaker::TextBoxLines.new(x: 10, y: 10, width: 200, height: 100)

      expect(text_box_lines.x).to eq(10)
      expect(text_box_lines.y).to be_within(0.1).of(13.33) # y + (line_spacing / 3)
      expect(text_box_lines.width).to eq(200)
      expect(text_box_lines.height).to eq(100)
    end

    it 'handles setting and getting lines', :aggregate_failures do
      text_box_lines = MtgCardMaker::TextBoxLines.new(x: 10, y: 10, width: 200, height: 100)

      text_box_lines.set_line(0, text: 'Test text', type: :rules_text)
      line_data = text_box_lines.get_line(0)

      expect(line_data[:text]).to eq('Test text')
      expect(line_data[:type]).to eq(:rules_text)
      expect(line_data[:y_pos]).to be > 0
    end

    it 'handles text lines filtering', :aggregate_failures do
      text_box_lines = MtgCardMaker::TextBoxLines.new(x: 10, y: 10, width: 200, height: 100)

      # Set some lines with different types
      text_box_lines.set_line(0, text: 'Rules text', type: :rules_text)
      text_box_lines.set_line(1, text: '', type: :rules_text) # Empty text
      text_box_lines.set_line(2, type: :separator) # Separator
      text_box_lines.set_line(3, text: 'Flavor text', type: :flavor_text)

      text_lines = text_box_lines.text_lines

      # Should only include non-empty, non-separator lines
      expect(text_lines.length).to eq(2)
      expect(text_lines.map { |line| line[:text] }).to contain_exactly('Rules text', 'Flavor text')
    end

    it 'handles separator line retrieval', :aggregate_failures do
      text_box_lines = MtgCardMaker::TextBoxLines.new(x: 10, y: 10, width: 200, height: 100)

      # Set a separator line
      text_box_lines.set_line(4, type: :separator)

      separator = text_box_lines.separator_line

      expect(separator).not_to be_nil
      expect(separator[:type]).to eq(:separator)
      expect(separator[:y_pos]).to be > 0
    end

    it 'handles case where no separator exists', :aggregate_failures do
      text_box_lines = MtgCardMaker::TextBoxLines.new(x: 10, y: 10, width: 200, height: 100)

      separator = text_box_lines.separator_line

      expect(separator).to be_nil
    end
  end

  describe 'with Gold color scheme' do
    let(:gold_color_scheme) { MtgCardMaker::ColorScheme.new(:gold) }
    let(:layer) do
      described_class.new(
        dimensions: { x: 10, y: 10, width: 100, height: 100 },
        rules_text: rules_text,
        flavor_text: flavor_text,
        color_scheme: gold_color_scheme
      )
    end

    it 'renders metallic rules text for Gold color scheme', :aggregate_failures do
      template = MtgCardMaker::Template.new(width: 200, height: 200)
      template.add_layer(layer)
      svg_content = template.to_svg

      # Check that metallic gradients and patterns are used
      expect(svg_content).to include('gold_metallic_highlight_gradient')
      expect(svg_content).to include('gold_metallic_shadow_gradient')
      expect(svg_content).to include('gold_metallic_pattern')
    end

    it 'renders metallic rules text without flavor text', :aggregate_failures do
      layer_no_flavor = described_class.new(
        dimensions: { x: 10, y: 10, width: 100, height: 100 },
        rules_text: rules_text,
        color_scheme: gold_color_scheme
      )

      template = MtgCardMaker::Template.new(width: 200, height: 200)
      template.add_layer(layer_no_flavor)
      svg_content = template.to_svg

      # Check that metallic gradients are used
      expect(svg_content).to include('gold_metallic_highlight_gradient')
      expect(svg_content).to include('gold_metallic_shadow_gradient')
      expect(svg_content).to include('gold_metallic_pattern')

      # Check that rules text is rendered
      expect_svg_to_have_text(template, 'Deal 3')
      expect_svg_to_have_text(template, 'damage')
      expect_svg_to_have_text(template, 'to any')
      expect_svg_to_have_text(template, 'target.')

      # Check that there are no flavor text lines (should be 0)
      line_count = svg_content.scan(%r{<text[^>]*>.*?</text>}m).count
      expect(line_count).to eq(4) # Only rules text lines, no flavor text
    end

    it 'renders metallic rules text with empty rules text' do
      layer = described_class.new(
        dimensions: { x: 10, y: 10, width: 100, height: 100 },
        rules_text: '',
        color_scheme: gold_color_scheme
      )

      # Should still render metallic structure even with empty rules text
      expect_svg_to_contain(layer, 'gold_metallic_highlight_gradient')
      expect_svg_to_contain(layer, 'gold_metallic_pattern')
      expect_svg_to_contain(layer, 'gold_metallic_shadow_gradient')
      expect_svg_to_have_elements(layer, 'g')
    end
  end
end
