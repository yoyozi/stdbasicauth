## Loading this App to build on Digital Ocean

**Clone the std app to your desktop as the name of the new application**

> git clone https://github.com/yoyozi/std.git fut-std
> git remote set-url origin https://github.com/yoyozi/fut-std.git
> git push -u origin master

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

Save the file
> reload ssh

**Setup ssh login to Github from the droplet server so no password is used to pull repository**
As the deploying user run
> ssh-keygen -t rsa

Cut and paste the output of below (the public key) to your github repo
> cat ./.ssh/id_rsa.pub

Test the login to github
> ssh -T git@github.com
Should be a welcome message


## On local : ensure IP address and the project repo is adjusted to suite in:
1deploy.rb and production.rb

Recreate the keys using "rake secrets"
```
development:
  secret_key_base: 
test:
  secret_key_base: 
production:
  secret_key_base: 
```




Populate these with the output of "rake secrets"

# Do not keep production secrets in the repository,
# instead read values from the environment.


**Set the locale (add at end of file)**
> sudo vi /etc/environment
> export LANG=en_US.utf8

## On local: Capistrano setup 

**Add the following to the Gemfile in the dev env group**
```
  gem 'capistrano', '~> 3.7.1'
end
```

> bundle
> cap install
> vi ./Capfile

```
# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load the SCM plugin appropriate to your project:
#
# require "capistrano/scm/hg"
# install_plugin Capistrano::SCM::Hg
# or
# require "capistrano/scm/svn"
# install_plugin Capistrano::SCM::Svn
# or
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
# require "capistrano/rvm"
# require "capistrano/rbenv"
# require "capistrano/chruby"
# require "capistrano/bundler"
# require "capistrano/rails/assets"
# require "capistrano/rails/migrations"
# require "capistrano/passenger"

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

```

> vi ./config/deploy.rb

```
# config valid only for current version of Capistrano
lock "3.7.1"

set :user,      'deployer'
set :port,      22


set :application, 'std'
set :repo_url, 'https://github.com/yoyozi/std.git'
set :branch, "master"

# Don't change these unless you know what you're doing
set :pty,             true
set :stage,           "production"
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :ssh_options,     {forward_agent: true, auth_methods: %w(publickey), user: 'craig'}


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Linked Files & Directories (Default None):
#set :linked_files, %w{config/database.yml}
#set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
```

**Create the task dropletsetup.rake in ./lib/capistrano/tasks in the rails app directory**

```
namespace :dropletsetup do


    desc "Updating the server"
    task :_1_update_server do 
        on roles(:app) do 
         execute :sudo, "/usr/bin/apt-get -y update"
       end
    end
   
    desc "Install python software properties"
    task :_2_install_python_software_properties do 
        on roles(:app) do 
           execute :sudo, "/usr/bin/apt-get -y install python-software-properties"
       end
    end 
        
    desc "Install software libaries"
    task :_3_install_libraries do 
        on roles(:app) do 
           execute :sudo,  "apt-get -y install git-core curl zlib1g-dev logrotate build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libpq-dev"
       end
    end

    desc "Install rbenv and ruby rbenv plugin and run  for 2.3.1 then rehash"
    task :_4_install_rbenv_2_3_1 do 
        on roles(:app) do 
            execute "git clone https://github.com/rbenv/rbenv.git ~/.rbenv"
            execute "git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build"
            execute "git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash"
            execute "echo 'export PATH=$HOME/.rbenv/bin:$PATH'  >> ~/.bashrc"
            execute "echo 'eval \"$(rbenv init -)\" ' >> ~/.bashrc"      
          execute "/home/#{fetch(:user)}/.rbenv/bin/rbenv install 2.3.1"
          execute "/home/#{fetch(:user)}/.rbenv/bin/rbenv global 2.3.1"
          execute "/home/#{fetch(:user)}/.rbenv/bin/rbenv rehash"  
        end
    end

    desc "Download nodejs repo then update then install nodejs"
    task :_5_install_nodejs do 
        on roles(:app) do 
            execute 'echo | sudo add-apt-repository ppa:chris-lea/node.js'      
            execute :sudo, "/usr/bin/apt-get -y update"      
            execute :sudo, "/usr/bin/apt-get -y install nodejs"
       end
    end
           
    desc "Install bundler and Rails 4.2.5"
    task :_6_install_bundler do 
        on roles(:app) do 
           execute "/home/deployer/.rbenv/shims/gem install bundler"
           execute "echo 'gem: --no-ri --no-rdoc' >> /home/deployer/.gemrc"      
           execute "/home/deployer/.rbenv/shims/gem install rails -v 4.2.5"
        end
    end

    desc "Install nginx"
    task :_7_install_nginx do 
        on roles(:app) do 
           execute :sudo, "apt-get -y install nginx"
       end
    end  

    desc "Install Postgresql"
    task :_8_install_PGSQL do 
        on roles(:app) do 
           execute :sudo, "apt-get -y install postgresql postgresql-contrib libpq-dev"
       end
    end                
          
end
```

## Run all the tasks above

**Then lets install a pluging to make sure the deploy path is created**

In the Gemfile add under development
```
  gem 'capistrano-safe-deploy-to', '~> 1.1.1'
  gem 'capistrano-unicorn-nginx'
  gem 'capistrano-postgresql'
  gem 'capistrano-rbenv'
  gem 'capistrano-rbenv-install'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-secrets-yml'
```

In the Capfile add
```
require "capistrano/rbenv"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require 'capistrano/safe_deploy_to'
require 'capistrano/unicorn_nginx'
require 'capistrano/postgresql'
require 'capistrano/rbenv_install'
require 'capistrano/secrets_yml'
```

Then in production.rb enable looging for unicorn must apt-get install logrotate
> set :unicorn_logrotate_enabled, true
> bundle install

**Make sure you are not putting the secrets.yml file into the repo and make sure you have in secrets.yml**
```
production:
  secret_key_base: a8c8f482.......................
```

## Create some static pages and deploy






