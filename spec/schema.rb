ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))
require 'yaml'


def establish_connection
  config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

  db_adapter = ENV['DB']

  db_adapter ||= 
    begin
      require 'rubygems'
      require 'sqlite3'
      'sqlite3'
    rescue MissingSourceFile
    end

  if db_adapter.nil?
    raise "No DB Adapter selected and sqlite3 is not installed"
  end

  ActiveRecord::Base.establish_connection(config[db_adapter])
end

def load_schema
  conn = ActiveRecord::Base.connection
  conn.tables.each { |t| conn.execute("DROP TABLE #{t}") }
  load(File.dirname(__FILE__) + "/schema.db")
  plugin_migrations = File.dirname(__FILE__) + "/../db/migrate"
  Dir[File.expand_path(File.join(plugin_migrations,'*.rb'))].each do |f|
    classes = require(f)
    classes.first.constantize.up
  end
end
