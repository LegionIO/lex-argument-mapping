# frozen_string_literal: true

module Legion
  module Extensions
    module ArgumentMapping
      module Helpers
        class Argument
          include Constants

          attr_reader :id, :claim, :grounds, :warrant, :backing,
                      :qualifier, :rebuttals, :created_at, :domain

          def initialize(id:, claim:, domain: :general, warrant: nil, qualifier: :presumably)
            @id         = id
            @claim      = claim
            @domain     = domain
            @warrant    = warrant
            @qualifier  = qualifier
            @grounds    = []
            @backing    = []
            @rebuttals  = []
            @created_at = Time.now.utc
          end

          def add_ground(ground:)
            @grounds << ground
          end

          def add_backing(backing:)
            @backing << backing
          end

          def add_rebuttal(content:, impact: 0.5)
            @rebuttals << { content: content, impact: impact.clamp(0.0, 1.0) }
          end

          def strength
            raw = (ground_score * GROUND_WEIGHT) +
                  (warrant_score * WARRANT_WEIGHT) +
                  (backing_score * BACKING_WEIGHT) -
                  (rebuttal_score * REBUTTAL_PENALTY)
            raw.clamp(0.0, 1.0)
          end

          def strength_label
            ARGUMENT_STRENGTHS.find { |range, _| range.cover?(strength) }&.last
          end

          def sound?
            strength >= 0.6 && !@warrant.nil? && !@grounds.empty?
          end

          def rebutted?
            @rebuttals.any? { |r| r[:impact] > 0.5 }
          end

          def to_h
            {
              id:             @id,
              claim:          @claim,
              domain:         @domain,
              grounds:        @grounds,
              warrant:        @warrant,
              backing:        @backing,
              qualifier:      @qualifier,
              rebuttals:      @rebuttals,
              strength:       strength,
              strength_label: strength_label,
              sound:          sound?,
              rebutted:       rebutted?,
              created_at:     @created_at
            }
          end

          private

          def ground_score
            [@grounds.size / 3.0, 1.0].min
          end

          def warrant_score
            @warrant.nil? ? 0.0 : 0.8
          end

          def backing_score
            [@backing.size / 2.0, 1.0].min
          end

          def rebuttal_score
            return 0.0 if @rebuttals.empty?

            @rebuttals.sum { |r| r[:impact] } / @rebuttals.size
          end
        end
      end
    end
  end
end
