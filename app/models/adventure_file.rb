class AdventureFile < NonDbModel
  # YAML attribs
  yaml_attr :title, :summary, :author, :author_link, :encounter_names, :aux_encounter_names, :xp_bracket, :image
  declare_type :image, Image
  
  # Non-YAML attribs
  non_yaml_attr :num_encounters, :num_aux_encounters, :encounters, :aux_encounters
  
  validates_presence_of :author, :summary, :title, :xp_bracket
  validates_inclusion_of :xp_bracket, :in => XpBrackets.keys
  validates :num_encounters, :numericality => {:greater_than_or_equal_to => 1, :less_than_or_equal_to => 15}, :allow_blank => true
  validates :num_aux_encounters, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 15}, :allow_blank => true
  validate :image_valid
  
  def initialize(attributes = {})
    attributes = HashWithIndifferentAccess.new.merge attributes

    enc_attrs = attributes.delete(:encounters) || []    
    self.encounters = {}
    enc_attrs.each do |enc_p| 
      enc = EncounterFile.new(enc_p)
      self.encounters[enc.title.parameterize('_')] = enc
    end
    
    aux_enc_attrs = attributes.delete(:aux_encounters) || []    
    self.aux_encounters = {}
    aux_enc_attrs.each do |enc_p| 
      enc = EncounterFile.new(enc_p)
      self.aux_encounters[enc.title.parameterize('_')] = enc
    end
    
    # Convert :xp_bracket to a symbol
    attributes[:xp_bracket] &&= attributes[:xp_bracket].to_sym
    
    super attributes
    self.num_encounters = num_encounters.to_i
    self.num_aux_encounters = num_aux_encounters.to_i
  end
  
private
  def image_valid
    unless image.valid?
      image.errors.each {|att, err| errors.add(:"image_#{att}", err)}
    end
  end
end