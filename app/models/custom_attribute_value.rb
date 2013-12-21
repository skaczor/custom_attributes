class CustomAttributeValue < ActiveRecord::Base
  belongs_to :column, :class_name => 'CustomColumn'

  validates_presence_of :caption
  validates_presence_of :value
  validates_numericality_of :value
  validates_presence_of :column_id, :unless => 'new_record?'
end
