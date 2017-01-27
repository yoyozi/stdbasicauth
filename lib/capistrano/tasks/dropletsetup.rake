
namespace :droplet do

  desc "Updating the server"  
  task :dsetup do   
      on roles(:app) do 
        execute :sudo, "/usr/bin/apt-get -y install nodejs"
    end  
  end 
end                    