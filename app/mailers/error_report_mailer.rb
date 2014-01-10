class ErrorReportMailer < ActionMailer::Base
  default :from => "aca@aca2.proteste.org.br"

  def report(exception)
    @exception = exception
    mail subject: "Error report: #{exception.message}",
      to: ["BRA-develop@conseur.org",'acosme@proteste.org.br','vmoraes@proteste.org.br']
  end


  def user_error_report(message, user, url_with_error, session_params)
    @message        = message
    @user           = user
    @url_with_error = url_with_error
    @session_params = session_params

    mail subject: "Client Error report in: #{url_with_error}",
      to: ["BRA-develop@conseur.org",'acosme@proteste.org.br','vmoraes@proteste.org.br']
  end
end
