# frozen_string_literal: true

module MtgCardMaker
  # Deep merge functionality for nested configuration merging
  module DeepMerge
    def deep_merge(other_hash)
      merge(other_hash) do |_key, this_val, other_val|
        if this_val.is_a?(Hash) && other_val.is_a?(Hash)
          # Extend the inner hash with deep merge functionality
          this_val.dup.extend(DeepMerge).deep_merge(other_val)
        else
          other_val
        end
      end
    end

    def deep_merge!(other_hash)
      replace(deep_merge(other_hash))
    end
  end
end
