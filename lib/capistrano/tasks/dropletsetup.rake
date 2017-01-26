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
           execute :sudo,  "apt-get -y install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libpq-dev"
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