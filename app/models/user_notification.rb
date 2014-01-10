require 'active_model'
require 'ostruct'
class UserNotification < OpenStruct

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  # attr_accessor :message, :current_user, :params, :session
  validates :message, presence: true

  # def initialize(attributes = {})
  #   attributes.each do |name, value|
  #     send("#{name}=", value)
  #   end
  # end
  
  def persisted?
    false
  end

  def send_notification
    return false unless self.valid?
    ErrorReportMailer.user_error_report(self.message,
      self.current_user,
      self.url_with_error,
      self.session).deliver
  end
end