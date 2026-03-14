# frozen_string_literal: true

require_relative 'argument_mapping/version'
require_relative 'argument_mapping/helpers/constants'
require_relative 'argument_mapping/helpers/argument'
require_relative 'argument_mapping/helpers/argument_engine'
require_relative 'argument_mapping/runners/argument_mapping'
require_relative 'argument_mapping/client'

module Legion
  module Extensions
    module ArgumentMapping
      extend Legion::Extensions::Core if defined?(Legion::Extensions::Core)
    end
  end
end
