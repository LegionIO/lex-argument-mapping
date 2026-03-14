# frozen_string_literal: true

module Legion
  module Extensions
    module ArgumentMapping
      module Helpers
        class ArgumentEngine
          include Constants

          attr_reader :arguments, :history

          def initialize
            @arguments = {}
            @history   = []
          end

          def create_argument(claim:, domain: :general, warrant: nil, qualifier: :presumably)
            return { success: false, reason: :max_arguments_reached } if @arguments.size >= MAX_ARGUMENTS

            id       = generate_id('arg')
            argument = Argument.new(id: id, claim: claim, domain: domain,
                                    warrant: warrant, qualifier: qualifier)
            @arguments[id] = argument
            add_history(type: :created, argument_id: id, claim: claim, domain: domain)
            { success: true, argument: argument.to_h }
          end

          def add_ground(argument_id:, ground:)
            argument = @arguments[argument_id]
            return { success: false, reason: :not_found } unless argument

            argument.add_ground(ground: ground)
            add_history(type: :ground_added, argument_id: argument_id)
            { success: true, argument: argument.to_h }
          end

          def add_backing(argument_id:, backing:)
            argument = @arguments[argument_id]
            return { success: false, reason: :not_found } unless argument

            argument.add_backing(backing: backing)
            add_history(type: :backing_added, argument_id: argument_id)
            { success: true, argument: argument.to_h }
          end

          def add_rebuttal(argument_id:, content:, impact: 0.5)
            argument = @arguments[argument_id]
            return { success: false, reason: :not_found } unless argument

            argument.add_rebuttal(content: content, impact: impact)
            add_history(type: :rebuttal_added, argument_id: argument_id, impact: impact)
            { success: true, argument: argument.to_h }
          end

          def assess_argument(argument_id:)
            argument = @arguments[argument_id]
            return { success: false, reason: :not_found } unless argument

            {
              success:        true,
              argument_id:    argument_id,
              claim:          argument.claim,
              domain:         argument.domain,
              strength:       argument.strength,
              strength_label: argument.strength_label,
              sound:          argument.sound?,
              rebutted:       argument.rebutted?,
              ground_count:   argument.grounds.size,
              backing_count:  argument.backing.size,
              rebuttal_count: argument.rebuttals.size
            }
          end

          def sound_arguments
            @arguments.values.select(&:sound?)
          end

          def rebutted_arguments
            @arguments.values.select(&:rebutted?)
          end

          def arguments_by_domain(domain:)
            @arguments.values.select { |a| a.domain == domain }
          end

          def strongest_arguments(limit: 5)
            @arguments.values.sort_by { |a| -a.strength }.first(limit)
          end

          def weakest_arguments(limit: 5)
            @arguments.values.sort_by(&:strength).first(limit)
          end

          def decay_all
            @arguments.each_value do |argument|
              next unless argument.instance_variable_defined?(:@base_strength)

              current = argument.instance_variable_get(:@base_strength)
              argument.instance_variable_set(:@base_strength, [current - DECAY_RATE, 0.0].max)
            end
            @arguments.size
          end

          def to_h
            {
              total_arguments:    @arguments.size,
              sound_arguments:    sound_arguments.size,
              rebutted_arguments: rebutted_arguments.size,
              history_entries:    @history.size
            }
          end

          private

          def add_history(entry)
            @history << entry.merge(timestamp: Time.now.utc)
            @history.shift if @history.size > MAX_HISTORY
          end

          def generate_id(prefix)
            "#{prefix}_#{Time.now.utc.to_f}_#{rand(10_000)}"
          end
        end
      end
    end
  end
end
