# frozen_string_literal: true

require 'json'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Extinction
          module Helpers
            class ProtocolState
              MAX_HISTORY = 500

              attr_reader :current_level, :history, :active

              def initialize
                @current_level = 0 # 0 = normal operation
                @active = false
                @history = []
                load_from_local
              end

              def escalate(level, authority:, reason:)
                authority = authority.to_sym if authority.respond_to?(:to_sym)
                return :invalid_level unless Levels.valid_level?(level)
                return :already_at_or_above if level <= @current_level
                return :insufficient_authority unless authority == Levels.required_authority(level)

                @current_level = level
                @active = true
                @history << {
                  action: :escalate, level: level, authority: authority,
                  reason: reason, at: Time.now.utc
                }
                trim_history
                save_to_local
                :escalated
              end

              def deescalate(target_level, authority:, reason:)
                authority = authority.to_sym if authority.respond_to?(:to_sym)
                return :not_active unless @active
                return :invalid_target if target_level >= @current_level
                return :irreversible unless Levels.reversible?(@current_level)
                return :insufficient_authority unless authority == Levels.required_authority(@current_level)

                @current_level = target_level
                @active = target_level.positive?
                @history << {
                  action: :deescalate, level: target_level, authority: authority,
                  reason: reason, at: Time.now.utc
                }
                trim_history
                save_to_local
                :deescalated
              end

              def to_h
                {
                  current_level: @current_level,
                  active:        @active,
                  level_info:    @current_level.positive? ? Levels.level_info(@current_level) : nil,
                  history_size:  @history.size
                }
              end

              def save_to_local
                return unless local_persistence_connected?

                payload = {
                  current_level: @current_level,
                  active:        @active,
                  history:       ::JSON.dump(@history.map { |h| h.merge(at: h[:at].to_s) }),
                  updated_at:    Time.now.utc
                }
                db = local_persistence_connection

                # Atomic upsert — avoids check-then-act race condition
                existing = db[:extinction_state].where(id: 1).update(payload)
                db[:extinction_state].insert(id: 1, **payload) if existing.zero?
                true
              rescue StandardError => e
                log.error("lex-extinction: save_to_local failed: #{e.message}")
                raise if @current_level >= 4

                false
              end

              private

              def trim_history
                @history = @history.last(MAX_HISTORY) if @history.size > MAX_HISTORY
              end

              def load_from_local
                return unless local_persistence_connected?

                row = local_persistence_connection[:extinction_state].where(id: 1).first
                return unless row

                db_level = row[:current_level].to_i
                @current_level = db_level
                @active = [true, 1].include?(row[:active])
                @history = parse_history(row[:history])
                true
              rescue StandardError => e
                log.error("lex-extinction: load_from_local failed: #{e.message}")
                false
              end

              def parse_history(raw)
                return [] if raw.nil? || raw.empty?

                parsed = ::JSON.parse(raw, symbolize_names: true)
                parsed.map do |h|
                  h.merge(
                    action:    h[:action].to_sym,
                    authority: h[:authority].to_sym,
                    at:        Time.parse(h[:at].to_s)
                  )
                end
              rescue StandardError => e
                log.error("lex-extinction: parse_history failed: #{e.message}")
                []
              end

              def local_persistence_connected?
                local_data_connected?
              rescue NoMethodError => e
                log.debug("lex-extinction: local persistence availability unavailable: #{e.message}")
                false
              end

              def local_persistence_connection
                local_data_connection
              rescue NoMethodError => e
                log.debug("lex-extinction: local persistence connection unavailable: #{e.message}")
                raise
              end

              def log
                Legion::Logging
              end
            end
          end
        end
      end
    end
  end
end
