require 'rubygems'
require 'ap'
require 'erb'
require 'coderay'

module APISpec
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
      Generator.template(binding, "field.html.erb")
    end
  end

  class Object
    def initialize(&block)
      instance_eval(&block)
    end

    def name(value)
      @name = value
    end
  
    def fields(*value)
      @fields = value
    end
  
    def example(format, value)
      @example = Example.new(format, value)
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
      @params = value
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
      Generator.template(binding, "message.html.erb")
    end
  end

  class Resource
    def initialize(method, path, &block)
      @method = method
      @path = path
      instance_eval(&block)
    end
  
    def desc(value)
      @desc = value
    end
    
    def request(&block)
      @request = Message.new(&block)
    end
    
    def response(&block)
      @response = Message.new(&block)
    end
    
    def highlighted_path
      "#{@interface.base_uri}/#{@path}".gsub(/:[^\/]+/) do |value|
        "<span class=\"parameter\">#{value}</span>"
      end
    end
    
    def to_html(interface)
      @interface = interface
      Generator.template(binding, "resource.html.erb")
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
  
    def http(method, path, &block)
      resource = Resource.new(method, path, &block)
      @resources << resource
    end
    
    def to_html
      Generator.template(binding, "interface.html.erb")
    end
  end
  
  module Generator
    def self.template(object, template_path)
      template = ERB.new(File.read("templates/#{template_path}"))
      template.result(object)
    end
  
    def self.create(path, interface)
      ap interface
      
      File.open(path, "w") do |file|
        file.write(interface.to_html)
      end
    end
  end
end