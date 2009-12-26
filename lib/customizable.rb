# Extends a model to allow custom attributes only for certain records
# The set of custom attributes is defined based on the association to the meta model that defines
# custom columns.
module Customizable
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def has_custom_attributes_based_on(association_name)
      return if self.included_modules.include?(Customizable::InstanceMethods)
      cattr_accessor :customizing_association_name
      self.customizing_association_name = association_name
      has_many :custom_attribute_records, 
        :as => :customized,
        :class_name => 'CustomAttribute',
        :include => :column,
        :dependent => :delete_all

      before_update :cleanse_custom_attributes
      after_update :save_custom_attributes
      send :include, Customizable::InstanceMethods
    end

    def defines_custom_columns
      has_many :custom_columns, :as => :customizing,
        :order => :position,
        :dependent => :delete_all
    end
  end

  module InstanceMethods

    def custom_columns
      customizing_model = self.send(self.class.customizing_association_name)
      return [] unless customizing_model && customizing_model.respond_to?(:custom_columns)
      customizing_model.custom_columns
    end

    def custom_attributes
      @custom_attributes ||= custom_columns.map do |c|
        custom_attribute_records.detect { |a| a.column == c } ||
        custom_attribute_records.build(:column => c, :value => nil)
      end
    end
    
    def custom_attributes=(values)
      values.stringify_keys!
      values.assert_valid_keys(custom_attributes.map{ |a| a.column.name })
      values.each do |key, value|
        attribute = custom_attributes.find { |a| a.column.name == key }
        attribute.value = value
      end
    end

    def reload_custom_attributes
      @custom_attributes = nil
    end

    # Deletes attributes no longer associated with this model
    def cleanse_custom_attributes
      return if custom_columns.empty?
      custom_column_ids = custom_columns.map { |c| c.id }
      CustomAttribute.delete_all([ "customized_id = ? AND customized_type = ? AND column_id NOT IN (#{custom_column_ids.join(',')})",
        self.id, self.class.name ])
      custom_attributes.each { |a| a.save! }
    end

    def save_custom_attributes
      custom_attributes.each { |a| a.save! }
    end
  end
    
end
