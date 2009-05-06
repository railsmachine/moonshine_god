require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class GodManifest < Moonshine::Manifest
  plugin :god
end

describe God do
  
  before do
    @manifest = GodManifest.new
  end
  
  
  it "should install god gem" do
    @manifest.packages.keys.should include 'god'
  end
    
end