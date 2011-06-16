class CreatePhotoTable < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.string :title
      t.string :image_url_640
      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
 
