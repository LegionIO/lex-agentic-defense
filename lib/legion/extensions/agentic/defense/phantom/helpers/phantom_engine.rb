# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module Phantom
          module Helpers
            class PhantomEngine
              def initialize
                @phantoms = {}
              end

              def register_removal(capability_name:, capability_domain: :general)
                if @phantoms.size >= Constants::MAX_PHANTOMS
                  Legion::Logging.warn "[cognitive_phantom] MAX_PHANTOMS (#{Constants::MAX_PHANTOMS}) reached, skipping #{capability_name}"
                  return nil
                end

                limb = PhantomLimb.new(capability_name: capability_name, capability_domain: capability_domain)
                @phantoms[limb.id] = limb
                Legion::Logging.info "[cognitive_phantom] registered phantom: capability=#{capability_name} domain=#{capability_domain} id=#{limb.id[0..7]}"
                limb
              end

              def process_stimulus(stimulus:, domain: :general)
                fired = []
                @phantoms.each_value do |limb|
                  next if limb.resolved?
                  next unless domain_match?(limb, domain)

                  signal = limb.trigger!(stimulus)
                  next unless signal

                  fired << signal
                  intensity_str = limb.intensity.round(3).to_s
                  Legion::Logging.debug "[cognitive_phantom] phantom fired: cap=#{limb.capability_name} trigger=#{signal.trigger_type} i=#{intensity_str}"
                end
                fired
              end

              def decay_all!
                @phantoms.each_value(&:decay!)
                resolve_check!
              end

              def acknowledge(phantom_id:)
                limb = @phantoms[phantom_id]
                return { acknowledged: false, reason: :not_found } unless limb

                limb.adapt!
                Legion::Logging.info "[cognitive_phantom] acknowledged phantom id=#{phantom_id[0..7]} intensity=#{limb.intensity.round(3)} state=#{limb.state}"
                { acknowledged: true, phantom_id: phantom_id, state: limb.state, intensity: limb.intensity }
              end

              def all_phantoms
                @phantoms.values
              end

              def active_phantoms
                @phantoms.values.reject(&:resolved?)
              end

              def phantom_activity_report
                all = @phantoms.values
                by_state = Constants::PHANTOM_STATES.to_h { |s| [s, all.count { |p| p.state == s }] }
                {
                  total:             all.size,
                  active:            active_phantoms.size,
                  by_state:          by_state,
                  total_activations: all.sum(&:activation_count)
                }
              end

              def most_persistent(limit: 5)
                active_phantoms.sort_by(&:activation_count).last(limit).reverse
              end

              def recently_triggered(limit: 5)
                active_phantoms
                  .select(&:last_triggered)
                  .sort_by(&:last_triggered)
                  .last(limit)
                  .reverse
              end

              def resolve_check!
                newly_resolved = @phantoms.values.select(&:resolved?)
                newly_resolved.each do |limb|
                  Legion::Logging.info "[cognitive_phantom] resolved: capability=#{limb.capability_name} activations=#{limb.activation_count}"
                end
                newly_resolved.size
              end

              private

              def domain_match?(limb, domain)
                domain == :any || limb.capability_domain == domain || limb.capability_domain == :general
              end
            end
          end
        end
      end
    end
  end
end
