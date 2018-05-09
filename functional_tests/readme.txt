Running on windows

Requires Ruby 1.9.3
do bundle install
run rake test TAGS="@sitemap"

This will fail
So find the path to the libxml.rb file it is complaining about and edit the file to add this to the very top of the file

ENV['PATH'] = ENV['PATH'] + ';' + File.expand_path(File.dirname(__FILE__) + '/libs')


Note if the bundle itself fails try modifying the Gemfile.lock temporarily to
libxml-ruby (2.6.0)