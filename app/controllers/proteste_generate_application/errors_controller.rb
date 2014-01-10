class ProtesteGenerateApplication::ErrorsController < ApplicationController
  skip_before_filter :can_access?, :authenticate_user!, :check_user_status
  def routing_error
    raise ActionController::RoutingError.new("Route '#{params[:path]}' does not exist.")
  end

  def error_404
    render layout: 'error'
  end

  def error_500
    render layout: 'error'
  end

  def error_in_javascript
    
  end

  def user_error_report
    attributes = {
      url_with_error: request.env["HTTP_REFERER"],
      session: session,
      current_user: current_user
    }.merge(params[:user_notification] || {})
    @user_notification = UserNotification.new(attributes)
    if @user_notification.send_notification
      flash.now[:success] = I18n.t('general.messages.user_error_report_success')
      @user_notification = nil
    end
    respond_to do |f|
      f.js
    end
  rescue => e
    flash.now[:error] = I18n.t('general.messages.user_error_report_exception')

    # show exception in log of server
    Rails.logger.info "Exception caught by customizing of PAF Framework:"
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.inspect
    respond_to do |f|
      f.js
    end
  end
end