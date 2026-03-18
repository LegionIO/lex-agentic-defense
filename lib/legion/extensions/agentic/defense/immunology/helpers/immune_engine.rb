# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module Immunology
          module Helpers
            class ImmuneEngine
              attr_reader :resistance, :inflammatory

              def initialize
                @threats      = {}
                @antibodies   = {}
                @resistance   = Constants::DEFAULT_RESISTANCE
                @inflammatory = false
              end

              def detect_threat(source:, tactic:, content_hash:, threat_level: 0.5)
                return nil unless Constants::MANIPULATION_TACTICS.include?(tactic.to_sym)

                prune_threats_if_full

                threat = Threat.new(
                  source:       source,
                  tactic:       tactic,
                  content_hash: content_hash,
                  threat_level: threat_level
                )

                matched = match_antibodies_for_tactic(tactic)
                matched.each do |ab|
                  ab.match!
                  reduction = (ab.strength * 0.2).round(10)
                  threat.threat_level = (threat.threat_level - reduction).clamp(0.0, 1.0).round(10)
                end

                @threats[threat.id] = threat
                Legion::Logging.debug "[cognitive_immunology] threat detected: id=#{threat.id} tactic=#{tactic} level=#{threat.threat_level.round(2)}"
                threat
              end

              def quarantine_threat(threat_id:)
                threat = @threats.fetch(threat_id, nil)
                return { success: false, reason: 'not found' } unless threat

                threat.quarantine!
                Legion::Logging.info "[cognitive_immunology] quarantined: id=#{threat_id} tactic=#{threat.tactic}"
                { success: true, threat_id: threat_id }
              end

              def release_threat(threat_id:)
                threat = @threats.fetch(threat_id, nil)
                return { success: false, reason: 'not found' } unless threat

                threat.release!
                Legion::Logging.debug "[cognitive_immunology] released: id=#{threat_id}"
                { success: true, threat_id: threat_id }
              end

              def inoculate(threat_id:)
                threat = @threats.fetch(threat_id, nil)
                return { success: false, reason: 'not found' } unless threat

                threat.expose!
                boost = (Constants::RESISTANCE_BOOST / (threat.exposure_count + 1)).round(10)
                @resistance = (@resistance + boost).clamp(0.0, 1.0).round(10)
                Legion::Logging.debug "[cognitive_immunology] inoculate: id=#{threat_id} exposure=#{threat.exposure_count} resistance=#{@resistance.round(2)}"
                { success: true, threat_id: threat_id, exposure_count: threat.exposure_count, resistance: @resistance }
              end

              def create_antibody(tactic:, pattern:, strength: 0.5)
                return nil unless Constants::MANIPULATION_TACTICS.include?(tactic.to_sym)

                prune_antibodies_if_full

                ab = Antibody.new(tactic: tactic, pattern: pattern, strength: strength)
                @antibodies[ab.id] = ab
                Legion::Logging.info "[cognitive_immunology] antibody created: id=#{ab.id} tactic=#{tactic} strength=#{strength}"
                ab
              end

              def scan_for_tactic(tactic:)
                @threats.values.select { |t| t.tactic == tactic }
              end

              def trigger_inflammatory_response
                @inflammatory = true
                Legion::Logging.warn '[cognitive_immunology] inflammatory response triggered — heightened scrutiny mode'
                { inflammatory: true }
              end

              def resolve_inflammation
                @inflammatory = false
                Legion::Logging.info '[cognitive_immunology] inflammation resolved — returning to normal scrutiny'
                { inflammatory: false }
              end

              def overall_immunity
                ab_coverage = antibody_coverage_score
                score = ((@resistance * 0.6) + (ab_coverage * 0.4)).round(10)
                score.clamp(0.0, 1.0)
              end

              def immunity_label
                score = overall_immunity
                Constants::IMMUNITY_LABELS.find { |range, _| range.cover?(score) }&.last || :compromised
              end

              def vulnerability_report
                covered_tactics = @antibodies.values.map(&:tactic).uniq
                uncovered = Constants::MANIPULATION_TACTICS.reject { |t| covered_tactics.include?(t) }
                {
                  covered:   covered_tactics,
                  uncovered: uncovered,
                  coverage:  (covered_tactics.size.to_f / Constants::MANIPULATION_TACTICS.size).round(10)
                }
              end

              def threat_history(limit: 10)
                @threats.values
                        .sort_by(&:created_at)
                        .last(limit)
                        .map(&:to_h)
              end

              def decay_all
                @antibodies.each_value(&:decay!)
                @resistance = (@resistance - Constants::RESISTANCE_DECAY).clamp(0.0, 1.0).round(10)
                Legion::Logging.debug "[cognitive_immunology] decay cycle: resistance=#{@resistance.round(2)} antibodies=#{@antibodies.size}"
                { resistance: @resistance, antibodies_decayed: @antibodies.size }
              end

              def prune_ineffective
                before = @antibodies.size
                @antibodies.select! { |_, ab| ab.effective? }
                pruned = before - @antibodies.size
                Legion::Logging.debug "[cognitive_immunology] pruned #{pruned} ineffective antibodies"
                { pruned: pruned, remaining: @antibodies.size }
              end

              def to_h
                {
                  threat_count:             @threats.size,
                  quarantined_count:        @threats.values.count(&:quarantined),
                  antibody_count:           @antibodies.size,
                  effective_antibody_count: @antibodies.values.count(&:effective?),
                  resistance:               @resistance,
                  inflammatory:             @inflammatory,
                  overall_immunity:         overall_immunity,
                  immunity_label:           immunity_label
                }
              end

              private

              def match_antibodies_for_tactic(tactic)
                @antibodies.values.select { |ab| ab.tactic == tactic && ab.effective? }
              end

              def antibody_coverage_score
                return 0.0 if @antibodies.empty?

                effective = @antibodies.values.select(&:effective?)
                return 0.0 if effective.empty?

                avg_strength = effective.sum(&:strength) / effective.size.to_f
                tactic_coverage = vulnerability_report[:coverage]
                ((avg_strength * 0.5) + (tactic_coverage * 0.5)).round(10)
              end

              def prune_threats_if_full
                return unless @threats.size >= Constants::MAX_THREATS

                oldest = @threats.values.min_by(&:created_at)
                @threats.delete(oldest.id) if oldest
              end

              def prune_antibodies_if_full
                return unless @antibodies.size >= Constants::MAX_ANTIBODIES

                weakest = @antibodies.values.min_by(&:strength)
                @antibodies.delete(weakest.id) if weakest
              end
            end
          end
        end
      end
    end
  end
end
