
class Page
  include GeneralUtils
  attr_accessor :browser, :logger, :config,
                :images, :scripts, :stylesheets, :metas, :iframes, :links,
                :game_image_count, :game_link_count, :category_link_count, :external_iframes, :external_scripts

  def initialize( browser )
    @browser = browser
    @logger = Logging.instance.logger
    @config = Configuration.instance
    @browser.current_page = self
  end

  def open( channel_name, extra_url_params='' )
    home_page_url = @config.get( channel_name, :home_page_url )
    @logger.debug( "Visiting home page @ #{home_page_url}" )
    if !"".eql?( extra_url_params )
      home_page_url = "#{home_page_url}?#{extra_url_params}"
    end
    @browser.goto( home_page_url )
  end

  def clear_all_cookies
    @browser.cookies.clear
  end


  def make_current( specific_page )
    @browser.current_page = specific_page
  end

  def find_option_with_value( value, options )
    options.each do |option|
      if value.eql?( option.attribute_value( "value" ) )
        return option
      end
    end
    return nil
  end

  def already_selected( value, options )
    options.each do |option|
      if value.eql?( option.attribute_value( "value" ) )
        return true
      end
    end
    false
  end

  def canonical_url
    #previously we used xpath here but I want all xpath gone...unfortunately watir-webdriver doesnt allow us to access the
    matches = @browser.html.match( /.*rel="canonical" href="([^"]*).*/ )
    if matches.nil?
      matches = @browser.html.match( /.*href="([^"]*)" rel="canonical".*/ )
    end
    return matches
  end

  def collect_page_information(domain)
    #wait for pages information to be readable we seem to see "Element is no longer attached to the DOM" during initial testing
    #symptematic of things being added/removed from the dom.
    #sleep 3 #hmm would be better to wait for page loaded if we can ?
    #home_page_url = @config.get( channel, :home_page_url )
    collect_image_information
    collect_iframe_information( domain )
    collect_script_information( domain )
    collect_link_information( domain )
    @stylesheets = collect_elements_with_attribute(  browser.elements(:css, 'link[rel="stylesheet"]'), 'href' )
    collect_meta_information
  end

  def collect_information
    #wait for pages information to be readable we seem to see "Element is no longer attached to the DOM" during initial testing
    #symptematic of things being added/removed from the dom.
    home_page_url = @channel_home_page.to_s
    collect_image_information
    collect_iframe_information( home_page_url )
    collect_script_information( home_page_url )
    collect_link_information( home_page_url )
    @stylesheets = collect_elements_with_attribute(  browser.elements(:css, 'link[rel="stylesheet"]'), 'href' )
    collect_meta_information
  end

  def collect_info(page)
    #wait for pages information to be readable we seem to see "Element is no longer attached to the DOM" during initial testing
    #symptematic of things being added/removed from the dom.
    sleep 3 #hmm would be better to wait for page loaded if we can ?
    collect_image_information
    collect_iframe_information( page )
    collect_script_information( page )
    collect_link_information( page )
    @stylesheets = collect_elements_with_attribute(  browser.elements(:css, 'link[rel="stylesheet"]'), 'href' )
    collect_meta_information
  end

  def collect_image_information
    @images = collect_elements_with_attribute( @browser.imgs, 'src' )
    @game_image_count = 0
    @images.each do |image|
      #The url's below may become brittle if we introduce any additional domains for partners - review at that point
      if image.include?('http://games.iwin.com/m/') || image.include?('http://m.iwin.com/assets') || image.include?('http://s.m.iwin.com/assets') || image.include?('http://s.ma.iwin.com/assets') || image.include?('http://s.games.iwin.com/m')
        @game_image_count += 1
      end
    end
  end

  def collect_iframe_information( home_page_url )
    begin
      @iframes = collect_elements_with_attribute( @browser.frames, 'src' )
      @external_iframes = {}
      @iframes.each do |iframe|
        if !iframe.include?( home_page_url )
          domain = iframe.split("/")[2]
          if @external_iframes[ domain ].nil?
            @external_iframes[ domain ] = 1
          else
            @external_iframes[ domain ] += 1
          end
        end
      end
    rescue Exception => erd
      Logging.instance.logger.warn("Couldn't locate iframe data, error was #{erd.message}\n#{erd.backtrace.join("\n ")}")
    end
  end

  def collect_script_information( page )
    @scripts = collect_elements_with_attribute( @browser.scripts, 'src' )
    @external_scripts = {}
    @scripts.each do |script|
      if !script.include?( page )
        domain = script.split('/')[2]
        #puts "#{domain}"
        if @external_scripts[ domain ].nil?
          @external_scripts[ domain ] = 1
        else
          @external_scripts[ domain ] += 1
        end
      end
    end
  end

  def collect_link_information( page )
    @links = collect_elements_with_attribute( @browser.as, 'href' )
    @game_link_count = 0
    @links.each do |link|
      if link.include?( "#{page}/game/")
        @game_link_count += 1
      end
    end
  end

  def collect_meta_information
    @metas = {}
    if !browser.metas.nil?
      metas_array = browser.metas.to_a
      if !metas_array.nil? && !metas_array.empty?
        metas_array.each do |meta|
          name = meta.attribute_value('name')
          content = meta.attribute_value('content')
          charset = meta.attribute_value('charset')
          if !charset.nil?
            @metas["charset"] = charset
          elsif !content.nil? && !name.nil?
            @metas[name] = content
          end
        end
      end
    end
  end

  def collect_elements_with_attribute( collection_of_elements, attribute_name )
    elements = []
    if !collection_of_elements.nil?
      elements_array = collection_of_elements.to_a
      if !elements_array.nil? && !elements_array.empty?
        elements_array.each do |element|
          value = element.attribute_value( attribute_name )
          if !value.nil? && !value.empty? && !elements.include?( value )
            elements << value
          end
        end
      end
    end
    elements
  end

  def contains_in_collected_information( collection, entry_to_find )
    collection.each do |entry|
      if entry.include?( entry_to_find )
        return true
      end
    end
    false
  end

  def has_text_matching_pattern?( regexp_pattern_text )
    regexp_pattern = Regexp.new(regexp_pattern_text)
    match = regexp_pattern.match( @browser.html.to_s )
    !match.nil?
  end

  def validate_is_page( page_name )
    actual_page_name = @config.get( :pages, page_name )
    Watir::Wait.until { has_text_matching_pattern?( "<!-- start .*#{actual_page_name}" ) }
    Watir::Wait.until { has_text_matching_pattern?( "<!-- end .*#{actual_page_name}" ) }
    true
  end

  def count_external_scripts( page )
    @scripts = collect_elements_with_attribute( @browser.scripts, 'src' )
    @external_scripts = {}
    @scripts.each do |script|
      if !script.include?( page )
        domain = script.split('/')[2]
        if @external_scripts[ domain ].nil?
          @external_scripts[ domain ] = 1
        else
          @external_scripts[ domain ] += 1
        end
      end
    end
  end


  def create_timestamp
    return Time.now.to_i
  end

  def create_new_username
    timestamp = create_timestamp
    return "username#{timestamp}"
  end

  def create_new_email
    timestamp = create_timestamp
    return "testemail_#{timestamp}@yopmail.com"
  end


  def get_month
    month = Time.now.month+1
    case month
      when 2
        id = '02'
      when 3
        id = '03'
      when 4
        id = '04'
      when 5
        id = '05'
      when 6
        id = '06'
      when 7
        id = '07'
      when 8
        id = '08'
      when 9
        id = '09'
      when 10
        id = '10'
      when 11
        id = '11'
      when 12
        id = '12'
      else
        id = '01'
    end
    return id
  end

  def get_year
    Time.now.year+1
  end

end

