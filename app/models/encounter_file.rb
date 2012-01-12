class EncounterFile < NonDbModel  
  class Resolution < NonDbModel
    yaml_attr :success, :failure, :botch, :text, :test    
    
    class Outcome < NonDbModel  
      yaml_attr :text, :effect
      validates_presence_of :text, :effect
    end
    
    [:success, :failure, :botch].each {|sym| declare_type(sym, Outcome)}
    
    validates_presence_of :text, :test
    validate :results_valid
    
  private
    def results_valid
      unless success.valid?
        success.errors.each {|att, err| errors.add :"success_#{att}", err}
      end
      
      unless failure.valid?
        failure.errors.each {|att, err| errors.add :"failure_#{att}", err}
      end
      
      unless (botch.text.blank? && botch.effect.blank?)
        unless botch.valid?
          errors.add :botch, :xor
        end
      end
    end
  end  
  
  # YAML attribs
  yaml_attr :author, :author_link, :text, :resolutions, :notes, :image, :xp_bracket, :adventure
  declare_type :image, Image
  
  # Non-YAML attribs
  non_yaml_attr :title, :num_resolutions
                
  validates_presence_of :author, :text, :adventure, :title, :xp_bracket
  validates_inclusion_of :xp_bracket, :in => XpBrackets.keys
  validates :num_resolutions, :numericality => {:greater_than_or_equal_to => 1, :less_than_or_equal_to => 5}, :allow_blank => true
  validate :image_valid
                
  def initialize(attributes = {})
    attributes = HashWithIndifferentAccess.new.merge attributes

    res_attrs = attributes.delete(:resolutions) || []        
    self.resolutions = res_attrs.map {|res_p| Resolution.new(res_p)}
    
    # Convert :xp_bracket to a symbol
    attributes[:xp_bracket] &&= attributes[:xp_bracket].to_sym
    attributes[:adventure] = :random if attributes[:adventure] == "random"
    
    super attributes
    self.num_resolutions = num_resolutions.to_i
  end
  
private
  def image_valid
    unless image.valid?
      image.errors.each {|att, err| errors.add(:"image_#{att}", err)}
    end
  end
end