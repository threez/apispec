class APISpec::Interface < APISpec::Node
  def initialize(name, &block)
    @resources = []
    super(name, &block)
  end

  def base_uri(value = nil)
    @base_uri ||= value
  end
  
  def get(path, &block);      http(:get, path, &block);     end
  def put(path, &block);      http(:put, path, &block);     end
  def post(path, &block);     http(:post, path, &block);    end
  def delete(path, &block);   http(:delete, path, &block);  end
  def options(path, &block);  http(:options, path, &block); end
  def head(path, &block);     http(:head, path, &block);    end
  def trace(path, &block);    http(:trace, path, &block);   end
  def connect(path, &block);  http(:connect, path, &block); end

  def http(method, path, &block)
    @resources << APISpec::Resource.new(method, path, &block)
  end
  
  def resolve_references!(root_namespace)
    @resources.each do |resource|
      resource.resolve_references!(root_namespace)
    end
  end
end
