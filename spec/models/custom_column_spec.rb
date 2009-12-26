require 'spec_helper'

describe CustomColumn do

  let(:custom_column) { CustomColumn.create!(:name => 'Column1', :customizing_id => 1, :customizing_type => 'SomeModel') }

  it "should create a new instance given valid attributes" do
    custom_column.should_not be_nil
    custom_column.should_not be_new_record
  end

end
