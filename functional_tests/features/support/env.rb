require 'rubygems'
require "bundler/setup"
require 'active_support/all'
require 'watir-webdriver'
require 'fileutils'
require 'erb'
require 'mechanize'
require 'json'
require 'uuid'
require 'methodize'
require 'random_data'
require 'rack'


# Auto require all Utils
# But dont require in any constants as these will generate an error if required here
Dir[ File.dirname(__FILE__) + "/lib/*.rb"].each do |file|
  require(file) unless "#{file}".end_with?( 'constants.rb' )
end

include GeneralUtils

selected_browser = ENV['BROWSER']
if selected_browser.nil?
  selected_browser = 'firefox'
end

take_screenshot = ENV['SCREENSHOT']
if take_screenshot.nil?
  take_screenshot = FALSE
end

use_gm = ENV['USE_GM']
if use_gm.nil?
  use_gm = FALSE
end

if !( selected_browser.eql?('ie') || selected_browser.eql?('firefox') || selected_browser.eql?('chrome') )
  throw Exception.new('You must set the BROWSER env variable to either , ie , firefox or chrome')
end

logger = Logging.instance.logger
config = Configuration.instance

if File.exist?("#{config.report_directory}")
  FileUtils.rmdir("#{config.report_directory}")
end

if !File.exist?("#{config.report_directory}")
  FileUtils.mkdir("#{config.report_directory}")
end

if !File.exist?("#{config.temp_directory}")
  FileUtils.mkdir("#{config.temp_directory}")
end

if File.exist?("#{config.screenshot_directory}")
  FileUtils.rmdir("#{config.screenshot_directory}")
end

if !File.exist?("#{config.screenshot_directory}")
  FileUtils.mkdir("#{config.screenshot_directory}")
end

if take_screenshot == 'true'
  puts "Taking screenshots"

  row = 0
  head = "<html><head><title>Upsell Testing Screen Shots</title></head><body><p><h1>Upsell Test Report</h1><p><table border='1' width=100%><tr><td>Test</td><td>URL</td><td>Scenario</td><td>Screenshot</td><td>JSON payload</td></tr>"
  filename = File.new("#{config.screenshot_directory}/upsell_report.html" , "w+")
  File.open(filename, 'w+') { |file| file.write( head ) }
else
  puts "Screenshots are disabled"
end


if use_gm == 'true'
  browser_ua = Configuration.instance.get(:useragents , :gamesmanager)
else
  browser_ua = nil
end

#Setup initial status of servers, debugging, mocks, etc...
timing_of_scenarios = {}
timing_of_feature_files = {}
start_time = nil
browser = nil

# Initialize a browser, logging etc, Called by cucumber before each scenario is ran
BrowserUtils.instance.browser_enabled = true
Before ('@nobrowser') do
  BrowserUtils.instance.browser_enabled = false
end

Before ('@ugm2') do
  browser_ua = Configuration.instance.get(:user_agent, :ugm2)
end

Before do
  if ENV['SELENIUM_HEADLESS'] == 'true'
    output = `/root/kick_xvfb.sh`
    #puts output
    require 'headless'
    @headless = Headless.new
    @headless.start
  end

  start_time = Time.now
  @logger = logger
  if BrowserUtils.instance.browser_enabled?
    @logger.debug('Starting Browser')
    @logger.info("Setting user agent to #{browser_ua} for the test")
    @browser = BrowserUtils.instance.create_browser( selected_browser, config, browser_ua)
    browser = @browser
  end
  @logger.debug('Starting..')
  @config = config
end

