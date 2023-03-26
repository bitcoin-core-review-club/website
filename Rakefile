# frozen_string_literal: true

# To display all the available rake (Ruby make) tasks, run:
#   rake -T

require 'rake/testtask'

# To run all tests:
#   rake (or) rake test
#
# To run one test file:
#   rake test TEST=test/FILENAME
#
# To run an individual test in a test file:
#   rake test TEST=test/FILENAME TESTOPTS=--name=TEST_NAME
#
desc 'Run all tests with `rake` or `rake test`'
task default: :test # Make test runner the default rake task.
Rake::TestTask.new do |task|
  task.pattern = 'test/test_*.rb'
end

desc 'Deprecated, use ./contrib/new-post.py instead'
namespace :posts do
  task :new do
    puts "Error: `rake posts:new` is deprecated, use `./contrib/new-post.py -h` instead"
    exit
  end
end
