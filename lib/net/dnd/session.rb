folder_path = File.dirname(__FILE__)

require "#{folder_path}/connection"
require "#{folder_path}/profile"
require "#{folder_path}/field"
require "#{folder_path}/errors"

module Net ; module DND
  
  # This is the DND session object. It provides the high-level interface for performing
  # lookup-style searches against a given DND host. It manages the Connection object,
  # which is the low-level socket stuff, and sends back DND Profile objects, either singly or
  # an array, as the result of the find method.
  
  class Session
    
    attr_reader :fields, :connection
    
    def initialize(host)
      @connection = Connection.new(host)
      raise ConnectionError, connection.error unless connection.open?
    end

    def self.start(host, field_list=[])
      session = Session.new(host)
      session.set_fields(field_list)
      session
    end
    
    def open?
      connection.open?
    end
    
    def set_fields(field_list=[])
      response = request(:fields, field_list)
      @fields = []
      response.items.each do |item|
        field = Field.from_field_line(item)
        if field.read_all? # only world readable fields are valid for DND Profiles
          @fields << field.to_sym
        else
          raise FieldAccessDenied, "#{field.to_s} is not world readable." unless field_list.empty?
        end
      end
    end
    
    def find(look_for, one=nil)
      response = request(:lookup, look_for.to_s, fields)
      if one
        return nil unless response.items.length == 1
        Profile.new(fields, response.items[0])
      else
        response.items.map { |item| Profile.new(fields, item) }
      end
    end
    
    def close
      request(:quit, nil)
    end
    
    private
    
    def request(type, *args)
      raise ConnectionClosed, "Connection closed." unless open?
      response = connection.send(type, *args)
      raise InvalidResponse, response.error unless response.ok?
      response
    end
    
  end
  
end ; end
