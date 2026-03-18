# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module Erosion
          class Client
            include Runners::CognitiveErosion

            def initialize(engine: nil, **)
              @default_engine = engine || Helpers::ErosionEngine.new
            end

            private

            attr_reader :default_engine
          end
        end
      end
    end
  end
end
