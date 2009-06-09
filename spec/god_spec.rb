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
      @manifest.god
    end

    it "should install god gem" do
      @manifest.packages.keys.should include('god')
    end

  end

  describe "with options" do

    before do
      ENV['RAILS_ENV'] = 'staging'
      ENV['RAILS_ROOT'] = '/srv/foo/current'
      @manifest.god(:log_level => 'info', :log_file => '/tmp/foo.log')
    end

    it "should use the provide log level" do
      @manifest.files['/etc/god/god.conf'].content.should =~ /:info/
    end

    it "should set the environment" do
      @manifest.files['/etc/god/god.conf'].content.should =~ /staging/
    end

    it "should set the RAILS_ROOT" do
      @manifest.files['/etc/god/god.conf'].content.should =~ /\/srv\/foo\/current/
    end

  end

end