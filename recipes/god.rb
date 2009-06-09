namespace :god do
  desc "Reload god configuration."
  task :reload do
    sudo 'god load /etc/god/god.conf'
  end
end
after 'deploy:restart', 'god:reload'
