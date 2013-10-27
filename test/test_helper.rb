ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/spec"
require 'factory_girl'
require 'active_support/testing/setup_and_teardown'

class MiniTest::Unit::TestCase
  ActiveRecord::Migration.check_pending!
  extend MiniTest::Spec::DSL

  # integration tests should have access to get/post/put/etc. and routes
  include Rails.application.routes.url_helpers
  include ActiveSupport::Testing::SetupAndTeardown
  include ActionController::TestCase::Behavior

  include FactoryGirl::Syntax::Methods
  FactoryGirl.find_definitions
end