class AddPostsCountToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :posts_count, :integer, :default => 0
    add_index :channels, :posts_count
  end
end
