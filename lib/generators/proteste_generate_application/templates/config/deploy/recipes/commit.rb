# require 'proteste_generate_application'
require 'proteste_generate_application/changelog_control'

namespace :commit do
  task :development do
    begin
      ticket_number = Capistrano::CLI.ui.ask("Ticket or bug number: ")
      solution      = Capistrano::CLI.ui.ask("Solution: ")
      
      ProtesteGenerateApplication::ChangelogControl.insert(:development, user_email, ticket_number, solution)

    end while Capistrano::CLI.ui.ask("Add another solution?") {|q| q.default = 'no'} == 'yes'
  end

  task :approval do
    begin
      ticket_number = Capistrano::CLI.ui.ask("Ticket or bug number: ")
      solution      = Capistrano::CLI.ui.ask("Solution: ")
      
      if ProtesteGenerateApplication::ChangelogControl.insert(:approval, user_email, ticket_number, solution)
        ['development','production'].each do |e|
          if Capistrano::CLI.ui.ask("Want publish the changes in #{e} changelog too? (yes or no): ") {|q| q.default = 'no'} == 'yes'
            ProtesteGenerateApplication::ChangelogControl.insert(e.to_sym, user_email, ticket_number, solution)
          end
        end
      end

    end while Capistrano::CLI.ui.ask("Add another solution?") {|q| q.default = 'no'} == 'yes'
  end

  task :staging do
    begin
      ticket_number = Capistrano::CLI.ui.ask("Ticket or bug number: ")
      solution      = Capistrano::CLI.ui.ask("Solution: ")
      
      if ProtesteGenerateApplication::ChangelogControl.insert(:approval, user_email, ticket_number, solution)
        ['development','production'].each do |e|
          if Capistrano::CLI.ui.ask("Want publish the changes in #{e} changelog too? (yes or no): ") {|q| q.default = 'no'} == 'yes'
            ProtesteGenerateApplication::ChangelogControl.insert(e.to_sym, user_email, ticket_number, solution)
          end
        end
      end

    end while Capistrano::CLI.ui.ask("Add another solution?") {|q| q.default = 'no'} == 'yes'
  end

  task :production do
    begin
      ticket_number = Capistrano::CLI.ui.ask("Ticket or bug number: ")
      solution      = Capistrano::CLI.ui.ask("Solution: ")
      
      if ProtesteGenerateApplication::ChangelogControl.insert(:production, user_email, ticket_number, solution)
        ['development','approval'].each do |e|
          if Capistrano::CLI.ui.ask("Want publish the changes in #{e} changelog too? (yes or no): ") {|q| q.default = 'no'} == 'yes'
            ProtesteGenerateApplication::ChangelogControl.insert(e.to_sym, user_email, ticket_number, solution)
          end
        end
      end

    end while Capistrano::CLI.ui.ask("Add another solution?") {|q| q.default = 'no'} == 'yes'
  end


  # when do deploy, the user will be asked if need some merge with some environment
  # development: don't ask anything
  # approval|staging: ask if need merge with development
  # production: ask if need merge with approval
end

def user_email
  @user_email ||= `git config user.email`.strip
end

# when do deploy, the user will be asked if need some merge with some environment
# development:        don't ask anything
# approval|staging:   ask if need merge with development
# production:         ask if need merge with approval|staging
def merge_changelog(current_env,back_env)
  changelog_control = ProtesteGenerateApplication::ChangelogControl.new(current_env)
  changelog_control.merge(back_env)
end
