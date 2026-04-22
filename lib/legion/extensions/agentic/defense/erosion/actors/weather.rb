# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Erosion
          module Actor
            class Weather < Legion::Extensions::Actors::Every # rubocop:disable Legion/Extension/EveryActorRequiresTime
              def runner_class
                Legion::Extensions::Agentic::Defense::Erosion::Runners::CognitiveErosion
              end

              def runner_function
                'weather_all'
              end

              def time
                600
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
