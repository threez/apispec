class APISpec::Example
  def initialize(format, example)
    @format = format
    @example = example
  end
  
  def to_html(message)
    CodeRay.scan(@example, @format).div
  end
end
