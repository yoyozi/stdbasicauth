## Basic AUTH and AUTH using TDD with RSpec and Capybara

## A clone of std

**Clone the std app to your desktop as the name of the new application**
> git clone https://github.com/yoyozi/reponame.git newreponame

**Create newreponame on github**
**Set the remote to created**

> git remote set-url origin https://github.com/yoyozi/newreponame.git

**Submit to repo just created**
> git add -A
> git commit -m "Ready" 
> git push -u origin master

**Change IPAddress and project repo name: so no mistake**
deploy.rb and production.rb

Create the ./config/secrets.yml file and use keys "rake secret" to populate
```
development:
  secret_key_base: xxx
test:
  secret_key_base: xxxcxccv
production:
  secret_key_base: <%= ENV['SECTRETSTRING'] %>
```

Create ./config/application.yml file for figaro
```
production:
   DBPW: thepw
   SECTRETSTRING: "the string from rake secret"
```

Create the database.yml file
```
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  host: localhost

development:
  <<: *default
  database: db_development

test:
  <<: *default
  database: db_test

production:
  <<: *default
  database: db_production
  username: rails-psql-user
  password: <%= ENV['DBPW'] %>
```

**MAKE SURE .gitignore has**

```
/db/*.sqlite3
/db/*.sqlite3-journal
*/log/
!/log/.keep
/tmp
/config/database.yml
/.env
/config/secrets.yml

# Ignore application configuration
/config/application.yml
```

## Setup testing environment
**Add gems**

gem 'faker'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
end

> bundle

**Setup rpec**

>rails g rspec:install

Edit the rails helper file
```
# This file is copied to spec/ when you run 'rails generate rspec:install'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rails'
require 'shoulda/matchers'
require 'database_cleaner'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.include FactoryGirl::Syntax::Methods
  # config.include Features, type => feature
  # config.include Features::SessionHelpers, type: :feature

end
```

**Test rspec**

> rspec 
Should get no examples found

**Get the server up and running**

> rake db:create
> rails s

## Testing

> rails g model post title:string body:text (this creates spec files for us)
>  rake db:migrate

./spec/model/post_spec.rb
```
require 'rails_helper'

RSpec.describe Post, type: :model do
  before(:all) do 
    @post = Post.new(body: "My body", title: "My Title")
  end
  it "Should have matching body" do 
    expect(@post.body).to eq("Your body")
  end
end
```

Run the test and it should fail: change to pass
>rspec ./spec/model/post_spec.rb

**To bring in Capybara a "Features test suite: testing user interactions"**

> rails g controller posts 
> mkdir ./spec/features
> touch ./spec/features/add_posts_spec.rb

```
require rails_helper.rb 

Rspec.feature "adding posts" do 


  scenario ' allow a user to add a post' do   

    visit new_post_path

    fill_in "Tital", with: "My Title"
    fill_in "Body", with: "My body"

    click_on("Create post")

    expect(page).to have_content("My Title")
    expect(page).to have_content("My body")
    
  end 

end
```

Run the test 
> rspec ./spec/features/add_post_spec.rb 

Should fail : undefined local variable or method `new_post_path'
No routes so create one
Add to routes:   resources :posts
Now run test and need to add controller action new 

Added simple form: gem 'simple_form', '~> 3.4'
> bundle 
> rails generate simple_form:install

Created views for new and _form
Go through the motions of finding failure and correcting**

**Bringing in FactoryGirl (replaces fixtures)**
Factory girl methods

build(:post) (returns model instance but doesnt save to DB)
create(:post) (returns model instance  and saves to DB)
attributes_for(:post) returns hash of the attributes: good for testing the params in the controller
build_stubbed(:post)  similar to build but returns an unsaved model instance and assigns a fake active record id to the model

Make sure you have this in your rails_helper.rb fileconfig.include FactoryGirl::Syntax::Methods

> mkdir ./spec/factories (if doesnt exist)
Do testing using factorygirl

## Bootstrap

In Gemfile add and bundle:
```
gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6'
gem 'font-awesome-sass', '~> 4.5.0'
gem 'bootstrap-sass-extras', '~> 0.0.2'
```

Application.css rename to application.css.scss if using sass for first time
> vi application.css.scss 

And add:
```
 *= require_tree .
 *= require_self
 */

@import "bootstrap";
@import "bootstrap-sprockets";

