module ProtesteGenerateApplication
  module ViewHelpers
    def changelog_items
      return @changelog_items if @changelog_items
      changelog_control = ProtesteGenerateApplication::ChangelogControl.new
      @changelog_items  = changelog_control.rows_by_date
    end

    def revision_info
      ProtesteGenerateApplication::DeployInfo.revision_informations.html_safe
    end

    # APP_ID constants come with proteste-auth gem
    def build_menu_at_top
      output = []
      if proteste_applications
        proteste_applications.each do |app|
          output << content_tag(:li, link_to(app['name'], app['url'], class: 'not_external').html_safe, class: ('active' if app['app_id'] == APP_ID))
        end
      end
      output.join.html_safe
    end

    def build_menu_at_side(childrens = nil)

      output = []
      unless childrens.blank?
        childrens.sort_by! {|hash| hash[:text]}
        childrens.each do |children|
          if children[:childrens].blank?
            path_info_of_children        = Rails.application.routes.recognize_path(children[:path])
            path_info_of_current         = {controller: controller.controller_name, action: controller.action_name}
            controller_and_action_equals = path_info_of_current[:controller] == path_info_of_children[:controller] && path_info_of_current[:action] == path_info_of_children[:action]
            output << content_tag(:li, link_to(children[:text], children[:path]).html_safe, class: ('active' if request.path == children[:path] || (controller_and_action_equals)))
          else
            output << content_tag(:li, children[:text], class: 'nav-header')
            output << build_menu_at_side(children[:childrens])
          end
        end
      end
      output.join.html_safe
    end


    def menu_by_breadcrumb
      internal_navigation.each do |menu|
        menu_founded = children_of_menu(menu,menu[:childrens])
        return menu_founded unless menu_founded.nil?
      end
      nil
    end

    def children_of_menu(menu, childrens)
      childrens.each do |children|
        return menu[:name] if children[:path] == @breadcrumbs.last[:url] || children_of_menu(menu,children[:childrens])
      end
      nil
    end

    def languages_except_current
      proteste_languages.find_all{|language| language['code'] != current_language['code']}
    end

    def edit_profile_url
      "#{Rails.application.config.acccess_control_2_url}/users?go_to=/users/#{current_user.id}/edit.js"
    end

    def current_user_change_password_url
      "#{Rails.application.config.acccess_control_2_url}/current_user/change_password"
    end

    def avatar_url(user, image_width=150)
      default_url = "#{Rails.application.config.acccess_control_2_url}/assets/guest.png"
      gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{image_width}"
    end
  end
end