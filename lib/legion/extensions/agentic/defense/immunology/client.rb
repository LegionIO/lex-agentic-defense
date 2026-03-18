# frozen_string_literal: true

require 'legion/extensions/agentic/defense/immunology/helpers/constants'
require 'legion/extensions/agentic/defense/immunology/helpers/threat'
require 'legion/extensions/agentic/defense/immunology/helpers/antibody'
require 'legion/extensions/agentic/defense/immunology/helpers/immune_engine'
require 'legion/extensions/agentic/defense/immunology/runners/cognitive_immunology'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Immunology
          class Client
            include Runners::CognitiveImmunology

            def initialize(**)
              @engine = Helpers::ImmuneEngine.new
            end

            private

            attr_reader :engine
          end
        end
      end
    end
  end
end
