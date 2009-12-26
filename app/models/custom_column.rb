class CustomColumn < ActiveRecord::Base
  belongs_to :customizing, :polymorphic => true

  before_validation :set_position

private
  def set_position
    unless position
      self.position = CustomColumn.count(:conditions => {
          :customizing_id => self.customizing.id,
          :customizing_type => self.customizing.class.name } ) + 1
    end
  end
end
