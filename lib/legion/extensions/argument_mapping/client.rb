# frozen_string_literal: true

require_relative 'runners/argument_mapping'

module Legion
  module Extensions
    module ArgumentMapping
      class Client
        include Runners::ArgumentMapping

        def initialize(**); end
      end
    end
  end
end
