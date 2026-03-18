# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Defense
        module ImmuneResponse
          class Client
            include Runners::CognitiveImmuneResponse

            def initialize(engine: nil)
              @default_engine = engine || Helpers::ImmuneEngine.new
            end
          end
        end
      end
    end
  end
end
