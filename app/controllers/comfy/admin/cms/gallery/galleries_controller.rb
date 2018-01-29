class Comfy::Admin::Cms::Gallery::GalleriesController < Comfy::Admin::Cms::BaseController

  before_action :load_gallery,  :except => [:index, :new, :create, :reorder]
  before_action :build_gallery, :only   => [:new, :create]

  def index
    if params[:category].present?
      @galleries = Comfy::Cms::Gallery::Gallery.for_category(params[:category]).all
    else
      @galleries = Comfy::Cms::Gallery::Gallery.all
    end
    @galleries = comfy_paginate(@galleries, 50)
  end

  def new
    render
  end

  def create
    @gallery.save!
    flash[:notice] = I18n.t('comfy.admin.cms.gallery.galleries.created')
    redirect_to :action => :index
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to create Gallery'
    render :action => :new
  end

  def show
    render
  end

  def edit
    render
  end

  def update
    @gallery.update_attributes!(gallery_params)
    flash[:notice] = I18n.t('comfy.admin.cms.gallery.galleries.updated')
    redirect_to :action => :index
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to update Gallery'
    render :action => :edit
  end

  def destroy
    @gallery.destroy
    flash[:notice] = 'Gallery deleted'
    redirect_to :action => :index
  end

  protected

  def load_gallery
    @gallery = Comfy::Cms::Gallery::Gallery.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Gallery not found'
    redirect_to :action => :index
  end

  def build_gallery
    @gallery = Comfy::Cms::Gallery::Gallery.new(gallery_params)
  end

  def gallery_params
    params.fetch(:gallery, {}).permit!
  end

end