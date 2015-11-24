require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/connection'

module Net ; module DND

  shared_context "a good socket" do 
    before(:each) do
      @socket = flexmock("TCP Socket")
      @tcp = flexmock(TCPSocket)
      @response = flexmock(Response)
     end
  end

  describe Connection, "to a bad host" do
    include_context "a good socket"
    
    before(:each) do
      @tcp.should_receive(:open).and_raise(Errno::ECONNREFUSED, "Connection refused")
      @connection = Connection.new('my.fakehost.com')
    end

    it "should not indicate an open connection" do
      expect(@connection).not_to be_open
    end

    it "should return the 'Could not connect' error message" do
      expect(@connection.error).to match(/^Could not connect to/)
    end
  end

  describe Connection, "to a busy/slow host" do

    include_context "a good socket"

    before(:each) do
      flexmock(Timeout).should_receive(:timeout).and_raise(Timeout::Error, "Connection timed out")
      @connection = Connection.new('my.slowhost.com')
    end

    it "should not indicate an open connection" do
      expect(@connection).not_to be_open
    end

    it "should return the 'Connection timed out' error message" do
      expect(@connection.error).to match(/^Connection attempt .* has timed out/)
    end
  end

  describe Connection, "to a good host" do

    include_context "a good socket"

    before(:each) do
      @tcp.should_receive(:open).once.and_return(@socket)
      @response.should_receive(:process).at_least.once.and_return(@response)
      @response.should_receive(:ok?).at_least.once.and_return(true)
      @connection = Connection.new('my.goodhost.com')
    end

    it "should indicate an open connection" do
      expect(@connection).to be_open
    end

    it "should not have any error messages" do
      expect(@connection.error).to be_nil
    end

    describe "sending commands" do

      it "should send the correct command when fields is called with empty field list" do
        @socket.should_receive(:puts).once.with('fields')
        @socket.should_receive(:closed?).and_return(false)
        @connection.fields
      end

      it "should send the correct command when fields is called with a field list" do
        @socket.should_receive(:puts).once.with('fields name nickname')
        @socket.should_receive(:closed?).and_return(false)
        @connection.fields(['name', 'nickname'])
      end

      it "should send the correct command when lookup is called" do
        @socket.should_receive(:puts).once.with('lookup joe user,name nickname')
        @socket.should_receive(:closed?).and_return(false)
        @connection.lookup('joe user', ['name', 'nickname'])
      end

      it "should send the correct command when quit is called" do
        @socket.should_receive(:puts).once.with('quit')
        @socket.should_receive(:close)
        @socket.should_receive(:closed?).and_return(false)
        @connection.quit
      end
    end
  end

end ; end
