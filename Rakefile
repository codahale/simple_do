require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require "spec/rake/spectask"

GEM = "simple_do"
GEM_VERSION = "1.0.0"
AUTHOR = "Coda Hale"
EMAIL = "coda.hale@gmail.com"
HOMEPAGE = "http://github.com/codahale/simple_do"
SUMMARY = "A simple wrapper for DataObjects."

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency "data_objects"
  s.add_dependency "addressable"
  
  s.require_path = 'lib'
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,specs}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end

desc "create a gemspec file"
task :make_gemspec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

desc "run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
  t.spec_opts = ["--options", "spec/spec.opts"]
end