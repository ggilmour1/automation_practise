require 'cucumber'
require 'cucumber/rake/task'
require 'fileutils'
require 'rake'
require File.dirname(__FILE__) + '/run_ftests'

Cucumber::Rake::Task.new(:test) do |task|
  if !ENV['PROFILE'].nil?
    task.profile = "#{ENV["PROFILE"]}"
  end
  if ENV['TAGS'].nil?
    task.cucumber_opts = ["-t","~@compile","-t","~@environment","features"]
  else
    opts = []
    opts << "-t"
    tags = ENV["TAGS"].split(" ")
    tags.map!{ |tag|
      if tag.start_with?("@")
        tag = "#{tag}"
      elsif tag.start_with?("~")
        tag = "#{tag}"
      else
        tag = "@#{tag}"
      end
    }
    opts << tags.join(",")
    opts << "features"
    task.cucumber_opts = opts
  end
end

Cucumber::Rake::Task.new(:rerunfailedtests) do |task|
  ENV['SUDO'] = 'true'
  ENV['ENV'] = 'test'
  task.profile = 'rerun'
  opts = []
  opts << "@rerun.txt"
  task.cucumber_opts = opts
end

task :failme do
  puts "Aww nuts! Somethjing went wrong."
  fail("Failed!")
end
