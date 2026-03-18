# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module Confabulation
          module Helpers
            module Constants
              MAX_CLAIMS = 500
              CONFABULATION_THRESHOLD = 0.6
              EVIDENCE_DECAY = 0.02

              RISK_LABELS = {
                0.0..0.2 => :minimal,
                0.2..0.4 => :low,
                0.4..0.6 => :moderate,
                0.6..0.8 => :high,
                0.8..1.0 => :extreme
              }.freeze

              CLAIM_TYPES = %i[factual causal explanatory predictive autobiographical].freeze
            end
          end
        end
      end
    end
  end
end
