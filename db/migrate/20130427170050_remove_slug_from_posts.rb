class RemoveSlugFromPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :slug
  end
end
