class AddStyleToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :style, :string, :default => 'default'
  end
end
