require 'cucumber'
require 'cucumber/rake/task'
require 'fileutils'
require File.dirname(__FILE__) + '/test_tasks'


desc "Run the functional tests and if failed, try the re-run failed tests once.  Report both runs"
task :runtests do
  begin
    first_exit = system("rake test")
    if first_exit
      puts "\n First run Success!"
      FileUtils.cp 'rerun-results.html', 'rerun_report'
    else
      raise Exception.new("First run failed.")
    end
  rescue Exception
    puts "\n ### First run failed.  Starting re-run of failed tests... ###\n"
    rerun_exit = system("rake rerunfailedtests")
    begin
      if rerun_exit
        puts "\n ### Test re-run success! ###"
      else
        puts  "\n ### Re-run of failed tests unsuccessful ###"
        system("rake failme")
      end
    rescue => ex
      raise "#{ex}"
      puts "\n ### Re-run failed.  Please investigate failures. ###\n"

    end
  end
  puts "Success status : #{rerun_exit}."
end