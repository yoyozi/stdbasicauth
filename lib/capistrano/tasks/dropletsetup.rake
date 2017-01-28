
namespace :droplet do

  desc "Updating the server"  
  task :dsetup do   
      on roles(:app) do 
        execute :sudo, "service postgresql start"
    end  
  end 
end                    