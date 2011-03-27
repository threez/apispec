require "logger"
require "fileutils"

class APISpec::Generator
  attr_reader :namespace, :logger
  
  def initialize(options)
    @options = options
    # logging
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN unless options[:verbose]
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime("%Y-%m-%d %H:%M:%S")} [#{severity}]: #{msg}\n"
    end
    @namespace = APISpec::Namespace.new(nil)
  end
  
  # returns the dir with the root based in the working directory
  def path(dir)
    File.join(@options[:workspace], dir)
  end
  
  # read all ruby files that can be found in the working directory
  def parse_files!
    @logger.info "parse all files"
    Dir[File.join(@options[:workspace], "**", "*.rb")].each do |path|
      logger.info "read file #{path}..."
      @namespace.read_file(path)
    end
  end
  
  # creates the output folder
  def create_output_folder!
    @logger.info "remove and create the output folder"
    FileUtils.rm_rf "#{@options[:output]}"
    FileUtils.mkdir_p @options[:output]
  end
  
  # create the index frame
  def create_index!
    @logger.info "create index frame"
    File.open(File.join("#{@options[:output]}", "index.html"), "w") do |file|
      file.write(template(binding, :index))
    end    
  end
  
  # create the links page (left part of frame)
  def create_links!
    @logger.info "create links page"
    File.open(File.join("#{@options[:output]}", "links.html"), "w") do |file|
      file.write(template(binding, :links))
    end
  end
  
  # create the documentation files itself
  def create_objects_and_interfaces!
    @namespace.objects.each do |object|
      create(object)
    end
    @namespace.interfaces.each do |interface|
      create(interface)
    end
  end
  
  # create the resources for all subfolders and main folder
  def create_resources!
    Dir[File.join(@options[:output], "**/*")].map do |path|
      File.dirname(File.expand_path(path))
    end.uniq.each do |path|
      @logger.info "copy template resources to #{path}"
      FileUtils.cp Dir[File.join(@options[:resource], "*")], path
    end
  end
  
  # start the generator
  def start!
    parse_files!
    create_output_folder!
    create_index!
    create_links!
    create_objects_and_interfaces!
    create_resources!
  end

  # render a template with the passed object as binding
  def template(object, template_name)
    path = File.join(@options[:template], "#{template_name}.html.erb")
    erb = ERB.new(File.read(path))
    erb.filename = path
    erb.result(object)
  end

  # create a doc file for the passed node
  def create(node)
    dir = File.dirname(node.to_path)
    file_name = File.basename(node.to_path)
    path = File.join("#{@options[:output]}", dir)
    FileUtils.mkdir_p path
    File.open(File.join(path, file_name), "w") do |file|
      @logger.info "create page for #{node}"
      file.write(node.to_html(self))
    end
  end
end
