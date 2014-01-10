# ProtesteGenerateApplication

Generate application to be use in Proteste Company with default settings


## Pre-requisits

Install rvm (http://rvm.io)
Install ruby 1.9.3
Install the gemset with rubygems 1.8.5. To set 1.8.5 in your gemset use:

    $ rvm rubygems 1.8.5


## Installation

Add this line to your application's Gemfile (prefer at top) after database gem:
And uncomment the line of therubyracer


    gem 'proteste_generate_application', :git => 'https://7f48847aabeed11d9f0e1358ef171debccfb79a6:x-oauth-basic@github.com/proteste/paf-application.git'
    gem 'therubyracer', platforms: :ruby

Inside your project, execute:

    $ bundle


## Usage

Enter in the project and prepare it

    $ rails g proteste_generate_application:prepare
    $ bundle update
    $ rails g proteste_generate_application:install

Copy the app_id and app_secret generated and insert a new Application on Access Control to run


## Capistrano informations

When the install occur the files of capistrano are copied to your project
They are:

    # Capfile
    # config/deploy.rb
    # config/deploy/recipes/commit.rb
    # config/database.yml.dev
    # config/database.yml.apr
    # config/database.yml.prd
    # config/database.yml.test

You need modify these files with your project name, port used with thin server and server name.


## Changelog steps

For each environment exists must exists a file of changelog. These occur because 
each environment have your own modifications. Here we have some scenarios to explain better.

NORMAL DEVELOPMENT STEP

1 - You receive new story to develop in development environment
2 - After test, develop and be sure it's ok you will need update the changelog
    
    $ cap commit:development

Insert the task number, your solution and if you have one more type yes on final
This command will insert on changelog.dev file with the new modifications

3 - Add and commit the files


FIXING A BUG IN PRODUCTION

1 - You receive new bug to fix in production environment
2 - After test, develop and be sure it's ok you will need update the changelog

    $ cap commit:production

Insert the bug number, your solution and you will be asked if want publish in approval
and development changelog too. In these case types yes because your solution must be 
applied on these branchs (manually)
This command will insert on changelog.prd file with new modifications and insert too 
on the changelog.apr and changelog.dev

3 - Add and commit the files
4 - Merge with your other branches


DEPLOY IN APPROVAL SOMETHING THAT YOU DEVELOP AND NEED BE TESTED

1 - You finished your work and someone need test in approval environment

    $ cap deploy production

You will be asked if want merge the changelog.apr with changelog.dev. Type yes.
When you type yes, the two files are opened, ordered by task and date and join in the
changelog.apr file again with last modifications.

2 - Add and commit the files


## Example application

With a few steps you can generate one application with all features

    $ rails g scaffold Category name
    $ rails g scaffold Color name
    $ rails g scaffold Accessory name
    $ rails g scaffold Specification name
    $ rails g scaffold ColorsProducts color:references product:references
    $ rails g scaffold AccessoriesProducts accessory:references product:references
    $ rails g scaffold ProductsSpecifications specification:references product:references
    $ rails g scaffold Product name published_at:date category:references colors:n_to_n_inline accessories:n_to_n_2_columns specifications:n_to_n_2_columns description:text
    $ rake db:migrate

Insert the functions on Access Control 2

    - /categories
    - /colors
    - /accessories
    - /specifications
    - /products

Create structure for new application on Access Control 2 with all functions above

Apply permissions to strcutures above

Start the server on application and enjoy


## This gem is updated and your project isn't?

Update the gem and run install without the first install process

    $ bundle update
    $ rails g proteste_generate_application:install --skip-first-install


