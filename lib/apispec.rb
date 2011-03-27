require 'erb'

begin
  require 'coderay'
  require 'redcloth'
rescue LoadError
  require 'rubygems'
  require 'coderay'
  require 'redcloth'
end

%w(http version example node field object message resource 
   interface namespace generator).each do |name|
  require File.join(File.dirname(__FILE__), "apispec", name)
end
