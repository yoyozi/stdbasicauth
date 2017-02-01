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