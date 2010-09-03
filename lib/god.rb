module God

  # A recipe to install and configure god. 
  # Put configuration files in config/god/*.god in your application.
  def god(options = {})
    gem 'god'

    # tells god where to find the main config file
    file '/etc/default/god',
         :require => package('god'),
         :content => "GOD_CONFIG=/etc/god/god.conf"

    file '/etc/god', :ensure => :directory

    # tells god to load all of the /etc/god/APPNAME.god
    file '/etc/god/god.conf',
         :require => file('/etc/god'),
         :backup => false,
         :notify => exec('restart_god'),
         :content => template("#{File.dirname(__FILE__)}/../templates/god.conf.erb", binding)

    # tells god to load all of the watches for this application
    file "/etc/god/#{configuration[:application]}.god",
        :require => file('/etc/god/god.conf'),
        :content => "God.load '#{configuration[:deploy_to]}/current/config/god/*.god'",
        :notify => exec('restart_god')

    # upstart- start god at boot, respawn when necessary
    path = Facter.lsbdistrelease.to_f < 10 ? "/etc/event.d/god" : "/etc/init/god.conf"
    file "#{path}",
        :content => File.read("#{File.dirname(__FILE__)}/../templates/god.upstart"),
        :notify => exec('restart_god')

    exec 'restart_god',
        :command => 'stop god || true && start god',
        :require => file(path),
        :refreshonly => true

    logrotate '/var/log/god.log',
        :options => ['daily','rotate 7','compress','missingok','sharedscripts'],
        :postrotate => '/usr/bin/god quit > /dev/null' # will be restarted by upstart
  end
  
end
