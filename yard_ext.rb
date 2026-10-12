# frozen_string_literal: true

# Strips README badges (GitHub-only) from the content YARD renders, so they
# never appear in or cause changes to the generated docs.
BADGES = /<!-- badges:start -->.*?<!-- badges:end -->\n?/m

YARD::CodeObjects::ExtraFileObject.prepend(Module.new do
  def contents
    super.to_s.gsub(BADGES, '')
  end
end)
