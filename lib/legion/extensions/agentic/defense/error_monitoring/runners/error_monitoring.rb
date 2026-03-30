# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module ErrorMonitoring
          module Runners
            module ErrorMonitoring
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def report_error(action:, domain:, intended:, actual:, severity:, **)
                log.debug("[error_monitor] error: action=#{action} domain=#{domain} severity=#{severity}")
                signal = monitor.register_error(
                  action: action, domain: domain,
                  intended: intended, actual: actual, severity: severity
                )
                {
                  success: true, error: signal.to_h,
                  error_rate: monitor.error_rate.round(4),
                  slowdown: monitor.slowdown.round(4),
                  state: monitor.monitoring_state
                }
              end

              def report_success(action:, domain:, **)
                log.debug("[error_monitor] success: action=#{action} domain=#{domain}")
                result = monitor.register_success(action: action, domain: domain)
                { success: true, action: action, domain: domain, error_rate: result[:error_rate] }
              end

              def report_conflict(action_a:, action_b:, domain:, intensity:, **)
                log.debug("[error_monitor] conflict: #{action_a} vs #{action_b} domain=#{domain}")
                entry = monitor.register_conflict(
                  action_a: action_a, action_b: action_b,
                  domain: domain, intensity: intensity
                )
                { success: true, conflict: entry, conflict_active: monitor.conflict_active? }
              end

              def apply_correction(action:, domain:, original_error:, correction:, **)
                log.debug("[error_monitor] correction: action=#{action} domain=#{domain}")
                entry = monitor.register_correction(
                  action: action, domain: domain,
                  original_error: original_error, correction: correction
                )
                { success: true, correction: entry, confidence: monitor.confidence.round(4) }
              end

              def recent_errors(limit: 10, **)
                errors = monitor.recent_errors(limit: limit.to_i).map(&:to_h)
                log.debug("[error_monitor] recent_errors: #{errors.size}")
                { success: true, errors: errors, count: errors.size }
              end

              def errors_in_domain(domain:, **)
                errors = monitor.errors_in(domain: domain).map(&:to_h)
                log.debug("[error_monitor] errors_in: domain=#{domain} count=#{errors.size}")
                { success: true, domain: domain, errors: errors, count: errors.size }
              end

              def uncorrected_errors(**)
                errors = monitor.uncorrected_errors.map(&:to_h)
                log.debug("[error_monitor] uncorrected: #{errors.size}")
                { success: true, errors: errors, count: errors.size }
              end

              def monitoring_state(**)
                state = monitor.monitoring_state
                log.debug("[error_monitor] state: #{state}")
                {
                  success: true, state: state,
                  label: Helpers::Constants::MONITORING_STATE_LABELS[state],
                  slowdown: monitor.slowdown.round(4),
                  confidence: monitor.confidence.round(4)
                }
              end

              def update_error_monitoring(**)
                log.debug('[error_monitor] tick')
                monitor.tick
                { success: true, state: monitor.monitoring_state, slowdown: monitor.slowdown.round(4) }
              end

              def error_monitoring_stats(**)
                log.debug('[error_monitor] stats')
                { success: true, stats: monitor.to_h }
              end

              private

              def monitor
                @monitor ||= Helpers::ErrorMonitor.new
              end
            end
          end
        end
      end
    end
  end
end
