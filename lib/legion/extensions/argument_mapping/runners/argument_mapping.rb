# frozen_string_literal: true

module Legion
  module Extensions
    module ArgumentMapping
      module Runners
        module ArgumentMapping
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def create_argument(claim:, domain: :general, warrant: nil, qualifier: :presumably, **)
            Legion::Logging.info "[argument_mapping] create_argument: claim=#{claim} domain=#{domain}"
            engine.create_argument(claim: claim, domain: domain, warrant: warrant, qualifier: qualifier)
          end

          def add_argument_ground(argument_id:, ground:, **)
            Legion::Logging.debug "[argument_mapping] add_ground: id=#{argument_id}"
            engine.add_ground(argument_id: argument_id, ground: ground)
          end

          def add_argument_backing(argument_id:, backing:, **)
            Legion::Logging.debug "[argument_mapping] add_backing: id=#{argument_id}"
            engine.add_backing(argument_id: argument_id, backing: backing)
          end

          def add_argument_rebuttal(argument_id:, content:, impact: 0.5, **)
            Legion::Logging.info "[argument_mapping] add_rebuttal: id=#{argument_id} impact=#{impact}"
            engine.add_rebuttal(argument_id: argument_id, content: content, impact: impact)
          end

          def assess_argument_strength(argument_id:, **)
            Legion::Logging.debug "[argument_mapping] assess: id=#{argument_id}"
            engine.assess_argument(argument_id: argument_id)
          end

          def sound_arguments_report(**)
            Legion::Logging.debug '[argument_mapping] sound_arguments_report'
            arguments = engine.sound_arguments
            { success: true, arguments: arguments.map(&:to_h), count: arguments.size }
          end

          def rebutted_arguments_report(**)
            Legion::Logging.debug '[argument_mapping] rebutted_arguments_report'
            arguments = engine.rebutted_arguments
            { success: true, arguments: arguments.map(&:to_h), count: arguments.size }
          end

          def strongest_arguments_report(limit: 5, **)
            Legion::Logging.debug "[argument_mapping] strongest_arguments: limit=#{limit}"
            arguments = engine.strongest_arguments(limit: limit)
            { success: true, arguments: arguments.map(&:to_h), count: arguments.size }
          end

          def update_argument_mapping(**)
            Legion::Logging.debug '[argument_mapping] decay_all'
            decayed = engine.decay_all
            { success: true, arguments_processed: decayed }
          end

          def argument_mapping_stats(**)
            Legion::Logging.debug '[argument_mapping] stats'
            { success: true }.merge(engine.to_h)
          end

          private

          def engine
            @engine ||= Helpers::ArgumentEngine.new
          end
        end
      end
    end
  end
end
