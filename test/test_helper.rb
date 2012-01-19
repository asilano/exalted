ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'shoulda/rails'
require 'active_support/testing/pending'
#require 'turn'

class ActiveSupport::TestCase
  include ActiveSupport::Testing::Pending
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def todo
    flunk "test not written"
  end
    
end

def skip &block
  
end