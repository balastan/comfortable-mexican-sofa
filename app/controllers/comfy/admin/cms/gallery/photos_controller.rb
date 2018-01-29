class Comfy::Admin::Cms::Gallery::PhotosController < Comfy::Admin::Cms::BaseController

  before_action :load_gallery
  before_action :load_photo,  :only => [:edit, :update, :destroy, :crop]
  before_action :build_photo, :only => [:new, :create]

  def index
    @photos = @gallery.photos
  end

  def new
    render
  end

  def create
    file_array  = gallery_photo_params[:image] || [nil]

    file_array.each_with_index do |file, i|
      file_params = gallery_photo_params.merge(:image => file)

      title = (file_params[:title].blank? && file_params[:image] ?
          file_params[:image].original_filename :
          file_params[:title]
      )
      title = title + " #{i + 1}" if file_params[:title] == title && file_array.size > 1

      @photo = Comfy::Cms::Gallery::Photo.new({:gallery => @gallery}.merge(file_params.merge(:title => title) || {}))
      @photo.save!
    end

    flash[:notice] = 'Photo created'
    redirect_to :action => :index
  rescue ActiveRecord::RecordInvalid
    flash[:error] = 'Failed to create Photo'
    render :action => :new
  end

  def edit
    render
  end

  def update
    @photo.update_attributes(gallery_photo_params)
    flash[:notice] = 'Photo updated'
    redirect_to :action => :index
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to updated Photo'
    render :action => :edit
  end

  def destroy
    @photo.destroy
    flash[:notice] = 'Photo deleted'
    redirect_to :action => :index
  end

  protected

  def load_gallery
    @gallery = Comfy::Cms::Gallery::Gallery.find(params[:gallery_id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Gallery not found'
    redirect_to admin_gallery_galleries_path
  end

  def load_photo
    @photo = @gallery.photos.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Photo not found'
    redirect_to :action => :index
  end

  def build_photo
    @photo = Comfy::Cms::Gallery::Photo.new({:gallery => @gallery}.merge(params[:sofa_gallery_photo] || {}))
  end

  def gallery_photo_params
    params.fetch(:gallery_photo, {}).permit!
  end

end