# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Confabulation
          module Helpers
            class Claim
              attr_reader :id, :content, :claim_type, :confidence, :evidence_strength,
                          :verified, :confabulated, :created_at

              def initialize(content:, claim_type:, confidence:, evidence_strength:)
                @id               = SecureRandom.uuid
                @content          = content
                @claim_type       = claim_type
                @confidence       = confidence.clamp(0.0, 1.0)
                @evidence_strength = evidence_strength.clamp(0.0, 1.0)
                @verified         = false
                @confabulated     = false
                @created_at       = Time.now.utc
              end

              def confabulation_risk
                (confidence - evidence_strength).clamp(0.0, 1.0)
              end

              def verify!
                @verified = true
                self
              end

              def mark_confabulated!
                @confabulated = true
                self
              end

              def risk_label
                Constants::RISK_LABELS.each do |range, label|
                  return label if range.cover?(confabulation_risk)
                end
                :extreme
              end

              def to_h
                {
                  id:                 id,
                  content:            content,
                  claim_type:         claim_type,
                  confidence:         confidence.round(10),
                  evidence_strength:  evidence_strength.round(10),
                  confabulation_risk: confabulation_risk.round(10),
                  risk_label:         risk_label,
                  verified:           verified,
                  confabulated:       confabulated,
                  created_at:         created_at.iso8601
                }
              end
            end
          end
        end
      end
    end
  end
end
