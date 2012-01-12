class ExaltedController < ApplicationController
  #before_filter :authenticate_user!, :except => [:root]  

  unless Rails.env.production?
    def clear_session
      reset_session
      render :text => "Session cleared"
    end
  end
  
  def root
    #if current_user
    #  redirect_to :action => "campfire"
    #end
  end
  
  def campfire
    @user = current_user
    @exalt = @user.exalt
    @old_exalts = @user.old_exalts
  end
  
end
