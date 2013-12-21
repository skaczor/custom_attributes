require 'rake'
require 'rdoc/task'
require 'spec/rake/spectask'
require 'rubygems'

desc 'Default: run unit tests.'
task :default => :all

desc 'Prepare database and run specs'
task :all => [:db, :spec]

desc 'Prepare testing database'
task :db do
  load(File.dirname(__FILE__) + "/spec/schema.rb")
  establish_connection
  load_schema
end

desc 'Test the custom_attributes plugin.'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.warning = false
  t.rcov = false
end

desc 'Generate documentation for the custom_attributes plugin.'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'CustomAttributes'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
