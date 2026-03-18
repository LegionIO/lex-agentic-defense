# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Phantom
          module Helpers
            class PhantomLimb
              ADAPT_DECAY_MULTIPLIER = 2.5

              attr_reader :id, :capability_name, :capability_domain, :removed_at,
                          :activation_count, :last_triggered, :trigger_history

              def initialize(capability_name:, capability_domain:)
                @id                 = SecureRandom.uuid
                @capability_name    = capability_name
                @capability_domain  = capability_domain
                @removed_at         = Time.now.utc
                @intensity          = Constants::INITIAL_INTENSITY
                @activation_count   = 0
                @last_triggered     = nil
                @trigger_history    = []
              end

              def intensity
                @intensity.round(10)
              end

              def state
                Constants.state_for(@intensity)
              end

              def trigger!(stimulus)
                return false if resolved?

                @activation_count += 1
                prev_triggered = @last_triggered
                @last_triggered = Time.now.utc
                signal = PhantomSignal.new(
                  phantom_limb_id:      @id,
                  stimulus:             stimulus,
                  trigger_type:         classify_trigger(stimulus, prev_triggered),
                  intensity_at_trigger: @intensity
                )
                @trigger_history << signal
                @trigger_history.shift while @trigger_history.size > 50
                boost = (@intensity * 0.05).clamp(0.0, 0.1)
                @intensity = (@intensity + boost).clamp(Constants::MIN_INTENSITY, 1.0)
                signal
              end

              def decay!
                return if resolved?

                @intensity = (@intensity - Constants::INTENSITY_DECAY).clamp(Constants::MIN_INTENSITY, 1.0)
              end

              def adapt!
                return if resolved?

                accelerated = Constants::INTENSITY_DECAY * ADAPT_DECAY_MULTIPLIER
                @intensity  = (@intensity - accelerated).clamp(Constants::MIN_INTENSITY, 1.0)
              end

              def resolved?
                @intensity <= Constants::MIN_INTENSITY
              end

              def to_h
                {
                  id:                @id,
                  capability_name:   @capability_name,
                  capability_domain: @capability_domain,
                  removed_at:        @removed_at,
                  intensity:         intensity,
                  activation_count:  @activation_count,
                  last_triggered:    @last_triggered,
                  state:             state,
                  resolved:          resolved?
                }
              end

              private

              def classify_trigger(stimulus, prev_triggered)
                return :stimulus_match if stimulus.is_a?(String) && stimulus.include?(@capability_name.to_s)

                return :temporal_pattern if prev_triggered && (Time.now.utc - prev_triggered) < 60

                return :habitual if @activation_count > 10

                :contextual_association
              end
            end
          end
        end
      end
    end
  end
end
