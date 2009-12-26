class CreateCustomColumns < ActiveRecord::Migration
  def self.up
    create_table :custom_columns do |t|
      t.references :customizing, :polymorphic => true
      t.string :name
      t.integer :position

    end
  end

  def self.down
    drop_table :custom_columns
  end
end
