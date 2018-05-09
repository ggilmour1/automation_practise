require 'singleton'
require 'logger'

class Logging
  include Singleton

  attr_reader :logger
  def initialize
    @logger = Logger.new(STDOUT)
    @logger.datetime_format = '%H:%M:%S'
    if 'DEBUG'.eql?( ENV['LOGGING'] )
      @logger.level = Logger::DEBUG
    elsif 'INFO'.eql?( ENV['LOGGING'] )
      @logger.level = Logger::INFO
    elsif 'WARN'.eql?( ENV['LOGGING'] )
      @logger.level = Logger::WARN
    elsif 'ERROR'.eql?( ENV['LOGGING'] )
      @logger.level = Logger::ERROR
    elsif 'FATAL'.eql?( ENV['LOGGING'] )
      @logger.level = Logger::FATAL
    else
      @logger.level = Logger::INFO
    end
  end

end