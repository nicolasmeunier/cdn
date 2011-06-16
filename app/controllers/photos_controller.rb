class PhotoController < ActionController::Base
  def photos
    @photos = photos.find :all
  end
  
end
