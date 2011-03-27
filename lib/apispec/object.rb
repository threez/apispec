class APISpec::Object < APISpec::Node
  def initialize(name, &block)
    @fields = []
    super(name, &block)
  end

  def desc(value)
    @desc = value
  end

  def fields(*value)
    @fields = value
  end
  
  def resolve_references!(root_namespace)
    @fields = @fields.map { |name| root_namespace.find_field(name) }.flatten
  end
  
  def example(format, value)
    @example = APISpec::Example.new(format, value)
  end
  
  def example_file(format, path)
    @example = [format, path]
  end
  
  def to_html(generator)
    if @example.is_a? Array
      format, path = @example
      @example = APISpec::Example.new(format, File.read(generator.path(path)))
    end
    super(generator)
  end
end
