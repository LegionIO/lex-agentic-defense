# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module Phantom
          module Runners
            module CognitivePhantom
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def register_removal(capability_name:, capability_domain: :general, engine: nil, **)
                raise ArgumentError, 'capability_name is required' if capability_name.nil? || capability_name.to_s.strip.empty?

                eng  = engine || phantom_engine
                limb = eng.register_removal(capability_name: capability_name, capability_domain: capability_domain)
                return { success: false, error: 'MAX_PHANTOMS limit reached' } unless limb

                log.debug("[cognitive_phantom] register_removal capability=#{capability_name}")
                { success: true, phantom_id: limb.id, capability_name: capability_name, state: limb.state, intensity: limb.intensity }
              rescue ArgumentError => e
                { success: false, error: e.message }
              end

              def process_stimulus(stimulus:, domain: :general, engine: nil, **)
                raise ArgumentError, 'stimulus is required' if stimulus.nil?

                eng    = engine || phantom_engine
                fired  = eng.process_stimulus(stimulus: stimulus, domain: domain)
                log.debug("[cognitive_phantom] process_stimulus domain=#{domain} fired=#{fired.size}")
                {
                  success:     true,
                  fired_count: fired.size,
                  signals:     fired.map(&:to_h),
                  domain:      domain
                }
              rescue ArgumentError => e
                { success: false, error: e.message }
              end

              def acknowledge_phantom(phantom_id:, engine: nil, **)
                raise ArgumentError, 'phantom_id is required' if phantom_id.nil? || phantom_id.to_s.strip.empty?

                eng    = engine || phantom_engine
                result = eng.acknowledge(phantom_id: phantom_id)
                log.debug("[cognitive_phantom] acknowledge phantom_id=#{phantom_id[0..7]}")
                result.merge(success: result[:acknowledged])
              rescue ArgumentError => e
                { success: false, error: e.message }
              end

              def phantom_status(engine: nil, **)
                eng    = engine || phantom_engine
                report = eng.phantom_activity_report
                log.debug("[cognitive_phantom] phantom_status total=#{report[:total]} active=#{report[:active]}")
                { success: true, **report }
              end

              def decay_all(engine: nil, **)
                eng = engine || phantom_engine
                resolved_count = eng.decay_all!
                report = eng.phantom_activity_report
                log.debug("[cognitive_phantom] decay_all resolved=#{resolved_count}")
                { success: true, resolved_this_cycle: resolved_count, **report }
              end

              private

              def phantom_engine
                @phantom_engine ||= Helpers::PhantomEngine.new
              end
            end
          end
        end
      end
    end
  end
end
