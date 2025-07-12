# frozen_string_literal: true

# More info at https://github.com/guard/guard#readme

guard :rubocop, cli: '--format progress --out tmp/rubocop_status.txt ',
                all_on_start: true, all_after_pass: true do
  watch(/.+\.rb$/)
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end

guard :rspec, cmd: 'bundle exec rspec --format progress --out tmp/rspec_status.txt --format progress 2> /dev/null',
              all_on_start: true, all_after_pass: true do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Watch lib files and run corresponding specs
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/mtg_card_maker/(?<filename>.+)\.rb$}) { |m| "spec/mtg_card_maker/#{m[:filename]}_spec.rb" }
  watch(%r{^lib/mtg_card_maker/layers/(?<filename>.+)\.rb$}) { |m| "spec/mtg_card_maker/#{m[:filename]}_spec.rb" }
end

# Single shell guard for card/sprite diff and summary
guard :shell, all_on_start: true do
  watch(/^(lib|spec|examples|bin).*$/) do
    `bin/status_summary`
  end
end
