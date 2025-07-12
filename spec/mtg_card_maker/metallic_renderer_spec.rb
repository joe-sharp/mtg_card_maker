# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/mtg_card_maker/metallic_renderer'

RSpec.describe MtgCardMaker::MetallicRenderer do
  # Dummy class to test the module
  let(:dummy_class) do
    Class.new do
      include MtgCardMaker::MetallicRenderer
    end
  end
  let(:dummy) { dummy_class.new }

  describe 'geometry helpers else branches' do
    it 'geometry_x returns 0 if param missing and no x method' do
      expect(dummy.send(:geometry_x, {})).to eq(0)
    end

    it 'geometry_y returns 0 if param missing and no y method' do
      expect(dummy.send(:geometry_y, {})).to eq(0)
    end

    it 'geometry_width returns 0 if param missing and no width method' do
      expect(dummy.send(:geometry_width, {})).to eq(0)
    end

    it 'geometry_height returns 0 if param missing and no height method' do
      expect(dummy.send(:geometry_height, {})).to eq(0)
    end
  end
end
