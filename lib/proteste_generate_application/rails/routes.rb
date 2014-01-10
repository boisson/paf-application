module ActionDispatch::Routing
  class Mapper
    def paf_application(*resources)
      if resources.include?(:change_language)
        namespace :proteste_generate_application do
          match  "locales/change_locale/:locale" => "locales#change_locale", :as => "change_locale"
        end
      end

      if resources.include?(:catch_errors)
        namespace :proteste_generate_application do
          match  "errors/routing_error" => "errors#routing_error", :as => "routing_error"
          match  "errors/error_404" => "errors#error_404", :as => "error_404"
          match  "errors/error_500" => "errors#error_500", :as => "error_500"
          match  "errors/user_error_report" => "errors#user_error_report", :as => "user_error_report"
        end

        unless Rails.application.config.consider_all_requests_local
          match '*path', to: redirect('/proteste_generate_application/errors/routing_error')
        end

      end
    end
  end
end