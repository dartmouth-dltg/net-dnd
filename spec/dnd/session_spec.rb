require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/session'

module Net ; module DND

  describe Session, "when created with a bad host" do

    before(:each) do
      @connection = flexmock("Bad Connection")
      @connection.should_receive(:open?).once.and_return(false)
      @connection.should_receive(:error).once.and_return("Could not connect to DND server")
      flexmock(Connection).should_receive(:new).once.and_return(@connection)
    end

    it "should raise a Connection Error" do
      expect { Session.new('my.badhost.com') }.to raise_error(ConnectionError)
    end
  end

  describe Session, "when created with a good host" do

    before(:each) do
      @connection = flexmock("Good Connection")
      @connection.should_receive(:open?).twice.and_return(true)
      flexmock(Connection).should_receive(:new).once.and_return(@connection)
      @session = Session.new('my.goodhost.com')
    end

    it do
      expect(@session).to be_open
    end
  end

  describe Session, "after closing down" do

    before(:each) do
      @connection = flexmock("Good Connection")
      @connection.should_receive(:open?).times(3).and_return(true, true, false)
      flexmock(Connection).should_receive(:new).once.and_return(@connection)
      @response = flexmock(Response)
      @connection.should_receive(:send).once.and_return(@response)
      @session = Session.new('my.goodhost.com')
      @session.close
    end

    it "should not be open" do
      expect(@session).not_to be_open
    end
  end

  shared_context "a connected session" do
    before(:each) do
      @connection = flexmock("Good Connection")
      @connection.should_receive(:open?).twice.and_return(true)
      flexmock(Connection).should_receive(:new).once.and_return(@connection)
    end
  end

  shared_context "a good response" do 
    before(:each) do
      @response = flexmock(Response)
      @connection.should_receive(:send).once.and_return(@response)
      @response.should_receive(:ok?).once.and_return(true)
      @session = Session.new('my.goodhost.com')
    end
  end

  describe Session, "when setting fields with an unknown field" do

    include_context "a connected session"

    before(:each) do
      @response = flexmock(Response)
      @connection.should_receive(:send).once.and_return(@response)
      @response.should_receive(:ok?).once.and_return(false)
      @response.should_receive(:error).once.and_return('unknown.')
      @session = Session.new('my.goodhost.com')
      @field_list = ['unknown']
    end

    it "should raise a Field Not Found error" do
      expect { @session.set_fields(@field_list) }.to raise_error(FieldNotFound, "unknown.")
    end
  end

  describe Session, "when setting fields with a bad field_list" do

    include_context "a connected session"
    include_context "a good response"

    before(:each) do
      @field_list = ['ssn']
      @items = ['ssn N N']
      @response.should_receive(:items).once.and_return(@items)
      @ssn_field = flexmock("a bad field")
      @ssn_field.should_receive(:read_all?).once.and_return(false)
      @ssn_field.should_receive(:to_s).once.and_return('ssn')
      flexmock(Field).should_receive(:from_field_line).once.and_return(@ssn_field)
    end

    it "should raise a Field Access Denied error" do
      expect { @session.set_fields(@field_list) }.
	  		 to raise_error(FieldAccessDenied, "#{@field_list[0]} is not world readable.")
    end
  end

  describe Session, "when setting fields with a good field_list" do

    include_context "a connected session"
    include_context "a good response"

    before(:each) do
      name_field = flexmock("a name field")
      name_field.should_receive(:read_all?).once.and_return(true)
      name_field.should_receive(:to_sym).once.and_return(:name)
      nickname_field = flexmock("a nickname field")
      nickname_field.should_receive(:read_all?).once.and_return(true)
      nickname_field.should_receive(:to_sym).once.and_return(:nickname)
      flexmock(Field).should_receive(:from_field_line).twice.and_return(name_field, nickname_field)
      @response.should_receive(:items).once.and_return(['name N A', 'nickname U A'])
      @session.set_fields(['name', 'nickname'])
    end

    it "should have [:name, :nickname] as the fields attribute" do
      expect(@session.fields).to eq [:name, :nickname]
    end
  end

  shared_context "mock items for a started session" do
    before(:each) do
      name_field = flexmock("a name field")
      name_field.should_receive(:read_all?).once.and_return(true)
      name_field.should_receive(:to_sym).once.and_return(:name)
      nickname_field = flexmock("a nickname field")
      nickname_field.should_receive(:read_all?).once.and_return(true)
      nickname_field.should_receive(:to_sym).once.and_return(:nickname)
      flexmock(Field).should_receive(:from_field_line).twice.and_return(name_field, nickname_field)
      @fields_resp = flexmock(Response)
      @fields_resp.should_receive(:items).once.and_return(['name N A', 'nickname U A'])
      @connection = flexmock("A Started Connection")
      @connection.should_receive(:open?).times(3).and_return(true)
      flexmock(Connection).should_receive(:new).once.and_return(@connection)
    end
  end

  describe Session, "performing a find with no profiles returned" do

    include_context "mock items for a started session"

    before(:each) do
      @find_resp = flexmock(Response)
      @find_resp.should_receive(:ok?).once.and_return(true)
      @find_resp.should_receive(:items).once.and_return([])
      @connection.should_receive(:send).twice.and_return(@fields_resp, @find_resp)
      @session = Session.start('my.goodhost.com', ['name', 'nickname'])
      @profiles = @session.find("Nothing returned")
    end

    it "should return an empty array" do
      expect(@profiles).to eq []
    end

  end

  describe Session, "performing a find with one profile returned" do

    include_context "mock items for a started session"

    before(:each) do
      @find_resp = flexmock(Response)
      @find_resp.should_receive(:ok?).once.and_return(true)
      @find_resp.should_receive(:items).once.and_return([['Joe D. User', 'joey jdu']])
      @joe = flexmock("Joe's Profile")
      flexmock(Profile).should_receive(:new).once.and_return(@joe)
      @connection.should_receive(:send).twice.and_return(@fields_resp, @find_resp)
      @session = Session.start('my.goodhost.com', ['name', 'nickname'])
      @profiles = @session.find("Joe User")
    end

    it "should return a single item array of profiles" do
      expect(@profiles.length).to eq 1
    end

    it "should return Joe's profile as the first item" do
      expect(@profiles[0]).to equal(@joe)
    end
  end

  describe Session, "performing a find with multiple profiles returned" do

    include_context "mock items for a started session"

    before(:each) do
      @joe = flexmock("Joe's Profile")
      @jane = flexmock("Jane's Profile")
      flexmock(Profile).should_receive(:new).twice.and_return(@joe, @jane)
      @find_resp = flexmock(Response)
      @find_resp.should_receive(:ok?).once.and_return(true)
      @find_resp.should_receive(:items).once.
                and_return([['Joe D. User', 'joey jdu'],['Jane P. User', 'janey jpu']])
      @connection.should_receive(:send).twice.and_return(@fields_resp, @find_resp)
      @session = Session.start('my.goodhost.com', ['name', 'nickname'])
      @profiles = @session.find("User")
    end

    it "should return a 2 item array of profiles" do
      expect(@profiles.length).to eq 2
    end

    it "should return Jane's profile as the second item" do
      expect(@profiles[1]).to equal(@jane)
    end
  end

  describe Session, "performing an bad single find" do

    include_context "mock items for a started session"

    before(:each) do
      @find_resp = flexmock(Response)
      @find_resp.should_receive(:ok?).once.and_return(true)
      @find_resp.should_receive(:items).once.and_return([])
      @connection.should_receive(:send).twice.and_return(@fields_resp, @find_resp)
      @session = Session.start('my.goodhost.com', ['name', 'nickname'])
      @profile = @session.find("Nothing", :one)
    end

    it "should return nil for the profile object" do
      expect(@profile).to be_nil
    end
  end

  describe Session, "performing a good single find" do

    include_context "mock items for a started session"

    before(:each) do
      @find_resp = flexmock(Response)
      @find_resp.should_receive(:ok?).once.and_return(true)
      @find_resp.should_receive(:items).twice.and_return([['Joe D. User', 'joey jdu']])
      @joe = flexmock("Joe's Profile")
      flexmock(Profile).should_receive(:new).once.and_return(@joe)
      @connection.should_receive(:send).twice.and_return(@fields_resp, @find_resp)
      @session = Session.start('my.goodhost.com', ['name', 'nickname'])
      @profile = @session.find("Joe User", :one)
    end

    it "should return Joe's profile" do
      expect(@profile).to equal(@joe)
    end
  end

end ; end
