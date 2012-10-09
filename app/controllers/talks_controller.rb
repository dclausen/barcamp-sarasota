class TalksController < ApplicationController
  before_filter :login_required, :except => [ :index, :show ]

  def index
    respond_to do |format|
      format.html do
        @day = Talk.logical_day
        @talks = Talk.all(:conditions => ["day = ?", @day], :include => :room, :with_deleted => false, :order => "day, start_time")
      end

      format.json do
        @talks = Talk.all(:include => :room, :with_deleted => false, :order => "day, start_time")
      end
    end
  end

  def new
    @talk = Talk.new
  end

  def create
    @talk = Talk.create(params[:talk])
    if @talk.save
      flash[:notice] = "Talk created"
      redirect_to talks_path
    else
      render :action => "new"
    end
  end

  def show
    @talk = Talk.find(params[:id])

    render_missing and return unless @talk

    render :action => "show"
  end

  def edit
    @talk = Talk.find(params[:id])
  end

  def update
    @talk = Talk.find(params[:id])
    @talk.update_attributes(params[:talk])
    if @talk.save
      flash[:notice] = "Talk updated"
      redirect_to root_path
    else
      render :action => "edit"
    end
  end

  def destroy
    Talk.destroy(params[:id])
    redirect_to talks_path
  end
end
