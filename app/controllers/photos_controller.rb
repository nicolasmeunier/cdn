class PhotosController < ActionController::Base
  layout "photo.haml"
  
  def index
    @photos = Photo.find :all
  end
  
end
