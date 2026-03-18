# frozen_string_literal: true

require 'securerandom'

require_relative 'whirlpool/version'
require_relative 'whirlpool/helpers/constants'
require_relative 'whirlpool/helpers/captured_thought'
require_relative 'whirlpool/helpers/vortex'
require_relative 'whirlpool/helpers/whirlpool_engine'
require_relative 'whirlpool/runners/cognitive_whirlpool'
require_relative 'whirlpool/client'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Whirlpool
        end
      end
    end
  end
end
