# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module Extinction
          module Runners
            module Extinction
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def escalate(level:, authority:, reason:, **)
                result = protocol_state.escalate(level, authority: authority, reason: reason)
                case result
                when :escalated
                  info = Helpers::Levels.level_info(level)
                  log.warn("[extinction] ESCALATED: level=#{level} name=#{info[:name]} authority=#{authority} reason=#{reason}")
                  enforce_escalation_effects(level)
                  emit_escalation_event(level, authority, reason)
                  { escalated: true, level: level, info: info }
                else
                  log.debug("[extinction] escalation denied: level=#{level} reason=#{result}")
                  { escalated: false, reason: result }
                end
              end

              def deescalate(authority:, reason:, target_level: 0, **)
                result = protocol_state.deescalate(target_level, authority: authority, reason: reason)
                case result
                when :deescalated
                  log.info("[extinction] de-escalated: target=#{target_level} authority=#{authority} reason=#{reason}")
                  { deescalated: true, level: target_level }
                else
                  log.debug("[extinction] de-escalation denied: target=#{target_level} reason=#{result}")
                  { deescalated: false, reason: result }
                end
              end

              def extinction_status(**)
                status = protocol_state.to_h
                log.debug("[extinction] status: level=#{status[:current_level]} active=#{status[:active]}")
                status
              end

              def monitor_protocol(**)
                status = protocol_state.to_h
                level = status[:current_level]

                if level.positive?
                  log.warn("[extinction] ACTIVE: level=#{level} active=#{status[:active]}")
                  detect_stale_escalation(level)
                else
                  log.debug('[extinction] status: level=0 active=false')
                end

                status
              end

              def check_reversibility(level:, **)
                reversible = Helpers::Levels.reversible?(level)
                log.debug("[extinction] reversibility: level=#{level} reversible=#{reversible}")
                {
                  level:      level,
                  reversible: reversible,
                  authority:  Helpers::Levels.required_authority(level)
                }
              end

              STALE_ESCALATION_THRESHOLD = 86_400

              private

              def enforce_escalation_effects(level)
                if level >= 1 && defined?(Legion::Extensions::Mesh::Runners::Mesh)
                  begin
                    Legion::Extensions::Mesh::Runners::Mesh.disconnect
                    log.warn('[extinction] mesh isolation enforced')
                  rescue StandardError => e
                    log.error("[extinction] mesh isolation failed: #{e.message}")
                  end
                end

                return unless level == 4

                if defined?(Legion::Extensions::Privatecore::Runners::Privatecore)
                  begin
                    Legion::Extensions::Privatecore::Runners::Privatecore.erase_all
                    log.warn('[extinction] cryptographic erasure triggered')
                  rescue StandardError => e
                    log.error("[extinction] cryptographic erasure failed: #{e.message}")
                  end
                end

                if defined?(Legion::Data::Model::DigitalWorker)
                  begin
                    Legion::Data::Model::DigitalWorker.where(lifecycle_state: 'active').update(
                      lifecycle_state: 'terminated', updated_at: Time.now.utc
                    )
                    log.warn('[extinction] all active workers terminated')
                  rescue StandardError => e
                    log.error("[extinction] worker termination failed: #{e.message}")
                  end
                end

                return unless defined?(Legion::Extensions::Apollo::Runners::Knowledge)

                begin
                  obj = Object.new.extend(Legion::Extensions::Apollo::Runners::Knowledge)
                  obj.handle_erasure_request(agent_id: 'system:extinction')
                  log.warn('[extinction] apollo erasure propagated')
                rescue StandardError => e
                  log.error("[extinction] apollo erasure failed: #{e.message}")
                end
              end

              def emit_escalation_event(level, authority, reason)
                return unless defined?(Legion::Events)

                info = Helpers::Levels.level_info(level)
                Legion::Events.emit("extinction.#{info[:name]}", {
                                      level: level, authority: authority, reason: reason, at: Time.now.utc
                                    })
              end

              def detect_stale_escalation(level)
                last_escalation = protocol_state.history.reverse.find { |h| h[:action] == :escalate }
                return unless last_escalation && (Time.now.utc - last_escalation[:at]) > STALE_ESCALATION_THRESHOLD

                log.warn("[extinction] STALE: level=#{level} has been active > 24 hours")
                return unless defined?(Legion::Events)

                Legion::Events.emit('extinction.stale_escalation', {
                                      level: level, since: last_escalation[:at],
                                      hours: ((Time.now.utc - last_escalation[:at]) / 3600).round(1)
                                    })
              end

              def protocol_state
                @protocol_state ||= Helpers::ProtocolState.new
              end
            end
          end
        end
      end
    end
  end
end
