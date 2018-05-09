require 'yaml'
require 'singleton'

class Configuration
  include Singleton

  attr_accessor :testdata_directory, :download_directory, :temp_directory, :report_directory, :screenshot_directory

  def initialize
    @runtime_configuration = YAML::load( ERB.new( File.open( "#{File.dirname(__FILE__)}/../../../configuration.yml" ).read ).result )   #ERB enabled
    @testdata_directory = File.expand_path( "#{File.dirname(__FILE__)}/../../../testdata" )
    @temp_directory = File.expand_path( "#{File.dirname(__FILE__)}/../../../temp" )
    @report_directory = File.expand_path( "#{File.dirname(__FILE__)}/../../../report" )
    @download_directory = Selenium::WebDriver::Platform.windows? ? @temp_directory.gsub!("/", "\\") : @temp_directory
    @screenshot_directory = File.expand_path( "#{File.dirname(__FILE__)}/../../../screenshots" )

    Logging.instance.logger.debug("Test Data directory #{@testdata_directory}")
    Logging.instance.logger.debug("Temp directory #{@temp_directory}")
    Logging.instance.logger.debug("Report Data directory #{@report_directory}")
    Logging.instance.logger.debug("Download directory #{@download_directory}")
  end

  def get( section, property_name )
    return @runtime_configuration[section.to_s][property_name.to_s]
  end

  def get_section( section )
    return @runtime_configuration[section.to_s]
  end
end

