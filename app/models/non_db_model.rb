class NonDbModel
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Translation
  
  class << self
    alias non_yaml_attr attr_accessor
    attr_reader :types, :yaml_attrs
  end
  
  def self.yaml_attr(*syms)
    @yaml_attrs ||= []
    attr_accessor *syms
    @yaml_attrs += syms.map{|s| "@#{s}"}
  end  
  
  def initialize(attributes = {})  
    attributes = HashWithIndifferentAccess.new.merge attributes
            
    attributes.reject! {|k,v| v.blank?}
   
    if self.class.types
      self.class.types.each do |sym, type|
        send("#{sym}=", type.new(attributes[sym])) if attributes.include?(sym)
      end
    end
   
    attributes.each do |name, value|  
      send("#{name}=", value) unless send(name)
    end  
    
    if self.class.types
      self.class.types.each do |sym, type|
        send("#{sym}=", type.new) unless send(sym)
      end
    end
  end
  
  def self.declare_type(sym, type)
    @types ||= {}
    @types[sym] = type
  end
  

  
  def persisted?
    false
  end
  
  def to_yaml_properties
    self.class.yaml_attrs
  end
end