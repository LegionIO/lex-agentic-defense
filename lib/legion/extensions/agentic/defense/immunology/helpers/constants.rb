# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module Immunology
          module Helpers
            module Constants
              DEFAULT_RESISTANCE = 0.5
              RESISTANCE_BOOST   = 0.1
              RESISTANCE_DECAY   = 0.02
              MAX_THREATS        = 500
              MAX_ANTIBODIES     = 200

              THREAT_LABELS = {
                (0.8..)     => :critical,
                (0.6...0.8) => :severe,
                (0.4...0.6) => :moderate,
                (0.2...0.4) => :low,
                (..0.2)     => :negligible
              }.freeze

              IMMUNITY_LABELS = {
                (0.8..)     => :immune,
                (0.6...0.8) => :resistant,
                (0.4...0.6) => :normal,
                (0.2...0.4) => :vulnerable,
                (..0.2)     => :compromised
              }.freeze

              MANIPULATION_TACTICS = %i[
                authority_appeal emotional_blackmail false_urgency
                social_proof_abuse gaslighting strawman ad_hominem
                sunk_cost_exploit bandwagon fear_mongering
              ].freeze
            end
          end
        end
      end
    end
  end
end
