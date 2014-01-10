module ProtesteGenerateApplication
  class InternalNavigationStore
    delegate :current_user, :current_language, :session, to: :@view

    def initialize(view, app_id)
      @view   = view
      @app_id = app_id
    end

    def valid?
      current_user? && app_id? && current_language?
    end

    def invalid?
      !valid?
    end

    def internal_navigation!
      return internal_navigation if has_internal_navigation?
      cache!
      @internal_navigation = Rails.cache.fetch("proteste_internal_navigation_#{current_user.id}", expires_in: 2.hours) do
        get_internal_navigation
      end
    end

    def internal_navigation
      @internal_navigation
    end

    def self.load_internal_navigation(view, app_id)
      internal_navigation = ProtesteGenerateApplication::InternalNavigationStore.new(view, app_id)
      return nil if internal_navigation.invalid?

      internal_navigation.internal_navigation!
    end

    protected

    def get_internal_navigation
      ProtesteGenerateApplication::Consumers.internal_navigation(user_login, app_id, current_language_id)
    end

    def has_internal_navigation?
      in_cache? && !internal_navigation.nil?
    end

    def user_login
      current_user.login
    end

    def app_id
      @app_id
    end

    def current_user?
      !current_user.nil?
    end

    def app_id?
      !@app_id.nil?
    end

    def current_language?
      !current_language.nil?
    end

    def current_language_id
      current_language['id']
    end

    def in_cache?
      if session[:internal_navigation_on_cache].nil?
        Rails.cache.delete("proteste_internal_navigation_#{current_user.id}")
        false
      else
        true
      end
    end

    def cache!
      session[:internal_navigation_on_cache] ||= true
    end

  end
end