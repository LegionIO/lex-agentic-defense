# frozen_string_literal: true

require_relative 'lib/legion/extensions/agentic/defense/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-agentic-defense'
  spec.version       = Legion::Extensions::Agentic::Defense::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Agentic Defense'
  spec.description   = 'LEX agentic defense domain: threat detection, stress response, boundaries'
  spec.homepage      = 'https://github.com/LegionIO/lex-agentic-defense'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = spec.homepage
  spec.metadata['changelog_uri']     = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    Dir.glob('{lib,spec}/**/*.rb') + %w[lex-agentic-defense.gemspec Gemfile LICENSE README.md CHANGELOG.md]
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'legion-cache',     '>= 1.3.11'
  spec.add_dependency 'legion-crypt',     '>= 1.4.9'
  spec.add_dependency 'legion-data',      '>= 1.4.17'
  spec.add_dependency 'legion-json',      '>= 1.2.1'
  spec.add_dependency 'legion-logging',   '>= 1.3.2'
  spec.add_dependency 'legion-settings',  '>= 1.3.14'
  spec.add_dependency 'legion-transport', '>= 1.3.9'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.75'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.26'
end
