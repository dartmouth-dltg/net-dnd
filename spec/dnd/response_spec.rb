require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/response'

module Net ; module DND

  describe Response, "on initial create" do
    before(:each) do
      @socket = flexmock("TCP Socket")
      @response = Response.new(@socket)
    end

    it "should have no :code value" do
      expect(@response.code).to be_nil
    end

    it "should have no :error value" do
      expect(@response.error).to be_nil
    end

    it "should have an empty :items value" do
      expect(@response.items).to be_empty
    end
  end

  describe Response, "after create status to a good socket" do
    before(:each) do
      @socket = flexmock("TCP Socket")
      @response = Response.new(@socket)
      @socket.should_receive(:gets).once.and_return('220 DND server ready.')
      @response.status_line
    end

    it "should have a :code of 220" do
      expect(@response.code).to eq 220
    end

    it do
      expect(@response).to be_ok
    end
  end

  describe Response, "parsing a bad command" do

    before(:each) do
      @code = 501
      @msg = "unknown field name foo"
      @socket = flexmock("DND Socket after bad :fields command")
      @socket.should_receive(:gets).once.and_return("#{@code} #{@msg}\r\n")
      @response = Response.process(@socket)
    end

    it "should return a code of 501" do
      expect(@response.code).to eq @code
    end

    it "should have the appropriate error message" do
      expect(@response.error).to eq @msg
    end

    it do
      expect(@response).to_not be_ok
    end
  end

  describe Response, "parsing a :quit command" do

    before(:each) do
      @code = 200
      @msg = "Ok"
      @socket = flexmock("DND Socket after :quit command")
      @socket.should_receive(:gets).once.and_return("#{@code} #{@msg}\r\n")
      @response = Response.process(@socket)
    end

    it "should return a code of 200" do
      expect(@response.code).to eq @code
    end

    it do
      expect(@response).to be_ok
    end
  end

  describe Response, "parsing a :fields command" do

    before(:each) do
      @code = [102, 200]
      @count = 2
      @data = ['120 name N A', '120 nickname U A']
      @status = 'Done'
      @socket = flexmock("DND Socket after :fields command")
      @socket.should_receive(:gets).times(4).and_return(
          "#{@code[0]} #{@count}\r\n", "#{@data[0]}\r\n",
          "#{@data[1]}\r\n", "#{@code[1]} #{@status}\r\n")
      @response = Response.process(@socket)
    end

    it "should have a sub_count of 0" do
      expect(@response.sub_count).to eq 0
    end

    it "should have the correct number of items" do
      expect(@response.items.size).to eq 2
    end

    it "should have 'nickname' as the second item" do
      expect(@response.items[1].split[0]).to eq 'nickname'
    end

    it "should have a code of 200" do
      expect(@response.code).to eq @code[1]
    end

    it do
      expect(@response).to be_ok
    end
  end

  describe Response, "parsing a :lookup command" do

    before(:each) do
      @code = [102, 201]
      @count = 2
      @sub_count = 2
      @data = ['110 Joe Q. User', '110 joey, jqu', '110 Jane P. User', '110 janes, jp']
      @status = 'Additional matches not returned'
      @socket = flexmock("DND Socket after :lookup command")
      @socket.should_receive(:gets).times(6).and_return(
          "#{@code[0]} #{@count} #{@sub_count}\r\n",
          "#{@data[0]}\r\n", "#{@data[1]}\r\n",
          "#{@data[2]}\r\n", "#{@data[3]}\r\n",
          "#{@code[1]} #{@status}\r\n")
      @response = Response.process(@socket)
    end
  
    it "should have the correct count" do
      expect(@response.count).to eq @count
    end
  
    it "should have the correct sub_count" do
      expect(@response.sub_count).to eq @sub_count
    end
  
    it "should have items stored as an array of arrays" do
      expect(@response.items[0]).to be_an_instance_of(Array)
    end
  
    it "should have the correct name for the sub-array of the second item" do
      expect(@response.items[1][0]).to eq 'Jane P. User'
    end
  
    it "should have a code of 201" do
      expect(@response.code).to eq @code[1]
    end
  
    it do
      expect(@response).to be_ok
    end
  end

end; end
