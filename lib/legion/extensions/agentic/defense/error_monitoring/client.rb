# frozen_string_literal: true

require 'legion/extensions/agentic/defense/error_monitoring/helpers/constants'
require 'legion/extensions/agentic/defense/error_monitoring/helpers/error_signal'
require 'legion/extensions/agentic/defense/error_monitoring/helpers/error_monitor'
require 'legion/extensions/agentic/defense/error_monitoring/runners/error_monitoring'

module Legion
  module Extensions
    module Agentic
      module Defense
        module ErrorMonitoring
          class Client
            include Runners::ErrorMonitoring

            def initialize(monitor: nil, **)
              @monitor = monitor || Helpers::ErrorMonitor.new
            end

            private

            attr_reader :monitor
          end
        end
      end
    end
  end
end
