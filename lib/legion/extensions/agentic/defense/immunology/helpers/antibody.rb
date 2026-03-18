# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Immunology
          module Helpers
            class Antibody
              attr_reader :id, :tactic, :pattern, :created_at
              attr_accessor :strength, :matches

              def initialize(tactic:, pattern:, strength: 0.5)
                @id       = SecureRandom.uuid
                @tactic   = tactic
                @pattern  = pattern
                @strength = strength.clamp(0.0, 1.0)
                @matches  = 0
                @created_at = Time.now.utc
              end

              def match!
                @matches += 1
                boost = Constants::RESISTANCE_BOOST / (@matches + 1)
                @strength = (@strength + boost.round(10)).clamp(0.0, 1.0).round(10)
              end

              def decay!
                @strength = (@strength - Constants::RESISTANCE_DECAY).clamp(0.0, 1.0).round(10)
              end

              def effective?
                @strength >= 0.3
              end

              def to_h
                {
                  id:         @id,
                  tactic:     @tactic,
                  pattern:    @pattern,
                  strength:   @strength,
                  matches:    @matches,
                  effective:  effective?,
                  created_at: @created_at
                }
              end
            end
          end
        end
      end
    end
  end
end
