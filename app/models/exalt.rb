class Exalt < ActiveRecord::Base
  validates_presence_of :name
  validates_length_of :name, :maximum => 100
  validates_presence_of :caste
  validates_presence_of :type
  validates_inclusion_of :type, :in => %w<Solar>
  validates_inclusion_of :gender, :in => %w<m f>
  
  attr_accessor :attributes
  
  validate do |ex|
    errors.add(:attributes, "Blah")
  end
  
end
