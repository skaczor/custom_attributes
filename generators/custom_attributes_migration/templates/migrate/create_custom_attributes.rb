class CreateCustomAttributes < ActiveRecord::Migration
  def self.up
    create_table :custom_columns do |t|
      t.references :customizing, :polymorphic => true
      t.string :name
      t.string :caption
      t.integer :position
      t.references :parent
      t.index :customizing_id, :customizing_type
    end

    create_table :custom_attribute_values do |t|
      t.references :column
      t.string :caption
      t.integer :value
      t.index :column_id
    end

    create_table :custom_attributes do |t|
      t.references :customized, :polymorphic => true
      t.references :column
      t.string :value
      t.index :customized_id, :customized_type
    end
  end

  def self.down
    drop_table :custom_attributes
    drop_table :custom_attribute_values
    drop_table :custom_columns
  end
end
