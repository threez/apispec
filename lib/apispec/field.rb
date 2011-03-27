class APISpec::Field < APISpec::Node  
  # default type is String and field is not optional
  def initialize(name, &block)
    @optional = false
    @nullable = false
    @type = :string
    super(name, &block)
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

  def nullable(value)
    @nullable = value
  end

  def example(value)
    @example = value
  end
  
  def resolve_references!(root_namespace)
    @type = root_namespace.find_object(@type) if @type.is_a? String
  end
end
