class ExaltsController < ApplicationController
  # GET /exalts
  # GET /exalts.json
  def index
    @exalts = Exalt.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @exalts }
    end
  end

  # GET /exalts/1
  # GET /exalts/1.json
  def show
    @exalt = Exalt.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @exalt }
    end
  end

  # GET /exalts/new
  # GET /exalts/new.json
  def new
    @exalt = Exalt.new(:type => "Solar")

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @exalt }
    end
  end

  # GET /exalts/1/edit
  def edit
    @exalt = Exalt.find(params[:id])
  end

  # POST /exalts
  # POST /exalts.json
  def create
    @exalt = Exalt.new(params[:exalt])

    respond_to do |format|
      if @exalt.save
        format.html { redirect_to @exalt, notice: 'Exalt was successfully created.' }
        format.json { render json: @exalt, status: :created, location: @exalt }
      else
        format.html { render action: "new" }
        format.json { render json: @exalt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /exalts/1
  # PUT /exalts/1.json
  def update
    @exalt = Exalt.find(params[:id])

    respond_to do |format|
      if @exalt.update_attributes(params[:exalt])
        format.html { redirect_to @exalt, notice: 'Exalt was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @exalt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exalts/1
  # DELETE /exalts/1.json
  def destroy
    @exalt = Exalt.find(params[:id])
    @exalt.destroy

    respond_to do |format|
      format.html { redirect_to exalts_url }
      format.json { head :ok }
    end
  end
end
