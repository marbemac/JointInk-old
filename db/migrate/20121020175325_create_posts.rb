class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.timestamps
      t.string :title
      t.string :slug
      t.text :content, :limit => nil
      t.string :status, :default => 'active'
      t.text :url, :limit => nil
      t.string :post_type, :default => 'text'
      t.string :post_subtype, :default => 'article'
      t.string :photo, :default => nil
      t.integer :photo_width, :default => nil
      t.integer :photo_height, :default => nil
      t.references :user
      t.references :channel
    end

    add_index :posts, :post_type
    add_index :posts, :slug, :unique => true
    add_index :posts, :user_id
    add_index :posts, :channel_id
  end
end
