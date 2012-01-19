require 'test_helper'

class ExaltTest < ActiveRecord::TestCase
  should validate_presence_of :name
  should ensure_length_of(:name).is_at_most(100)
  should validate_presence_of :caste
  should allow_value("Solar").for :caste
  should allow_value("m").for :gender
  should allow_value("f").for :gender
  should_not allow_value("male").for :gender
end
