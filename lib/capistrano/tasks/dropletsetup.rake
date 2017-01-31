
namespace :droplet do

  desc "Updating the server"  
  task :dsetup do   
      on roles(:app) do 
            execute "echo 'export LANG=\"en_US.utf8\"' >> ~/.bashrc"
            execute "echo 'export LANGUAGE=\"en_US.utf8\"' >> ~/.bashrc"
            execute "echo 'export LC_ALL=\"en_US.UTF-8\"' >> ~/.bashrc"
            execute "source /home/#{fetch(:user)}/.bashrc"
            execute "source /home/deployer/.bashrc"
    end  
  end 
end                    