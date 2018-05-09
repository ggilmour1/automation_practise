require 'cucumber'
require 'cucumber/rake/task'
require 'fileutils'
require File.dirname(__FILE__) + '/lib/test_tasks'
require File.dirname(__FILE__) + '/lib/run_ftests'
#require File.dirname(__FILE__) + '/features/support/lib/logging.rb'

include FileUtils

task :help do
  print <<EOF
  --------------------------------
  Installation
  --------------------------------
  Create a gem set
    rvm gemset create fe_functest
    rvm gemset use fe_functest
  In your frontend functional_test folder you checked out do
    bundle install
  Again in same folder create rvm file
    echo "rvm 2.2.1@fe_functest" > .rvmrc
    cd ..
    type yes

  --------------------------------
  Running
  --------------------------------
  bundle exec rake test

  you can rerun failed tests by tunning
  rake rerunfailedtests

  Optional test settings:
  --------------------------------
  LOGGING               - can be set to either DEBUG, INFO, WARN, ERROR, FATAL, defaults to INFO
  TAGS                  - can be set to specify the tag to run (we should update this to support multiple tags)

  Taking Screenshots:
  --------------------------------
  SCREENSHOT            - if set to 'true' will allow screen shots to be taken for the Upsell tests.  This produces
                          a report for each of the Upsell pages in the feature file.

  Set the correct user agent for running as Games Manager
  -------------------------------------------------------
  USE_GM                - if set to true will run the test and set the user agent to the current configuration of the UGM ua

EOF
end

task :default => :help