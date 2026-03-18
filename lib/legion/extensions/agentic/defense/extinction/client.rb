# frozen_string_literal: true

require 'legion/extensions/agentic/defense/extinction/helpers/levels'
require 'legion/extensions/agentic/defense/extinction/helpers/protocol_state'
require 'legion/extensions/agentic/defense/extinction/runners/extinction'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Extinction
          class Client
            include Runners::Extinction

            def initialize(**)
              @protocol_state = Helpers::ProtocolState.new
            end

            private

            attr_reader :protocol_state
          end
        end
      end
    end
  end
end
