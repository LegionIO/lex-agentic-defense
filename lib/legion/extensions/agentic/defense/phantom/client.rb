# frozen_string_literal: true

require 'legion/extensions/agentic/defense/phantom/helpers/constants'
require 'legion/extensions/agentic/defense/phantom/helpers/phantom_signal'
require 'legion/extensions/agentic/defense/phantom/helpers/phantom_limb'
require 'legion/extensions/agentic/defense/phantom/helpers/phantom_engine'
require 'legion/extensions/agentic/defense/phantom/runners/cognitive_phantom'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Phantom
          class Client
            include Runners::CognitivePhantom

            def initialize(**)
              @phantom_engine = Helpers::PhantomEngine.new
            end

            private

            attr_reader :phantom_engine
          end
        end
      end
    end
  end
end
