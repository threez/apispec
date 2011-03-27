class APISpec::Namespace < APISpec::Node
  class AlreadyDefinedError < StandardError; end
  class ReferenceError < StandardError; end
  
  def initialize(name, &block)
    @nodes = {}
    super(name, &block)
  end
  
  # reads the passed file
  def read_file(path)
    eval(File.read(path), binding, path)
  end
  
  def find_field(path)
    result = find(path)
    if result.is_a? Array
      result.map { |path| find(path) }
    else
      [result]
    end
  end
  
  def find_object(path)
    find(path)
  end
  
  def find(path)
    path_parts = path.split(".")
    node = self
    while path_parts.any?
      node = node.find_node(path_parts.shift)
      raise ReferenceError.new("#{path} not found in #{self.to_s}") unless node
    end
    node
  end
  
  def all(method, type)
    nodes = []
    @nodes.keys.sort.each do |name|
      node = @nodes[name]
      if node.is_a? APISpec::Namespace
        nodes << node.send(method)
      elsif node.is_a? type
        nodes << node
      end
    end
    nodes.flatten
  end
  
  def interfaces
    all(:interfaces, APISpec::Interface)
  end
  
  def objects
    all(:objects, APISpec::Object)    
  end
  
  def find_node(name)
    @nodes[name]
  end
    
  def to_s
    "#{super} (Nodes: #{@nodes.size})"
  end
  
  # print the structure of all namespaces
  def print_tree(indent = 0, lines = [])
    lines << ("  " * indent) + self.to_s
    @nodes.keys.sort.each do |reference|
      node = @nodes[reference]
      if node.is_a? APISpec::Namespace
        node.print_tree(indent + 1, lines)
      else
        lines << ("  " * (indent + 1)) + "#{reference} => #{node.to_s}"
      end
    end
    lines.join("\n")
  end
  
  def namespace(name, &block)
    if node = @nodes[name]
      node.instance_eval &block
    else
      define_node name, APISpec::Namespace.new(name, &block)
    end
  end
  
  def define_node(name, node)
    raise AlreadyDefinedError.new("#{name} is already defined!") if @nodes[name]
    @nodes[name] = node
    node.parent = self if node.respond_to? :parent
  end
  
  def interface(name, reference = nil, &block)
    reference = reference || name
    define_node name, APISpec::Interface.new(name, &block)
  end
  
  def object(name, reference = nil, &block)
    reference = reference || name
    define_node reference, APISpec::Object.new(name, &block)
  end
  
  def field(name, reference = nil, &block)
    reference = reference || name
    define_node reference, APISpec::Field.new(name, &block)
  end
  
  def field_set(reference = nil, *fields)
    define_node reference, fields
  end
end
