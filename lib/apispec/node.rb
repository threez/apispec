class APISpec::Node
  attr_accessor :parent
  attr_reader :name
  
  def initialize(name, &block)
    @name = name
    instance_eval(&block) if block_given?
  end
  
  def to_s
    "#{self.class.name.gsub("APISpec::", "")} #{@name}"
  end
  
  def node_path
    @name ? "#{@name.downcase}" : "apispec"
  end
  
  def root?
    @parent.nil?
  end
  
  def full_name
    namespace = @name
    current_parent = self.parent
    while current_parent
      break if current_parent.root?
      namespace = "#{current_parent.name}.#{namespace}"
      current_parent = current_parent.parent
    end
    namespace
  end
  
  # walk the tree up and return a complete path to the node
  def to_path
    namespace = node_path
    current_parent = self.parent
    while current_parent
      break if current_parent.root?
      namespace = File.join(current_parent.node_path, namespace)
      current_parent = current_parent.parent
    end
    "#{namespace}.html"
  end

  def to_html(generator)
    @generator = generator
    if self.respond_to? :resolve_references!
      resolve_references!(generator.namespace)
    end
    generator.template(binding, self.class.name.downcase.gsub("apispec::", ""))
  end
end
