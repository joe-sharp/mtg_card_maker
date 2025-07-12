# frozen_string_literal: true

require 'nokogiri'

module MtgCardMaker
  # Handles the core construction of sprite sheets from individual card files
  class SpriteSheetBuilder
    attr_reader :cards_per_row, :spacing

    def initialize(cards_per_row: 5, spacing: 30)
      @cards_per_row = cards_per_row
      @spacing = spacing
    end

    # Calculate sprite sheet dimensions
    def sprite_dimensions(card_count)
      return [0, 0] if card_count.zero?

      cols = [card_count, @cards_per_row].min
      rows = (card_count.to_f / @cards_per_row).ceil

      width = (cols * CARD_WIDTH) + ((cols - 1) * @spacing)
      height = (rows * CARD_HEIGHT) + ((rows - 1) * @spacing)

      [width, height]
    end

    # Create the sprite sheet XML builder with assets and cards
    def create_sprite_builder(width, height, card_files, assets)
      Nokogiri::XML::Builder.new do |xml|
        xml.svg(xmlns: 'http://www.w3.org/2000/svg',
                viewBox: "0 0 #{width} #{height}",
                width: width,
                height: height) do
          assets.add_assets_to_sprite(xml)
          add_cards_to_sprite(xml, card_files)
        end
      end
    end

    # Write the sprite sheet to file
    def write_sprite_file(output_file, builder)
      File.write(output_file, builder.to_xml)
    end

    private

    def add_cards_to_sprite(xml, card_files)
      card_files.each_with_index do |file, index|
        add_card_to_sprite(xml, file, index)
      end
    end

    def add_card_to_sprite(xml, card_file, index)
      position = calculate_card_position(index)
      doc = load_card_document(card_file)
      svg_element = doc.at_css('svg')

      return unless svg_element

      xml.g(transform: "translate(#{position[:x]}, #{position[:y]})") do
        add_card_children(xml, svg_element)
      end
    end

    def calculate_card_position(index)
      row = index / @cards_per_row
      col = index % @cards_per_row

      {
        x: col * (CARD_WIDTH + @spacing),
        y: row * (CARD_HEIGHT + @spacing)
      }
    end

    def load_card_document(card_file)
      Nokogiri::XML(File.read(card_file.path))
    end

    def add_card_children(xml, svg_element)
      excluded_elements = ['defs', 'style']
      svg_element.children.each do |child|
        next if excluded_elements.include?(child.name)
        next if child.name&.start_with?('linearGradient', 'radialGradient', 'pattern')

        xml.parent.add_child(child.dup)
      end
    end
  end
end
