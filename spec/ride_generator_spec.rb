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
    File.join(APP_ROOT, some_path)
  end
end

# Time to add your specs!
# http://rspec.info/
describe "Ride Generator", "when application is generated" do
  include RideGeneratorSpecHelper
  before(:all) do  
    bare_setup
    run_generator('ride', [APP_ROOT], sources, {:console_debugger => 'irb', :template => 'rails', :shell => 'bash', :editor => 'vim'})
  end

  RideGenerator::BASEDIRS.each do |dir|
    it "should create #{dir}" do
      File.directory?(full_path(dir)).should == true
    end
  end

  %w{Rakefile History.txt License.txt README.txt}.each do |file|
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

  %w{destroy generate}.each do |file|
    it "should create #{file}" do
      script_path = File.join("script", file)
      File.exists?(full_path(script_path)).should == true
      FileTest.executable?(full_path(script_path)).should == true
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

  it "should create the script/ride file" do
    file_path = File.join("script", "ride")
    File.exists?(full_path(file_path)).should == true
    FileTest.executable?(full_path(file_path)).should == true
  end

=begin
  it "should create a default season" do
    File.exists?(full_path(File.join("config", "global.yml"))).should == true
    File.exists?(full_path(File.join("config", "requirements.rb"))).should == true
    File.directory?(full_path(File.join("config", "seasons", "testing"))).should == true
  end

  %w{database stems season leaves}.each do |yml|
    it "should put the default #{yml}.yml in place" do
      File.exists?(full_path(File.join("config", "seasons", "testing", "#{yml}.yml"))).should == true
    end
  end

  AutumnGenerator::DEMOLEAVES.each do |leaf|
    it "should create the #{leaf} leaf directory" do
      File.directory?(full_path(File.join("leaves", leaf))).should == true
    end
    AutumnGenerator::LEAFDIRS.each do |dir|
      leaf_dir = File.join("leaves", leaf, dir)
      it "should create #{leaf_dir}" do
        File.directory?(full_path(leaf_dir)).should == true
      end
    end
    it "should create #{leaf}/controller.rb" do
      File.exists?(full_path(File.join("leaves", leaf, "controller.rb"))).should == true
    end
    it "should create #{leaf}/README" do
      File.exists?(full_path(File.join("leaves", leaf, "README"))).should == true
    end
  end

  %w{autumn.txt.erb  reload.txt.erb}.each do |admin_file|
    file_path = File.join("leaves", "administrator", "views", admin_file)
    it "should create #{file_path}" do
      File.exists?(full_path(file_path)).should == true
    end
  end

  %w{about.txt.erb  help.txt.erb  insult.txt.erb}.each do |insult_file|
    file_path = File.join("leaves", "insulter", "views", insult_file)
    it "should create #{file_path}" do
      File.exists?(full_path(file_path)).should == true
    end
  end

  it "should put ScoreKeeper's config.yml in place" do
    file_path = File.join("leaves", "scorekeeper", "config.yml")
    File.exists?(full_path(file_path)).should == true
  end

  %w{about.txt.erb  change.txt.erb  history.txt.erb  points.txt.erb  usage.txt.erb}.each do |tmpl|
    file_path = File.join("leaves", "scorekeeper", "views", tmpl)
    it "should create #{file_path}" do
      File.exists?(full_path(file_path)).should == true
    end
  end

  %w{channel.rb  person.rb  pseudonym.rb  score.rb}.each do |tmpl|
    file_path = File.join("leaves", "scorekeeper", "models", tmpl)
    it "should create #{file_path}" do
      File.exists?(full_path(file_path)).should == true
    end
  end

  it "should put the scorekeeper leaf's tasks in place" do
    file_path = File.join("leaves", "scorekeeper", "tasks", "stats.rake")
    File.exists?(full_path(file_path)).should == true
  end
  
  it "should put the scorekeeper leaf's helpers in place" do
    file_path = File.join("leaves", "scorekeeper", "helpers", "general.rb")
    File.exists?(full_path(file_path)).should == true
  end
=end

  after(:all) do
#    bare_teardown
  end
  
end

# Some generator-related assertions:
#   assert_generated_file(name, &block) # block passed the file contents
#   assert_directory_exists(name)
#   assert_generated_class(name, &block)
#   assert_generated_module(name, &block)
#   assert_generated_test_for(name, &block)
# The assert_generated_(class|module|test_for) &block is passed the body of the class/module within the file
#   assert_has_method(body, *methods) # check that the body has a list of methods (methods with parentheses not supported yet)
#
# Other helper methods are:
#   app_root_files - put this in teardown to show files generated by the test method (e.g. p app_root_files)
#   bare_setup - place this in setup method to create the APP_ROOT folder for each test
#   bare_teardown - place this in teardown method to destroy the TMP_ROOT or APP_ROOT folder after each test
