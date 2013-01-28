class AddPostsCountToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :posts_count, :integer
    add_index :channels, :posts_count
  end
end
