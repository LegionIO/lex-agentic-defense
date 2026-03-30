# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module Confabulation
          module Runners
            module Confabulation
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def register_claim(content:, claim_type: :factual, confidence: 0.5, evidence_strength: 0.5, **)
                claim = confabulation_engine.register_claim(
                  content:           content,
                  claim_type:        claim_type,
                  confidence:        confidence,
                  evidence_strength: evidence_strength
                )
                log.debug("[confabulation] register: id=#{claim.id} type=#{claim.claim_type} " \
                          "risk=#{claim.confabulation_risk.round(2)} label=#{claim.risk_label}")
                claim.to_h
              end

              def verify_claim(claim_id:, **)
                result = confabulation_engine.verify_claim(claim_id: claim_id)
                if result[:found]
                  log.info("[confabulation] verified: claim_id=#{claim_id}")
                else
                  log.debug("[confabulation] verify: claim_id=#{claim_id} not found")
                end
                result
              end

              def flag_confabulation(claim_id:, **)
                result = confabulation_engine.flag_confabulation(claim_id: claim_id)
                if result[:found]
                  log.warn("[confabulation] flagged: claim_id=#{claim_id} marked as confabulated")
                else
                  log.debug("[confabulation] flag: claim_id=#{claim_id} not found")
                end
                result
              end

              def confabulation_report(**)
                report = confabulation_engine.confabulation_report
                log.debug("[confabulation] report: total=#{report[:total_claims]} " \
                          "high_risk=#{report[:high_risk_claims]} " \
                          "rate=#{report[:confabulation_rate].round(2)} label=#{report[:risk_label]}")
                report
              end

              def high_risk_claims(**)
                claims = confabulation_engine.high_risk_claims
                log.debug("[confabulation] high_risk_claims: count=#{claims.size}")
                { claims: claims.map(&:to_h), count: claims.size }
              end

              def confabulation_status(**)
                { engine: confabulation_engine.to_h }
              end

              private

              def confabulation_engine
                @confabulation_engine ||= Helpers::ConfabulationEngine.new
              end
            end
          end
        end
      end
    end
  end
end
