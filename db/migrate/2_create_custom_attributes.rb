class CreateCustomAttributes < ActiveRecord::Migration
  def self.up
    create_table :custom_attributes do |t|
      t.references :customized, :polymorphic => true
      t.references :column
      t.string :value
    end
  end

  def self.down
    drop_table :custom_attributes
  end
end
