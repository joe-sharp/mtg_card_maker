# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MtgCardMaker::CssService do
  describe '.css_classes' do
    it 'generates CSS classes for all card elements', :aggregate_failures do
      css = described_class.css_classes

      expect(css).to include('.card-name')
      expect(css).to include('.card-type')
      expect(css).to include('.card-rules-text')
      expect(css).to include('.card-flavor-text')
      expect(css).to include('.card-power-toughness')
      expect(css).to include('.card-copyright')
      expect(css).to include('.mana-cost-text')
    end

    it 'applies correct font styling to flavor text', :aggregate_failures do
      css = described_class.css_classes

      # Extract the flavor text CSS block
      flavor_css_match = css.match(/\.card-flavor-text\s*\{[^}]*\}/m)
      expect(flavor_css_match).not_to be_nil

      flavor_css = flavor_css_match[0]
      expect(flavor_css).to include('font-family: serif')
      expect(flavor_css).to include('font-style: italic')
    end

    it 'applies correct font styling to name and type elements', :aggregate_failures do
      css = described_class.css_classes

      # Extract the name/type CSS block
      name_type_css_match = css.match(/\.card-name,\s*\.card-type\s*\{[^}]*\}/m)
      expect(name_type_css_match).not_to be_nil

      name_type_css = name_type_css_match[0]
      expect(name_type_css).to include('font-family: serif')
      expect(name_type_css).to include('font-weight: bold') # Default when embed is false
    end

    it 'applies correct font styling to power/toughness', :aggregate_failures do
      css = described_class.css_classes

      # Extract the power/toughness CSS block
      power_css_match = css.match(/\.card-power-toughness\s*\{[^}]*\}/m)
      expect(power_css_match).not_to be_nil

      power_css = power_css_match[0]
      expect(power_css).to include('font-family: serif')
      expect(power_css).to include('font-weight: bold')
    end

    it 'applies correct font styling to rules text', :aggregate_failures do
      css = described_class.css_classes

      # Extract the rules text CSS block
      rules_css_match = css.match(/\.card-rules-text,\s*\.mana-cost-text\s*\{[^}]*\}/m)
      expect(rules_css_match).not_to be_nil

      rules_css = rules_css_match[0]
      expect(rules_css).to include('font-family: serif')
    end

    it 'applies correct font styling to copyright', :aggregate_failures do
      css = described_class.css_classes

      # Extract the copyright CSS block
      copyright_css_match = css.match(/\.card-copyright\s*\{[^}]*\}/m)
      expect(copyright_css_match).not_to be_nil

      copyright_css = copyright_css_match[0]
      expect(copyright_css).to include('font-family: sans-serif')
    end

    context 'with embedded fonts' do
      it 'uses embedded font family when embed is true', :aggregate_failures do
        css = described_class.css_classes(embed: true)

        name_type_css_match = css.match(/\.card-name,\s*\.card-type\s*\{[^}]*\}/m)
        expect(name_type_css_match).not_to be_nil

        name_type_css = name_type_css_match[0]
        expect(name_type_css).to include("font-family: 'Goudy Mediaeval DemiBold', serif")
        expect(name_type_css).to include('font-weight: normal')
      end

      it 'uses fallback font family when embed is false', :aggregate_failures do
        css = described_class.css_classes(embed: false)

        name_type_css_match = css.match(/\.card-name,\s*\.card-type\s*\{[^}]*\}/m)
        expect(name_type_css_match).not_to be_nil

        name_type_css = name_type_css_match[0]
        expect(name_type_css).to include('font-family: serif')
        expect(name_type_css).to include('font-weight: bold')
      end
    end
  end

  describe '.font_face' do
    it 'returns empty string when embed is false' do
      result = described_class.font_face(embed: false)
      expect(result).to eq('')
    end

    it 'generates font face declaration when embed is true', :aggregate_failures do
      result = described_class.font_face(embed: true)

      expect(result).to include('@font-face')
      expect(result).to include("font-family: 'Goudy Mediaeval DemiBold'")
      expect(result).to include('src: url(data:font/truetype')
      expect(result).to include('format(\'truetype\')')
    end

    it 'reads font data from correct file' do
      font_path = File.join(File.dirname(__FILE__), '../../lib/mtg_card_maker/fonts/goudy_base64.txt')
      expect(File.exist?(font_path)).to be true
    end
  end

  describe '.complete_styles' do
    it 'combines font face and CSS classes when embed is true', :aggregate_failures do
      result = described_class.complete_styles(embed: true)

      expect(result).to include('@font-face')
      expect(result).to include('.card-name')
      expect(result).to include('.card-flavor-text')
    end

    it 'includes only CSS classes when embed is false', :aggregate_failures do
      result = described_class.complete_styles(embed: false)

      expect(result).not_to include('@font-face')
      expect(result).to include('.card-name')
      expect(result).to include('.card-flavor-text')
    end
  end

  describe '.font_family' do
    it 'returns embedded font family when embed is true' do
      result = described_class.font_family(true)
      expect(result).to eq("'Goudy Mediaeval DemiBold', serif")
    end

    it 'returns fallback font family when embed is false' do
      result = described_class.font_family(false)
      expect(result).to eq('serif')
    end
  end

  describe '.font_weight' do
    it 'returns normal weight when embed is true' do
      result = described_class.font_weight(true)
      expect(result).to eq('normal')
    end

    it 'returns bold weight when embed is false' do
      result = described_class.font_weight(false)
      expect(result).to eq('bold')
    end
  end
end
