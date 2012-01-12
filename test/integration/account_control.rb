require 'int_test_helper'

class AccountControlTest < ActionController::IntegrationTest
  should "visit root page" do    
    visit '/'
    assert page.has_content? 'Welcome to Exalted Mini Adventures!'
    assert page.has_content? 'Log In or Sign Up'
    assert page.has_content? 'Welcome, Guest'
  end
  
  should "register new user" do
    visit '/'
    click_link 'Sign Up'
    assert find('.userForm h1').has_content? 'Sign Up'
    fill_in 'Email', :with => "alan@example.com"
    fill_in 'Password', :with => "password"
    fill_in 'Password confirmation', :with => "password"
    click_button 'Sign up'
    
    assert page.has_content? 'Welcome, alan@example.com'
    assert page.has_content? 'Log Out'
    assert page.has_content? 'Current Exalt'
    assert page.has_content? 'You don\'t currently have an Exalt'
  end
  
  context "with user created" do
    setup do
      @user = Factory(:user)
    end
    
    should "log in" do
      visit '/'
      click_link 'Log In'
      assert find('.userForm h1').has_content? 'Log In'
      fill_in 'Email', :with => @user.email
      fill_in 'Password', :with => @user.password
      check 'Remember me'
      click_button 'Log in'
      
      assert page.has_content? "Welcome, #{@user.email}"
      assert page.has_content? 'Log Out'
      assert page.has_content? 'Current Exalt'
      assert page.has_content? 'You don\'t currently have an Exalt'
    end
  end
end