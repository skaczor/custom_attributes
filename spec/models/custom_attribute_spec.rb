require 'spec_helper'

describe CustomAttribute do

  let(:custom_attribute) { CustomAttribute.create!(:customized_id => 1, :customized_type => "CustomizedModel",
      :column => CustomColumn.create!(:name => 'Column1', :customizing_id => 1, :customizing_type => 'SomeModel')) }

  it "should create a new instance given valid attributes" do
    custom_attribute.should_not be_nil
    custom_attribute.should_not be_new_record
  end

end
