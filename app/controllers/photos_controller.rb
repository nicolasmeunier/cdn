class PhotosController < ActionController::Base
  def index
    @photos = Photo.find :all
  end
  
end
