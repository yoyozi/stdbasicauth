# config valid only for current version of Capistrano
lock "3.7.1"

set :user,      'deployer'
set :port,      22


set :application, 'fut-std'
set :repo_url, 'https://github.com/yoyozi/fut-std.git'
set :branch, "master"

# Don't change these unless you know what you're doing
set :pty,             true
set :stage,           "production"
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :ssh_options,     {forward_agent: true, auth_methods: %w(publickey), user: 'craig'}

set :rbenv_ruby, '2.3.1'


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
