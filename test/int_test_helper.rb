require 'test_helper'
require 'capybara/rails'

chrome_path = `which google-chrome`.strip
ENV["LAUNCHY_BROWSER"] = chrome_path
ENV["BROWSER"] = chrome_path

module ActionController
  class IntegrationTest
    include Capybara::DSL
    
    self.use_transactional_fixtures = false
    
    def current_path
      URI.parse(current_url).path
    end
    
    setup do
      visit '/clear_session'
      ActionMailer::Base.deliveries.clear
    end
  end
end
