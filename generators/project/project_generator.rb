require 'rubygems'
require 'rubigen'
class ProjectGenerator < RubiGen::Base
  default_options :author => nil
  attr_reader :name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    @name = args.shift
    extract_options
  end

  def manifest
    record do |m|    
      create_directories(m)
      m.template "gemfile.rb.erb", "Gemfile"
      m.template "local_config.rb.erb", "config.txt"
      m.template "configuration.rb.erb", File.join("lib/#{name}","configuration.rb")
      m.template "project.rb.erb", File.join("lib","#{name}.rb")
      m.template "sample_controller.rb.erb", File.join("lib/#{name}/workflows/sample", "sample_controller.rb")
      m.template "sample_model.rb.erb", File.join("lib/#{name}/workflows/sample","sample_model.rb")
      m.template "sample_view.rb.erb", File.join("lib/#{name}/workflows/sample","sample_view.rb")
      m.template "sample_spec.rb.erb", File.join("spec","sample_spec.rb")
    end
  end

  def create_directories(m)
    BASEDIRS.each { |path| m.directory path }
    m.directory File.join('lib',@name)
    m.directory File.join('lib',@name, 'workflows')
    m.directory File.join('lib',@name, 'workflows', 'sample')
  end
  
  protected
    def banner
      <<-EOS
USAGE: #{spec.name} path/for/your/test/project project_name [options]
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
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end

    # Installation skeleton.  Intermediate directories are automatically
    # created so don't sweat their absence here.
    BASEDIRS = %w(
      lib
      spec
      feature
    )
end