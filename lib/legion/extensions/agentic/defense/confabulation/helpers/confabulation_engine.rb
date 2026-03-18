# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module Confabulation
          module Helpers
            class ConfabulationEngine
              attr_reader :claims

              def initialize
                @claims = {}
              end

              def register_claim(content:, claim_type: :factual, confidence: 0.5, evidence_strength: 0.5)
                claim_type = claim_type.to_sym
                claim_type = :factual unless Constants::CLAIM_TYPES.include?(claim_type)

                claim = Claim.new(
                  content:           content,
                  claim_type:        claim_type,
                  confidence:        confidence,
                  evidence_strength: evidence_strength
                )
                prune_if_needed
                @claims[claim.id] = claim
                claim
              end

              def verify_claim(claim_id:)
                claim = @claims[claim_id]
                return { found: false, claim_id: claim_id } unless claim

                claim.verify!
                { found: true, claim_id: claim_id, verified: true }
              end

              def flag_confabulation(claim_id:)
                claim = @claims[claim_id]
                return { found: false, claim_id: claim_id } unless claim

                claim.mark_confabulated!
                { found: true, claim_id: claim_id, confabulated: true }
              end

              def high_risk_claims
                @claims.values.select { |c| c.confabulation_risk >= Constants::CONFABULATION_THRESHOLD }
              end

              def verified_claims
                @claims.values.select(&:verified)
              end

              def confabulation_rate
                total = @claims.size
                return 0.0 if total.zero?

                flagged = @claims.values.count(&:confabulated)
                (flagged.to_f / total).round(10)
              end

              def average_calibration
                return 0.0 if @claims.empty?

                total_gap = @claims.values.sum { |c| (c.confidence - c.evidence_strength).abs }
                gap = total_gap / @claims.size.to_f
                (1.0 - gap).clamp(0.0, 1.0).round(10)
              end

              def confabulation_report
                total          = @claims.size
                high_risk      = high_risk_claims.size
                verified       = verified_claims.size
                confabulated   = @claims.values.count(&:confabulated)
                overall_risk   = total.zero? ? 0.0 : high_risk.to_f / total
                risk_label     = risk_label_for(overall_risk)

                {
                  total_claims:        total,
                  high_risk_claims:    high_risk,
                  verified_claims:     verified,
                  confabulated_claims: confabulated,
                  confabulation_rate:  confabulation_rate,
                  average_calibration: average_calibration,
                  overall_risk:        overall_risk.round(10),
                  risk_label:          risk_label
                }
              end

              def prune_if_needed
                return unless @claims.size >= Constants::MAX_CLAIMS

                oldest_key = @claims.min_by { |_, c| c.created_at }&.first
                @claims.delete(oldest_key)
              end

              def to_h
                {
                  claim_count:         @claims.size,
                  confabulation_rate:  confabulation_rate,
                  average_calibration: average_calibration
                }
              end

              private

              def risk_label_for(value)
                Constants::RISK_LABELS.each do |range, label|
                  return label if range.cover?(value)
                end
                :extreme
              end
            end
          end
        end
      end
    end
  end
end
