require "rubygems"
require "spec/rake/spectask"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = Dir.glob('spec/**/*_spec.rb')
  t.spec_opts << '--diff --format d'
  #t.rcov = true
end

task :default => :spec