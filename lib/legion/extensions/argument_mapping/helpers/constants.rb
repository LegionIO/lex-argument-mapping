# frozen_string_literal: true

module Legion
  module Extensions
    module ArgumentMapping
      module Helpers
        module Constants
          ARGUMENT_STRENGTHS = {
            (0.8..)     => :compelling,
            (0.6...0.8) => :strong,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :weak,
            (..0.2)     => :fallacious
          }.freeze

          QUALIFIER_TYPES = %i[certainly presumably probably possibly apparently].freeze

          REBUTTAL_IMPACT_LABELS = {
            (0.8..)     => :devastating,
            (0.6...0.8) => :significant,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :minor,
            (..0.2)     => :negligible
          }.freeze

          MAX_ARGUMENTS = 200
          MAX_HISTORY   = 500

          DEFAULT_STRENGTH  = 0.5
          GROUND_WEIGHT     = 0.3
          WARRANT_WEIGHT    = 0.3
          BACKING_WEIGHT    = 0.2
          REBUTTAL_PENALTY  = 0.2

          DECAY_RATE = 0.02
        end
      end
    end
  end
end
