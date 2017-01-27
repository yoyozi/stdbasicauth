
namespace :droplet do

  desc "Updating the server"  
  task :dsetup do   
      on roles(:app) do 
        execute :sudo, "apt-get -y install postgresql postgresql-contrib libpq-dev"
    end  
  end 
end                    