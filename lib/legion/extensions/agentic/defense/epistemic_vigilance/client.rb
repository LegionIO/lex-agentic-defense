# frozen_string_literal: true

require 'legion/extensions/agentic/defense/epistemic_vigilance/helpers/constants'
require 'legion/extensions/agentic/defense/epistemic_vigilance/helpers/claim'
require 'legion/extensions/agentic/defense/epistemic_vigilance/helpers/source'
require 'legion/extensions/agentic/defense/epistemic_vigilance/helpers/vigilance_engine'
require 'legion/extensions/agentic/defense/epistemic_vigilance/runners/epistemic_vigilance'

module Legion
  module Extensions
    module Agentic
      module Defense
        module EpistemicVigilance
          class Client
            include Runners::EpistemicVigilance

            private

            def engine
              @engine ||= Helpers::VigilanceEngine.new
            end
          end
        end
      end
    end
  end
end
