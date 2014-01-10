require 'rails/generators'
module ProtesteGenerateApplication
  module Generators
    class PrepareGenerator < Rails::Generators::Base
      desc "Install files for layout, authentication and authorization"
      source_root File.expand_path('../templates', __FILE__)

      def configuring_access_control_2_api_url
        # api settings
        application(nil, :env => "development") do
          "config.acccess_control_2_api_url = 'http://localhost:9999'"
        end

        application(nil, :env => "production") do
          "config.acccess_control_2_api_url = 'http://localhost:9999'"
        end

        application(nil, :env => "test") do
          "config.acccess_control_2_api_url = 'http://localhost:9999'"
        end
      end

      def add_gems
        puts "\n\n- Adding proteste-scaffold, proteste-auth and proteste-authorization gems"
        content_for_gems = []
        content_for_gems << "gem 'newrelic_rpm'"
        content_for_gems << "gem 'thin'"
        content_for_gems << "gem 'capistrano'"
        content_for_gems << "gem 'rvm-capistrano'"
        content_for_gems << "gem 'proteste_scaffold',    git: 'https://4347f04925c36c7c6c8b477cf89d55cefbc070b1:x-oauth-basic@github.com/proteste/paf-scaffold.git'"
        content_for_gems << "gem 'proteste_auth',        git: 'https://54ce42d5673c0aa07bbfbb4d8b77f79e1e6a5f23:x-oauth-basic@github.com/proteste/paf-auth.git'"
        content_for_gems << "gem 'proteste_authorize',   git: 'https://0f022deb564668d3c9dcbdc6f17cf2f07b6ffdc4:x-oauth-basic@github.com/proteste/paf-authorize.git'"
        # content_for_gems << "gem 'proteste_integration', git: 'git@github.com:proteste/paf-integration.git', group: [:test, :development, :cucumber]"

        # content_for_gems << "gem 'proteste_scaffold',    path: '~/www/paf-scaffold'"
        # content_for_gems << "gem 'proteste_auth',        path: '~/www/paf-auth'"
        # content_for_gems << "gem 'proteste_authorize',   path: '~/www/paf-authorize'"
        # content_for_gems << "gem 'proteste_integration', path: '~/www/paf-integration', group: [:test, :development, :cucumber]"
        content_for_gems.each do |c|
          append_to_file 'Gemfile' do
            "\n#{c}"
          end
        end

        comment_lines 'Gemfile', /gem 'jquery-rails'/
      end
    end
  end
end
