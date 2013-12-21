require 'spec_helper'

describe CustomAttribute do

  let(:custom_attribute) do
    foo = foos(:foo_1)
    bar = bars(:bar_1)
    custom_column = CustomColumn.create!(:name => 'column1', :caption => 'Column 1', :customizing => foo)
    CustomAttribute.create!(:customized => bar, :column => custom_column)
  end

  it "should create a new instance given valid attributes" do
    custom_attribute.should_not be_nil
    custom_attribute.should_not be_new_record
  end


  it "should be created when customizable model's association is loaded" do
    foo = Foo.create!(:name => "Foo 3")
    foo.custom_columns.create!(:name => 'column1', :caption => 'Column 1')
    bar = Bar.create!(:foo => foo, :name => "Bar 3")
    foo.should have(1).custom_columns
    bar.custom_attributes(true)
    bar.save
    bar.should have(1).custom_attributes
  end

  it "should be created when customizing model defines new custom columns" do
    foo = Foo.create!(:name => "Foo 3")
    foo.custom_columns.create!(:name => 'column1', :caption => 'Column 1')
    bar = Bar.create!(:foo => foo, :name => "Bar 3")
    bar.custom_attributes.length.should == 1
    bar.save
    foo.custom_columns.create!(:name => 'column2', :caption => 'Column 2')
    bar = Bar.find(bar.id)
    bar.custom_attributes.length.should == 2
  end

  it "should be created when customizing model defines new custom columns and associations are preloaded" do
    foo = Foo.create!(:name => "Foo 3")
    foo.custom_columns.create!(:name => 'column1', :caption => 'Column 1')
    bar = Bar.create!(:foo => foo, :name => "Bar 3")
    bar.custom_attributes.length.should == 1
    bar.save
    foo.custom_columns.create!(:name => 'column2', :caption => 'Column 2')
    bar = Bar.find(bar.id, :include => {:custom_attributes => :column})
    bar.custom_attributes.length.should == 2
  end
end
