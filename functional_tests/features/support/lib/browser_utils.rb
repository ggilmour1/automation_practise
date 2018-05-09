require 'singleton'

class BrowserUtils
  include Singleton

  def initialize
    @browser_enabled = true
  end

  def browser_enabled?
    @browser_enabled
  end

  def browser_enabled=( value )
    @browser_enabled = value
  end

  def instance.create_browser(selected_browser, config, custom_useragent)

    #Increase timeout to prevent very first request to system timing out due to the amount of work the first page access creates
    http = Selenium::WebDriver::Remote::Http::Default.new
    http.read_timeout = 180

    if selected_browser.eql?('chrome')
      http = Selenium::WebDriver::Remote::Http::Default.new
      http.read_timeout = 10
      if custom_useragent.nil?
        switches = ["--disable-web-security", "--disable-extensions", "--disable-popup-blocking"]
      else
        switches = ["--disable-web-security", "--disable-extensions", "--disable-popup-blocking", "--user-agent=#{custom_useragent}"]
      end
      browser =  Watir::Browser.new( :chrome, :http_client => http, :switches => switches)
      width = browser.execute_script("return screen.width")
      height = browser.execute_script("return screen.height")
      browser.window.move_to(0, 0)
      browser.window.resize_to(width, height)
      return browser
    else
      #Note proxy wont be available
      return Watir::Browser.new(selected_browser.to_sym, :http_client => http)
    end
  end

end
