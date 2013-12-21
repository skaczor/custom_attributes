require 'spec_helper'

describe CustomColumn do

  let(:custom_column) do
    CustomColumn.create!(:name => 'column1', :caption => 'Column 1', :customizing => foos(:foo_1))
  end

  it "should create a new instance given valid attributes" do
    custom_column.should_not be_nil
    custom_column.should_not be_new_record
  end

  it "should have a list of valid values" do
    custom_column.values.create(:caption => "value 1", :value => 1)
    custom_column.values.create(:caption => "value 2", :value => 2)
    custom_column.values(true)
    custom_column.should have(2).values
  end

  it "should allow children" do
    child = CustomColumn.create!(:name => 'column1', :caption => 'Column 1', :customizing => foos(:foo_2))
    child.parent = custom_column
    child.save
    child.parent.should == custom_column
    custom_column.children(true)
    custom_column.should have(1).children
  end

  it "should include parent's valid values" do
    custom_column.values.create(:caption => "value 1", :value => 1)
    custom_column.values.create(:caption => "value 2", :value => 2)
    child = CustomColumn.create!(:name => 'column1', :caption => 'Column 1', :customizing => foos(:foo_2))
    child.values.create(:caption => "value 1", :value => 1)
    child.values.create(:caption => "value 2", :value => 2)
    child.parent = custom_column
    child.save
    child.should have(4).all_values
  end

end
