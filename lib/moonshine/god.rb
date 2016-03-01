module Moonshine
  module God

    def self.included(manifest)
      manifest.class_eval do
        extend ClassMethods
        configure :god => {:version => '0.13.7'}
      end
    end

    module ClassMethods
      def god_template_dir
        @god_template_dir ||= Pathname.new(__FILE__).join('..', '..', '..', 'templates').expand_path.relative_path_from(Pathname.pwd)
      end
    end

    # A recipe to install and configure god.
    # Put configuration files in config/god/*.god in your application.
    def god(options = {})
      god_version = options[:version] || configuration[:god][:version]
      gem 'god', :version => god_version,
                 :notify => exec('restart_god')

      # tells god where to find the main config file
      file '/etc/default/god',
           :require => package('god'),
           :content => "GOD_CONFIG=/etc/god/god.conf"

      file '/etc/god', :ensure => :directory
      file "/etc/god/#{ENV['RAILS_ENV']}", :ensure => :directory

      # tells god to load all of the /etc/god/APPNAME.god
      file '/etc/god/god.conf',
           :require => file('/etc/god'),
           :backup => false,
           :notify => exec('restart_god'),
           :content => template(god_template_dir.join('god.conf.erb'), binding)

      # tells god to load all of the watches for this application
      file "/etc/god/#{configuration[:application]}.god",
          :require => file('/etc/god/god.conf'),
          :content => "God.load '#{configuration[:deploy_to]}/current/config/god/*.god'",
          :notify => exec('restart_god')

      upstart_path = if Facter.value(:lsbdistrelease).to_f < 10
                       "/etc/event.d/god"
                     else
                       "/etc/init/god.conf"
                     end

      upstart_template = if Facter.value(:lsbdistrelease).to_f < 10
                          god_template_dir.join('god.upstart')
                        else
                          god_template_dir.join('god.upstart.lucid')
                        end

      file upstart_path,
          :content => template(upstart_template, binding),
          :notify => exec('restart_god')

      exec 'restart_god',
          :command => 'stop god || true && start god',
          :require => file(upstart_path),
          :refreshonly => true

      logrotate '/var/log/god.log',
          :options => ['copytruncate', 'daily','rotate 7','compress','missingok','sharedscripts']
    end

  end
end
