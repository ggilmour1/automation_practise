require 'mechanize'
require 'singleton'


class HttpUtils
  include Singleton

  attr_accessor :response, :validated_urls

  def initialize
    @validated_urls = []
  end

  def get( url, headers = nil )
    agent, url = create_agent_and_url( url )
    Logging.instance.logger.debug("Invoking url #{url}")
    page = agent.get( url, nil, nil, headers )
    @response = page
    @agent_cookie_jar = agent.cookie_jar
    return page
  end

  def put( url, headers = nil, body = "" )
    agent, url = create_agent_and_url( url )
    Logging.instance.logger.debug("Invoking url #{url}  body #{body}")
    page = agent.put( url, body, headers )
    @response = page
    @agent_cookie_jar = agent.cookie_jar
    return page
  end

  def post( url, headers = nil, body = "" )
    agent, url = create_agent_and_url( url )
    Logging.instance.logger.debug("Invoking url #{url}  body #{body}")
    page = agent.post( url, body, headers )
    @response = page
    @agent_cookie_jar = agent.cookie_jar
    return page
  end

  def delete( url, headers = {} )
    agent, url = create_agent_and_url( url )
    Logging.instance.logger.debug("Invoking url #{url}")
    page = agent.request_with_entity(:delete, url, "", headers )
    @response = page
    @agent_cookie_jar = agent.cookie_jar
    return page
  end

  def options( url, headers = {} )
    agent, url = create_agent_and_url( url )
    Logging.instance.logger.debug("Invoking url #{url}")
    page = agent.request_with_entity(:options, url, "", headers )
    @response = page
    @agent_cookie_jar = agent.cookie_jar
    return page
  end

  def response_headers
    @response.response
  end

  def content
    @response.body
  end

  def response_code
    @response.code
  end

  def content_type
    @response.response['Content-Type']
  end

  def cache_control
    @response.response['Cache-Control']
  end

  def cookie(domain, path, name)
    result = nil
    domain_cookies = @agent_cookie_jar.jar[domain]
    if domain_cookies
      path_cookies = domain_cookies[path]
      if path_cookies
        result = path_cookies[name]
      end
    end
    return result
  end

  def get_expecting_response_code_error( url, headers = nil )
    Logging.instance.logger.debug("Invoking url #{url} expecting error")
    begin
      agent, url = create_agent_and_url( url )
      agent.get( url, nil, nil, headers )
      raise "Expected an error response to have occurred fetching URL #{url} before reaching this point"
    rescue Mechanize::ResponseCodeError => ex
      @response = ex.page
      return ex
    end
  end

  def put_expecting_response_code_error( url, headers = nil, body = '' )
    Logging.instance.logger.debug("Invoking url #{url} with body #{body} expecting error")
    begin
      agent, url = create_agent_and_url( url )
      agent.put( url, body, headers )
      raise "Expected an error response to have occurred fetching URL #{url} before reaching this point"
    rescue Mechanize::ResponseCodeError => ex
      @response = ex.page
      return ex
    end
  end

  def post_expecting_response_code_error( url, headers = nil, body = '' )
    Logging.instance.logger.debug("Invoking url #{url} with body #{body} expecting error")
    begin
      @agent, url = create_agent_and_url( url )
      @agent.post( url, body, headers )
      raise "Expected an error response to have occurred fetching URL #{url} before reaching this point"
    rescue Mechanize::ResponseCodeError => ex
      @response = ex.page
      return ex
    end
  end


private
 
  def create_agent_and_url( url )
    agent = Mechanize.new do |a|
      a.agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
		  a.agent.gzip_enabled = false #gzip is not being supported well inside Mechanisze.rb gem, so disabling this. IP-209
    end
	return agent, url
  end

end