# Called by cucumber after each scenario has been ran
After do |scenario|
  dump = ''
  begin
    if scenario.failed? && BrowserUtils.instance.browser_enabled?
      timestamp = human_friendly_timestamp()
      sleep(2) #brittle_suppress - Give browser a further 2 seconds to finish rendering whatever it is rendering
      dump = browser.html
      filename = "#{config.report_directory}/failed_at_#{timestamp}.html"
      logger.warn("Added failure html to file #{filename}")
      File.open(filename, 'w') { |file| file.write( dump ) }
    end
  rescue Exception => e
    logger.warn("Could not take html dump because of #{e}")
    logger.warn("dump was #{dump}")
  end

  if take_screenshot == 'true'
    begin
      row += 1
      filename = "#{config.screenshot_directory}/upsell_report.html"
      logger.warn("Added screenshot to file #{filename}")
      dump = "<tr><td>#{row}</td><td>#{@upsell_url}</td><td>User Type: #{@status} #{@user}; Game Type: #{@type}, #{@game_id}; Game: #{@installed} installed, #{@premium} Premium Game, #{@allaccess} and All Access Game; Trial Type: #{@trial};  Entry Point: #{@param}; I have #{@coins} coins/credits</td><td><a href='#{@image}' target='_blank'><img src='#{@image}' height='240' width='300'></img></a></td><td>' #{@json}'</td></tr>"
      File.open(filename, 'a+') { |file| file.write( dump ) }
    end
  end

  begin
    @headless.destroy if @headless.present?
# Pete - this always fails on Jenkins so disabling it for time being !
#    if scenario.failed? && BrowserUtils.instance.browser_enabled?
#      timestamp = human_friendly_timestamp()
#      filename = "failed_at_#{timestamp}.png"
#      path_to_filename = "#{config.report_directory}/#{filename}"
#      sleep(2) #brittle_suppress - Give browser a further 2 seconds to finish rendering whatever it is rendering
#      browser.driver.save_screenshot path_to_filename
#      embed(filename, 'image/png')
#      File.open("#{config.report_directory}/failed_at_#{timestamp}.html", 'w') { |file| file.write( browser.html ) }
#    end
  rescue
#    logger.warn("Could not create screenshot for failure...skipping it")
    logger.warn('Creating new browser as it may be suspect')
  end

  file = scenario.respond_to?( 'scenario_outline' ) ? scenario.scenario_outline.feature.file : scenario.feature.file
  title = "#{file} - #{scenario.respond_to?( 'scenario_outline' ) ? scenario.scenario_outline.name : scenario.name}"
  title_with_linenumber = "#{file} - #{scenario.respond_to?( 'scenario_outline' ) ? scenario.scenario_outline.name : scenario.name} (line #{scenario.location.line})"

  begin
    if BrowserUtils.instance.browser_enabled?
      browser.close
    end
  rescue
    logger.warn('Failed to close the browser but continuing anyway')
  end

  time_taken = Time.now - start_time
  file = scenario.respond_to?( 'scenario_outline' ) ? scenario.scenario_outline.feature.file : scenario.feature.file
  title = "#{file} - #{scenario.respond_to?( 'scenario_outline' ) ? scenario.scenario_outline.name : scenario.name} (line #{scenario.location.line})"
  timing_of_scenarios[title] = time_taken
  timing_of_feature_files[file].nil? ? timing_of_feature_files[file] = time_taken : timing_of_feature_files[file] += time_taken

  BrowserUtils.instance.browser_enabled = true

  if use_gm == 'true'
    browser_ua = Configuration.instance.get(:useragents , :gamesmanager)
  else
    browser_ua = nil
  end
  selected_browser = ENV['BROWSER']
  if selected_browser.nil?
    selected_browser = 'firefox'
  end

  #Code to remove files left in temp folder by Chromedriver
  begin
    #system('for /d %G in ("%temp%\\scoped_dir*") do rd /s /q "%~G"')
    system('for /d %G in ("%temp%\\2\\scoped_dir*") do rd /s /q "%~G"')
  rescue
    puts "Could not remove temp files.  Please remove manually"
  end
end

# Called by cucumber at exit
at_exit do
  report_file = "#{config.report_directory}/results.html"
  if take_screenshot == 'true'
    foot = "</table></body></html>"
    filename = "#{config.screenshot_directory}/upsell_report.html"
    File.open(filename, 'a+') { |file| file.write( foot ) }
  end
end