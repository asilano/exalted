class Image < NonDbModel
  yaml_attr :file, :artist, :artist_link, :licence
  
  validates_presence_of :artist, :licence, :unless => Proc.new{|im| im.file.blank?}
end