# frozen_string_literal: true

require 'tempfile'
require 'fileutils'

# Simple canvas class for managing dimensions
class TestCanvas
  attr_reader :width, :height

  def initialize(width: MtgCardMaker::CARD_WIDTH, height: MtgCardMaker::CARD_HEIGHT)
    @width = width
    @height = height
  end
end

module SVGFixtureHelper
  # Default canvas for most tests
  def default_canvas
    @default_canvas ||= TestCanvas.new
  end

  # Create a custom canvas for specific tests
  def custom_canvas(width:, height:)
    TestCanvas.new(width: width, height: height)
  end

  # Generate an SVG for a given layer and return the SVG content
  def generate_svg_for_layer(layer, canvas_width: nil, canvas_height: nil, embed_font: false)
    canvas = if canvas_width && canvas_height
               custom_canvas(width: canvas_width, height: canvas_height)
             else
               default_canvas
             end

    template = MtgCardMaker::Template.new(width: canvas.width, height: canvas.height, embed_font: embed_font)
    template.add_layer(layer)

    capture_svg_output(template)
  end

  # Load expected SVG content from fixtures
  def load_fixture_svg(fixture_name)
    fixture_path = File.join(File.dirname(__FILE__), '..', 'fixtures', "#{fixture_name}.svg")
    raise "Fixture not found: #{fixture_path}" unless File.exist?(fixture_path)

    File.read(fixture_path)
  end

  # Normalize SVG content for comparison (remove whitespace differences)
  def normalize_svg(svg_content)
    svg_content.gsub(/\s+/, ' ').strip
  end

  # Get SVG content from various input types
  def get_svg_content(layer_or_template_or_path) # rubocop:disable Metrics/MethodLength
    case layer_or_template_or_path
    when String
      if layer_or_template_or_path.include?('<svg') || layer_or_template_or_path.include?('<?xml')
        layer_or_template_or_path
      else
        get_svg_from_file_path(layer_or_template_or_path)
      end
    when MtgCardMaker::Template
      get_svg_from_template(layer_or_template_or_path)
    when ->(obj) { obj.respond_to?(:save) && !obj.respond_to?(:render) }
      get_svg_from_card_object(layer_or_template_or_path)
    else
      get_svg_from_layer(layer_or_template_or_path)
    end
  end

  # Generate a complete card template for integration testing
  def generate_complete_card_svg(layers = {}, embed_font: false)
    canvas = default_canvas
    template = MtgCardMaker::Template.new(width: canvas.width, height: canvas.height, embed_font: embed_font)

    add_default_layers(template, canvas) if layers.empty?
    layers.each_value { |layer| template.add_layer(layer) }

    capture_svg_output(template)
  end

  private

  def capture_svg_output(template)
    Tempfile.create(['test_svg', '.svg']) do |temp_file|
      template.save(temp_file.path)
      File.read(temp_file.path)
    end
  end

  def add_default_layers(template, canvas)
    template.add_layer(MtgCardMaker::BorderLayer.new(
                         dimensions: { x: 0, y: 0, width: canvas.width, height: canvas.height }
                       ))
    template.add_layer(MtgCardMaker::FrameLayer.new(
                         dimensions: { x: 30, y: 30, width: canvas.width - 60, height: canvas.height - 60 }
                       ))
  end

  def get_svg_from_file_path(file_path)
    File.read(file_path)
  end

  def get_svg_from_template(template)
    template.to_svg
  end

  def get_svg_from_card_object(card_object)
    Tempfile.create(['card', '.svg']) do |file|
      card_object.save(file.path)
      File.read(file.path)
    end
  end

  def get_svg_from_layer(layer)
    generate_svg_for_layer(layer)
  end
end

module SVGFixtureExpectations
  include SVGFixtureHelper

  def expect_svg_to_contain(layer_or_template_or_path, expected_content)
    svg_content = get_svg_content(layer_or_template_or_path)
    expect(svg_content).to include(expected_content)
  end

  def expect_svg_to_have_elements(layer_or_template_or_path, *element_names)
    svg_content = get_svg_content(layer_or_template_or_path)
    element_names.each do |element_name|
      expect(svg_content).to include("<#{element_name}"), "Expected SVG to contain <#{element_name}> element"
    end
  end

  def expect_svg_to_have_text(layer_or_template_or_path, expected_text)
    svg_content = get_svg_content(layer_or_template_or_path)
    expect(svg_content).to include(expected_text)
  end

  def expect_svg_to_have_attributes(layer_or_template_or_path, expected_attributes)
    svg_content = get_svg_content(layer_or_template_or_path)
    expected_attributes.each do |attribute, value|
      expect(svg_content).to include("#{attribute}=\"#{value}\"")
    end
  end

  def expect_svg_to_match_fixture(layer, fixture_name)
    generated_svg = generate_svg_for_layer(layer)
    expected_svg = load_fixture_svg(fixture_name)
    expect(normalize_svg(generated_svg)).to eq(normalize_svg(expected_svg))
  end

  def expect_svg_generation_to_succeed(layer)
    expect { generate_svg_for_layer(layer) }.not_to raise_error
  end
end
