require 'active_support'
require File.expand_path(File.join(File.dirname(__FILE__), 'internal_navigation_store'))

module ProtesteGenerateApplication
  module Controller
    extend ActiveSupport::Concern

    included do
      before_filter :build_breadcrumbs, :set_user_language, :check_user_status
      helper_method :current_application, :proteste_applications, :internal_navigation,
      :current_language, :proteste_languages

      unless Rails.application.config.consider_all_requests_local
        rescue_from Exception, with: lambda { |exception| catch_exception 500, exception }
        rescue_from ActionController::UnknownController,
          ActionController::UnknownAction,
          ActionController::RoutingError,
          ActiveRecord::RecordNotFound,
          with: lambda { |exception| catch_exception 404, exception }
      end

      rescue_from ActiveRecord::StatementInvalid, with: lambda { |exception| catch_exception 500, exception }
    end

    def check_user_status
      return unless current_user
      if current_user.blocked?
        I18n.locale = 'en'
        flash[:error] = t('devise.failure.blocked')
        sign_out(:user)
        redirect_to new_user_session_path
      elsif current_user.access_locked?
        I18n.locale = 'en'
        flash[:error] = t('devise.failure.locked')
        sign_out(:user)
        redirect_to new_user_session_path
      end
    end

    def catch_exception(status, exception)
      # show exception in log of server
      Rails.logger.info "Exception caught by customizing of PAF Framework:"
      Rails.logger.error exception.message
      Rails.logger.error exception.backtrace.inspect

      @exception = exception
      message = @exception.message

      if statement_invalid_on_delete?(exception)
        message = t('general.messages.delete_error_with_associations')
        flash[:error] = message
      else
        flash[:error] = t('general.messages.modal_ajax_error')
      end

      ErrorReportMailer.report(exception).deliver rescue flash[:error] += ".<br />Contact your sistem administrator and report the error."

      if !request.env["HTTP_REFERER"].blank? and
        request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
        if statement_invalid_on_delete?(exception)
          render template: 'shared/batch_destroy.js.erb'
        else
          redirect_to :back
        end
      elsif request.env["REQUEST_URI"] != root_path
        if statement_invalid_on_delete?(exception)
          render template: 'shared/batch_destroy.js.erb'
        else
          redirect_to root_path
        end
      else
        respond_to do |format|
          format.html { redirect_to eval("proteste_generate_application_error_#{status}_url(message: message)") }
          format.js   { 
            if statement_invalid_on_delete?(exception)
              render template: 'shared/batch_destroy.js.erb'
            else
              render template('proteste_generate_application/errors/error_in_javascript.js.erb'), layout: nil, status: status
            end
          }
          format.json { render nothing: true, status: status }
          format.all  { render nothing: true, status: status }
        end
      end
    end

    def statement_invalid_on_delete?(exception)
      exception.is_a?(ActiveRecord::StatementInvalid) and ["destroy","batch_destroy"].include?(self.action_name)
    end

    def set_user_language
      return unless current_user
      I18n.locale = current_language['code']
    end

    def current_language
      return session[:current_language] unless session[:current_language].nil?
      language                    = ProtesteGenerateApplication::Consumers.current_language(current_user.login,params[:locale])
      I18n.locale                 = language['code']
      session[:current_language]  = language
    end

    def proteste_languages
      session[:proteste_languages] ||= ProtesteGenerateApplication::Consumers.languages
    end

    def current_application
      session[:current_application] ||= ProtesteGenerateApplication::Consumers.current_application(APP_ID)
    end

    def proteste_applications
      session[:proteste_applications] ||= ProtesteGenerateApplication::Consumers.applications(current_user.login, APP_ID)
    end

    def internal_navigation
      ProtesteGenerateApplication::InternalNavigationStore.load_internal_navigation(view_context, APP_ID)
    end

    def build_breadcrumbs
      actions = ["index", "show", "new", "edit", "create", "update"]
      
      if (self.action_methods.to_a & actions) == actions
        add_breadcrumb(:index, url_for(action: :index, only_path: true))
        add_breadcrumb(t('general.actions.list'), url_for(action: :index, only_path: true))
        return true
      end
      false
    end

    def set_layout
      'application_proteste'
    end
  end
end