require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/field'

module Net ; module DND
  
  describe Field, "created normally" do
    before :each do
      @name, @write, @read = %w(nickname U A)
      @field = Field.new(@name, @write, @read)
    end
    
    it "should properly set the writeable flag" do
      expect(@field.writeable).to eq @write
    end
    
    it "should properly set the readable flag" do
      expect(@field.readable).to eq @read
    end
    
    it "should report as readable by all if readable value is 'A'" do
      expect(@field).to be_read_all
    end
    
    it "should report back the proper name" do
      expect(@field.name).to eq @name
    end
    
    it "should report back the proper inspection string" do
      expect(@field.inspect).to match(/<Net::DND::Field name=".*" writeable="[AUNT]" readable="[AUNT]">/)
    end
    
    it "should return the name when coerced to a string" do
      expect(@field.to_s).to eq @name
    end
    
    it "should return :name when coerced to a symbol" do
      expect(@field.to_sym).to eq @name.to_sym
    end
    
    it "should not report as readable by all if readable value is not 'A'" do
      @read = "T"
      @field = Field.new(@name, @write, @read)
      expect(@field).not_to be_read_all
    end
    
  end
  
  describe Field, "created using from_field_line with a proper line format" do

    before(:each) do
      @values = %w(nickname U A)
      line = @values.join(" ")
      @field = Field.from_field_line(line)
    end

    it "should have the correct name" do
      expect(@field.name).to eq @values[0]
    end

    it "should have to correct readable value" do
      expect(@field.readable).to eq @values[2]
    end
  end
  
  describe Field, "created using from_field_line with an improper line format" do
    it "should raise the proper error" do
      line = "This is a bad field line"
      expect { Field.from_field_line(line) }.to raise_error(FieldLineInvalid)
    end
  end
  
end ; end