@import "font-awesome";
@import "font-awesome-sprockets";
```

> rails g bootstrap:install

and for responsive layout run 
> rails g bootstrap:layout application fluid
> rails generate simple_form:install --bootstrap


























Doing later
## Loading this App to build on Digital Ocean with Capistrano3

## On remote: Sign up with Digital Ocean or rebuild your existing droplet
Delete the fingerprints of the known host in the known hosts file on your local machine

**User accounts and remote ssh. On droplet**
Log in with you cert and change root password
> passwd
> adduser username
> adduser deploy_user
> gpasswd -a username sudo
> gpasswd -a deploy_user sudo

**Make editing the sudo file use vim**
__AFTER Defaults        env_reset
>Defaults        editor=/usr/bin/vim

**Make the deploy user passwordless when running listed commands/apps**
> visudo

```
for now
#deploy_user ALL=(ALL) NOPASSWD:ALL
will change later to 
deploy_user ALL=NOPASSWD:/usr/bin/apt-get
```

## On local machine (on mac use):
> ssh-copy-id deploy_user@x.x.x.x
> ssh-copy-id username@x.x.x.x

**Test that you can login with the deployer user and your own username, and su to root BEFORE removing root remote login!!!**
> ssh -p xxxx deployer@x.x.x.x
> sudu su -

**For better security, it's recommended that you disable remote root login**
> vi /etc/ssh/sshd_config

```
Port 22 # change this to whatever port you wish to use
Protocol 2
PermitRootLogin no
(At the end of sshd_config, enter):
UseDNS no
AllowUsers username username
```

**To squeulch the perl WARNIG**

Edit the /etc/ssh/ssh_config file
> vi /etc/ssh/ssh_config
Find the line "SendEnv LANG LC_*"

```
# SendEnv LANG LC_*
```

Save the file
> reload ssh

## Digital Ocean specific

Configure the time zone and ntp service
> sudo dpkg-reconfigure tzdata
> sudo apt-get install ntp

Configure swap space
> sudo fallocate -l 4G /swapfile
> sudo chmod 600 /swapfile
> sudo mkswap /swapfile
> sudo swapon /swapfile
> sudo sh -c 'echo "/swapfile none swap sw 0 0" >> /etc/fstab'

**Setup ssh login to Github from the droplet server so no password is used to pull repository**

As the deploying user run
> ssh-keygen -t rsa

Cut and paste the output of below (the public key) to your github repo
> cat ./.ssh/id_rsa.pub

Test the login to github
> ssh -T git@github.com
Should be a welcome message

Set the locale (add at end of file)
> sudo vi /etc/environment
> export LANG=en_US.utf8

## On local 

In the Capfile make sure these are all commented out
```
#require 'capistrano/figaro_yml'
#require "capistrano/rbenv"
#require "capistrano/bundler"
#require "capistrano/rails/assets"
#require "capistrano/rails/migrations"
#require 'capistrano/safe_deploy_to'
#require 'capistrano/unicorn_nginx'
#require 'capistrano/rbenv_install'
#require 'capistrano/secrets_yml'
#require 'capistrano/database_yml'
```

## Run the task droplet:dsetup
Make sure file looks like this
```
namespace :droplet do

  desc "Updating the server"  
  task :setup do   
      on roles(:app) do 
        execute "echo 'export LANG=\"en_US.utf8\"' >> ~/.bashrc"
        execute "echo 'export LANGUAGE=\"en_US.utf8\"' >> ~/.bashrc"
        execute "echo 'export LC_ALL=\"en_US.UTF-8\"' >> ~/.bashrc"
        execute "source /home/#{fetch(:user)}/.bashrc"
        execute "source /home/deployer/.bashrc"
        execute :sudo, "/usr/bin/apt-get -y update"
        execute :sudo, "/usr/bin/apt-get -y install python-software-properties"
        execute :sudo,  "apt-get -y install git-core curl zlib1g-dev logrotate build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libpq-dev"
        execute :sudo, "apt-get -y install nginx"
        execute :sudo, "apt-get -y install postgresql postgresql-contrib libpq-dev"
        execute :sudo, "service postgresql start"
        execute 'echo | sudo add-apt-repository ppa:chris-lea/node.js'          
        execute :sudo, "/usr/bin/apt-get -y install nodejs"
        execute :sudo, "/usr/bin/apt-get -y update"  
    end  
  end 
end
```

## On remote: setup postgresql on the remote server
> sudo -u postgresql createuser -s rails-psql-user
> sudo -u postgres psql
> \password (set the postgres user password)
> \password rails-psql-user (set the rails-user password)
> sudo -u postgres createdb chraig_production
> \q

## on local



Create linked files and directories by adding into deploy.rb
```
set :linked_files, %w{config/database.yml}
set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
```

In the Capfile make sure these are all NOT commented out
```
require 'capistrano/figaro_yml'
require "capistrano/rbenv"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require 'capistrano/safe_deploy_to'
require 'capistrano/unicorn_nginx'
require 'capistrano/rbenv_install'
require 'capistrano/secrets_yml'
require 'capistrano/database_yml'
```

## Setup the server

> cap -T
> cap production safe_deploy_to:ensure
> cap production setup
> cap production deploy


