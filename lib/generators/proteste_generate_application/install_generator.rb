require 'rails/generators'
require 'active_support'
module ProtesteGenerateApplication
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Install files for layout, authentication and authorization"
      source_root File.expand_path('../templates', __FILE__)
      class_option :first_install, :type => :boolean, :default => true, desc: 'install of other proteste gems.'


      def install_gems
        if options.first_install?
          puts "\n\n- Installing gems proteste-scaffold, proteste-auth and proteste-authorization gems"
          run('rails g proteste_scaffold:install --force')
          run('rails g proteste_auth:install --force')
          run('rails g proteste_authorize:install --force')
        end
      end

      def copy_app
        puts "\n\n- Copying application files like layout, helpers..."
        directory('app')
      end

      def copy_config
        puts "\n\n- Copying config files like deploy..."
        directory('config')
        copy_file('Capfile')
      end

      def migrating_db
        if options.first_install?
          puts "\n\n- Migrating database"
          rake("db:drop")
          rake("db:migrate")
          rake("db:test:clone")
        end
      end

      def inject_on_application_controller
        if options.first_install?
          content_for_controller = []
          content_for_controller << "layout :set_layout"

          content_for_controller.each do |c|
            inject_into_class 'app/controllers/application_controller.rb', ApplicationController do
              "\t#{c}\n"
            end
          end
        end
      end

      def remove_index_from_public
        remove_file('public/index.html')
      end

      def inject_on_routes
        if options.first_install?
          inject_into_file 'config/routes.rb', "\n  paf_application :change_language, :catch_errors", before: "\nend"
        end
      end
    end
  end
end

