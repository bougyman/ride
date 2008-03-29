class EditorGenerator < Rails::Generator::NamedBase
  default_options :shell => "bash"
  attr_accessor :screen_name, :shell

  def initialize(runtime_args, runtime_options = {})
    super
    @screen_name = runtime_args.shift
    @shell       = options[:shell] || "bash"
  end

  def manifest
    recorded_session = record do |m|
      m.template 'editor', File.join("script","editor")
      m.template 'screenrc', File.join("config",".screenrc.code.erb")
    end
  end

  protected
  def has_rspec?
    options[:rspec] || (File.exist?('spec') && File.directory?('spec'))
  end

  def banner
    "Usage: #{$0} editor SCREEN_NAME
       SCREEN_NAME will be the name of your editor screen sessions"
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--shell SHELL","Choose a shell to use in the editor (Defaults to bash)") { |v| options[:shell] = v }
  end

end
