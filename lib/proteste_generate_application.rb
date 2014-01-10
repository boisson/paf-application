require 'proteste_generate_application/changelog_control'
require 'proteste_generate_application/deploy_info'

module ProtesteGenerateApplication
  if defined?(Rails)
    require "proteste_generate_application/engine"
    require "proteste_generate_application/railtie"
  end
end

require "action_view"
require "proteste_generate_application/constants"
require "proteste_generate_application/consumers"
require 'proteste_generate_application/rails/routes'

