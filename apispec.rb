require 'rubygems'
require 'erb'
require 'coderay'

module APISpec
  HTTP_STATUS_CODES = {
    100 => "Continue",
    101 => "Switching Protocols",
    102 => "Processing",
    200 => "OK",
    201 => "Created",
    202 => "Accepted",
    203 => "Non-Authoritative Information",
    204 => "No Content",
    205 => "Reset Content",
    206 => "Partial Content",
    207 => "Multi-Status",
    226 => "IM Used",
    300 => "Multiple Choices",
    301 => "Moved Permanently",
    302 => "Found",
    303 => "See Other",
    304 => "Not Modified",
    305 => "Use Proxy",
    307 => "Temporary Redirect",
    400 => "Bad Request",
    401 => "Unauthorized",
    402 => "Payment Required",
    403 => "Forbidden",
    404 => "Not Found",
    405 => "Method Not Allowed",
    406 => "Not Acceptable",
    407 => "Proxy Authentication Required",
    408 => "Request Timeout",
    409 => "Conflict",
    410 => "Gone",
    411 => "Length Required",
    412 => "Precondition Failed",
    413 => "Request Entity Too Large",
    414 => "Request-URI Too Long",
    415 => "Unsupported Media Type",
    416 => "Requested Range Not Satisfiable",
    417 => "Expectation Failed",
    422 => "Unprocessable Entity",
    423 => "Locked",
    424 => "Failed Dependency",
    426 => "Upgrade Required",
    500 => "Internal Server Error",
    501 => "Not Implemented",
    502 => "Bad Gateway",
    503 => "Service Unavailable",
    504 => "Gateway Timeout",
    505 => "HTTP Version Not Supported",
    507 => "Insufficient Storage",
    510 => "Not Extended"
  }
  
  class Example
    def initialize(format, example)
      @format = format
      @example = example
    end
    
    def to_html(message)
      CodeRay.scan(@example, @format).div
    end
  end

  class Field
    # default type is String and field is not optional
    def initialize(&block)
      @optional = false
      @type = String
      instance_eval(&block)
    end
  
    def name(value)
      @name = value
    end
  
    def type(value)      
      @type = value
    end
  
    def desc(value)
      @desc = value
    end
  
    def default(value)
      @default = value
    end
  
    def optional(value)
      @optional = value
    end
  
    def example(value)
      @example = value
    end
    
    def to_html(message)
      Generator.template(binding, :field)
    end
  end

  class Object
    def initialize(&block)
      @fields = []
      instance_eval(&block)
    end

    def name(value)
      @name = value
    end

    def desc(value)
      @desc = value
    end
  
    def fields(*value)
      @fields = value
    end
  
    def example(format, value)
      @example = Example.new(format, value)
    end

    def to_html(message)
      Generator.template(binding, :object)
    end

    def to_s
      @name
    end

    def to_path
      "Object #{@name}.html"
    end
  end
  
  class Message
    def initialize(&block)
      instance_eval(&block)
    end

    def headers(*value)
      @headers = value
    end

    def params(*value)
      @parameters = value
    end

    def desc(value)
      @desc = value
    end
    
    def content(value)
      @content = value
    end

    def example(format, value)
      @example = Example.new(format, value)
    end
    
    def to_html(resource)
      @resource = resource
      Generator.template(binding, :message)
    end
  end

  class Resource
    def initialize(method, path, &block)
      @method = method
      @path = path
      @response = {}
      instance_eval(&block)
    end
  
    def desc(value)
      @desc = value
    end
    
    def request(&block)
      @request = Message.new(&block)
    end
    
    def response(http_code = 200, &block)
      @response[http_code] = Message.new(&block)
    end
    
    def highlighted_path
      "#{@interface.base_uri}/#{@path}".gsub(/:[^\/0-9][^\/]*/) do |value|
        "<span class=\"parameter\">#{value}</span>"
      end
    end
    
    def to_html(interface)
      @interface = interface
      Generator.template(binding, :resource)
    end
  end

  class Interface
    def initialize(&block)
      @resources = []
      instance_eval(&block)
    end

    def name(value)
      @name = value
    end

    def base_uri(value = nil)
      @base_uri ||= value
    end

    def get(path, &block)
      http(:get, path, &block)
    end

    def put(path, &block)
      http(:put, path, &block)
    end

    def post(path, &block)
      http(:post, path, &block)
    end

    def delete(path, &block)
      http(:delete, path, &block)
    end
  
    def http(method, path, &block)
      resource = Resource.new(method, path, &block)
      @resources << resource
    end
    
    def to_html(generator)
      Generator.template(binding, :interface)
    end
    
    def to_s
      @name
    end
    
    def to_path
      "Interface #{@name}.html"
    end
  end
  
  module Generator
    def self.template(object, template_path)
      template = ERB.new(File.read("templates/#{template_path}.html.erb"))
      template.result(object)
    end
  
    def self.create(path, htmlable)
      File.open("#{path}/#{htmlable.to_path}", "w") do |file|
        file.write(htmlable.to_html(self))
      end
    end
    
    def self.frame(root_path, interfaces, objects)
      puts "API Specification Documentation Generator"
      puts("=" * 50)
      puts " * create folders and move static rescoures..."
      rm_rf "#{root_path}/*"
      mkdir_p root_path
      cp "templates/style.css", root_path
      cp "templates/links.css", root_path
      cp "templates/stripe.png", root_path
      @first_interface = interfaces.first
      @interfaces = interfaces
      @objects = objects
      puts " * create index frame..."
      File.open("#{root_path}/index.html", "w") do |file|
        file.write(template(binding, :index))
      end
      puts " * create links page..."
      File.open("#{root_path}/links.html", "w") do |file|
        file.write(template(binding, :links))
      end
      puts " * create interfaces..."
      for interface in interfaces do
        puts " ** interface #{interface}..."
        create root_path, interface
      end
      puts " * create objects..."
      for object in objects do
        puts " ** object #{object}..."
        create root_path, object
      end
      puts " * done"
    end
    
    def self.rm_rf(path)
      system "rm -rf #{path}"
    end
    
    def self.mkdir_p(path)
      system "mkdir -p #{path}"
    end
    
    def self.cp(from, to)
      system "cp #{from} #{to}"
    end
  end
end