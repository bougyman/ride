class RideGenerator < RubiGen::Base

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  default_options :author => nil, :language => "ruby", :shell => 'bash', :editor => 'vim', :console_debugger => 'script/ride-console'

  attr_reader :name, :main_lib, :shell, :editor, :template, :language, :screen_name, :console_debugger

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    @name = base_name
    extract_options
    if @language == 'ruby'
      @main_lib ||= File.basename(@destination_root)
    end
    @screen_name ||= @name
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory ''
      BASEDIRS.each { |path| m.directory path }

      # Create stubs
      # m.template "template.rb",  "some_file_after_erb.rb"
      # m.template_copy_each ["template.rb", "template2.rb"]
      # m.file     "file",         "some_file_copied"
      # m.file_copy_each ["path/to/file", "path/to/file2"]

      m.dependency "install_rubigen_scripts", [destination_root, 'ride'],
        :shebang => options[:shebang], :collision => :force
      m.file_copy_each %w{History.txt License.txt README.txt}
      m.file_copy_each [%w{ftplugin ruby ruby.vim}, %w{plugin taglist.vim}, %w{syntax eruby.vim}, %w{ftdetect ruby.vim}].map { |vimfile| File.join(".vim", *vimfile) }
      script_options     = { :chmod => 0755, :shebang => options[:shebang] == RideGenerator::DEFAULT_SHEBANG ? nil : options[:shebang] }
      m.file_copy_each %w{tasks/rspec.rake tasks/ride.rake}
      m.template  "config/.screenrc.code.erb", "config/.screenrc.code.erb"
      m.template "config/code_template.erb", "config/code_template.erb"
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
      opts.on("-l", "--language", String, "Language to develop in" "Default: ruby") { |options[:language]| }
      opts.on("-t", "--template", String, "Project template" "Default: rails") { |options[:template]| options[:language] = 'ruby' if options[:template] == 'rails'  }
      opts.on("-e", "--editor", String, "Editor to use" "Default: vim") { |options[:editor]| }
      opts.on("-s", "--shell", String, "Shell to use" "Default: bash") { |options[:shell]| }
      opts.on("-n", "--name", String, "What to name the screen session" "Default: #{@name}") { |options[:screen_name]| }
      opts.on("-d", "--debugger", String, "What to use for window 1, debugger", "Default: script/ride-console") { |options[:console_debugger]| }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
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
      test
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
