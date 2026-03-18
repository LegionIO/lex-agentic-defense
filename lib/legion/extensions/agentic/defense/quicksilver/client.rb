# frozen_string_literal: true

require 'legion/extensions/agentic/defense/quicksilver/helpers/constants'
require 'legion/extensions/agentic/defense/quicksilver/helpers/droplet'
require 'legion/extensions/agentic/defense/quicksilver/helpers/pool'
require 'legion/extensions/agentic/defense/quicksilver/helpers/quicksilver_engine'
require 'legion/extensions/agentic/defense/quicksilver/runners/cognitive_quicksilver'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Quicksilver
          class Client
            include Runners::CognitiveQuicksilver

            def initialize
              @quicksilver_engine = Helpers::QuicksilverEngine.new
            end

            private

            attr_reader :quicksilver_engine
          end
        end
      end
    end
  end
end
