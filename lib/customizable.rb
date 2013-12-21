# Extends a model to allow custom attributes only for certain records
# The set of custom attributes is defined based on the association to the meta model that defines
# custom columns.
module Customizable
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def has_custom_attributes_based_on(association_name, options = {})
      return if self.included_modules.include?(Customizable::InstanceMethods)

      cattr_accessor :customizing_association_name, :custom_attributes_options

      self.customizing_association_name = association_name

      options[:auto_create] = true unless options.has_key?(:auto_create)
      self.custom_attributes_options = options

      has_many :custom_attributes,
        :as => :customized,
        :include => :column,
        :order => 'custom_columns.position',
        :dependent => :delete_all do

        # Add missing attributes
        def populate
          return if @populated
          return unless @owner.class.custom_attributes_options[:auto_create]
          @target ||= []
          @owner.custom_columns.each do |c|
            unless @target.detect { |a| a.column_id == c.id }
              @target << CustomAttribute.new(:customized => @owner, :column => c, :value => nil)
            end
          end
          @populated = true
        end

        # Used to indicate that collection needs to be repopulated at the next access
        def repopulate
          @populated = false
        end

        # Delete obsolete attributes
        def trim_obsolete
          return if @trimmed
          return unless @target
          to_delete = @target.find_all do |a|
            !@owner.customizing_model.custom_column_ids.include?(a.column_id)
          end
          delete(to_delete) if to_delete.any?
          @trimmed = true
        end

        def trim_duplicates
          return unless @target
          column_ids = @target.reject{ |a| a.new_record? }.map(&:column_id)
          @target.reject! do |a|
            a.new_record? && column_ids.include?(a.column_id) 
          end
        end

        # Overriding active record method to:
        #   - Populate new attributes
        #   - Purge obsolete attributes
        def load_target
          if !@owner.new_record? || foreign_key_present
            begin
              if !loaded?
                if @target.is_a?(Array) && @target.any?
                  @target = find_target.map do |f|
                    i = @target.index(f)
                    t = @target.delete_at(i) if i
                    j = @target.index{ |t| t.column_id == f.column_id }
                    @target.delete_at(j) if j
                    if t && t.changed?
                      t
                    else
                      f.mark_for_destruction if t && t.marked_for_destruction?
                      f
                    end
                  end + @target.find_all {|t| t.new_record?}
                else
                  @target = find_target
                end
              end
            rescue ActiveRecord::RecordNotFound
              reset
            end
          end
          loaded if target
          populate
          trim_obsolete
          target
        end

        def target
          populate
          trim_obsolete
          trim_duplicates
          @target
        end

      end
      
      accepts_nested_attributes_for :custom_attributes, :allow_destroy => true,
        :reject_if => proc { |attributes| attributes[:value].nil? }

      send :include, Customizable::InstanceMethods

      before_save :cleanse_custom_attributes
      after_save :reset_populated_flag
    end

    def defines_custom_columns(options = {})
      has_many :custom_columns, :as => :customizing,
        :order => :position,
        :dependent => :delete_all
      if options[:accepts_nested_attributes]
        accepts_nested_attributes_for :custom_columns, :allow_destroy => true,
          :reject_if => proc { |columns| columns[:name].nil? }
      end
    end

  end

  module InstanceMethods

    def clone
      cloned = super
      custom_attributes.each do |attribute|
        cloned.custom_attributes.build(:column => attribute.column, :value => attribute.value)
      end
      cloned
    end

    def customizing_model(reload=false)
      @customizing_model = nil if reload
      @customizing_model ||= self.send(self.class.customizing_association_name)
    end

    def custom_columns
      return [] unless customizing_model && customizing_model.respond_to?(:custom_columns)
      customizing_model.custom_columns
    end

    def custom_column_ids
      return [] unless customizing_model && customizing_model.respond_to?(:custom_column_ids)
      customizing_model.custom_column_ids
    end

    def custom_column(name)
      custom_columns.detect { |c| c.name == name }
    end

    def custom_attributes_hash
      res = {}
      custom_attributes.each_with_index do |ca, i|
        res[i] = {:column_id => ca.column_id, :value => ca.value}
      end
      res
    end

  private

    # Deletes attributes 
    # 1. no longer associated with this record 
    # 2. that have empty values
    def cleanse_custom_attributes
      to_delete = []
      custom_attributes.each do |ca|
        if ca.value.blank? || !custom_column_ids.include?(ca.column_id)
          if ca.new_record?
            to_delete << ca
          else
            ca.mark_for_destruction
          end
        end
      end
      to_delete.each { |ca| custom_attributes.delete(ca) }
      true
    end

    def reset_populated_flag
      custom_attributes.repopulate
      true
    end

  end
    
end
