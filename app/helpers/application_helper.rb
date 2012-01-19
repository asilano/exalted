module ApplicationHelper

  def self.included(mod)
    include ViewMethods
    include UtilMethods
  end
  
  module UtilMethods
    def title_to_filename(title, extn = "")
      title.titleize.gsub(/\s/,'').underscore + extn
    end
  end
  
  module ViewMethods
    def artist_link(image)
      if image.artist_link
        link_to image.artist, image.artist_link
      else
        image.artist
      end
    end      
  end
  
end
