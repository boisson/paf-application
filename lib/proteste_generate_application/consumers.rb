require 'httparty'
require 'json'

module ProtesteGenerateApplication
  class Consumers

    def self.current_language(login, new_language_code = nil)
      get_json("/request_current_language", {'login' => login, 'new_language_code' => new_language_code})
    end

    def self.languages
      get_json("/request_languages")
    end

    def self.current_application(app_id)
      get_json("/request_current_application", {'app_id' => app_id})
    end

    def self.applications(login, app_id)
      get_json("/request_applications", {'login' => login, 'app_id' => app_id})
    end

    def self.childrens_functions(functions, function_id = nil)
      functions.find_all{|t| ["S",'G'].include?(t["type_of"]) && t["function_id"] == function_id}.collect do |function|
        {text: function["name"], path: function["url"], ind_category: function["ind_category"], childrens: childrens_functions(functions, function["id"])}
      end
    end

    def self.internal_navigation(login, app_id, language_id)

      menus = get_json("/request_menu", {'login' => login, 'app_id' => app_id, 'language_id' => language_id})

      internal_navigation = []
      unless menus.blank?
        menus.each do |menu|
          internal_navigation << { id: menu["id"], icon: menu["icon"], name: menu["name"], childrens: childrens_functions(menu["functions"]) }
        end
      end
      internal_navigation
    end

    def self.get_json(path, query = nil)
      webservice_url = "#{Rails.application.config.acccess_control_2_api_url}" rescue "http://localhost:9999/api"
      begin
        response        = nil
        response = HTTParty.get("#{webservice_url}#{path}", :query => query )
        
        json = JSON.parse(response.body)
        if json.is_a?(Array) && json[0] == "error"
          raise 'error in webservice'
        end

        json
      rescue => exception
        message = []
        message << 'ACA2 webservice its off'
        message << 'The following request can\'t be accessed'
        message << "url: #{webservice_url}#{path}"
        message << "params: #{query}"
        e = Exception.new(message.join("\n"))
        e.set_backtrace(exception.backtrace)
        ErrorReportMailer.report(e).deliver
        raise 'error in webservice'
      end
    end
  end
end