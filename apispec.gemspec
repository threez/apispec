$:.push('lib')
require "apispec/version"

Gem::Specification.new do |s|
  s.name        = 'apispec'
  s.version     = APISpec::VERSION.dup
  s.date        = Time.now("%Y-%M-%d")
  s.summary     = "A ruby based http/rest documentation generator"
  s.email       = "vilandgr+github@googlemail.com"
  s.homepage    = "http://github.com/threez/apispec/"
  s.authors     = ['Vincent Landgraf']
  s.description = "A documentation generator for http/rest"
  
  dependencies = [
    [:runtime,     "RedCloth", "~> 4.2.7"],
    [:runtime,     "coderay",  "~> 0.9.7"],
    [:development, "rspec",    "~> 2.1"],
  ]
  
  s.files         = Dir['**/*']
  s.test_files    = Dir['test/**/*'] + Dir['spec/**/*']
  s.executables   = Dir['bin/*'].map { |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  
  ## Make sure you can build the gem on older versions of RubyGems too:
  s.rubygems_version = APISpec::VERSION.dup
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 3 if s.respond_to? :specification_version
  
  dependencies.each do |type, name, version|
    if s.respond_to?("add_#{type}_dependency")
      s.send("add_#{type}_dependency", name, version)
    else
      s.add_dependency(name, version)
    end
  end
end
