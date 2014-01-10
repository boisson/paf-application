require "rvm/capistrano" 
# require 'bundler/capistrano'

default_run_options[:pty] = true
set :application, "NAME_OF_APPLICATION"

set :rvm_ruby_string, "ruby-1.9.3@#{application}"
set :rvm_type, :user

set :user, "railsapps"
set :use_sudo, false
set :ssh_options, { :forward_agent => true }

set :scm, :git
set :repository, "git@github.com:proteste/#{application}.git"
set :branch, "master"
set :deploy_via, :copy
set :deploy_to, "/home/#{user}/#{application}"

set :bundle_flags,    nil
set :bundle_without,  nil

set :thin_pid, "#{deploy_to}/shared/pids/thin.pid"
set :thin_port, "PORT_OF_APPLICATION"

load 'config/deploy/recipes/commit'

after "deploy", "deploy:cleanup", "rvm:trust_rvmrc"

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end

task :development do
  set :deploy_via, :remote_cache
  set :app_env, 'development'
  set :branch, "develop"
  server "DEVELOPMENT_SERVER_NAME", :app, :web, :db, :primary => true
  after  "deploy:update_code", "deploy:database_config_dev", "deploy:write_informations", "deploy:changelog_dev"
end

task :approval do
  if Capistrano::CLI.ui.ask("Want merge with development changelog too? (yes or no): ") {|q| q.default = 'no'} == 'yes'
    merge_changelog(:approval, :development)
  end
  select_release
  set :app_env, 'production'
  server "APPROVAL_SERVER_NAME", :app, :web, :db, :primary => true
  after  "deploy:update_code", "deploy:database_config_apr", "deploy:write_informations", "deploy:changelog_apr"
end

task :production do
  if Capistrano::CLI.ui.ask("Want merge with approval changelog too? (yes or no): ") {|q| q.default = 'no'} == 'yes'
    merge_changelog(:production, :approval)
  end
  select_release
  set :app_env, 'production'
  server "PRODUCTION_SERVER_NAME", :app, :web, :db, :primary => true
  after  "deploy:update_code", "deploy:database_config_prd", "deploy:write_informations", "deploy:changelog_prd"
end


task :select_release do
  logger.info "These are the latest releases on git:"
  show_releases_list
  set :release_to_deploy, Capistrano::CLI.ui.ask("Enter git release to deploy (enter to deploy latest): ") {|q| q.default = last_release}
  set :branch,  "release/#{release_to_deploy}"
end

namespace :deploy do
  
  task :restart do
    run "cd #{deploy_to}/current && thin stop; true"
    run "cd #{deploy_to}/current && thin start -e #{app_env} -p #{thin_port} -d; true"
  end
  task :start do
    run "cd #{deploy_to}/current && thin start -e #{app_env} -p #{thin_port} -d"
  end
  task :stop do
    run "cd #{deploy_to}/current && thin stop; true"
  end
  
  task :database_config_apr do
    run "rm -rf #{release_path}/config/database.yml"
    run "cp #{release_path}/config/database.yml.apr #{release_path}/config/database.yml"
  end

  task :database_config_prd do
    run "rm -rf #{release_path}/config/database.yml"
    run "cp #{release_path}/config/database.yml.prd #{release_path}/config/database.yml"
  end

  task :database_config_dev do
    run "rm -rf #{release_path}/config/database.yml"
    run "cp #{release_path}/config/database.yml.dev #{release_path}/config/database.yml"
  end

  task :write_informations do
    put Date.today.strftime("%Y-%m-%d").to_s, "#{release_path}/DEPLOY_DATE"
    put branch, "#{release_path}/DEPLOY_RELEASE"
  end

  task :changelog_apr do
    run "cp #{release_path}/changelog.apr #{release_path}/CHANGELOG"
  end

  task :changelog_prd do
    run "cp #{release_path}/changelog.prd #{release_path}/CHANGELOG"
  end

  task :changelog_dev do
    run "cp #{release_path}/changelog.dev #{release_path}/CHANGELOG"
  end
end

task :create_release do
  show_releases_list
  create_release
end

def releases_list
  return @releases_list if @releases_list
  @releases_list = `git branch -r`.split("\n")
  @releases_list = @releases_list.find_all{|t| t.include?('release')}.collect{|t| t.gsub(/\s+/, "").gsub('origin/release/','')}.reverse
end

def last_release
  @releases_list.first
end

def create_release
  position_in_month = (Date.today.day / 15) + 1
  release_name      = Capistrano::CLI.ui.ask("Enter git release name (ex.: #{Date.today.strftime("%y%m")}_0#{position_in_month}.01): ")
  `git branch release/#{release_name}`
  `git checkout release/#{release_name}`
  `git push origin release/#{release_name}`
end

def show_releases_list
  puts "releases on repository:"
  if releases_list.empty?
    logger.info " ===== Create release ====="
  else
    logger.info last_release + " <===== LATEST"
    if releases_list.size > 5
      1.upto(4) do |i|
        logger.info releases_list[i]
      end
      
    else
      1.upto(releases_list.size-1) do |i|
        logger.info releases_list[i]
      end
    end
  end
end