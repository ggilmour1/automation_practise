Running on Windows
==================


Installing Ruby
===============
Install Ruby code from https://rubyinstaller.org/downloads/ # I have tested against v2.3.3, other versions may work on Windows, but might require additional steps 

Make sure that the location of the Ruby/bin is on your path

Download the Dev Kit for Ruby from https://rubyinstaller.org/downloads 
	(https://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe)

Download it, run it to extract it somewhere (permanent). Then cd to it, run 
	> ruby dk.rb init,  and 
	> ruby dk.rb install 
to bind it to ruby installations in your path.
	
Open a command prompt, and go to the functional test_folder, then run the command to install the bundler gem 
	> cd functional_tests
	> gem install bundler
  
Install the required gems contained in the Gemfile by running the following  command    
	> bundle install

Install Chrome and the ChromeDriver
===================================
The tests (at the moment) will work best in Chrome, certainly for those that need to run in the browser. If you already have Chrome installed, 
check that its at the latest version. 

You also need to install the Chrome Driver from http://chromedriver.chromium.org/. 
The latest version (and the one that I used to test with is v2.38, but check as there can be issues if the browser version and driver versions are not supported, so 
being at the latest of each gives the greatest chance of success. 

Make sure that the location of the ChromeDriver ius added to the path.

Install Ansicon
===============
To add somne colour to you test output, install Ansicon

See the Documentation folder and the ansi184.zip, extract this, add it to your path
then run ansicon -i  to install it.

Run the Tests
=============
To run the tests you njeed to run the following 
	> bundle exec cucumber BROWSER=chrome

This sets the browser to use Chrome, and will run all of the tests.  You should see initially the API tests running (these dont use the browser), then the UI ytests will run and interact with Chrome. 

Output
======

There is visual output as the tests run, and at the end of the run that will look like

Failing Scenarios:
cucumber features/validate_api.feature:24 # Scenario: I will be not be able to GET a single user when they do not exist
cucumber features/validate_api.feature:63 # Scenario: I will not be able to GET a single resource when the id does not exist
cucumber features/validate_api.feature:73 # Scenario: I can PUT a request to update a user
cucumber features/validate_page.feature:42 # Scenario: As a signed in user who has previously placed an order, I will be able to check that the item ordered is the correct colou
r

12 scenarios (4 failed, 8 passed)
93 steps (4 failed, 3 skipped, 86 passed)
1m58.571s

Self explanatory, but you can see the line(s) and scenario descriptions that have failed and the location in the feature file.  

You can also see the number oif tests and steps run, the number passed or failed (and in some cases undefined)  and the time it took to run.  

There is also a test report under functional_tests/report which gives an HTML report of the scenarios run, passed and failed in a more human friendly output. 

  
  