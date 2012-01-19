class ContributeController < ApplicationController
  
  static_pages :contribute, :example_encounter, :example_adventure
  
  #after_filter :log_page
  
  def log_page
    Rails.logger.info(response.body)
  end

  # GET - present form for creating a new Encounter
  def new_encounter
    @adventure = session[:adventure]
    
    if @adventure
      @encounter = EncounterFile.new(:adventure => @adventure.title.parameterize('_'),
                                     :author => @adventure.author,
                                     :author_link => @adventure.author_link,
                                     :xp_bracket => @adventure.xp_bracket)
                                     
      render 'new_adventure_encounter'
    else
      @encounter = EncounterFile.new(:adventure => :random,
                                     :author => session[:author],
                                     :author_link => session[:author_link])
                                     
      session[:encounter] = @encounter
      render 'new_encounter'
    end
  end
  
  # POST - process form for creating a new encounter
  def create_encounter
    @encounter = EncounterFile.new(params[:encounter_file])

    if @encounter.valid?
      session[:author] = @encounter.author
      session[:author_link] = @encounter.author_link
    
      if @encounter.resolutions.length == @encounter.num_resolutions
        # Usual if JS in enabled.
        encounter_complete
      else        
        # Encounter's fine, set up first Resolution
        session[:encounter] = @encounter
        redirect_to :action => 'new_resolution'
      end
    else
      @adventure = session[:adventure]
      
      if @adventure
        render 'new_adventure_encounter'
      else
        render 'new_encounter'
      end
    end
  end
  
  # GET - present form for a new resolution attached to an Encoutner
  def new_resolution
    @encounter = session[:encounter]
    unless @encounter
      flash[:alert] = "You need to be editing an Encounter to add a Resolution"
      redirect_to(:action => 'new_encounter') 
      return
    end
    
    @resolution = EncounterFile::Resolution.new
  end
  
  # POST - process form for creating a new Encounter
  def create_resolution
    @encounter = session[:encounter]
    @resolution = EncounterFile::Resolution.new(params[:encounter_file_resolution])
    
    if @resolution.valid?
      @encounter.resolutions << @resolution
      
      if @encounter.resolutions.length == @encounter.num_resolutions
        # Encounter has had all its Resolutions defined.
        encounter_complete
      else
        flash[:notice] = "Resolution added"
        redirect_to :action => 'new_resolution'
      end
    else
      render 'new_resolution'
    end
  end
  
  def new_adventure
    @adventure = AdventureFile.new(:author => session[:author],
                                   :author_link => session[:author_link])       
  end
  
  def create_adventure
    @adventure = AdventureFile.new(params[:adventure_file])

    if @adventure.valid?
      session[:author] = @adventure.author
      session[:author_link] = @adventure.author_link
    
      if @adventure.encounters.length == @adventure.num_encounters
        # Really shouldn't happen - but we may as well cope.
        ContributionsMailer.adventure(@adventure).deliver
        
        flash[:notice] = "Adventure '#{@adventure.title}' sent for approval"
        redirect_to 'thanks'
      else        
        @adventure.encounter_names = [:random] * @adventure.num_encounters
        @adventure.aux_encounter_names = []
        session[:adventure] = @adventure
        redirect_to :action => 'encounter_types'
      end
    else
      render 'new_adventure'
    end
  end
  
  def encounter_types
    @adventure = session[:adventure]
    
    unless @adventure
      flash[:alert] = "You need to be editing an Adventure to set the type of each Encounter"
      redirect_to(:action => 'new_adventure') 
      return
    end
  end
  
  def set_encounter_types
    @adventure = session[:adventure]
    
    params[:enc_type].map!{|t| t.downcase.to_sym}
    
    if params[:enc_type][-1] != :fixed
      flash[:alert] = "An Adventure needs the last Encounter, at least, to be a Fixed Encoutner"
      redirect_to :action => 'encounter_types'
      return
    end
    
    @adventure.encounter_names = params[:enc_type]
    
    redirect_to :action => 'new_encounter'
  end
  
  def res_fields_for_enc
    @encounter = session[:encounter]
    
    unless @encounter
      render :nothing => true
    else
      render :layout => false
    end
  end
  
  def new_res_fields_for_enc
    @encounter = EncounterFile.new
    @encounter.resolutions = [EncounterFile::Resolution.new]
    render 'res_fields_for_enc', :layout => false
  end
  
  def encounter_preview
    @encounter = EncounterFile.new(params[:encounter_file])
    render :partial => "exalted/encounter", :layout => false, :object => @encounter, :locals => {:options => {:demo => true}}
  end
  
  def enc_fields_for_adv
    @adventure = session[:adventure] || AdventureFile.new
    @adventure.encounters = [EncounterFile.new]
    
    unless @adventure
      render :nothing => true
    else
      render :layout => false
    end
  end
  
  def new_enc_fields_for_adv
    @adventure = AdventureFile.new
    @adventure.encounters = [EncounterFile.new]
    render 'enc_fields_for_adv', :layout => false
  end
  
  def adventure_preview
    @adventure = AdventureFile.new(params[:adventure_file])
    #render :partial => "exalted/adventure", :layout => false, :object => @encounter, :locals => {:options => {:demo => true}}
  end

private
  def encounter_complete
    if session[:adventure]
      # Encounter is part of an Adventure. Determine whether it's Fixed or Auxilliary          
      @adventure = session[:adventure]
      
      ix = @adventure.encounter_names.index(:fixed)
      if ix
        # Still got undefined fixed encounters, so this is one.
        @adventure.encounters[@encounter.title.parameterize('_')] = @encounter
        @adventure.encounter_names[ix] = @encounter.title.parameterize('_')
        
        if !@adventure.encounter_names.index(:fixed)
          # All fixed encounters defined. Move on to Auxilliary Encounters
          if @adventure.num_aux_encounters != 0
            flash[:notice] = "Encounter '#{@encounter.title}' added to Adventure '#{@adventure.title}'"
            redirect_to :action => 'new_encounter'
          else
            # No Auxilliary Encounters to do. Send adventure for approval
            ContributionsMailer.adventure(@adventure).deliver
      
            flash[:notice] = "Adventure '#{@adventure.title}' sent for approval"        
            redirect_to :action => 'thanks'
          end
        else
          flash[:notice] = "Encounter '#{@encounter.title}' added to Adventure '#{@adventure.title}'"
          redirect_to :action => 'new_encounter'
        end
      else
        # This is an Auxiliary encounter
        @adventure.aux_encounters[@encounter.title.parameterize('_')] = @encounter
        @adventure.aux_encounter_names << @encounter.title.parameterize('_')
        
        if @adventure.aux_encounter_names.length == @adventure.num_aux_encounters
          # All done. Send adventure for approval
          ContributionsMailer.adventure(@adventure).deliver
    
          flash[:notice] = "Adventure '#{@adventure.title}' sent for approval"        
          redirect_to :action => 'thanks'
        else
          # More Aux Encounters to add
          flash[:notice] = "Auxiliary Encounter '#{@encounter.title}' added to Adventure '#{@adventure.title}'"
          redirect_to :action => 'new_encounter'
        end
      end
    else
      ContributionsMailer.random_enc(@encounter).deliver
      
      flash[:notice] = "Random Encounter '#{@encounter.title}' sent for approval"
      redirect_to :action => 'thanks'
    end
  end
  
end
