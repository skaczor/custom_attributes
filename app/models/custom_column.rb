class CustomColumn < ActiveRecord::Base

  belongs_to :parent, :class_name => "CustomColumn"
  has_many :children, :class_name => "CustomColumn", :foreign_key => :parent_id,
    :dependent => :destroy
  belongs_to :customizing, :polymorphic => true
  has_many :values, :class_name => 'CustomAttributeValue', :foreign_key => :column_id, 
    :dependent => :delete_all, :order => :value
  accepts_nested_attributes_for :values, :allow_destroy => true

  acts_as_list :column => :position, :scope => :customizing

  before_validation :set_position

  validates_presence_of :name
  validates_presence_of :caption
  validates_format_of :name, :with => /^[_a-z]{1}[_a-z0-9]*$/,
    :message => "can contain only lowercase letters, numbers and '_'. Cannot start with a number."

  def all_values
    (parent ? parent.values : []) + values
  end
  def to_s
    caption
  end

private
  def set_position
    unless position
      self.position = CustomColumn.count(:conditions => {
          :customizing_id => self.customizing.id,
          :customizing_type => self.customizing.class.name } ) + 1
    end
  end
end
