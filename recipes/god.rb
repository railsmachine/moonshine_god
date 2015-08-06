namespace :god do
  desc <<-DESC
  Restart god to remove old watches. Would ideally be replaced with something
  like 'god reload' - http://github.com/eric/god/commits/god-reload
  DESC
  task :restart, :roles => :god do
    sudo 'god terminate || true'
    sudo 'start god || true'
    sleep 5
  end

  desc "Reload god configuration."
  task :reload, :roles => :god do
    sudo 'god load /etc/god/god.conf'
  end
  
  desc "Display status of god watches"
  task :status, :roles => :god do
    sudo 'god status'
  end

end
after 'deploy:restart', 'god:restart'
after 'god:restart', 'god:status'