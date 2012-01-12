require 'test_helper'

class SolarTest < ActiveRecord::TestCase
  %w<Dawn Zenith Twilight Night Eclipse>.each {|caste| should allow_value(caste).for :caste}
  %w<Air Water Dusk Day No\ Moon Journeys Endings>.each {|caste| should_not allow_value(caste).for :caste}
end