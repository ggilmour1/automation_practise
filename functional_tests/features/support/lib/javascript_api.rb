require 'singleton'

# Example usage  JavascriptApi.instance.<name of method>
class JavascriptApi
  include Singleton

  attr_accessor :collated_errors

  def initialize
    @collated_errors = []
    @excludes = {}
  end

  #returns an array of javascript errors detected
  def errors( browser )
    errors = browser.execute_script("return JSErrorCollector_errors.pump();")
    error_descriptions = ""
    errors.each do |error|
      error_descriptions += "Javascript error #{error["errorMessage"]} #{error["sourceName"]}:#{error["lineNumber"]}\n"
    end
    error_descriptions
  end

end