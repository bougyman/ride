class RideGenerator < RubiGen::Base

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  # These get passed into options
  default_options :author => nil, :language => "ruby", :shell => 'bash', :template_type => 'ramaze', :editor => 'vim', :console_debugger => 'script/ride-console'

  attr_reader :name, :main_lib, :shell, :editor, :template_type, :language, :screen_name, :console_debugger, :shell

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    puts 'Args left: ' + args.inspect
    @destination_root = File.expand_path(args.last)
    @name = base_name
    extract_options
    if @language == 'ruby'
      @main_lib ||= File.basename(@destination_root)
    end
    ramaze_defaults = { :helper_base => "/lib/", :controller_base => "/controller/", :view_base => "/view/", :model_base => "/model/", :test_base => "/spec/" }
    rails_defaults = { :helper_base => "/app/helpers/", :controller_base => "/app/controllers/", :view_base => "/app/views/", :model_base => "/app/models/", :test_base => "/test/" }
    ruby_defaults = { :controller_base => nil, :view_base => nil, :model_base => nil, :test_base => "/spec/" }
    puts "Options: " + options.inspect
    puts 'template: ' + @template_type.to_s
    defaults = case @template_type.to_s
    when "ramaze"
      ramaze_defaults
    when "rails"
      rails_defaults
    else
      @template_type = "ruby"
      ruby_defaults
    end
    defaults.each_pair { |k,v| options[k] = v }
    @screen_name ||= @name
  end

  def create_ruby
    puts %x{newgem #{@destination_root}}
  end

  def create_ramaze
    puts %x{ramaze --create #{@destination_root}}
  end

  def create_rails
    puts %x{rails #{@destination_root}}
  end

  def manifest
    unless File.exists?(@destination_root) and File.directory?(@destination_root)
      self.send("create_#{template_type}".to_sym)
    end
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory ''
      BASEDIRS.each { |path| m.directory path }

      # create the test directory
      m.directory options[:test_base].sub(%r|^/|,"").sub(%r|/$|,"")

      # Create stubs
      # m.template "template.rb",  "some_file_after_erb.rb"
      # m.template_copy_each ["template.rb", "template2.rb"]
      # m.file     "file",         "some_file_copied"
      # m.file_copy_each ["path/to/file", "path/to/file2"]

      #m.dependency "install_rubigen_scripts", [destination_root, 'ride'],
      #  :shebang => options[:shebang], :collision => :force
      m.file_copy_each %w{RIDE_History.txt RIDE_License.txt RIDE_README.txt .vimrc .irbrc}
      m.file_copy_each [%w{ftplugin ruby ruby.vim}, %w{plugin taglist.vim}, %w{syntax eruby.vim}, %w{ftdetect ruby.vim}].map { |vimfile| File.join(".vim", *vimfile) }
      script_options     = { :chmod => 0755, :shebang => options[:shebang] == RideGenerator::DEFAULT_SHEBANG ? nil : options[:shebang] }
      m.file_copy_each %w{tasks/rspec.rake tasks/ride.rake}
      m.template  "config/.screenrc.code.erb", "config/.screenrc.code.erb"
      m.template "config/code_template_#{@template_type}.erb", "config/code_template.erb"
      m.template "script/ride", "script/ride", script_options
      m.file "script/console", "script/ride-console", script_options
    end
  end

  protected
    def banner
      <<-EOS
Creates a ...

USAGE: #{spec.name} name
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |options[:author]| }
      opts.on("--language EDITOR", String, "Language to develop in" ,"Default: ruby") { |options[:language]| }
      opts.on("--template TEMPLATE", String, "Project template (support ramaze, rails, newgem)", "Default: ramaze") { |x| options[:project_type] = x }
      opts.on("--editor EDITOR", String, "Editor to use", "Default: vim") { |options[:editor]| }
      opts.on("--shell SHELL", String, "Shell to use", "Default: bash") { |options[:shell]| }
      opts.on("--name NAME", String, "What to name the screen session", "Default: #{@name}") { |options[:screen_name]| }
      opts.on("--debugger SCRIPT", String, "What to use for window 1, debugger", "Default: script/ride-console") { |options[:console_debugger]| }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
      @template_type = options[:project_type]
      puts "Extracted #{template_type} as template_type"
      @language = options[:language]
      @main_dir = options[:main_dir]
      @shell = options[:shell]
      @editor = options[:editor]
      @console_debugger = options[:console_debugger]
    end

    # Installation skeleton.  Intermediate directories are automatically
    # created so don't sweat their absence here.
    BASEDIRS = %w(
      lib
      log
      script
      config
      tasks
      tmp
      .vim
      .vim/syntax
      .vim/plugin
      .vim/ftdetect
      .vim/ftplugin
      .vim/ftplugin/ruby
    )
end
