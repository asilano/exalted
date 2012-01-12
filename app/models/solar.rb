class Solar < Exalt
  validates_inclusion_of :caste, :in => %w<Dawn Zenith Twilight Night Eclipse>
end