# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Bias
          module Actor
            class Update < Legion::Extensions::Actors::Every
              def runner_class
                Legion::Extensions::Agentic::Defense::Bias::Runners::Bias
              end

              def runner_function
                'update_bias'
              end

              def time
                60
              end

              def run_now?
                false
              end

              def use_runner?
                false
              end

              def check_subtask?
                false
              end

              def generate_task?
                false
              end
            end
          end
        end
      end
    end
  end
end
