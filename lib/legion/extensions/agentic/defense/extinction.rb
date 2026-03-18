# frozen_string_literal: true

require 'legion/extensions/agentic/defense/extinction/version'
require 'legion/extensions/agentic/defense/extinction/helpers/levels'
require 'legion/extensions/agentic/defense/extinction/helpers/protocol_state'
require 'legion/extensions/agentic/defense/extinction/runners/extinction'
require 'legion/extensions/agentic/defense/extinction/client'

module Legion
  module Extensions
    module Agentic
      module Defense
        module Extinction
        end
      end
    end

    if defined?(Legion::Data::Local)
      Legion::Data::Local.register_migrations(
        name: :extinction,
        path: File.join(__dir__, 'extinction', 'local_migrations')
      )
    end
  end
end
