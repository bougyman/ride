require File.join(File.dirname(__FILE__), '/spec_generator_helper.rb')

module RideGeneratorSpecHelper
  include RubiGen::GeneratorSpecHelper
  def generator_path
    "app_generators"
  end

  def sources
    [RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", generator_path))
    ]
  end

  def full_path(some_path)
    File.join(APP_ROOT, @template_type, some_path)
  end
end

# Time to add your specs!
# http://rspec.info/
describe "Ride Rails Generator", "when rails application is generated" do
# {{{
  include RideGeneratorSpecHelper
  before(:all) do  
    bare_setup
    @template_type = 'rails'
    run_generator('ride', [File.join(APP_ROOT,@template_type)], sources, {:console_debugger => 'irb', :project_type => @template_type, :shell => 'bash', :editor => 'vim'})
  end

  RideGenerator::BASEDIRS.each do |dir|
    it "should create #{dir}" do
      File.directory?(full_path(dir)).should == true
    end
  end

  %w{RIDE_History.txt RIDE_License.txt RIDE_README.txt .vimrc .irbrc}.each do |file|
    it "should create #{file}" do
      File.exists?(full_path(file)).should == true
    end
  end

  it "should put our rake tasks in place" do
    file_path = File.join("tasks", "ride.rake")
    File.exists?(full_path(file_path)).should == true
    file_path = File.join("tasks", "rspec.rake")
    File.exists?(full_path(file_path)).should == true
  end

  %w{destroy generate console}.each do |file|
    it "should not overwrite rails #{script_path = File.join("script", file)}" do
      File.exists?(full_path(script_path)).should == true
      File.readlines(full_path(script_path))[1].to_s.should =~ %r{/../config/boot}
    end
  end

  it "should create the config/.screenrc.code.erb file" do
    file_path = File.join("config", ".screenrc.code.erb")
    File.exists?(full_path(file_path)).should == true
  end

  it "should create the config/code_template.erb file" do
    file_path = File.join("config", "code_template.erb")
    File.exists?(full_path(file_path)).should == true
  end

  it "should create the script/ride file (executable)" do
    file_path = File.join("script", "ride")
    File.exists?(full_path(file_path)).should == true
    FileTest.executable?(full_path(file_path)).should == true
    File.read(full_path(file_path)).match(/app\/models/).should_not == nil
  end

  it "should create the script/ride-console file (executable)" do
    file_path = File.join("script", "ride-console")
    File.exists?(full_path(file_path)).should == true
    FileTest.executable?(full_path(file_path)).should == true
  end

  [%w{ftplugin ruby ruby.vim}, %w{plugin taglist.vim}, %w{syntax eruby.vim}, %w{ftdetect ruby.vim}].each do |vimfile|
    it "Should create #{vim_path = File.join(".vim", *vimfile)}" do
      File.exists?(full_path(vim_path)).should == true
    end
  end

  after(:all) do
    #bare_teardown
  end
  
end
# }}}

describe "Ride Ramaze Generator", "when ramaze application is generated" do
  include RideGeneratorSpecHelper
  before(:all) do  
    @template_type = 'ramaze'
    bare_setup
    run_generator('ride', [File.join(APP_ROOT, @template_type)], sources, {:console_debugger => 'irb', :project_type => @template_type, :shell => 'bash', :editor => 'vim'})
  end

  RideGenerator::BASEDIRS.each do |dir|
    it "should create #{dir}" do
      File.directory?(full_path(dir)).should == true
    end
  end

  %w{RIDE_History.txt RIDE_License.txt RIDE_README.txt .vimrc .irbrc}.each do |file|
    it "should create #{file}" do
      File.exists?(full_path(file)).should == true
    end
  end

  it "should put our rake tasks in place" do
    file_path = File.join("tasks", "ride.rake")
    File.exists?(full_path(file_path)).should == true
    file_path = File.join("tasks", "rspec.rake")
    File.exists?(full_path(file_path)).should == true
  end

  %w{destroy generate console}.each do |file|
    it "should not create #{script_path = File.join("script", file)}" do
      File.exists?(full_path(script_path)).should_not == true
      FileTest.executable?(full_path(script_path)).should_not == true
    end
  end

  it "should create the config/.screenrc.code.erb file" do
    file_path = File.join("config", ".screenrc.code.erb")
    File.exists?(full_path(file_path)).should == true
  end

  it "should create the config/code_template.erb file" do
    file_path = File.join("config", "code_template.erb")
    File.exists?(full_path(file_path)).should == true
  end

  it "should create the script/ride file (executable)" do
    file_path = File.join("script", "ride")
    File.exists?(full_path(file_path)).should == true
    FileTest.executable?(full_path(file_path)).should == true
    File.read(full_path(file_path)).match(/app\/models/).should == nil
    File.read(full_path(file_path)).match(/\/model\//).should_not == nil
    File.read(full_path(file_path)).match(%r|  :controllers_base => [^\s]+ \+ "/controller/",|).should_not == nil
    File.read(full_path(file_path)).match(%r|  :models_base\s+=>\s[^\s]+\s+\+\s+"/model/",|).should_not == nil
  end

  it "should create the script/ride-console file (executable)" do
    file_path = File.join("script", "ride-console")
    File.exists?(full_path(file_path)).should == true
    FileTest.executable?(full_path(file_path)).should == true
  end

  [%w{ftplugin ruby ruby.vim}, %w{plugin taglist.vim}, %w{syntax eruby.vim}, %w{ftdetect ruby.vim}].each do |vimfile|
    it "Should create #{vim_path = File.join(".vim", *vimfile)}" do
      File.exists?(full_path(vim_path)).should == true
    end
  end


  after(:all) do
#    bare_teardown
  end
end
