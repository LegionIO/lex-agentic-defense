# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module Immunology
          module Runners
            module CognitiveImmunology
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def detect_threat(source:, tactic:, content_hash:, threat_level: 0.5, **)
                threat = engine.detect_threat(source: source, tactic: tactic, content_hash: content_hash, threat_level: threat_level)
                { success: true, threat: threat.to_h }
              end

              def quarantine_threat(threat_id:, **)
                result = engine.quarantine_threat(threat_id: threat_id)
                result.merge(success: result.fetch(:success, false))
              end

              def release_threat(threat_id:, **)
                result = engine.release_threat(threat_id: threat_id)
                result.merge(success: result.fetch(:success, false))
              end

              def inoculate(threat_id:, **)
                engine.inoculate(threat_id: threat_id)
              end

              def create_antibody(tactic:, pattern:, strength: 0.5, **)
                ab = engine.create_antibody(tactic: tactic, pattern: pattern, strength: strength)
                { success: true, antibody: ab.to_h }
              end

              def scan_for_tactic(tactic:, **)
                threats = engine.scan_for_tactic(tactic: tactic)
                { success: true, tactic: tactic, threats: threats.map(&:to_h), count: threats.size }
              end

              def trigger_inflammatory_response(**)
                result = engine.trigger_inflammatory_response
                { success: true }.merge(result)
              end

              def resolve_inflammation(**)
                result = engine.resolve_inflammation
                { success: true }.merge(result)
              end

              def overall_immunity(**)
                score = engine.overall_immunity
                { success: true, score: score, label: engine.immunity_label }
              end

              def vulnerability_report(**)
                report = engine.vulnerability_report
                { success: true }.merge(report)
              end

              def threat_history(limit: 10, **)
                threats = engine.threat_history(limit: limit)
                { success: true, threats: threats, count: threats.size }
              end

              def decay_all(**)
                result = engine.decay_all
                { success: true }.merge(result)
              end

              def prune_ineffective(**)
                result = engine.prune_ineffective
                { success: true }.merge(result)
              end

              def immune_status(**)
                { success: true }.merge(engine.to_h)
              end

              private

              def engine
                @engine ||= Helpers::ImmuneEngine.new
              end
            end
          end
        end
      end
    end
  end
end
