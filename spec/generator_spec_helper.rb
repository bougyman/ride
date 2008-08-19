module RubiGen
  module GeneratorSpecHelper
    # Runs the create command (like the command line does)
    def run_generator(name, params, sources, options = {})
      generator = build_generator(name, params, sources, options)
      silence_generator do
        generator.command(:create).invoke!
      end
      generator
    end

    # Instatiates the Generator
    def build_generator(name, params, sources, options)
      options.merge!(:collision => :force)  # so no questions are prompted
      if sources.is_a?(Symbol)
        if sources == :app
          RubiGen::Base.use_application_sources!
        else
          RubiGen::Base.use_component_sources!
        end
      else
        RubiGen::Base.reset_sources
        RubiGen::Base.prepend_sources(*sources) unless sources.blank?
      end
      RubiGen::Base.instance(name, params, options)
    end

    # Silences the logger temporarily and returns the output as a String
    def silence_generator
      logger_original=RubiGen::Base.logger
      myout=StringIO.new
      RubiGen::Base.logger=RubiGen::SimpleLogger.new(myout)
      # TODO redirect $stdout to myout
      yield if block_given?
      RubiGen::Base.logger=logger_original
      # TODO fix $stdout again
      myout.string
    end

    # asserts that the given file was generated.
    # the contents of the file is passed to a block.
    def generated_file?(path)
      file_exists?(path)
      File.open("#{APP_ROOT}/#{path}") do |f|
        yield f.read if block_given?
      end
    end

    # asserts that the given file exists
    def file_exists?(path)
      File.exists?("#{APP_ROOT}/#{path}").should eql(true)
    end

    # asserts that the given directory exists
    def directory_exists?(path)
      File.directory?("#{APP_ROOT}/#{path}").should eql(true)
    end

    # asserts that the given class source file was generated.
    # It takes a path without the <tt>.rb</tt> part and an optional super class.
    # the contents of the class source file is passed to a block.
    def generated_class?(path,parent=nil)
      path=~/\/?(\d+_)?(\w+)$/
      class_name=$2.camelize
      generated_file?("#{path}.rb") do |body|
        it "should define #{class_name} in #{path}.rb" do
          body.should match(/class #{class_name}#{parent.nil? ? '':" < #{parent}"}/)
        end
        yield body if block_given?
      end
    end

    # asserts that the given module source file was generated.
    # It takes a path without the <tt>.rb</tt> part.
    # the contents of the class source file is passed to a block.
    def generated_module?(path)
      path=~/\/?(\w+)$/
      module_name=$1.camelize
      generated_file?("#{path}.rb") do |body|
        it "should define #{module_name} in #{path}.rb" do
          body.should match(/module #{module_name}/)
        end
        yield body if block_given?
      end
    end

    # asserts that the given unit test was generated.
    # It takes a name or symbol without the <tt>test_</tt> part and an optional super class.
    # the contents of the class source file is passed to a block.
    def generated_test_for?(name, parent="Test::Unit::TestCase")
      generated_class? "test/test_#{name.to_s.underscore}", parent do |body|
        yield body if block_given?
      end
    end

    # asserts that the given methods are defined in the body.
    # This does assume standard rails code conventions with regards to the source code.
    # The body of each individual method is passed to a block.
    def has_method?(body,*methods)
      methods.each do |name|
        it "should define the method #{name.to_s}" do
          body.should match(/^  def #{name.to_s}\n((\n|   .*\n)*)  end/)
        end
        yield( name, $1 ) if block_given?
      end
    end
    
    def app_root_files
      Dir[APP_ROOT + '/**/*']
    end

    def rubygem_folders
      %w[bin examples lib test]
    end
  
    def rubygems_setup
      bare_setup
      rubygem_folders.each do |folder|
        Dir.mkdir("#{APP_ROOT}/#{folder}") unless File.exists?("#{APP_ROOT}/#{folder}")
      end
    end
  
    def rubygems_teardown
      bare_teardown
    end
  
    def bare_setup
      FileUtils.mkdir_p(APP_ROOT)
    end
  
    def bare_teardown
      FileUtils.rm_rf TMP_ROOT || APP_ROOT
    end
  
  end
end
