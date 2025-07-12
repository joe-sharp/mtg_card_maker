# frozen_string_literal: true

module MtgCardMaker
  # Mixin to provide common layer initialization patterns
  module LayerInitializer
    private

    def initialize_layer_color(color, color_scheme, default_method)
      color || color_scheme.send(default_method)
    end
  end
end
