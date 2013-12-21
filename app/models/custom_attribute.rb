class CustomAttribute < ActiveRecord::Base
  belongs_to :column, :class_name => 'CustomColumn'
  belongs_to :customized, :polymorphic => true

  validates_presence_of :column_id
  validates_presence_of :customized_id, :unless => 'new_record?'
  validates_presence_of :customized_type, :unless => 'new_record?'

  def to_s
    value
  end
end
