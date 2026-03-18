# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Phantom
          module Helpers
            class PhantomSignal
              attr_reader :id, :phantom_limb_id, :stimulus, :trigger_type,
                          :intensity_at_trigger, :timestamp

              def initialize(phantom_limb_id:, stimulus:, trigger_type:, intensity_at_trigger:)
                @id                  = SecureRandom.uuid
                @phantom_limb_id     = phantom_limb_id
                @stimulus            = stimulus
                @trigger_type        = trigger_type
                @intensity_at_trigger = intensity_at_trigger.clamp(0.0, 1.0)
                @timestamp = Time.now.utc
              end

              def to_h
                {
                  id:                   @id,
                  phantom_limb_id:      @phantom_limb_id,
                  stimulus:             @stimulus,
                  trigger_type:         @trigger_type,
                  intensity_at_trigger: @intensity_at_trigger.round(10),
                  timestamp:            @timestamp
                }
              end
            end
          end
        end
      end
    end
  end
end
