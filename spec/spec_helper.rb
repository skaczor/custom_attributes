ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

require 'rubygems'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))
require 'spec/rails'
require File.dirname(__FILE__) + '/../rails/init.rb'
require File.dirname(__FILE__) + '/../lib/customizable.rb'

require File.dirname(__FILE__) + '/schema.rb'
establish_connection

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = false
  config.use_instantiated_fixtures  = true
  config.fixture_path = File.dirname(__FILE__) + '/fixtures/'

  config.global_fixtures = :foos, :bars

  config.before(:all) do 
  end
end

class Bar
  include Customizable
  has_custom_attributes_based_on(:foo)
end

class Foo
  include Customizable
  defines_custom_columns
end
