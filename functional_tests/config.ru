require 'bundler'

Bundler.require

require './mock_site/site.rb'

run Sinatra::Application
