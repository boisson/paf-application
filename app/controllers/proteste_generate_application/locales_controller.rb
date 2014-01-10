class ProtesteGenerateApplication::LocalesController < ApplicationController
  skip_before_filter :can_access?, :check_user_status

  def change_locale
    session[:current_language]    = ProtesteGenerateApplication::Consumers.current_language(current_user.login,params[:locale])
    session[:internal_navigation] = ProtesteGenerateApplication::Consumers.internal_navigation(current_user.login, APP_ID, current_language['id'])
    I18n.locale = current_language['code']
    redirect_to :back
  end
end