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

Set the locale (add at end of file)
> sudo vi /etc/environment
> export LANG=en_US.utf8

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
  username: db
  password: <%= ENV['STD_DATABASE_PASSWORD'] %>
```

In the Capfile make sure these are all commented out
```
# require "capistrano/rbenv"
# require "capistrano/bundler"
# require "capistrano/rails/assets"
# require "capistrano/rails/migrations"
# require 'capistrano/safe_deploy_to'
# require 'capistrano/unicorn_nginx'
# require 'capistrano/rbenv_install'
# require 'capistrano/secrets_yml'
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

In the Capfile remove comments
```
require "capistrano/rbenv"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require 'capistrano/safe_deploy_to'
require 'capistrano/unicorn_nginx'
require 'capistrano/rbenv_install'
require 'capistrano/secrets_yml'
```

## Submit to repo
> git add -A
> git commit -m "Ready" 
> git push -u origin master
> cap production setup

## Now lets setup postgresql
> sudo -u postgresql createuser -s rails-psql-user
> sudo -u postgres psql
> /password (set the postgres user password)
> /password rails-psql-user (set the rails-user password)
> /q
> createdb "name"

**Create the connection in ./shared/config**
> vi database.yml

```
production:
  adapter: postgresql
  encoding: unicode
  pool: 5
  host: localhost
  database: name
  username: rails-psql-user
  password: 'cccccc'
```

> chmod 500 ./database.yml 

**Create linked files and directories by adding into deploy.rb**

```
set :linked_files, %w{config/database.yml}
set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
```

## Setup the server

> cap production setup
> cap production deploy


