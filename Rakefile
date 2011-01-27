require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
require 'rspec/core/rake_task'

GEM = 'early-flusher'
GEM_NAME = 'Early Flusher'
GEM_VERSION = '0.0.1'
AUTHORS = ['Alejandro Crosa']
EMAIL = "alejandrocrosa@gmail.com"
HOMEPAGE = "http://github.com/acrosa/early-flusher"
SUMMARY = "Plugin to support a block-like syntax in sinatra and perform early flushing of content"
DESCRIPTION = "Plugin to support a block-like syntax in sinatra and perform early flushing of content"

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["LICENSE"]
  s.summary = SUMMARY
  s.description = DESCRIPTION
  s.authors = AUTHORS
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_development_dependency "rspec"
  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(LICENSE README.md Rakefile) + Dir.glob("{lib,tasks,spec}/**/*")
end

task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM_NAME}-#{GEM_VERSION}}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

desc "Run all examples with RCov"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = true
end
