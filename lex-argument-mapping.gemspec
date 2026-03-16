# frozen_string_literal: true

require_relative 'lib/legion/extensions/argument_mapping/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-argument-mapping'
  spec.version       = Legion::Extensions::ArgumentMapping::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LegionIO argument mapping extension'
  spec.description   = 'Toulmin-model argument mapping for LegionIO — ' \
                       'claim/grounds/warrant/backing/qualifier/rebuttal argument construction, ' \
                       'strength assessment, and soundness evaluation'
  spec.homepage      = 'https://github.com/LegionIO/lex-argument-mapping'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = 'https://github.com/LegionIO/lex-argument-mapping'
  spec.metadata['documentation_uri']     = 'https://github.com/LegionIO/lex-argument-mapping'
  spec.metadata['changelog_uri']         = 'https://github.com/LegionIO/lex-argument-mapping'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/LegionIO/lex-argument-mapping/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['lib/**/*']
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
