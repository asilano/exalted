class ApplicationController < ActionController::Base
  require_dependency 'adventure_file'
  require_dependency 'encounter_file'
  require_dependency 'image'
  
  protect_from_forgery
  
  def self.static_pages *pages
    pages.each do |sym|
      define_method(sym) {}
    end
  end
end
