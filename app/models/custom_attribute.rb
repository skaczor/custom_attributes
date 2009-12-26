class CustomAttribute < ActiveRecord::Base
  belongs_to :column, :class_name => 'CustomColumn'
end
