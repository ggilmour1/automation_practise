module Watir

  class Browser

    def current_page
      @current_page ||= Page.new( self )
      @current_page
    end

    def current_page=(page_instance)
      @current_page = page_instance
    end

    def wait_until_loaded( text_to_locate, timeout = 30)
      start_time = ::Time.now
      until ( html.include? text_to_locate)  do
        sleep 0.1   #brittle_suppress
        if ::Time.now - start_time > timeout
          raise RuntimeError, "Timed out after #{timeout} seconds waiting for #{text_to_locate}"
        end
      end
    end

    def element_valid?( element )
      element_is_nil = element.nil?
      element_exists = element.exists?
      !element_is_nil && element_exists
    end

    def list_methods( element )
      Logging.instance.logger.debug( 'Available Methods on element are' )
      Logging.instance.logger.debug( element.methods.sort.join("\n") )
    end

  end
end


module Watir
  module Wait

    class << self

      attr_accessor :max_successful_wait

      def for_condition(timeout = 30, sleep_interval = 0.1, message = nil, &block)  #brittle_suppress
        start_time = ::Time.now
        end_time = ::Time.now + timeout
        until ::Time.now > end_time
          result = yield(self)
            if result
            delta = ::Time.now - start_time
            Logging.instance.logger.debug( "Watir for_condition waited #{delta} seconds with timeout currently set to #{timeout} for #{message}")
            if @max_successful_wait.nil?
              @max_successful_wait = 0
            end
            if delta > @max_successful_wait
              @max_successful_wait = delta
            end
            return result
            end
        sleep sleep_interval   #brittle_suppress
        end
        raise TimeoutError, "Failed #{message}"
      end

    end
  end
end