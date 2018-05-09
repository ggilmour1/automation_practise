require 'singleton'
require 'json'
require 'json_spec'
include JsonSpec::Helpers

# Example usage  JsonApi.instance.<name of method>
class JsonApi
  include Singleton

  attr_accessor :last_generated_profile_id, :last_cache_key

  def last_fetched_json
    @last_fetched_json
  end

  def last_fetched_json=(json)
    @last_fetched_json = json
    @last_built_json = nil
  end

  def as_json
    if @last_built_json.nil?
      @last_built_json = JSON.parse( last_fetched_json )
    end
    @last_built_json
  end

  def is_key_value_string_structure
    as_json.each do |key,value|
      if !( key.is_a?(String) && value.is_a?(String) )
        return false
      end
    end
    true
  end

  def value_at_path( path )
    parse_json(last_fetched_json, path)               #todo could be optomized to use the as_json instead so parsing only happens once
  end

  def last_fetched_authorization_code
    parse_json(last_fetched_json, "accessToken")      #todo could be optomized to use the as_json instead so parsing only happens once
  end

  def valid_json?(json)
    begin
      JSON.parse(json)
      return true
    rescue Exception => e
      return false
    end
  end
end