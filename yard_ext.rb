# frozen_string_literal: true

# Strips README badges (GitHub-only) from the content YARD renders, so they
# never appear in or cause changes to the generated docs.
module YardReadmeBadgeStripper
  def contents
    super.to_s.gsub(/<!-- badges:start -->.*?<!-- badges:end -->\n?/m, "")
  end
end

# .yardopts may load this file more than once; only prepend once.
unless YARD::CodeObjects::ExtraFileObject <= YardReadmeBadgeStripper
  YARD::CodeObjects::ExtraFileObject.prepend(YardReadmeBadgeStripper)
end
