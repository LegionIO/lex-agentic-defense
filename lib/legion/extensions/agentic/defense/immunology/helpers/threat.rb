# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Immunology
          module Helpers
            class Threat
              attr_reader :id, :source, :tactic, :content_hash, :created_at
              attr_accessor :threat_level, :quarantined, :exposure_count

              def initialize(source:, tactic:, content_hash:, threat_level: 0.5)
                @id             = SecureRandom.uuid
                @source         = source
                @tactic         = tactic
                @content_hash   = content_hash
                @threat_level   = threat_level.clamp(0.0, 1.0)
                @quarantined    = false
                @exposure_count = 0
                @created_at     = Time.now.utc
              end

              def threat_label
                Constants::THREAT_LABELS.find { |range, _| range.cover?(@threat_level) }&.last || :negligible
              end

              def quarantine!
                @quarantined = true
              end

              def release!
                @quarantined = false
              end

              def expose!
                @exposure_count += 1
                reduction = (0.05 / (@exposure_count + 1)).round(10)
                @threat_level = (@threat_level - reduction).clamp(0.0, 1.0).round(10)
              end

              def escalate!(amount: 0.1)
                @threat_level = (@threat_level + amount).clamp(0.0, 1.0).round(10)
              end

              def to_h
                {
                  id:             @id,
                  source:         @source,
                  tactic:         @tactic,
                  content_hash:   @content_hash,
                  threat_level:   @threat_level,
                  threat_label:   threat_label,
                  quarantined:    @quarantined,
                  exposure_count: @exposure_count,
                  created_at:     @created_at
                }
              end
            end
          end
        end
      end
    end
  end
end
