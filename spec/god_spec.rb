require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class GodManifest < Moonshine::Manifest::Rails
  plugin :god
end

describe God do

  before do
    @manifest = GodManifest.new
  end

  describe "with no options" do

    before do
      ENV['RAILS_ENV'] = nil
      @manifest.configure(:deploy_to => '/srv/app')
      @manifest.god
    end

    it "should install god gem" do
      @manifest.packages.keys.should include('god')
    end

    it "should default to production" do
      @manifest.files['/etc/god/god.conf'].content.should =~ /production/
    end

    it "should set the RAILS_ROOT" do
      @manifest.files['/etc/god/god.conf'].content.should =~ /\/srv\/app\/current/
    end

  end

  describe "with options" do

    before do
      ENV['RAILS_ENV'] = 'staging'
      @manifest.god(:log_level => 'info', :log_file => '/tmp/foo.log')
    end

    it "should use the provide log level" do
      @manifest.files['/etc/god/god.conf'].content.should =~ /:info/
    end

    it "should set the environment" do
      @manifest.files['/etc/god/god.conf'].content.should =~ /staging/
    end

  end

end