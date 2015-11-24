require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/profile'

module Net ; module DND

  describe Profile, "for Joe D. User" do

    before(:each) do
      @fields = [:name, :nickname, :deptclass, :email]
      @items = ['Joe D. User', 'joey jdu', 'Student', 'Joe.D.User@Dartmouth.edu']
      @profile = Profile.new(@fields, @items)
    end

    it "should return the correct object" do
      expect(@profile).to be_instance_of(Profile)
    end

    it "should return the correct inspection string" do
      expect(@profile.inspect).to match(/<Net::DND::Profile length=4, .*deptclass="Student".*>/)
    end

    it "should have the correct number of entries" do
      expect(@profile.length).to eq 4
    end

    it "should return the correct name" do
      expect(@profile.name).to eq @items[0]
    end

    it "should return the correct email" do
      expect(@profile[:email]).to eq @items[3]
    end

    it "should contain nickname field" do
      expect(@profile.respond_to? :nickname?).to be true
    end

    it "should not contain did field" do
      expect(@profile.respond_to? :dnd?).to be false
    end

    it "should raise Field Not Found error if did field is requested" do
      expect { @profile.did }.to raise_error(FieldNotFound)
    end

  end

  describe Profile, "for Joe D. Expired" do

    before(:each) do
      @fields = [:name, :expires]
      @items = ['Joe D. User', '01-Jan-2010']
      @profile = Profile.new(@fields, @items)
    end

    it "should have a valid expire_date" do
      expect(@profile.expires_on).not_to be_nil
    end

    it "should be expired" do
      expect(@profile).to be_expired
    end

  end

end ; end