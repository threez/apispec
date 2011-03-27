class APISpec::Message
  def initialize(&block)
    @headers = []
    @parameters = []
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
  
  def object(value)
    @object = value
  end
  
  def array(value)
    @array = value
  end
  
  def content_desc(value)
    @content_desc = value
  end

  def example(format, value)
    @example = APISpec::Example.new(format, value)
  end
  
  def example_file(format, path)
    @example = [format, path]
  end
  
  def resolve_references!(root_namespace)
    @headers    = @headers.map    { |name| root_namespace.find_field(name) }.flatten
    @parameters = @parameters.map { |name| root_namespace.find_field(name) }.flatten
    @object     = root_namespace.find_object(@object) if @object
    @array      = root_namespace.find_object(@array) if @array
  end
  
  def to_html(generator, resource)
    @generator = generator
    @resource = resource
    if @example.is_a? Array
      format, path = @example
      @example = APISpec::Example.new(format, File.read(@generator.path(path)))
    end
    generator.template(binding, :message)
  end
end
