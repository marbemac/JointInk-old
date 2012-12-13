class AddPhotoDataToPost < ActiveRecord::Migration
  def change
    add_column :posts, :photo_public_id, :string
    add_column :posts, :photo_exif, :hstore
  end
end
