# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

# YARD documentation tasks
require 'yard'

YARD::Rake::YardocTask.new(:docs) do |t|
  t.files = ['lib/**/*.rb', 'bin/**/*']
  t.options = ['--readme', 'README.md']
end

task default: %i[spec rubocop]
