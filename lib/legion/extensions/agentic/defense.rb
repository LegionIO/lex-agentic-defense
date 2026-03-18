# frozen_string_literal: true

require_relative 'defense/version'
require_relative 'defense/immune_response'
require_relative 'defense/immunology'
require_relative 'defense/erosion'
require_relative 'defense/friction'
require_relative 'defense/quicksand'
require_relative 'defense/quicksilver'
require_relative 'defense/phantom'
require_relative 'defense/epistemic_vigilance'
require_relative 'defense/bias'
require_relative 'defense/confabulation'
require_relative 'defense/dissonance'
require_relative 'defense/error_monitoring'
require_relative 'defense/extinction'
require_relative 'defense/avalanche'
require_relative 'defense/whirlpool'

module Legion
  module Extensions
    module Agentic
      module Defense
        extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core

        def remote_invocable?
          false
        end
      end
    end
  end
end
