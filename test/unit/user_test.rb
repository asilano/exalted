require 'test_helper'

class UserTest < ActiveRecord::TestCase
  should validate_presence_of :email
  should validate_format_of(:email).with("user+throwaway@subdom.example.com").with_message(/valid email address/)
  should validate_presence_of(:password)
  #should validate_confirmation_of :password
  
  should "be able to create a user" do
    assert_nothing_raised do
      Factory(:user)
    end
  end
    
end
