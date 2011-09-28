class APISpec::Resource
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
    @request = APISpec::Message.new(&block)
  end
  
  def response(http_code = 200, &block)
    @response[http_code] = APISpec::Message.new(&block)
  end
  
  def uid
    "#{@method}-#{@path}".gsub(/[^a-zA-Z0-9]/, "-").gsub(/[-]+/, "-")
  end
  
  def highlighted_path
    "#{@interface.base_uri}/#{@path}".gsub(/:[^\/0-9][^\/&\?]*/) do |value|
      "<span class=\"parameter\">#{value}</span>"
    end
  end
  
  def resolve_references!(root_namespace)
    @request.resolve_references!(root_namespace) if @request
    @response.values.each do |response|
      response.resolve_references!(root_namespace)
    end
  end
  
  def to_html(generator, interface)
    @interface = interface
    @generator = generator
    generator.template(binding, :resource)
  end
end
