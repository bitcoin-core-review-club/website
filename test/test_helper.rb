# frozen_string_literal: true

# test/test_helper.rb - This test setup helper is required by each test file.

# Load test runner.
require 'minitest/autorun'

# Load test reporter.
require 'color_pound_spec_reporter'
Minitest::Reporters.use! [ColorPoundSpecReporter.new]
