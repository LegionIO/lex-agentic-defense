# frozen_string_literal: true

require 'legion/extensions/agentic/defense/confabulation/helpers/constants'
require 'legion/extensions/agentic/defense/confabulation/helpers/claim'
require 'legion/extensions/agentic/defense/confabulation/helpers/confabulation_engine'
require 'legion/extensions/agentic/defense/confabulation/runners/confabulation'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Confabulation
          class Client
            include Runners::Confabulation

            def initialize(**)
              @confabulation_engine = Helpers::ConfabulationEngine.new
            end

            private

            attr_reader :confabulation_engine
          end
        end
      end
    end
  end
end
