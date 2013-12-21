class CustomAttributesMigrationGenerator < Rails::Generator::Base 

  def manifest 
    record do |m|
      m.migration_template "migrate/create_custom_attributes.rb", 
      "db/migrate", {  :migration_file_name => 'create_custom_attributes' } 
    end 
  end 
#
#  private 
#
#  def custom_file_name 
#    custom_name = class_name.underscore.downcase 
#    custom_name = custom_name.pluralize if ActiveRecord::Base.pluralize_table_names 
#    custom_name 
#  end 
#
#  def custom_attributes_local_assigns {}.tap do |assigns| 
#      assigns[:migration_action] = "add" 
#      assigns[:class_name] = "add_custom_attributes_fields_to_#{custom_file_name}" 
#      assigns[:table_name] = custom_file_name 
#      assigns[:attributes] = [Rails::Generator::GeneratedAttribute.new("last_squawk", "string")] 
#    end 
#  end 
end
