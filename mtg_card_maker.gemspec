# frozen_string_literal: true

require_relative 'lib/mtg_card_maker/version'

Gem::Specification.new do |spec|
  spec.name = 'mtg_card_maker'
  spec.version = MtgCardMaker::VERSION
  spec.authors = ['joe-sharp']
  spec.email = ['joesharp13@gmail.com']

  spec.summary = 'MTG Card Maker is a tool for creating fan-made MTG cards'
  spec.description = 'MTG Card Maker is a tool for creating fan-made MTG cards. ' \
                     'MTG Card Maker is unofficial Fan Content permitted under the Fan Content Policy. ' \
                     'Not approved/endorsed by Wizards. Portions of the materials used are property of ' \
                     'Wizards of the Coast. ©Wizards of the Coast LLC.'
  spec.homepage = 'https://github.com/joe-sharp/mtg_card_maker'
  spec.license = 'CC-BY-NC-ND-4.0'
  spec.metadata['license'] = 'CC-BY-NC-ND-4.0'
  spec.required_ruby_version = '>= 3.2.8'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).select do |f|
      f.start_with?(*%w[
                      lib/
                      sig/
                      bin/mtg_card_maker
                      CHANGELOG.md
                      CODE_OF_CONDUCT.md
                      README.md
                      LICENSE.txt
                    ])
    end
  end
  spec.bindir = 'bin'
  spec.executables = ['mtg_card_maker']
  spec.require_paths = ['lib']

  spec.add_dependency 'addressable', '~> 2.8'
  spec.add_dependency 'nokogiri', '~> 1.15'
  spec.add_dependency 'thor', '~> 1.3'
  spec.add_dependency 'victor', '~> 0.5.0'
end
