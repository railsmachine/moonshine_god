namespace :god do
  desc "Restart god"
  task :restart do
    sudo 'god quit' # upstart will restart
  end

  desc "Reload god configuration."
  task :reload do
    sudo 'god load /etc/god/god.conf'
  end
  
  desc "Display status of god watches"
  task :status do
    sudo 'god status'
  end

end
after 'deploy', 'god:restart'
