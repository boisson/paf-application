require 'rails/railtie'
# require 'proteste_generate_application/routes'
require 'proteste_generate_application/controller'
require 'proteste_generate_application/view_helpers'
module ProtesteGenerateApplication
  class Railtie < Rails::Railtie
    initializer "proteste_generate_application.action_controller" do
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send(:include, ProtesteGenerateApplication::Controller)
        # include  # ActiveSupport::Concern
      end
    end

    initializer "proteste_generate_application.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end