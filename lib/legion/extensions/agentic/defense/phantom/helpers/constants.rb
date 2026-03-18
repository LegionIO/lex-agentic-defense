# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module Phantom
          module Helpers
            module Constants
              MAX_PHANTOMS = 100
              INITIAL_INTENSITY = 0.8
              INTENSITY_DECAY   = 0.05
              MIN_INTENSITY     = 0.01

              PHANTOM_STATES = %i[acute adapting residual resolved].freeze
              TRIGGER_TYPES  = %i[stimulus_match contextual_association temporal_pattern habitual].freeze

              STATE_THRESHOLDS = {
                acute:    0.6,
                adapting: 0.3,
                residual: MIN_INTENSITY
              }.freeze

              PHANTOM_LABELS = {
                acute:    'Active phantom — strong ghost signals firing',
                adapting: 'Adapting — agent learning to cope with absence',
                residual: 'Residual — faint ghost signals, near resolution',
                resolved: 'Resolved — phantom fully integrated and silent'
              }.freeze

              module_function

              def label_for(state)
                PHANTOM_LABELS.fetch(state, 'Unknown state')
              end

              def state_for(intensity)
                if intensity >= STATE_THRESHOLDS[:acute]
                  :acute
                elsif intensity >= STATE_THRESHOLDS[:adapting]
                  :adapting
                elsif intensity > MIN_INTENSITY
                  :residual
                else
                  :resolved
                end
              end
            end
          end
        end
      end
    end
  end
end
